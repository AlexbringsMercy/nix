# PM OPERATING RULES — Aurora

**The incoming project manager's operating contract.** Compact by design. Written
2026-07-28; **canonical branch `main`** (the `codex/macbook-desktop` line was
fast-forwarded onto `main` and retired 2026-08-09); **Stage 2 OPEN.** Mutable
machine/generation state is deliberately **not** hard-coded here — defer to
`docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md` (the machine is currently on
generation 32, hard-failed). The rules themselves are unchanged and remain binding.

This file tells you how to work. It does not tell you what is true about the
machine — `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md` does that — and it does not tell you what to
build — `docs/plans/GRAND_PLAN.md` (design authority), `docs/plans/MASTER_REQUIREMENTS.md`
(requirements ledger), and `docs/reports/gen32-recovery-diagnosis.md` (accepted recovery
findings and current snap/minimize semantics) do that.
`docs/plans/STAGE2_CLOSEOUT_WORK_ORDER.md` is the prior-cycle gen-32 work order — useful for
Stage 2 scope/provenance, but **not current implementation authority** where it conflicts
with later corrections (notably: its snap sections use the pair model gen32 was built against;
current binding snap authority is the reservation/reflow model in `docs/plans/GRAND_PLAN.md` §6.2).

---

## 1. Authority order

When two sources disagree, the higher-ranked one wins. Say which one you used.

1. **Current machine evidence** — `readlink -f /run/current-system`, `nix path-info`
   validity, `hyprctl`, `udevadm`, `libinput`, `systemctl`, the actual files on
   disk. A verified read beats every second-hand claim, including this file's.
2. **`docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md`** — the verified state snapshot. Do not modify it;
   supersede it with a new dated audit if it goes stale.
3. **The latest dated entries in `docs/reports/EXECUTION_LOG.md`** — what physically happened,
   plus the operator decisions register.
4. **`docs/plans/GRAND_PLAN.md`** — design authority for everything not yet built.
5. **`docs/plans/MASTER_REQUIREMENTS.md`** — the requirements ledger the plan answers to,
   including **§ EXECUTION GOVERNANCE — 2026-07-28**.
6. **`docs/prompts/SESSION_PREAMBLE.md`** — binds you and every agent you spawn. No exceptions.
7. **`docs/references/visual-design-reference.md`** — visual *intent* only (mood, quality bar,
   motion feel, typography). Explicitly subordinate to `docs/plans/GRAND_PLAN.md`; it is
   never architecture, surface-ownership, or palette authority.
8. **Archived material** (`docs/archive/superseded-handoffs/`,
   `docs/archive/superseded-docs/`) — historical provenance only. Never an active
   instruction. `docs/archive/superseded-docs/2026-07-29/ISSUE_LOG.md` and the
   pre-Grand-Plan `docs/archive/superseded-docs/2026-07-29/visual-design-reference.md`
   live there; both are dated audits of the retired Waybar/Rofi-era system. (The
   **current** visual-intent doc is the live `docs/references/visual-design-reference.md`
   in item 7 above.)

Two things sit outside the ranking because they are absolute:

- **Never mention licensing.** Attribution for vendored code is upstream repo +
  path only. Not in code, commits, logs, prompts, reports, or thinking.
- **Never narrow what's intended.** Any answer that cuts or downgrades a planned
  feature to silence a bug is wrong.

---

## 2. PM rules

**With Alex**

- Stay at his decision level. Product, architecture, tradeoffs, scope, deferral
  approvals, physical gate acceptance — those are his. Routine implementation
  choices are yours.
- Do not ask him to pick commands, flags, or implementation minutiae.
- Every escalation states a recommendation, not an open menu.
- Surface **all** divergences and deferrals. Nothing is "closed" or "deferred"
  unless Alex said so, in his words.
- Record every operator decision in `docs/reports/EXECUTION_LOG.md` **the same day**, with the
  actual confirmed active generation.
- Keep communication concise and high level. Ping him when you actually need him.

**On the work**

- Do not mark a stage done early. Seven states, all true, then his acceptance
  (governance rule 2).
- Do not proceed through a failed or incomplete gate.
- Do not cut an intended feature to remove an error.
- **No surface may be removed until its replacement is live in the same closure.**
  (Decision 21, 2026-07-29 — operator-approved standing rule.) "Retired in the
  architecture" is **not** "replaced on the machine." A plan can declare a surface
  retired years before the thing that replaces it exists; deleting it early does not
  de-duplicate anything, it deletes the only copy. This applies to keybinds, panels,
  status entries, scripts and packages alike.
  **When briefing any agent, state the *current* target, not the end state** — this
  rule exists because three separate sessions each removed a still-load-bearing
  surface while correctly following a brief that described the end state:
  `special:min-*` before the taskbar (caught by the operator), the `Super+K`
  dashboard bind, and the rail's tray/clock/status/power entries (both caught in
  review). The agents were not at fault; the briefs were.
  The test is concrete: **after this closure boots, can the user still do the thing
  the removed surface did?** If not, it stays, with an in-file comment naming the
  stage that retires it.
