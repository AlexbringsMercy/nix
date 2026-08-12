# NixOS / Aurora — Current Source Index

_A navigation map for a fresh planning chat. Find the area here, then read the
source directly. For the documentation corpus see [`../README.md`](../README.md);
for the repository's provenance and reproducibility state see
[`../reports/REPOSITORY_REPRODUCIBILITY_AUDIT.md`](../reports/REPOSITORY_REPRODUCIBILITY_AUDIT.md)._

- **GitHub:** `AlexbringsMercy/nix`
- **Branch:** `main` (canonical; also the GitHub default)
- **Local checkout:** `/home/alex/nix`
- **Actual rebuild entry point:** the machine-local wrapper **live instance** at
  `~/.config/nixos-local/` is intentionally machine-local (binds machine paths, not
  committed). Its **canonical source/template is tracked in Git** at
  `hosts/macbook/nixos-local/flake.nix` (+ `README.md` with recreation steps); the
  firmware path stays an external prerequisite. There is **no wrapper source debt**.
  The repo also self-evaluates `nixosConfigurations.macbook` without the wrapper.

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
| **Stage 3 top bar — DORMANT** (not built, not imported) | `modules/home/aurora-shell/stage-3-in-progress/topbar/` (see its `README.md`) |
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
- `checks/preflight.sh`, `docs/reports/stage2-runtime-gate.md`, `docs/plans/stage2-closeout.md`.

---

## Project governance & source-of-truth (authoritative)

| Doc | Purpose |
|---|---|
| `docs/plans/GRAND_PLAN.md` | Overall plan |
| `docs/plans/MASTER_REQUIREMENTS.md` | Requirements |
| `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md` | Current state |
| `docs/plans/STAGE2_CLOSEOUT_WORK_ORDER.md` | Prior-cycle gen-32 work order / Stage 2 scope provenance (not current implementation authority — snap sections use the pair model gen32 was built against; current snap authority is GRAND_PLAN §6.2) |
| `docs/instructions/PM_OPERATING_RULES.md` | PM operating rules |
| `docs/prompts/SESSION_PREAMBLE.md` | Session preamble (subagents must read first) |
| `docs/reports/EXECUTION_LOG.md` | Execution history |
| `docs/references/SOURCES.md` | Vendored-source attribution / patch provenance |
| `docs/references/macbook-build-spec.md` | MacBook machine/build spec |
| `docs/references/nixos-hyprland-build-spec.md` | Earlier **Alienware-desktop** build spec (dual-monitor, Windows→NixOS) — kept as reference; predates the MacBook target and is not the current machine |
| `docs/research/RESEARCH_GUIDE.md`, `docs/research/VISUAL_RESEARCH.md`, `docs/references/visual-design-reference.md` | Research / visual reference |
| `README.md`, `docs/README.md` | Repo overview / documentation index |
| `docs/instructions/` | Recovery, controls, updating, wallpapers, PM operating rules |
| `docs/reports/gen32-recovery-diagnosis.md` | Accepted recovery findings D1–D9 + current reservation/reflow snap semantics |
| `docs/reports/codex-consultation-record.md` | Consultation/review-gate status |
| `docs/reports/REPOSITORY_REPRODUCIBILITY_AUDIT.md` | Repo normalization + reproducibility verdict |
| `docs/reports/xbox-bluetooth-diagnostic.md` | Xbox controller Bluetooth diagnostic |
| `docs/reports/stage2-runtime-gate.md` | Gen-32 runtime gate — ran and stopped on physical hard fail (historical execution evidence) |
| `docs/plans/stage2-closeout.md` | Prior-cycle pre-gen32 operator gate (historical; uses the pair model gen32 was built against) |
| `docs/plans/stage2-correction-manifest.md` | Frozen manifest that produced gen32 (historical build evidence) |

## Handoff / recovery (point-in-time, generation 32)

The current recovery resume path starts at `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md` →
`docs/reports/gen32-recovery-diagnosis.md` → `docs/reports/codex-consultation-record.md` →
`docs/plans/GRAND_PLAN.md`. The dated July incident briefs below are supporting historical context:

- `docs/briefs/PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md`
- `docs/briefs/PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md`
- `docs/instructions/recovery.md`

## Historical (superseded — read for context only)

- `docs/archive/superseded-docs/`, `docs/archive/superseded-handoffs/` — dated snapshots of
  earlier plans/handoffs; not current.

## Prompts / research (working material)

- `docs/prompts/` — per-stage Codex task prompts (Stage 1 → Stage 3) + `SESSION_PREAMBLE.md`.
- `docs/research/` — upstream inventories and driver/hardware notes. Raw upstream
  clones live in gitignored `/repos/` (~11 GB, re-cloneable).

---

## Branches

- **`main`** — canonical, complete project. The only active branch; use this.

The former `codex/macbook-desktop` line was normalized onto `main` and retired.
The former `stage3/topbar` branch and its `/home/alex/aurora-stage3` worktree were
also retired (2026-08-09): its one unique commit's source is now dormant on `main`
at `modules/home/aurora-shell/stage-3-in-progress/topbar/`.
