{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aurora.quickshell;

  runtimePath = lib.makeBinPath [
    pkgs.bash
    pkgs.blueman
    pkgs.bluez
    pkgs.brightnessctl
    pkgs.cava
    pkgs.coreutils
    pkgs.curl
    pkgs.dunst
    pkgs.easyeffects
    pkgs.hyprlock
    pkgs.iproute2
    pkgs.jq
    pkgs.networkmanagerapplet
    pkgs.power-profiles-daemon
    pkgs.pwvucontrol
    pkgs.systemd
    pkgs.util-linux
    pkgs.waypaper
  ];
in
{
  options.aurora.quickshell.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable the Aurora QuickShell control and notification layer.";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."quickshell/aurora-shell".source = ./config;

    home.packages = [
      pkgs.blueman
      pkgs.brightnessctl
      pkgs.dunst
      pkgs.hyprlock
      pkgs.networkmanagerapplet
      pkgs.power-profiles-daemon
      pkgs.pwvucontrol
      pkgs.quickshell
    ];

    systemd.user.services.aurora-shell = {
      Unit = {
        Description = "Aurora QuickShell control and notification layer";
        Documentation = "https://quickshell.org/docs/v0.3.0/";
        Wants = [ "aurora-wallpaper-init.service" ];
        After = [
          "aurora-wallpaper-init.service"
          "graphical-session-pre.target"
        ];
        PartOf = [ "graphical-session.target" ];
        OnFailure = [ "aurora-notification-fallback.service" ];
        StartLimitIntervalSec = 30;
        StartLimitBurst = 5;
      };

      Service = {
        Type = "simple";
        ExecStartPre = "-${pkgs.systemd}/bin/systemctl --user stop aurora-notification-fallback.service";
        ExecStart = "${pkgs.quickshell}/bin/qs --no-duplicate --config aurora-shell";
        Restart = "on-failure";
        RestartSec = "2s";
        Environment = [
          "PATH=${config.home.homeDirectory}/.local/bin:${config.home.profileDirectory}/bin:${runtimePath}"
          "QS_NO_RELOAD_POPUP=1"
        ];
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    # This unit is intentionally not enabled. systemd starts it only after the
    # shell has actually failed, and the shell stops it before every restart.
    # That ordering prevents Dunst and QuickShell from competing for the
    # org.freedesktop.Notifications bus name.
    systemd.user.services.aurora-notification-fallback = {
      Unit = {
        Description = "Dunst fallback when Aurora QuickShell is unavailable";
        After = [ "aurora-shell.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecCondition = "${pkgs.systemd}/bin/systemctl --user is-failed aurora-shell.service";
        ExecStart = "${pkgs.dunst}/bin/dunst -config ${config.home.homeDirectory}/.cache/aurora-theme/dunstrc";
        Restart = "on-failure";
        RestartSec = "3s";
      };
    };
  };
}
