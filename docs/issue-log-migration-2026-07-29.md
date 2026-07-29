# ISSUE_LOG.md migration — 2026-07-29

**Purpose.** `ISSUE_LOG.md` (Phase A audit, 2026-07-16 + Stage 0/1 additions through
2026-07-21) is a dated audit of the retired Waybar/Rofi-era system. It states its own
findings were observations, not fixes. It has been archived intact at
`archive/superseded-docs/2026-07-29/ISSUE_LOG.md` and removed from the mandatory
active read list (`PM_OPERATING_RULES.md` §5 already reflects this).

**Method.** Every item in the 1061-line file was read and checked against, in order:
`STAGE2_CLOSEOUT_WORK_ORDER.md`, `GRAND_PLAN.md` (including its §15 "Bug Log
Traceability" and §14 "No-Session List Accounting"), `EXECUTION_LOG.md` (full
Stage 0/1/2 history including the 2026-07-29 Stage 2 runtime-gate failure on
generation 31), `MASTER_REQUIREMENTS.md` §5's own bug log, `CURRENT_STATE_AUDIT.md`
(current, gen-31 edition), and read-only checks against the live machine
(`hyprctl`, `libinput list-devices`, `udevadm info`, `systemctl`, `uptime`) and the
repo source (`rules.lua`, `keybinds.lua`, `kitty.conf`, `Weather.qml`, `desktop.nix`,
`desktop-apps.nix`) where the documents alone didn't settle it.

**This file exists to prevent one specific failure mode:** a still-unresolved
defect silently disappearing because the document that recorded it was archived.
The list below is every item from `ISSUE_LOG.md` that this research could **not**
find a current owner (stage, deliverable, or completed fix) for. Everything else —
resolved items and items already assigned to a stage/deliverable — is documented in
the full triage table returned to the PM directly (not duplicated here to avoid a
second stale copy; see `EXECUTION_LOG.md` and `GRAND_PLAN.md` §15 for those).

---

## STILL OPEN AND UNOWNED — needs a home

### 1. EasyEffects is still a visible, floating application

**ISSUE_LOG §11.** Two claims, both still true on disk today:

- `modules/home/hyprland/hyprland/rules.lua:20-33` still gives
  `com.github.wwmm.easyeffects` a `float = true, center = true, size = 72%` window
  rule — i.e. the compositor still treats it as a real, user-facing window, not
  invisible backend infrastructure.
- No mechanism hides it from the launcher by default. `GlobalConfig.launcher.hiddenApps`
  exists as a user-toggleable list (`modules/home/aurora-shell/modules/nexus/pages/apps/AppInfo.qml:17,100-103`)
  but nothing in the Nix seed (`modules/home/aurora-shell/nix/hm-module.nix` — the
  `shellSeed` only sets `general.idle.timeouts`) pre-populates EasyEffects into it.

`GRAND_PLAN.md` §5.9 states the design intent ("EasyEffects remains invisible") but
no stage, deliverable, or `EXECUTION_LOG.md` entry claims the concrete fix (remove
the float rule; default-hide the launcher entry). Not part of Stage 2's scope, not
named in Stage 3/4's surface lists either.

**Evidence:** `modules/home/hyprland/hyprland/rules.lua:20-33` (rule verified present
by direct read, 2026-07-29); no `NoDisplay`/hidden-apps default found anywhere in
`modules/`.

### 2. Kitty: `Ctrl+T` still does not open a new tab

**ISSUE_LOG §14.** `modules/home/kitty/kitty.conf:74-82` binds `ctrl+shift+t` →
`new_tab_with_cwd` and several other combinations, but plain `ctrl+t` is unbound.
`MASTER_REQUIREMENTS.md` §5 ("Capture & keys") still lists this as a live requirement
("Kitty: Ctrl+T opens new tab; Ctrl+Shift+T reopens last closed tab"), so it isn't at
risk of being lost from the requirements ledger — but no stage/deliverable in
`GRAND_PLAN.md` or `STAGE2_CLOSEOUT_WORK_ORDER.md` claims the one-line remap. It is a
trivial fix that is easy to drop precisely because it's trivial.

**Evidence:** `modules/home/kitty/kitty.conf:74-82` (read directly, 2026-07-29).

### 3. Kitty "reopen last closed tab" — the plan answers a different request; confirm with Alex

**ISSUE_LOG §14** flagged that Kitty has no native undo-close-tab and any fix would
be a partial custom kitten at best. `GRAND_PLAN.md` §7.4 later addresses an
"ex-Ctrl+Shift+T" intent, but as **editor** file-reopen via recents + fzf history —
not Kitty tab-reopening. This may be a deliberate, reasonable reinterpretation, but
nothing records that Alex accepted the substitution, and `PM_OPERATING_RULES.md`
explicitly forbids narrowing an intended feature to silence a bug without saying so.
Flagging so the PM states the substitution to Alex rather than letting the original
ask quietly become the editor feature.

**Evidence:** `GRAND_PLAN.md` §7.4 (read 2026-07-29); no operator decision in
`EXECUTION_LOG.md` addresses the substitution.

