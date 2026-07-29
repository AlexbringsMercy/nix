{ pkgs, ... }:
{
  # Aurora: awww, rofi, waybar and waypaper are retired here. Nothing live
  # referenced them — the only remaining mentions are matugen templates, which
  # render text and never execute either program, and scripts/apply-wallpaper,
  # which is not packaged into any deployed derivation. The matugen templates
  # and the Dunst fallback stay until Stage 4 replaces the theming pipeline.
  home.packages = with pkgs; [
    bluez
    brightnessctl
    cava
    dunst
    easyeffects
    gh
    grim # Aurora: the Print capture path — aurora-shell's Screenshotter runs it directly. Do not remove.
    hypridle
    hyprlock
    libnotify
    matugen
    mission-center
    networkmanagerapplet
    playerctl
    power-profiles-daemon
    pwvucontrol
    quickshell
    slurp # Aurora: still required by caelestia record -r, which only reads a geometry.
    wireplumber
    wl-clipboard
    wlogout
    xdg-utils
  ];
}
