# macbook NixOS configuration

Declarative NixOS, Home Manager, Hyprland Lua, Waybar, and QuickShell setup for
Alex's 2020 Intel/T2 MacBook Air.

The MacBook uses the pinned public flake in this repository plus a machine-local
wrapper at `/home/alex/.config/nixos-local`. The wrapper supplies proprietary
Apple/Broadcom firmware from `/etc/nixos/firmware/brcm` without ever adding it
to Git.

## Desktop architecture

- Hyprland 0.55 native Lua, two workspaces, tiling, touchpad gestures, function
  keys, screenshots, and pointer-driven move/resize controls.
- A permanent glass Waybar with launcher, pinned applications, running tasks,
  media, hardware status, clock, tray, and notification controls.
- Independent QuickShell Wi-Fi, Bluetooth, volume, power, notification,
  music/EQ, and calendar/weather surfaces opened from Waybar.
- Matugen, Waypaper, and awww for atomic wallpaper-adaptive colors and animated
  background changes.
- Hyprlock/Hypridle, PipeWire, SwayOSD, EasyEffects, Cava, Dunst fallback, and
  native Wayland application defaults.

## Validate and build

Run the complete preflight without activating the live desktop:

```sh
./checks/preflight.sh
```

The preflight evaluates the public flake, builds the firmware-backed system with
conservative concurrency, and verifies the T2 kernel, local firmware,
QuickShell, and `nix-ld` are all present in the closure.

For the first cutover, install the exact validated closure as a **boot**
generation rather than switching underneath the active terminal:

```sh
out=$(nix build --no-link --print-out-paths \
  path:/home/alex/.config/nixos-local#nixosConfigurations.macbook.config.system.build.toplevel \
  --override-input macbook-config path:/home/alex/nix \
  --override-input firmware path:/etc/nixos/firmware \
  --max-jobs 2 --cores 2)
sudo "$out/bin/switch-to-configuration" boot
```

Reboot normally to test the new generation. Older generations remain selectable
from systemd-boot. Do not run standalone `home-manager switch`; Home Manager is
integrated into the NixOS generation and backs up colliding files during the
first activation.

## Documentation

- `BUILD_PLAN.md` — durable design, invariants, source integration, and status
- `docs/controls.md` — pointer paths and optional shortcuts
- `docs/wallpapers.md` — local collection and adaptive-color pipeline
- `docs/recovery.md` — symlink-safe dotfile restore and generation rollback
- `docs/updating.md` — controlled input updates after acceptance
- `SOURCES.md` — exact community provenance and adaptations
- `EXECUTION_LOG.md` — implementation and validation record
