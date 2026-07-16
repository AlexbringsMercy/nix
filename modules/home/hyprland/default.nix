{ pkgs, ... }:

let
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
in
{
  home.packages = [
    rofiToggle
    screenshotArea
    screenshotFull
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
    "hypr/hyprland" = {
      source = ./hyprland;
      recursive = true;
    };
  };
}
