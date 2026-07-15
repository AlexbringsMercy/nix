{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      "${builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/main.tar.gz"}/apple/t2"
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.hostName = "macbook";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git nano curl wget kitty
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

  services.openssh.enable = true;

  system.stateVersion = "26.11";
}
