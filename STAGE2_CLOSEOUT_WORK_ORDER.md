# STAGE 2 CLOSE-OUT — WORK ORDER

**Status: `STAGE 2 — OPEN`.**

The exact implementation brief for the incoming PM. Written 2026-07-28 against
confirmed ground truth: branch `codex/macbook-desktop`, HEAD `6486742`, clean
tree, 0 ahead / 0 behind upstream; `/run/current-system`, `/run/booted-system` and
`/nix/var/nix/profiles/system` all resolve to **generation 26**. **Revised
2026-07-29** to bring Stage 2 scope into line with the corrected `GRAND_PLAN.md`
architecture (top/left bar split, wallpaper-derived palette, rejected
`special:min-*` minimize backend, deterministic two-pane snap, `follow_mouse = 2`,
retired dashboard UI). Per `GRAND_PLAN.md` §10 batch rule: **generation 27 from
the 2026-07-29 session is a valid compile/staging milestone but not the final
Stage 2 candidate**, because it predates the approved snap/minimize/rail/focus
decisions recorded in `GRAND_PLAN.md` §10.2.

Authority: `CURRENT_STATE_AUDIT.md` for state, `GRAND_PLAN.md` for design,
`EXECUTION_LOG.md` (2026-07-28 operator decisions, plus the 2026-07-29 §10.2
architecture decisions) for the governance that binds this order,
`PM_OPERATING_RULES.md` for how to work.

---

## 1. Current truth

- **Stage 0** carries two physical-check debts: **TV reachability** and **Xbox
  controller pairing**. Both were deferred at the Stage 0 gate and then never run.
  Inference-backed, not test-backed.
- **Stage 1** is accepted, **with the glass A/B deferral to Stage 4 now explicitly
  approved** (decision 16). The current glass appearance is *not* accepted.
- **Stage 2 is not closed.** Conditional pass only.
- **Generation 26 is active and is the default boot generation.** Generation 27
  (2026-07-29 compile/staging session) exists as a valid staging milestone but is
  not itself a Stage 2 candidate — see the revision note above.
- **The naive half-snap is active but does not implement the deterministic
  model.** Verified on disk at `modules/home/hyprland/hyprland/keybinds.lua:61-135`
  (`snap_geometry`/`half_snap`): `Super+Left`/`Super+Right` float, exact-resize,
  and exact-move the active window to a computed half, and a second press on an
  already-snapped half toggles it back into the dwindle tree. It does **not**
  minimize a prior occupant on an occupied-side snap, does **not** minimize
  surplus same-workspace windows on pair completion, and has no pair-dissolution
  logic beyond the single second-press toggle. This is the Stage 2 starting point
  for deliverable G below, not the finished behavior.
