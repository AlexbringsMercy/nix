{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.aurora.wallpaper;
  applyWallpaper = pkgs.writeShellApplication {
    name = "apply-wallpaper";
    runtimeInputs = with pkgs; [
      awww
      coreutils
      gnugrep
      hyprland
      jq
      matugen
      procps
      systemd
      util-linux
    ];
    text = builtins.readFile ../../../scripts/apply-wallpaper;
  };
  runtimePath = lib.makeBinPath [
    pkgs.awww
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.hyprland
    pkgs.jq
    pkgs.matugen
    pkgs.procps
    pkgs.systemd
    pkgs.util-linux
  ];
  selectWallpaper = ''
    select_wallpaper() {
      local state selected
      state="''${XDG_CACHE_HOME:-$HOME/.cache}/aurora-theme/wallpaper.json"
      selected=""

      if [ -s "$state" ]; then
        selected=$(${pkgs.jq}/bin/jq -r '.path // empty' "$state" 2>/dev/null || true)
      fi

      if [ -z "$selected" ] || [ ! -r "$selected" ]; then
        selected=${lib.escapeShellArg cfg.defaultWallpaper}
      fi

      if [ -z "$selected" ] || [ ! -r "$selected" ]; then
        selected=""
        if [ -d ${lib.escapeShellArg cfg.directory} ]; then
          selected=$(
            ${pkgs.findutils}/bin/find ${lib.escapeShellArg cfg.directory} -maxdepth 1 -type f \
              \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) \
              -print | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/head -n 1
          )
        fi
      fi

      [ -n "$selected" ] && [ -r "$selected" ] || return 1
      printf '%s\n' "$selected"
    }
  '';
  initializeWallpaper = pkgs.writeShellScript "aurora-wallpaper-init" ''
    set -eu
    ${selectWallpaper}
    if ! selected=$(select_wallpaper); then
      printf 'aurora-wallpaper-init: add an image to %s before graphical login\n' \
        ${lib.escapeShellArg cfg.directory} >&2
      exit 0
    fi
    ${applyWallpaper}/bin/apply-wallpaper "$selected"
  '';
in
{
  options.aurora.wallpaper = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable awww and the mouse-driven Waypaper workflow.";
    };
    directory = lib.mkOption {
      type = lib.types.str;
      default = "/home/alex/Pictures/Wallpapers/aurora-collection";
      description = "Wallpaper library shown by Waypaper.";
    };
    defaultWallpaper = lib.mkOption {
      type = lib.types.str;
      default = "/home/alex/Pictures/Wallpapers/aurora-collection/violet-nokstella-stars.jpeg";
      description = "Wallpaper selected on the first graphical login.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      applyWallpaper
      pkgs.awww
      pkgs.waypaper
    ];

    home.file = {
      ".local/bin/apply-wallpaper" = {
        source = "${applyWallpaper}/bin/apply-wallpaper";
        executable = true;
      };
    };

    # Wallpapers are personal machine-local data, not flake inputs. Create the
    # picker directory without claiming or replacing any image inside it.
    home.activation.prepareAuroraWallpaperDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.coreutils}/bin/install -d -m 0755 ${lib.escapeShellArg cfg.directory}
    '';

    # Create every cache fragment before graphical-session.target can start.
    # Re-rendering the last selected image also migrates existing caches when
    # templates gain new consumers such as GTK or the Dunst fallback.
    home.activation.seedAuroraTheme =
      lib.hm.dag.entryAfter
        [
          "linkGeneration"
          "prepareAuroraWallpaperDirectory"
        ]
        ''
          ${selectWallpaper}
          if selected=$(select_wallpaper); then
            run ${applyWallpaper}/bin/apply-wallpaper --theme-only "$selected"
          else
            echo 'No local Aurora wallpaper is available yet; theme seeding skipped.' >&2
          fi
        '';

    xdg.configFile."waypaper/config.ini".text = ''
      [Settings]
      language = en
      folder = ${cfg.directory}
      monitors = All
      wallpaper = ${cfg.defaultWallpaper}
      backend = none
      fill = fill
      sort = name
      color = #05060b
      subfolders = True
      show_hidden = False
      show_gifs_only = False
      # Waypaper shell-quotes the replacement value itself.
      post_command = apply-wallpaper $wallpaper
      number_of_columns = 3
    '';

    systemd.user.services = {
      aurora-wallpaper = {
        Unit = {
          Description = "Aurora awww wallpaper daemon";
          Documentation = "https://codeberg.org/LGFae/awww";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.awww}/bin/awww-daemon --quiet";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      aurora-wallpaper-init = {
        Unit = {
          Description = "Restore Aurora wallpaper and initialize its palette";
          After = [ "aurora-wallpaper.service" ];
          Requires = [ "aurora-wallpaper.service" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = initializeWallpaper;
          Environment = [ "PATH=${runtimePath}" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
