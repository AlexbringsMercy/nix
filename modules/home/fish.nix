{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      set -gx EDITOR nano
      set -gx VISUAL nano

      # Aurora: re-assert the agent lane invariant last, so neither a stale
      # `fish_user_paths` universal variable nor an installer's prepend can put the
      # npm-global lane ahead of the self-managed ~/.local/bin one. Idempotent.
      set -gx PATH (string match -v "$HOME/.local/bin" $PATH)
      set -gx PATH "$HOME/.local/bin" $PATH

      # Workbench: an imperative `nix profile install` python3 (bare, no
      # packages) sits on ~/.nix-profile/bin, which is earlier in PATH than
      # the Home Manager-managed workstation python3 (numpy/pandas/etc, see
      # modules/home/lib/workstation-python.nix) from
      # modules/home/dev-toolchain.nix. Alias it explicitly here instead of
      # reordering PATH or removing the existing profile entry.
      alias python3 "${pkgs.python3.withPackages (import ./lib/workstation-python.nix)}/bin/python3"
    '';
    shellAliases = {
      # Aurora: override macbook-config with the git-backed input, never raw `path:`.
      # `git+file` is git-aware — it ships only committed, tracked content and honours
      # `.gitignore`, so the ~11 GB ignored `repos/` clones never enter the Nix store.
      # A raw `path:/home/alex/nix` fetch copies the whole worktree and has OOM/ENOSPC'd
      # this machine. Firmware stays a separate machine-local input (not in Git).
      rebuild-macbook = "sudo nixos-rebuild switch --flake /home/alex/.config/nixos-local#macbook --override-input macbook-config git+file:///home/alex/nix --override-input firmware path:/etc/nixos/firmware";
      test-macbook = "sudo nixos-rebuild test --flake /home/alex/.config/nixos-local#macbook --override-input macbook-config git+file:///home/alex/nix --override-input firmware path:/etc/nixos/firmware";
      qs-panels = "qs -c aurora-shell ipc call panels status";
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "/home/alex/Desktop";
    documents = "/home/alex/Documents";
    download = "/home/alex/Downloads";
    music = "/home/alex/Music";
    pictures = "/home/alex/Pictures";
    publicShare = "/home/alex/Public";
    templates = "/home/alex/Templates";
    videos = "/home/alex/Videos";
  };
}
