# Documentation index

Project documentation for the **Aurora** desktop — a declarative NixOS + Home
Manager + Hyprland + QuickShell build for Alex's 2020 T2 MacBook Air.

- **Canonical repo:** `AlexbringsMercy/nix`, branch **`main`** (checked out at
  `/home/alex/nix`, upstream `origin/main`). `main` is the only active branch;
  the former `codex/macbook-desktop` line was normalized onto `main` and retired,
  and the `stage3/topbar` worktree/branch was retired after its unique source was
  absorbed onto `main` (see below).
- **Stage:** **Stage 2 is OPEN.**
- Repository entry point: [`../README.md`](../README.md). Source-tree map:
  [`references/NIXOS_CURRENT_SOURCE_INDEX.md`](references/NIXOS_CURRENT_SOURCE_INDEX.md).

## Authority order (highest wins)

When two documents disagree, the higher-ranked source wins. Full contract in
[`instructions/PM_OPERATING_RULES.md`](instructions/PM_OPERATING_RULES.md) §1.

1. **Current machine evidence** — live reads (`/run/current-system`, `hyprctl`, …).
2. [`reports/CURRENT_STATE_AUDIT_2026-08-09.md`](reports/CURRENT_STATE_AUDIT_2026-08-09.md) — verified state snapshot.
3. Latest dated entries in [`reports/EXECUTION_LOG.md`](reports/EXECUTION_LOG.md) — what happened + operator decisions.
4. [`plans/GRAND_PLAN.md`](plans/GRAND_PLAN.md) — design authority for everything not yet built.
5. [`plans/MASTER_REQUIREMENTS.md`](plans/MASTER_REQUIREMENTS.md) — requirements ledger.
6. [`prompts/SESSION_PREAMBLE.md`](prompts/SESSION_PREAMBLE.md) — binds every session and subagent.
7. [`references/visual-design-reference.md`](references/visual-design-reference.md) — visual *intent* only, subordinate to the Grand Plan.
8. `archive/` — historical provenance only, never an active instruction.

## `plans/` — forward-looking direction

| Doc | Role |
|---|---|
| [GRAND_PLAN.md](plans/GRAND_PLAN.md) | The design authority: architecture, surface ownership, stage sequence |
| [MASTER_REQUIREMENTS.md](plans/MASTER_REQUIREMENTS.md) | Requirements ledger + execution governance |
| [STAGE2_CLOSEOUT_WORK_ORDER.md](plans/STAGE2_CLOSEOUT_WORK_ORDER.md) | **The current open Stage 2 work order** |
| [stage2-closeout.md](plans/stage2-closeout.md) | Stage 2 operator close-out gate (`STAGE 2 — OPEN`) |
| [stage2-correction-manifest.md](plans/stage2-correction-manifest.md) | Frozen correction manifest (produced gen 32, which hard-failed) |

## `reports/` — observed state, results, evidence

| Doc | Role |
|---|---|
| [CURRENT_STATE_AUDIT_2026-08-09.md](reports/CURRENT_STATE_AUDIT_2026-08-09.md) | **Current** verified machine + repository state (supersedes the archived July gen-31 audit) |
| [gen32-recovery-diagnosis.md](reports/gen32-recovery-diagnosis.md) | Accepted recovery diagnosis — defects **D1–D9** (all OPEN) + approved reservation/reflow snap semantics |
| [EXECUTION_LOG.md](reports/EXECUTION_LOG.md) | Full implementation/validation history + operator decisions |
| [REPOSITORY_REPRODUCIBILITY_AUDIT.md](reports/REPOSITORY_REPRODUCIBILITY_AUDIT.md) | Repo normalization + reproducibility verdict |
| [stage2-runtime-gate.md](reports/stage2-runtime-gate.md) | The runtime gate that was stopped on the gen 32 hard fail |
| [codex-consultation-record.md](reports/codex-consultation-record.md) | Codex consultation record — recovery reviews **completed** 2026-08-09 (diagnosis accepted; fixes still OPEN) |
| [xbox-bluetooth-diagnostic.md](reports/xbox-bluetooth-diagnostic.md) | Xbox controller Bluetooth diagnostic |
| [issue-log-migration-2026-07-29.md](reports/issue-log-migration-2026-07-29.md) | Record of the ISSUE_LOG archival/migration |

## `references/` — material referred back to

| Doc | Role |
|---|---|
| [NIXOS_CURRENT_SOURCE_INDEX.md](references/NIXOS_CURRENT_SOURCE_INDEX.md) | Map of the source tree (flake, modules, patches, shell) |
| [SOURCES.md](references/SOURCES.md) | Provenance ledger for vendored/adapted components |
| [visual-design-reference.md](references/visual-design-reference.md) | Visual intent (mood, quality bar, motion) |
| [macbook-build-spec.md](references/macbook-build-spec.md) | MacBook machine/build specification |
| [nixos-hyprland-build-spec.md](references/nixos-hyprland-build-spec.md) | Earlier Alienware-desktop build spec (see note in `NIXOS_CURRENT_SOURCE_INDEX.md`) |

## `instructions/` — how to operate, build, recover, use

| Doc | Role |
|---|---|
| [PM_OPERATING_RULES.md](instructions/PM_OPERATING_RULES.md) | The project-manager operating contract |
| [recovery.md](instructions/recovery.md) | Symlink-safe dotfile restore + generation rollback |
| [updating.md](instructions/updating.md) | Controlled input updates after acceptance |
| [controls.md](instructions/controls.md) | Desktop controls (keybinds + pointer paths) |
| [wallpapers.md](instructions/wallpapers.md) | Wallpaper library + adaptive-color pipeline |

Build wiring (firmware, wrapper) is documented at
[`../hosts/macbook/nixos-local/README.md`](../hosts/macbook/nixos-local/README.md).

## `prompts/` — retained task prompts + session instructions

- [SESSION_PREAMBLE.md](prompts/SESSION_PREAMBLE.md) — mandatory preamble for every session/subagent.
- `stage1*.md`, `stage2*.md`, `stage3-taskbar-mapping.md` — the retained per-stage
  Codex/task prompts.

## `research/` — research work, inventories, findings

Full-repo reads and topic research (ilyamiro, caelestia, agridyne, iNiR, cxOrz,
hardware-drivers, lock-screen, wallpaper-pipeline, window-input, …), plus
[RESEARCH_GUIDE.md](research/RESEARCH_GUIDE.md), [SYNTHESIS.md](research/SYNTHESIS.md)
and [VISUAL_RESEARCH.md](research/VISUAL_RESEARCH.md).

## `briefs/` — handoffs and kickoffs

- [PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md](briefs/PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md)
- [PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md](briefs/PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md)

These are dated incident briefs; their git-state metadata predates the 2026-08-09
branch normalization (canonical branch is now `main`).

## `archive/` — superseded / historical (never an active instruction)

`archive/superseded-docs/` and `archive/superseded-handoffs/` hold dated
snapshots of retired plans, handoffs, the Waybar-era design, and `ISSUE_LOG.md`.
History only.

## Stage 3 source (dormant)

The unfinished Stage 3 top-bar source lives, dormant, on `main` at
`modules/home/aurora-shell/stage-3-in-progress/` — not built, not imported. Its
provenance and reactivation steps are in that directory's `README.md`. The Stage 3
mapping prompt is [prompts/stage3-taskbar-mapping.md](prompts/stage3-taskbar-mapping.md).
