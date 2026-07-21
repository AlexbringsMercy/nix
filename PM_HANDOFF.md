# The Aurora Build — PM Handoff Brief

The design phase of this project ended when `GRAND_PLAN.md` was written; execution began
immediately after and is now mid-flight. The previous project manager session ran the build
through Stage 0 and two-thirds of Stage 1 before hitting its usage limit, and wrote this
brief so that you inherit its exact operating state — role, machinery, policies, lessons,
and resume point. When it's read, you are the PM, and the build continues without a seam.

Written 2026-07-21. Where this file and `EXECUTION_LOG.md` disagree, trust the log.

## Who you are

You are the **project manager and verifier** of a complete operating system build — not
the designer (that work is done and locked in `GRAND_PLAN.md`), and not the executor
(that work is delegated). You are the brains that keeps everyone honest. Alex's words,
binding: the PM model is expensive and "best used as the project manager and brains to
verify everyones work does/is what they say. if its simple, delegate it for sure."

The execution model, exactly as Alex set it:

- **You write specific execution prompts** — exact files, patches, configs, test criteria.
  **Codex sessions do the terminal/file work.** You launch, monitor, and steer Codex
  directly (it is your de facto subagent; Alex never ferries anything between you).
- **You verify everything** before it counts: diff scope, claimed-vs-actual, build results.
  Execution agents are competent but literal, and this project has been burned by agents
  who invented instead of adapting. Verification has already caught one real bug
  (a flake dynamic-attrs error Codex introduced in 1A). Assume nothing.
- **You commit, build, and push.** Codex physically cannot commit — its sandbox mounts
  `.git` read-only. This division is permanent: Codex edits, PM commits.
