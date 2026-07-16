{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/t2-firmware.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/laptop-power.nix
  ];

  networking.hostName = "macbook";
  system.stateVersion = "26.11";
}
