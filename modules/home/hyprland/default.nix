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

  hyprbarsLua = pkgs.writeText "aurora-hyprbars.lua" ( # Aurora: generate a Lua module containing the immutable plugin store path.
    builtins.replaceStrings [ "@HYPRBARS_PLUGIN@" ] [ "${patchedHyprbars}/lib/libhyprbars.so" ] ( # Aurora: load the locally patched, ABI-matched hyprbars output.
      builtins.readFile ./hyprbars.lua.in # Aurora: preserve the readable Lua source outside the recursively deployed tree.
    ) # Aurora: finish the template substitution input.
  ); # Aurora: publish the generated early-load module.

  windowMinimize = pkgs.writeShellApplication { # Aurora: package the per-window special-workspace minimize helper.
    name = "window-minimize"; # Aurora: give hyprbars and the restore bind one stable command name.
    runtimeInputs = with pkgs; [ # Aurora: provide every external command used by the vendored behavior.
      coreutils # Aurora: state-file creation and LIFO selection.
      hyprland # Aurora: query clients and dispatch silent workspace moves.
      jq # Aurora: parse active-window and live-client JSON.
      gawk # Aurora: field extraction in the upstream LIFO restore path.
      gnused # Aurora: strip blank lines when rewriting the store file.
      gnugrep # Aurora: match minimized addresses against the live client set.
    ]; # Aurora: close the minimize helper runtime set.
    text = builtins.readFile ../../../scripts/window-minimize; # Aurora: keep the community-derived behavior reviewable in scripts/.
  }; # Aurora: finish the minimize helper package.

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
    windowMinimize # Aurora: place minimize/restore on PATH for hyprbars and keybinds.
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
