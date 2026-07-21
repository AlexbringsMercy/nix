{ pkgs, ... }:

let
  hyprbarsLua = pkgs.writeText "aurora-hyprbars.lua" ( # Aurora: generate a Lua module containing the immutable plugin store path.
    builtins.replaceStrings [ "@HYPRBARS_PLUGIN@" ] [ "${pkgs.hyprlandPlugins.hyprbars}/lib/libhyprbars.so" ] ( # Aurora: keep ABI-matched hyprbars in the deployed closure.
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

  screenshotArea = pkgs.writeShellApplication {
    name = "screenshot-area";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      jq
      libnotify
      slurp
      wl-clipboard
    ];
    text = builtins.readFile ../../../scripts/screenshot-area;
  };

  screenshotFull = pkgs.writeShellApplication {
    name = "screenshot-full";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      libnotify
      wl-clipboard
    ];
    text = builtins.readFile ../../../scripts/screenshot-full;
  };

  rofiToggle = pkgs.writeShellApplication {
    name = "rofi-toggle";
    runtimeInputs = with pkgs; [
      procps
      rofi
    ];
    text = builtins.readFile ../../../scripts/rofi-toggle;
  };

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
    rofiToggle
    screenshotArea
    screenshotFull
    windowMinimize # Aurora: place minimize/restore on PATH for hyprbars and keybinds.
  ];

  services.swayosd = {
    enable = true;
    topMargin = 0.08;
    stylePath = ./swayosd.css;
  };

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
