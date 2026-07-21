{ pkgs, ... }:
{
  imports = [
    ../../modules/home/packages.nix
    ../../modules/home/hyprland
    ../../modules/home/kitty
    # Aurora: the vendored chassis replaces the Waybar, Rofi, and old QuickShell surfaces.
    ../../modules/home/theming
    # Aurora: wallpaper rendering retires now; the surviving theming backends remain imported above.
    ../../modules/home/desktop-apps.nix
    ../../modules/home/fish.nix
    ../../modules/home/lock
  ];

  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "26.11";
    sessionPath = [ "$HOME/.npm-global/bin" ];
  };

  xdg.enable = true;
  fonts.fontconfig.enable = true;

  programs.aurora-shell.enable = true; # Aurora: make the vendored chassis Alex's active declared shell.
  programs.aurora-shell.cli.enable = true; # Aurora: retain the internal caelestia CLI alongside the shell package.
  # Aurora: relax caelestia's aggressive idle defaults (operator, 2026-07-21). Stock
  # is lock@180s / dpms@300s / suspendThenHibernate@600s — the 3-min lock nuisance,
  # and auto-suspend is unsafe on this T2 until the Stage 7 suspend gate. Lock at
  # 20 min, DPMS at 25 min, no auto-suspend. (This is the sole shell.json key at v1.)
  programs.aurora-shell.settings = {
    general.idle.timeouts = [
      {
        timeout = 1200;
        idleAction = "lock";
      }
      {
        timeout = 1500;
        idleAction = "dpms off";
      }
    ];
  };

  home.activation.createDesktopDirectories = ''
    run mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"
  '';

  programs.home-manager.enable = true;
}