- Investigate before declaring something impossible. Configuration, community
  implementations, older upstream behaviour, and narrow patches all get
  investigated first. A single-lane search is a coverage report, not a fact.
- Prefer sourced adaptation over bespoke work (MASTER §1.2).
- Use a narrow custom patch when it is justified (governance rule 8) and record it
  in `docs/references/SOURCES.md`.
- Batch compatible fixes: **one build + one reboot per batch** (standing operator
  directive). Rebuild-per-fix has already wasted his time.
- **Publish a frozen batch manifest before any expensive build** (decision 20,
  2026-07-29). The manifest lists every item with `Code complete` / `PM reviewed` /
  `Included`. **No build starts until every blocking row is complete.** Do not
  compile or stage a generation for each small config, script, QML, documentation or
  shell fix — batch them, continue independent work in parallel, and take one
  combined build → boot-only deploy → reboot → gate.
- **A validation-only compile must name the uncertainty it resolves** and why
  cheaper static or unit checks are insufficient. "It was ready" is not a reason to
  boot a generation.
- **Reuse existing Hyprland/Hyprbars store outputs when the source patch set is
  unchanged.** Never trigger a compositor or plugin recompile merely because
  unrelated configuration or shell code changed. Check the patch list in the
  derivation, not the calendar.
- **Keep deployed closures stage-pure** — later-stage or incomplete work must never enter
  the current closure. Dormant/incomplete source lives in **ordinary directories on `main`**
  (e.g. the Stage 3 top-bar source under `modules/home/aurora-shell/stage-3-in-progress/`),
  **not** in a permanent branch or worktree. A temporary branch/worktree may still be used
  when a bounded task genuinely needs isolation during a build/reboot, but branches and
  worktrees are **not** permanent project or stage containers.
- **Sonnet-first** for narrow diagnosis, source location and straightforward
  implementation. The PM reads the evidence and escalates to a stronger model only
  when source-level design ambiguity or patch risk justifies it.
- Separate written / built / installed / activated / tested status in every
  sentence you write about progress.
- Update `docs/reports/EXECUTION_LOG.md` as you go, same day.

**Mechanically**

- **Codex edits; the PM verifies, builds, commits, and pushes.** Codex's sandbox
  has `.git` read-only and no nix daemon — building and committing are yours.
  `git add` explicit paths only; never `git add -A`.
- Every config change builds **both** eval paths before staging (git-backed input,
  never raw `path:` — it drags the ignored `repos/` clones into the store):
  `git+file:///home/alex/nix#homeConfigurations.alex.activationPackage` and
  `git+file:///home/alex/nix#nixosConfigurations.macbook.config.system.build.toplevel`.
- **Use detached builds.** Long builds run in `systemd-run --user` units — a
  tool-managed background task's timeout can kill a nix build mid-derivation, and
  the compositor is one long derivation.
- **Never live-hot-swap the compositor or Hyprbars.** Plugin hot-swap double-loads
  the singleton and SIGSEGVs into safe mode; a live `switch` attached to your
  terminal has OOM-killed this machine. Boot-only deployment, then a clean reboot.
- Deploys route through the machine-local wrapper flake at
  `~/.config/nixos-local` (not in Git; repin with `nix flake update` after every
  commit). `--max-jobs 2 --cores 2`.
- All durable PM outputs — research reports, Codex finals, event streams, evidence
  captures, build logs — go to `/home/alex/.local/state/aurora-build/pm/`, never
  to a session scratchpad. Session scratchpads die with sessions; this was paid
  for twice.
- Never stage or push `secrets/`, the firmware tree, wallpaper binaries, or
  `repos/`.
- Push at every stage gate.

The full inherited machinery — the exact Codex `systemd-run` invocation, the
deploy command sequence, the armed-resume loop, and the accumulated
already-paid-for lessons — is in the archived
`docs/archive/superseded-handoffs/2026-07-28/PM_HANDOFF.md`. Read it for **machinery
only**; its state claims (generation 25, "gen 26 staged and never tested") are
stale and lose to `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md`.

---

## 3. Mandatory stage close-out table

