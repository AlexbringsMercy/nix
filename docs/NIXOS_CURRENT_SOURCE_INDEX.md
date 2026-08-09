# NixOS / Aurora — Current Source Index

_A navigation map for a fresh planning chat. Find the area here, then read the
source directly. For the repository's provenance and reproducibility state see
[`REPOSITORY_REPRODUCIBILITY_AUDIT.md`](REPOSITORY_REPRODUCIBILITY_AUDIT.md)._

- **GitHub:** `AlexbringsMercy/nix`
- **Branch:** `main` (canonical; also the GitHub default)
- **Local checkout:** `/home/alex/nix`
- **Actual rebuild entry point:** machine-local wrapper `~/.config/nixos-local`
  (NOT in git — see the audit §6). The repo self-evaluates
  `nixosConfigurations.macbook` without it.

---

## Flake / system core

| What | Where |
|---|---|
| Flake, inputs (pinned), overlays, `lib.mkMacbook`, outputs | `flake.nix` |
| Lockfile | `flake.lock` |
| Host definition (macbook) | `hosts/macbook/default.nix` |
| Hardware configuration | `hosts/macbook/hardware-configuration.nix` |
| System modules | `modules/nixos/{base,desktop,laptop-power,media-center,build-harness,t2-firmware}.nix` |
| T2 firmware wiring (proprietary firmware injected externally) | `modules/nixos/t2-firmware.nix` |

## Hardware / OS

- T2 MacBook support: `nixos-hardware.apple-t2` + `t2fanrd` inputs in `flake.nix`;
  `hosts/macbook/`, `modules/nixos/base.nix`, `modules/nixos/t2-firmware.nix`.
- Power / suspend: `modules/nixos/laptop-power.nix`.
- Proprietary Broadcom firmware: **external**, `/etc/nixos/firmware/brcm`
  (see audit §6). In-repo `firmware/` is gitignored.

## Desktop

| What | Where |
|---|---|
| Hyprland config (Lua) | `modules/home/hyprland/hyprland.lua`, `modules/home/hyprland/hyprland/*.lua` |
| Hyprland Nix module | `modules/home/hyprland/default.nix` |
| hyprbars integration | `modules/home/hyprland/hyprbars.lua.in`, `modules/home/hyprland/patches/hyprbars-hover.patch` |
| `aurora-minimize` plugin (C++) | `modules/home/hyprland/aurora-minimize/{main.cpp,CMakeLists.txt}` |
| Compositor patches (via overlay) | `modules/nixos/patches/hyprland-{drag-anchor,deco-border-grab,dwindle-resize-workarea}.patch` |
| Aurora / Quickshell shell (QML, ~457 files) | `modules/home/aurora-shell/` |
| Kitty | `modules/home/kitty/` |
| Lock screen | `modules/home/lock/` |
| Theming (matugen templates → `~/.cache/aurora-theme/*`) | `modules/home/theming/` |
| Desktop apps / packages | `modules/home/desktop-apps.nix`, `modules/home/packages.nix` |

## Shell / agent integration

- Fish config, PATH lanes, `rebuild-macbook`/`test-macbook` abbreviations:
  `modules/home/fish.nix`.
- Agent-lane PATH ordering & `~/.bashrc` reconciliation: `home/alex/default.nix`.
- Agent binaries are **user-managed** (`~/.local/bin/{claude,codex}`) — not
  git-owned; do not replace with Nix copies (audit §6).
- Helper scripts: `scripts/{apply-wallpaper,aurora-resume-agent,equalizer-state,weather-fetch}`.

## Verification / gates

- `scripts/aurora-stage2-gate-auto.sh` (automated objective gate).
- `checks/preflight.sh`, `docs/stage2-runtime-gate.md`, `docs/stage-gates/stage2-closeout.md`.

---

## Project governance & source-of-truth (authoritative)

| Doc | Purpose |
|---|---|
| `GRAND_PLAN.md` | Overall plan |
| `MASTER_REQUIREMENTS.md` | Requirements |
| `CURRENT_STATE_AUDIT.md` | Current state |
| `STAGE2_CLOSEOUT_WORK_ORDER.md` | Stage 2 closeout work order |
| `PM_OPERATING_RULES.md` | PM operating rules |
| `SESSION_PREAMBLE.md` | Session preamble (subagents must read first) |
| `EXECUTION_LOG.md` | Execution history |
| `SOURCES.md` | Vendored-source attribution / patch provenance |
| `macbook-build-spec.md`, `nixos-hyprland-build-spec.md` | Build specs |
| `RESEARCH_GUIDE.md`, `VISUAL_RESEARCH.md`, `visual-design-reference.md` | Research / visual reference |
| `README.md` | Repo overview |
| `docs/` | Recovery, controls, updating, wallpapers, correction manifest, consultation record, xbox-bluetooth diagnostic |

## Handoff / recovery (point-in-time, generation 32)

- `PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md`
- `PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md`
- `docs/recovery.md`

## Historical (superseded — read for context only)

- `archive/superseded-docs/`, `archive/superseded-handoffs/` — dated snapshots of
  earlier plans/handoffs; not current.

## Prompts / research (working material)

- `codex-prompts/` — per-stage Codex task prompts (Stage 1 → Stage 3).
- `research/` — upstream inventories and driver/hardware notes. Raw upstream
  clones live in gitignored `/repos/` (~11 GB, re-cloneable).

---

## Branches

- **`main`** — canonical, complete project. Use this.
- **`stage3/topbar`** (`dbd3c72`) — unmerged Stage 3 WIP (top widget bar), one
  unique commit, live worktree at `/home/alex/aurora-stage3`. Preserved pending an
  operator decision (audit §8). Not required to see or continue the main project.
