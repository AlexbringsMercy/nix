# Updating

The first migration deliberately pins the package set that is already running.
Do not update inputs while diagnosing the desktop cutover.

After the new generation has survived reboot and passed the hardware checklist:

```sh
cd /home/alex/nix
nix flake update
nix flake check git+file:///home/alex/nix --show-trace --max-jobs 2 --cores 2
nix build --no-link path:/home/alex/.config/nixos-local#nixosConfigurations.macbook.config.system.build.toplevel \
  --override-input macbook-config git+file:///home/alex/nix \
  --override-input firmware path:/etc/nixos/firmware \
  --max-jobs 2 --cores 2
```

Review the closure diff and `docs/reports/EXECUTION_LOG.md` before activation. Never add the
machine-local firmware input or downloaded wallpaper library to this repository.
