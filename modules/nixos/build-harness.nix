# BUILD-PERIOD SCAFFOLDING — remove at Stage 10 acceptance (GRAND_PLAN §10),
# together with scripts/aurora-resume-agent and its autostart hook. The §7.5
# sudo session switch supersedes this for daily use from Stage 8.
#
# Operator-requested 2026-07-21: lets the build agent deploy and reboot without
# a password across the whole build. Scoped to the exact deploy verbs — any
# command off this list still prompts, which keeps a confused agent from doing
# anything worse than a deploy.
{ ... }:
{
  security.sudo.extraRules = [
    {
      users = [ "alex" ];
      commands = [
        { command = "/run/current-system/sw/bin/nix-env"; options = [ "NOPASSWD" ]; }
        { command = "/nix/var/nix/profiles/system/bin/switch-to-configuration"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl reboot"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/reboot"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl poweroff"; options = [ "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/nix-collect-garbage"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
