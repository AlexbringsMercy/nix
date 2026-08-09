# CURRENT STATE AUDIT — 2026-08-09

_The current verified machine + repository snapshot. Supersedes the July generation-31
audit, archived at
`docs/archive/superseded-docs/2026-08-09/CURRENT_STATE_AUDIT-2026-07-29-gen31.md`.
Per `docs/instructions/PM_OPERATING_RULES.md` §1, supersede this with a newer dated audit
when it goes stale; do not edit it in place to make it current._

**Stage status: `STAGE 2 — OPEN`.**

Seven states are never collapsed: **written · built · installed · activated · tested ·
passed · accepted.** Any check not actually run is `UNVERIFIED`.

---

## A. Live / known machine state

Repository-finalization scope this session was documentation/source-truth only. The machine
was inspected **read-only** (no build, activation, or reboot).

| Fact | Value | Evidence |
|---|---|---|
| `/run/current-system` | `62aim1mw2c26siwlymv9r5xa0qqa5ryw-nixos-system-macbook-26.11…` | `readlink -f` (this session) |
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
- **Recovery consultation completed**: two independent blind Codex reviews converged on the
  diagnosis (`docs/reports/codex-consultation-record.md`). Accepted **diagnosis only** — not
  a fix.
- **Xbox controller reliability is OPEN**: immediate connection proven (917 ms) and ≥13 min
  stable once; repeatability **unproven**, root cause **unknown**; no spontaneous disconnect
  proven. Full gate in `docs/reports/xbox-bluetooth-diagnostic.md`.
- Other open debts (wallpaper mouse path, TV reachability, VA-API/iHD verification, persistent
  boot default, npm-global duplicates) carry forward from the archived gen-31 audit §8.

---

## B. Repository state (verified this session)

| Fact | Value |
|---|---|
| Canonical repo | `/home/alex/nix` |
| Remote | `AlexbringsMercy/nix` (GitHub default branch `main`) |
| Branch | `main` (the only active branch) |
| Upstream | `origin/main` |
| HEAD at start of this session | `f78a462f8a3af279a2a38ba232b64ad8c4a1e9c0` (advanced by this session's documentation-truth commit — see `git log -1`) |
| Sync | local `main` == `origin/main`, **0 ahead / 0 behind** |
| Tree | clean |
| Retired | `codex/macbook-desktop` (normalized onto `main`) and `stage3/topbar` + `/home/alex/aurora-stage3` worktree — both gone locally and remotely |
| Stage 3 source | **dormant** on `main` at `modules/home/aurora-shell/stage-3-in-progress/topbar/` (not built, not imported) |
| Machine-local wrapper | live instance at `~/.config/nixos-local/` (not committed, by design); **canonical template tracked** at `hosts/macbook/nixos-local/` |

Source-completeness and reproducibility: `docs/reports/REPOSITORY_REPRODUCIBILITY_AUDIT.md`.
Source map: `docs/references/NIXOS_CURRENT_SOURCE_INDEX.md`.

---

## C. Live-vs-source caveat (important)

**Tracked source has been corrected, but nothing was built or activated this session.** In
particular, `modules/home/fish.nix`'s `rebuild-macbook`/`test-macbook` aliases now use the
Git-backed `git+file:///home/alex/nix` input instead of raw `path:` — **in the tracked
source only.** The running generation (gen 32, built 2026-07-29) predates this and every
other August correction, so the **live shell may still expose the old alias** until a future
**accepted** generation installs the corrected configuration.

This caveat is intentional. It is **not** resolved by building — no build/activation/reboot
is in scope for repository finalization. It closes only when a future Stage 2 closure is
built, boot-deployed, rebooted, and physically accepted.

---

## D. What this audit does not claim

- No runtime behaviour of any post-gen-31 correction is verified — none has been built or
  activated.
- D1–D7 and D9 are **diagnosed** and D8 is **unresolved** — none is fixed; Stage 2 remains
  physically failed/open.
- The active generation id above is a read-only observation this session; re-verify live
  before any deployment decision.
