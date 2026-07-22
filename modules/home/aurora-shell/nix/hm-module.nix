# Vendored from caelestia-dots/shell — nix/hm-module.nix. Aurora build; local changes tracked in git.
self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  cli-default = self.inputs.caelestia-cli.packages.${system}.default;
  shell-default = self.packages.${system}.with-cli;

  cfg = config.programs.aurora-shell; # Aurora: expose the vendored chassis under the product namespace.
  shellSeed = pkgs.writeText "aurora-shell.json" (builtins.toJSON { # Aurora: materialize the initial writable shell configuration as an immutable seed source.
    general.idle.timeouts = [ # Aurora: preserve the approved idle policy while allowing caelestia to save later edits.
      { timeout = 1200; idleAction = "lock"; } # Aurora: lock after 20 minutes.
      { timeout = 1500; idleAction = "dpms off"; } # Aurora: power off displays after 25 minutes without auto-suspend.
    ]; # Aurora: finish the seeded idle timeout list.
  }); # Aurora: finish the JSON seed derivation.
in {
  imports = [
    (lib.mkRenamedOptionModule ["programs" "aurora-shell" "environment"] ["programs" "aurora-shell" "systemd" "environment"]) # Aurora: keep the environment compatibility alias inside the renamed namespace.
  ];
  options = with lib; {
    programs.aurora-shell = { # Aurora: make Aurora the Home Manager option authority.
      enable = mkEnableOption "Enable Caelestia shell";
      package = mkOption {
        type = types.package;
        default = shell-default;
        description = "The package of Caelestia shell";
      };
      systemd = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable the systemd service for Caelestia shell";
        };
        target = mkOption {
          type = types.str;
          description = ''
            The systemd target that will automatically start the Caelestia shell.
          '';
          default = config.wayland.systemd.target;
        };
        environment = mkOption {
          type = types.listOf types.str;
          description = "Extra Environment variables to pass to the Caelestia shell systemd service.";
          default = [];
          example = [
            "QT_QPA_PLATFORMTHEME=gtk3"
          ];
        };
      };
      settings = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Caelestia shell settings";
      };
      extraConfig = mkOption {
        type = types.str;
        default = "";
        description = "Caelestia shell extra configs written to shell.json";
      };
      cli = {
        enable = mkEnableOption "Enable Caelestia CLI";
        package = mkOption {
          type = types.package;
          default = cli-default;
          description = "The package of Caelestia CLI"; # Doesn't override the shell's CLI, only change from home.packages
        };
        settings = mkOption {
          type = types.attrsOf types.anything;
          default = {};
          description = "Caelestia CLI settings";
        };
        extraConfig = mkOption {
          type = types.str;
          default = "";
          description = "Caelestia CLI extra configs written to cli.json";
        };
      };
    };
  };

  config = let
    cli = cfg.cli.package;
    shell = cfg.package;
  in
    lib.mkIf cfg.enable {
      systemd.user.services.aurora-shell = lib.mkIf cfg.systemd.enable { # Aurora: give the chassis its cutover unit name.
        Unit = {
          Description = "Aurora Shell Service"; # Aurora: identify the renamed user unit in service status.
          After = [cfg.systemd.target];
          PartOf = [cfg.systemd.target];
          OnFailure = ["aurora-notification-fallback.service"]; # Aurora: start Dunst only when the shell fails.
          StartLimitIntervalSec = 30; # Aurora: bound repeated shell failures to a 30-second window.
          StartLimitBurst = 3; # Aurora: stop crash loops after three starts in the limit window.
          X-Restart-Triggers = lib.mkIf (cfg.settings != {}) [
            "${config.xdg.configFile."caelestia/shell.json".source}"
          ];
        };

        Service = {
          Type = "exec";
          ExecStartPre = "-${pkgs.systemd}/bin/systemctl --user stop aurora-notification-fallback.service"; # Aurora: remove the fallback before each shell start without making a failed stop fatal.
          ExecStart = "${shell}/bin/caelestia-shell";
          Restart = "on-failure";
          RestartSec = "5s";
          KillMode = "process"; # Aurora: keep user applications outside shell restart teardown.
          SuccessExitStatus = "143"; # Aurora: treat the shell's SIGTERM exit as clean.
          LimitCORE = "0"; # Aurora: prevent crash loops from consuming disk with core dumps.
          TimeoutStopSec = "5s";
          Environment =
            [
              "QT_QPA_PLATFORM=wayland"
            ]
            ++ cfg.systemd.environment;

          Slice = "session.slice";
        };

        Install = {
          WantedBy = [cfg.systemd.target];
        };
      };

      systemd.user.services.aurora-notification-fallback = lib.mkIf cfg.systemd.enable { # Aurora: preserve the inactive Dunst failure path after retiring the old shell tree.
        Unit = { # Aurora: keep fallback ordering tied to the shell lifecycle.
          Description = "Dunst fallback when Aurora Shell is unavailable"; # Aurora: make the emergency-only purpose explicit.
          After = ["aurora-shell.service"]; # Aurora: evaluate the failed state only after the shell attempt.
          PartOf = [cfg.systemd.target]; # Aurora: stop the fallback with the graphical session.
        }; # Aurora: close fallback unit metadata.

        Service = { # Aurora: define the self-contained emergency notification daemon.
          Type = "simple"; # Aurora: keep Dunst in the foreground under systemd supervision.
          ExecCondition = "${pkgs.systemd}/bin/systemctl --user is-failed aurora-shell.service"; # Aurora: refuse manual starts unless the shell is failed.
          ExecStart = "${pkgs.dunst}/bin/dunst -config ${../assets/fallback-dunstrc}"; # Aurora: use a static palette-independent config from the surviving chassis.
          Restart = "on-failure"; # Aurora: recover the fallback itself if Dunst crashes.
          RestartSec = "3s"; # Aurora: avoid a tight fallback restart loop.
        }; # Aurora: close fallback service settings.
      }; # Aurora: leave the fallback without WantedBy so only OnFailure starts it.

      home.activation.seedAuroraScheme = lib.hm.dag.entryAfter ["writeBoundary"] '' # Aurora: seed mutable shell state only after Home Manager's write boundary.
        state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia" # Aurora: retain the chassis' internal state directory.
        scheme_file="$state_dir/scheme.json" # Aurora: target the file watched by Colours.qml.
        if [ ! -e "$scheme_file" ] && [ ! -L "$scheme_file" ]; then # Aurora: preserve every existing regular file or symlink, including broken symlinks.
          run ${pkgs.coreutils}/bin/install $VERBOSE_ARG -d -m 0700 "$state_dir" # Aurora: create private mutable state storage when absent.
          run ${pkgs.coreutils}/bin/install $VERBOSE_ARG -m 0600 ${../assets/aurora-scheme.json} "$scheme_file" # Aurora: copy instead of symlinking so future scheme changes can overwrite it.
        fi # Aurora: make activation write-once and leave user-selected schemes untouched.
      ''; # Aurora: finish the write-if-absent seed activation.

      home.activation.seedAuroraShellConfig = lib.hm.dag.entryAfter ["writeBoundary"] '' # Aurora: seed mutable shell config only after Home Manager removes obsolete managed links.
        config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/caelestia" # Aurora: honor XDG_CONFIG_HOME while retaining caelestia's default path.
        config_file="$config_dir/shell.json" # Aurora: target the file caelestia reads and writes at runtime.
        if [ ! -e "$config_file" ] && [ ! -L "$config_file" ]; then # Aurora: write only when no regular file or symlink exists, including a broken symlink.
          run ${pkgs.coreutils}/bin/install $VERBOSE_ARG -d -m 0700 "$config_dir" # Aurora: create private writable configuration storage when absent.
          run ${pkgs.coreutils}/bin/install $VERBOSE_ARG -m 0600 ${shellSeed} "$config_file" # Aurora: copy the idle seed so the destination remains mutable rather than store-linked.
        fi # Aurora: preserve all later caelestia/user changes across activations.
      ''; # Aurora: finish the shell.json write-if-absent activation.

      xdg.configFile = let
        mkConfig = c:
          lib.pipe (
            if c.extraConfig != ""
            then c.extraConfig
            else "{}"
          ) [
            builtins.fromJSON
            (lib.recursiveUpdate c.settings)
            builtins.toJSON
          ];
        shouldGenerate = c: c.extraConfig != "" || c.settings != {};
      in {
        "caelestia/shell.json" = lib.mkIf (shouldGenerate cfg) {
          text = mkConfig cfg;
        };
        "caelestia/cli.json" = lib.mkIf (shouldGenerate cfg.cli) {
          text = mkConfig cfg.cli;
        };
      };

      home.packages = [shell] ++ lib.optional cfg.cli.enable cli;
    };
}
