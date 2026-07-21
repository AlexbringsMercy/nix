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

  # Plex Media Server (test — proprietary/account-gated; evaluating DV Direct Play).
  # Runs as 'alex' so it can read media under /home/alex. Reachable by the TV via
  # the firewall MAC rule above. (allowUnfree lives in base.nix.)
  services.plex = {
    enable = true;
    user = "alex";
    group = "users";
    openFirewall = true;
  };
}
