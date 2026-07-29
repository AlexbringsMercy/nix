# STAGE 2 CLOSE-OUT — WORK ORDER

**Status: `STAGE 2 — OPEN`.**

The exact implementation brief for the incoming PM. Written 2026-07-28 against
confirmed ground truth: branch `codex/macbook-desktop`, HEAD `6486742`, clean
tree, 0 ahead / 0 behind upstream; `/run/current-system`, `/run/booted-system` and
`/nix/var/nix/profiles/system` all resolve to **generation 26**.

Authority: `CURRENT_STATE_AUDIT.md` for state, `GRAND_PLAN.md` for design,
`EXECUTION_LOG.md` (2026-07-28 operator decisions) for the governance that binds
this order, `PM_OPERATING_RULES.md` for how to work.

---

## 1. Current truth

- **Stage 0** carries two physical-check debts: **TV reachability** and **Xbox
  controller pairing**. Both were deferred at the Stage 0 gate and then never run.
  Inference-backed, not test-backed.
- **Stage 1** is accepted, **with the glass A/B deferral to Stage 4 now explicitly
  approved** (decision 16). The current glass appearance is *not* accepted.
- **Stage 2 is not closed.** Conditional pass only.
- **Generation 26 is active and is the default boot generation.**
- **Half-snap (2D) is active but untested** — it is running in generation 26 and
  Alex has never exercised it.
- **The drag-anchor patch exists but is not built.** `df37152` committed the patch
  and the overlay; the patched output `azvhdgfz…-hyprland-0.55.4` is not a valid
  store path. Stock unpatched Hyprland is running.
- **DWT does not exist on the touchpad** because udev classifies it
  `ID_INPUT_TOUCHPAD_INTEGRATION=external`; libinput reports
  `Disable-w-typing: n/a`.
- **Corner resize has no implementation** — no patch, no research artifact, no
  prompt. Non-negotiable by decision #11.
- **Stage 3 has not started.** No `topbar`/`taskbar` module exists.

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

---

## 3. Unfinished Stage 2 cleanup

After verifying nothing still depends on them:

- Remove the dead `waybar`, `rofi`, `awww`, and `waypaper` package entries from
  `modules/home/packages.nix`.
- Remove the obsolete `rofi-toggle` wrapper from
  `modules/home/hyprland/default.nix`.
- **Keep** the theming templates still required by the transitional Dunst/theme
  path (`modules/home/theming/` — `waybar.css`, `rofi.rasi`, `dunstrc`) until
  Stage 4 replaces the pipeline. Retiring them piecemeal risks breaking the Dunst
  fallback.
- **Do not let cleanup jeopardise the core fixes.** If the sweep destabilises the
  HM closure, drop it from the batch and say so — three real fixes outrank
  cosmetic dead weight.
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
| 4 | Half-snap geometry — `Super+Left` / `Super+Right` land fully in frame, no top-left drift | |
| 5 | Return from half-snap to tiling — a second arrow press retiles the window | |
| 6 | New-window behaviour after snapping — a new window does not tile underneath a permanent floater | |
| 7 | DWT objective libinput state — `Disable-w-typing: enabled` for `/dev/input/event7` | |
| 8 | Real typing with palms resting naturally — the cursor does not jump | |
| 9 | All four floating-window corners, **both directions** (expand and shrink) | |
| 10 | `Super+RMB` redundant resize still works | |
| 11 | Region screenshot — `Super+Shift+S`, adjustable selection, clipboard + PNG | |
| 12 | Full screenshot — `Print` | |
| 13 | Screenshot colour fidelity — sampled pixels match the displayed test image | |
| 14 | Held-backspace repeat — controlled and progressive, not runaway | |
| 15 | Pinch zoom — 2-finger pinch drives `cursor_zoom` | |
| 16 | Existing close / maximize / minimize buttons | |
| 17 | Click-to-focus | |
| 18 | Launcher — `Super+Space` and the Apps button | |
| 19 | Brightness and volume OSD — single owner, no double OSD | |
| 20 | TV reachability (Stage 0 debt) | |
| 21 | Xbox controller pairing (Stage 0 debt) | |
| 22 | VA-API / iHD encode verification (Stage 1 debt — `vainfo` is not in the closure; add `libva-utils` or verify by another route) | |

Note on item 9: on a **tiled** window, one-directional corner behaviour is expected
from dwindle tree math (`GRAND_PLAN.md` §6.2) — do not report that as a failure.
The requirement is the **floating** window case.

---

## 5. Exclusions — what must not creep into this batch

- No Stage 3 implementation.
- No taskbar.
- No minimized-workspace (`special:min-*`) filter until the taskbar ships — hiding
  it earlier makes minimize a one-way trip.
- No Stage 4 wallpaper pipeline.
- No broad palette redesign.
- No glass tuning — explicitly Stage 4 (decision 16).
- No compositor version bump. (The volume gesture is deferred *to* the bump; the
  bump is not this batch. Bumping now invalidates both patches and the hyprbars
  ABI in one move.)
- No Stage 5 clipboard implementation.
- No Stage 6 Dolphin/apps work.
- No Stage 7 boot/lock work.
- No unrelated quick fixes discovered en route — log them, do not absorb them.
- No live compositor switch.
- No plugin hot-swap.
- No repeated build/reboot per individual fix.

---

## 6. Stage 2 completion condition

Stage 2 is complete only when:

1. All core changes (A, B, C, D) are **written**;
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