### 4. Corrected Kitty-SIGUSR1 diagnosis is not carried forward

**ISSUE_LOG §14** documented a correction: the "never send Kitty SIGUSR1" rule
(recorded in `EXECUTION_LOG.md`) is very likely a misdiagnosis — SIGUSR1 is
reload-config in Kitty 0.47.4's own source, and the real risk is a broad
`pkill -USR1 kitty`-style signal reaching `kitten __watch_conf__`/`__atexit__` helper
processes that don't handle it and die, which presents as "kitty terminated."
`EXECUTION_LOG.md:130` and `:416` (line numbers as of the 2026-07-29 revision;
content unchanged since 2026-07-16) still state the blanket rule with no nuance.
Not a functional bug — nothing asks anyone to send the signal — but a corrected
finding that will be fully lost once `ISSUE_LOG.md` is off the read list, since no
other current document carries the nuance (remote-control-based recolor,
GRAND_PLAN §5.9a-adjacent, is the safer mechanism already favored elsewhere).

**Evidence:** `EXECUTION_LOG.md:130,416` (grepped 2026-07-29); no other document
restates the correction.

### 5. Notification click closes the toast instead of expanding to details

**ISSUE_LOG §26.** Clicking a persistent/critical toast dismisses it; the requested
behavior is expand-to-details with an explicit close (X). No reference to this
specific interaction exists in `GRAND_PLAN.md` §5.6 (Notifications), `STAGE2_CLOSEOUT_WORK_ORDER.md`,
or `EXECUTION_LOG.md`. Not assigned to any stage.

**Evidence:** searched `GRAND_PLAN.md`, `STAGE2_CLOSEOUT_WORK_ORDER.md`,
`EXECUTION_LOG.md`, `CURRENT_STATE_AUDIT.md` for "expand-to-detail", "swipe-dismiss"
context, and the toast-click behavior — no hits addressing this specific bug.

### 6. Session menu / OSD buttons have no hover tooltips

**ISSUE_LOG §26.** No reference anywhere in the current document set (searched for
"tooltip" across `GRAND_PLAN.md`, `STAGE2_CLOSEOUT_WORK_ORDER.md`, `EXECUTION_LOG.md`,
`CURRENT_STATE_AUDIT.md`, `MASTER_REQUIREMENTS.md` — zero hits). Not assigned to any
stage.

### 7. Calendar click does nothing

