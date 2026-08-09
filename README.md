# MacBook NixOS configuration

Declarative NixOS + Home Manager + Hyprland (native Lua) + QuickShell
configuration for Alex's 2020 Intel/T2 MacBook Air.

- **Target:** 2020 MacBook Air (Intel i3, T2 security chip), single display.
- **Canonical branch:** `main` (GitHub: `AlexbringsMercy/nix`). This is the only
  active branch; the former `codex/macbook-desktop` line was normalized onto
  `main` and retired.
- **Stage:** **Stage 2 is OPEN.** `docs/plans/GRAND_PLAN.md` is the sole design
  authority. Verified machine state: `docs/reports/CURRENT_STATE_AUDIT_2026-08-09.md`. What
  physically happened: `docs/reports/EXECUTION_LOG.md`.
- **All documentation lives under [`docs/`](docs/README.md) — start there.**

## Desktop architecture

Hyprland 0.55 native Lua with narrow carried compositor patches, plus caelestia
forked as **`aurora-shell`** — one systemd-supervised QuickShell instance owning
a top widget bar and a left application rail, with a wallpaper-derived light/dark
semantic palette. See `docs/plans/GRAND_PLAN.md` for authoritative architecture,
surface ownership, and stage sequence.

## How the build is wired

The MacBook is **not** rebuilt directly against this repository's flake. It is
rebuilt through a tiny **machine-local wrapper** at `~/.config/nixos-local`,
whose only job is to inject proprietary Apple/Broadcom firmware from
`/etc/nixos/firmware/brcm` **without ever adding it to Git**.

- **External firmware prerequisite.** `/etc/nixos/firmware/brcm` must exist
  (extracted from macOS; never committed). On a fresh machine, restore it from
  backup before the first rebuild.
- **The wrapper consumes this repo via `git+file:///home/alex/nix`, never raw
  `path:`.** The git fetcher ships only committed, tracked content and honours
  `.gitignore`, so the ~11 GB ignored `repos/` research clones never enter the
  Nix store. The canonical template and recreation steps for the wrapper live at
  [`hosts/macbook/nixos-local/`](hosts/macbook/nixos-local/README.md).
- This repository's own `flake.nix` still self-evaluates
  `nixosConfigurations.macbook` (firmware `null`) so `nix flake check` works from
  a clone.

## Validate and build

Preflight (evaluates the flake and builds the firmware-backed system without
touching the live desktop; verifies the T2 kernel, firmware, QuickShell and
`nix-ld` are in the closure):

```sh
./checks/preflight.sh
```

Install an exact validated closure as a **boot** generation without switching
underneath the active terminal:

```fish
# Repin the wrapper to the current commit first — it tracks
# git+file:///home/alex/nix, so it builds COMMITTED work only.
nix flake update --flake /home/alex/.config/nixos-local
set out (nix build --no-link --print-out-paths \
  /home/alex/.config/nixos-local#nixosConfigurations.macbook.config.system.build.toplevel \
  --max-jobs 2 --cores 2)
sudo nix-env --profile /nix/var/nix/profiles/system --set "$out"
sudo "$out/bin/switch-to-configuration" boot
```

The `rebuild-macbook` / `test-macbook` fish abbreviations (see
`modules/home/fish.nix`) wrap this and pass
`--override-input macbook-config git+file:///home/alex/nix`, which re-fetches the
current committed HEAD.

> **Never pass `--override-input macbook-config path:/home/alex/nix`.** The
> `path:` fetcher ignores `.gitignore` and copies the entire worktree — including
> the 11 GB `repos/` clones — into the store on **every** evaluation. Three such
> copies (33 GB) once filled the disk to 98% and killed the 2026-07-29 compositor
> build (`No space left on device`). Always use the committed `git+file:` input.

Reboot to test the new generation; older generations remain selectable from
systemd-boot. Do not run standalone `home-manager switch` — Home Manager is
integrated into the NixOS generation.

## Documentation

The full corpus is organized and indexed under **[`docs/README.md`](docs/README.md)**
(plans · reports · references · research · briefs · prompts · instructions ·
archive). Quick entry points:

- Design authority — `docs/plans/GRAND_PLAN.md`
- Requirements — `docs/plans/MASTER_REQUIREMENTS.md`
- Stage 2 is **OPEN**; current recovery entry path — `docs/briefs/PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md` → `docs/reports/gen32-recovery-diagnosis.md`
- Stage 2 requirements (prior-cycle gen-32 work order, superseded for the current cycle) — `docs/plans/STAGE2_CLOSEOUT_WORK_ORDER.md`
- Verified state — `docs/reports/CURRENT_STATE_AUDIT_2026-08-09.md`
- Operating contract — `docs/instructions/PM_OPERATING_RULES.md`
- Source map — `docs/references/NIXOS_CURRENT_SOURCE_INDEX.md`
- Reproducibility — `docs/reports/REPOSITORY_REPRODUCIBILITY_AUDIT.md`
