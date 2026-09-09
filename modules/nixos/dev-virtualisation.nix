{ pkgs, ... }:
# System-level half of Alex's workstation tooling plan: the Docker daemon and
# non-root packet capture, which cannot be granted from Home Manager alone.
# The corresponding CLI front ends (docker-compose, docker-buildx, kubectl,
# tshark itself, …) are user-scope Home Manager packages in
# modules/home/cloud-infra.nix and modules/home/security-tooling.nix.
{
  virtualisation.docker.enable = true;
  users.users.alex.extraGroups = [
    "docker"
    "wireshark"
  ];

  # Non-root tshark/dumpcap capture: installs a setcap'd dumpcap wrapper and
  # creates the `wireshark` group, instead of requiring sudo for every capture.
  programs.wireshark.enable = true;

  # Extra font coverage the plan asked for beyond what modules/nixos/desktop.nix
  # already ships (inter, noto-fonts, noto-fonts-color-emoji, fira-code,
  # nerd-fonts.fira-code).
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    liberation_ttf
    dejavu_fonts
  ];
}
