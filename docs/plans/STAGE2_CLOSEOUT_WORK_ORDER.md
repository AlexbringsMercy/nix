# STAGE 2 CLOSE-OUT — WORK ORDER

**Status: `STAGE 2 — OPEN`.**

> ## ⚠ SUPERSEDED FOR THE CURRENT CYCLE — GENERATION 32 HARD FAIL (2026-07-29)
>
> This work order drove the generation-32 build. Generation 32 **activated and then failed
> the physical gate** on ten defects, several of them regressions against generation 31
> (titlebar drag, tiled resize). Its close-out criteria are therefore **not met** and this
> document is **not** the brief for the next cycle.
>
> The current brief is **`docs/briefs/PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md`**, with ground truth and
> the failure matrix in **`docs/briefs/PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md`**.
>
> Requirements below that were **met and must not be regressed** — notably rail previews and
> exact grouped window selection — are listed in handoff §4.

The exact implementation brief for the incoming PM. Written 2026-07-28 against
confirmed ground truth (canonical branch is now `main`; written on the former
`codex/macbook-desktop` line at HEAD `6486742`), clean
tree, 0 ahead / 0 behind upstream; `/run/current-system`, `/run/booted-system` and
`/nix/var/nix/profiles/system` all resolve to **generation 26**. **Revised
2026-07-29** to bring Stage 2 scope into line with the corrected `docs/plans/GRAND_PLAN.md`
architecture (top/left bar split, wallpaper-derived palette, rejected
`special:min-*` minimize backend, deterministic two-pane snap, `follow_mouse = 2`,
retired dashboard UI). Per `docs/plans/GRAND_PLAN.md` §10 batch rule: **generation 27 from
the 2026-07-29 session is a valid compile/staging milestone but not the final
Stage 2 candidate**, because it predates the approved snap/minimize/rail/focus
decisions recorded in `docs/plans/GRAND_PLAN.md` §10.2.

Authority: `docs/reports/CURRENT_STATE_AUDIT_2026-08-09.md` for state, `docs/plans/GRAND_PLAN.md` for design,
`docs/reports/EXECUTION_LOG.md` (2026-07-28 operator decisions, plus the 2026-07-29 §10.2
architecture decisions) for the governance that binds this order,
`docs/instructions/PM_OPERATING_RULES.md` for how to work.

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
  handle the reservation/reflow model described in `docs/plans/GRAND_PLAN.md` §6.2
  (clarified 2026-08-09 — not a pair model), and has no reservation-release
  logic beyond the single second-press toggle. This is the Stage 2 starting point
  for deliverable G below, not the finished behavior.
- **The current minimize backend is the model `docs/plans/GRAND_PLAN.md` §6.2 rejects.**
  Verified on disk: `modules/home/hyprland/hyprland/general.lua` sets
  `close_special_on_empty = true` ("remove each per-window minimize workspace
  after restore"); `modules/home/hyprland/hyprbars.lua.in:51` and
  `modules/home/hyprland/default.nix:24,33` wire a `window-minimize` script
  (`modules/home/scripts/window-minimize`, "the vendored omarchy script") that
  minimizes into per-window `special:` workspaces; `keybinds.lua:32,50` bind
  `Super+Down` to minimize and `Super+Alt+M` to a LIFO "restore last minimized."
  This is exactly the `special:min-*` backend now rejected as final
  (`docs/plans/GRAND_PLAN.md` §6.2, §10.2 item 5) — it is the Stage 2 deliverable F
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
  surface") — the now-retired dashboard surface (`docs/plans/GRAND_PLAN.md` §5.4, §10.2 item
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
- **Build both evaluation paths** (git-backed input, never raw `path:`) —
  `git+file:///home/alex/nix#homeConfigurations.alex.activationPackage` and
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
8. **Implement the final `docs/plans/GRAND_PLAN.md` §5.12 architecture now** — carried
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
  (`docs/plans/GRAND_PLAN.md` §6.2).
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
  (`docs/plans/GRAND_PLAN.md` §6.2, §10.2 items 7–8):
  - `Super+Left`/`Super+Right` always produce exact left/right halves,
    independent of dwindle-tree shape or window count.
  - Snapping a window onto an **already-reserved side demotes the previous owner
    to ordinary** — the previous owner joins the opposite half's reflow pool
    (or overflow/minimized if that half is also reserved).
  - **Both halves reserved** by explicit half-snap owners and no ordinary tiled
    region remaining → remaining ordinary windows minimize. Ordinary windows
    are **not** minimized merely because one half is reserved.
  - **Releasing a reservation** — dragging/unsnapping/maximizing/closing an owner —
    returns that region to the ordinary reflow pool and re-tiles normally,
    restoring prior placement/state where technically possible.
- **Snap gate:** one, two, and 3+ windows; target side already reserved;
  left/right; second-press return; single-owner reflow (other windows stay
  visible); both-halves-reserved minimize; owner demotion on cross-side snap;
  restore; drag; close; maximize; new window while a half is reserved.

### H. Minimum final left-rail application slice *(added 2026-07-29)*

**This is the final rail architecture that Stage 3/5 extend — not a disposable
temporary strip.** Structural source: caelestia's `modules/bar/` app entries plus
`modules/windowinfo/` preview machinery, forked into aurora-shell
(`docs/plans/GRAND_PLAN.md` §2.1, §5.3).

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
`docs/plans/GRAND_PLAN.md` §5.1 Visibility policy, §10.2 item 11). Stage 2 ships the rail
**persistent** for its own acceptance sitting.