- **Alex gate-tests** from compressed checklists you prepare ("open this, click this,
  yes/no"). Mechanical gates (0, 2, 6) are quick checklists, batched. Visual gates
  (1, 4, 7) are sit-down sessions — he needs to see and feel it. Gate 0 has passed;
  Stage 1's visual gate is the next one, and it needs him present.
- **Big stages (1, 3, 7) split across multiple Codex sessions.** Stage 1 is running as
  1A (done), 1B (done), 1C (next).
- **Subagent tiers** (Alex, binding): **never haiku — def dont use haiku.** Sonnet for
  light tasks. Opus for medium and up, reasoning effort high minimum where the interface
  allows. Codex for file execution whenever the work is well-specified.
- **Every Codex session and every subagent reads `/home/alex/nix/SESSION_PREAMBLE.md`
  first.** No exceptions — that file exists because five consecutive sessions once got a
  load-bearing claim wrong by grepping instead of reading.

Work autonomously between gates. Come to Alex only for decisions, sudo outside the harness
scope, reboots needing his presence, and gate checks.

## What you're managing

The execution of `~/nix/GRAND_PLAN.md` — the complete NixOS + Hyprland "Aurora" desktop —
on Alex's 2020 MacBook Air: T2, Intel i3 dual-core, 8GB RAM, 121GB partition. The hardware
constraint is real and shapes operations: `--max-jobs 2 --cores 2` on builds, memory caps
on Codex, bulk file operations scripted rather than looped through tools. An OOM has
already killed a PM terminal mid-activation once; the policies below exist because of it.

The flake at `~/nix` is the sole configuration authority (Stage 0 reconciled and retired
the channel lineage). Deploys go through a machine-local wrapper flake at
`~/.config/nixos-local/` that injects Apple firmware from `/etc/nixos/firmware/brcm`.

## Authority order

1. **`SESSION_PREAMBLE.md` rules and GRAND_PLAN locked decisions** — not yours to relitigate.
   You are not the designer; if execution reveals a genuine flaw in the plan, log it, flag
   it to Alex, and let him decide. Deviations you do make on execution grounds (the PM has
   made one: snapshot-vendor instead of history graft, because audited bytes win) get
   recorded explicitly in `EXECUTION_LOG.md` and `SOURCES.md`.
2. **`EXECUTION_LOG.md`** — the record of what physically happened. Beats this file and
   beats memory.
3. **`GRAND_PLAN.md`** — the design authority for everything not yet built.
4. **Ground truth** — the repo, the git history, the running machine. A verified read
   beats every second-hand claim, including the ones in this brief.

## Files to read

### Tier 1 — read fully, in this order, before acting

- **`SESSION_PREAMBLE.md`** — binds you and everyone you spawn. The failure case study it
  opens with is the reason this project's verification culture exists.
- **This file** — you're in it.
- **`GRAND_PLAN.md`** — the source of truth you are executing. Read it whole once; every
  verification you ever do is against this document. Note §2.1 (fork manifest), §3.1
  (palette ladder), §8.7 (protected state), §9–10 (stage sequence and gates).
- **`EXECUTION_LOG.md`** — Stage 0 close-out, the house deploy procedure with exact
  commands, incident reports, Stage 1A/1B close-outs, and the NEXT pointer.
- **`ISSUE_LOG.md`** — known issues; §19 (start-hyprland warning) is root-caused and stands.

### Tier 2 — read fully before your first Codex launch

- **`SOURCES.md`** — the vendored-components ledger; aurora-shell row + provenance note.
- **`codex-prompts/stage1a-vendor-chassis.md`** and **`codex-prompts/stage1b-aurora-scheme.md`**
  — the house prompt style. Match it for 1C: mandatory preamble read, scope IN/OUT, hard
  rules, tasks, raw-data report format.
- **`modules/nixos/build-harness.nix`** — the scoped passwordless sudo you inherit.
- **`scripts/aurora-resume-agent`** and the `aurora-resume-agent` line in
  `modules/home/hyprland/hyprland/autostart.lua` — the reboot-resume loop.
- **`~/.config/nixos-local/flake.nix`** — the machine-local wrapper (NOT in this repo).
  Read the comment explaining why its input is `git+file://` and never `path:`.

### Tier 3 — when you start 1C work

- **`modules/home/aurora-shell/nix/hm-module.nix`** — the upstream HM module you'll have
  Codex adapt into `programs.aurora-shell`.
- **`modules/home/aurora-shell/services/Colours.qml`** — the 1B palette work and the
  `scheme.json` watch chain (the source of the caveat below).
- **`modules/home/{waybar,rofi,wallpaper,quickshell}`** — the trees 1C retires. Live
  desktop: untouchable by Codex until the cutover is actually deployed at the gate.
- **`modules/home/theming/default.nix`** — keeper wirings that must be carried before
  retirement: equalizer-state backend, weather cache pattern.
- **`repos/`** — read-only reference clones, gitignored. Never staged, never modified.

## The machinery you inherit

**Build harness** (BUILD-PERIOD SCAFFOLDING — removed Stage 10; the §7.5 sudo toggle
supersedes daily use at Stage 8). Scoped NOPASSWD sudo for exactly: `nix-env`, the
canonical `/nix/var/nix/profiles/system/bin/switch-to-configuration`, `systemctl reboot`,
`reboot`, `systemctl poweroff`, `nix-collect-garbage`. Everything else prompts.

**Armed resume loop** — how you survive reboots. Create the flag file
`~/.local/state/aurora-build/resume-armed`, reboot; autostart runs `aurora-resume-agent`,
which consumes the flag and opens kitty running `claude --continue` in `$HOME`. That
resumes the most recent conversation — after handoff, that's you. Un-armed boots do nothing.

**Deploy procedure** (exact commands in `EXECUTION_LOG.md`): refresh the wrapper-flake
lock first (`nix flake update --flake /home/alex/.config/nixos-local` — it pins a git rev
of `~/nix`, so every deploy after new commits needs this), `nix build` the toplevel via
`path:/home/alex/.config/nixos-local`, `sudo nix-env --profile /nix/var/nix/profiles/system
--set`, then `switch-to-configuration boot`. The console line "Not checking switch
inhibitors (action = boot)" is benign informational output.

**Activation safety — POLICY, paid for with an OOM incident**: never run a live
`switch-to-configuration switch` attached to your own terminal. Either fully detach
(`setsid bash -c '… > log 2>&1' &`) or go boot-only + armed-resume reboot for anything
that touches the session.

**The Codex pipeline** (proven across two sessions). codex-cli 0.144.4 at
`/home/alex/.npm-global/bin/codex`. Launch recipe:

```
systemd-run --user --unit=codex-stageXX \
  -p WorkingDirectory=/home/alex/nix -p MemoryHigh=3G -p MemoryMax=4G -p CPUWeight=30 \
  /run/current-system/sw/bin/bash -lc \
  '/home/alex/.npm-global/bin/codex exec --cd /home/alex/nix --sandbox workspace-write --json \
   --output-last-message <scratchpad>/stageXX-final.md "$(cat /home/alex/nix/codex-prompts/stageXX-*.md)" \
   > <scratchpad>/stageXX-events.jsonl 2>&1'
```

`<scratchpad>` is your session's scratchpad directory. Watch with a background poller on
`systemctl --user is-active --quiet codex-stageXX`. The working directory is set redundantly
because omitting it cost the previous PM three failed launches ("Not inside a trusted
directory"). The event stream carries a thread ID; `codex exec resume <id>` steers a
session mid-flight.

## Current state — the exact resume point

- **Done and pushed**: Stage 0 (gate PASSED), Stage 1A, Stage 1B. HEAD `3044e5e` on
  branch `codex/macbook-desktop`, remote `github.com/AlexbringsMercy/nix`, tree clean.
- **Builds green**: `nix build /home/alex/nix#aurora-shell` →
  `/nix/store/46jqdy8svnx719hw1ybcz5db40nggbfs-caelestia-shell-1.0.0`.
- **Generations**: 17 current, 16 booted-verified, 15 = last channel-lineage build kept as
  rollback anchor until Stage 10. Gens 1–7 deleted and GC'd.
- **NEXT: Stage 1C — the cutover Codex session.** Scope: adapt
  `modules/home/aurora-shell/nix/hm-module.nix` into `programs.aurora-shell` (rename per
  §2.1), supervised systemd user service, retire `modules/home/{waybar,rofi,wallpaper,quickshell}`
  with keepers carried first (equalizer-state backend, weather cache pattern,
  dunst/aurora-notification-fallback), **seed a clean aurora `scheme.json`**, IPC/keybind
  smoke. Codex does the file work now; activation and the Stage 1 visual gate wait for
  Alex (glass A/B evening, VA-API check, plus the Stage 0 leftovers: TV-from-couch
  reachability, Xbox controller pairing).
- **The 1B caveat that makes the seed load-bearing**: the aurora palette pinned in
  `services/Colours.qml` is only the *fallback* — any pre-existing
  `${XDG_STATE_HOME}/caelestia/scheme.json` overrides it, and the caelestia CLI's own
  default scheme is Catppuccin Mocha. Without the seed, first light is stock, not aurora.

## Standing constraints — locked, enforce on yourself and everyone you spawn

- Attribution for vendored code = upstream repo + path only. **Never mention licensing.
  Ever. For any reason** — not in code, commits, logs, prompts, or reports.
- Never stage or push: `secrets/`, the firmware tree, wallpaper binaries, `repos/`.
- `git add` explicit paths only. Never `git add -A` at repo root.
- `/etc/nixos` is read-only reference; its `firmware/` dir is load-bearing for the wrapper.
- Protected state per GRAND_PLAN §8.7: Media Center stack, TV firewall rule, Xbox BT
  tuning, `/var/lib/bluetooth`, firmware, T2 invariants.
- Push at every stage gate. Append close-outs to `EXECUTION_LOG.md` as you go.
- Report honestly — failures, deviations, and your own mistakes included. The previous PM
  confessed a triple-botched Codex launch; that standard holds.

## Lessons already paid for (don't re-buy them)

- Shell cwd resets across reboots — `git -C /home/alex/nix` style, always.
- `pkill -f` patterns can match your own shell and kill you (exit 144). Bracket trick:
  `"nix buil[d]"`.
- The gh credential helper must stay PATH-resolved (`!gh auth git-credential`) — a store
  path written by an ephemeral `nix shell` got GC'd and broke pushes once.
- The wrapper flake's `path:` fetcher would copy the whole worktree including 11GB of
  `repos/` into the store. It is `git+file://` for a reason; it ships committed tree only.
- Live switches attached to your terminal can die at exit 137 and take you with them.

## What NOT to do

- **Don't redesign.** GRAND_PLAN stands. Execution-forced deviations get logged and flagged,
  not silently absorbed.
- **Don't execute what you should delegate.** Well-specified file work goes to Codex;
  light verification sweeps go to sonnet subagents. You verify and integrate.
- **Don't trust reports without checking.** Diff the actual tree against the claimed scope
  every time.
- **Don't spawn haiku. Don't skip the preamble read for any spawn.**
- **Don't touch protected state, live desktop trees (until the 1C gate deploy), or
  anything in the never-push list.**

## First actions

1. Complete the Tier 1 + Tier 2 reading.
2. Confirm repo state matches this brief; tell Alex your understanding of where the build
   stands and your 1C plan in a few sentences.
3. Draft `codex-prompts/stage1c-cutover.md` in the house style, launch it through the
   pipeline, verify, commit, build, push.
4. Schedule the activation + Stage 1 visual gate for when Alex is at the machine.

Open items awaited from Alex (non-blocking): Erdtree ASCII art (the Night's Edge piece is
done at `~/Downloads/nightsedge.ansi`, ships raw via fastfetch file-raw at the fetch-pane
stage), backup destination, headphone model names, calendar ICS URL. Deferred by decision:
KDE Connect. Sequenced later: M11 generator-clamp half lands Stage 4 with the CLI;
light-mode code removal is a recorded later cleanup; harness removal at Stage 10.
