# Stage 3 prep — top taskbar compose map (PROPOSAL ONLY, no edits)

## Read first

1. `/home/alex/nix/SESSION_PREAMBLE.md` — binds you, always.
2. `docs/plans/GRAND_PLAN.md` §5.1–5.2 (the two bars + popouts/expanded tier), §3.3
   (motion vocabulary), §6.2 (minimized-task behavior), and the M1–M4 + M17
   rows in the §9 table.
3. The aurora-shell tree: `modules/home/aurora-shell/` (components, services,
   modules — especially `modules/bar/`, `modules/windowinfo/`, config plumbing).

## Scope

PROPOSAL ONLY. No file edits, no commits, no live commands against the running
shell or compositor. Deliver a report. A heavy nix build is running on this
machine — do not start builds or other CPU-heavy local work.

## The task

Stage 3 builds the persistent horizontal top taskbar (new module inside
aurora-shell, plan calls it `modules/topbar/`) composed from vendored donors,
plus the expanded-tier panels. Produce the execution map the PM will turn into
implementation batches:

### 1. Component map (the core deliverable)

For EVERY element in §5.1's top-bar spec (left island: apps button + pinned;
center: workspace pills as DropAreas, running tasks with the iNiR behavior set,
active title + windowinfo popout re-anchor; right island: media chip, CPU/RAM
pills, network Mbps, battery, clock, bell, System button; scroll actions) and
§5.2's expanded tier (ilyamiro battery ring, liquid audio orb, radial BT
constellation, network radial gauge, FocusTime opt-in): identify

- the donor artifact: exact file paths (+ key line ranges) in
  `repos/ilyamiro-nixos-configuration`, `repos/inir`, `repos/dankmaterialshell`,
  or the aurora-shell tree itself;
- what aurora-shell service it must bind to: which existing services under
  `modules/home/aurora-shell/services/` already provide the data (Audio, Mpris?,
  system usage, network, battery, time, notifs, Hyprland window/workspace
  model) vs. what is missing and must be written (the plan says M4's
  MPRIS→desktop-entry resolver ~50 lines is new — spec its inputs/outputs);
- the adaptation delta: what changes between donor and target (theme tokens,
  service names, geometry), classed S/M/L.

Donor licensing is irrelevant to your report — never mention it. Attribution is
repo + path only.

### 2. Batch plan sized around rebuilds

The operator wants FEWER rebuild cycles. Group the work into implementation
batches where each batch is independently testable and lands in ONE home
rebuild. State what each batch depends on (services first? bar shell first?)
and what can be verified statically vs. needs the live shell.

### 3. Dev-loop verification (cycle-time attack — answer definitively)

Determine from the aurora-shell nix wiring (`nix/hm-module.nix`, `nix/default.nix`,
`flake.nix`, how the shell service launches, the `qs -c aurora-shell` IPC form in
`modules/home/fish.nix`) whether a SECOND QuickShell instance can run from the
working tree (`~/nix/modules/home/aurora-shell/`) for hot QML iteration while
the deployed shell keeps running — different config name/IPC id, no singleton
collision, no daemon conflict. QuickShell reloads QML on file change; confirm
what the pinned QuickShell supports (read its docs/source in the store if
present). Deliver the exact command line and any preconditions, or the exact
reason it cannot work. Do NOT run it — the PM will trial it at the gate. This
determines whether Stage 3 QML iteration happens per-save instead of
per-rebuild, so treat it as load-bearing.

### 4. Risks and unknowns

Anything §5.1 assumes that the donors/pinned versions do not actually provide
(e.g. DropArea/Drag across surfaces on the pinned QuickShell, ScreencopyView
re-anchor constraints, iNiR task-cycling assumptions about the Hyprland IPC
surface on 0.55.4 native-Lua). Cite what you read to conclude each.

## Report

Raw data, per the four sections. Read accounting per preamble rule 5: what you
read fully, what you sampled, what you did not cover.
