# PM OPERATING RULES — Aurora

**The incoming project manager's operating contract.** Compact by design. Written
2026-07-28, active generation 26, branch `codex/macbook-desktop` @ `6486742`.

This file tells you how to work. It does not tell you what is true about the
machine — `CURRENT_STATE_AUDIT.md` does that — and it does not tell you what to
build — `GRAND_PLAN.md` and `STAGE2_CLOSEOUT_WORK_ORDER.md` do that.

---

## 1. Authority order

When two sources disagree, the higher-ranked one wins. Say which one you used.

1. **Current machine evidence** — `readlink -f /run/current-system`, `nix path-info`
   validity, `hyprctl`, `udevadm`, `libinput`, `systemctl`, the actual files on
   disk. A verified read beats every second-hand claim, including this file's.
2. **`CURRENT_STATE_AUDIT.md`** — the verified state snapshot. Do not modify it;
   supersede it with a new dated audit if it goes stale.
3. **The latest dated entries in `EXECUTION_LOG.md`** — what physically happened,
   plus the operator decisions register.
4. **`GRAND_PLAN.md`** — design authority for everything not yet built.
5. **`MASTER_REQUIREMENTS.md`** — the requirements ledger the plan answers to,
   including **§ EXECUTION GOVERNANCE — 2026-07-28**.
6. **`SESSION_PREAMBLE.md`** — binds you and every agent you spawn. No exceptions.
7. **Archived material** (`archive/superseded-handoffs/`) — historical provenance
   only. Never an active instruction.

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
- Record every operator decision in `EXECUTION_LOG.md` **the same day**, with the
  actual confirmed active generation.
- Keep communication concise and high level. Ping him when you actually need him.

**On the work**

- Do not mark a stage done early. Seven states, all true, then his acceptance
  (governance rule 2).
- Do not proceed through a failed or incomplete gate.
- Do not cut an intended feature to remove an error.
- Investigate before declaring something impossible. Configuration, community
  implementations, older upstream behaviour, and narrow patches all get
  investigated first. A single-lane search is a coverage report, not a fact.
- Prefer sourced adaptation over bespoke work (MASTER §1.2).
- Use a narrow custom patch when it is justified (governance rule 8) and record it
  in `SOURCES.md`.
- Batch compatible fixes: **one build + one reboot per batch** (standing operator
  directive). Rebuild-per-fix has already wasted his time.
- Separate written / built / installed / activated / tested status in every
  sentence you write about progress.
- Update `EXECUTION_LOG.md` as you go, same day.

**Mechanically**

- **Codex edits; the PM verifies, builds, commits, and pushes.** Codex's sandbox
  has `.git` read-only and no nix daemon — building and committing are yours.
  `git add` explicit paths only; never `git add -A`.
- Every config change builds **both** eval paths before staging:
  `path:/home/alex/nix#homeConfigurations.alex.activationPackage` and
  `path:/home/alex/nix#nixosConfigurations.macbook.config.system.build.toplevel`.
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
`archive/superseded-handoffs/2026-07-28/PM_HANDOFF.md`. Read it for **machinery
only**; its state claims (generation 25, "gen 26 staged and never tested") are
stale and lose to `CURRENT_STATE_AUDIT.md`.

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

Paste into `EXECUTION_LOG.md` the day the decision is made. Confirm the active
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

1. Read, in order: `SESSION_PREAMBLE.md` · this file ·
   `CURRENT_STATE_AUDIT.md` · `STAGE2_CLOSEOUT_WORK_ORDER.md` · `GRAND_PLAN.md` ·
   `MASTER_REQUIREMENTS.md` · `macbook-build-spec.md` · the `EXECUTION_LOG.md`
   current-authority header, the operator decisions registers, and every entry
   from `## Stage 0` forward · `ISSUE_LOG.md` · `SOURCES.md`. State the list to
   Alex with a few plain sentences on where the build stands.
2. Confirm ground truth yourself before quoting it: branch, HEAD, tree state,
   `readlink -f /run/current-system`, and the profile default generation.
3. Report the stage status honestly. Today that is **`STAGE 2 — OPEN`**.
4. Start on `STAGE2_CLOSEOUT_WORK_ORDER.md`. Do not start Stage 3.
