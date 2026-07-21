# Window Management, Input & Gestures — Full Research

**Session:** L1 Session 3 (Window Management, Input & Gestures). **Output owner:** the window/input interaction model.
**Target:** NixOS 26.11 + Hyprland 0.55 (**native Lua config** — hyprlang deprecated since 0.55) + QuickShell, 2020 T2 MacBook Air (Intel i3 dual-core, Iris Plus, 8 GB; Apple keyboard Cmd=Super; libinput touchpad with **working tap-to-click + two-finger scroll that must not regress**; single display).
**Scope covered:** §4.15 per-window controls · Focus policy (§5 hover-focus bug) · §4.16 window move/snap/drag(-to-workspace) · §4.8 gestures (4-finger + pinch) · open Category-F input/window bugs.
**Rules honored:** community-sourced (no from-scratch); full reads; previews VIEWED before ranking; multi-candidate; licensing never a factor; no execution/diagnostics — every empirical before/after is flagged as **[LIVE-TEST @ execution]**.

> **A note on the big picture.** The whole window/input model here is *achievable with the stack already chosen*, and it lands very close to Windows/macOS muscle memory (§2). The spine is: **hyprbars** (official plugin) for per-window titlebar buttons + modifier-free drag, a **click-to-focus** policy (`follow_mouse = 0`) that kills the hover-focus bug, **native Hyprland 0.55 Lua gestures** (which now include pinch-to-zoom — previously thought unsourced), and **DankMaterialShell's real drag-window-onto-workspace** implementation as the concrete source for the bar drag-target. Almost nothing here is bespoke; the only genuinely bespoke pieces are small glue (a minimize script — already community-sourced from omarchy — and moving DMS's drop-target from an overview grid onto the bar's workspace buttons).

---

## 0. Requirement → solution map (one-glance)

