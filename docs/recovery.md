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

## Boot an older generation

Choose an earlier NixOS generation from the systemd-boot menu at startup.
Holding Option at power-on remains the path to the macOS boot picker.