**ISSUE_LOG §26.** The calendar *surface* is architecturally owned by the top bar
(Stage 3, `GRAND_PLAN.md` §5.1/§5.2), but this specific interaction defect (clicking
the calendar produces no response) is not named as a to-do anywhere in the Stage 3
scope notes available in the main tree (Stage 3 is progressing in an isolated
worktree, `/home/alex/aurora-stage3` on `stage3/topbar`, per `CURRENT_STATE_AUDIT.md`
§1 — not inspected here since it is out of this task's scope and not yet merged).
Flagging so it's an explicit checklist item when Stage 3 lands, not an assumption
that "Stage 3 owns calendar" automatically covers it.

---

## Items that are owned but worth flagging to the PM (not unowned, but easy to lose)

These already have a stage/deliverable home, so they are **not** in the unowned list
above, but each has a subtlety worth restating so it doesn't get silently marked
"done" because the general area has an owner:

- **Weather → Austin (ISSUE_LOG §9).** `GRAND_PLAN.md` traces this to §5.1/§5.2
  (Stage 3). The old hardcoded-Chicago files it named no longer exist (the whole
  `modules/home/quickshell/` tree was deleted). The **replacement** service
  (`modules/home/aurora-shell/services/Weather.qml`) reads
  `GlobalConfig.services.weatherLocation`, which is **empty** in every Nix-owned
  config today and falls back to IP geolocation (`ipinfo.io`) — not a pinned Austin
  lat/lon. `MASTER_REQUIREMENTS.md` §5 still lists this as an open bug-log line.
  When Stage 3 lands, confirm `weatherLocation` is actually set, not just that the
  IP-geolocation fallback happens to guess correctly.
- **CPU/Memory buttons opening the same window (ISSUE_LOG §10).** Owned by Stage 3
  (`GRAND_PLAN.md` §15: "CPU/RAM distinction→§5.1") and by the final destination in
  §5.18 (dedicated sysmon workspace). The old Waybar bindings that caused it are
  moot (Waybar is retired), but the distinct-destinations requirement itself isn't
  built yet — Stage 3 hasn't merged.
- **Screenshot lifecycle (ISSUE_LOG §8, superseded by Stage 2 deliverable D).** The
  original pink-film root cause is fixed and proven (`slurp`'s overlay compositing
  into the frame — measured, not assumed; see `EXECUTION_LOG.md` findings 19a-19c).
  But the Stage 2 gen-31 runtime gate (2026-07-29) found the *lifecycle* still
  broken: capture leaves the prior window unable to receive typing until re-clicked,
  floating-window bounds are inconsistent, and the screenshot utility is a dead icon
  in the app rail. A toolbar fix is **written** (`modules/areapicker/Toolbar.qml`,
  `AreaPicker.qml`, `Picker.qml`, `services/Screenshotter.qml`) but not yet built or
  tested (`CURRENT_STATE_AUDIT.md` §7). Don't let "color fidelity fixed" read as
  "screenshot bug fixed."
- **T2 RTC boot-clock skew (ISSUE_LOG §28).** Confirmed still live on this machine
  right now (`uptime` reports "up 20659 days" as of this session). Nominally a
  Stage 7 boot-chain item, but a concrete fix citing ISSUE_LOG §28 by name is
  **already written** in `modules/nixos/base.nix` (enables `time-sync.target` /
  `systemd-time-wait-sync.service`, capped at 60s) as part of the current Stage 2
  correction batch — not yet built or tested. This item is more "in flight right
  now" than "deferred to Stage 7," and the base.nix comment referencing
  `ISSUE_LOG §28` by name will become a dangling reference once the file is
  archived; the archive path (`archive/superseded-docs/2026-07-29/ISSUE_LOG.md`)
  keeps the citation resolvable.
- **Corner resize, tiled case (ISSUE_LOG §16 "border resize only expands").**
  Stage 2 deliverable C. The gen-31 runtime gate (2026-07-29) found floating corner
  resize passes but tiled corner resize still only moves one axis. A third
  compositor patch (`hyprland-dwindle-resize-workarea.patch`) was written the same
  day specifically to fix this, changing the Hyprland/Hyprbars patch set — not yet
  built (would require the hour-class compositor rebuild).
- **libadwaita never enters dark mode (ISSUE_LOG §15a).** Owned by Stage 4's GTK
  consumer mapping (`GRAND_PLAN.md` §4, "GTK3+GTK4/libadwaita | iNiR writers").
  `gtk-application-prefer-dark-theme=1` is set (`modules/home/desktop-apps.nix:22-23`)
  but the actual root cause — no `color-scheme` dconf key under
  `org/gnome/desktop/interface` — is still unset anywhere in the tree
  (`programs.dconf.enable = true` only). Confirm Stage 4 writes the dconf key, not
  just the (already-present, already-ineffective) GTK3/4 preference.

---

## Not carried forward as an issue (historical/moot)

- **ISSUE_LOG §0** ("the handoff report is out of date, generation 10 booted") is a
  2026-07-16 staleness note about a machine state 20+ generations behind the current
  one (generation 31 as of this session). No action needed.

---

## PM disposition of the seven unowned items (2026-07-29)

Recorded by the PM at migration time so **no item leaves this file without a
named owner**. These are *proposed* owners, confirmed at the owning stage's gate —
not silent deferrals, and not closures. None of them enters the Stage 2 correction
closure (work order §5 forbids absorbing unrelated fixes found en route).

| # | Item | Proposed owner | Why that stage |
|---|---|---|---|
| 1 | EasyEffects is a visible/floating window with no launcher-hide default (`rules.lua:20-33`) | **Stage 3** | `GRAND_PLAN.md` §5.9 already states "EasyEffects remains invisible" and §8.2 lists it as an *invisible EQ backend*. The float rule is drift **against** the plan, and Stage 3 owns the media/EQ surface that replaces its UI. Also needs the desktop-entry `NoDisplay` half. |
| 2 | Kitty `Ctrl+T` does not open a new tab (`kitty.conf:74-82`) | **Stage 8** | Stage 8 owns the dev workspace and terminal. Note `MASTER_REQUIREMENTS.md` §11 protects only Kitty `Ctrl+C/V`, so this is an addition, not a regression. |
| 3 | Kitty "reopen last closed tab" | **Alex's decision — see below** | Not assignable without his word. |
| 4 | Kitty SIGUSR1 diagnosis not carried into `EXECUTION_LOG.md` | **Closed by this pass** | Correction note appended to `EXECUTION_LOG.md`. |
| 5 | Notification click closes the toast instead of expanding to detail | **Stage 9** | `GRAND_PLAN.md` §5.6 carries the notification surface; Stage 9 owns the Notifications page (per-app rules, DND, semantic filter). Expand-vs-dismiss is that surface's behaviour contract. |
| 6 | Session menu / OSD buttons have no hover tooltips | **Stage 3** | Stage 3 owns the top composition and its independent expansions, where these controls live. |
| 7 | Calendar click does nothing | **Stage 3** | `GRAND_PLAN.md` §5.2 places calendar event data in the top calendar expansion, which Stage 3 builds. |

### The one item that needs Alex, not a stage

**Item 3 — Kitty "reopen last closed tab."** `ISSUE_LOG.md` recorded this as a
terminal-tab request. `GRAND_PLAN.md` §7.4 answers a *different* request — editor
file-reopen in the dev workspace. Treating the plan as satisfying the original ask
would be a silent substitution, which governance rule 3 forbids. **Question for
Alex:** did you want terminal tab restore, editor file restore, or both? Until he
answers, this stays open and unowned rather than being quietly folded into §7.4.

### Items 1 and 5 carry a standing hazard

Both describe a surface behaving differently from the plan. Per `PM_OPERATING_RULES.md`
§2, neither may be "fixed" by removing the surface — the EasyEffects window and the
notification toast both stay until their replacements are live in the same closure.
