{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      "${builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz"}/apple/t2"
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "macbook";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  nixpkgs.config.allowUnfree = true;

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Graphical environment
  programs.hyprland.enable = true;

  # Auto-login to Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "alex";
      };
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-nerdfont
  ];

  environment.systemPackages = with pkgs; [
    git nano curl wget
    kitty google-chrome
    nodejs_22 fish
    waybar rofi-wayland
    wl-clipboard grim slurp
  ];

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "brcm-firmware";
      buildCommand = ''
        dir="$out/lib/firmware"
        mkdir -p "$dir"
        cp -r ${/etc/nixos/firmware/brcm} "$dir/brcm"
      '';
    })
  ];

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "26.11";
}