| Requirement | Solution | Source | Confidence |
|---|---|---|---|
| §4.15 per-window min/max/close on every window | **hyprbars** plugin (Lua-native config) | hyprwm/hyprland-plugins · omarchy-desktop-shell | SOURCED + preview VIEWED |
| §4.15 minimize semantics | **per-window special workspace** (`special:min-<addr>`) via a small script | omarchy `window-minimize` (bug-fixed) | SOURCED (small glue) |
| §5 hover-focus mis-targeting | `follow_mouse = 0` (click-to-focus) + per-window buttons remove the bar-travel entirely | Hyprland Variables wiki | SOURCED |
| §4.16 Cmd+arrows move window | `hl.dsp.window.move({ direction })` / `movewindow` | caelestia keybinds.lua | SOURCED (config) |
| §4.16 modifier-free titlebar drag | hyprbars bar is draggable to move the window (no modifier) | hyprbars | SOURCED |
| §4.16 drag window → workspace button | **DMS `OverviewWidget.qml`** DropArea + `moveToWorkspace` (real impl) → graft onto bar workspace delegate | DankMaterialShell | SOURCED impl + small glue |
| §4.16 drag-to-edge half/full snap | native `general:snap` = float magnetism only; Aero-Snap half-tiling = keybind (works) or bespoke drag-glue (unsourced) | Hyprland wiki + source (PR #8088) | PARTIAL — see §3.2 |
| §4.8 3-finger workspace swipe (keep) | native `hl.gesture(horizontal, workspace)` | Gestures wiki · caelestia | SOURCED |
| §4.8 4-finger map | native `hl.gesture` (fingers=4) — conflict resolved below | Gestures wiki · caelestia | SOURCED |
| §4.8 pinch-to-zoom | **native** `hl.gesture(pinch, cursor_zoom, mode="live")` | Gestures wiki (0.55) | SOURCED (was "unsourced everywhere") |
| §5 disable_while_typing | **libinput keyboard↔touchpad pairing** via a quirks override (`AttrKeyboardIntegration=internal`) — DWT is a no-op until paired | linuxtouchpad.org · who-t · omarchy #1273 | SOURCED — see §5.1 |
| §5 backspace repeat too fast | `repeat_rate ≈ 22–25` / `repeat_delay ≈ 300–400` (accel impossible — proven via wl_keyboard) | Hyprland wiki · Wayland protocol | SOURCED — see §5.2 |
| §5 scroll speed inconsistent | `scroll_factor` global (0.3 ok) + Chrome `#smooth-scrolling` Disabled; no per-app factor exists | Hyprland wiki · Chromium #1811219 | SOURCED/PARTIAL — see §5.3 |
| §5 corner-resize one-directional | dwindle tiling behavior; free-corner resize is a *floating* property; pseudotile for symmetric | Dwindle wiki · Arch #308369 | SOURCED — see §5.4 |
| §5 3rd-window resizes/closes another | resize=expected dwindle; close=process death (Waybar-cgroup/OOM theory; Waybar now removed) — re-verify | GAP_REVIEW B13/F | PARTIAL — see §5.5 |

---

## 1. PER-WINDOW CONTROLS (§4.15) — comparison + ranking

**Requirement restated.** Min/Max/Close on EVERY window, not only in the bar. Redundancy is fine; user choice is the point. Hover-reveal at window top is *acceptable* (not required — a persistent titlebar is fine, arguably better). Traveling to the bar for every close is tedious; hover-follows-focus makes it error-prone. Minimize "may map to a special workspace."

### 1.1 The candidate field (multi-candidate, no first-match)

I confirmed the full official Hyprland plugin inventory (hypr.land/plugins). **hyprbars is the only plugin that draws titlebars/window buttons.** Borders++ and Image-borders are border *aesthetics* (no buttons); Hyprtrails is motion; the overview plugins (hyprexpo/hyprspace/hymission/gloview) don't put controls on windows. So the real candidates are:

| # | Candidate | What it is | Sourced? |
|---|---|---|---|
| **A** | **hyprbars** (official plugin) | Server-side titlebar per window with clickable buttons; draggable to move | YES — maintained, packaged for 0.55 |
| B | QuickShell-drawn per-window control overlay | A shell layer that tracks each window's rect and floats buttons over its top | **NO community impl** — bespoke, and fights QuickShell's model |
| C | Client-side decorations (CSD) | Let apps draw their own headerbar close buttons (GTK/libadwaita) | Partial/native but **inconsistent across apps** |
| D | Bar-only controls (status quo) | Controls live in the top bar / a window-info popout | The thing the user rejected as "tedious travel" |

### 1.2 hyprbars — CURRENT STATE re-evaluation (it was deferred over bugs)

**Preview VIEWED** (official README image, `hyprland-plugins/hyprbars`): two windows (a Files manager and Google Chrome), **each** carrying a clean macOS-style titlebar — three circular "traffic-light" buttons top-left (red close / yellow / green), centered title text, and **rounded top corners that match the window rounding**. The bar color adapts light/dark per window. It reads as native and tasteful, not bolted-on. This is a strong direct match for "min/max/close on every window."

**Config is Lua-native — directly compatible with the target's Lua Hyprland config** (this is important; it is *not* a hyprlang-only plugin):

```lua
hl.config({
  plugin = {
    hyprbars = {
      bar_height   = 28,
      bar_padding  = 10,
      bar_button_padding = 8,
      bar_text_size = 11,
      bar_text_font = "JetBrainsMono Nerd Font",   -- target uses FiraCode NF / Nerd Font — has glyphs
      bar_text_align = "left",
      bar_part_of_window = true,          -- bar counts as part of window → shadows/rounding wrap it
      bar_precedence_over_border = true,  -- border wraps the bar (cleaner corners)
      on_double_click = "hyprctl dispatch fullscreen 1",
    },
  },
})
-- buttons via the Lua button API (right → left on screen):
hl.plugin.hyprbars.add_button({ bg_color="rgb(6cc06a)", fg_color="rgb(000000)", size=16, icon="◇", action="hyprctl dispatch fullscreen 1" })      -- maximize/restore
hl.plugin.hyprbars.add_button({ bg_color="rgb(c9c24f)", fg_color="rgb(000000)", size=16, icon="⌄", action="~/.local/bin/window-minimize" })        -- minimize (see 1.4)
hl.plugin.hyprbars.add_button({ bg_color="rgb(d35f5f)", fg_color="rgb(000000)", size=16, icon="✗", action="hyprctl dispatch killactive" })          -- close
```

(hyprlang form is `hyprbars-button = bgcolor, size, icon, on-click, fgcolor` inside `plugin { hyprbars { } }` — but the target is Lua, so use the `hl.plugin.hyprbars.add_button` API above. Both are documented in the hyprbars README.) Config values above are lifted from **OnlyLyan/omarchy-desktop-shell** (`05-hyprbars-titlebar/files/hyprbars.conf`), a Windows/macOS-style Hyprland shell that pairs a QuickShell bar with hyprbars — i.e. the exact pairing this build wants.

**Config options** (full list, from README): `enabled, bar_color, bar_height (def 15), bar_blur (needs global blur), col.text, bar_title_enabled, bar_text_size (10), bar_text_weight (400), bar_text_font (Sans), bar_text_align (center), bar_buttons_alignment (right), bar_part_of_window, bar_precedence_over_border, bar_padding (7), bar_button_padding (5), icon_on_hover (false), inactive_button_color, on_double_click`. Per-window overrides via dynamic window rules: `hyprbars:no_bar`, `hyprbars:bar_color`, `hyprbars:title_color`.

**"icon_on_hover = true"** gives the hover-reveal behavior §4.15 mentions (buttons appear only on hover) while the slim bar stays — but a **persistent** macOS-style bar (icon_on_hover=false) is the better default: zero-travel close, always-visible, matches macOS. Redundancy with the bar's own controls is explicitly fine per §4.15.

**Confirmed working on Hyprland 0.55.** Direct evidence: hyprbars issue #675 was filed by a user actively running it on `Hyprland 0.55.2` (their pasted `--version`, dated May 2026). The plugin builds and runs on the target compositor version.

**The historical/current bugs — characterized precisely** (issue threads read, not just titles; primary source incl. `barDeco.cpp`):

| Issue | State | What it is | Root class | Applies to this build? |
|---|---|---|---|---|
| #634 (Mar 2026) | open | After a Hyprland update, bars unresponsive (can't move/click) — Arch | **ABI/hyprpm version mismatch** (stale plugin vs new compositor) | **NO — structurally prevented** (pinned flake, below) |
| #635 (Mar 2026) | open | Buttons visible but not responding to clicks, on **0.54.2** | interaction regression on a specific 0.54.x point release | **Live-test on the pinned 0.55 build** — not confirmed intrinsic to 0.55 |
| #643 (Apr 2026) | open | Pointer events pass **through the bar** to underlying **XWayland** windows | XWayland input passthrough | Minor — affects XWayland apps; [LIVE-TEST] |
| #655 | open | Doesn't respect **CSD** requests → **double titlebar** on apps that draw their own | CSD/SSD negotiation | Handle with `hyprbars:no_bar` rules on GNOME/CSD apps (see 1.3-C) |
| #355 | open | `general:resize_on_border` doesn't work when hyprbars enabled | border-resize interaction | Minor — end-4 uses resize_on_border; note the trade-off |
| #283 (Jan 2025) | closed | Buttons functional but **not rendered** — empty icon field | **missing Nerd-Font glyph** | NO — use a font with the glyph (FiraCode/JetBrainsMono NF) or text |
| #128 | open | Rounding "not correct" — values below ~10 misalign | bar-vs-window rounding | Minor — target rounding **15**; `bar_precedence_over_border=true`; [LIVE-TEST] |
| #675 | open | Text size differs across monitors with different scale | multi-monitor double-scale | **N/A — single display** |
| #627 / #576 | open | Build / Nix-flake build failure | toolchain/version-specific | Mitigated by pinning plugin to matching Hyprland rev |
| #203 / #318 / #215 | open | Crash/glitch when combined with hyprtrails / hyprexpo / borders-plus-plus | plugin-interaction | N/A — we don't run those alongside it |

The one that would sink it — "clicks completely dead" (#634/#635) — is reported against **Arch/hyprpm on 0.54.x updates**, i.e. the ABI-desync class, **not** confirmed as an intrinsic 0.55 defect. It must be validated on the actual pinned build [LIVE-TEST @ execution], but the structural reason it shouldn't recur is below.

**Why the #634-class ABI bug is structurally eliminated on NixOS.** On Arch/hyprpm, updating Hyprland leaves the compiled plugin stale until you `hyprpm update` against the new headers — that mismatch is what breaks buttons/interaction. On NixOS you **do not use hyprpm**; hyprbars is loaded declaratively from the `hyprwm/hyprland-plugins` flake with `hyprland-plugins.inputs.hyprland.follows = "hyprland"`, so the plugin is *always* built against the exact compositor revision in the same `nixos-rebuild`. The version-lockstep failure mode simply cannot desync. Declarative load:

```nix
# home-manager
wayland.windowManager.hyprland.plugins = [
  inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
];
```

**Verdict on the deferral:** the deferral was reasonable *at the time and on a rolling distro*, but the two dominant failure modes are (a) ABI desync — structurally prevented by the pinned Nix flake — and (b) a font glyph choice. Neither is a design flaw. **hyprbars is usable today on this build.** Remaining genuine caveats: it draws a real bar that reserves ~24–28 px at the top of each window (client area shrinks — expected for titlebars); rounding interaction with the target's rounding=15 wants a live check; and CSD apps (see 1.3-C) can double-up a headerbar — handle with `hyprbars:no_bar` rules where needed. All [LIVE-TEST @ execution].

### 1.3 Why B, C, D lose

- **B — QuickShell per-window overlay: no community implementation exists, and it fights the framework.** QuickShell's `PanelWindow` is a Wayland *layer-shell* surface that docks to screen edges and reserves space — it is built for shell chrome, not for floating a widget precisely over an arbitrary *client* window and following it through moves/animations/workspace changes/z-order. Every QuickShell shell I've read (caelestia, iNiR, DMS) puts window controls in the **bar or an overview**, never as a per-window hovering overlay. caelestia's `modules/windowinfo/Buttons.qml` is the closest — but it's a **bar popout** (Move-to-workspace grid + Float/Tile/Pin/Kill), not an overlay on the window itself. Building B would be bespoke, brittle, and exactly the from-scratch UI §1.2 prohibits. **Rejected** — but its dispatch shapes are reused (see 1.5).
- **C — CSD (client-side decorations): inconsistent, can't be universal.** GTK/libadwaita apps (Nautilus, GNOME Settings) draw their own headerbar with a close button; but Kitty, Chrome (Wayland), Qt apps, and XWayland apps vary — some draw nothing, some draw a different style. You cannot get a *consistent* close button on *every* window from CSD, and the mix breaks §3 cohesion. CSD is also why hyprbars can visually double-up on GNOME apps (noted above). **Rejected as the universal answer**; relevant only as the reason for a few `hyprbars:no_bar` rules.
- **D — bar-only controls: the rejected status quo.** This is what the user has now ("traveling to the top of the screen for every close is tedious"). Keep the bar's right-click-close on running tasks as *redundancy* (§2), but it cannot be the only path.

### 1.4 Minimize semantics — the real gotcha, already solved

Hyprland has **no native minimize**. The community pattern is "move to a hidden special workspace," but the naive version has a real bug — and the fix is sourced.

> **Why the naive one-liner isn't enough (contested-claim note).** The obvious hyprbars minimize button `hyprctl dispatch movetoworkspacesilent special:minimized` was reported broken around 0.54 ([Hyprland discussion #13703](https://github.com/hyprwm/Hyprland/discussions/13703), "…example from wiki no longer works in 0.54"; resolution not read — flag [LIVE-TEST]). Independently of that regression, a *single shared* `special:minimized` has the dump-all-windows bug below. Both problems are avoided by the omarchy per-window-special script — which is dated 2026-06-25 (post-0.54) and is a *working current* implementation, so it supersedes the naive wiki example. Use the script as the button's action, not the raw dispatch.

**Source: omarchy-desktop-shell `window-minimize` (bash, jq; bug-fixed 2026-06-25).** The naive approach (move all minimized windows to one `special:minimized`) breaks: when *any* window in a special workspace gets focus (alt+tab / `activate` / focuswindow), the special becomes **visible and dumps ALL its windows onto the focused monitor**. The proven fix:

- Give **each** minimized window its **own** special workspace: `special:min-<address>`. Focusing one reveals only that one.
- Always `movetoworkspacesilent` (never `togglespecialworkspace`) so the special is never revealed.
- Set `misc:close_special_on_empty = 1` (destroy the empty special on restore).
- Track a LIFO store (`/tmp/minimized-windows`: `<address> <ws_origin> <monitorID>`), reconciled against live `hyprctl clients` each op (auto-prunes ghosts). `restore` returns the last-minimized window to its origin workspace/monitor.

Wire-up: the hyprbars minimize button calls `window-minimize` (minimize); restore on a keybind **and** a mouse-reachable control (§2 redundancy):

```lua
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("~/.local/bin/window-minimize restore"))
```

This is ~60 lines of already-written community glue, not from-scratch. **Mouse equivalents (§2):** minimize = the yellow hyprbars button; restore = a bar affordance (e.g. clicking a running-task icon that is currently minimized restores it — the bar taskbar already knows the toplevel; on click, if its workspace name starts `special:min`, call `window-minimize restore` / `movetoworkspace` the window back). That bar-restore is small glue on top of the QuickShell taskbar the build already plans.

> **Alternative worth a plan-time note:** if per-window special workspaces feel heavy, "minimize" could instead mean **scratchpad-style** hide to one `special:minimized` *with* the single-window-reveal caveat accepted, or simply *not shipping minimize* and relying on the taskbar (click-to-hide/show) — but the omarchy per-window-special approach is the honest "real minimize" and is already solved, so it's the recommendation.

### 1.5 Reusable dispatch shapes (from caelestia `windowinfo/Buttons.qml`)

Even though caelestia's window-info is a bar popout (not the chosen per-window solution), it is the verified **Lua-aware dispatch reference** for any window-control button (hyprbars actions, bar taskbar context menu, or a restore control). Note the `Hypr.usingLua` branch — the build is Lua, so use the first form:

```js
// move to workspace N:  hl.dsp.window.move({ window = "address:0x<addr>", workspace = "<N>", follow = true })
// float/tile:           hl.dsp.window.float({ window = "address:0x<addr>" })
// pin/unpin:            hl.dsp.window.pin({ window = "address:0x<addr>" })
// close:                hl.dsp.window.kill({ window = "address:0x<addr>" })
```

### 1.6 Ranking

1. **hyprbars** — the only sourced, maintained, preview-verified per-window titlebar; Lua-native config; modifier-free drag-to-move (see §4); ABI risk structurally removed by the Nix flake; minimize solved via omarchy script. **Chosen.**
2. **CSD (C)** — used only as a supplement (a few `hyprbars:no_bar` rules on GNOME apps that already have a good headerbar). Not a standalone answer.
3. **Bar-only (D)** — kept purely as redundancy (right-click-close on taskbar tasks), never the only path.
4. **QuickShell overlay (B)** — rejected: no community implementation, bespoke, fights QuickShell's layer model. Would violate the no-from-scratch rule.

---

## 2. FOCUS POLICY (§5 hover-focus bug)

**Bug.** "Hover-based focus makes targeting the bar's close button error-prone — must avoid hovering other windows en route." Root cause: Hyprland default `input:follow_mouse = 1` = **sloppy focus** (cursor movement always refocuses the window under it), so any window you pass over on the way to a target steals focus.

**Authoritative `follow_mouse` semantics (Hyprland Variables wiki, verbatim):**
- `0` — Cursor movement will **not** change focus.
- `1` — Cursor movement will **always** change focus to the window under the cursor. *(default; the bug)*
- `2` — Cursor focus **detached** from keyboard focus. Clicking a window moves keyboard focus to it.
- `3` — Cursor focus completely separate; clicking does **not** change keyboard focus.

**Recommendation: `follow_mouse = 0` (click-to-focus).** This is the Windows/macOS model (§2 "muscle memory respected"): moving the cursor across windows never changes focus, so reaching the bar or a per-window button never mis-focuses anything. It composes perfectly with per-window hyprbars buttons — the user no longer *travels to the bar* at all, and even when they do, the trip is focus-safe. This single line resolves the bug.

Supporting settings (sourced from Hyprland Variables wiki; caelestia values cross-referenced):

```lua
hl.config({
  input = {
    follow_mouse   = 0,   -- click-to-focus (fixes the hover mis-target bug)
    focus_on_close = 2,   -- on close, focus the most-recently-used window (macOS-like), NOT whatever is under the cursor
  },
  misc = {
    focus_on_activate = true,  -- launched/activating apps get focus (mouse-first launch flow); caelestia sets this
  },
})
```

- `focus_on_close = 2` (most-recently-active) suits click-to-focus better than caelestia's `1` (under-cursor), which could focus a random window the cursor happens to rest on after a close.
- `focus_on_activate = true` keeps the "click a launcher/taskbar icon → the app comes to focus" behavior intuitive (caelestia uses it).

**Documented alternative if the user wants hover-scroll of unfocused windows:** `follow_mouse = 2` (keyboard focus only changes on click, but the hovered window still receives scroll/mouse events). Slightly more surprising than `0`; offer it as a toggle in Settings › Input (B7). `follow_mouse_shrink` / `follow_mouse_threshold` / `mouse_refocus=false` only matter under `follow_mouse=1` and are moot once we pick `0`.

**Every choice here is a one-line config with an obvious before/after** — pick `0`, then [LIVE-TEST @ execution] whether the user prefers `0` vs `2`.

---

## 3. WINDOW MOVEMENT & SNAPPING (§4.16)

### 3.1 Cmd+arrows to move windows (config — trivial, sourced)

The build's Apple keyboard maps Cmd→Super. Directional move and workspace move are plain dispatchers, all verified against a **real 0.55 Lua config** (end-4 `keybinds.lua`) and the Dispatchers wiki:

```lua
-- move active window in a direction (tiling swap / floating nudge). Direction tokens are l/r/u/d.
hl.bind("SUPER + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))
-- move active window to workspace N (Cmd+number pattern); follow=false = old movetoworkspacesilent (stay), follow=true = follow the window
-- for i=1..10: hl.bind("SUPER + ALT + "..key, hl.dsp.window.move({ workspace = i, follow = false }))
-- move to adjacent workspace ON THE CURRENT MONITOR (r±N includes empty); plain +1/-1 is the global-relative form
hl.bind("SUPER + ALT + Page_Up",   hl.dsp.window.move({ workspace = "r-1" }), { repeating = true })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "r+1" }), { repeating = true })
-- to/from scratchpad special workspace
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }))
```

> **Note on exact keymap:** caelestia binds *plain* `SUPER+arrows` to **focus** and `SUPER+SHIFT+arrows` to **move**. The build should pick the arrow map deliberately in the plan (the user asked for "Cmd+arrows to move windows"); if plain Cmd+arrows should *move*, remap focus elsewhere. This is a config decision, not a research gap. Every move action also has a **mouse** path (drag — see 3.3/3.4) per §2.

### 3.2 Drag-to-edge half/full snapping — HONEST status (primary-source confirmed)

This is the one area where the answer is "partly native, partly glue." Confirmed against the Hyprland wiki markdown source, Hyprland C++ source, and a real 0.55 config on disk (end-4).

- **Native `snap` is FLOAT-ONLY proximity magnetism, NOT Aero-Snap.** Hyprland's built-in `snap` (added 0.45, [PR #8088](https://github.com/hyprwm/Hyprland/pull/8088)) makes **floating** windows magnetically stick to monitor edges and to other windows *while you drag/resize* — it does **not** resize a window to half/full on edge contact. PR author, verbatim: *"While moving and resizing floating windows, edges and corners will snap to the edges/corners of the monitor or other windows when they get close enough."* Options (under `general:snap`, verbatim from Variables wiki; real end-4 values in parens):
  | option | meaning | default |
  |---|---|---|
  | `enabled` | enable snapping for floating windows | `false` (end-4: `true`) |
  | `window_gap` | min gap px between windows before snapping | `10` (end-4: `4`) |
  | `monitor_gap` | min gap px between window and monitor edge before snapping | `10` (end-4: `5`) |
  | `border_overlap` | snap so only one border's space is between windows | `false` |
  | `respect_gaps` | snapping respects `general:gaps_in` | `false` (end-4: `true`) |
  Ship this (`general:snap { enabled = true }`) for nicer floating-window behavior — free, native, cheap.
- **Aero-Snap half/full-tiling on drag-to-edge is NOT-SOLVED** — no native feature, **no plugin**, and **not present in ANY of the 25+ reference repos** (caelestia, iNiR, DMS, end-4, saatvik333, ilyamiro, glassesarch, … all checked). Every config that does "half-ish" resizing uses **keybind-driven** `resizeactive`, never drag-to-edge. So this splits into two honest deliverables:
  1. **Keybind half/full snap (fully sourced, works today):**
     > **Critical syntax caveat (confirmed from Hyprland source `LuaBindingsDispatchers.cpp`):** the Lua `hl.dsp.window.resize({ x, y })` accepts **numeric PIXELS only** — no `"50%"` strings, no `exact` keyword. **Percent snapping must go through the legacy string dispatchers**, which are still registered in 0.55 (verified in `KeybindManager.cpp`). This is exactly what hyprbars itself does internally (`setfloating` → `resizewindowpixel "exact 50% 50%"` → `movewindowpixel`).
     ```lua
     -- left-half snap (float + percent-resize + reposition, via legacy string dispatchers)
     hl.bind("SUPER + CTRL + Left", function()
       hl.dispatch(hl.dsp.window.float({ action = "enable" }))
       hl.dispatch(hl.dsp.exec_cmd('hyprctl dispatch resizewindowpixel "exact 50% 100%,activewindow"'))
       hl.dispatch(hl.dsp.exec_cmd('hyprctl dispatch movewindowpixel  "exact 0 0,activewindow"'))
     end)
     -- full-screen is native and simple:
     hl.bind("SUPER + Up", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
     ```
     caelestia also ships `fn.resize_by_screen(55, 70)` + `window.center()` for a centered floater; same mechanism, different fractions. This is the **mouse-free** half/full snap and is done.
  2. **True drag-to-edge half-snap (bespoke glue, no community drop-in):** would need an external helper subscribed to Hyprland's socket2 events that, on drag-end, reads `hyprctl cursorpos` and, if within N px of an edge, dispatches the float+resize+move above. **No community implementation exists to adapt** — flag as *build-it-yourself development*, optional polish on top of the keybind snap. Not required for §4.16 (the drag requirement is satisfied by titlebar-drag §3.3 and drag-to-workspace §3.4).
- **For tiled windows**, "snapping" is inherent — dwindle already tiles to fill; Aero-Snap is mainly a *floating*-window nicety. **Recommendation:** ship `general:snap` (floating magnetism) + keybind half/full snap now; treat drag-to-edge as optional bespoke glue for the plan, and expose the keybind snaps with mouse-redundant equivalents (a bar/window-menu "tile left/right/max" action reusing the same dispatch).

### 3.3 Modifier-free titlebar dragging (grab the bar like Windows) — SOURCED via hyprbars

Today the build (like caelestia) uses `SUPER + mouse:272 → window.drag()` — hold Cmd and drag anywhere. The user wants to **grab a titlebar with no modifier**. **hyprbars provides exactly this — confirmed from source.** Reading hyprbars' `barDeco.cpp` input path: pressing inside the bar rect sets a pending drag (`handleDownEvent` → `m_bDragPending = true`); on mouse-move it calls `handleMovement()` which invokes `g_pKeybindManager->changeMouseBindMode(MBIND_MOVE)` — i.e. it starts Hyprland's normal interactive window-move (the same action as Super+drag), triggered purely by pressing on the bar, no modifier. This is the community-standard answer to the long-standing requests [Hyprland#3014](https://github.com/hyprwm/Hyprland/issues/3014) ("drag windows by the header bar without a modifier") and [#954](https://github.com/hyprwm/Hyprland/issues/954). So adopting hyprbars simultaneously delivers §4.15 buttons *and* §4.16 modifier-free move. Keep `SUPER+drag` as redundancy for the window body (`hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })`).

### 3.4 Drag a window ONTO a workspace button (the marquee interaction) — REAL impl found

The brief said the iNiR `BarModuleOrderEditor` DropArea is "a pattern, not an implementation," and to find the real dragged-window→workspace approach. **I found a real one: DankMaterialShell `Modules/WorkspaceOverlays/OverviewWidget.qml`.** It implements drag-a-window-tile-onto-a-workspace-tile end-to-end. The mechanism (verbatim structure):

- Each **workspace cell** hosts a `DropArea` whose `onEntered`/`onExited` set `root.draggingTargetWorkspace` and toggle a hover highlight (`hoveredWhileDragging`).
- Each **window** is a draggable `Item` with `Drag.hotSpot`, wrapped in a `MouseArea` with `drag.target: parent`. `onPressed` sets `draggingFromWorkspace`, `Drag.active = true`, `Drag.source = window`. `onReleased` reads `draggingTargetWorkspace` and, if valid and different, calls `HyprlandService.moveToWorkspace(targetWorkspace, windowData.address, false)`, then `Qt.callLater` refreshes toplevels/workspaces and snaps the tile home.
- `HyprlandService.moveToWorkspace` dispatches (Lua-aware, matching caelestia):
  ```js
  Hyprland.dispatch(`hl.dsp.window.move({ workspace = ${luaValue(ws)}, window = ${luaString(selector)}, follow = ${follow} })`)
  // (hyprlang fallback: movetoworkspace / movetoworkspacesilent)
  ```

**This is the whole payload+drop+dispatch chain the build needs.** DMS proves it as an **overview grid** (drag window tile → workspace tile). The build wants the drop target to be the **bar's workspace buttons** and the drag source to be the **bar's running-task icons**. That is a *graft*, not a rebuild: put a `DropArea` on each workspace delegate in the QuickShell bar (as DMS does on its cells), make the bar's task icons `Drag`-sources carrying the window address (as DMS does on its window tiles), and on drop call the same `hl.dsp.window.move({ workspace, window="address:0x…", follow=false })`. The iNiR `BarModuleOrderEditor` remains a useful **DropArea-ergonomics** reference (insertion markers, lifted drag item, cross-zone `onDropped` → `_commitDrop`), but DMS supplies the actual window→workspace semantics. iNiR's own bar `Workspaces.qml` does **not** accept window drops (confirmed — matches iNiR.md's stated gap), so DMS is the donor.

**Effort:** small glue (move DMS's proven drop logic from an overview grid onto the bar delegate). **Mouse-first ✓** (§2/§4.16 "drag onto workspace buttons"). Keyboard redundancy = the Cmd+number move binds (3.1).

---

## 4. GESTURES (§4.8) — 4-finger map + pinch, conflict resolved

**Big finding: pinch-to-zoom is NOT unsourced — it's a first-class native Hyprland 0.55 gesture action.** The GAP_REVIEW listed pinch as "research — unsourced everywhere." Hyprland 0.51 reworked gestures into a fully general engine (removing the old `gestures:workspace_swipe*` options), and 0.55 expresses it in **Lua** — exactly the target's config language. The authoritative Gestures wiki gives the complete grammar.

### 4.1 Native gesture grammar (Hyprland 0.55 Lua — verbatim from wiki)

```lua
hl.gesture({ fingers = <2–9>, direction = <dir>, action = <action>, [mods=], [scale=], [<action args>] })
```

- **Directions:** `swipe` (any), `horizontal`, `vertical`, `left`/`right`/`up`/`down`, `pinch` (any), `pinchin`, `pinchout`.
- **Actions:** a *Lua function/lambda* · `workspace` (workspace swipe) · `move` (move active window) · `resize` · `special` (arg `workspace_name`) · `close` · `fullscreen` (arg `mode="maximize"`) · `float` (arg `mode="float"|"tile"`) · **`cursor_zoom`** (args `zoom_level`, `mode="mult"|"live"`) · `scroll_move` (scrolling layout only). `unset` removes a previously-set gesture.
- **Fields:** `fingers` (2–9), `mods` (e.g. `"SUPER"`, `"ALT SHIFT"`), `scale` (delta multiplier), `disable_inhibit` (bypass shortcut inhibitors). **Live gestures**: pass a table with `start`/`update`/`finish` methods (each gets `{type, time_ms, fingers, delta.x/y, scale, rotation}`) for continuous, reactive gestures (e.g. volume/brightness that track the swipe).

### 4.2 PINCH-to-zoom — sourced (native)

```lua
-- pinch to toggle a cursor magnifier (compositor-level zoom, always-consistent):
hl.gesture({ fingers = 2, direction = "pinch", action = "cursor_zoom", zoom_level = 2 })
-- OR live/continuous magnifier tracking the pinch, anchored to the cursor:
hl.gesture({ fingers = 2, direction = "pinch", action = "cursor_zoom", zoom_level = 1, mode = "live" })
```

**Critical distinction to set expectations:** native `cursor_zoom` is a **compositor magnifier** (zooms the whole screen around the cursor) — this is the *consistent, always-works* pinch behavior that fixes "pinch-to-zoom is app-dependent and hit-or-miss": the compositor gives a deterministic zoom on every app. It is **not** in-app content zoom (zooming a webpage/image within the app). If the user also wants **Chrome page pinch-zoom**, that's app-level and separate — enable it via Chrome's Ozone/Wayland touchpad flags (pairs with the C16a two-finger-back/forward flag; confirm the exact flag in the parallel input pass). Recommendation: ship **native `cursor_zoom` live** as the system pinch (magnifier), and enable Chrome's own pinch flag for in-page zoom — the two coexist. Mouse equivalent for the magnifier (§2): a Settings/System toggle + a hotkey (`SUPER + =`/`SUPER + -` to zoom via `cursor_zoom`), so pinch is never the only path.

> Wiki nuance: the actions table names the action `cursor_zoom`; the inline examples write `cursorZoom`. Treat them as the same action and confirm the accepted spelling [LIVE-TEST @ execution] — the target's Lua parser (caelestia's `hl.*` binding layer) will reveal which token it accepts.

### 4.3 4-finger map + resolving caelestia's workspace-vs-sleep conflict

**caelestia `gestures.lua` (the sourced syntax/action reference) does this** (`variables.lua`: `workspaceSwipeFingers=4`, `gestureFingers=3`, `gestureFingersMore=4`):

```lua
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })                 -- 4-finger = workspace
hl.gesture({ fingers = 3, direction = "up",   action = "special", workspace_name = "special" })
hl.gesture({ fingers = 3, direction = "down", action = fn -> "caelestia toggle specialws" })
hl.gesture({ fingers = 4, direction = "down", action = fn -> systemctl suspend-then-hibernate })  -- 4-finger down = SLEEP
```

**The conflict** the brief flags: caelestia puts **workspace switching on 4 fingers** *and* **sleep on a 4-finger-down swipe**. Two problems for this build: (1) the target's **working** gesture is **3-finger** horizontal workspace swipe (§4.8/§11 — must keep), so workspace must live on 3, not 4; and (2) **sleep-on-a-swipe is dangerous** — an accidental 4-finger-down suspending the laptop mid-work is precisely the surprising, un-asked-for behavior §2 forbids. Sleep belongs on a deliberate control (the Session/power menu button), never a swipe.

**Resolved gesture map for this build** (3-finger workspace preserved; 4-finger becomes a safe, useful set; every action has a mouse path):

```lua
-- 3 fingers: keep the working workspace swipe (§11 do-not-regress)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
-- 3 fingers vertical: reactive volume (live) — mouse path: bar volume slider / OSD
hl.gesture({ fingers = 3, direction = "vertical", action = {
  start  = function(e) volume(-0.25 * e.delta.y) end,
  update = function(e) volume(-0.25 * e.delta.y) end } })          -- pattern straight from the Gestures wiki
-- 4 fingers up: open the overview / expo (mouse path: Apps button / bar) -- action = special or a toggle to the QS overview
hl.gesture({ fingers = 4, direction = "up",   action = function() hl.dsp.global("<shell>:overview") end })
-- 4 fingers down: show desktop / minimize-all OR special:special toggle (mouse path: bar button)
hl.gesture({ fingers = 4, direction = "down", action = "special", workspace_name = "special" })
-- pinch: cursor magnifier (mouse path: Settings toggle + SUPER +/-)
hl.gesture({ fingers = 2, direction = "pinch", action = "cursor_zoom", zoom_level = 1, mode = "live" })
```

- **Sleep is removed from gestures** and lives in the Session/power menu (§6) — a button, per §2. This *is* the resolution of the workspace-vs-sleep conflict: keep workspace (on 3), drop sleep-on-swipe.
- **Brightness** could mirror volume as a 4-finger vertical live gesture if wanted (same wiki pattern, `brightnessctl`), but don't overload; keep it on the OSD/keys.
- caelestia binds `binds:scroll_event_delay = 0` and `input:touchpad:natural_scroll = true` — carry both (natural scroll matches macOS muscle memory; §11 two-finger scroll must not regress — natural_scroll is a *direction* setting and doesn't affect the working scroll mechanics).

**Every gesture has a mouse-accessible equivalent** (§2): workspace = bar workspace buttons (+ drag-to-workspace, §3.4); volume = bar volume/OSD; overview = Apps/bar; special/desktop = bar button; zoom = Settings toggle + keys; sleep = Session menu.

---

## 5. OPEN INPUT/WINDOW BUGS (sourced values / repro — primary-source verified)

*(Values below are grounded against the caelestia reference config on disk and authoritative sources read in full: the Hyprland Variables + Dwindle wikis, the Wayland `wl_keyboard` protocol, libinput maintainer docs/blog, linuxtouchpad.org, the omarchy MacBook thread, and Chromium bug 1811219. Every before/after remains [LIVE-TEST @ execution].)*

### 5.1 disable_while_typing ineffective — "cursor clicks into text while typing" — **SOURCED (root cause + fix)**
- **Real cause on a MacBook (not a timeout):** libinput's DWT only activates when **either** the keyboard and touchpad are both "internal," **or** their vendor/product IDs match — *"If libinput detects neither of the above conditions, then the 'Disable While Typing' setting will do nothing"* (linuxtouchpad.org). On T2 MacBooks the Apple keyboard is frequently enumerated such that libinput treats it as **external**, so it never pairs with the touchpad → `disable_while_typing = true` is a **silent no-op** → taps land as clicks mid-type. This is a *known MacBook* symptom: omarchy discussion #1273 reports the identical *"cursor would constantly jump to other windows"* on Apple hardware.
- **The sourced fix** — force the internal keyboard to be recognized as internal via a **libinput quirks override** (`/etc/libinput/local-overrides.quirks`); this pairs the devices so DWT engages, and it does **not** touch tap-to-click or two-finger scroll (§11 preserved — DWT suppresses *only during typing bursts*):
  ```
  [MacBook Internal Keyboard]
  MatchUdevType=keyboard
  MatchBus=usb            # or spi — match the actual enumerated bus of THIS machine's keyboard
  AttrKeyboardIntegration=internal
  ```
  Hyprland needs nothing beyond `disable_while_typing = true` — it just forwards the flag to libinput. **Hyprland exposes no `dwtp`/DWT-timeout option** (the full `input:touchpad` list is `disable_while_typing, natural_scroll, scroll_factor, middle_button_emulation, tap_button_map, clickfinger_behavior, tap_to_click, drag_lock, tap_and_drag, flip_x, flip_y, drag_3fg` — no dwtp; `dwtp` is a trackpoint feature, irrelevant here). Per the libinput maintainer (who-t), once paired: *"any touch started while you were typing is permanently ignored… modifier keys are ignored for DWT, so shift-clicks work unimpeded"* — so tap-to-click during real typing is exactly what gets suppressed, which is the fix.
- **MYTH corrected (was in an earlier draft of this file):** "an external USB mouse disables DWT" is **NOT supported by any source** — libinput's "disable touchpad on external mouse" is a *separate, opt-in* send-events mode, not auto-enabled, and does not touch DWT. Do not chase it.
- **Key-remapper caveat (important if the build ever adds keyd/kanata for Cmd handling):** if a remapper injects a **virtual** keyboard, *that* virtual device — not the Apple keyboard — is what libinput must pair for DWT; a remapper's virtual keyboard is often not detected, re-breaking DWT (EndeavourOS/Toshy reports). Verify after any remapper is introduced.
- **[LIVE-TEST @ execution]:** `libinput list-devices` (is the internal keyboard present? does the touchpad list DWT?) and `sudo libinput debug-events` while typing a burst — if touchpad tap/motion events still stream during the burst, pairing is broken (apply the quirk); if suppressed, DWT already works and the stray input is coming from elsewhere (e.g. a remapper's virtual keyboard). Before/after = taps registering as clicks during a typing burst → zero touchpad events during the burst.

### 5.2 Backspace/Delete repeat too fast / not progressive — **SOURCED**
- Hyprland `input:repeat_rate` = **repeats per second** (default **25**); caelestia sets **35** → *faster than default* (this is why it feels runaway). `input:repeat_delay` = **milliseconds** (default **600**); caelestia sets **250** → a short grace period, so repeat kicks in eagerly.
- **Recommended calmer start:** `repeat_rate = 22–25`, `repeat_delay = 300–400`. Lowering **`repeat_rate`** matters most for taming held-Backspace (it sets chars/sec once repeat begins). Honest full range: rate ~15 (slow)–50 (very fast); delay ~200 (eager)–600 (default/relaxed). It's preference — expose both in **Settings › Input** (B7) as *user-tunable*, per GAP_REVIEW.
- **Progressive/accelerating repeat is impossible on Wayland — proven, not asserted.** The `wl_keyboard.repeat_info` event carries only a scalar `rate` (*"repeating keys in characters per second"*) and a scalar `delay` (*"delay in milliseconds since key down until repeating starts"*) — there is no field for an accelerating curve. Both libinput and the Wayland protocol model repeat as constant-rate. State this honestly; don't promise acceleration. (Only knobs are the two constants.)

### 5.3 Scroll speed inconsistent (fine in terminal, too fast/jumpy in Chrome) — **SOURCED (mechanism + Hyprland range + Chrome flag); PARTIAL (no clean per-app fix exists)**
- `input:touchpad:scroll_factor` (default **1.0**; caelestia **0.3**) is a **global** multiplier across all apps — tuning it for Chrome makes the terminal proportionally slower and vice-versa. **This globality IS the "inconsistent" complaint** — there is **no per-app/per-window scroll factor** on Wayland/Hyprland. Practical range ~0.1–1.0; 0.3 is already conservative. (Note: a *separate* `input:scroll_factor` exists for external mice — don't confuse the two.) Keep `binds:scroll_event_delay = 0` (caelestia) to avoid added latency.
- **Why terminal ≠ Chrome:** terminals consume scroll as **discrete line steps**; Chrome (Ozone/Wayland) consumes **high-resolution pixel-precise** axis events **and adds its own smooth-scroll momentum**, so the same swipe travels much further/jumpier. Chromium bug 1811219 (verbatim): with smooth scrolling on, *"It's having to fake the smoothness by delaying and extrapolating from mouse wheel-style tick events."*
- **The concrete Chrome-side fix:** `chrome://flags/#smooth-scrolling` → **Disabled** → restart. This removes the extrapolated momentum that makes Chrome feel fast/jumpy vs the terminal. Ships with the C16 Chrome polish pack.
- **Honest limits:** Chrome has **no scroll-speed multiplier flag** (long-requested, doesn't exist — ungoogled-chromium #2034; Firefox has `mousewheel.default.delta_multiplier_y`, Chrome has no equivalent). Hyprland's `input:emulate_discrete_scroll` (0/1/2, default 1 — *"emulates discrete scrolling from high resolution scrolling events"*) is the one lever that may pull Chrome toward terminal-like stepping; forcing `2` (all wheel events) or `0` (disable emulation) is an **[A/B LIVE-TEST]** with a device-dependent result (no source guarantees a value). The C16a `--enable-features=TouchpadOverscrollHistoryNavigation` (two-finger back/forward) is separately buggy on Wayland (action delayed until the pointer moves) — note it, adopt cautiously.
- **Bonus lead:** `hypr-kinetic-scroll` plugin (momentum touchpad scrolling, compositor-side) could give consistent macOS-like inertial scroll across all apps — see Bonus Finds; evaluate against the simpler `scroll_factor` + Chrome-flag fix.

### 5.4 Corner/border resize only one direction — **SOURCED (inherent dwindle behavior, not a fixable bug)**
- Confirmed against the Dwindle wiki (read in full) and cross-checked independently. Every tiled window is a **leaf in a binary tree**; a leaf's size on an axis is the **split ratio of the parent node splitting that axis**, clamped to **[0.1–1.9]**. Resizing doesn't freely move an edge — it adjusts a parent split ratio, so a leaf can only resize *against a sibling subtree that exists on that side*. A window on the **outer edge** of the tree has no sibling there, so dragging that corner does nothing in that direction — exactly the *"upper-right corner only goes upper-right"* symptom. **Not a Hyprland bug; only floating windows resize freely from any corner.**
- `dwindle:smart_resizing = true` (caelestia's setting; wiki: *"resizing direction will be determined by the mouse's position on the window (nearest to which corner). Else, it is based on the window's tiling position"*) decides *which* corner-direction responds — it does **not** grant free four-corner resize.
- **The honest fixes for feel:** (1) toggle `smart_resizing` on/off to change which corner-direction is honored (preference [LIVE-TEST]); (2) use **pseudotile** (`SUPER+P`) for symmetric, centered resizing of a tiled window; (3) if the user genuinely wants free any-corner resize, the window must be **floating** — say this plainly; no config value unlocks it for tiled windows (the `[0.1–1.9]` split clamp + tree topology are hard limits). **Repro [LIVE-TEST]:** 3 tiled windows → grab the outer screen-edge corner (one-directional, expected) vs the split-facing corner (normal) vs float it (free).

### 5.5 Opening a 3rd+ window resizes/closes an existing window — **PARTIAL (split the symptom)**
- **"Resizes an existing window" = normal, expected dwindle behavior** — opening a window splits the focused node so neighbors shrink (see 5.4). Not a bug; don't chase it.
- **"Closes an existing window" = the anomaly, and tiling never closes windows** — a window vanishing means **the underlying process died** (a resource/lifecycle cause, not a layout bug). No genuine 0.5x Hyprland "opening the Nth window closes another" tiling bug exists (searched; #2900 is an old 0.27 crash; #9515/#7058 are resize-cascade = the expected half).
- **Prior root-cause theory (GAP_REVIEW B13/F):** apps launched *from Waybar* become children in **Waybar's process tree / systemd cgroup**; a Waybar restart/crash/**OOM** tears down that cgroup **including the child apps** → a previously-opened window disappears. On an **8 GB dual-core** machine a 3rd heavy window can push memory over the edge and trigger the OOM cascade. **Waybar is now retired (§15)**, which removes that launcher/cgroup entirely — and QuickShell launches are **detached** (`systemd-run --user --scope` / setsid — iNiR's `ShellExec` + caelestia's detached launches are the sourced pattern), so children are insulated. *Honest caveat:* this chain rests on process-lifecycle reasoning + community reports, **not a single authoritative write-up** — treat as plausible-but-unproven until re-verified.
- **Re-verify after Waybar removal [LIVE-TEST @ execution]:** (1) reproduce by opening 3–5 windows — if nothing closes, it was Waybar (cgroup child-death or OOM source); done. (2) If a window still vanishes, distinguish: capture `hyprctl clients -j` before/after — **gone from clients AND from `ps`** = process died (then check `journalctl -k`/`dmesg` + `coredumpctl` for **OOM-killer** lines — prime suspect on 8 GB, independent of Waybar); **still in `hyprctl clients`** but ~0 px/off-screen/hidden = a real tiling artifact worth filing with a repro. (3) Launch apps under their own systemd scope (uwsm/`systemd-run`) so a shared cgroup OOM can't take neighbors with it.
- Related already-sourced (F): kitty `confirm_os_window_close = 0` (agent terminals can close themselves); detached launches so bar restarts never kill apps.

---

## 6. BONUS FINDS (flagged — nobody asked)

- **`hypr-kinetic-scroll` plugin** — momentum/inertial touchpad scrolling, compositor-side. Directly relevant to the scroll-feel bug (§5.3) and gives macOS-like flick-scroll consistency across apps. Same declarative Nix-plugin loading as hyprbars. *Evaluate at execution against the simpler `scroll_factor`+Chrome-flag fix; may make scrolling feel materially more premium.* [perf check on Iris Plus].
- **`hypr-dynamic-cursors` plugin** — cursor physics (tilt/stretch on move). Pure delight, cheap; fits the "polished, alive" §3 motion story. Optional.
- **Live-gesture volume/brightness (native, no plugin)** — the Gestures wiki's `start/update/finish` table lets a 3- or 4-finger vertical swipe adjust volume/brightness *continuously with visual feedback*. A premium, mouse-redundant touch already in the resolved map (§4.3).
- **`cursor_zoom` as an accessibility magnifier (C19)** — the same native pinch action doubles as the "look closer at this UI" tool and an accessibility zoom; expose a Settings toggle + hotkey. Zero extra mechanism.
- **hyprbars `on_double_click`** — double-clicking a titlebar to maximize/restore is free Windows/macOS muscle memory (`on_double_click = hyprctl dispatch fullscreen 1`). Already in the config above.
- **hyprbars per-window rules** (`hyprbars:no_bar`, `:bar_color`, `:title_color`) — lets special surfaces (games, PiP, the QuickShell shell) skip the bar and lets themed apps tint their bar to the palette (§3 cohesion). Ties the titlebar into the wallpaper-adaptive theming.
- **`misc:close_special_on_empty = 1`** — required by the minimize script, but also generally tidies special workspaces. Cheap correctness.
- **caelestia's `misc:animate_mouse_windowdragging = false`** — worth keeping: animating window drag on an i3/Iris Plus adds latency to the drag; off = snappier. (caelestia already disables it.)

---

## 7. WHAT I ACTUALLY READ / VIEWED vs WHAT I DIDN'T

### Read in full (local repos, on disk)
- `~/nix/MASTER_REQUIREMENTS.md` (all 15 sections) · `~/nix/research/GAP_REVIEW.md` (all, incl. Category E table + Category F) · `~/nix/research/caelestia.md` (full) · `~/nix/research/iNiR.md` (full) · `RESEARCH_SESSIONS.md` Session-3 block.
- caelestia Hyprland Lua, full files: `gestures.lua`, `input.lua`, `general.lua`, `variables.lua`, `keybinds.lua`, `rules.lua`, `misc.lua`, `decoration.lua`.
- caelestia shell `modules/windowinfo/Buttons.qml` (full — the Lua-aware window-control dispatch reference).
- DankMaterialShell `Modules/WorkspaceOverlays/OverviewWidget.qml` (drag-to-workspace mechanism, lines ~170–440) + `Services/HyprlandService.qml` `moveToWorkspace` (the dispatch).
- iNiR `modules/common/widgets/BarModuleOrderEditor.qml` (DropArea pattern — grepped/read) + confirmed `modules/bar/Workspaces.qml` does **not** accept window drops.
- Local plugin configs: saatvik333 `plugins.conf` (hyprexpo, commented), glassesarch `plugins/default.conf` (hyprexpo + hyprfocus) — confirmed **no local repo actively runs hyprbars** (all use overview/focus plugins), so hyprbars is web-sourced.

### Read in full (web, authoritative) — by me directly
- Hyprland **Gestures** wiki (`content/Configuring/Advanced and Cool/Gestures.md`, raw markdown) — complete 0.55 Lua gesture grammar, directions, actions, pinch/`cursor_zoom`, live gestures. **Fully read.**
- Hyprland **Variables** wiki (`content/Configuring/Basics/Variables.md`, raw) — `follow_mouse` (0/1/2/3 note verbatim), `focus_on_close`, `mouse_refocus`, `float_switch_override_focus`, `focus_on_activate`, `follow_mouse_shrink/threshold`.
- Hyprland **Dwindle-Layout** wiki (raw) — `smart_resizing`, `preserve_split`, split model, resize dispatchers (cross-check for the corner-resize bug).
- **hyprbars README** (hyprland-plugins, raw) — full config table + hyprlang and **Lua** button APIs + window rules.
- **omarchy-desktop-shell** `05-hyprbars-titlebar/` — `hyprbars.conf`, `window-minimize` (full script — the minimize gotcha + fix), `bindings.snippet.conf`.
- hyprbars issues **#634** and **#283** (read threads); official **Hyprland plugins list** (hypr.land/plugins) — confirmed hyprbars is the only titlebar/button plugin; noted hyprgrass=touchscreen, hypr-kinetic-scroll, overview plugins.

### VIEWED (previews)
- **hyprbars official preview image** (README `user-attachments/…184a66b9…`) — macOS traffic-light titlebars on Files + Chrome; rounded, integrated, adaptive color. Ranking-basis view for per-window controls.

### Delegated detective work — TWO focused research passes, each of which read `~/nix/SESSION_PREAMBLE.md` in full and did **primary-source** reads (not search snippets); I cross-checked their key claims against my own reads
> *Transparency note (per the user's guidance that subagents must not repeat the "skim" failure): both passes were mid-flight directed to read the preamble and re-verify against fully-read sources with verbatim quotes + an explicit read/didn't accounting. I independently sourced the overlapping items (hyprbars config, dwindle model, movement dispatchers, focus vars) so nothing critical rests on an unverified hand-off.*
- **Pass B (window movement / snapping / hyprbars state)** read **primary source**: hyprbars `barDeco.cpp` (confirmed modifier-free drag = `changeMouseBindMode(MBIND_MOVE)`), Hyprland `LuaBindingsDispatchers.cpp`/`KeybindManager.cpp` (Lua resize = pixels only; legacy string dispatchers still registered), a **real 0.55 config** (end-4 `general.lua` snap block + `keybinds.lua`), the Variables/Dispatchers/Binds wiki markdown, PR **#8088** (native snap = float-only), and hyprbars issues **#634/#635/#643/#655/#355/#675/#627** (state/dates). Verified hyprbars runs on **0.55.2**.
- **Pass A (input/typing bugs)** read **primary source**: the Wayland `wl_keyboard.repeat_info` protocol (proof accel is impossible), the Hyprland Variables + Dwindle wiki bodies, libinput maintainer **who-t** DWT blog, **linuxtouchpad.org** DWT diagnosis, **omarchy #1273** (same MacBook DWT symptom + quirks fix), EndeavourOS Apple-touchpad thread, **Chromium bug 1811219** (Wayland smooth-scroll), ungoogled-chromium #2034 (no Chrome scroll multiplier), Arch #308369 (pseudotile), Hyprland #2900. It also **corrected one of my own hypotheses** (the "external mouse disables DWT" myth) — folded into §5.1.

### NOT read / did not view (honest gaps)
- **No live testing** (out of scope): every DWT/scroll/repeat value, the corner-resize + 3rd-window repros, the pinch action-token spelling (`cursor_zoom` vs `cursorZoom`), the exact enumerated bus of this machine's keyboard for the quirks match, and the hyprbars-on-0.55-pinned click responsiveness (#635 class) are all flagged **[LIVE-TEST @ execution]**.
- Did **not** view a hyprbars preview *in a dark aurora-glass palette* (only the stock light preview exists) — verify the dark look at execution; hyprbars colors are fully configurable, so this is a theming step, not a risk.
- Did **not** read the QuickShell layer-shell API docs to *prove* a per-window overlay is impossible — reasoned from three full shells never doing it + PanelWindow's edge-dock/space-reserve semantics (Pass B independently reached the same conclusion). A `PanelWindow`/layer-shell doc check would close it definitively (low priority — hyprbars wins regardless).
- Did **not** read Hyprland discussion **#13703**'s resolution (naive special-workspace minimize broke ~0.54) — flagged; the omarchy per-window-special script (dated post-0.54) is the working path regardless.
- The **Waybar→cgroup→child-death** chain (§5.5) rests on process-lifecycle reasoning + community-report *snippets* (not one fully-read authoritative source) — explicitly PARTIAL, resolved by re-verification at execution.

### Contested-claims settled this session (per §15 rule)
- **"hyprbars is unusable / too buggy" (the deferral):** settled — the deferral bugs are (a) rolling-release ABI desync (structurally prevented by the NixOS pinned-flake load; confirmed running on 0.55.2) and (b) a Nerd-Font glyph choice. Residual open bugs are cosmetic or edge-case (XWayland click-through #643, CSD double-bar #655→`hyprbars:no_bar`). **Usable on this build** (validate #635-class click responsiveness at execution).
- **"pinch is unsourced everywhere" (GAP_REVIEW):** settled FALSE — pinch `cursor_zoom` is a native Hyprland 0.55 gesture action (compositor magnifier); in-app page-zoom is a separate Chrome-flag matter.
- **"drag-window-to-workspace has no implementation, only iNiR's pattern":** settled FALSE — DankMaterialShell `OverviewWidget.qml` is a real end-to-end implementation; the bar version is a graft, not a rebuild.
- **"external USB mouse disables DWT" (my own earlier hypothesis):** settled FALSE — unsupported by any source; the real MacBook cause is keyboard↔touchpad pairing (§5.1).
- **"Aero-Snap drag-to-edge half-tiling exists somewhere":** settled FALSE — not native, no plugin, absent from all 25+ reference repos; only keybind snap (works) or bespoke drag-glue.
