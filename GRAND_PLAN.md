# THE GRAND PLAN — Aurora
## The complete build plan for the NixOS + Hyprland desktop on the 2020 MacBook Air (T2)

**Status:** Authoritative. This document supersedes `OVERHAUL_PLAN.md`, `BUILD_PLAN.md`, and every research recommendation where they conflict. Execution sessions work from this document and only this document. `MASTER_REQUIREMENTS.md` remains the requirements ledger this plan answers to; where this plan makes a different call than a research file, the divergence is stated inline with the reason.

**Author:** Fable, head designer. Written 2026-07-21 after full reads of MASTER_REQUIREMENTS, macbook-build-spec, SESSION_PREAMBLE, SYNTHESIS, GAP_REVIEW, caelestia-full-inventory, visual-design-reference, all ten research session outputs, the no-session list, EXECUTION_LOG, the relevant OVERHAUL_PLAN sections, and direct on-disk verification of the skwd-wall and caelestia repos.

---

## 0. RULES OF ENGAGEMENT (for every execution session)

1. **This document is the source of truth.** If an instruction here is ambiguous, the answer is in the cited source repo — open it and read it. It is never "write your own version."
2. **Every component has a source attribution (repo + path).** "Adapt" means: vendor the cited files, make the minimal changes listed in the adaptation delta, keep the original structure recognizable. If you find yourself writing a new file that does what a cited file already does, stop — you are off the plan.
3. **Any subagent you spawn must read `~/nix/SESSION_PREAMBLE.md` first.** No exceptions. That file explains why.
4. **[GATE] markers are live test gates.** Work stops at a gate until the listed checks pass on the physical machine, with Alex present for anything visual or feel-based.
5. **Report honestly.** If a test fails, the log says it failed. If a step was skipped, the log says so. If a source file turned out different from this plan's description, flag it — do not silently improvise.
6. **Do not regress §11 of MASTER_REQUIREMENTS** (font rendering, cursor states, tap-to-click, two-finger scroll, boot WiFi, Kitty Ctrl+C/V, dual-boot rollback, agent execution, Chrome Wayland).
7. **Protected state (never clobber):** see §8.7. The Media Center stack, the TV firewall rule, the Xbox controller Bluetooth tuning, Bluetooth pairings in `/var/lib/bluetooth`, `/etc/nixos/firmware/brcm`, and the T2 invariants of MASTER §10.

---

## 1. THE DESIGN

One sentence: **a dark glass operating system where aurora light bleeds through every surface, driven entirely by clicking, built from the community code Alex already fell in love with — running smoothly on a two-core MacBook Air.**

The desktop is two surfaces and a wallpaper. A **top bar** that is a real taskbar — the Windows muscle-memory home, where Alex clicks running-app buttons to move between windows, watches his machine's vitals, and reaches every control. A **left dock** of frosted glass tiles that appears when he wants to launch something and retracts when a window needs the space. Between them, the wallpaper — the aurora — is the third character: every panel is translucent enough to let it through, and when it changes, the whole OS recolors in one smooth 300ms breath.

Underneath the glass is one coherent machine, not a parts bin. One shell process owns every surface. One palette authority recolors everything. One wallpaper daemon renders every transition. One settings app configures it all. Every popup opens in ~260ms and closes when you click anywhere else. Nothing pops; everything slides, fades, or morphs. Cinema — the 700–1200ms choreography — is reserved for exactly two moments: the lock screen and the first expansion of a rich widget. Daily clicks are never slowed for beauty.

The win condition, walked end to end in §6: press power → aurora splash → a lock screen with real depth-of-field → click, type, you're in → everything from installing Spotify to checking why the fan spun up is one or two clicks away, discoverable, and gorgeous. At least as easy as Windows and macOS. More beautiful than either. Smooth on *this* hardware — every expensive effect in this plan is either GPU-cheap by construction or gated behind a measured test.

### The four structural decisions (summary — full reasoning in §12)

1. **The shell chassis is caelestia.** We fork `caelestia-dots/shell` (57,875 lines, on disk, code-traced in `caelestia-full-inventory.md`) into our flake as **aurora-shell** and build the OS on its plugin, services, and surfaces. Alex's own screenshots — the live window previews, the nested tray menus, the tabbed dashboard — *are* caelestia surfaces. We stop extracting slices from the thing he wants and start living in it.
2. **The wallpaper system is the full skwd-wall application, daemon included. awww is retired.** The daemon's 38 shader transitions are what Alex saw and approved; its socket API gives us wallpaper control and a broadcast `applied` event that the palette pipeline subscribes to with zero upstream patches.
3. **The palette authority is caelestia's own scheme engine, patched to pin our surfaces.** Not Matugen, not an iNiR token transplant. One engine, native to the chassis, animating every recolor.
4. **The window model is hyprbars + click-to-focus.** Every window gets real close/minimize/maximize buttons and a grab-anywhere titlebar; focus never moves unless you click. This single pair of decisions kills the worst daily frictions in the bug log.

---

## 2. THE ARCHITECTURE

### 2.1 The chassis decision (open question #2 — resolved)

**Decision: carry caelestia's shell as the foundation of the one QuickShell instance, forked into `~/nix/modules/home/aurora-shell/`.**

What this means concretely: the shell that runs on this machine is caelestia's `shell.qml` composition — its C++ plugin (typed config, sensors, cava/beat-tracker, lyrics, appdb, qalculator, blob shaders), its 18 backend services, its shared component library, its drawer coordinator — with our scheme, our layout changes, and our grafted-in components. It is deployed through caelestia's own Home-Manager module pattern (`nix/hm-module.nix` → `programs.caelestia` — we vendor and rename to `programs.aurora-shell`), which handles the systemd user service, the `shell.json` settings attrset, and the CLI.

**Why this beats the alternative** (the existing aurora-shell skeleton absorbing per-repo slices):

- **The surfaces Alex approved are caelestia surfaces.** The five screenshots he fought five sessions over — window-preview popouts, tray drill-in menus, the tabbed dashboard, the duration submenus — are `modules/windowinfo/`, `modules/bar/popouts/TrayMenu.qml`, `modules/dashboard/`. Extracting them means reimplementing their service wiring; carrying the shell means they simply run.
- **The dependency economics inverted once the full inventory existed.** The shell-surfaces session recommended a "pure-QML launcher slice" to avoid compiling the C++ plugin — written when the shell repo wasn't yet on disk and the plugin looked like dead weight. But the plugin is also the sensors backend (CPU/GPU/memory/storage for the bar and dashboard), the audio visualizer, the lyrics service, the app-frequency ranking, and the calculator. We want all of those anyway. Once the plugin is resident, the "slice vs. shell" question dissolves: the full-fat launcher, Nexus, and the dashboard come nearly free. This is exactly the settings session's "Model A," and it called this correctly: *"the settings center comes almost for free — the single strongest argument for the packaged-shell path."*
- **§15's panel-coordinator comparison comes out against the incumbent.** The existing `PanelCoordinator`/`PanelHost` implements mutual exclusion + focus-grab + staged animation — competently, but it fronts the from-scratch panel content that the whole overhaul exists to replace. Caelestia's `modules/drawers/` (`ContentWindow.qml` HyprlandFocusGrab click-away, `Interactions.qml` edge gestures, `Exclusions.qml`) does the same job, more maturely, already wired to every surface we're keeping. "It already works" was explicitly ruled insufficient; the drawers win on merit. The incumbent panels' *backends* that are genuinely good — the Open-Meteo weather cache pattern, the `equalizer-state` EasyEffects generator — are carried as backends (§5.9, §5.4).
- **Independent-surface architecture is preserved where it matters.** MASTER §6 rejected *ilyamiro's single morphing hub* — one panel morphing between unrelated contents. Caelestia's drawers host **separate, independently-openable surfaces** (launcher, dashboard, sidebar, session, OSD, utilities) with per-surface state; the requirement's intent (no hub, click-away everywhere, progressive disclosure per panel) is satisfied. Nexus is a standalone `FloatingWindow`. The grafted components (dock, display panel) are their own `PanelWindow`s.

**What we keep, change, disable, and replace** (the fork manifest — every execution session references this table):

| caelestia module | Verdict | Notes |
|---|---|---|
| `plugin/` (C++, 15.8k lines) | **KEEP, build via its flake** | Config, sensors, cava/beat, lyrics, appdb, qalculator, blobs, lazylistview. No source changes at v1 except the scheme defaults. |
| `services/` (18 singletons) | **KEEP** | Two patches: `Nmcli.qml` password path (§5.2), `NetworkUsage.qml` two bugs (§5.2). Weather → Austin. |
| `components/` (60-file UI kit) | **KEEP** | Tokens restyled via scheme, not code edits. |
| `modules/drawers/` | **KEEP** | The panel coordinator. Edge-gesture thresholds retuned for top-bar layout. |
| `modules/bar/` | **KEEP vertical (the left rail)** + a new top taskbar module beside it | Layout revised with Alex 2026-07-21. Full spec §5.1. |
| `modules/bar/popouts/`, `modules/windowinfo/` | **KEEP, re-anchor** | Popouts anchor below the top bar instead of beside a left rail. §5.2. |
| `modules/dashboard/` | **KEEP** | Top-edge drawer, pairs naturally with the top bar. Calendar restyle per §5.4. |
| `modules/launcher/` | **KEEP (full-fat)** | Drop `WallpaperList` mode (skwd-wall owns wallpapers). Bind Cmd+Space + Apps button. §5.5. |
| `modules/sidebar/` (notif history) | **KEEP** | Right-edge drawer, bell + Super+N + edge swipe. §5.6. |
| `modules/notifications/` | **KEEP** | + iNiR ingress cap + semantic filter (budgeted glue). §5.6. |
| `modules/osd/`, `modules/session/` | **KEEP** | Restyle only. Session gets hold-to-confirm (§5.7). |
| `modules/utilities/` | **KEEP, extend** | Becomes the System surface: keep-awake / recorder / toggles + our added action cards. §5.7. |
| `modules/areapicker/` | **KEEP** | The screenshot region/freeze/clip tool. §5.12. |
| `modules/nexus/` | **KEEP, prune + extend** | The Settings app. Page plan §5.8. |
| `modules/lock/` | **REPLACE** | Our composite lock (ilyamiro × Vast × DMS) lives here instead. §5.10. |
| `modules/background/` | **KEEP with `wallpaperEnabled = false`** | Verified: `backgroundconfig.hpp:73` is a stock flag. skwd-paper owns the wallpaper layer; this module keeps hosting the desktop clock/visualizer/right-click layer. §5.15. |
| `Shortcuts.qml`, IPC | **KEEP, extend** | The 13-target IPC surface + 22 global shortcuts are the spine that makes every control both clickable and bindable. New IPC targets: `dock`, `displaypanel`, `switcher`. |
| CLI (`caelestia` → `aurora` CLI) | **KEEP** | `toggle.py` (dev workspace spine), `screenshot`, `record`, `emoji`, `resizer`, scheme/theme fan-out. `wallpaper.py` re-pointed at the skwd socket. |

**Grafted into the chassis from other repos** (each fully specified in §5): DMS dock (§5.3), DMS DisplayConfig (§5.2/§5.8), the composite lock (§5.10), the iNiR polkit dialog (§5.14), the iNiR clipboard panel + ilyamiro grid morph (§5.13), the iNiR desktop right-click menu (§5.15), ilyamiro's EQ subview (§5.9), the drag-to-workspace graft from DMS (§5.1), the QuickShell live cycler (§5.16).

### 2.2 Process topology

Everything that runs, who owns it, and why it exists:

| Unit (systemd user unless noted) | What | Source |
|---|---|---|
| `aurora-shell.service` | The one QuickShell instance (caelestia chassis) | fork; unit hardening from iNiR `assets/systemd/inir.service`: `Restart=on-failure`, `RestartSec=5`, `StartLimitBurst=3/30s`, **`KillMode=process`** (shell restart never kills user apps), `SuccessExitStatus=143`, `LimitCORE=0` |
| `skwd-daemon.service` | Wallpaper renderer + transitions + library | ships inside skwd-wall's Nix package (verified in its `flake.nix`) |
| `hypridle.service` | Idle staging + lock-before-sleep | end-4 `hypridle.conf` pattern (§8.5) |
| `hyprsunset` (via shell service) | Night light | first-party Hyprland tool (§8.3) |
| `easyeffects.service` | Invisible EQ backend | present today; presets move to XDG data dir |
| `t2fanrd` (system) | Fan curve | **already live in the flake — preserve as-is** (§8.7) |
| `aurora-notification-fallback` (dunst) | Inactive failure fallback for notifications | present today; deliberate non-bridge, keep |
| `restic-home.timer` | Nightly backup | `services.restic.backups` (§8.4) |
| `nix-gc` + generation trimmer | Disk stewardship | §8.4 |
| `systembus-notify` | System→user notification bridge for health events | §8.4 |
| `agent.slice` | CPU/IO/memory containment for Claude/Codex | §8.6 |
| **Retired:** `waybar.service`, `swayosd.service`, awww, Waypaper, Rofi, the old `aurora-wallpaper*` units, Hyprlock-as-daily (stays installed as emergency fallback) | | |

### 2.3 Repository layout (target state of `~/nix`)

