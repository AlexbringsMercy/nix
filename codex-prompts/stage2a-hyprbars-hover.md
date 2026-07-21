# Stage 2A patch proposal — hyprbars button hover state

You are a Codex execution session for the Aurora build (NixOS + Hyprland 0.55.4, MacBook Air T2), working in `/home/alex/nix`. Your PM launches, reviews, and integrates you; your final message is a report to them. **This is a PROPOSAL task: you write the patch + wiring as files, but you do NOT build, deploy, commit, or run nix — the PM audits your proposal, raises it to the operator for approval, and only then builds/tests it live.**

## Mandatory reading, in order

1. `/home/alex/nix/SESSION_PREAMBLE.md` — in full; its rules bind you (adapt real source, don't invent; full reads; honest reporting).
2. The hyprbars source, now cloned locally: `/home/alex/nix/repos/hyprland-plugins/hyprbars/` — read `barDeco.cpp` and `barDeco.hpp` fully. Note especially `renderBarButtons` (draws the per-button `bgcol` rect), `renderBarButtonsText` (computes per-button hover into the `m_iButtonHoverState` bitfield), `onMouseMove` (line ~152, only calls `damageOnButtonHover()` when `icon_on_hover` is set), and `damageOnButtonHover` (line ~667).
3. `/home/alex/nix/modules/home/hyprland/default.nix` (the `hyprbarsLua`/`windowMinimize` wiring + how `${pkgs.hyprlandPlugins.hyprbars}/lib/libhyprbars.so` is referenced) and `/home/alex/nix/modules/home/hyprland/hyprbars.lua.in`.

## The goal (operator, 2026-07-21)

The titlebar buttons are clean monochrome glyphs on a transparent background — **keep the transparent background** (operator: "no backgrounds, just a hover state"). Add a **hover state**: when the pointer is over a button, draw a subtle highlight behind that button's glyph (like a Windows titlebar button lighting up), and remove it when the pointer leaves. Also make the buttons **a bit bigger**.

## Scope

IN — PROPOSE (write the files, do not build/deploy):
1. A minimal C++ patch to hyprbars adding the hover highlight.
2. The Nix wiring to build a patched hyprbars and point the plugin load at it.
3. The `hyprbars.lua.in` button-size bump.

OUT: building, `nix` anything, `git` commit/push, deploying, `systemctl`/`hyprctl`, touching the running session. Do NOT add a persistent button background. Do NOT change button actions, icons, or the double-click (already fixed and working). Do NOT touch anything outside the files below.

## Tasks

### 1. Investigate + propose the C++ patch (write it as a unified diff file)

Read the render path and propose the smallest correct change:
- **In `renderBarButtons`**: after drawing the base `bgcol` rect for button `i`, if that button is hovered (`m_iButtonHoverState & (1 << i)`), render a subtle highlight rect over the same `buttonBox` (same rounding). The base bg is usually transparent, so the highlight is what the user sees on hover. Use the existing `CHyprColor`/`renderRect` idiom already in the file. Note `renderBarButtons` runs one frame before `renderBarButtonsText` updates the bitfield — a one-frame lag is fine.
- **In `onMouseMove`**: `damageOnButtonHover()` is currently gated behind `icon_on_hover`, so without it a hover change never triggers a redraw and the highlight won't appear/disappear. Make the damage fire on hover change **regardless** of `icon_on_hover`, without breaking the existing `icon_on_hover` behavior. (Read `damageOnButtonHover` to confirm it damages the button region and is safe to call every move / on-change.)
- **Highlight colour**: propose a new config value `plugin:hyprbars:hover_color` (follow how the existing `plugin:hyprbars:*` values are registered — find the `addConfigValue`/config-struct site and mirror it exactly) defaulting to a subtle translucent white (e.g. `rgba(ffffff22)`), so it's tunable. If adding a config value turns out to be more than a few lines of plumbing, fall back to a hardcoded subtle white highlight and say so — keep the patch minimal.
- Write the patch to `/home/alex/nix/modules/home/hyprland/patches/hyprbars-hover.patch` as a proper `-p1` unified diff against the `hyprbars/` subtree (paths like `a/hyprbars/barDeco.cpp`). It must apply against the cloned source (HEAD `7644cec…` in `repos/hyprland-plugins`); report that rev so the PM can pin the derivation's `src` to it if nixpkgs' rev differs.

### 2. Propose the Nix wiring (edit `modules/home/hyprland/default.nix`)

Build a patched hyprbars via `pkgs.hyprlandPlugins.hyprbars.overrideAttrs` adding `patches = [ ./patches/hyprbars-hover.patch ]` (and, if you judge the nixpkgs src rev may not match the patch, override `src` to fetch `hyprwm/hyprland-plugins` at the reviewed rev — propose the `fetchFromGitHub` with the rev, leaving the `hash` as a placeholder `""` for the PM to fill from the build error). Replace the `@HYPRBARS_PLUGIN@` substitution's `${pkgs.hyprlandPlugins.hyprbars}` with the patched derivation's output so the loaded `.so` is the patched one. Marker-comment every line. Keep it ABI-matched (still built against `pkgs.hyprland`).

### 3. Button size (edit `hyprbars.lua.in`)

Bump the three buttons' `size` (currently 20) to a slightly larger value (propose ~22–24). Keep `bg_color = "rgba(00000000)"` (transparent — the hover highlight is the only background). Leave everything else.

## Final report (raw data — this is a PROPOSAL for PM audit)

- The full C++ patch quoted, with a plain-English explanation of each hunk and exactly how the hover render + damage work.
- Whether you added the `hover_color` config value or hardcoded it, and why.
- The `default.nix` wiring diff (quoted) and whether you overrode `src` (and the rev).
- The `hyprbars.lua.in` size change.
- **Risks for the PM to weigh:** compositor-crash surface (it's a compositor plugin — what could a wrong render/damage do?), ABI considerations, the src-rev/patch-apply risk, and anything you're unsure of.
- What you verified by reading vs. what only a live build/test can confirm (you cannot compile or run a compositor here).
