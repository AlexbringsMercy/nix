{ config, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = false;
  };
  programs.hyprlock.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.hyprland}/bin/start-hyprland";
        user = "alex";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd ${pkgs.hyprland}/bin/start-hyprland";
        user = "greeter";
      };
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.LE = {
      # Xbox BLE firmware can negotiate overly slow defaults under BlueZ.
      # 7..9 ticks is 8.75..11.25 ms, matching the controller's 100 Hz protocol.
      MinConnectionInterval = 7;
      MaxConnectionInterval = 9;
      ConnectionLatency = 0;
    };
  };
  services.blueman.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-color-emoji
    fira-code
    nerd-fonts.fira-code
  ];

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    google-chrome
    kitty
    papirus-icon-theme
    thunar
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "GNOME PolicyKit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}
