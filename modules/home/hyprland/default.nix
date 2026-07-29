{ pkgs, ... }:

let
  hyprbarsSource = pkgs.fetchFromGitHub { # Aurora: expose the full ABI-compatible v0.55.0 repository as the -p1 patch root.
    owner = "hyprwm"; # Aurora: use the official hyprland-plugins repository.
    repo = "hyprland-plugins"; # Aurora: fetch the repository containing the v0.55.0 hyprbars subtree.
    rev = "90e66baf99c9025b1d5e9c9e58dd3c80d0911ea2"; # Aurora: exact v0.55.0 tag used by nixpkgs' Hyprland 0.55 plugin set.
    hash = "sha256-WMUJ7tyw/9QbKUyRzLndEQSqX05fQLmFlRdMAmPD7tI="; # Aurora: v0.55.0 hyprland-plugins source hash (PM-filled from the build).
  }; # Aurora: finish the pinned v0.55.0 hyprland-plugins source.

  patchedHyprbars = pkgs.hyprlandPlugins.hyprbars.overrideAttrs (_: { # Aurora: retain nixpkgs' Hyprland inputs while replacing only hyprbars source and patching it.
    src = hyprbarsSource; # Aurora: nixpkgs' subtree src cannot resolve the required a/hyprbars/ paths with its default -p1 patch phase.
    cmakeDir = "../hyprbars"; # Aurora: after patching from the repository root, configure only the ABI-compatible v0.55.0 hyprbars subtree.
    patches = [ ./patches/hyprbars-hover.patch ]; # Aurora: add the audited hover-highlight implementation.
  }); # Aurora: finish the ABI-matched patched hyprbars derivation.

  patchedAuroraMinimize = pkgs.hyprlandPlugins.mkHyprlandPlugin { # Aurora: same ABI-pinned builder patchedHyprbars relies on (hyprlandPlugins.mkHyprlandPlugin links against topLevelArgs.hyprland's own stdenv/buildInputs), applied to our own bespoke source instead of an overridden upstream plugin.
    pluginName = "aurora-minimize"; # Aurora: same-workspace minimize/restore dispatchers + Lua bindings; generalizes Hyprland's own toggleSwallow mechanism (see aurora-minimize/main.cpp).
    version = "0.1";
    src = ./aurora-minimize; # Aurora: bespoke Aurora glue, not vendored -- CMakeLists.txt mirrors hyprbars' own module list.
    inherit (pkgs.hyprland) nativeBuildInputs; # Aurora: pin the build toolchain (cmake, ninja, ...) to the exact compositor build's own inputs, matching patchedHyprbars.
    meta = with pkgs.lib; {
      description = "Aurora same-workspace minimize/restore plugin for Hyprland";
      platforms = platforms.linux;
    };
  }; # Aurora: finish the ABI-matched aurora-minimize derivation.

  hyprbarsLua = pkgs.writeText "aurora-hyprbars.lua" ( # Aurora: generate a Lua module containing the immutable plugin store paths.
    builtins.replaceStrings
      [ "@HYPRBARS_PLUGIN@" "@AURORA_MINIMIZE_PLUGIN@" ]
      [ "${patchedHyprbars}/lib/libhyprbars.so" "${patchedAuroraMinimize}/lib/libaurora-minimize.so" ] ( # Aurora: load both locally built, ABI-matched plugin outputs.
      builtins.readFile ./hyprbars.lua.in # Aurora: preserve the readable Lua source outside the recursively deployed tree.
    ) # Aurora: finish the template substitution input.
  ); # Aurora: publish the generated early-load module.

  # Aurora: the interim screenshot-area / screenshot-full wrappers are retired.
  # Both capture paths now live in the shell (aurora-shell modules/areapicker),
  # bound through caelestia:screenshot and caelestia:screenshotFull, so no
  # slurp-selection overlay can be composited into a saved frame.
  # Aurora: the rofi-toggle wrapper is retired with rofi itself; every launcher
  # bind has run through caelestia:launcher since 29fedce.

  # Build-period scaffolding — removed at Stage 10 together with
  # modules/nixos/build-harness.nix.
  auroraResumeAgent = pkgs.writeShellApplication {
    name = "aurora-resume-agent";
    runtimeInputs = with pkgs; [ coreutils ];
    text = builtins.readFile ../../../scripts/aurora-resume-agent;
  };
in
{
  home.packages = [
    auroraResumeAgent
  ];

  # systemd's graphical-session targets intentionally refuse direct manual
  # starts. This compositor-owned wrapper pulls them in as dependencies and
  # gives raw start-hyprland sessions the same clean service lifecycle a full
  # desktop environment would provide.
  systemd.user.targets.hyprland-session.Unit = {
    Description = "Hyprland graphical session";
    Requires = [
      "graphical-session-pre.target"
      "graphical-session.target"
    ];
    After = [ "graphical-session-pre.target" ];
    Before = [ "graphical-session.target" ];
  };

  # Hyprland 0.55+ reads this native Lua entry point.  Keeping the modules as
  # individual files makes parser errors local and future hardware overrides
  # straightforward.
  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hyprland.lua;
    "hypr/hyprbars.lua".source = hyprbarsLua; # Aurora: load the Nix-templated plugin module through Lua require.
    "hypr/hyprland" = {
      source = ./hyprland;
      recursive = true;
    };
  };
}
