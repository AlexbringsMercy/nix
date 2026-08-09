# Stage 2C — close out the window model (gesture restore, half-snap, DWT quirk)

## Read list — read ALL of these IN FULL before touching anything. No exceptions.

1. `/home/alex/nix/SESSION_PREAMBLE.md` — binds you. Internalize the failure case study.
2. `/home/alex/nix/EXECUTION_LOG.md` — the Stage 2 sections (2A, hover-crash lesson,
   2B close-out, and the **operator decisions register** at the end — decisions #1 and
   #4 there define two of your three tasks).
3. `/home/alex/nix/GRAND_PLAN.md` §6.2 (window management — the gesture and input
   rows), §6.4 (keymap), §3.3 (motion).
4. The current config tree you will edit: everything under
   `/home/alex/nix/modules/home/hyprland/hyprland/` (input.lua, keybinds.lua,
   general.lua, animations.lua, rules.lua) and `modules/home/hyprland/default.nix`.
5. The installed Hyprland 0.55.4 Lua API metadata and default Lua config in the nix
   store (find them; 2A verified dispatcher forms against these).
6. Reference sources for verified forms (read the relevant configs in full, on disk):
   `~/nix/repos/caelestia/` (main repo Hyprland Lua configs),
   `~/nix/repos/end4-dots-hyprland/` (Hyprland 0.55 Lua, gestures + animation curves).

## Scope

IN: the three tasks below, config/module edits only, plus your report.
OUT: everything else. Do NOT touch the drag bind, `animate_mouse_windowdragging`,
`scroll_factor`, hyprbars, the minimize system, or any aurora-shell QML. Do NOT
stage, commit, build, or run any live `hyprctl`/`hyprland` command. `.git` is
read-only to you by sandbox; the PM commits.

## Hard rules

- **Never cut or stub a planned feature to make an error go away.** If a task can't
  be done with a verified form, report exactly what you tried and what failed —
  the PM escalates; you do not "defer" it yourself. (Operator decision #4.)
- **Every dispatcher/gesture/quirk form you write must cite its source** — the exact
  file and line in the installed 0.55.4 metadata/default config or a reference repo
  where that literal form appears. The 2A lesson is binding: legacy `hyprctl`-style
  strings PARSE fine in Lua config and then fail silently or fault AT RUNTIME.
  A form you invented or "adapted from memory" is not verified.
- Attribution for anything vendored = upstream repo + path only.
- Report raw data, honestly, including anything you could not verify.

## Task 1 — restore the 3-finger vertical live-volume gesture (§6.2)

Commit 262472b removed it because a **lua-function gesture action faulted at
runtime**. The operator ruled: restore, properly. Find the verified native 0.55
gesture form for a continuous vertical 3-finger swipe driving volume — check the
installed default Lua config and API metadata first, then caelestia's and end-4's
gesture configs. If the native gesture API cannot drive volume continuously
without a Lua callback, the fallback shape is a gesture bound to the shell's
existing IPC volume targets (the OSD already owns volume feedback) — but only in
a form whose every piece is verified. State which shape you shipped and why.
Preserve: 3-finger horizontal workspace swipe (do-not-regress), pinch zoom.

## Task 2 — half-snap on bare Super+Left / Super+Right (operator decision #1)

Windows-style: snap focused window to exact left/right half (50% width, full
height). Deferred in 2A because no verified exact-resize form was in hand.
Resolve the tension: the plan (§6.2) says legacy string dispatchers work for
`resizewindowpixel "exact ..."`, but 2A found legacy strings rejected at runtime
by the 0.55 Lua path. Determine what actually works on 0.55.4 — the Lua
`hl.dsp.window.resize`/move forms (pixels-only per plan), a `hl.dsp.execHyprctl`-class
escape hatch if one exists in the metadata, or caelestia's own snap/resize usage.
Bare Super+arrows are partly taken: Super+Up = maximize, Super+Down = minimize
(keep both). Your binds are Super+Left and Super+Right only. Handle the tiled
case honestly: if half-snapping a tiled dwindle window requires floating it
first, do that explicitly in the action chain and say so in the report.

## Task 3 — the DWT libinput quirk (§6.2 input row, "DWT quirk!")

`disable_while_typing = true` is set but ineffective on T2 — root cause per the
plan is libinput not pairing the internal keyboard with the touchpad. Ship the
quirks override: `AttrKeyboardIntegration=internal`, **matched to this machine's
actual internal keyboard** — read `/proc/bus/input/devices` and the libinput
quirks documentation format; match narrowly (the Apple internal keyboard on the
T2 bus, not a wildcard that catches USB keyboards). Deliver it declaratively in
our NixOS/HM module tree (the correct Nix option for local libinput quirks —
verify the option exists in our nixpkgs rev before using it). Note in the report
that live verification is `libinput debug-events` before/after — a gate step for
the PM, not yours.

## Report format

Raw data, no prose padding: per task — files touched (exact paths), the exact
forms/values written, the source citation for each (file:line), what you verified
vs what needs the live gate, and anything that didn't work with what you tried.