```
flake.nix                      # inputs: nixpkgs, nixos-hardware, home-manager, t2fanrd (KEEP),
                               #   hyprland + hyprland-plugins (follows), skwd-wall (+ its skwd-daemon input),
                               #   aurora-shell (path:./modules/home/aurora-shell)
hosts/macbook/                 # host composition (unchanged pattern)
modules/nixos/                 # base, t2-firmware, desktop, laptop-power (+ agent-slice.nix, backup.nix,
                               #   guardrails.nix, media-center.nix ← ported TV firewall rule)
modules/home/
  aurora-shell/                # the caelestia fork (shell + plugin + cli) — vendored, not a flake input,
                               #   because we patch it; keep upstream git history via subtree for diffability
  hyprland/                    # Lua config (bindings, rules, gestures, glass, plugins)
  dolphin/  kitty/  fish/  starship/  theming/  dev-workspace/  lock/  boot/
GRAND_PLAN.md                  # this file
```

The old `modules/home/{waybar,rofi,wallpaper,quickshell}` trees are deleted in Stage 1 (their good backends are carried into aurora-shell first — see the manifest above).

**The remote (operator confirmation 2026-07-21): everything goes back to the original boot repo.** `~/nix` *is* that repo — `github.com/AlexbringsMercy/nix`, the bare-bones config that first booted this machine — and the complete OS lives in it: the aurora-shell fork, every vendored component (attribution headers per file; `SOURCES.md` remains the provenance ledger), all modules, this plan, and the research corpus. **Stage 0 sets the upstream and pushes; every stage gate ends with a push**, so the entire OS is reproducible from GitHub at any point mid-build; the working branch merges to `main` at Stage 10 acceptance. Never pushed, by design: the Apple/Broadcom firmware tree (stays machine-local through the non-Git wrapper — the reason the portable evaluation exists), secrets (restic password file, the calendar ICS URL — a gitignored `secrets/` path consumed by modules), and wallpaper binaries (existing rule; the library lives in `~/Pictures`, backed up by restic instead).

### 2.4 The IPC map (how buttons and hotkeys stay redundant)