Every stage report includes this table. One row per requirement assigned to the
stage. **No row may disappear because it is inconvenient**, and no skipped check
becomes an implied pass — a check that was not run is `UNVERIFIED`, never blank
and never `PASS`.

```markdown
| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| <requirement, one per row> | Y/N | Y/N | Y/N | Y/N | PASS/FAIL/UNVERIFIED | Y/N | <command output, file:line, or "Alex, <date>"> |
```

The stage is `OPEN` unless every row reads `Y … PASS … Y` and Alex has accepted
the gate in his own words.

---

## 4. Decision-log template

Paste into `docs/reports/EXECUTION_LOG.md` the day the decision is made. Confirm the active
generation from the machine — never copy a number from a document.

```markdown
### Decision NN — <short title>

**Date/time:** YYYY-MM-DD HH:MM <TZ>
**Active generation:** NN  (`readlink -f /nix/var/nix/profiles/system`)
**Stage:** <stage>
**Status:** APPROVED / REJECTED / DEFERRED / OVERRIDDEN — BINDING
**Original requirement:** <what GRAND_PLAN / MASTER_REQUIREMENTS asked for, cited>
**Operator decision:** <what Alex decided, in his words where possible>
**Reason:** <why>
**Plan impact:** <what changes in the plan, which stage now owns it>
**Revisit trigger:** <the event that reopens this, or "none — final">
**Acceptance condition:** <the objective test that proves it satisfied>
```

---

## 5. First actions for the incoming PM

1. Read, in order: `docs/prompts/SESSION_PREAMBLE.md` · this file ·
   `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md` ·
   `docs/reports/gen32-recovery-diagnosis.md` (defect record D1–D9) ·
   `docs/reports/codex-consultation-record.md` (consultation status) ·
   `docs/plans/GRAND_PLAN.md` ·
   `docs/plans/MASTER_REQUIREMENTS.md` · `docs/references/macbook-build-spec.md` · the `docs/reports/EXECUTION_LOG.md`
   current-authority header, the operator decisions registers, and every entry
   from the current Stage 2 correction work forward · `docs/references/SOURCES.md`.
   Stage 2 preservation requirements (rail previews, exact grouped selection) are
   carried forward into current authority (`docs/plans/GRAND_PLAN.md` §5.3/§6.2,
   `docs/reports/gen32-recovery-diagnosis.md`). The prior-cycle work order
   `docs/plans/STAGE2_CLOSEOUT_WORK_ORDER.md` is useful for Stage 2 scope/provenance
   but is **not current implementation authority** — its snap sections use the pair
   model gen32 was built against, not the current reservation/reflow model.
   The dated July incident briefs (`docs/briefs/PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md`
   and `docs/briefs/PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md`) are useful supporting
   context — read them for provenance, but **do not treat the kickoff's task list as
   current instructions** (its blind-review and root-cause-report tasks are now
   complete).
   **`ISSUE_LOG.md` is no longer on this list** — it is an archived dated audit of
   the retired Waybar/Rofi-era system; its still-live items were migrated into the
   current gate (see `docs/reports/issue-log-migration-2026-07-29.md`). State the list to
   Alex with a few plain sentences on where the build stands.
2. Confirm ground truth yourself before quoting it: branch, HEAD, tree state,
   `readlink -f /run/current-system`, and the profile default generation. **Never
   inherit a generation number, a build outcome, or a "the build started" claim
   from a prior session's closing message** — a build that was launched is not a
   build that completed, staged, or booted. Check for a live process, a newer
   generation link, a newer boot entry, and whether the current source's closure is
   actually valid in the store.
3. Report the stage status honestly. Today that is **`STAGE 2 — OPEN`**.
4. Start on the gen-32 **recovery resume path**: `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md`
   → `docs/reports/gen32-recovery-diagnosis.md` → `docs/reports/codex-consultation-record.md`
   → `docs/plans/GRAND_PLAN.md`. Current design and requirements authority is
   `GRAND_PLAN.md` + `MASTER_REQUIREMENTS.md` + `gen32-recovery-diagnosis.md`, not
   the prior-cycle work order. Do not start Stage 3.

**Latest binding operator decisions** (full text in `docs/reports/EXECUTION_LOG.md`):
decisions 20–23 (frozen manifest, no-premature-removal, dashboard entry paths,
persistent NixOS default boot) and **decisions 24–27** of 2026-07-29 — agent CLI
persistence/PATH ownership (pulled into the next compatible closure), native in-app
application updates with three-version retention (Stage 6/9), actionable writing
suggestions (Stage 6/9), and the final screenshot mode toolbar.
