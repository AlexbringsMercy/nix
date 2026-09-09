{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/t2-firmware.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/laptop-power.nix
    ../../modules/nixos/media-center.nix
    ../../modules/nixos/build-harness.nix
    ../../modules/nixos/dev-virtualisation.nix
  ];

  networking.hostName = "macbook";
  system.stateVersion = "26.11";
}
