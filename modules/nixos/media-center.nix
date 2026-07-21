# Ported verbatim from the channel config (/etc/nixos/configuration.nix, 2026-07-19)
# during Stage 0 reconcile — GRAND_PLAN.md §8.7. The flake is the sole authority
# from this commit forward.
{ ... }:
{
  # Allow ALL traffic to/from the living-room LG TV, both directions.
  # Matched by the TV's MAC address so it keeps working even if the eero
  # assigns the TV a different IP. (Outbound is already unrestricted; this
  # opens inbound, so Jellyfin/DLNA/SSAP on this PC are reachable by the TV.)
  networking.firewall.extraCommands = ''
    iptables -I nixos-fw 1 -m mac --mac-source 40:2f:86:81:26:3e -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -m mac --mac-source 40:2f:86:81:26:3e -j nixos-fw-accept 2>/dev/null || true
  '';

  # Plex removed 2026-07-21 (operator decision): Jellyfin/Moonfin is the media
  # stack. Plex was a channel-era leftover mistakenly ported in Stage 0 — it is
  # not used, and its scan/transcode jobs were burning compute and blocking
  # reboots at service-stop. The user-dir Moonfin/Jellyfin stack is untouched.
}
