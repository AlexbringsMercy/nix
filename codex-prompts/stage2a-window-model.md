# Stage 2A — The window model: hyprbars, minimize, focus, move/snap, workspaces 1–5

You are a Codex execution session for the Aurora build (NixOS + Hyprland 0.55.4, 2020 MacBook Air T2), working in `/home/alex/nix`. Your PM launches, monitors, and reviews you; your final message is a report to them, not to a human bystander. The caelestia shell is now the live desktop (Stage 1C cutover done). This session gives every window real title-bar buttons and a proper window-management model.

**File work only. You do not activate.** The PM builds, commits, pushes, and deploys. No nix, no git commit/push, no systemctl, no touching the running session.

## Mandatory reading, in order, before any other action

1. `/home/alex/nix/SESSION_PREAMBLE.md` — in full; its rules bind this session (read the system before writing verdicts; never declare something absent from a partial look; adapt cited sources, don't invent).
2. `/home/alex/nix/GRAND_PLAN.md` §6.2 "Window management (the full spec)" (lines ~431–441) — this is your law for this session. Also §3.2 (glass, for the hyprbars color source) and the §2.1 manifest note that hyprbars owns per-window buttons.
3. `/home/alex/nix/SOURCES.md` `## Source map` rows for `hyprwm/hyprland-plugins` (hyprbars) and `omarchy-desktop-shell` (window-minimize + hyprbars config values).
4. The current config you are editing: `modules/home/hyprland/hyprland/{keybinds,input,rules,general,animation}.lua`, `modules/home/hyprland/default.nix`, `modules/home/packages.nix`.

## Scope — Stage 2A only

IN:
- **hyprbars** plugin: load it, configure per §6.2, add `no_bar` rules for the right windows.
- **Minimize**: the omarchy `window-minimize` per-window-special-workspace approach + a restore keybind.
- **Focus policy**: click-to-focus.
- **Move / resize / snap**: title-bar drag (no modifier), keep the `Super+drag` fallbacks, magnetism, half/full snap keybinds, maximize toggle.
- **Workspaces 1–5** (up from 1–2).

OUT (later — do NOT touch this session):
- Input tuning (DWT quirk, repeat/scroll values), gestures, SwayOSD retire, brightness/media-key rebind, the launcher/surface keymap, `rules.lua` layer-namespace cleanup, `easyeffects` hiding → **Stage 2B**.
- `hyprexpo` overview (MISSING from our nixpkgs; comes with the plugins-flake in Stage 5), the Alt+Tab live cycler, clipboard, sysmon workspace → **Stage 5 / 8**.
- The composite lock, top taskbar, palette → their stages.
- Do NOT rewrite whole files. Minimal, marked diffs.

## Hard rules

- NO network, NO nix (`build`/`eval`/`flake`), NO git commit/push, NO systemctl, NO live activation. The PM does all of that.
- `git add`/`git rm` are not available to you (`.git` is read-only in your sandbox) — just leave the working tree edited; the PM stages and commits. Report every path you changed.
- `/home/alex/nix/repos/` is READ-ONLY reference.
- Minimal diffs; every changed/added line in an existing file gets an `-- Aurora:` (lua) / `# Aurora:` (nix) marker with a one-line why. If you're rewriting a file, stop and report instead.
- Native Hyprland 0.55 Lua only — no legacy `hyprland.conf`, no `hyprctl keyword`. Runtime dispatchers are `hl.dsp.*` Lua expressions (EXECUTION_LOG "Hyprland 0.55 IPC rule"). Static JSON/Nix validation will NOT catch a bad dispatcher — get the forms right by reading the existing working binds in `keybinds.lua`.
- 8 GB machine: scripts for bulk ops.
- Report honestly — every deviation, forced interpretation, and anything you couldn't complete.

## Tasks

### 1. Investigate first — report findings before editing

Do not guess any of these; read and report:
- **How the Lua config is deployed** by `modules/home/hyprland/default.nix` (xdg.configFile? a generated tree?), so you know how to inject a Nix store path into the Lua.
- **The native-Lua plugin-load API for Hyprland 0.55.** Find the correct call (likely `hl.plugin("<path>")` — verify against the hyprland Lua API / any plugin-loading example in `repos/` or the caelestia reference config). The plugin `.so` is a Nix store path: `${pkgs.hyprlandPlugins.hyprbars}/lib/libhyprbars.so` (confirm the exact lib filename by reasoning from the package layout — report your assumption for PM verification). Plan the cleanest injection: generate a tiny Lua file with the store path templated via Nix in `default.nix` (mirror the `theming/default.nix` `matugenConfig`/`writeText` + `replaceStrings` pattern), loaded early in the Lua entry order.
- **hyprbars native-Lua config shape.** hyprbars is configured under a `plugin.hyprbars` block and its buttons use `hyprbars-button` directives — determine how these map into `hl.config({ plugin = { hyprbars = { ... } } })` and how buttons are expressed in this Lua API. Read the existing `hl.config({...})` calls in `general.lua`/`input.lua` for the shape. Report the exact form you'll use.
- **The omarchy `window-minimize` approach**: per-window `special:min-<addr>` workspaces, `movetoworkspacesilent`, `misc:close_special_on_empty = 1`, LIFO restore. `repos/` may not have omarchy — if absent, implement the small script from the §6.2 description (a shell script vendored to `scripts/`, wired like the other `scripts/*` in `hyprland/default.nix` via `builtins.readFile`). Report where the pattern came from.
- Current `keybinds.lua` window binds, `rules.lua` window rules, and `general.lua` decoration/gaps/snap settings — so your changes compose instead of collide.

### 2. hyprbars

- Load the plugin (task-1 mechanism).
- Config per §6.2: `bar_height 28`, padding 10, title text 11 FiraCode Nerd Font, `bar_part_of_window = true`, `bar_precedence_over_border = true`, `on_double_click = fullscreen 1`. Buttons right→left: **close** (`killactive`), **maximize** (`fullscreen 1`), **minimize** (→ the window-minimize script from task 3). Button/title colors come from the scheme — for THIS session use the §3.1 ladder values directly as literals (a scheme-driven template is Stage 4); mark them as interim.
- `no_bar` window rules (in `rules.lua`) for: the shell's own surfaces/namespaces, GNOME/libadwaita CSD headerbar apps (so they don't get double bars), and Picture-in-Picture. Match the existing `rules.lua` idiom.

