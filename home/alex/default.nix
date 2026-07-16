{ pkgs, ... }:
{
  imports = [
    ../../modules/home/packages.nix
    ../../modules/home/hyprland
    ../../modules/home/waybar
    ../../modules/home/kitty
    ../../modules/home/rofi
    ../../modules/home/quickshell
    ../../modules/home/theming
    ../../modules/home/wallpaper
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

  home.activation.createDesktopDirectories = ''
    run mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"
  '';

  programs.home-manager.enable = true;
}
