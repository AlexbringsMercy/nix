# Stage 2D — window float/placement lifecycle fixes

## Read first

1. `/home/alex/nix/SESSION_PREAMBLE.md` — binds you, always.
2. `docs/reports/EXECUTION_LOG.md` — the "Stage 2 gate — RAN 2026-07-21 evening" entry and the
   operator decisions register above it. That gate entry is your task spec's
   evidence base: every root cause referenced below was proven live there.
3. Your working files: `modules/home/hyprland/hyprland/{keybinds.lua,general.lua,input.lua}`,
   the installed Hyprland 0.55.4 lua stubs + default config in the nix store, and
   the reference configs at `repos/caelestia/hypr/` and `repos/end4-dots-hyprland/dots/.config/hypr/`.

## Scope

IN: the five tasks below. OUT: everything else — no aurora-shell QML, no plugin
source, no live hyprctl/hyprland commands, no staging/commit (PM commits). If a
task requires patching Hyprland source or bumping the pinned Hyprland, STOP that
task and report it as an escalation with your evidence — that is an operator
decision, not yours.

## Hard rules

Same as 2C: never cut a feature to silence a bug; every form you write must cite
the exact file:line where that literal form is used (installed stubs/default
config or a reference repo); the 2A lesson stands (legacy strings parse but fail
at runtime); report raw data honestly including failures.

## Task 1 — make `animate_mouse_windowdragging = false` permanent

`general.lua` misc block. One line, true→false. Operator decision #8; the plan's
§3.3 value. Done.

## Task 2 — the tiled-drag pickup jump (research → implement only if config-level)

Proven live: when MBIND_MOVE plucks a *tiled* window from the layout, 0.55.4
places it centered under the cursor, discarding the grab offset. Floating windows
drag perfectly. Your job is to find how this is properly handled, in order:
(a) Any 0.55.4 config option governing pickup placement or grab-offset
    preservation — exhaustive pass over the installed option metadata, not a
    keyword guess.
(b) Upstream: did later Hyprland releases change/fix tiled-pickup placement?
    Find the commit/PR if so — that tells us whether the compositor bump
    (already planned for the volume gesture, decision #9) inherits the fix free.
(c) Community configs: how do caelestia, end-4, and other mature 0.55-era Lua
    configs handle Super+drag on tiled windows — do they pre-float in place, use
    a different bind shape, or live with it?
If (a) or (c) yields a verified config-level fix, implement it. A pre-float-in-
place wrapper on the drag bind is acceptable ONLY if you verify the mouse-bind
press/release semantics survive a lua-function action (check the stubs + the
default config; if unverifiable statically, report instead of shipping). If the
only real fix is (b)-class, escalate with the citation.

## Task 3 — half-snap: fix placement + add a release path

Two proven defects in `half_snap()` (keybinds.lua):
(a) Placement drifts out of frame top-left. Determine the coordinate space
    `hl.dsp.window.move` exact coords use relative to decoration reserved
    extents (hyprbars top bar) and gaps; correct the geometry so the snapped
    window sits fully in frame respecting gaps_out. Cite how you determined the
    coordinate space (stub docs, caelestia usage, or geometry math from the
    monitor's reserved area fields if exposed on `hl.get_active_monitor()`).
(b) Snapped windows stay floating forever; new windows tile underneath them.
    Add the release path: pressing Super+Left/Right on an ALREADY-SNAPPED
    (floating) window returns it to the layout (`float action off`), or — if you
    find a cleaner community pattern for snap-cycling (left→right→retile) in the
    reference configs — propose it in the report and implement the simple toggle
    meanwhile. Also make Super+Up (maximize) and any drag of a snapped window
    behave sanely — at minimum document what happens.

## Task 4 — DWT deeper research (no machine diagnostics — config prep only)

The 2C quirk landed but typing-protection is only partially effective, and
libinput's stock Apple rule may have already set AttrKeyboardIntegration. Research
the T2/Apple touchpad palm-detection surface: which additional quirk attributes
(palm pressure/size thresholds, thumb detection, dwt-related attrs) libinput
1.31.3 supports and what values the t2linux/Apple community uses for this
hardware. Deliver: a candidate quirks stanza EXTENSION (commented out or in your
report — NOT enabled) with per-attribute source citations, so the PM can A/B it
live with the operator at the re-check. Do not enable anything you cannot verify.

## Task 5 — corner-resize verdict (research + config only)

resize_on_border corner grabs are hit-or-miss with hyprbars loaded — the plan's
§6.2 flags a known upstream interaction (referenced as issue #355). Establish:
is this the known issue on our pinned versions? Check `extend_border_grab_area`
and related general/border options for a verified mitigation. If a config-level
improvement exists, implement it; if the honest answer is the known conflict,
say so — the plan pre-authorizes the fallback (corner Super+RMB, already bound,
+ documentation), and the PM will apply that verdict.

## Report

Raw data per task: files touched, exact forms written, citation per form, what
is verified vs needs the live re-check, escalations with evidence. Static
checks: luac -p on every touched lua file; nix eval sanity if you touch nix.
