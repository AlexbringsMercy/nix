First, read /home/alex/nix/SESSION_PREAMBLE.md in full and follow it. Then read PM_HANDOFF.md and EXECUTION_LOG.md for the Stage 2 state. Do not skip this.

# Task: root-cause the Super+drag "spring" and PROPOSE fixes — DO NOT change any files

This is a **proposal-only investigation**. You will NOT edit, stage, commit, build, or run any live Hyprland command. Your entire deliverable is a written root-cause + ranked fix options. The PM raises your proposal to the operator, who picks one; only then will a follow-up prompt tell you to execute. If you touch a tracked file, you have failed the task.

## The symptom (operator, reproduced every session since Stage 2A)
Holding **Super** and dragging a window with the left mouse button does not drag it smoothly from the grab point. The window "bounces out of frame" — a small pointer movement throws the window a large distance, often half or fully off-screen. This happens on ordinary tiled terminal windows (kitty). Close, maximize, minimize, and hover all work correctly; only the move-drag is wrong.

## Hard environmental facts (already gathered live — treat as ground truth)
- Compositor: **Hyprland 0.55.4**, native-Lua config.
- Monitor: `eDP-1`, **2560x1600 @ 60Hz, scale = 1.50 (fractional), transform 0**. Single display.
- Layout: `general:layout = dwindle`.
- The move bind is exactly: `hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })` in modules/home/hyprland/hyprland/keybinds.lua:26. The resize bind directly below uses `hl.dsp.window.resize()`.
- hyprbars plugin is loaded (our ABI-matched patched v0.55.0, adds titlebars + the hover state).
- `input:follow_mouse = 0`, `sensitivity = 0.05`, `accel_profile = "adaptive"` (input.lua).

## What "propose" means — answer these precisely
1. **What is `hl.dsp.window.drag()` actually dispatching?** Resolve it in the installed Hyprland 0.55.4 Lua API metadata / the caelestia hl helper source — is it `movewindow`, a mouse-follow move loop, or something else? Quote the resolved dispatcher string/form. If it is the wrong dispatcher for a continuous mouse-follow move (vs. e.g. a one-shot keyboard move), say so.
2. **Is fractional scale 1.5 the cause?** Search upstream Hyprland issues/changelog knowledge for drag/move jump under fractional scaling around 0.55.x. State whether the move delta is known to be mis-scaled and whether it was fixed, worked-around, or still open at 0.55.4.
3. **Is the tiled→float transition the cause?** When Super+drag grabs a *tiled* dwindle window, does Hyprland float it first, and if so where does it place it (cursor-relative with a bad offset? centered? 0,0?)? Distinguish this from the scale hypothesis — which one matches "small move → large jump" better?
4. **Does hyprbars change the grab math?** Does the titlebar height shift the window's logical origin so the grab point is computed wrong? Rule this in or out.

## Deliverable — ranked fix options
Give **2–4** concrete fix options, each with: the exact change (file + line + before/after), the mechanism it fixes, the risk/tradeoff, and whether it is config-only (live-reloadable) or needs a rebuild. Rank them by your confidence that they fix the root cause. Consider at minimum: the correct 0.55 continuous-move dispatcher form; any `misc:` / `input:` knob that governs drag-to-scale; forcing a sane float placement on grab; and whether a dedicated `bindm`-style continuous mouse bind differs from the current `hl.dsp.window.drag()` form. If one option is clearly correct, say so and say why the others are inferior — do not hedge.

## Output
Return raw findings only (this is the return value, not a human message): the resolved dispatcher, the root-cause verdict with evidence, and the ranked options table. No preamble, no summary of what you read.
