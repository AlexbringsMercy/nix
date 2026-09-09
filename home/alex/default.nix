{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/home/packages.nix
    ../../modules/home/workbench.nix
    ../../modules/home/dev-toolchain.nix
    ../../modules/home/security-tooling.nix
    ../../modules/home/cloud-infra.nix
    ../../modules/home/hyprland
    ../../modules/home/kitty
    # Aurora: the vendored chassis replaces the Waybar, Rofi, and old QuickShell surfaces.
    ../../modules/home/theming
    # Aurora: wallpaper rendering retires now; the surviving theming backends remain imported above.
    ../../modules/home/desktop-apps.nix
    ../../modules/home/fish.nix
    ../../modules/home/lock
  ];

  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "26.11";
    # Aurora: the user-owned agent lane wins by declaration, not by accident. Home Manager
    # emits these in list order ahead of the inherited PATH, so `.local/bin` (the
    # self-managed `claude update` / Codex standalone lane) always resolves before the
    # legacy npm-global lane. Reversing these two entries is what let a stale npm-global
    # Claude Code shadow the newer self-managed one after an activation.
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.npm-global/bin"
    ];
  };

  xdg.enable = true;
  fonts.fontconfig.enable = true;

  programs.aurora-shell.enable = true; # Aurora: make the vendored chassis Alex's active declared shell.
  programs.aurora-shell.cli.enable = true; # Aurora: retain the internal caelestia CLI alongside the shell package.
  programs.aurora-shell.settings = { }; # Aurora: stop Home Manager from replacing mutable shell.json with a read-only store symlink.

  home.activation.createDesktopDirectories = ''
    run mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/Wallpapers"
  '';

  # Aurora: `~/.bashrc` predates the flake and is not Home Manager managed. Its single
  # line prepends the npm-global lane *after* everything else has run, which inverts the
  # agent PATH invariant for every bash shell. Normalize that one line in place — Nix owns
  # PATH order; it still does not own, pin, or replace the agent binaries themselves.
  # Idempotent, and it keeps a one-time backup rather than editing blind.
  home.activation.normalizeAgentPathOrder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    bashrc="$HOME/.bashrc"
    if [ -f "$bashrc" ] && grep -q '\.npm-global/bin:\$PATH' "$bashrc"; then
      if ! grep -q 'Aurora: agent lane order' "$bashrc"; then
        run cp -n "$bashrc" "$bashrc.pre-aurora" || true
      fi
      run ${pkgs.gnused}/bin/sed -i \
        -e 's|^export PATH="\$HOME/\.npm-global/bin:\$PATH"$|# Aurora: agent lane order — the self-managed ~/.local/bin lane must precede npm-global.\nexport PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"|' \
        "$bashrc"
    fi
  '';

  programs.home-manager.enable = true;
}
