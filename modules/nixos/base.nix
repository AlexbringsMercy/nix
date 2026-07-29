{ inputs, pkgs, ... }: # Aurora: consume the flake inputs already supplied through nixosSystem.specialArgs.
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";

  # Boot-readiness ordering (Stage 2 fix, 2026-07-29 — see ISSUE_LOG §28 and
  # ~/.local/state/aurora-build/pm/stage2-boot-readiness.md). This T2 Mac's
  # RTC reads back 1970-01-05 at boot, so the wall clock starts wrong and is
  # only corrected once systemd-timesyncd reaches a real NTP server tens of
  # seconds later; anything making an outbound TLS connection before that
  # correction sees "SSL certificate is not yet valid" (proven directly from
  # this boot's own logs, not inferred).
  #
  # `time-sync.target` already ships as one of NixOS's default upstream
  # units, but nothing populates it: confirmed live that it sits
  # `inactive (dead)` even once the clock is actually synchronized, because
  # the one thing that's supposed to report to it — systemd-time-wait-sync.service
  # — isn't enabled by default (upstream ships it only as an example unit).
  # Enabling it is the systemd-native "wait until the kernel clock is
  # synchronized" primitive the task asked us to evaluate, and gives both the
  # system and user-session tooling (scripts/aurora-resume-agent) a real
  # `systemctl is-active time-sync.target` / is-synchronized signal instead of
  # a target that is vacuously never reached.
  #
  # Upstream ships this unit with TimeoutStartSec=infinity by design ("leave
  # it to local modifications to make it work for the remaining cases" — its
  # own comment). That default is a real risk on this exact machine: the
  # 2026-07-29 boot log shows the wired connection profile failing to
  # activate repeatedly for the entire session (still retrying an hour in),
  # so a boot that never reaches a wired or wifi connection must not wait on
  # NTP forever. Capped to the same 60s bound aurora-resume-agent's own
  # readiness wait uses, so a network-less boot still reaches a login prompt.
  #
  # Deliberately NOT wiring network-online.target into multi-user.target here
  # even though it has the identical "never activated" problem (confirmed:
  # also `inactive (dead)` right now) — doing so would add that same flaky
  # wired-connection retry loop to the critical path of every boot, deferring
  # the login screen itself, which nobody asked for. The resume script
  # queries `nm-online -x -q` directly instead (the same primitive
  # NetworkManager-wait-online.service uses), bounded by its own wait loop,
  # without changing system-wide boot ordering. Flagged here for the PM to
  # weigh independently.
  systemd.additionalUpstreamSystemUnits = [ "systemd-time-wait-sync.service" ];
  systemd.services.systemd-time-wait-sync = {
    wantedBy = [ "sysinit.target" ];
    serviceConfig.TimeoutStartSec = "60s";
  };

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
