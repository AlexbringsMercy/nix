{ ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      set -gx EDITOR nano
      set -gx VISUAL nano
    '';
    shellAliases = {
      rebuild-macbook = "sudo nixos-rebuild switch --flake /home/alex/.config/nixos-local#macbook --override-input macbook-config path:/home/alex/nix --override-input firmware path:/etc/nixos/firmware";
      test-macbook = "sudo nixos-rebuild test --flake /home/alex/.config/nixos-local#macbook --override-input macbook-config path:/home/alex/nix --override-input firmware path:/etc/nixos/firmware";
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
