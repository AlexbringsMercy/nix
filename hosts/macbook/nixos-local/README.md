# Machine-local deploy wrapper (`~/.config/nixos-local`)

The MacBook is not rebuilt directly against this repository's flake. It is
rebuilt through a tiny **machine-local wrapper flake** whose only job is to inject
the proprietary Broadcom T2 firmware, which must stay out of Git.

`flake.nix` in this directory is the **canonical tracked template** for that
wrapper. The live copy lives at `~/.config/nixos-local/flake.nix` and is not, and
must not be, committed with machine paths baked in elsewhere.

## Why a wrapper at all

- The firmware (`/etc/nixos/firmware/brcm`, ~163 proprietary `.bin`/`.ptb` files
  extracted from macOS) cannot be committed. The wrapper passes it in as a
  `flake = false` input so this repository stays firmware-free.
- The wrapper consumes this repository through **`git+file:///home/alex/nix`**,
  not `path:`. The git fetcher ships only committed, tracked content and honours
  `.gitignore`, so the ~11 GB ignored `repos/` research clones never enter the
  Nix store. A raw `path:` fetch copies the whole worktree and has ENOSPC/OOM'd
  this machine.
- This repository's own `flake.nix` still self-evaluates
  `nixosConfigurations.macbook` (with `firmwareSource = null`) so `nix flake
  check` works from a clone; the wrapper only adds firmware for the real install.

## Recreate the wrapper on a fresh machine

```sh
# 1. Restore the proprietary firmware (from backup — never from Git):
sudo mkdir -p /etc/nixos/firmware/brcm
# ...copy the extracted brcm firmware into /etc/nixos/firmware/brcm...

# 2. Materialize the wrapper from this template:
mkdir -p ~/.config/nixos-local
cp hosts/macbook/nixos-local/flake.nix ~/.config/nixos-local/flake.nix
nix flake update --flake ~/.config/nixos-local     # generates flake.lock

# 3. Rebuild (see modules/home/fish.nix for the canonical abbreviations):
rebuild-macbook      # or: test-macbook
```

## Keeping it current

`git+file` ships **committed** content only. After committing new work in
`/home/alex/nix`, the wrapper's lock must be repinned so it picks up the new HEAD:

```sh
nix flake update --flake ~/.config/nixos-local
```

The `rebuild-macbook` / `test-macbook` abbreviations pass
`--override-input macbook-config git+file:///home/alex/nix`, which re-fetches the
current committed HEAD at eval time and sidesteps a stale wrapper lock.

See also: `docs/instructions/recovery.md`, `docs/instructions/updating.md`,
`docs/reports/repository-reproducibility-audit.md`.