Every action in this OS is reachable two ways, and both ways call the same function. The shell exposes it via `aurora shell ipc call <target> <fn>` (caelestia's IPC layer, renamed); Hyprland binds keys to the same globals; bar/dock/panel buttons call the same handlers internally. The 13 existing targets (mpris, brightness, notifs, audio, hypr, gameMode, idleInhibitor, wallpaper, lock, picker, drawers, nexus, toaster) plus our additions (dock, displaypanel, switcher) mean the keymap in §6.4 is *thin* — every bind is one IPC call, and deleting a bind never removes a capability.

---

## 3. THE VISUAL SYSTEM

This section is the concrete answer to "what does it look like." Execution agents copy these values; they do not interpret adjectives.

### 3.1 Palette — the fixed ladder and the adaptive accents

The mubin policy, implemented: **surfaces are pinned forever; only accents follow the wallpaper.** The ladder (from SYNTHESIS's reconciled values, which match the master glass RGB exactly):

| Role | Value | Used for |
|---|---|---|
| `background` | `#080b14` | Deepest base (lock scrim, bar end-caps) |
| `surfaceLowest` | `#0a0e1a` | **The glass RGB.** Every translucent panel fill is this color at the alphas in §3.2 |
| `surfaceLow` | `#0f1526` | First elevation (inner cards) |
| `surface` | `#151d33` | Mid containers |
| `surfaceHigh` | `#1c2742` | Selected/elevated states |
| `onSurface` | `#e6edf7` | Primary text (never pure white) |
| `onSurfaceMuted` | `#aab6c8` | Secondary text |
| border | `rgba(255,255,255,0.08–0.12)`, 1px | Every panel edge |
| `primary` / `secondary` / `tertiary` | **wallpaper-derived**, clamped | Teal/cyan (#00d4aa / #38bdf8 family), purple (#7c3aed family), seafoam/deep-green (#34d399 family) |

**The accent clamp is the pink/mauve fix** (accepted finding §9): the defect was tone-80 lightness destroying saturation, not hue. The scheme generator (§4) clamps accent tone into the 55–70 band and floors chroma before any hue decision. Accents must read as *luminous against near-black*, never pastel.

Never use the word "navy" in any prompt, asset request, or comment. It reliably produces flat corporate output.

### 3.2 Glass — the recipe and the measurement gate

The test is unchanged: **can you see the wallpaper through it? If no, too opaque.**

| Surface class | Fill | Where |
|---|---|---|
| Bar / main panels | `#0a0e1a` @ **0.60** (`#990a0e1a`) | top bar, dock rail, dashboard, sidebar, launcher |
| Popouts / history | @ 0.58 | bar popouts, notification cards |
| Inner cards | `surfaceLow` @ 0.48, or `rgba(255,255,255,0.04)` fill, no border | cards inside panels |
| Tooltips | @ 0.65 | |
| Kitty | `background_opacity 0.88` (current, working — keep; tune 0.82–0.88 live) | |
| Hover | brightness up (`+rgba(255,255,255,0.06)` layer, ~150–200ms), **never a color swap** | |

**Blur is compositor-owned, one scoped pass — never per-surface QML blur, never a full-screen FBO.** Hyprland Lua starting point, with the D7 reconciliation applied:

```lua
decoration = { blur = {
  enabled = true, size = 12, passes = 1, xray = false,
  contrast = 1.05, brightness = 1.0, vibrancy_darkness = 0,  -- 0 = maximum effect (accepted §9)
}}
-- layerrules: blur only the named aurora-shell layer namespaces + skwd-wall's picker layer
-- ignore_alpha = 0.10  (overhaul-verified: higher thresholds pop blur in late in every fade-in)
```

**[GATE — glass A/B, one evening, Alex present]** `hyprctl` live comparison: (a) size 12/1-pass vs size 8/2-pass on the visible layers only; (b) `xray = true` vs `false` — xray is the decisive Iris Plus perf lever and its "windows don't show through panels" trade matches the aesthetic anyway; (c) `decoration:glow` rim accent (accepted §9: per-window rim glow, one draw per window) tinted to `primary` at low intensity — adopt if it reads as aurora rim-light, drop if gamer-y. The winning values become the shipped config; this gate settles D7 permanently.

### 3.3 Motion — the vocabulary

One token table, owned by the theme (caelestia's `tokens.hpp` anim tiers, values overridden to ours), consumed everywhere. Milliseconds and curves are not restated per-component; components reference tokens.

| Token | Value | Use |
|---|---|---|
| `effectFast` | 120–150ms ease-out | color, icon, pressed states |
| `effect` | 180–200ms `(0.2,0,0,1)` / OutCubic | hover, toggles, simple opacity |
| `panelOpen` | **260ms OutCubic** — opacity immediately, translate 8–16px, scale .97→1 | every daily popup/panel |
| `panelClose` | 180–200ms InCubic, then unmap | every close |
| `morph` | 210–260ms OutCubic; content swap opacity OutQuint + scale .98→1 | compact↔expanded, subviews (the ilyamiro master-morph pattern, SYNTHESIS motion table) |
| `selectionStretch` | leading 200ms / trailing 350ms OutExpo | workspace/tab/preset indicators (the signature "stretchy catch-up") |
| `layout` | 300–350ms OutExpo/OutQuart | list heights, card arrangement, EQ bands |
| `cinematic` | 750–1000ms staged | lock/unlock, arrival moments, and expanded-widget entrances. *Operator direction 2026-07-21: cinematic is welcome anywhere it doesn't slow real workflow* — so first-opens and expansions may stage up to ~1s, **repeat interactions of the same surface run at `panelOpen` speed, and motion never queues input** |
| `reducedMotion` | 0–120ms opacity only; no travel/scale/ambient loops | exposed as a Nexus Appearance toggle from day one (caelestia has a duration-scale token — wire it) |

**The morph engine is ilyamiro's — everywhere, not just his widgets.** `morph` is his Main.qml master geometry/content pattern (x/y/w/h 210ms OutCubic; content enter opacity OutQuint + scale .98→1); `selectionStretch` is his leading/trailing catch-up; the card→detail shared-geometry morph (clipboard, device detail, album/EQ expansion) is his 250–300ms OutExpo pattern; the staged cinematic entrances are his choreography (full stagger on first open, ~900–1100ms; shortened on repeat). Caelestia-sourced surfaces are **retimed onto these tokens** — their stock 500ms springy drawer curve does not ship. This is a design invariant: ilyamiro's motion is the animation identity of the OS.

**The boundary rule (operator design review, 2026-07-21 — this is what keeps it from getting funky):** *morphs happen within an anchor, never across anchors.* Three cases, spelled out: (1) **Within a popout family** — caelestia's rail popout sliding and resizing along the bar as you hover from network to bluetooth to battery is already morph grammar (one object, new anchor point, cross-fading content); it keeps exactly that mechanic, retimed to `morph`/`selectionStretch` — and the right-edge history/utilities background join retimes to `layout`. This is where caelestia's conjoined-small-popout design and ilyamiro's morph engine turn out to be the same idea at different sizes. (2) **Across anchors** — a rail popout followed by a top-bar popout is two different objects at two different homes: the first exits (`panelClose`), the second enters (`panelOpen`), and **nothing ever flies across the screen pretending to be continuous**. (3) **Compact → expanded** — a popout's click-through to its full ilyamiro panel is exit + the panel's own staged entrance (they are separate layer surfaces; a cross-window shared-geometry morph is a false continuity and technically fragile — the shared-geometry morph is reserved for elements *inside* one surface, like clipboard card→preview or album→EQ). Because every duration/curve lives in one token file, the **[GATE — bars]** includes a live motion-feel pass with Alex: popout slide timing, morph curves, and the rail↔top-bar handoff tuned on the spot until it reads as one system.

Hyprland-side window animations (Lua, from visual-design-reference): open = fade+scale .95→1 ~250ms ease-out; close = 150–200ms; workspace slide 300ms; `misc:animate_mouse_windowdragging = false` (drag latency on this GPU). QML bezier arrays must be length-multiple-of-6 ending `1,1` (overhaul §5.8a — silently discarded otherwise).

Performance rules that make this smooth on an i3: all continuous renderers (cava, sparklines, scanning spinners) are **demand-driven and visibility-gated** (iNiR's `CavaService`/`ResourceUsage` lifecycle is the adopted pattern — one shared cava process, teardown when hidden/silent/on-battery); ambient loops (orbiting blobs) appear only inside expanded widgets, max 1–2 per surface; vinyl rotation uses `RotationAnimator` (render thread); heavy Canvas work is event-only.

### 3.4 Gradients, typography, icons

- **Diffuse aurora, never sharp linear.** The ML4W technique, translated to QML as the standard treatment for hero surfaces (lock, session menu, expanded music, Nexus sidebar): two overlapping radial gradients of `secondary`/`primary` at 0.45–0.55 alpha, ellipse radii 100–180%, centers *off-canvas* (e.g. 30%/140% and 75%/−40%), over the 0.5-alpha surface fill. Everyday panels stay plain glass — the wallpaper itself carries the aurora field (Agridyne's negative-space lesson).
- **Type:** Inter (UI), FiraCode Nerd Font (terminal/code), light-weight large numerals for hero clocks with `tnum` tabular figures. Base UI size 14–15 (caelestia's 13 is too small at 1.5×). `QT_SCALE_FACTOR=1` — logical sizing only, no double scaling.
- **Icons:** Papirus everywhere (bar, dock, launcher, tray, Nexus), replaced centrally at the token layer.
- **Hit targets:** ≥34px for any bar control (media buttons explicitly), 40×40 grid cells, 44px primary actions — independent of visual scale.
- **Micro-status language (C17):** battery pill amber <20% + gentle charge pulse; network icon soft activity shimmer under real traffic; bell dot only for post-filter unread. Built once the services exist; cheap; exercises the motion vocabulary daily.

---

## 4. THE THEMING PIPELINE — one authority, atomic, animated

**Decision (divergence from SYNTHESIS, stated):** the palette authority is **caelestia's own scheme engine** — `services/Colours.qml` (semantic palette + live `scheme.json` watch + `CAnim` 300ms animated propagation) fed by the aurora CLI's generator (`cli/utils/material/generator.py` + `theme.py` fan-out templates). SYNTHESIS recommended an extracted iNiR token slice with an ilyamiro alias facade; that architecture was designed for a bespoke shell assembled from parts. With caelestia as the chassis, its native engine is already wired into all 57k lines — transplanting a second authority would be integration work with negative value. The Matugen-verification question (accepted §9: v4.0 silently discards `custom_colors`) is **dissolved, not answered**: Matugen is no longer in the system pipeline at all. Hellwal remains the named fallback generator only if caelestia's generator fails acceptance. iNiR's contribution survives as *templates*, not authority.

**The patches to the engine (this is the mubin policy, enforced in code):**
1. Scheme generation pins `background/surface*/onSurface*` to the §3.1 ladder — fixed roles never derive from the wallpaper.
2. Accent roles (`primary/secondary/tertiary` + containers) derive from the wallpaper with the §3.1 tone/chroma clamps.
3. Light mode is removed from the product (dark is the identity).

**Template/consumer inventory** — every surface that recolors on wallpaper change. Templates live in the aurora CLI's `data/templates/`; caelestia already ships the starred ones, the rest are ported in (iNiR `scripts/colors/targets/` is the donor for breadth):

| Consumer | Source of template |
|---|---|
| aurora-shell (all QML) | native (`Colours.qml` + CAnim — animated) |
| Hyprland (borders, glow tint) | caelestia★ |
| Kitty | **iNiR target** (caelestia configures Foot — this is a known port) |
| Fish/terminal 16-color, btop, cava, fastfetch | caelestia★ |
| Starship | new small template writing the `[palettes.aurora]` block (§7.5) |
| GTK3 (19 named colors) + GTK4/libadwaita (4 root vars) | **iNiR writers** — the accepted §9 finding, verbatim |
| Qt6/KF6 + Kvantum (Dolphin, Ark, Gwenview, Okular) | iNiR Qt writers + agridyne KDE role mapping (§5.17) |
| Chrome frame | one `BrowserThemeColor` enterprise-policy Nix line (accepted §9); content stays opaque (Agridyne chrome/content rule) |
| Spotify (Spicetify), VS Code, Discord/Vesktop | caelestia★ integrations (SYNTHESIS's app-specific winners) |
| hyprbars (`bar_color`, `col.text`) | new tiny template |
| regreet CSS, skwd-wall UI scheme | new tiny templates (skwd reads a scheme file; point it at ours so the picker matches the OS) |

**The transaction** (the "no half-applied states" requirement, honestly scoped as bespoke glue — see §9): a wrapper around the fan-out that (1) generates every template output into a staging dir, (2) validates each (non-empty, parseable, required keys), (3) publishes all of them with atomic renames in one pass, (4) touches `scheme.json` **last** (the shell recolor is the visible commit), (5) on any failure keeps the previous coherent state and raises a `toaster` error naming the failed consumer. iNiR's `switchwall.sh` temp-and-rename flow is the pattern donor; the all-or-nothing boundary is ours.

### 4.1 The wallpaper system (open question #1 — resolved)

**Decision: keep the complete skwd-wall application with its Rust daemon. awww is retired entirely.**

The reasoning, from on-disk verification (`~/nix/repos/liixini-skwd-wall/`):
- The transitions Alex approved in the preview — the diagonal wipes, the ink/ripple/warp effects — live in the daemon's `skwd-paper` renderer (38 shaders). The daemon-free "vendor SliceDelegate" path in MASTER §6 would discard exactly the thing that made skwd-wall the best picker he's seen, and rebuild the picker's host around one extracted delegate — the pattern this project got burned by. That instruction is **retired**.
- The daemon is externally drivable: JSON-RPC over `$XDG_RUNTIME_DIR/skwd/daemon.sock` (`wall.apply`, `wall.list`, `wall.random_start/stop`, `wall.set_favourite`, …, verified in `qml/services/DaemonClient.qml`).
- It **broadcasts `skwd.wall.applied` (type, name, path) to every socket subscriber.** That is the palette hook: an ~80-line `SkwdBridge.qml` service in aurora-shell subscribes and fires the §4 transaction on every apply — picker click, random rotation, or scripted — with **zero patches to skwd**.
- Packaging is done for us: skwd-wall's flake builds the QML app, the daemon (its own flake input), a `skwd` CLI, the `skwd-daemon.service` user unit, a desktop entry, and a `programs.skwd-wall` NixOS module. Pin both revs (`74be656…` app / `36f165a…` daemon — the verified snapshots).
- With awww gone there is no daemon conflict to patch — the `awww kill` guard branch is unreachable. One renderer owns the wallpaper layer; aurora-shell's own background sets `wallpaperEnabled = false` (stock flag, verified).

**Auto-cycling (C10):** use the daemon's native rotation — `wall.random_start` with interval + `favourites_only` (already exposed in skwd's own FilterBar UI). Every rotation apply emits `applied` → palette follows automatically; there is no second authority because *theming reacts to the renderer* rather than racing it. The **evening variant** (prefer dark wallpapers after night-light onset) is one small systemd user timer that sends a single `wall.apply` JSON-RPC line for a curated `dark/` subset pick — ~15 lines of glue, listed in §9.
**Half-applied-state note:** wallpaper transitions (~600ms shader) and the palette commit (~1s later, animated 300ms) are deliberately sequential — the aurora "breath." Atomicity lives inside the palette fan-out (§4 transaction), which is where half-applied states actually hurt.
**skwd's internal Matugen** themes only its own UI; execution confirms its template output is scoped to its config dir and additionally points its UI scheme at our generated palette so the picker itself wears aurora. `QSG_RHI_BACKEND=vulkan` default: verify on Iris Plus (ANV), override to `opengl` in the wrapper if it misbehaves. **[GATE — wallpaper]** picker click → shader transition plays → whole OS recolors within ~1.5s → no consumer left stale (checklist: bar, Kitty *new window*, Chrome frame, Dolphin, Spotify, hyprbars, lock).

Entry points: System button → Wallpaper; desktop right-click → Change Wallpaper; launcher "wallpaper" action; `random_start` toggle inside skwd's own UI.

**Library:** Alex's wallpapers currently live in `~/Downloads`. Stage 4 imports the collection into `~/Pictures/Wallpapers` (skwd's library dir) via skwd's own import (`wall.import`) — originals untouched, the curated `aurora-collection/` twelve stay, and a `dark/` subset gets tagged for the evening variant. **Any wallpaper works:** surfaces are pinned, so a red or gold image can never break the dark-glass identity — it only re-tints the accents (clamped), and gowall recolor-toward-palette remains the optional inverse for images that fight the mood.

**Animated wallpapers (previously deferred — now a built-in toggle):** verified on disk, the skwd daemon natively plays **video wallpapers and Wallpaper Engine items** (`wall.apply` types `video`/`we`, with per-output audio/volume/mute). The §14 deferral stands as the *default* — a dual-core i3 doesn't decode video for free — but the capability ships with the picker we're installing anyway. Post-acceptance opt-in behind a perf gate, with policy: pause on battery, pause when a window is fullscreen/covering, static fallback image published to the palette pipeline.

**Built for the daemon's future (operator note on the v2 rewrite):** our entire integration is deliberately one thin seam — the `SkwdBridge` socket client + the `skwd.wall.applied` subscription + the packaged systemd unit. The picker app, the palette pipeline, and every surface are ignorant of the renderer. If the lighter-rendering v2 daemon ships and proves itself, adopting it is: bump the flake pin, re-verify the socket protocol against `SkwdBridge` (adapt that one file if the RPC changed), rerun the wallpaper gate. Nothing else in the OS knows the difference. v1 stays pinned until that check passes — proven code doesn't get swapped for release notes.

---

## 5. THE SURFACES

Every surface: what it is, where the code comes from, what changes, how Alex touches it.

### 5.1 The two bars — top taskbar + the caelestia rail *(layout revised 2026-07-21 with Alex: vertical is welcome; both surfaces, cohesive, on demand)*

**The revision:** Alex is open to a vertical bar and loves ilyamiro's top-bar aesthetic; the original plan's rotation of caelestia's bar was the riskiest adaptation in the document. New layout: **a persistent horizontal top taskbar (new module, ilyamiro's geometry) + caelestia's left rail kept vertical and native (hover-reveal by default)**. This deletes the popout-system surgery entirely — caelestia's tray menus, status popouts, WiFi join flow, and kb-layout switcher run exactly as shipped and as Alex screenshotted — and gives each beloved bar aesthetic its natural home. It also resolves the ilyamiro-vs-caelestia bar dilemma by splitting duties instead of picking a loser.

**The top bar — new module `modules/topbar/`, the taskbar. Persistent.** 48px logical, **ilyamiro `TopBar.qml` geometry** (sectioned islands, 34px minimum controls, 4–8px spacing, room to breathe — the bar look Alex rated best); behavior donors: iNiR `BarTaskbar*` + caelestia components + DMS drag chain.
- **Left island:** Apps button (launcher) · pinned Chrome, Kitty, Dolphin (Papirus ~22px, detached).
- **Center island:** workspace pills 1–5 (caelestia `Workspace` delegates in a Row; **each a `DropArea`** → `hl.dsp.window.move({workspace, window:"address:0x…", follow:false})` — DMS `OverviewWidget` chain grafted; same-surface as the drag sources, deliberately) · **running tasks** (iNiR behavior: click activate, click-active cycle that app's windows, right-click menu Close / Close others / Move to workspace ▸ / Float / Pin — dispatch shapes from caelestia `windowinfo/Buttons.qml`; **`Drag` sources**; minimized tasks render dimmed, click restores — §6.2) · active title (hover = live `windowinfo` preview popout, re-anchored to open below the bar — the one popout that moves).
- **Right island:** media chip (≥34px controls + source-app icon, resolver M4, click focuses/launches the player) · CPU pill · RAM pill (hover = plugin-sensor sparkline popout; **click = sysmon workspace** — distinct views, the "both open CPU" bug dies) · network **Mbps** · battery % · clock (→ dashboard) · bell (unread dot → history) · **System button** (→ §5.7).
- Scroll: workspace zone scrolls workspaces; right cluster scrolls volume (caelestia `bar.scrollActions` config). All launches detached.

**The left rail — caelestia `modules/bar/` in its native orientation, near-zero adaptation.** Entries (top→bottom): OS logo · **the dock entry (new — §5.3)**: agridyne-glass app tiles, pinned + running grouped · tray (native nested `TrayMenu` popouts with ‹ Back) · StatusIcons (network / bluetooth / audio / battery — native hover popouts incl. `WirelessPassword` join flow and kb-layout switcher) · **Kurve visualizer strip (new entry — §5.3)** · power (→ session). The vertical workspaces entry is disabled (workspaces live on the top bar, keeping drag-and-drop same-surface). **Reveal: hover-reveal by default** — caelestia `BarWrapper`'s shipped persistent-vs-hover mode; this is Alex's "on demand." Persistent-rail is a Nexus Appearance toggle. Rail and top bar share tokens, islands, and motion — one visual system, two axes.

**Redundancy by design (the §2 philosophy, mapped):** quick glance = top-right pills; quick control = rail popouts (native caelestia); full views = the ilyamiro-presentation expanded panels (§5.2). Window switching = top taskbar; app launching = rail tiles + launcher. Nothing exists in only one place, and nothing renders twice at the same fidelity.

**Adaptation delta (revised — net risk sharply down):** top bar = new module composed from cited parts (M1, size M); rail = **two added entries**, zero popout surgery (M5); `windowinfo` popout re-anchor to top (S); tray/status/kb popouts untouched.

**[GATE — bars]** every §6 bar requirement demonstrable by mouse: workspace click + drag-task-to-workspace; task click/cycle/right-click-close; media controls usable; CPU vs RAM distinct; Mbps visible; rail hover-reveal doesn't fight window edges or the dock tiles' hit areas; tray menus drill in and back natively; nothing dies on `systemctl --user restart aurora-shell`.

### 5.2 Popouts, previews, and the status panels

**Source: carried caelestia modules — native on the rail** (§5.1; only the windowinfo preview re-anchors to the top bar). These are the surfaces Alex screenshotted; they ship with their behavior intact:
- **Window preview popout** — `modules/windowinfo/` (`Preview.qml` live `ScreencopyView`, `Details.qml`, `Buttons.qml` max/float/pin/close + move-grid). Hover the active title or a task button. Live capture is visibility-gated (only while the popout is open — cheap).
- **Tray menus** — `popouts/TrayMenu.qml` StackView drill-in with ‹ Back.
- **Network popout** — `popouts/Network.qml` + `WirelessPassword.qml` (622-line in-bar WiFi join flow). **Two mandated patches:** (1) the password never transits argv — use the pinned QuickShell's native `WifiNetwork.connectWithPsk()` if present, else an nmcli stdin/secret-agent path; clear the QML field on every outcome; (2) `NetworkUsage.qml` gets its two verified bugs fixed (stale read-after-reload; 2^64 wraparound spike) and binds to the default-route interface; label is "live traffic," with a click-to-run WAN speed test action (labeled as a test). Shows SSID, IPv4/v6, gateway/DNS, band, and the §8.4 Portal/Limited/Full state distinctly from link speed.
- **Bluetooth popout** — `popouts/Bluetooth.qml` + Nexus `BtDeviceInfo` (battery %). Device rows stay put across refreshes (stable ordering); pair/forget flows in Nexus. ilyamiro's radial device view is cut-listed (§11) as an optional expanded treatment.
- **Audio popout** — `popouts/Audio.qml`: output volume/mute, mic mute, device switch, per-app streams (Nexus `AppVolumes`), EQ button → §5.9. OSD (`modules/osd/`) is the transient volume/brightness feedback: bounded surface, no input interception, 220ms in / 2s dismiss.
- **Battery popout** — `popouts/Battery.qml` + UPower truth: %, time-to-empty/full (0 = "calculating…", never "0 minutes"), power-profile selector (PPD), keyboard-backlight slider (§8.1).
- **Keyboard-layout popout** — carried as-is (kblayout).
- **Display panel** — **grafted: DMS `Modules/Settings/DisplayConfig/` + `Services/DisplayService.qml`** (session verdict over ilyamiro MonitorPopup: real per-compositor apply, VRR/transform/mirror, reconnect persistence, **battery-aware 60Hz downclock** — adopted). Presented as a Nexus Display page + a bar-reachable panel; visual template is ekremx25's button-row layout (resolution/refresh/scale rows, "layout looks healthy" line). Single-display v1 exposes Mode/Refresh/Scale/Transform; the arrangement canvas stays dormant for the Alienware future. Adaptation M: map `SettingsData`/`Theme` → aurora Config/Colours.

**The expanded tier — ilyamiro's presentation layer (promoted per Alex's cinematic direction).** The rail popouts are the fast path; *clicking through* opens the full panels, and these wear **ilyamiro's compositions** — his widgets are the expressive half of this OS: **battery/power panel** = his animated battery ring + uptime + profile row (staged entrance shortened to ≤700ms; `BatteryPopup.qml`) · **audio expanded** = his liquid master orb + node cards (`VolumePopup.qml`) over the chassis PipeWire service · **Bluetooth expanded** = his radial five-slot device constellation with scan rings and hold-to-disconnect (`NetworkPopup.qml` BT mode — promoted from the cut-list; compact rail popout stays the everyday path) · **network expanded** = the radial gauge with **download Mbps as the hero number** (signal is only the arc fill) + 2×2 detail grid · **FocusTime** (his SQLite app-history analytics — the "app history" panel Alex likes) ships as an opt-in dashboard page rather than a cut-list item. All of them run on chassis services (no shell-script pollers — that part of ilyamiro is replaced), enter with staged choreography on first open, and reopen at `panelOpen` speed.

### 5.3 The dock entry — glass tiles + the Kurve strip (lives inside the rail)

**Source: DMS `quickshell/Modules/Dock/` (11 files, ~3.5k lines, on disk)** — the settled three-way winner — grafted as a **caelestia bar entry** rather than a separate PanelWindow (layout revision §5.1): `DockApps`/`DockAppButton` behavior with `CompositorService/SettingsData/Theme` mapped to the chassis's `Hypr`/`Config`/`Colours`.

**Behavior:** pinned block (Chrome, Kitty, Dolphin, Spotify, Media Center) → 1px separator → running apps grouped per-app (≤4 running dots, focus dot in `primary`); click activates (grouped >1 cycles), middle-click launches a new instance, right-click menu (pin/unpin, desktop-file actions like New Window, Close All), long-press drag-reorder persisted. "On demand" comes from the rail's hover-reveal (§5.1) rather than DMS auto-hide; DMS's smart overlap detection is the donor if the reveal policy ever needs to be occlusion-aware.

**The glass tile treatment** (the one bespoke visual piece, sanctioned small-glue — **motif from agridyne's monochrome-glass launcher tiles**, the "YouTube tile" look from Alex's reference build; no repo ships per-icon tiles, so this is a delegate wrapper over DMS's button): ~48px rounded-square (radius 12–14), shared 0.60 tint fill, 1px 10%-white inner rim, Papirus icon 28–32px, hover = brightness layer 200ms, active = thin `primary` underglow.

**Kurve strip** — `luisbocanegra/kurve` Canvas/Cava renderer (`Visualizer.qml`, `drawCanvas.js`, `Cava.qml`), exact agridyne settings verified from screenshots: Blocks style, fill wave on, rounded bars, bar width 4/gap 5, block height 5/gap 4, orientation Left, transparent background, non-interactive ("disable left click"). ~140px band at the rail's foot; **shares the chassis's one cava provider**; stops when silent, hidden, or on battery.

DMS's live-thumbnail hover (`DockPreview`-class) is **not** in v1 — the top bar owns live previews. iNiR's `DockPreview.qml` graft stays cut-listed behind an Iris Plus measurement (§11).

### 5.4 The dashboard — the top drawer

**Source: carried `modules/dashboard/`** (Wrapper/Content/Tabs + Dash/Media/Performance/Weather). Opens from the clock, a 4-finger-up gesture… and its native top-edge hover/swipe — which now composes perfectly with a top bar. Tabs swipe with the animated indicator.

- **Dashboard tab:** DateTime + **calendar rebuilt to the overhaul §5.8 values** (the "wall of text" fix): hero clock 64px light `tnum` with seconds as a separate 1s-tick Text; 7×6 month grid, 40×40 cells; today = filled `primary` circle; event dots 4px `secondary` — fed read-only from Alex's Google Calendar ICS URL (C20; **built for access now, URL supplied later** — read from the gitignored secrets path so it never reaches GitHub; empty state is graceful, the calendar simply shows no dots) · User card · Resources · SmallWeather.
- **Media tab:** cover art + radial `CoverVisualiser` (adapted per overhaul: 32 paths, ~30fps cap, GeometryRenderer) + controls + seek + **synced lyrics** (`LyricList` — C8, free with the chassis).
- **Performance tab:** Hero/Memory/Network/Storage/Battery cards (plugin sensors; NetworkCard gets the §5.2 NetworkUsage fixes). The storage card carries the §8.4 disk thresholds (amber <15GiB, red <8GiB, "Review generations" action).
- **Weather tab:** forecast — **Austin, TX (30.2672, −97.7431)**, defined once (collapse the four duplicate definitions).

### 5.5 The launcher

**Source: carried `modules/launcher/`, full-fat** — real icons, fuzzy search-as-type, favorites, **appdb frequency ranking** and **qalculator inline calculator** (plugin is resident, so the shell-surfaces session's "drop these" trade is obsolete), actions (lock/sleep/scheme…), detached `DesktopEntry.execute()`. Click-away via the drawers' `HyprlandFocusGrab` (the §5 Escape-only bug dies by construction) and Escape.

Adaptation: drop `WallpaperList` mode (skwd-wall owns wallpapers; the "wallpaper" action launches skwd); keep scheme/variant modes (harmless, cut-listed); Papirus icons; rows sized for 1707-logical width; **triggers: Apps button, dock Apps tile, and Cmd+Space** (rebound from window-focus — the §5 bug). Emoji mode: `:` prefix (iNiR pattern) — see §5.7 for the button path. File results (§4.11): a `plocate`-backed file mode is budgeted glue (§9) — labeled "app/action/file search," honest about not being a content indexer.

### 5.6 Notifications

**Source: carried** — `services/Notifs.qml` + `NotifData` (server, history, DND), `modules/notifications/` (top-right glass cards, actions, images, swipe-dismiss), `modules/sidebar/` (grouped history drawer — bell click, Super+N, right-edge swipe; joins the utilities surface with the 500ms width-join it ships).

Two ported behaviors + one bespoke: **iNiR's noncritical ingress cap** (20/s) and fullscreen/game suppression ported into Notifs; the **semantic routine-event filter** is acknowledged bespoke policy (§9): a keyed rule table (app/category/event) that records-silently or drops routine events — first entries: home-WiFi connect on boot, expected agent-slice unit restarts. Failures always surface. **Screen-share auto-DND (C15):** while `services/Recorder` is active, transient popups suppress automatically (two lines of policy on existing state). Agent hooks (§7.3) make notifications the supervision surface; dunst stays as the inactive failure fallback.

### 5.7 OSD, session menu, and the System surface

- **OSD** — carried; bounded, no input; volume/brightness/mic.
- **Session menu** — carried `modules/session/`; adds ilyamiro's **hold-to-confirm liquid fill** (700ms) on shutdown/reboot — destructive actions are held, not clicked, and never live one accidental click deep. Sleep lives here (it is *removed* from gestures — an accidental 4-finger sleep mid-work is exactly the surprise §2 bans).
- **The System surface** — carried `modules/utilities/` extended into the B18 "actions you take" home, opened by the bar's System button: existing cards (Keep-Awake with duration submenu · Screen Recorder with pause/history · Quick toggles WiFi/BT/mic/DND/GameMode) + our action row: **Screenshot** (→ areapicker) · **Record** · **Wallpaper** (→ skwd) · **Color picker** (hyprpicker → hex to clipboard + toast swatch, C9) · **Emoji** (launcher `:` mode, B15) · **Test camera** (mpv preview of any `/dev/video*`, §8.1) · **Night light** toggle + warmth slider (§8.3) · **Settings** (→ Nexus). Capped at the action row + cards; everything deeper lives in Nexus. This is the §5 fix for "capture controls under the battery panel."

### 5.8 Nexus — the Settings app

**Source: carried `modules/nexus/`** (45 files — standalone `FloatingWindow`, page registry, typed row vocabulary, **built-in settings search**). Model A confirmed: with the chassis resident, Nexus costs pruning + retheming + new pages. Ship order (value-first, from the settings session):

1. **Appearance** — wallpaper (→ skwd), accent strategy, **glass tuner** (opacity/blur sliders added on `SliderRow` — Nexus only has a toggle today), motion/reduced-motion.
2. **Input** *(new page)* — scroll speed, key repeat delay/rate, DWT toggle, tap settings, gesture map: **the §5 input bugs become user-tunable rows.**
3. **Audio** (adapt: devices, per-app volumes, EQ access) + **Network** (adapt NetworkPage + 6 detail pages + VPN manager — WireGuard/WARP/NetBird/**Tailscale** ships with it, C18; argv-password path replaced as §5.2).
4. **Notifications** — per-app rules + DND + the semantic filter's UI.
5. **Display** *(new page)* — DMS DisplayConfig front (§5.2) + night light schedule + brightness.
6. **Default apps** *(§4.1 MIME map made visible)* + **Startup apps** *(new, small)*.
7. **System** *(new page — the capstone)* — generation list, **Check for updates → `nh os build` diff view → Update / Update-at-boot**, **Roll back** buttons (`nixos-rebuild {switch,boot} --rollback`), disk/GC status + "Review generations" + known-good pin control, backup status line (restic last-run), health events (§8.4). The single strongest better-than-Windows/macOS statement in the OS.
8. **Language & region** (weather location UI) + **About**.
9. **Bluetooth** page (carried: pairing, device info, battery).

Retheme: Blobs window chrome → plain glass container (keep the window factory); tokens ride the scheme. Nexus opens from: System surface, launcher "settings," bar right-click, `aurora shell ipc call nexus open`.

### 5.9 Music & EQ — the staged composition (D2 resolved: staged upgrades)

**Daily surface:** the dashboard Media tab (§5.4) — art, controls, radial visualizer, lyrics. **Stage 2 — the expanded Music/EQ widget** (first-expansion cinematic allowed): overhaul §5.8 geometry (900×340; play 56×56, prev/next 44; 20px-tall seek hit area; vinyl via RotationAnimator, pause-don't-stop). EQ subview: **ilyamiro's EQ** (`music/MusicPopup.qml` — 10 bands, 8 presets, 350ms band motion, finite lightning sweep as apply feedback) adapted onto the **existing, working `equalizer-state` backend script** (kept from the current build: validates, locks, writes a modern EasyEffects `equalizer#0` preset to `$XDG_STATE_HOME`, applies async). MPRIS/cava/lyrics come from the chassis; EasyEffects stays invisible (service mode, presets in the XDG data dir — both §5 fixes). Per-device EQ autoload (§8.3) shows the active preset name here — the "why it sounds right everywhere" row.

### 5.10 The lock screen — the composite (decision already made with Alex; carried into the plan verbatim)

**`ilyamiro appearance + Vast cinematic depth/unlock engine + iNiR/DMS status pills + DMS safety lifecycle. Hyprlock stays installed as the emergency fallback.`**

Built as aurora-shell's `modules/lock/` replacement (the chassis instantiates `Lock{}` in `shell.qml` — we swap the module's internals):
- **Identity (ilyamiro `Lock.qml`, 1,252 lines read):** blurred current wallpaper, circular rings/orbit vignette, 140px clock + date, avatar→PIN transformation on input activity (400–600ms), restrained bottom pills, 3×120ms failure shake.
- **Depth + unlock (Vast `Modules/Lock/`):** two-plane wallpaper (background + one precomputed foreground cutout — *still* planes on Iris Plus), typing-focus zoom (planes to 1.12, blur builds), and the **gated multi-beat exit**: lock-icon open → bar collapse → planes scale 1.15 + blur release → only the final `ScriptAction` releases the session lock.
- **Status (iNiR/DMS):** battery + WiFi pills.
- **Lifecycle (DMS `Modules/Lock/Lock.qml` donor):** logind `LockedHint` set before locking, cleared only after PAM success *and* the gated exit completes; on shell start, if logind says locked → immediately re-acquire `WlSessionLock`. Hyprland `misc:allow_session_lock_restore = true` (present in 0.55 — verified). Bounded PAM timeouts/retries; never release on timeout or missing resources; **never** the iNiR release-then-fallback pattern.
- **PAM:** `security.pam.services.aurora-lock = {};` declared **before** first enable. Password is the acceptance path.

**[GATE — lock, mandatory before it owns idle/suspend]** the lock session's full checklist: correct/incorrect/empty/stalled PAM; kill the shell while locked → stays locked → service restarts → re-acquires → password works (repeat during entry animation, during auth, during exit); suspend/lid/DPMS only after lock-ready; failed resource loads still give a usable password field; VT chord + root login verified on the T2 keyboard; motion smooth, memory sane. **If crash/re-acquire fails even once, ship Hyprlock** (`security.pam.services.hyprlock = {};`) and revisit.

### 5.11 Boot, greeter, and the session chain (§4.4)

Power-on → **no Option hold** (one-time t2linux Startup-Manager procedure: Option → hold Control → boot NixOS = persistent default; documented chore: redo after macOS updates; **never touch Startup Security**) → systemd-boot `timeout 0` (hold a key to reveal generations/macOS) → **Plymouth** aurora splash (theme: adapt a minimal spinner-class theme from `pkgs.plymouth-themes` recolored to the ladder; `quiet splash loglevel=3 rd.udev.log_level=3`, `boot.initrd.verbose = false`) → greetd auto-login → aurora-shell starts **locked** (lock-on-session-start), so the first thing Alex ever sees is the lock screen, not a terminal scroll. Unlock → desktop.

- **Logout path:** `regreet` themed via the GTK work + wallpaper background (session pick) — the recovery face of the OS; `tuigreet` on a spare TTY as the text fallback.
- **Keyring:** `security.pam.services.greetd.enableGnomeKeyring = true`; with auto-login the login keyring gets a **blank password** (single-user laptop, §15 defers hardening) so no gcr prompt ever appears — the LUKS-key recipe is the documented upgrade path.
- **[GATE — boot]** cold boot with no keys held lands on the lock screen with zero visible text; hold-key reveal still reaches macOS + old generations; `start-hyprland` warning (open bug) is resolved or root-caused at this gate.

### 5.12 Screenshots & recording (§4.10)

**Source: carried** `modules/areapicker/` (live region / frozen region / straight-to-clipboard modes) + `services/Recorder.qml` + utilities Record card + CLI `screenshot.py`/`record.py`.
- **Bindings:** `Cmd+Shift+S` → region picker (adjustable, **overlay-tinted only** — capture happens via grim after geometry, so the §5 purple-film bug is structurally gone); `Print` → full screen. Region output: clipboard **and** timestamped PNG in `~/Pictures/Screenshots`. Buttons: System surface + bar.
- **Recorder backend: `gpu-screen-recorder` with VA-API H.264** (`intel-media-driver`/iHD — **already in the flake**; `LIBVA_DRIVER_NAME=iHD`) — caelestia's Recorder drives it natively, so zero backend glue. Fallback if region capture misbehaves on i915: `wf-recorder -c h264_vaapi -d /dev/dri/renderD128 -g "$(slurp)"`. **[GATE]** `vainfo` shows iHD encode; 10s test recording stays low-CPU and smooth.
- **OCR (C6):** "Copy text" mode on the picker toolbar → tesseract → clipboard + toast.

### 5.13 Clipboard history (§4.3)

**Sources:** cliphist + wl-clipboard ingestion (caelestia main repo's dual watcher pattern); **iNiR** `services/deferred/Cliphist.qml` + `ClipboardPanel/ClipboardItem/CliphistImage` (lazy image decode, decode-only-when-visible); **ilyamiro** `clipboard/ClipboardManager.qml` grid presentation (3×4 pages, 250–300ms selected-card shared-geometry morph). Composed as an aurora-shell drawer surface: `Cmd+V`-equivalent (`Super+V`) + bar/System entry; click = copy/paste without keyboard; history survives reload; **no session-start deletion** (cxOrz anti-pattern excluded). Privacy policy layer (sensitive-type exclusion, expiry) is §15-deferred; the surface is not.

### 5.14 Polkit & privileged prompts (B8)

**Source: iNiR `modules/polkit/`** (155 lines — cleanest) over QuickShell's first-party `Quickshell.Services.Polkit.PolkitAgent`, restyled to tokens: the sudo-grade dialog **is** an aurora glass surface. Exactly one agent runs (no hyprpolkitagent/GNOME agent autostart). Live-check: `Quickshell.Services.Polkit` present in the pinned QuickShell rev.

### 5.15 The desktop layer

**Source: carried `modules/background/`** with `wallpaperEnabled = false` (skwd-paper renders the wallpaper): hosts the **desktop right-click menu** — iNiR's pattern (`Background.qml` ~l.1108–1144 + `common/widgets/ContextMenu.qml`): New Terminal · Change Wallpaper (→ skwd) · Display Settings (→ §5.2 panel), edge-aware, tokens shared with every other menu. Optional (cut-list): caelestia `DesktopClock`, background `Visualiser`, and iNiR's desktop-widget edit mode (C11 — restrained: clock + weather max).

### 5.16 Alt+Tab & overview (B1)

Alex's primary switching is the taskbar; Alt+Tab is the keyboard redundancy. **Shipped end-state: a live-content QuickShell cycler** composed from carried parts — `windowinfo/Preview.qml` (ScreencopyView) delegates in a horizontal centered strip, MRU order from the `Hypr` service, Alt-hold/release + arrows + mouse click, glass container, `selectionStretch` indicator. Composition of resident components, budgeted §9 (M). From day one (before it lands): `Alt+Tab` → `hl.dsp` `cyclenext` + `bringactivetotop` so the reflex never hits dead air. **hyprexpo** plugin (pinned via the plugins flake) gives the mouse-driven "show everything" overview on a 4-finger-up gesture + bar corner. snappy-switcher stays on the cut-list as a zero-effort alternative if the cycler slips.

### 5.17 The file manager — Dolphin (locked) + the file layer

- **Dolphin** (Qt/KF6): `inode/directory` handler; split view, tabs, undo, batch rename, built-in terminal panel; **Baloo disabled** (on-demand search only). Service menus: **Ark** (Extract Here/To, Compress) — archives' double-click opener (B10). Thumbnails via KIO providers (image/PDF/video, remote previews conservative).
- **Theming (§4.17):** Qt6/KF6 color roles + Kvantum from the scheme (iNiR Qt writers + agridyne's KDE mapping); GTK3/GTK4/libadwaita writers stay for non-Qt apps. Dark, near-black surfaces, rounded frame — "dark glass adjacent," honest about GTK/Qt windows not compositing real blur.
- **Devices & trash (§4.12):** UDisks2 + Solid; **one** headless `udiskie` for hotplug automount + notification; Dolphin owns mount/eject affordances; KIO Trash. **[GATE]** the §4.12 checklist live: insert USB → one notification, sidebar appears, writable, trash vs delete correct, safe eject; verify with no window open.
- **File-picker portal (B9):** `default=hyprland;gtk` with `org.freedesktop.impl.portal.FileChooser=kde` (matches Dolphin's world). **[GATE]** Chrome upload + Save-As: dark, parented, Recents, remembers directory; drag-from-Dolphin-into-page works.
- **Default apps (§4.1), declared once in Home Manager `mimeapps.list`:** dev-lane (code/md/json/logs/configs) → VS Code · images → Gwenview · video/audio → mpv · PDF → Okular · archives → Ark · web → Chrome · directories → Dolphin. Surfaced in Nexus › Default apps.

### 5.18 The system/process workspace (§6 system monitor)

`special:sysmon` — the dedicated full workspace, not a widget, in the canonical riced layout: the **fetch card** (aurora ASCII + OS info lines, persistent) on one side, **btop** (caelestia theme — the reactive CPU/RAM/net waveforms) as the centerpiece, plus `sensors` temps/fan RPM and PipeWire xrun visibility (`pw-top`) in flanking panes — the fan/thermal/audio legibility the guardrails ask for. Opened by: bar CPU/RAM pills (click), launcher "system monitor," `Cmd+Escape` bind, dock right-click. Spawned via the toggle orchestrator (§7.1) with a named Kitty (`--class sysmon`).

---

## 6. THE INTERACTION MODEL

### 6.1 The daily walk (the win condition, moment by moment)

1. **Press power.** Aurora splash. No menu, no text. (Hold a key if you ever need macOS or an old generation.)
2. **The lock screen** fades in with real depth — clock huge, wallpaper alive behind glass. Click or type → avatar and PIN field morph in. Enter password → the cinematic exit plays → desktop.
3. **Open an app:** click Apps (bar or dock) → launcher → type two letters or click the icon (frequency-ranked). Or click a pinned tile. Or Cmd+Space.
4. **Manage windows:** every window wears a titlebar — grab it anywhere to move, double-click to maximize, red/yellow/green buttons to close/minimize/maximize. Minimized windows dim on the taskbar; click to bring back. Drag a task button onto a workspace number to move it there. Focus moves only when you click.
5. **Adjust volume:** function keys (OSD confirms) or click the bar's audio icon → slider, devices, per-app, EQ. Plug in AirPods → sound moves there, with their EQ profile, automatically.
6. **Check WiFi:** the bar icon shows real Mbps. Click for networks; join with a password inline; captive portals announce themselves with a Sign-in button.
7. **Install an app:** Nexus › (or nix-software-center) → click Install — imperative "now" or declarative "permanent" is a visible choice. Updating the OS shows exactly what will change, with a Roll back button. Updating Claude/Codex is `npm install -g` like anywhere else.
8. **Take a screenshot:** Cmd+Shift+S → drag region → it's on the clipboard and in Pictures. Print for full screen. Copy-text mode for OCR.
9. **Lock:** Cmd+L, or the bar power → Lock. **Close the lid:** it locks, then sleeps. **Open it tomorrow:** lock screen, instantly, WiFi back, nothing lost.
10. **When agents run hot:** the fan ramps early and quietly, the UI never stutters (they're weight-capped, not you), and a notification tells you when Claude finished and what changed.

### 6.2 Window management (the full spec)

- **Per-window controls: hyprbars** (official plugin; pinned via `hyprland-plugins` flake with `inputs.hyprland.follows` — the ABI-desync failure class is structurally impossible on NixOS). Config: `bar_height 28`, padding 10, text 11 FiraCode NF, `bar_part_of_window`, `bar_precedence_over_border`, `on_double_click = fullscreen 1`, buttons (R→L): close `killactive` · maximize `fullscreen 1` · minimize → `window-minimize`. Colors from the scheme template. `hyprbars:no_bar` rules for CSD apps (GNOME headerbar apps), the shell's own windows, PiP.
- **Minimize:** omarchy `window-minimize` script (per-window `special:min-<addr>` workspaces, `movetoworkspacesilent`, `misc:close_special_on_empty = 1`, LIFO restore) — the community-proven fix for the shared-special dump-all bug. Restore paths: taskbar click (dimmed task), `Super+Alt+M`.
- **Focus:** `follow_mouse = 0` (click-to-focus — kills the hover-mistarget bug outright), `focus_on_close = 2` (most-recent, macOS-like), `misc:focus_on_activate = true`. `follow_mouse = 2` documented as a Nexus Input toggle for hover-scroll fans.
- **Move/snap:** titlebar drag with **no modifier** (hyprbars `MBIND_MOVE` — verified in `barDeco.cpp`); `Super+drag` anywhere as redundancy; `general:snap { enabled }` floating magnetism; keybind half/full snap via the legacy string dispatchers (`resizewindowpixel "exact 50% 100%"` — the Lua resize API is pixels-only, verified); `Super+Ctrl+arrows` = half-snaps, `Super+Up` = maximize toggle. Drag-to-edge Aero snap: no community implementation exists anywhere — optional bespoke glue, cut-listed, not required (drag-to-workspace + keybinds + titlebar drag cover §4.16).
- **Workspaces:** 1–5 + `special:sysmon` + `special:dev` + per-window `special:min-*`. Move: `Super+Shift+arrows` (directional), `Super+Alt+1..5` (to workspace), drag-to-bar-button (mouse).
- **Resize:** `resize_on_border` on; **known hyprbars interaction (#355)** — [GATE] verify border-resize with bars on the pinned build; if broken, corner `Super+RMB` + document. Corner one-directionality on tiled windows is dwindle's tree math, not a bug: `smart_resizing` tuned live; pseudotile (`Super+P`) for symmetric; floating resizes freely — this is the honest §5 answer.
- **Gestures (§4.8):** 3-finger horizontal = workspace swipe (**keep — do-not-regress**); 3-finger vertical = live volume (wiki live-gesture table); 4-finger up = hyprexpo overview; 4-finger down = `special:sysmon`; pinch = native `cursor_zoom` live magnifier (**pinch is sourced** — 0.55 native; the accessibility zoom C19 rides the same action with `Super+=`/`Super+-` and a Nexus toggle); Chrome in-page pinch/back-forward via its Ozone flags (C16a). **Sleep is not a gesture.** Every gesture has a click path.
- **Input tuning (§5 bugs → values):** DWT root cause is libinput keyboard↔touchpad pairing on T2 — ship the quirks override (`AttrKeyboardIntegration=internal`, bus matched on-machine) then `disable_while_typing = true` works; [GATE] `libinput debug-events` before/after. `repeat_rate 22` / `repeat_delay 350` (progressive repeat is protocol-impossible — say so in Nexus Input's help text). `scroll_factor 0.3` + Chrome `#smooth-scrolling` Disabled (+ `emulate_discrete_scroll` A/B); natural scroll on. All exposed as Nexus Input rows.
- **Third-window-closes bug:** expected-resize half is dwindle; the close half was the Waybar cgroup/OOM chain — Waybar is gone and every launch is detached + `KillMode=process`; [GATE] repro attempt post-cutover; if anything still vanishes, `hyprctl clients` + `coredumpctl` triage per the window session's script.

### 6.3 The placement map (B18 — where every control lives)

**Principle: bar right = status that changes · System surface = actions you take · Nexus = anything you configure · launcher = everything by name.** The §5 surfaces implement it; the keymap below is the redundancy layer. Any control reachable only one way is a bug.

### 6.4 The keymap (hotkeys are shortcuts, never the only path)

| Keys | Action (click path in parentheses) |
|---|---|
| `Cmd+Space` | Launcher (Apps button / dock tile) |
| `Cmd+Shift+S` / `Print` | Region / full screenshot (System surface) |
| `Cmd+V` → `Super+V` | Clipboard history (bar) |
| `Cmd+L` | Lock (power menu) |
| `Alt+Tab` | Window cycler (taskbar buttons) |
| `Super+N` | Notification history (bell) |
| `Cmd+E` | Dolphin (dock/pinned) |
| `Cmd+Return` | Kitty (dock/pinned) |
| `Super+D` | Dev workspace (dock button) |
| `Cmd+Escape` | sysmon workspace (CPU/RAM pills) |
| `Super+Alt+M` | Restore last minimized (taskbar click) |
| `Cmd+.` (`Cmd+Ctrl+Space`) | Emoji (System surface) |
| `Super+=` / `Super+-` | Zoom magnifier (Nexus toggle) |
| Media/brightness Fn keys | OSD-confirmed (bar sliders) |
| `Ctrl+T` | Kitty new tab (tab bar `+`) |

Window keys per §6.2. Kitty: `confirm_os_window_close = 0` (agents can close their own terminals — §5 bug), `copy_or_interrupt` Ctrl+C, Ctrl+V paste, 10k scrollback, clickable tabs, `kitten hints` path/linenum maps (§7.4), startup art = a **custom aurora ASCII header + caelestia's boxed blue-gradient fastfetch panel** (`fastfetch/config.jsonc`) — saatvik333's terminals are the quality bar, and if LazyVim is adopted its dashboard art rides along in the editor — never SIGUSR1.

---

## 7. THE DEV WORKSPACE (§7)

One action — `Super+D` or the dock's code-glyph tile — reveals `special:dev`, the two-agent cockpit. Composed entirely from sourced mechanisms:

### 7.1 The spine
**caelestia CLI `toggle.py`** (read in full; vendored as `aurora toggle dev`): workspace-name → clients map, spawns missing clients **directly into** `special:NAME` (`[workspace special:dev] exec …`), moves matching strays, else toggles. `rules.lua` pins `class: dev-*` → `special:dev`.

### 7.2 The layout (spawned members)
- **Claude terminal:** `kitty --class dev-claude --title "Claude Code" --directory ~/nix` running zellij session `claude-nix` → inside it, `systemd-run --user --scope -p Slice=agent.slice --nice=10 -- claude --dangerously-skip-permissions`.
- **Codex terminal:** same shape, `--class dev-codex`, zellij `codex-nix`, `codex --yolo` (verified current flag; `--full-auto` is deprecated).
- **The fetch pane** (`--class dev-fetch`, persistent): the classic riced-fetch card — ASCII art on the left, OS info lines on the right (`alex@macbook · NixOS <ver> · linux-t2 kernel · Hyprland · uptime · packages · shell · 1707×1067 · CPU/GPU/mem`), caelestia's boxed blue-gradient fastfetch config as the base. **The art rotates like the wallpaper:** a curated `~/.config/fastfetch/logos/` set, one drawn at random per terminal spawn (a three-line wrapper around `fastfetch --logo`), every piece colored through the scheme's ANSI slots so whatever shows is wearing the current accents. Starting set (revised with Alex 2026-07-21; he curates at review): the **NixOS snowflake** (fastfetch built-in) · **saatvik's four shipped pieces, verified on disk at `saatvik333-hyprland-dotfiles/fastfetch/*.txt`** — `star`, `cyberpunk-mask` (the skeleton), the tall cross piece — **renamed `gothic-cross.txt` on vendor** (operator call) — and `illuminati` — all braille art already using fastfetch `$N` color-slot placeholders, so they palette-tint with zero adaptation · an **aurora-waves** piece *only if a genuinely well-designed one is found in the community archives* (quality bar, not a filler slot) · **two reserved slots for Alex's own uploads: the Erdtree and Night's Edge** — drop into the logos dir when ready, `$N`-slot them so they recolor too. Skipped by operator call: the Apple mark, and the AURORA wordmark (redundant — the name is already everywhere). It sits in its own section and stays.
- **btop pane** (`--class dev-btop`) — the reactive terminal-style meters (CPU/RAM/net graphs, caelestia btop theme) — and a **lazygit pane** (`--class dev-git`; Fish abbrs from caelestia's config ride along: `lg`, `gs`, `gd`, `ga`, `gc`). Together with the fetch pane this is the canonical two-terminal composition: art + identity on one side, live waveforms on the other.
- **Dolphin** (`--class dev-files`, window rule → `special:dev`): the file pane of the workspace — split view + its built-in terminal panel pointed at the active repo.
- Quick-spawn buttons for preset dirs (`~/nix`, active project): `kitty --class dev-term --directory <preset>`.

Per-class Papirus-mapped desktop entries give each terminal its own icon in the taskbar/dock; Kitty `window_logo_path` watermarks Claude vs Codex panes.

### 7.3 Agent supervision (C1/C2)
- **Persistence: zellij** (`default_mode "locked"` so its binds never shadow agent TUIs; built-in serialization). A dead Kitty window never kills an agent — reattach and continue. tmux is the documented fallback if RAM pressure bites (a values coin-flip, per the session).
- **Claude hooks** (`~/.claude/settings.json`): `Stop` → `agent-notify.sh` (reads stdin JSON `cwd`, `git status --porcelain | wc -l`, fires detached `notify-send "Claude finished" "~/nix — 3 files changed"`; `stop_hook_active` re-fire guard); `Notification` hook → "Claude needs you" (urgent). **Codex:** `~/.codex/config.toml` `notify = ["python3", …/notify-send.py]` on `agent-turn-complete`. The notification bell becomes the agent supervision surface; a small dev-workspace tile lists live zellij sessions + last hook event per agent ("which agent needs me" at a glance — glue, §9).
- **Containment:** every agent launcher enters `agent.slice` (§8.6). A "full speed" override toggle lives on the dev tile (deliberate, temporary).

### 7.4 Find-file & path-click
- `Super+P` (in Kitty): fzf overlay — `fd | fzf --style full --preview 'bat …' | xargs -r -o $EDITOR` (television is the documented alternative; both in nixpkgs).
- `kitten hints`: `Super+Shift+F` open path, `Super+Shift+G` path:line → editor (`--linenum-action`). "Reopen closed file" intent (ex-Ctrl+Shift+T) is satisfied by editor recents + fzf history, per §15.

### 7.5 The sudo session switch *(new feature, operator-requested 2026-07-21)*

The problem: agent sessions stall on password prompt after password prompt for sudo commands Alex has already verbally approved. The fix is a **visible, self-expiring arm switch**:

- **Mechanism:** a sudoers drop-in sets `Defaults timestamp_type=global` + `timestamp_timeout=15`. Arming = one password entry through a glass askpass prompt (a small aurora-shell dialog wired via `SUDO_ASKPASS`, same visual system as the polkit dialog) running `sudo -v`, then a keepalive (`sudo -nv` every ~4 min) while armed. Disarm = `sudo -k` + keepalive stops. **Auto-disarm** on: toggle off, lock, suspend, agent-terminal close, or a 60-minute ceiling (Nexus-tunable). With the global timestamp valid, every sudo the agents run — in any pane, any child shell — passes silently.
- **UI:** an **"Allow sudo" switch** on the dev-workspace tile and in the System surface, plus an **amber `sudo armed · 12m` pill in the top bar** while active (click = disarm instantly). IPC target `sudoswitch` (arm/disarm/status) so it's bindable and scriptable like everything else.
- **Visibility (the "special color" ask):** two layers — a Fish `sudo` wrapper function prints an amber ⚡ banner line before executing (so every privileged command flashes inside agent transcripts, which we can't restyle from outside), and Kitty **marks** (`mark1` regex on `\bsudo\b`, amber) highlight the word in dev-terminal scrollback live.
- **Framing:** this is convenience, not hardening (§15 defers security work); it's the verbal approval made mechanical, visible, and self-expiring — and it composes with `agent.slice` containment. Register: M26.

### 7.6 Prompt & editor
- **Starship:** tokyo-night structure refactored onto a generated `[palettes.aurora]` block (template in §4's fan-out) — directory=blue, git=purple, langs/duration=teal.
- **Neovim (§14):** LazyVim provisional (most VS-Code-like, tokyonight, proven in this aesthetic lane) — **decision gate after the workspace lands:** startup/RAM measured on the i3; fallback NvChad/kickstart. Until then VS Code (themed via caelestia integration) stays the GUI editor.

---

## 8. THE SYSTEM LAYER

### 8.1 Hardware truth (T2)

The substrate is `nixos-hardware`'s `apple-t2` module (already imported): apple-bce in initrd, T2-patched kernel + PipeWire, `intel_iommu=on iommu=pt pm_async=off`. The manual `/etc/nixos/firmware/brcm` adapter stays; `hardware.apple-t2.firmware.enable` stays **off** (never both).

- **Webcam (B5) — the honest risk item:** t2linux State says Working via apple-bce; mechanism under-documented; **treat as probable-not-proven.** [GATE] `/dev/video0` enumerates → mpv preview color-sane → Chrome/Meet selects it → suspend/resume recheck (+ `modprobe -r apple-bce && modprobe apple-bce` recovery test). Ship the **Test camera** action regardless (§5.7); if it fails, the answer is stated plainly + a USB cam is the reliable path (the action lets you pick any `/dev/video*`).
- **In-use dots (B4):** mic dot = derived property over caelestia Audio's existing `streams` list (input-stream active); bar mic-mute toggle = iNiR `MicToggle` pattern. Camera dot = 1s `fuser /dev/video0` watcher (PipeWire can't see V4L2-direct Chrome) — small glue.
- **Speakers (C4):** `angelobdev/t2-easyeffects-preset` `mbp.json` as the default output preset (XDG data dir, autoloaded against the T2 speaker sink; limiter stays in-chain). Framed as "macOS-like default, trim by ear in the EQ" — no Air-specific DSP exists; never cross-apply the MBP16 array DSP.
- **Fan (C14):** t2fanrd — **already live in the flake with Alex's tuned curve (50/75 linear). Preserve verbatim**; the module generates `/etc/t2fand.conf` declaratively (do not hand-edit). Temps/RPM surface in sysmon; a thermal-throttle event feeds the health stream.
- **Keyboard backlight (B17/C13):** `brightnessctl -d 'apple::kbd_backlight'` (exact node confirmed live) behind the battery-popout slider; boot persistence via systemd-backlight; idle-dim/restore-on-keypress via `keyboard-backlightd` (small Rust, packaged as glue); resume re-apply hook if the live-test shows resets.
- **Gaming (§4.6):** xpadneo (BT) + xone (dongle/wired) both enabled; **the likely root cause of the recorded latency is BT×2.4GHz coexistence on BCM4377** — fix is 5GHz WiFi or wired/dongle, live A/B'd; `allow_tearing` + `immediate` rule for `steam_app_*`; PipeWire quantum **256** (min 128 / max 512 — never the 32-sample snippets on two cores); `xwayland { force_zero_scaling = true }` for crisp Steam at 1.5×; VRR off (fixed-refresh panel). [GATE] controller session feels macOS-snappy; `pw-top` clean during play.
- **Bluetooth LE tuning:** the uncommitted `hardware.bluetooth.settings.LE` (interval 7–9, latency 0) **is the Xbox fix — commit and keep** (§8.7).

### 8.2 Battery & power (B3)

UPower owns thresholds/action: `PercentageLow=20, PercentageCritical=10, PercentageAction=5, CriticalPowerAction=Suspend, AllowRiskyCriticalPowerAction=true` (zram-only machine — suspend is the honest action; hibernate never). Shell (iNiR-derived battery service) owns the UX only: one 20% normal warning, one persistent 10% critical, re-armed per discharge cycle; panel shows time-to-empty/full honestly. PPD actuates profiles: battery → power-saver, AC → saved preference (balanced default; performance = deliberate hold via `powerprofilesctl launch` for long builds); DMS's battery-aware 60Hz refresh downclock rides the Display service. Nothing else calls suspend.

### 8.3 Night light & audio lifecycle (B2/B4/C5)

- **hyprsunset** (first-party): 19:00–06:30 schedule, 6500K day / 4500K night default, System-surface toggle + warmth slider (iNiR control pattern), manual = override till next boundary. [GATE] eyeball 4500K on the panel: text neutral, teal/violet distinct, glass not brown.
- **Audio routing:** PipeWire `module-switch-on-connect` (physical devices only) + WirePlumber defaults explicit (`restore-default-targets`, moving streams follow default); 3.5mm is a route change, not the BT rule; match devices by stable IDs. **BT codecs:** WirePlumber BlueZ config `aac, sbc_xq, sbc`, A2DP for music (HFP only when a mic client opens). **Per-device EQ (C5):** EasyEffects autoload — speakers → C4 preset, each headphone → its AutoEq-exported preset (exact model only), unknown → passthrough; hardware stays the PipeWire default (EE follows it). [GATE] the full transition matrix with audio playing (speakers↔AirPods↔3.5mm; codec shows `aac`; mic client flips to HFP and back).

### 8.4 Disk, backup, health, portals (B6/B13/B14/B11)

- **Disk truth:** iNiR `ResourceUsage` df poll in bar/sysmon + caelestia StorageCard in the dashboard; thresholds on **free bytes**: amber <15GiB/85%, red <8GiB/92% (persistent + "Review generations"), re-arm at 18GiB. Never auto-deletes.
- **GC policy:** `nix.gc.automatic` weekly **after** a generation trimmer enforcing *keep ≥5 generations OR everything <30 days, whichever is more* (NixOS wiki trimmer adapted, dry-run action in Nexus › System); **no `--delete-older-than` on the GC itself.** A human-labeled **known-good GC root** pins the accepted closure (with its activation path recorded); "Mark current as known-good" is a Nexus button, never automatic. §15 lifecycle: delete gens 1–7 now; at acceptance, pin the accepted closure *first*, then wipe the era. `nh clean` covers user profiles.
- **Backup (B14):** `services.restic.backups.home` — **fully wired now, destination deliberately deferred (operator call 2026-07-21):** paths (`~/Documents`, `~/Pictures/Wallpapers`, project repos, `~/.local/share/mediacenter` — the Jellyfin data, `~/.local/state`), nightly `Persistent=true`, keep 7d/5w/12m, and the `createWrapper` restore/browse tooling all ship configured. The repository target (external disk and/or B2/rclone bucket) is the one missing input: until Alex sets it, the timer stays inert and Nexus › System shows **"Backup: choose a destination"** rather than a fake status; the moment a target + password file land in the secrets path, first run initializes and the status line goes live.
- **Health (B13):** `OnFailure=notify-failure@%n` template on user-relevant units (aurora-shell, skwd-daemon, restic, easyeffects, hypridle) → journal excerpt → **systembus-notify** bridge → notification history. The shell's own unit hardening (§2.2) makes "watchdog gave up" legible. restic failures ride the same channel.
- **Captive portals (B11):** NetworkManager connectivity check (plain-HTTP probe, single named setting) + `connectivity-change` dispatcher → user-unit handler → one actionable "This network needs a sign-in" notification (opens the probe URL); PORTAL ≠ LIMITED in the network panel.
- **System sounds (§4.9):** freedesktop sound theme, played by a small hook in the Notifs service, off by default, Nexus toggle.
- **Spellcheck (§4.5), honest scope:** hunspell dictionaries + Chrome spellcheck + gspell-capable GTK apps; **no system-wide autocorrect exists on Linux** — stated in the plan and in Nexus, not half-promised. Fish accept keys = Right-Arrow/Ctrl-F (defaults, documented; 2-minute live check).
- **Printing (§4.14):** `services.printing` + hplip; test page at acceptance.

### 8.5 Lid, suspend, and wake (open question #3 — resolved)

**Structure: logind owns the lid; hypridle owns lock-before-sleep; T2 suspend sits behind a hardware acceptance gate; the Hyprland switch-bind exists only as a documented fallback.**

- logind: `HandleLidSwitch/ExternalPower/Docked = suspend`, `LidSwitchIgnoreInhibited = yes` (a stuck media inhibitor must never cook a closed laptop in a bag).
- hypridle (end-4 config pattern): staged dim → lock → DPMS → suspend on idle; `before_sleep_cmd = loginctl lock-session`; **`inhibit_sleep = 3`** (sleep waits until the session-lock client reports locked — pairs with the lock's ready-handshake); `after_sleep_cmd` restores DPMS/focus. One lock path covers every sleep source, including UPower's 5% action.
- T2 reality: apple-bce upstream doesn't support suspend/resume; t2linux ships an unload-before-sleep/reload-on-wake workaround, with conditional Broadcom steps only if WiFi breaks. **Policy: add nothing speculatively.** [GATE — suspend acceptance] repeated lid cycles on AC + battery: exactly one suspend per close; wake lands on the lock screen; keyboard/trackpad/audio/mic/camera/WiFi/BT verified after every cycle + one long sleep. Only reproduced failures earn the apple-bce pre/post unit (declarative), and only WiFi failures earn the brcmfmac steps. If logind provably never sees the lid switch: set logind lid handling to ignore and bind the **exact named** switch (`switch:on:<name>`) to suspend — never the unqualified form (fires on open too).

### 8.6 Agent workloads vs. a smooth desktop (open question #4 — resolved)

**Structure: one `agent.slice` for the agents; separate containment for nix-daemon; the fan curve handles heat; weights — not quotas — keep the UI responsive without wasting idle cores.**

- `agent.slice`: `CPUWeight=20`, `IOWeight=20`, `MemoryHigh=50%` (~4GiB), `MemoryMax=70%` (~5.6GiB), swap untouched (zram stays). Launch scopes add `Nice=10` + idle-IO. Work-conserving: agents get the whole machine when it's idle, and lose instantly to a keystroke, a panel open, or audio when it isn't. No CPU quota at v1; a 200% aggregate quota is the documented second stage if the dual-agent trial still stutters (after confirming logical-CPU count on-machine).
- Every §7 launcher enters the slice — there is no bypass launcher; the "full speed" override is a visible, temporary toggle.
- **Nix builds:** `nix.settings.max-jobs=1, cores=2` + CPUWeight/IOWeight on `nix-daemon.service` (daemon builders escape user slices — contain them where they live).
- This *is* the §10 "smooth on this hardware" mechanism for the roughest daily load — [GATE] two agents at full tilt: typing, cursor, workspace swipe, panel open, and audio all stay clean; a runaway memory agent hits the slice ceiling, not the desktop.

### 8.7 Protected state & config reconciliation (open question #5 — resolved)

Located and inventoried (verified this session):

| Item | Where it lives | Action |
|---|---|---|
| **Xbox controller BT tuning** | uncommitted `modules/nixos/desktop.nix` (`bluetooth.settings.LE` 7–9/0) | **Commit in Stage 0; keep verbatim** |
| **t2fanrd + curve 50/75** | uncommitted `flake.nix` input + `laptop-power.nix` | **Commit; keep verbatim** (supersedes the research's 55/82 suggestion — this is the live-tuned value) |
| **VA-API (iHD)** | uncommitted `desktop.nix` (`hardware.graphics` + intel-media-driver) | **Commit; keep** (serves Chrome decode + recorder encode) |
| **Media Center ("Moonfin") stack** | `~/.local/share/mediacenter/` (server.js, Jellyfin data/cache), `~/.local/bin/mediacenter`, `mediacenter.desktop`, `mediacenter-cache-cleanup.{service,timer}` | User-dir — survives rebuilds by construction. **Add to restic paths; pin the launcher in the dock; never auto-start Jellyfin** (on-demand is the design) |
| **TV firewall rule** (LG TV MAC-accept) | **channel `/etc/nixos/configuration.nix`** — *not in the flake* | **Stage 0: read it (sudo), port the exact rule into `modules/nixos/media-center.nix`**, plus any other post-Jul-16 additions found in the same diff |
| BT pairings, keyring, Jellyfin ServerId | `/var/lib/bluetooth`, `~/.local/share/keyrings`, mediacenter data | State, not config — no rebuild touches them; do not regenerate machine identity |
| Bluetooth QML + `equalizer-state` edits | uncommitted in the repo | Commit; carry the equalizer-state backend into §5.9; port any BT panel improvements' *behavior* into the new BT popout before deleting the old tree |

**Stage 0 exists because of this table:** the machine currently has two config lineages (flake + channel edits) and pending work in the tree. Until they're reconciled into the flake, nothing else ships.

### 8.8 App lifecycle (§4.2/§13/C3)

- **Two lanes:** GUI apps default **declarative** (`modules/nixos/apps.nix`; picked via tuxmate's catalog UX or nix-software-center's "System" mode; activated by `nh os switch` — one command, diff shown automatically). **Imperative lane** for click-and-have-it-now: nix-software-center in `nix profile` mode (pin a known-good rev; verify its declarative writer against our flake layout before ever enabling that mode).
- **Agents:** the npm-global lane, durable (`NPM_CONFIG_PREFIX=~/.npm-global` + sessionPath + `.npmrc` + pinned nodejs_22 — already working; make it declarative). `npm install -g @anthropic-ai/claude-code@latest @openai/codex@latest` and `claude update` keep working; agents never go through nixpkgs.
- **Updates & rollback (C3):** `programs.nh` (`flake = "/home/alex/nix"`); Nexus › System fronts `nh os build` (check + diff) / `switch` / `boot` / `--rollback` — the diff-and-undo superpower as a page, per §5.8. `nvd`/`nix store diff-closures` are the parse targets.
- **§13 apps** all land in `apps.nix` at Stage 6 (VS Code, Spotify+spicetify, Discord, mpv, btop, fastfetch, cava, OBS, Audacity, Python/pip, Rust, Docker, gh) — each opened once at the gate ("install path works" acceptance).
- **Bonus affordances:** launcher "Run once" (`nix run nixpkgs#`), `nixos-rebuild build-vm` "test this update in a VM" (cut-list).

---

## 9. THE MANUAL-WORK REGISTER (honest scope — everything that is more than config)

Everything below is development or substantial adaptation. If it isn't in this table or a §5 adaptation delta, it's config/vendoring — and if an execution session finds itself doing unlisted development, that's a plan bug to flag, not to absorb silently.

| # | Work | Size | Anchor |
|---|---|---|---|
| M1 | Top taskbar module — new compose: ilyamiro geometry, iNiR task behavior, caelestia components (+ windowinfo popout re-anchor) | **M** | §5.1–5.2 |
| M2 | Top-bar right cluster (media chip, pills, System button) + ilyamiro expanded-tier panels on chassis services | **M** | §5.1–5.2 |
| M3 | Drag-task→workspace graft (DMS DropArea chain onto bar delegates) | S–M | §5.1 |
| M4 | MPRIS→desktop-entry source-app resolver (~50 lines, unsourced anywhere) | S | §5.1 |
| M5 | DMS dock behavior as a rail entry (service/theme mapping) + agridyne glass-tile delegate + Kurve strip wiring | **M** | §5.3 |
| M6 | Composite lock (ilyamiro identity × Vast engine × DMS lifecycle × pills) | **L** | §5.10 |
| M7 | Calendar rebuild (hero clock, month grid, event dots; curved hourly timeline is Shape-built — no community artifact exists) | M | §5.4 |
| M8 | Music/EQ stage-2 composition (ilyamiro EQ subview on equalizer-state backend) | M | §5.9 |
| M9 | Theme transaction wrapper (stage→validate→publish→report) + new templates (Kitty, Starship, hyprbars, regreet, skwd UI, Qt/Kvantum) | **M** | §4 |
| M10 | SkwdBridge subscriber service (~80 lines) + evening-variant timer (~15 lines) | S | §4.1 |
| M11 | Scheme-generator patch: pinned surface ladder + accent tone/chroma clamps | S–M | §4 |
| M12 | Nexus new pages: Input, Display (DMS front), System (updates/rollback/GC/backup/health), Startup apps; glass-tuner sliders | **M–L** (page by page) | §5.8 |
| M13 | Semantic notification filter + iNiR ingress-cap port | S–M | §5.6 |
| M14 | Nmcli password-path replacement + NetworkUsage two-bug fix | S | §5.2 |
| M15 | Alt+Tab live cycler (composition of carried preview components) | M | §5.16 |
| M16 | Clipboard panel composition (iNiR service + ilyamiro grid/morph) | M | §5.13 |
| M17 | window-minimize vendoring + taskbar-restore glue + minimized-task dimming | S | §6.2 |
| M18 | Dev workspace: toggle entry, agent-status tile, git-count script, launchers | S–M | §7 |
| M19 | Camera-in-use watcher; mic dot + bar mute (derived properties) | S | §8.1 |
| M20 | Health template unit + systembus-notify wiring; captive-portal dispatcher+handler | S | §8.4 |
| M21 | Plymouth aurora theme (recolor an existing minimal theme) + regreet theming | S | §5.11 |
| M22 | Generation trimmer service + known-good pin affordance | S–M | §8.4 |
| M23 | keyboard-backlightd packaging + idle-dim wiring | S | §8.1 |
| M24 | plocate-backed launcher file mode | S–M | §5.5 |
| M25 | DisplayConfig graft (DMS state/service mapping) | M | §5.2 |
| M26 | Sudo session switch: sudoers drop-in, glass askpass, keepalive/disarm service, bar pill, Fish banner + Kitty marks | S–M | §7.5 |

Explicitly **not** built: any from-scratch panel content, a second theming authority, a QuickShell per-window-button overlay (hyprbars owns that), drag-to-edge Aero glue (cut-list), a new wallpaper picker host (retired with the SliceDelegate plan).

---

## 10. THE BUILD SEQUENCE

Each stage ends at a gate; Alex tests before the next begins. Order chosen so every stage leaves the machine *more* usable than before it.

- **Stage 0 — Reconcile & baseline.** Commit the uncommitted work (§8.7); **set the `AlexbringsMercy/nix` upstream and push** (pushes repeat at every gate — §2.3). Read `/etc/nixos` (sudo), port the TV firewall rule + any other channel-side additions into the flake; flake becomes the sole authority. Reboot **[GATE]**: generation boots clean, `start-hyprland` warning resolved or root-caused, Media Center still reachable from the TV, controller still paired. Delete gens 1–7.
- **Stage 1 — Chassis up.** Vendor the caelestia fork (aurora-shell) + plugin build via Nix; aurora scheme with pinned ladder (M11); shell replaces the old QuickShell/Waybar/Rofi/SwayOSD trees (their keepers — equalizer-state, weather cache pattern, dunst fallback — carried first). Bar still vertical at this gate (stock caelestia) — **[GATE]**: shell runs supervised, launcher/dashboard/notifications/OSD/session/utilities/Nexus all open, IPC works, glass A/B evening happens here (§3.2), VA-API confirmed.
- **Stage 2 — The window model.** hyprbars + minimize + focus policy + input tuning (DWT quirk!) + gestures + keymap + detached-launch sweep. **[GATE]**: §6.2 checklist; the §5 input/window bug list retested line by line. *(Clarified 2026-07-28 — see §10.1.)*
- **Stage 3 — The top taskbar + expanded panels.** M1–M4 (rail stays native throughout — no downtime on the surfaces Alex already likes). **[GATE]**: §5.1 gate.
- **Stage 4 — Wallpaper & theme pipeline.** skwd-wall + daemon (awww retired), SkwdBridge, transaction, all templates (M9–M10); **import the Downloads wallpaper collection into the skwd library** (`wall.import` → `~/Pictures/Wallpapers`, tag the `dark/` subset). **[GATE]**: §4.1 gate — the one-breath recolor across every consumer, **plus the §3.2 glass A/B gate, moved here by explicit operator approval dated 2026-07-28** *(see §10.1)*.
- **Stage 5 — Rail dock entry + desktop layer + clipboard + polkit + switcher.** M5, M15–M16, desktop menu, hyprexpo. **[GATE]**: two-surface daily flow feels complete; rail hover-reveal feels "on demand," never in the way. *(Placement unchanged; clipboard scope confirmed 2026-07-28 — see §10.1.)*
- **Stage 6 — Files & apps.** Dolphin suite (theming, portals, udiskie, Ark, MIME map), apps.nix (§13 list), nh + store lanes, npm-global hardening. **[GATE]**: USB/trash/portal/upload checklists; every §13 app installed and opens.
- **Stage 7 — Boot & lock.** Plymouth, timeout 0, startup-manager default, greetd+keyring, regreet; the composite lock (M6) behind its **mandatory** gate; hypridle + lid policy + T2 suspend acceptance (§8.5). This stage has the two hardest gates in the plan — schedule Alex time.
- **Stage 8 — Dev workspace & agents.** §7 complete: toggle, launchers, slice, hooks, zellij, fzf, Starship; sysmon workspace. **[GATE]**: §8.6 dual-agent responsiveness trial; hooks toast; a killed Kitty window doesn't kill an agent.
- **Stage 9 — Guardrails & Nexus completion.** Battery/night-light/audio-lifecycle/disk/GC/backup/health/captive-portal (§8.2–8.4); Nexus pages M12 in ship order; dashboard calendar (M7); music stage-2 (M8). **[GATE]**: guardrail acceptance matrices (audio transitions, thresholds, restic run, health event).
- **Stage 10 — Hardware truth & polish.** Webcam gate, speaker preset A/B, kbd-backlight, gaming legs A–D, OCR, color picker, emoji, system sounds, micro-status, C-item sweep (§11). **[GATE — acceptance]**: the §6.1 walk end-to-end with Alex; §11 do-not-regress checklist; pin known-good; §15 generation wipe; retire this plan's Stage markers into EXECUTION_LOG.

Dependencies are linear except: Stage 4 can start once Stage 1's scheme exists; Stage 6 and 7 are order-swappable; Stage 8–10 items may interleave as gates allow. **Nothing in any stage is a throwaway** — every artifact is the end-state artifact.

### 10.1 Sequencing clarifications (2026-07-28, active generation 26)

Operator-approved sequencing only. **The architecture in §1–§9 is unchanged.** Full decision text: `EXECUTION_LOG.md` → **OPERATOR DECISIONS — 2026-07-28 — ACTIVE GENERATION 26** (decisions 15–17). Close-out brief: `STAGE2_CLOSEOUT_WORK_ORDER.md`.

**Stage 2 — screenshot colour fidelity pulled forward (decision 15).** Stage 2's close-out now includes an operator-approved urgent screenshot colour-fidelity correction. Both region **and** full-screen captures currently carry a uniform mauve/pink cast, so the region-selection overlay is *not* established as the sole cause. Required: diagnose **both** capture paths (is the physical display tinted, or does PNG capture change the colours?); **pull forward the final §5.12 capture architecture** rather than repairing the interim path; ship no throwaway interim screenshot implementation (MASTER §1.6). **Stage 2 cannot close while screenshots retain a uniform tint or a capture overlay baked into output.** This is a targeted capture correction — it is not authorisation for the Stage 4 palette or theme work.

**Stage 4 — the glass A/B gate lives here (decision 16).** §3.2's glass A/B gate was a Stage 1 gate item; its move to Stage 4 is now explicitly approved by Alex, dated 2026-07-28, because the final wallpaper and palette pipeline lands here. The Stage 4 gate must include: `size 12 / 1-pass` versus `size 8 / 2-pass`; `xray = true` versus `false`; the optional `decoration:glow` rim accent; actual wallpaper visibility through the surfaces; and Alex's physical visual approval. **The current glass settings are not accepted** — the live `size 8 / passes 2 / vibrancy_darkness 0.38` is an unratified interim value, not a shipped decision. Stage 4 cannot close without Alex physically approving the result.

**Stage 5 — clipboard scope confirmed, placement unchanged.** Clipboard history remains Stage 5 as written in §5.13, and its surface is committed scope: `cliphist` + `wl-clipboard` ingestion; the iNiR service/panel; the ilyamiro grid/morph presentation; `Super+V`; a clickable bar/System entry; persistent history across reload. **Only the privacy-policy layer** (sensitive-type exclusion, expiry) remains deferred per MASTER §15 — the clipboard surface itself is not deferred and must not be treated as optional.

---

## 11. THE BONUS ROSTER (generous by instruction — Alex cuts here, not us)

Already woven into §5–§8: OCR (C6) · lyrics (C8) · color picker (C9) · auto-cycling + evening variant (C10) · Chrome polish pack (C16: VA-API shipped, swipe-nav flag, PiP float rules) · micro-status (C17) · Tailscale slot (C18, free inside the VPN manager) · screen-share DND (C15) · cursor-zoom accessibility (C19) · calendar ICS dots (C20) · keep-awake (idle inhibitor) · hold-to-confirm fills · settings search · Run-once · smart auto-hide · battery refresh-downclock · agent Fish abbrs · fastfetch art.

Promoted out of this list 2026-07-21 (now shipped in §5.2): ilyamiro's radial Bluetooth expanded view and FocusTime (opt-in page). Added to the plan: the sudo session switch (§7.5) and animated-wallpaper opt-in (§4.1).

Optional layer (in the plan, first to cut):
- **Desktop widgets** (iNiR edit-mode; clock + weather only) — C11.
- **Bar pomodoro** (iNiR timers) — C12 tail.
- **KDE Connect** (C7) — included as module + firewall ports + indicator; **needs Alex's phone answer** (Android = full; iPhone = files/clipboard only).
- **hypr-kinetic-scroll** (macOS inertial feel; A/B vs scroll_factor fix) and **hypr-dynamic-cursors** (delight) — perf-gated.
- ilyamiro radial Bluetooth expanded view; iNiR DockPreview live thumbnails (perf-gated); snappy-switcher trial; drag-to-edge Aero glue; `build-vm` update sandbox; caelestia scheme/variant launcher modes; background Visualiser + DesktopClock.
- **Deferred stays deferred (§14):** animated wallpapers, matrix boot theme, Alienware port, self-hosted music, clipboard privacy policy + WiFi-argv hardening (security bundle).

---

## 12. THE SIX OPEN QUESTIONS — RESOLVED

1. **skwd daemon vs awww →** Full skwd-wall app **with** its daemon; **awww retired**. The daemon's socket API + `skwd.wall.applied` broadcast (verified on disk) gives the palette pipeline a patch-free hook; its 38 shader transitions are the approved experience; its native rotation covers auto-cycling with theming reacting to every apply. The MASTER §6 "vendor SliceDelegate" instruction is retired as obsolete. (§4.1)
2. **How much caelestia →** The shell **is** the chassis (fork = aurora-shell): plugin, services, drawers, launcher, dashboard, windowinfo, tray, notifications, OSD, session, utilities, areapicker, Nexus, CLI — and after the 2026-07-21 revision, **its bar stays vertical as the left rail**, with a new ilyamiro-geometry top taskbar beside it. Replaced: lock (composite), wallpaper rendering (skwd). Grafts ride inside it. Rationale: Alex's approved surfaces are caelestia code; the plugin we'd need anyway collapses the slice-vs-shell economics; Nexus/lyrics/VPN/appdb arrive nearly free; one authority everywhere. (§2.1)
3. **Lid close →** logind owns suspend; hypridle locks-before-sleep with `inhibit_sleep=3`; `LidSwitchIgnoreInhibited=yes`; T2 suspend ships behind a repeated-cycle acceptance gate, with the apple-bce/brcmfmac workarounds added **only** on reproduced failure; Hyprland switch-bind is the documented fallback, exact-named, never unqualified. (§8.5)
4. **Agent workloads →** `agent.slice` (CPUWeight 20 / IOWeight 20 / MemoryHigh 4GiB / MemoryMax 5.6GiB, nice+idle-IO scopes), all §7 launchers inside it; nix-daemon contained separately (`max-jobs 1, cores 2` + weights); no hard quota unless the dual-agent gate demands it; t2fanrd keeps it cool and audible-sane. Work-conserving weights are how "smooth on this machine" and "agents at full speed when idle" coexist. (§8.6)
5. **Recent config to preserve →** Located, itemized, and staged: Xbox BLE tuning + t2fanrd curve + VA-API (uncommitted flake changes — commit verbatim); Media Center stack (user-dir; backed up; docked; never auto-started); TV firewall MAC rule (channel config — ported to the flake in Stage 0); pairing/keyring/ServerId state untouched. (§8.7)
6. **Current broken things →** Screenshot keybind → rebuilt capture chain (§5.12, Stage 2/4); brightness keys → rebound through the shell's brightness service + OSD (Stage 2); start-hyprland warning → Stage 0 reboot gate root-cause; all three die inside the clean-state stages rather than being spot-patched. (§10)

---

## 13. SOURCE MAP (consolidated attribution — repo → what we take)

| Source (all under `~/nix/repos/` unless noted) | Taken |
|---|---|
| `caelestia/shell-main/shell-main` | **The chassis** (§2.1 manifest); btop theme; fastfetch art; Fish abbrs |
| `caelestia` main repo + `cli-main` | Hyprland Lua patterns (gestures/keybinds/rules), `toggle.py`, CLI subcommands, scheme/theme fan-out |
| `liixini-skwd-wall` (+ its `skwd-daemon` flake input, pinned) | The entire wallpaper system |
| `dankmaterialshell` | Dock (11 files) · DisplayConfig + DisplayService · OverviewWidget drag chain · Lock.qml lifecycle donor · greeter reference |
| `inir` | Polkit dialog · Cliphist service/panel · emoji DB+picker · desktop ContextMenu · MicToggle · Battery service · Hyprsunset service/controls · ingress caps · systemd unit hardening · Qt/GTK/Kitty theme writers · ShellExec scope pattern · AltSwitcher perf guards (pattern) |
| `ilyamiro-nixos-configuration` | **The expressive presentation layer:** top-bar geometry/sections · expanded panels (battery ring, liquid audio orb, radial Bluetooth, network gauge) · EQ widget · lock visual identity · clipboard grid/morph · hold-to-confirm fill · motion patterns · FocusTime |
| `saatvik333-hyprland-dotfiles` | Terminal-experience quality bar (startup art standard; LazyVim proven in this aesthetic lane) |
| vast-shell (web, rev `2884937…`) | Lock depth planes + gated unlock engine |
| omarchy-desktop-shell (web) | `window-minimize` + hyprbars config values |
| `hyprwm/hyprland-plugins` (flake) | hyprbars · hyprexpo |
| `luisbocanegra/kurve` (via agridyne) | Cava strip renderer + exact sizing |
| `agridyne-dotfiles-dt/rice-contents` | Glass-tile motif · KDE color mapping · negative-space discipline · chrome/content rule |
| `end4-dots-hyprland` | hypridle config · animation curve tables · snap values |
| `cxorz-dotfiles-hyprland` | FeatureTile split-tile pattern · OSD timing references |
| `linuxbeginnings-hyprland-dots` | ML4W radial-aurora gradient technique |
| `abusoww-tuxmate` | Install-UX bar + declarative snippet lane |
| snowfallorg/nix-software-center · nix-community/nh · nvd · restic · udiskie · systembus-notify · gpu-screen-recorder · t2fanrd (in flake) · angelobdev/t2-easyeffects-preset · AutoEq · hyprsunset · hyprpicker · tesseract · zellij · fzf+bat+fd · Starship (tokyo-night preset) · LazyVim · snappy-switcher (cut-list) · regreet/tuigreet · plocate | Named tools, roles as cited |

## 14. NO-SESSION LIST ACCOUNTING (nothing vanished)

A1→§2.1/§5.1 · D1→§2.1 (comparison run, drawers win) · D2→§5.9 (staged) · D4→§5.2 (bug-fixed donor) · D5→§5.6/M13 · D7→§3.2 gate · process workspace→§5.18 · Ctrl+Shift+T→§7.4 · MIME map→§5.17 · CUPS→§8.4 · VA-API→§8.7/§5.12 · Chrome pack→§11/§6.2 · weather Austin→§5.4 · purple film→§5.12 · capture/launcher binds→§6.4 · system sounds→§8.4 · USB/trash→§5.17 · C17/C15/C19→§3.4/§5.6/§6.2 · C9→§5.7 · generation cleanup→§8.4/§10 · glass alpha/palette slots/EasyEffects/detach/motion/ML4W→§3–§4 · C6/C8/C11/C12/C20→§11/§5.4 · B18 map→§6.3 · deferred security items→§11 · **C7/C18 user questions→§11 (flagged for Alex)**.

## 15. BUG LOG TRACEABILITY (§5 of MASTER → where it dies)

Input: DWT→§6.2(quirk) · repeat→§6.2 · scroll→§6.2 · gestures/pinch→§6.2. Windows: 3rd-window→§6.2 · corner-resize→§6.2(honest) · hover-focus→§6.2(`follow_mouse 0`) · ws2 dead→§5.1(QuickShell workspaces) · move-between-ws→§5.1/§6.2 · agents-can't-close→§6.4(Kitty) · bar-restart-kills→§5.1+§2.2(`KillMode=process`). Bar/panels: cramped/media-size→§5.1(34px) · CPU=RAM→§5.1 · calendar wall→§5.4 · no audio panel→§5.2 · capture-under-battery→§5.7 · notif spam→§5.6. Launcher: broken visuals/Escape-only/Cmd+Space→§5.5. Visual: opaque glass→§3.2 · non-universal palette/cheap gradients→§4/§3.4 · EasyEffects visible/preset path→§5.9 · Thunar dated→§5.17(Dolphin) · picker jank→§4.1 · no morphing→§3.3. Capture/keys: purple film→§5.12 · Cmd+Shift+S/Print→§5.12 · Kitty Ctrl+T→§6.4 · weather→§5.4.

---

*Everything before this document collapses into it. Build the OS.*
