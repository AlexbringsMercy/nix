# This file mirrors the generated hardware configuration that was active before
# the flake migration. Filesystem UUIDs are machine-specific invariants.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0169e805-8ebf-44a0-9c80-e77534d1cc47";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5F66-17ED";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  # 7.45 GiB gap freed by shrinking the macOS APFS container on 2026-09-09
  # (nvme0n1p4). Disk swap at low priority: zram (priority 100) fills first,
  # this catches the overflow that used to OOM-freeze the 7.6 GB laptop.
  # When macOS is reinstalled fresh the gap grows and /nix moves there.
  swapDevices = [
    {
      device = "/dev/disk/by-label/nixswap";
      priority = 10;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