---

## 3. Unfinished Stage 2 cleanup

After verifying nothing still depends on them:

- Remove the dead `waybar`, `rofi`, `awww`, and `waypaper` package entries from
  `modules/home/packages.nix`. (`docs/plans/GRAND_PLAN.md` confirms awww is retired
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
| 7 | Reservation/reflow, one side reserved — ordinary windows stay visible and reflow in the opposite half; they are not minimized | |
| 8 | Reservation/reflow, both sides reserved — both halves owned by explicit half-snap owners and no ordinary region remains → surplus minimizes | |
| 9 | Snap onto already-reserved side — previous owner is demoted to ordinary and joins reflow pool | |
| 10 | Reservation release — dragging/unsnapping/maximizing/closing an owner releases the reservation and returns the region to ordinary tiling | |
| 11 | New window while a half is reserved — new window tiles in the available region | |
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
| 23 | **Tiled** corner resize — all four corners, **both axes**, expand *and* shrink, in 3- and 4-window layouts, **without floating the window first and without a hotkey** | |
| 23b | Floating corner resize still works (incidental regression check — **not** the acceptance target) | |
| 24 | `Super+RMB` redundant resize still works | |
| 25 | Region screenshot — `Super+Shift+S`, adjustable selection, clipboard + PNG | |
| 26 | Full screenshot — reachable by **one click on the visible Full screen button**; no Print key involved | |
| 27 | Screenshot colour fidelity — sampled pixels match the displayed test image | |
| 28 | Held-backspace repeat — controlled and progressive, not runaway | |
| 29 | Pinch zoom — already physically passed and not touched by this batch; confirm still working, but this is not a functional retest of new code (`docs/plans/GRAND_PLAN.md` §10.2 item 13) | |
| 30 | Existing hyprbars close / maximize buttons | |
| 31 | Click-to-focus | |
| 32 | Launcher — `Super+Space` and the Apps button | |
| 33 | Brightness and volume OSD — single owner, no double OSD | |
| 34 | TV reachability (Stage 0 debt) | |
| 35 | Xbox controller pairing (Stage 0 debt) | |
| 36 | VA-API / iHD encode verification (Stage 1 debt — `vainfo` is not in the closure; add `libva-utils` or verify by another route) | |

**Rows added 2026-07-29** for the correction batch and operator decisions 24 and 27.
They are gate rows, not a second gate — the same single sitting.

| # | Test | Result |
|---|---|---|
| 37 | Rail hover preview, **single window** — hovering a single-window app shows a live preview (this failed globally at gen 31; Thunar only proved *restore*, never *preview*) | |
| 38 | Rail hover preview, **grouped app** — two Kitty windows show two distinct exact previews, not one group icon | |
| 39 | Rail grouped restore — clicking a specific thumbnail focuses/restores **that exact window address** | |
| 40 | Rail minimized members visibly **dimmed** yet still selectable, current workspace only | |
| 41 | Rail hover/scroll **never** changes brightness (gen-31 blocker: brightness fell to zero) | |
| 42 | Status controls elsewhere still respond to their own scroll — the rail fix did not kill legitimate scrolling | |
| 43 | Floating window hover — pointer scroll works while keyboard focus **stays on the last clicked window** until a click | |
| 44 | DWT recovery — measure how quickly pointer control returns after typing stops. **Normal libinput DWT delay is not a defect**; record the measurement | |
| 45 | Screenshot toolbar — appears **top-centred** with Region · Window · Full screen, active mode visually obvious | |
| 46 | Screenshot toolbar **absent from captured output** (the pink-film defect class — structural exclusion, not timing) | |
| 47 | Screenshot focus — **cancel** restores the exact prior focus owner and typing works without an extra click | |
| 48 | Screenshot focus — **completion** restores the exact prior focus owner; the capture target did not permanently steal focus | |
| 49 | Screenshot — **no ghost image/screenshot utility icon** in the app rail | |
| 50 | Boot readiness — no Chrome clock/auth failure after reboot; no premature first-post-resume API failure. Terminals still return promptly even if sync is slow | |
| 51 | **Agent persistence — Claude:** `claude --version` resolves the canonical `~/.local/bin/claude` (2.1.220 or newer) in (a) the resumed shell, (b) a fresh terminal, (c) a fresh graphical login, (d) after reboot. No older duplicate wins | |
| 52 | **Agent persistence — Codex:** same four contexts resolve `~/.local/bin/codex` → the standalone lane (0.145.0 or newer) | |
| 53 | Agent state intact — Claude and Codex configuration, credentials and resumable sessions survive the generation | |
| 54 | Boot default (decision 23) — during this reboot, select NixOS in Apple Startup Manager **while holding Control**. **Verified only on the NEXT cold boot**, not this one | |

**Non-blocking, recorded, not gating this closure:** the wallpaper picker has no
ordinary mouse path. Operator ruling — temporary debt until Stage 4 installs the
final skwd workflow. Do not build throwaway wallpaper UI to clear it.

**Note on item 23 — REVERSED BY THE OPERATOR, 2026-07-29.** This work order
previously said one-directional corner behaviour on a *tiled* window was expected
dwindle-tree math and should not be reported as a failure, and that "the
requirement is the **floating** window case." **That is now wrong and is
superseded.** At the generation-31 runtime gate Alex ruled, verbatim: *"Floating
corner resize: PASS, incidental and not the acceptance target. Tiled corner
resize: FAIL, Stage 2 blocker."* and *"Do not treat working floating resize as
resolution, and do not introduce 'float first' as the workflow. Alex does not
ordinarily use floating windows and does not want floating behavior elevated into
a prerequisite or primary window-management model."*

The accepted requirement is ordinary mouse resizing on **normal tiled windows** —
grabbing any corner resizes both applicable axes wherever neighbouring layout
space permits, with no float-first preparation and no memorized hotkey. The
one-directional behaviour that this note previously excused is the **root cause
that `hyprland-dwindle-resize-workarea.patch` exists to fix**: dwindle measured
its edge-stick flags against the un-inset monitor box instead of
`space()->workArea()`, so with any `gaps_out >= 2` all four `DISPLAY*` flags were
permanently false and a corner grab on a work-area edge contributed no axis.

---

## 5. Exclusions — what must not creep into this batch

- **No Stage 3 implementation. No top widget bar / `topbar` module in the Stage 2
  closure** — the ilyamiro-composition top bar is Stage 3 work
  (`docs/plans/GRAND_PLAN.md` §10).
- **No dashboard UI work at all** — the Caelestia dashboard drawer is retired
  outright, not something to build, restyle, or gate in any stage
  (`docs/plans/GRAND_PLAN.md` §5.4, §10.2 item 14).
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
8. `docs/reports/EXECUTION_LOG.md` records the result with the date and the actual confirmed
   active generation, plus the completed §4 table and the close-out table from
   `docs/instructions/PM_OPERATING_RULES.md` §3.

**Until every one of those is true, report:**

`STAGE 2 — OPEN`
