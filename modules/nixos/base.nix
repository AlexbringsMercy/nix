{ inputs, pkgs, ... }: # Aurora: consume the flake inputs already supplied through nixosSystem.specialArgs.
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  users.users.alex = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];
  };

  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  programs.dconf.enable = true;

  services.openssh.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    nano
    nodejs_22
    wget
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-before-aurora";
    extraSpecialArgs = { };
    sharedModules = [ inputs.aurora-shell.homeManagerModules.default ]; # Aurora: teach every integrated Home Manager user the aurora-shell options.
    users.alex = import ../../home/alex;
  };
}
