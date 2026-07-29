# macbook NixOS configuration

Declarative NixOS, Home Manager, Hyprland Lua, and QuickShell setup for
Alex's 2020 Intel/T2 MacBook Air.

> **Status note (2026-07-28).** The "Desktop architecture" section below describes
> the **retired** 2026-07-16 Waybar-era desktop and is kept only as history. The
> current architecture is `GRAND_PLAN.md` — caelestia forked as `aurora-shell`
> under QuickShell, with Waybar, Rofi and SwayOSD retired. For verified machine
> state read `CURRENT_STATE_AUDIT.md`; for the build's current status and rules
> read `EXECUTION_LOG.md`, `PM_OPERATING_RULES.md`, and
> `STAGE2_CLOSEOUT_WORK_ORDER.md`. The build/deploy instructions in this file
> remain accurate.

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

To install an exact validated closure as a **boot** generation without switching
underneath the active terminal:

```fish
set out (nix build --no-link --print-out-paths \
  path:/home/alex/.config/nixos-local#nixosConfigurations.macbook.config.system.build.toplevel \
  --override-input macbook-config path:/home/alex/nix \
  --override-input firmware path:/etc/nixos/firmware \
  --max-jobs 2 --cores 2)
sudo nix-env --profile /nix/var/nix/profiles/system --set "$out"
sudo "$out/bin/switch-to-configuration" boot
```

Setting the system profile is what creates the new numbered generation.
`switch-to-configuration boot` then writes that generation's systemd-boot
entry; invoking it without advancing the profile only rewrites the current
generation's entry.

Reboot normally to test the new generation. Older generations remain selectable
from systemd-boot. Do not run standalone `home-manager switch`; Home Manager is
integrated into the NixOS generation and backs up colliding files during the
first activation.

## Documentation

- `GRAND_PLAN.md` — the authoritative build plan (supersedes `BUILD_PLAN.md`)
- `MASTER_REQUIREMENTS.md` — the requirements ledger, incl. execution governance
- `CURRENT_STATE_AUDIT.md` — verified machine and repository state
- `PM_OPERATING_RULES.md` — operating contract for the project-manager session
- `STAGE2_CLOSEOUT_WORK_ORDER.md` — the current open work order
- `SESSION_PREAMBLE.md` — mandatory reading for every session and subagent
- `archive/superseded-handoffs/` — retired handoffs and plans (history only)
- `docs/controls.md` — pointer paths and optional shortcuts
- `docs/wallpapers.md` — local collection and adaptive-color pipeline
- `docs/recovery.md` — symlink-safe dotfile restore and generation rollback
- `docs/updating.md` — controlled input updates after acceptance
- `SOURCES.md` — recorded community provenance and adaptations
- `EXECUTION_LOG.md` — implementation and validation record
