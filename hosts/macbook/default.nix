{ inputs, ... }:
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

  # Keep the integrated Home Manager graph able to build the editor wrapper
  # from the same pinned flake inputs as standalone Home Manager.
  home-manager.extraSpecialArgs = { inherit inputs; };
}
