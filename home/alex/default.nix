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
  programs.aurora-shell.settings = { }; # Aurora: stop Home Manager from replacing mutable shell.json with a read-only store symlink.

  home.activation.createDesktopDirectories = ''
    run mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"
  '';

  programs.home-manager.enable = true;
}
