{ pkgs, ... }:
let
  lockNetwork = pkgs.writeShellScript "hyprlock-network" ''
    ssid=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi \
      | ${pkgs.gnused}/bin/sed -n 's/^yes://p' \
      | ${pkgs.coreutils}/bin/head -n 1)
    printf '󰤨  %s' "''${ssid:-Offline}"
  '';

  lockBattery = pkgs.writeShellScript "hyprlock-battery" ''
    percentage=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || printf '%s' '--')
    status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/status 2>/dev/null || true)
    printf '󰁹  %s%%  %s' "$percentage" "$status"
  '';
in
{
  home.file.".face".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
      <defs>
        <radialGradient id="bg" cx="68%" cy="22%" r="95%">
          <stop offset="0" stop-color="#36d6b2"/>
          <stop offset="0.34" stop-color="#143b52"/>
          <stop offset="0.70" stop-color="#26133f"/>
          <stop offset="1" stop-color="#05070d"/>
        </radialGradient>
      </defs>
      <circle cx="128" cy="128" r="124" fill="url(#bg)" stroke="#8ff3dc" stroke-opacity=".45" stroke-width="4"/>
      <text x="128" y="155" text-anchor="middle" fill="#effffb" font-family="Inter, sans-serif" font-size="92" font-weight="600">A</text>
    </svg>
  '';

  programs.hyprlock = {
    enable = true;
    settings = {
      # apply-wallpaper rewrites this fragment atomically. The first-login
      # wallpaper unit creates it before the lock screen is normally used.
      source = "/home/alex/.cache/aurora-theme/hyprlock.conf";

      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 1;
        no_fade_in = false;
        no_fade_out = false;
        ignore_empty_input = true;
      };

      background = [
        {
          monitor = "eDP-1";
          path = "$auroraWallpaper";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.018;
          contrast = 1.06;
          brightness = 0.48;
          vibrancy = 0.20;
          vibrancy_darkness = 0.12;
        }
      ];

      shape = [
        {
          monitor = "eDP-1";
          size = "660, 660";
          position = "0, 30";
          halign = "center";
          valign = "center";
          color = "$auroraPanel";
          rounding = -1;
          border_size = 1;
          border_color = "$auroraSecondary";
          shadow_passes = 4;
          shadow_size = 22;
          shadow_color = "rgba(00000090)";
        }
      ];

      image = [
        {
          monitor = "eDP-1";
          path = "/home/alex/.face";
          size = 104;
          rounding = -1;
          border_size = 2;
          border_color = "$auroraSecondary";
          position = "0, 24";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 12;
          shadow_color = "rgba(000000b0)";
        }
      ];

      label = [
        {
          monitor = "eDP-1";
          text = "$TIME";
          color = "$auroraText";
          font_family = "FiraCode Nerd Font";
          font_size = 80;
          position = "0, 300";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 8;
          shadow_color = "rgba(000000b0)";
        }
        {
          monitor = "eDP-1";
          text = "cmd[update:60000] date '+%A, %B %d'";
          color = "$auroraMuted";
          font_family = "Inter";
          font_size = 18;
          position = "0, 232";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "eDP-1";
          text = "alex";
          color = "$auroraText";
          font_family = "Inter SemiBold";
          font_size = 17;
          position = "0, -54";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "eDP-1";
          text = "cmd[update:5000] ${lockNetwork}";
          color = "$auroraMuted";
          font_family = "FiraCode Nerd Font";
          font_size = 13;
          position = "-110, 34";
          halign = "center";
          valign = "bottom";
        }
        {
          monitor = "eDP-1";
          text = "cmd[update:5000] ${lockBattery}";
          color = "$auroraMuted";
          font_family = "FiraCode Nerd Font";
          font_size = 13;
          position = "110, 34";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = [
        {
          monitor = "eDP-1";
          size = "330, 54";
          position = "0, -132";
          halign = "center";
          valign = "center";
          outline_thickness = 2;
          rounding = 12;
          outer_color = "$auroraPrimary";
          inner_color = "$auroraPanel";
          font_color = "$auroraText";
          check_color = "$auroraSecondary";
          fail_color = "$auroraError";
          capslock_color = "$auroraTertiary";
          placeholder_text = "Password";
          fail_text = "$FAIL";
          dots_center = true;
          fade_on_empty = false;
          hide_input = false;
          shadow_passes = 3;
          shadow_size = 12;
          shadow_color = "rgba(000000a0)";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        inhibit_sleep = 3;
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 20%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 660;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
