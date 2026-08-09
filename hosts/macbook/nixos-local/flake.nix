{
  # ============================================================================
  # CANONICAL TEMPLATE for the machine-local deploy wrapper.
  #
  # This is the tracked source of truth for the tiny flake that actually lives at
  #   ~/.config/nixos-local/flake.nix
  # and is invoked by `rebuild-macbook` / `test-macbook` (see modules/home/fish.nix)
  # and by checks/preflight.sh.
  #
  # It is intentionally NOT evaluated as part of this repository's own flake —
  # `hosts/macbook/default.nix` imports explicit module files, never this subtree.
  # To (re)create the machine-local wrapper on a fresh machine, copy this file:
  #
  #   mkdir -p ~/.config/nixos-local
  #   cp hosts/macbook/nixos-local/flake.nix ~/.config/nixos-local/flake.nix
  #   nix flake update --flake ~/.config/nixos-local     # generate flake.lock
  #
  # The wrapper exists for one reason: to supply the proprietary Broadcom T2
  # firmware, which must never be committed to Git. See ./README.md and
  # docs/instructions/recovery.md.
  # ============================================================================
  description = "Machine-local MacBook wrapper with proprietary firmware";

  inputs = {
    # git+file (not path:): the path fetcher would copy the whole worktree into
    # the store — including the 11 GB repos/ research clones — on every eval.
    # The git fetcher ships the committed tree only and honours .gitignore.
    macbook-config.url = "git+file:///home/alex/nix";
    firmware = {
      # Machine-local, proprietary, extracted from macOS — NOT in Git.
      # Provisioning prerequisite: /etc/nixos/firmware/brcm must exist. See README.md.
      url = "path:/etc/nixos/firmware";
      flake = false;
    };
  };

  outputs = { macbook-config, firmware, ... }: {
    nixosConfigurations.macbook = macbook-config.lib.mkMacbook {
      firmwareSource = "${firmware}/brcm";
    };
  };
}
