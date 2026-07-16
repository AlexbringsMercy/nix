{
  firmwareSource,
  lib,
  pkgs,
  ...
}:
{
  warnings = lib.optional (firmwareSource == null) ''
    The portable macbook output omits machine-local Broadcom firmware. Build
    /home/alex/.config/nixos-local instead when installing this host.
  '';

  hardware.firmware = lib.optionals (firmwareSource != null) [
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "apple-t2-brcm-firmware";
      version = "local";
      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        install -d "$out/lib/firmware/brcm"
        cp -R ${firmwareSource}/. "$out/lib/firmware/brcm/"
        runHook postInstall
      '';
    })
  ];
}