- **The current minimize backend is the model `GRAND_PLAN.md` §6.2 rejects.**
  Verified on disk: `modules/home/hyprland/hyprland/general.lua` sets
  `close_special_on_empty = true` ("remove each per-window minimize workspace
  after restore"); `modules/home/hyprland/hyprbars.lua.in:51` and
  `modules/home/hyprland/default.nix:24,33` wire a `window-minimize` script
  (`modules/home/scripts/window-minimize`, "the vendored omarchy script") that
  minimizes into per-window `special:` workspaces; `keybinds.lua:32,50` bind
  `Super+Down` to minimize and `Super+Alt+M` to a LIFO "restore last minimized."
  This is exactly the `special:min-*` backend now rejected as final
  (`GRAND_PLAN.md` §6.2, §10.2 item 5) — it is the Stage 2 deliverable F
  starting point, not something to delete before its replacement exists.
- **`follow_mouse` is currently `0`, not `2`.**
  `modules/home/hyprland/hyprland/input.lua:6` sets `follow_mouse = 0` ("require
  a click so pointer travel cannot retarget window actions"). `focus_on_close = 2`
  is already set (`input.lua:7`) and `misc:focus_on_activate = true` is already
  set (`general.lua:93`) — only the `follow_mouse` value itself needs to change
  for deliverable E.
- **No left-rail application surface exists yet.** No rail/dock module exists in
  `modules/home/`. Building the minimum final slice (deliverable H) starts from
  nothing, not from a partial implementation.
- **`Super+K` still binds to `caelestia:dashboard`**
  (`keybinds.lua:16`, "retain caelestia's upstream panels chord for the dashboard
  surface") — the now-retired dashboard surface (`GRAND_PLAN.md` §5.4, §10.2 item
  14). Removing this bind is **not** Stage 2 scope (see Exclusions, §5) but is
  flagged here as known drift for whichever stage takes it up.
- **DWT does not exist on the touchpad** because udev classifies it
  `ID_INPUT_TOUCHPAD_INTEGRATION=external`; libinput reports
  `Disable-w-typing: n/a`.
- **Corner resize has no implementation** — no patch, no research artifact, no
  prompt. Non-negotiable by decision #11.
- **Stage 3 has not started.** No `topbar`/`taskbar` module exists. The top
  widget bar is explicitly out of the Stage 2 closure (§5).

---

## 2. Core Stage 2 deliverables

### A. Drag-anchor patch — build it

- **Build the existing patch.** No new code: `modules/nixos/patches/hyprland-drag-anchor.patch`
  and the `hyprlandOverlay` in `flake.nix` are committed and PM-verified (applies
  with zero fuzz against the pinned blob; overlay live in real eval).
- **Build both evaluation paths** —
  `path:/home/alex/nix#homeConfigurations.alex.activationPackage` and
  `…#nixosConfigurations.macbook.config.system.build.toplevel`.
- **Hyprland and Hyprbars must rebuild against the same compositor derivation.**
  The plugin helper consumes top-level `hyprland`, so building the patch changes
  `pkgs.hyprland` and hyprbars rebuilds in the same closure. They cannot be
  deployed separately without ABI drift.
- **No live plugin hot-swap.** Ever.
- **Boot-only deployment**, then one clean reboot.

Run the compositor build in a detached `systemd-run --user` unit — a tool-managed
background task's timeout will kill the build mid-derivation and lose the compile.

### B. Disable while typing

- Add the fully specified udev hwdb entry via `services.udev.extraHwdb` in
  `modules/nixos/desktop.nix`:
  - match: `touchpad:usb:v05acp0280:*`
  - property: `ID_INPUT_TOUCHPAD_INTEGRATION=internal`
- **Lowercase VID/PID in the hwdb match** — hwdb matching requires it. Reference:
  systemd's stock `70-touchpad.hwdb`.
- **Objective acceptance:** `libinput list-devices` for `/dev/input/event7` changes
  from `Disable-w-typing: n/a` to `Disable-w-typing: enabled`. That is the
  pass/fail, not a subjective impression.
- Run the hands-on palm/thumb measurement with Alex when practical:
  `libinput measure touch-size /dev/input/event7`, with his hands resting on the
  trackpad as they naturally would. Tool is at
  `/nix/store/md7kljxi6ys3vbghgbliqcrp1x40mj1x-libinput-1.31.3-bin/bin/libinput`;
  `alex` is in the `input` group, so no sudo. Keyboard is `event2`, trackpad is
  `event7`.
- **The measurement does not block shipping the classification correction.** The
  hwdb entry alone flips DWT from absent to enabled. Record the measured
  thresholds and any resulting libinput quirk **separately**, as a second pass.

### C. Corner resize

- **Research the carried Hyprbars v0.55.0 source** (built via `overrideAttrs` in
  `modules/home/hyprland/default.nix`).
- **Investigate its top-decoration event handling against `resize_on_border`.** The
  known mechanism: hyprbars reserves the 30 px top bar
  (`bar_part_of_window = true`, `bar_precedence_over_border = true`) and consumes
  pointer events over it, shadowing the compositor's corner border-grab zones —
  which is why `extend_border_grab_area = 12` cannot reach through it.
- **Search community and upstream implementations and prior behaviour** before
  writing anything. Sourced fixes preferred; the hover patch is the precedent that
  extending this plugin in-house is tractable.
- **Extend the carried Hyprbars patch narrowly** — isolation constraints modelled
  on the drag prompt. Codex xhigh, house prompt style.
- **`Super+RMB` remains a redundant path, not the final solution.**
- **All four corners of a floating window must expand *and* shrink reliably.**
- **Do not close Stage 2 with only a fallback.** Decision #11 is explicit:
  *"I want corner resize... just like the drag its a non negotiable we dont just
  skip over."*

### D. Screenshot colour fidelity

**Observed facts:** region screenshots exhibit a uniform mauve/pink cast, **and so
do full-screen screenshots**. Therefore the selector overlay is **not** established
as the sole cause.

**Required diagnosis — in this order:**

1. Compare the saved PNG against the physical display.
2. Test region and full-screen **separately**.
3. Display a known-colour test image containing white, neutral grey, red, green,
   blue, and black.
4. Capture it through **both** paths.
5. **Sample the output pixels programmatically** — do not judge by eye.
6. Determine which of these is true:
   - the physical desktop itself is tinted;
   - the compositor / theme / a shader alters the render;
   - grim or a post-processing step alters pixels;
   - a colour profile or gamma step is involved;
   - an overlay remains in either capture path.
7. Inspect the active screenshot scripts **and** the Aurora `modules/areapicker/`
   implementation.
8. **Implement the final `GRAND_PLAN.md` §5.12 architecture now** — carried
   `modules/areapicker/` (live region / frozen region / straight-to-clipboard),
   bindings, clipboard + timestamped PNG output, System/bar entry.
9. **Do not retain a throwaway interim screenshot path** (MASTER §1.6).

**Do not assume a palette root cause. Do not assume an Areapicker-only root
cause.** Both assumptions are explicitly ruled out by decision 15 until evidence
says otherwise.

**Acceptance:**

- Full-screen screenshot matches the visible colours.
- Region screenshot matches the visible colours.
- No mauve film.
- No selection overlay baked into output.
- Region selection remains adjustable.
- Region output goes to **both** the clipboard **and** a timestamped PNG in
  `~/Pictures/Screenshots`.
- Full-screen output works from `Print`.
- A mouse-accessible System/bar path exists or is preserved, per the final
  architecture (MASTER §2 — hotkeys are never the only path).

**Scope fence:** this is a targeted screenshot correction, **not** permission to
perform a broad Stage 4 palette redesign. A minimal palette or render correction
that is genuinely required to restore screenshot fidelity is in scope; **any
broader visual-theme change must be logged and brought to Alex** before it lands.

### E. `follow_mouse = 2` — window model default *(added 2026-07-29)*

This is a small config change plus a gate row, not a research programme.

- Change `modules/home/hyprland/hyprland/input.lua`: `follow_mouse = 0` → `2`.
  Pointer interaction/scroll follows the window under the cursor; keyboard focus
  stays on the last clicked window; clicking transfers keyboard focus
  (`GRAND_PLAN.md` §6.2).
- `focus_on_close = 2` and `misc:focus_on_activate = true` are already set and
  need no change.
- No compositor patch, no new mechanism — one config value.

### F. Same-workspace minimize backend — final, non-`special:min-*` *(added 2026-07-29)*

- Replace the current per-window `special:` minimize workspaces
  (`close_special_on_empty`, the vendored omarchy `window-minimize` script,
  `Super+Alt+M` LIFO restore) with a backend where minimized windows retain their
  original workspace, prior tiling/floating state, and geometry where possible;
  they leave rendering/input/layout entirely and are represented — dimmed — in
  the left rail (deliverable H).
- **Investigate native Hyprland minimized-window state or a narrow carried patch
  first**, per decision #7/#11 (exhaustive evidence before "impossible"— a
  single-lane search that concludes "the ecosystem lives with it" is not a
  finding). Offscreen hiding is not accepted without Alex's explicit approval.
- **One-click restore/focus from the left rail is mandatory.** A restore-last
  hotkey (the existing `Super+Alt+M` shape) may continue to exist only as
  optional redundancy — never the primary or required path.
- This backend is what deliverable G's occupied-side and surplus minimization
  calls into; build or stub it before G's minimize-triggering behavior can be
  verified end-to-end.

### G. Deterministic two-pane snapping *(added 2026-07-29 — extends the existing half-snap)*

- Extend `snap_geometry`/`half_snap` (`keybinds.lua:61-135`) from a
  single-window float-and-toggle into the full deterministic model
  (`GRAND_PLAN.md` §6.2, §10.2 items 7–8):
  - `Super+Left`/`Super+Right` always produce exact left/right halves,
    independent of dwindle-tree shape or window count.
  - Snapping a window onto an **occupied side minimizes the previous occupant**
    (via deliverable F's backend).
  - **Completing a pair** (both halves occupied) **minimizes all other visible
    same-workspace windows.** The opposite half remains stable.
  - **Restoring a surplus minimized window**, or **dragging / unsnapping /
    maximizing / closing either pair member, dissolves the pair** and returns the
    workspace to ordinary Hyprland tiling, restoring prior placement/state where
    technically possible.
- **Snap gate:** one, two, and 3+ windows; target side already occupied;
  left/right; second-press return; restore surplus; drag; close; maximize; new
  window after a pair.

### H. Minimum final left-rail application slice *(added 2026-07-29)*

**This is the final rail architecture that Stage 3/5 extend — not a disposable
temporary strip.** Structural source: caelestia's `modules/bar/` app entries plus
`modules/windowinfo/` preview machinery, forked into aurora-shell
(`GRAND_PLAN.md` §2.1, §5.3).

The slice must include:

- launcher entry;
- pinned apps always visible;
- running and minimized windows from the **current workspace only**;
- minimized entries visibly dimmed but still active (consumes deliverable F's
  state);
- one window: click focuses/restores;
- multiple windows on one app: hover opens exact live previews, click a preview
  focuses/restores that exact window;
- **no duplicated top-bar status stack** — no workspace, tray, calendar,
  network, Bluetooth, audio, or battery presence on the rail;
- **no other-workspace running-window clutter.**

Out of this deliverable's acceptance bar (deferred to later stages, not silently
dropped): agridyne's full glass app-icon visual polish, drag-to-workspace-pill,
the optional Kurve visualizer, and the persistent-vs-hover-reveal default
(decided only after Stage 3's completed top+left view,
`GRAND_PLAN.md` §5.1 Visibility policy, §10.2 item 11). Stage 2 ships the rail
**persistent** for its own acceptance sitting.

---

## 3. Unfinished Stage 2 cleanup

After verifying nothing still depends on them:

- Remove the dead `waybar`, `rofi`, `awww`, and `waypaper` package entries from
  `modules/home/packages.nix`. (`GRAND_PLAN.md` confirms awww is retired
  entirely, not conditionally — this removal is validated, not merely
  historical dead weight.)
- Remove the obsolete `rofi-toggle` wrapper from
  `modules/home/hyprland/default.nix`.
- **Keep** the theming templates still required by the transitional Dunst/theme
  path (`modules/home/theming/` — `waybar.css`, `rofi.rasi`, `dunstrc`) until
  Stage 4 replaces the pipeline. Retiring them piecemeal risks breaking the Dunst
  fallback.
- **Do not let cleanup jeopardise the core fixes.** If the sweep destabilises the
  HM closure, drop it from the batch and say so — real fixes outrank cosmetic
  dead weight.
- Record anything retained and why.

---

## 4. Verification debt included in the next sitting

After the **one** boot-only deployment and reboot, Alex tests all of the following
in a single sitting. Mark **every** item `PASS`, `FAIL`, or `UNVERIFIED`. **No
skipped item becomes an implied pass.**

| # | Test | Result |
|---|---|---|
| 1 | Drag anchor — 4 grab points × short/tall windows × `Super+LMB` and titlebar drag; the window stays under the cursor at the grab point | |
| 2 | Floating drag regression — a floating window drags exactly as before | |
| 3 | Drop-to-retile — dropping a dragged tiled window back into the layout re-tiles it | |
| 4 | `follow_mouse = 2` — pointer scroll/interaction follows the hovered window without stealing keyboard focus; a click still transfers keyboard focus | |
| 5 | Deterministic snap, single window — `Super+Left` / `Super+Right` land fully in frame, exact halves, no top-left drift | |
| 6 | Deterministic snap, return — a second arrow press on a snapped half releases it back into ordinary tiling | |
| 7 | Deterministic snap, occupied side — snapping onto an occupied side minimizes the previous occupant into the same-workspace rail | |
| 8 | Deterministic snap, completed pair — snapping the second half minimizes all other same-workspace windows; the opposite half stays stable | |
| 9 | Pair dissolution, restore — restoring a surplus minimized window dissolves the pair and returns to ordinary tiling | |
| 10 | Pair dissolution, drag/unsnap/maximize/close — each action on a pair member dissolves the pair, restoring prior placement/state where possible | |
| 11 | New window after a pair — a new window does not tile underneath either snapped half | |
| 12 | Minimize backend — minimizing a window leaves layout/render/input and is not represented as a `special:` workspace | |
| 13 | Minimize backend — minimized windows retain original workspace, tiling/floating state, and geometry where possible | |
| 14 | Left rail — launcher entry present and opens the launcher | |
| 15 | Left rail — pinned apps always visible regardless of running state | |
| 16 | Left rail — running windows shown from the current workspace only | |
| 17 | Left rail — minimized windows shown dimmed, current workspace only, no other-workspace entries | |
| 18 | Left rail — single window: one click focuses/restores | |
| 19 | Left rail — multiple windows on one app: hover shows exact live previews, click selects the exact window | |
| 20 | Left rail — no duplicated workspace/tray/calendar/network/Bluetooth/audio/battery stack present | |
| 21 | DWT objective libinput state — `Disable-w-typing: enabled` for `/dev/input/event7` | |
| 22 | Real typing with palms resting naturally — the cursor does not jump | |
| 23 | All four floating-window corners, **both directions** (expand and shrink) | |
| 24 | `Super+RMB` redundant resize still works | |
| 25 | Region screenshot — `Super+Shift+S`, adjustable selection, clipboard + PNG | |
| 26 | Full screenshot — `Print` | |
| 27 | Screenshot colour fidelity — sampled pixels match the displayed test image | |
| 28 | Held-backspace repeat — controlled and progressive, not runaway | |
| 29 | Pinch zoom — already physically passed and not touched by this batch; confirm still working, but this is not a functional retest of new code (`GRAND_PLAN.md` §10.2 item 13) | |
| 30 | Existing hyprbars close / maximize buttons | |
| 31 | Click-to-focus | |
| 32 | Launcher — `Super+Space` and the Apps button | |
| 33 | Brightness and volume OSD — single owner, no double OSD | |
| 34 | TV reachability (Stage 0 debt) | |
| 35 | Xbox controller pairing (Stage 0 debt) | |
| 36 | VA-API / iHD encode verification (Stage 1 debt — `vainfo` is not in the closure; add `libva-utils` or verify by another route) | |

Note on item 23: on a **tiled** window, one-directional corner behaviour is
expected from dwindle tree math (`GRAND_PLAN.md` §6.2) — do not report that as a
failure. The requirement is the **floating** window case.

---

## 5. Exclusions — what must not creep into this batch

- **No Stage 3 implementation. No top widget bar / `topbar` module in the Stage 2
  closure** — the ilyamiro-composition top bar is Stage 3 work
  (`GRAND_PLAN.md` §10).
- **No dashboard UI work at all** — the Caelestia dashboard drawer is retired
  outright, not something to build, restyle, or gate in any stage
  (`GRAND_PLAN.md` §5.4, §10.2 item 14).
- The left-rail application slice built here (deliverable H) is Stage 2's own
  **minimum final slice** — not the complete Stage 3/5 rail. Full agridyne visual
  polish, cross-surface drag-to-workspace-pill, and the Kurve visualizer remain
  later-stage work; do not expand this batch to chase them.
- No half-measure minimize or snap ships as "final" — deliverables F and G are
  in scope precisely so Stage 2 does not close on the rejected
  `special:min-*` backend or the naive single-window half-snap.
- No Stage 4 wallpaper pipeline.
- No broad palette redesign.
- No glass tuning — explicitly Stage 4 (decision 16).
- No compositor version bump. (The volume gesture is deferred *to* the bump; the
  bump is not this batch. Bumping now invalidates both patches and the hyprbars
  ABI in one move.)
- No Stage 5 clipboard implementation.
- No Stage 6 Dolphin/apps work.
- No Stage 7 boot/lock work.
- No unrelated quick fixes discovered en route — log them, do not absorb them
  (e.g. the stray `Super+K` → `caelestia:dashboard` bind noted in §1 is logged,
  not fixed, here).
- No live compositor switch.
- No plugin hot-swap.
- No repeated build/reboot per individual fix.

---

## 6. Stage 2 completion condition

Stage 2 is complete only when:

1. All core changes (A–H) are **written**;
2. Both evaluation paths **build**;
3. The combined closure is **installed** (system profile set, boot-only);
4. The machine **boots** it;
5. All mandatory tests in §4 **pass**;
6. **No open Stage 2 requirement remains**;
7. **Alex explicitly accepts the gate**, in his own words;
8. `EXECUTION_LOG.md` records the result with the date and the actual confirmed
   active generation, plus the completed §4 table and the close-out table from
   `PM_OPERATING_RULES.md` §3.

**Until every one of those is true, report:**

`STAGE 2 — OPEN`
