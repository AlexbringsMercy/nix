{
  config,
  lib,
  pkgs,
  ...
}:
let
  runtimePath = lib.makeBinPath (
    with pkgs;
    [
      blueman
      google-chrome
      hyprland
      kitty
      mission-center
      networkmanagerapplet
      playerctl
      pwvucontrol
      quickshell
      thunar
      wireplumber
      wlogout
    ]
  );
  waitForAuroraShell = pkgs.writeShellScript "wait-for-aurora-shell" ''
    for _ in {1..50}; do
      if ${pkgs.quickshell}/bin/qs -c aurora-shell ipc call panels status >/dev/null 2>&1; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 0.1
    done
    printf 'Waybar: Aurora shell IPC was not ready after five seconds; continuing.\n' >&2
  '';
in
{
  xdg.configFile = {
    "waybar/config".source = ./config.json;
    "waybar/style.css".source = ./style.css;
  };

  systemd.user.services.waybar = {
    Unit = {
      Description = "Aurora Waybar taskbar";
      Documentation = "man:waybar(5)";
      Wants = [
        "aurora-shell.service"
        "aurora-wallpaper-init.service"
      ];
      After = [
        "aurora-shell.service"
        "aurora-wallpaper-init.service"
        "graphical-session-pre.target"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = waitForAuroraShell;
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
      RestartSec = 1;
      Environment = [
        "PATH=${config.home.homeDirectory}/.local/bin:${config.home.profileDirectory}/bin:${runtimePath}"
      ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
