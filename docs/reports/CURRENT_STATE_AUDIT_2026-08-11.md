# CURRENT STATE AUDIT — 2026-08-11

_The current verified machine + repository snapshot. Supersedes
`CURRENT_STATE_AUDIT_2026-08-09.md` (now a historical verified snapshot for that
date). Per `docs/instructions/PM_OPERATING_RULES.md` §1, supersede this with a newer
dated audit when it goes stale; do not edit it in place to make it current._

**Stage status: `STAGE 2 — OPEN`.**

Seven states are never collapsed: **written · built · installed · activated · tested ·
passed · accepted.** Any check not actually run is `UNVERIFIED`.

---

## A. Live / known machine state

This session was documentation/repository-truth only. The machine was inspected
**read-only** (no build, activation, or reboot).

| Fact | Value | Evidence |
|---|---|---|
| `/run/current-system` | `62aim1mw2c26siwlymv9r5xa0qqa5ryw-nixos-system-macbook-26.11…` | `readlink -f` (this session, 2026-08-11) |
| `/run/booted-system` | `62aim1mw…` — **identical** to current | `readlink -f` |
| System profile default | `62aim1mw…` | `readlink -f /nix/var/nix/profiles/system` |
| **Active generation** | **generation 32** (store id `62aim1mw…`) — the generation that booted and **physically hard-failed** | matches the gen-32 id recorded across the recovery docs |
| Generations on disk | 8, 9, … 29, 30, 31, **32** | `ls /nix/var/nix/profiles/` |
| Failed units | **none** (system and user) | `systemctl [--user] --failed` |

Known state (authoritative, from the recovery investigation and operator gate):

- **Stage 2 is OPEN.** Generation 32 passed the automated structural gate 41/41 and then
  **failed the physical operator gate on ten defects**; the operator stopped the gate.
- **No Stage 3 deployment is permitted** until Stage 2 physically passes. Stage 3 source is
  present but dormant (see §B).
- **Rail previews and exact-window rail selection work** and are a **preservation
  requirement** for any window-model fix.
- **Accepted gen-32 recovery findings — defect record D1–D9**, all **OPEN**: D1–D7 and D9
  are diagnosed to the level recorded; **D8 (focus-dependent Kitty scroll) is UNRESOLVED —
  no accepted root cause.** None of D1–D9 is implemented, built, or physically accepted. See
  `docs/reports/gen32-recovery-diagnosis.md`.
- **Recovery diagnostic review completed**: two independent blind GPT-5.6 Sol Pass-1 reviews
  converged on the diagnosis (`docs/reports/codex-consultation-record.md`). An adversarial
  Pass-2 review artifact exists, but this audit does **not** assert a fully accepted
  adversarial sign-off — the operator's implementation gate is separate and remains open.
  Accepted **diagnosis only** — not a fix.
- **Xbox controller reliability is OPEN**: immediate connection proven (917 ms) and ≥13 min
  stable once; repeatability **unproven**, root cause **unknown**; no spontaneous disconnect
  proven. Full gate in `docs/reports/xbox-bluetooth-diagnostic.md`.
- Other open debts (wallpaper mouse path, TV reachability, VA-API/iHD verification, persistent
  boot default, npm-global duplicates) carry forward from the archived gen-31 audit §8.

---

## B. Repository state

Stable repository topology (verify exact mutable HEAD from `git log -1` directly):

| Fact | Value |
|---|---|
| Canonical repo | `/home/alex/nix` |
| Remote | `AlexbringsMercy/nix` (GitHub default branch `main`) |
| Branch | `main` (the only active branch) |
| Upstream | `origin/main` |
| Sync model | local `main` tracks `origin/main`; verify exact HEAD and ahead/behind from Git directly — this audit does not freeze a specific commit as eternal truth |
| Tree | clean at time of audit |
| Retired | `codex/macbook-desktop` (normalized onto `main`) and `stage3/topbar` + `/home/alex/aurora-stage3` worktree — both gone locally and remotely |
| Stage 3 source | **dormant** on `main` at `modules/home/aurora-shell/stage-3-in-progress/topbar/` (not built, not imported) |
| Machine-local wrapper | live instance at `~/.config/nixos-local/` (not committed, by design); **canonical template tracked** at `hosts/macbook/nixos-local/` |

Source-completeness and reproducibility: `docs/reports/REPOSITORY_REPRODUCIBILITY_AUDIT.md`.
Source map: `docs/references/NIXOS_CURRENT_SOURCE_INDEX.md`.

---

## C. Live-vs-source caveat (important)

**Tracked source has been corrected, but nothing was built or activated since the gen-32
deployment on 2026-07-29.** In particular, `modules/home/fish.nix`'s
`rebuild-macbook`/`test-macbook` aliases now use the Git-backed `git+file:///home/alex/nix`
input instead of raw `path:` — **in the tracked source only.** The running generation (gen 32,
built 2026-07-29) predates every August correction, so the **live shell may still expose the
old alias** until a future **accepted** generation installs the corrected configuration.

This caveat is intentional. It closes only when a future Stage 2 closure is built,
boot-deployed, rebooted, and physically accepted.

---

## D. What this audit does not claim

- Gen32 was built, activated, and physically tested — its failures produced the accepted
  recovery findings (D1–D9). No **post-gen32 / August source correction** has been built or
  activated.
- D1–D7 and D9 are **diagnosed** and D8 is **unresolved** — none is fixed; Stage 2 remains
  physically failed/open.
- The active generation id above is a read-only observation this session; re-verify live
  before any deployment decision.
- This audit does not embed a specific Git HEAD as current truth; documentation-only commits
  advance `main` without changing machine state, so the exact HEAD should be verified from Git
  directly (`git rev-parse HEAD`).
