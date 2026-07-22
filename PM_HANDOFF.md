# The Aurora Build — PM Handoff Brief

The design phase ended when `GRAND_PLAN.md` was written; execution is mid-flight. This
brief was written by the Fable PM session that closed out most of Stage 2, for the next
PM session. When it's read, you are the PM, and the build continues without a seam.

Written 2026-07-22. Where this file and `EXECUTION_LOG.md` disagree, trust the log.

## Who you are

You are the **project manager and verifier** of a complete operating system build — not
the designer (done and locked in `GRAND_PLAN.md`), and not the executor (delegated).
Alex's operating guidance to the PM model, binding and learned the hard way across three
PM sessions (two fired):

- **Stay high-level and efficient.** The PM model is expensive. Use your reasoning where
  it moves needles and needs Alex's decisions; delegate execution to Codex. Stay out of
  the weeds.
- **Straight talk, no overformatted jargon.** Tell him things plainly, as a high-level
  PM. Ping him when you *actually* need him, not every 5 minutes.
- **Never narrow what's intended.** Any answer that means cutting or downgrading a
  planned feature to silence a bug is WRONG. "The ecosystem lives with it" from one
  narrow search is a void conclusion (preamble precedence): if Alex says a fix exists,
  keep looking — this session's drag-bug research proved him right (upstream regression,
  fix = forward-port; see below). Easy answers in a new suit are still easy answers.
- **Nothing is "closed" or "deferred" unless Alex said so, in his words.** The PM called
  corner resize "closed by verdict" when Alex never accepted the fallback — he reopened
  it as non-negotiable. Plan features are commitments. Fallbacks are proposals until he
  signs off. Log his decisions in the EXECUTION_LOG decisions register **the same day**.
- **State your read list before starting work.** He will ask what you've read. The
  Tier 1 list below is the answer; read it fully, not performatively.

The execution model:

- **You write execution prompts** — exact scope, citations required, IN/OUT lists, report
  format. **Codex does the terminal/file work.** You launch, monitor, and steer directly.
  Codex gets the preamble + task-scoped context, NOT the full PM read list — it's the
  delegee; the PM is where full context lives (Alex's calibration).
- **You verify everything before it counts.** Diff the tree against claimed scope, re-run
  the checks Codex's sandbox couldn't (nix eval/build need the daemon — Codex can't reach
  it), verify load-bearing citations yourself (this session WebFetch-verified the upstream
  issue before acting on it).
- **You commit, build, push.** Codex's sandbox mounts `.git` read-only. Codex edits,
  PM commits. `git add` explicit paths only.
- **Alex gate-tests** from compressed checklists. Batch his touches: **one build + one
  reboot per batch of fixes** (his standing directive — rebuild-per-fix wasted his time).
- **Research/patch work runs Codex on xhigh** (`-c model_reasoning_effort=xhigh`) with
  **at most ~2 judicious subagents** — never 6+ fan-outs (operator budget ruling).
- **Subagent tiers: never haiku.** Sonnet light, Opus medium+. Every Codex session and
  every subagent reads `/home/alex/nix/SESSION_PREAMBLE.md` first, no exceptions.

Work autonomously between gates. Come to Alex for decisions, gate tests, reboots, and
anything needing his hands (e.g. the touch-size measurement below).

## What you're managing

Execution of `~/nix/GRAND_PLAN.md` — the complete NixOS + Hyprland "Aurora" desktop —
on Alex's 2020 MacBook Air: T2, Intel i3 dual-core, 8GB RAM, 2560×1600 @ 1.5 scale.
The hardware shapes operations: `--max-jobs 2 --cores 2`, memory caps on Codex units,
no parallel heavy builds. The flake at `~/nix` is sole authority; deploys go through the
machine-local wrapper flake at `~/.config/nixos-local/` (injects Apple firmware).

Hyprland is 0.55.4 **native-Lua config** (not legacy): `hyprctl keyword` fails ("use
eval"); live changes via `hyprctl eval 'hl.config({...})'`; legacy dispatch strings parse
but fail at runtime. We now **carry a compositor patch** (see state) — plugin/compositor
changes require a clean reboot into the new gen, never hot-swap (SIGSEGV, learned live).

## Authority order

1. **`SESSION_PREAMBLE.md` + GRAND_PLAN locked decisions** — not yours to relitigate.
2. **`EXECUTION_LOG.md`** — what physically happened + the operator decisions register.
   Beats this file and beats memory.
3. **`GRAND_PLAN.md` / `MASTER_REQUIREMENTS.md` / `macbook-build-spec.md`** — design
   authority for everything not yet built.
4. **Ground truth** — repo, git history, the running machine. A verified read beats every
   second-hand claim, including this brief's.

## Files to read

### Tier 1 — read fully, in this order, before any work; state the list to Alex

- **`SESSION_PREAMBLE.md`** — binds you and everyone you spawn.
- **This file.**
- **`GRAND_PLAN.md`** — whole, once. Note §3.3 (motion), §5.1–5.2 (Stage 3 target),
  §6.2 (window spec), §10 (stage sequence).
- **`MASTER_REQUIREMENTS.md`** and **`macbook-build-spec.md`** — the requirement ledger
  and hardware spec. A previous PM skipped these and was corrected; don't.
- **`EXECUTION_LOG.md`** — at minimum: the operator decisions register, the Stage 2 gate
  entry, the 2C/2D close-outs, and both 2026-07-22 entries (drag patch + session
  close-out). The close-out is the precise complement to this brief's state section.
- **`ISSUE_LOG.md`** — known issues.

### Tier 2 — before your first Codex launch

- **`SOURCES.md`** — vendored-components ledger.
- **House prompt style**: `codex-prompts/stage2d-drag-anchor-patch.md` (execution) and
  `codex-prompts/stage3-taskbar-mapping.md` (research/mapping) are the current templates:
  preamble first, task-scoped reads, IN/OUT scope, isolation constraints, verification
  duties, raw-data report.
- **`modules/nixos/build-harness.nix`** — scoped passwordless sudo (nix-env,
  switch-to-configuration, reboot/poweroff, nix-collect-garbage).
- **`scripts/aurora-resume-agent`** + its autostart.lua line — the reboot-resume loop.
- **`~/.config/nixos-local/flake.nix`** — wrapper (NOT in repo); `git+file://` on purpose,
  never `path:` (would copy 11GB of `repos/` to store).
- **`~/.local/state/aurora-build/pm/`** — the PM artifact directory (see machinery).
  Contains the drag research report, Codex final reports, the DWT evidence capture.

### Tier 3 — per-task, when you pick the task up

Named in the work queue below.

## The machinery you inherit

**PM artifact directory — NEW RULE, paid for twice**: session scratchpads die with
sessions; two sessions' research reports were nearly stranded that way. ALL PM outputs —
Codex finals, event streams, research reports, evidence captures, build logs — go to
`/home/alex/.local/state/aurora-build/pm/`, never to session-scoped scratch dirs.

**The Codex pipeline** (codex-cli at `/home/alex/.npm-global/bin/codex` — ALWAYS the
absolute path: systemd user units don't inherit the interactive PATH; a bare `codex`
dies exit 127):

```
systemd-run --user --unit=codex-<task> \
  -p WorkingDirectory=/home/alex/nix -p MemoryHigh=3G -p MemoryMax=4G -p CPUWeight=30 \
  bash -lc '/home/alex/.npm-global/bin/codex exec --cd /home/alex/nix \
   --sandbox workspace-write --json -c model_reasoning_effort=xhigh \
   --output-last-message /home/alex/.local/state/aurora-build/pm/<task>-final.md \
   "$(cat /home/alex/nix/codex-prompts/<task>.md)" \
   > /home/alex/.local/state/aurora-build/pm/<task>-events.jsonl 2>&1'
```

Watch with a detached poller on `systemctl --user is-active --quiet codex-<task>`.
**Steering/resume: global flags go BEFORE the `resume` subcommand** —
`codex exec --cd ... --json -c ... --output-last-message ... resume <thread-id> '<msg>'`
(the other order is exit 3). Thread IDs are in the first line of the events stream.
`--enable multi_agent` is available and stable when a prompt calls for subagents (≤2).

**Long builds**: also detached `systemd-run --user` units (a tool-managed background
task has a hard timeout; a killed nix build loses the whole in-flight derivation —
the compositor is ONE derivation, don't lose 40 minutes of compile to a 10-minute leash).

**Deploy procedure** (exact commands in EXECUTION_LOG): `nix flake update --flake
/home/alex/.config/nixos-local` (repins the git rev — needed after every commit) →
`nix build path:/home/alex/.config/nixos-local#nixosConfigurations.macbook.config.system.build.toplevel
--max-jobs 2 --cores 2` → `sudo nix-env --profile /nix/var/nix/profiles/system --set "$TOP"`
→ `sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot`. ("Not checking
switch inhibitors (action = boot)" is benign.) **Never** run a live `switch` attached to
your own terminal (OOM incident) — boot-only + armed resume.

**Armed resume loop**: `touch ~/.local/state/aurora-build/resume-armed`, then reboot;
autostart opens kitty running `claude --continue`. Un-armed boots do nothing.

**Verification both-paths rule**: every config change builds BOTH
`path:/home/alex/nix#homeConfigurations.alex.activationPackage` and
`path:/home/alex/nix#nixosConfigurations.macbook.config.system.build.toplevel` before
staging. Codex cannot build (no daemon in its sandbox) — building is yours.

## Current state — the exact resume point

- **Branch** `codex/macbook-desktop`, remote `github.com/AlexbringsMercy/nix`. HEAD at
  handoff includes the drag patch commit `df37152` and the handoff commit; pushed.
- **Generations**: gen 25 booted (Stage 2C content), **gen 26 staged boot-only and
  NEVER TESTED** — it carries the 2D half-snap rework (in-frame geometry + arrow-press
  release path). Do not report 2D fixes as live; the running system is gen 25.
- **Stage 2: CONDITIONAL PASS**, closes after the open items below land and Alex re-tests
  everything in ONE reboot.

### The open work queue, in order

1. **Finish the drag-patch builds.** The carried compositor patch
   (`modules/nixos/patches/hyprland-drag-anchor.patch` + overlay in `flake.nix`) is
   committed and PM-verified (applies with zero fuzz to the pinned source; overlay
   present in real eval; hyprbars rebuilds against the patched compositor via the
   overlay automatically). The interrupted build never compiled the patched Hyprland —
   re-run both builds (they resume from store). Background: the bug, the research, and
   the operator's conditions are in the 2026-07-22 log entries and
   `~/.local/state/aurora-build/pm/{dragresearch-final.md,dragpatch-final.md}`.
2. **DWT fix — root cause is FOUND, implement it.** The T2 trackpad is USB, udev defaults
   USB touchpads to `ID_INPUT_TOUCHPAD_INTEGRATION=external`, and libinput therefore
   reports `Disable-w-typing: n/a` — **DWT has never been active on this machine**;
   Hyprland's `dwt=true` is a silent no-op. Fix: udev hwdb entry
   (`touchpad:usb:v05acp0280:*` → `ID_INPUT_TOUCHPAD_INTEGRATION=internal`, lowercase
   vid/pid, via `services.udev.extraHwdb`). Then the tap-classification half: run
   `libinput measure touch-size /dev/input/event7` WITH ALEX (tool:
   `/nix/store/md7kljxi6ys3vbghgbliqcrp1x40mj1x-libinput-1.31.3-bin/bin/libinput`;
   alex is in `input` group, no sudo; keyboard=event2, trackpad=event7) and fill the 2D
   report's candidate stanza with measured palm/thumb size thresholds. Evidence of the
   leak: `pm/dwt-capture.log` (22 palm-taps during typing, ±0.15s of keypresses).
3. **Corner resize — REOPENED by operator, non-negotiable (decision #11).** He wants it
   working, not the Super+RMB fallback. Known mechanism: carried hyprbars v0.55.0
   reserves the 30px top bar and consumes pointer events over it, shadowing the
   compositor's corner border-grab zones. We already patch hyprbars (hover patch,
   `modules/home/hyprland/default.nix` + `patches/hyprbars-hover.patch`) — research and
   extend the carried patch so corner grabs work. Codex xhigh, house research style,
   sourced fixes preferred, isolation constraints like the drag prompt.
4. **Batch → one rebuild → one staged boot → ONE reboot with Alex.** Items 1–3 all land
   together. His re-test checklist: drag grab-point (4 grab positions × short/tall ×
   Super-drag/titlebar; floating unchanged; drop-retile works), gen-26 half-snap
   (in-frame, arrow-release, no permanent floaters), DWT (`Disable-w-typing: enabled` in
   `libinput list-devices` + typing test), corner resize. Then **Stage 2 gate closes** —
   push at the gate.
5. **Stage 3 prep — resume the mapping thread.** Prompt:
   `codex-prompts/stage3-taskbar-mapping.md` (component map donor→target for every §5.1
   element, batch plan sized to rebuilds, dev-loop feasibility: a second QuickShell
   instance running from the worktree for hot QML iteration — load-bearing for cycle
   time). The session died mid-run; thread `019f8ad6-f360-7340-8c92-c17189e395b0` is
   resumable; partial events at `pm/stage3prep-events.jsonl`. Verify anything it
   claims before you build the Stage 3 batches from it.

### Parked with paper trail (do not silently drop)

- Volume gesture: **deferred by Alex** (decision #9) to the compositor bump; note 0.56
  adds Lua touchpad gestures — revisit at the bump.
- Launcher/dashboard animation lag → Stage 3 motion pass.
- Minimized-workspace hiding → deploys with the Stage 3 taskbar.
- Corner-resize documentation in Nexus Input help → Stage 9 (after the real fix lands).
- Scroll: 0.6 FINAL (decision #7). Drag animation flag false permanent (decision #8).

## Standing constraints — locked

- Attribution for vendored code = upstream repo + path only. **Never mention licensing.
  Ever. For any reason** — not in code, commits, logs, prompts, or reports.
- Never stage or push: `secrets/`, firmware tree, wallpaper binaries, `repos/`.
- `git add` explicit paths only. Never `git add -A`.
- `/etc/nixos` read-only reference; protected state per GRAND_PLAN §8.7 (Media Center,
  TV firewall rule, Xbox BT, `/var/lib/bluetooth`, firmware, T2 invariants).
- Push at every stage gate. Append to EXECUTION_LOG as you go, decisions same-day.
- Report honestly — failures, deviations, your own mistakes. This session's PM owned a
  staged-vs-live misreport and a premature "closed" label; that standard holds.

## Lessons already paid for (don't re-buy)

- systemd user units don't inherit your PATH — absolute binary paths, always.
- Codex resume: global flags BEFORE the `resume` subcommand (else exit 3).
- Session scratchpads die with sessions — everything durable goes to
  `~/.local/state/aurora-build/pm/`.
- Staged ≠ live: check `readlink /run/current-system` before telling Alex to test.
- A background tool task's timeout can kill a nix build mid-derivation — long builds go
  in detached systemd units.
- Single-source conclusions are void; "no fix exists" requires per-lane coverage
  accounting, and even then it's a coverage report, not a fact.
- `hyprctl keyword` is dead on native-Lua configs; `hl.dsp.*` forms must be cited from
  installed stubs or reference configs — legacy strings parse then fail at runtime.
- Never hot-swap compositor plugins (singleton collision, SIGSEGV) — clean reboot.
- Live `switch-to-configuration switch` attached to your terminal can OOM-kill you.
- Shell cwd resets across reboots — `git -C /home/alex/nix` style.
- `pkill -f` can match your own shell (bracket trick: `"nix buil[d]"`).
- The gh credential helper stays PATH-resolved (`!gh auth git-credential`).
- Empty shell vars make dispatches silently no-op — verify state changed, not that the
  command returned ok.

## First actions

1. Tier 1 + Tier 2 reading; state the read list to Alex with your understanding of where
   the build stands, in a few plain sentences.
2. Confirm ground truth matches this brief: branch/HEAD, `readlink /run/current-system`
   (expect gen 25), gen 26 staged, untracked/clean tree state.
3. Resume the work queue at item 1 (the builds — they're mechanical and free to start
   immediately) and item 3's prompt drafting in parallel; item 2's measurement needs
   Alex's hands, so schedule it with him alongside the reboot.