### 3. Minimize

- Vendor `scripts/window-minimize` (omarchy approach from task 1) and wire it in `hyprland/default.nix` like the sibling scripts. Bind **`Super+Alt+M`** = restore-last-minimized. (Taskbar-click restore is Stage 3 — keybind only now.) Set `misc:close_special_on_empty = 1` in `general.lua` if not present.

### 4. Focus policy (in `input.lua`)

- `follow_mouse = 0` (click-to-focus — kills the hover-mistarget bug), `focus_on_close = 2`, `misc:focus_on_activate = true` (misc goes in the appropriate config block — read where `misc` is set today).

### 5. Move / resize / snap

- Title-bar drag with no modifier is hyprbars' `MBIND_MOVE` (verify it's on by default in this hyprbars version; if a config knob exists, set it). Keep the existing `Super+mouse:272/273` move/resize binds.
- `general.snap { enabled = true }` (floating magnetism) in `general.lua`.
- Keybinds: `Super+Ctrl+Left/Right/Up/Down` = half-snaps via the pixel dispatcher (`resizewindowpixel "exact 50% 100%"` etc. — the Lua resize API is pixels-only; use the legacy-string form that works in 0.55, verified against a working bind). `Super+Up` (or keep `Super+F`) = maximize toggle — reconcile with the existing `Super+F` maximize bind, don't create a conflict; report your final mapping.

### 6. Workspaces 1–5

- `rules.lua`: extend the persistent workspace rules from 1–2 to **1–5** on `eDP-1` (workspace 1 stays default).
- `keybinds.lua`: extend the `for workspace = 1, 2` focus/move loops to `1, 5`.

### 7. Third-window-closes note

No code — in your report, confirm the mechanism is structurally gone (Waybar retired, launches detached, shell `KillMode=process`) and that a post-deploy repro attempt is a PM gate step.

## Final report (raw data)

- Task-1 investigation map: Lua deploy mechanism, the exact plugin-load call + templated store path you used, the hyprbars Lua config/button form, the minimize approach + source, and the current-binds survey.
- Every edited/created file with its quoted diff (small, `Aurora:`-marked). Quote the full `window-minimize` script.
- Your final keybind mapping (close/max/min, snap, maximize, workspaces) as a table, and any conflict you had to resolve.
- Anything you interpreted, deviated on, or couldn't complete — plainly.
