# Recovery

The pre-migration configuration remains in `/etc/nixos`, and systemd-boot keeps
older generations. Do not delete either until the new build has survived reboot.

## Restore user configuration

Home Manager installs managed paths as Nix-store symlinks, so do not copy over
them in place. This sequence preserves the entire post-cutover version beside
each restored directory before copying the known-good backup:

```bash
backup=/home/alex/.local/state/codex-backups/macbook-desktop-20260715-234753
stamp=$(date +%Y%m%d-%H%M%S)

for name in hypr waybar kitty rofi; do
  current="$HOME/.config/$name"
  if [ -e "$current" ] || [ -L "$current" ]; then
    mv "$current" "$current.aurora-$stamp"
  fi
  cp -a "$backup/config/$name" "$current"
done

mkdir -p "$HOME/.config/fish"
fish_config="$HOME/.config/fish/config.fish"
if [ -e "$fish_config" ] || [ -L "$fish_config" ]; then
  mv "$fish_config" "$fish_config.aurora-$stamp"
fi
cp -a "$backup/config/fish/config.fish" "$fish_config"
```

Log out and back in, or reboot into the known-good generation, after restoring.
The `.aurora-TIMESTAMP` paths are intentionally retained until recovery has
been verified.

## Rebuild the known-good channel configuration

```sh
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
```

## Roll back the standalone Home Manager profile

The Retina repair temporarily used direct activation packages while Generation
9 was already running. The current profile is Home Manager generation 2; both
generation 1 and 2 contain the Retina fix. This is therefore a narrow activation
rollback, not a return to the pre-Aurora desktop.

Save all work first and open the maintenance terminal with Command+Enter, not
the Waybar Terminal button. Until Waybar application launch isolation is fixed,
do not restart Waybar while important apps launched from it are open.

Inspect the profile without changing it:

```fish
nix-env --profile ~/.local/state/nix/profiles/home-manager --list-generations
```

Only when specifically directed to return from generation 2 to generation 1:

```fish
nix-env --profile ~/.local/state/nix/profiles/home-manager --switch-generation 1
~/.local/state/nix/profiles/home-manager/activate
```

Both observed direct activations were followed within seconds by the initiating
Kitty scope ending, although the journal does not prove causality. Treat this as
potentially disruptive: do not run it from the only terminal containing unsaved
work. For a true pre-Aurora restore, use the timestamped user-configuration
backup procedure above and an older NixOS generation.

## Boot an older generation

Choose an earlier NixOS generation from the systemd-boot menu at startup.
Holding Option at power-on remains the path to the macOS boot picker.
