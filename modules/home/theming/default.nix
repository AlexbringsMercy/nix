{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aurora.theming;
  weather = config.aurora.weather;
  matugenTemplateDir = ./matugen/templates/aurora;
  # Matugen resolves template paths relative to the config file itself. Home
  # Manager installs a single-file source as an isolated store symlink, so make
  # every template reference an immutable store path before deployment.
  matugenConfig = pkgs.writeText "aurora-matugen.toml" (
    builtins.replaceStrings [ "./templates/aurora/" ] [ "${matugenTemplateDir}/" ] (
      builtins.readFile ./matugen/aurora.toml
    )
  );
in
{
  options.aurora = {
    theming.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Aurora Matugen templates and atomic theme helpers.";
    };

    weather = {
      latitude = lib.mkOption {
        type = lib.types.str;
        default = "41.8781";
        description = "Latitude used by the on-demand Open-Meteo forecast.";
      };
      longitude = lib.mkOption {
        type = lib.types.str;
        default = "-87.6298";
        description = "Longitude used by the on-demand Open-Meteo forecast.";
      };
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "America/Chicago";
        description = "IANA timezone requested from Open-Meteo.";
      };
      location = lib.mkOption {
        type = lib.types.str;
        default = "Chicago";
        description = "Human-readable location displayed in the calendar panel.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cava
      curl
      jq
      matugen
      util-linux
    ];

    services.easyeffects.enable = true;

    xdg.configFile = {
      "matugen/aurora.toml".source = matugenConfig;
      "matugen/templates/aurora/quickshell.json".source = ./matugen/templates/aurora/quickshell.json;
      "matugen/templates/aurora/waybar.css".source = ./matugen/templates/aurora/waybar.css;
      "matugen/templates/aurora/kitty.conf".source = ./matugen/templates/aurora/kitty.conf;
      "matugen/templates/aurora/rofi.rasi".source = ./matugen/templates/aurora/rofi.rasi;
      "matugen/templates/aurora/hyprland.lua".source = ./matugen/templates/aurora/hyprland.lua;
      "matugen/templates/aurora/hyprlock.conf".source = ./matugen/templates/aurora/hyprlock.conf;
      "matugen/templates/aurora/gtk.css".source = ./matugen/templates/aurora/gtk.css;
      "matugen/templates/aurora/dunstrc".source = ./matugen/templates/aurora/dunstrc;
      "cava/aurora-raw.conf".source = ./cava/aurora-raw.conf;
      "gtk-3.0/gtk.css".text = ''
        @import url("file:///home/alex/.cache/aurora-theme/gtk.css");
      '';
      "gtk-4.0/gtk.css".text = ''
        @import url("file:///home/alex/.cache/aurora-theme/gtk.css");
      '';
      "aurora-shell/weather.conf".text = ''
        latitude=${weather.latitude}
        longitude=${weather.longitude}
        timezone=${weather.timezone}
        location=${weather.location}
      '';
    };

    home.file = {
      ".local/bin/equalizer-state" = {
        source = ../../../scripts/equalizer-state;
        executable = true;
      };
      ".local/bin/weather-fetch" = {
        source = ../../../scripts/weather-fetch;
        executable = true;
      };
    };
  };
}
