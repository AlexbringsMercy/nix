# THE GRAND PLAN — Aurora
## The complete build plan for the NixOS + Hyprland desktop on the 2020 MacBook Air (T2)

**Status:** Authoritative. This document supersedes `OVERHAUL_PLAN.md`, `BUILD_PLAN.md`, and every research recommendation where they conflict. Execution sessions work from this document and only this document. `MASTER_REQUIREMENTS.md` remains the requirements ledger this plan answers to; where this plan makes a different call than a research file, the divergence is stated inline with the reason.

**Author:** Fable, head designer. Written 2026-07-21 after full reads of MASTER_REQUIREMENTS, macbook-build-spec, SESSION_PREAMBLE, SYNTHESIS, GAP_REVIEW, caelestia-full-inventory, visual-design-reference, all ten research session outputs, the no-session list, EXECUTION_LOG, the relevant OVERHAUL_PLAN sections, and direct on-disk verification of the skwd-wall and caelestia repos.

**Architecture revision:** 2026-07-29, after Alex re-opened the bar/window split against the original agridyne, caelestia, and ilyamiro visual references. This revision corrects source-role drift, removes duplicate app/status surfaces, replaces the special-workspace minimize model, defines deterministic two-pane snap behavior, and records the approved parallel/batched execution workflow.

**Daily-QoL revision:** 2026-07-29, after operator review of Nix application lifecycle. This revision makes Windows-equivalent native in-app updating the minimum for applications whose Linux builds actually expose an updater, defines the strictly graphical fallback for the proven no-native-updater case, caps retained application versions, protects Claude Code and Codex from rebuild-time shadowing/downgrades, and promotes broad correction suggestions from passive spellcheck to a Stage 6 acceptance requirement.

**Naming boundary:** **Aurora is the project/shell codename, not a color scheme.** References to the teal/purple/green aurora-borealis look use **Northern Lights**. The product theme is wallpaper-agnostic: glass is persistent, while light/dark mode, surface colors, text colors, accents, gradients, bars, panels, applications, and the lock screen all adapt coherently to the active wallpaper.

---

## 0. RULES OF ENGAGEMENT (for every execution session)

1. **This document is the source of truth.** If an instruction here is ambiguous, the answer is in the cited source repo — open it and read it. It is never "write your own version."
2. **Every component has a source attribution (repo + path).** "Adapt" means: vendor the cited files, make the minimal changes listed in the adaptation delta, keep the original structure recognizable. If you find yourself writing a new file that does what a cited file already does, stop — you are off the plan.
3. **Any subagent you spawn must read `~/nix/SESSION_PREAMBLE.md` first.** No exceptions. That file explains why.
4. **[GATE] markers are live test gates.** Work stops at a gate until the listed checks pass on the physical machine, with Alex present for anything visual or feel-based.
5. **Report honestly.** If a test fails, the log says it failed. If a step was skipped, the log says so. If a source file turned out different from this plan's description, flag it — do not silently improvise.
6. **Do not regress §11 of MASTER_REQUIREMENTS** (font rendering, cursor states, tap-to-click, two-finger scroll, boot WiFi, Kitty Ctrl+C/V, dual-boot rollback, agent execution, Chrome Wayland).
7. **Protected state (never clobber):** see §8.7. The Media Center stack, the TV firewall rule, the Xbox controller Bluetooth tuning, Bluetooth pairings in `/var/lib/bluetooth`, `/etc/nixos/firmware/brcm`, the T2 invariants of MASTER §10, and the user-owned Claude Code and Codex installations/config/session state. A Nix activation may provide runtimes and PATH ordering; it may not silently replace, shadow, or downgrade an agent binary.
8. **Source-role fidelity is binding.** A donor may supply structure, behavior, visuals, motion, or a backend only in the role assigned by this plan. Do not preserve a donor's unrelated modules merely because they ship together, and do not make a secondary donor the owner of a surface without Alex's explicit approval.
9. **Freeze expensive batches before compiling.** Before a Hyprland/plugin or other hour-class build, publish a compact manifest showing every intended item is code-complete, reviewed, and included. A validation build may run early only for a stated technical reason; it is not an intermediate deployment. Coherent closure = one build, one boot-only deployment, one reboot, one gate unless Alex approves otherwise.
10. **Parallel future-stage work is allowed and expected.** During builds, reboots, operator waits, or current-stage testing, later-stage implementation may proceed in an isolated branch/worktree when dependencies permit. Keep commits and build inputs stage-pure; do not merge or deploy future-stage work into the current gate until intended.
11. **Ordinary UI actions require ordinary UI paths.** Hotkeys are optional shortcuts, never the only practical way to minimize/restore, switch windows, open controls, or recover state.
12. **Native application behavior is the update UX contract.** When an application's native Linux build has its own update/check/install/relaunch UI, that exact in-app path is the required primary experience and the invisible backend adapts to it. No extension, injected replacement button, global app-update notification, terminal command, or central updater is an accepted substitute. A separate graphical updater path is allowed only after source/runtime/package evidence proves the native Linux build truly has no updater UI.

---

## 1. THE DESIGN

One sentence: **a cohesive glass operating system whose entire visual palette follows the active wallpaper, driven through visible UI first, built from the community code Alex selected, and kept smooth on a two-core MacBook Air.**

**Aurora is the project codename only.** It does not prescribe teal, purple, green, darkness, or an aurora-borealis look. The specific teal/purple/green family is the **Northern Lights** palette/preset. A red wallpaper may produce a polished oxblood/crimson glass system; a cream/yellow wallpaper may produce a light ivory/gold glass system; a dark blue or green wallpaper remains richly blue or green rather than collapsing to black panels with a colored outline.

The desktop is two complementary surfaces and a wallpaper:

- **The top information/widget bar** follows ilyamiro's top-bar composition nearly 1:1: independent glass islands for search/notifications, workspaces, now-playing/music+EQ, clock/date/weather, tray/language, network, Bluetooth, audio, battery, and the small approved system additions. It does **not** duplicate pinned, running, or minimized applications.
- **The left application/work rail** follows caelestia's vertical app-rail model: launcher, pinned apps, current-workspace running windows, current-workspace minimized windows, previews/grouping, and optional app-centric visualizer/power affordances. It does **not** duplicate the top bar's network/Bluetooth/audio/battery/calendar/tray stack.
- **The wallpaper** is the visual source of truth. It drives one coherent semantic palette across the top bar, left rail, panels, notifications, application chrome, terminal, file manager, lock screen, borders, icons, text, and effects. Glass remains the persistent material; no fixed hue family or fixed dark ladder is the product identity.

This is the governing division of labor: **top = system awareness and independent widgets; left = applications, windows, and work flow.** The same app never appears as a task on the top and again on the left. A minimized window stays part of its original workspace, disappears from layout, remains dimmed in the left rail, and returns with one click.

Underneath the glass is one coherent machine, not a parts bin. One shell process owns every surface. One semantic palette chain recolors everything. One wallpaper daemon renders every transition. One settings app configures it all. Every popup opens in ~260ms and closes when you click anywhere else. Nothing pops; everything slides, fades, or morphs. Cinema — the 700–1200ms choreography — is reserved for the lock screen and first expansion of a rich widget; daily clicks are never slowed for beauty.

The win condition, walked end to end in §6: press power → Aurora-branded splash → a wallpaper-coherent lock screen with real depth-of-field → click, type, you're in → everything from restoring a minimized file manager to changing audio output is one or two visible clicks away. At least as easy as Windows and macOS; more cohesive than either; smooth on *this* hardware.

### The five structural decisions (summary — full reasoning in §12)

1. **The shell chassis is caelestia.** We fork `caelestia-dots/shell` into **aurora-shell** for its plugin, services, drawers, launcher, window previews, notifications, OSD, session, utilities, Areapicker, Nexus, CLI, and vertical rail foundation. The stock dashboard UI is disabled; reusable data/services may be retained.
2. **The two visible bars have non-overlapping owners.** ilyamiro owns the top widget-bar structure and independent expanding widgets; caelestia owns the left application/work rail. Agridyne supplies major visual direction where specified, not the information architecture.
3. **The wallpaper system is the full skwd-wall application and daemon.** Its apply event triggers the palette transaction; awww is retired.
4. **The project palette chain is wallpaper-triggered, mode-aware, full-system, and atomic.** The patched caelestia scheme engine is the single semantic authority; skwd triggers it; iNiR/agridyne provide consumer mappings; Hellwal is fallback. It derives the complete light or dark color system—not merely accent colors. Matugen is not the system-wide authority.
5. **The window model is mouse-first and workspace-coherent.** Hyprbars provides ordinary controls; keyboard focus changes on click while scrolling follows the pointer; exact left/right two-pane snap minimizes surplus same-workspace windows; minimize never creates a user-visible or conceptual workspace.

## 2. THE ARCHITECTURE

### 2.1 The chassis and source-role decision (open question #2 — resolved, corrected 2026-07-29)

**Decision: carry caelestia's shell as the foundation of the one QuickShell instance, forked into `~/nix/modules/home/aurora-shell/`, while replacing its final bar information architecture with the explicit split in §1/§5.1.**

The running shell remains caelestia's `shell.qml` composition: C++ plugin, typed config, sensors, cava/beat, lyrics, app database, calculator, shared components, drawer coordinator, services, and IPC. The fork is not permission to ship every stock surface unchanged. The final product uses each donor only for the role Alex approved.

**Why the chassis still wins:**

- Caelestia already owns the mature services and surfaces Alex selected: launcher, notifications/history, OSD, session, utilities, Areapicker, Nexus, window previews, tray plumbing, and the vertical rail foundation. Dashboard data/services may be reused, but the stock dashboard UI is not a final surface.
- Its plugin supplies the sensors, visualizer, lyrics, app ranking, and calculator required elsewhere, so keeping the complete chassis remains cheaper and safer than extracting slices.
- Caelestia's drawer coordinator remains the one popup coordinator. Independent ilyamiro-style widgets are separate anchored surfaces on that coordinator, not one unrelated morphing hub.
- **Correction:** carrying caelestia does not make its stock status-heavy rail the final rail, and ilyamiro geometry does not make the top bar a Windows taskbar. Those were synthesis errors now retired.

**Fork manifest — keep, change, disable, replace:**

| caelestia module | Verdict | Final role / boundary |
|---|---|---|
| `plugin/` | **KEEP** | Config, sensors, cava/beat, lyrics, appdb, qalculator, blobs, lazy list. |
| `services/` | **KEEP, patch as specified** | Backends for both bars and panels; weather Austin; network/password and usage fixes. |
| `components/` | **KEEP** | Shared controls/tokens; retimed and restyled. |
| `modules/drawers/` | **KEEP** | One panel coordinator for independent surfaces. |
| `modules/bar/` | **KEEP as left app/work rail; substantially prune** | Launcher/pinned/current-workspace running+minimized apps/previews. Remove final network/BT/audio/battery/calendar/tray duplication. §5.1/§5.3. |
| `modules/bar/popouts/` | **KEEP as backend/content donors; re-anchor** | System popouts move under corresponding top islands; app previews remain anchored to left-rail app entries. §5.2. |
| `modules/windowinfo/` | **KEEP and extend** | Live previews, exact-window selection, context actions; used by rail groups and Alt+Tab. |
| `modules/dashboard/` | **DISABLE final UI; retain reusable data/components only** | No dashboard drawer, hover trigger, swipe trigger, or duplicate tabs. Calendar/weather/media/resource backends feed independent top widgets, Nexus, and sysmon where useful. §5.4. |
| `modules/launcher/` | **KEEP full-fat** | Search/app launcher; drop WallpaperList; visible entry on rail and top search island. |
| `modules/sidebar/` | **KEEP** | Notification history; opened from top bell/gesture. |
| `modules/notifications/` | **KEEP** | Notification server/cards plus iNiR policies. |
| `modules/osd/`, `modules/session/` | **KEEP** | Restyle; hold-to-confirm destructive actions. |
| `modules/utilities/` | **KEEP, extend** | System actions surface. |
| `modules/areapicker/` | **KEEP** | Final region capture/OCR geometry source. |
| `modules/nexus/` | **KEEP, prune + extend** | Settings app. |
| `modules/lock/` | **REPLACE** | Composite in §5.10: agridyne visual direction + Vast depth/exit + selected ilyamiro interaction/motion + DMS lifecycle/status donors. |
| `modules/background/` | **KEEP with `wallpaperEnabled = false`** | Desktop context layer; skwd renders wallpaper. |
| `Shortcuts.qml`, IPC | **KEEP, extend** | Shared actions; add rail/app, display, switcher targets. |
| CLI (`caelestia` → `aurora`) | **KEEP** | Toggle/dev, screenshot/record/emoji, scheme fan-out; wallpaper points to skwd socket. |

**Graft boundaries:**

- **ilyamiro:** final top-bar structure and independent widgets, expanded music/EQ and system panels, motion/choreography, selected lock interaction details, clipboard presentation.
- **agridyne:** major glass/negative-space/app-button visual direction, KDE mapping, visualizer reference, and lock visual composition.
- **DMS:** DisplayConfig, drag/drop mechanics where needed, lock lifecycle, greeter/safety patterns; **not** primary owner of the rail.
- **iNiR:** polkit, clipboard service, context menus, notification caps, theme writers, systemd/performance patterns; **not** top widget bar ownership.
- **Vast:** lock depth planes and gated unlock engine.

Any source-role change beyond those boundaries is a plan divergence requiring Alex's approval.

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

Every action in this OS is reachable through an ordinary UI and may also have a shortcut; both call the same function. The shell exposes actions via `aurora shell ipc call <target> <fn>`; Hyprland binds optional keys to the same globals; top widgets, left-rail entries, and panels call the same handlers internally. Existing targets plus `railapps`, `displaypanel`, `switcher`, and the snap/minimize state service keep the keymap thin — deleting a bind never removes a capability.

---

## 3. THE VISUAL SYSTEM

This section is the concrete answer to "what does it look like." Execution agents copy these values; they do not interpret adjectives.

### 3.1 Palette — wallpaper-derived semantic roles, usually dark, fully colored

**Permanent identity:** glass, cohesion, readability, geometry, and motion. **Not permanent:** darkness, a fixed surface RGB, a teal/purple/green family, or black panels with colored trim.

The generator analyzes the active wallpaper and creates a complete semantic palette:

- **Auto mode is dark-preferred, not dark-forced.** A wallpaper that is dark, evening-toned, richly colored, or predominantly shadowed produces a dark theme. A dark red wallpaper produces deep burgundy/oxblood/crimson surfaces and related foreground/accent roles—not generic black glass with a red border. Dark blue, green, purple, gold, and other wallpapers likewise retain their own color identity throughout the system.
- **Clearly light wallpapers produce a light theme.** Cream, pale yellow, high-key white, and other clearly light images produce translucent ivory/cream/tinted-light surfaces with dark readable foregrounds. The system does not force a dark UI over a light composition.
- **Mode is based on the wallpaper's luminance distribution and composition**, not hue alone and not a simplistic “colorful = light” rule. Exact thresholds are tuned at the Stage 4 palette gate against Alex's real wallpaper library.
- **Every semantic family adapts:** background, surface ladder, foreground, muted foreground, borders, selection, error/warning/success, primary/secondary/tertiary, containers, gradients, window borders/glow, bars, rail, panels, notifications, application chrome, terminal, file manager, lock screen, and supported application themes.
- **Cohesion means full tinting, not accent sprinkling.** A red theme must read as a polished red system; a blue theme as a polished blue system. “Black bar + colored border” is a failed result.
- **Northern Lights** is one optional saved palette/preset for the teal/purple/green aurora-borealis family. **Aurora** remains only the project/shell codename.

| Semantic role | Dark-auto behavior | Light-auto behavior |
|---|---|---|
| `background` | deepest wallpaper-related tone, near-black only when the source supports it | light wallpaper-related base, usually ivory/cream/pale-tinted rather than pure white |
| `surfaceLowest` → `surfaceHigh` | a stepped, chromatically related dark ladder preserving the wallpaper's dominant family | a stepped, chromatically related light ladder preserving the wallpaper's dominant family |
| `onSurface` / muted | high-contrast light foregrounds, gently tinted where readable | high-contrast dark foregrounds, gently tinted where readable |
| border/divider | low-alpha light or complementary edge chosen from the generated scheme | low-alpha dark or complementary edge chosen from the generated scheme |
| primary/secondary/tertiary | wallpaper-derived roles with contrast/chroma guards | wallpaper-derived roles with contrast/chroma guards |
| semantic states | error/warning/success remain legible but harmonize with the generated family | same, with light-mode contrast targets |

**Contrast and quality guards:**

1. Meet readable contrast for text/icons and preserve clear state differences.
2. Preserve wallpaper hue identity unless doing so would make content unreadable.
3. Avoid pastel washout on dark themes and muddy gray washout on light themes.
4. Avoid forcing every wallpaper toward the Northern Lights family.
5. On analysis failure, retain the previous coherent palette and report the failure; use a neutral fallback only for first boot/recovery.

**User-facing control:**

```text
Theme mode
● Auto from wallpaper
○ Force dark
○ Force light
```

Auto is the default. Force dark/light keeps wallpaper-derived color families while changing the semantic tone range; it does not switch to a fixed universal palette.

### 3.2 Glass — persistent material, mode-aware color

The invariant is: **the wallpaper remains perceptible through the surface, the content stays readable, and the glass belongs to the current palette.**

| Surface class | Dark-auto starting point | Light-auto starting point |
|---|---|---|
| Top bar / left rail / main panels | generated `surfaceLowest` at ~0.52–0.64 alpha | generated `surfaceLowest` at ~0.38–0.54 alpha |
| Popouts / history / notifications | slightly more opaque than their anchor | slightly more opaque than their anchor |
| Inner cards | generated `surfaceLow` at ~0.40–0.52 or a low-alpha foreground wash | generated `surfaceLow` at ~0.28–0.44 or a low-alpha foreground wash |
| Tooltips | enough opacity to stay legible over any wallpaper | same |
| Kitty/app surfaces | mode- and palette-derived application theme; terminal opacity tuned physically | same |
| Hover/selected | brightness/contrast/elevation change within the generated family—never a random fixed color swap | same |

These are starting ranges, not fixed colors. Stage 4 tests them against dark red, dark blue/green, Northern Lights, evening, cream/yellow, and other representative wallpapers from Alex's real library.

**Blur is compositor-owned, one scoped pass — never per-surface QML blur, never a full-screen FBO.** Hyprland Lua starting point:

```lua
decoration = { blur = {
  enabled = true, size = 12, passes = 1, xray = false,
  contrast = 1.05, brightness = 1.0, vibrancy_darkness = 0,
}}
-- blur only named shell/picker layer namespaces
-- ignore_alpha starts at 0.10; tune against animation pop-in
```

**[GATE — glass/palette A/B, Stage 4, Alex present]**

Test at minimum:

- size 12/1-pass vs size 8/2-pass;
- `xray = true` vs `false`;
- dark saturated red wallpaper;
- dark blue/green wallpaper;
- Northern Lights wallpaper;
- dark/evening multicolor wallpaper;
- clearly light cream/yellow wallpaper;
- another clearly light wallpaper;
- generated window rim/glow in the wallpaper family, kept only if polished rather than gamer-like;
- top bar, left rail, popouts, notifications, lock, Kitty, Chrome frame, Dolphin and supported app themes all changing coherently.

Failure conditions include opaque panels, unreadable light glass, generic black surfaces with token colored edges, forced Northern Lights hues, mixed stale consumers, or a theme that changes accents without recoloring the actual system.

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

**The boundary rule:** *morphs happen within an anchor, never across anchors.* Top-bar islands expand beneath themselves and may morph between their own compact/detail states. Left-rail app entries may expand into grouped live previews beside the rail. A rail app preview and a top system widget are separate homes: one closes and the other opens; nothing flies across the screen pretending to be continuous. Shared geometry remains inside one surface (album→EQ, clipboard card→preview, device row→detail). The bar gate includes motion-feel tuning with Alex.

Hyprland-side window animations (Lua, from visual-design-reference): open = fade+scale .95→1 ~250ms ease-out; close = 150–200ms; workspace slide 300ms; `misc:animate_mouse_windowdragging = false` (drag latency on this GPU). QML bezier arrays must be length-multiple-of-6 ending `1,1` (overhaul §5.8a — silently discarded otherwise).

Performance rules that make this smooth on an i3: all continuous renderers (cava, sparklines, scanning spinners) are **demand-driven and visibility-gated** (iNiR's `CavaService`/`ResourceUsage` lifecycle is the adopted pattern — one shared cava process, teardown when hidden/silent/on-battery); ambient loops (orbiting blobs) appear only inside expanded widgets, max 1–2 per surface; vinyl rotation uses `RotationAnimator` (render thread); heavy Canvas work is event-only.

### 3.4 Gradients, typography, icons

- **Diffuse wallpaper-derived gradients, never sharp generic linear gradients.** The ML4W technique, translated to QML for hero surfaces (lock, session menu, expanded music, Nexus sidebar): overlapping radial gradients from generated semantic roles, with off-canvas centers and restrained alpha over the current mode-aware glass. The hue family follows the wallpaper. The Northern Lights preset may use teal/purple/green; red, gold, blue, green, monochrome, and light themes use their own generated families. Everyday panels stay restrained glass—Agridyne's negative-space lesson.
- **Type:** Inter (UI), FiraCode Nerd Font (terminal/code), light-weight large numerals for hero clocks with `tnum` tabular figures. Base UI size 14–15 (caelestia's 13 is too small at 1.5×). `QT_SCALE_FACTOR=1` — logical sizing only, no double scaling.
- **Icons:** Papirus everywhere (top bar, left rail, launcher, tray, Nexus), replaced centrally at the token layer.
- **Hit targets:** ≥34px for any bar control (media buttons explicitly), 40×40 grid cells, 44px primary actions — independent of visual scale.
- **Micro-status language (C17):** battery pill amber <20% + gentle charge pulse; network icon soft activity shimmer under real traffic; bell dot only for post-filter unread. Built once the services exist; cheap; exercises the motion vocabulary daily.

---

## 4. THE THEMING PIPELINE — one authority, full-system, atomic, animated

### 4.0 Ownership chain — wallpaper triggers a complete semantic theme

```text
skwd-wall applies wallpaper
        ↓  `skwd.wall.applied`
SkwdBridge starts the project palette transaction
        ↓
patched caelestia generator analyzes wallpaper
and chooses Auto-dark or Auto-light semantic ranges
        ↓
it derives the complete surface/foreground/accent/state palette
        ↓
atomic fan-out writes every external consumer
        ↓
`services/Colours.qml` publishes/animates the shell palette
```

**Naming boundary:** Aurora is the project/shell codename. It is not a palette policy. The teal/purple/green aurora-borealis look is called **Northern Lights** and exists as one preset/result, never as a forced default.

**System-wide semantic authority:** the project's patched caelestia scheme engine: the CLI generator plus `services/Colours.qml`. It owns the final role values because the chassis already consumes that scheme everywhere.

**Wallpaper authority:** skwd-wall/skwd-paper chooses and renders the wallpaper and emits the event. It influences the entire generated theme through image analysis, but it does not independently publish a competing system palette.

**Consumer mapping donors:** caelestia's shipped templates, iNiR's GTK/Qt/Kitty breadth, agridyne's KDE/Chrome role mapping and visual cohesion, plus small project templates for missing consumers.

**Fallback generator:** Hellwal only if the patched caelestia generator fails acceptance. A fallback must still feed the same semantic role contract and atomic transaction.

**Matugen:** not the system-wide authority. It may remain an internal implementation detail inside skwd's own picker UI, which is pointed back at the published system scheme. Do not create a second independent Matugen fan-out.

**Generator policy:**

1. Analyze wallpaper luminance distribution, dominant/secondary hue families, chroma, and usable foreground contrast.
2. Default to dark when the composition is dark/evening/shadowed; choose light when it is clearly high-key/light.
3. Generate the **entire** semantic ladder—backgrounds, surfaces, foregrounds, borders, accents, containers and states—from the wallpaper family.
4. Preserve strong color identity across actual surfaces. A dark red result must be a cohesive dark-red system, not black plus red trim.
5. Apply contrast/chroma guards without forcing teal, purple, green, pastel, or a universal neutral ladder.
6. Expose Auto / Force dark / Force light in Nexus. Forced modes retain wallpaper-derived color identity.
7. Remove any rule that disables light mode globally.
8. On generation/validation failure, keep the previous complete scheme and show a visible error.

**Template/consumer inventory:**

| Consumer | Source of mapping/template |
|---|---|
| aurora-shell QML | native `Colours.qml` + animated propagation |
| Hyprland borders/glow | caelestia template, extended for carried patches |
| Kitty | iNiR target, adapted for generated light/dark roles |
| Fish/terminal 16-color, btop, cava, fastfetch | caelestia |
| Starship | project template |
| GTK3 + GTK4/libadwaita | iNiR writers |
| Qt6/KF6 + Kvantum | iNiR writers + agridyne KDE mapping |
| Chrome frame | Nix `BrowserThemeColor`; content stays opaque per agridyne rule |
| Spotify, VS Code, Discord/Vesktop | caelestia integrations, validated in both modes |
| hyprbars | project template |
| regreet, skwd UI, lock | project templates/semantic bindings |

**Atomic transaction:** generate into a staging directory, validate every output, publish with atomic renames, and touch `scheme.json` last. Failure preserves the previous coherent state and raises a visible error. iNiR's temp-and-rename flow is the pattern donor; the all-or-nothing boundary is project glue.


### 4.1 The wallpaper system (open question #1 — resolved)

**Decision: keep the complete skwd-wall application with its Rust daemon. awww is retired entirely.**

The reasoning, from on-disk verification (`~/nix/repos/liixini-skwd-wall/`):
- The transitions Alex approved in the preview — the diagonal wipes, the ink/ripple/warp effects — live in the daemon's `skwd-paper` renderer (38 shaders). The daemon-free "vendor SliceDelegate" path in MASTER §6 would discard exactly the thing that made skwd-wall the best picker he's seen, and rebuild the picker's host around one extracted delegate — the pattern this project got burned by. That instruction is **retired**.
- The daemon is externally drivable: JSON-RPC over `$XDG_RUNTIME_DIR/skwd/daemon.sock` (`wall.apply`, `wall.list`, `wall.random_start/stop`, `wall.set_favourite`, …, verified in `qml/services/DaemonClient.qml`).
- It **broadcasts `skwd.wall.applied` (type, name, path) to every socket subscriber.** That is the palette hook: an ~80-line `SkwdBridge.qml` service in aurora-shell subscribes and fires the §4 transaction on every apply — picker click, random rotation, or scripted — with **zero patches to skwd**.
- Packaging is done for us: skwd-wall's flake builds the QML app, the daemon (its own flake input), a `skwd` CLI, the `skwd-daemon.service` user unit, a desktop entry, and a `programs.skwd-wall` NixOS module. Pin both revs (`74be656…` app / `36f165a…` daemon — the verified snapshots).
- With awww gone there is no daemon conflict to patch — the `awww kill` guard branch is unreachable. One renderer owns the wallpaper layer; aurora-shell's own background sets `wallpaperEnabled = false` (stock flag, verified).

**Auto-cycling (C10):** use the daemon's native rotation — `wall.random_start` with interval + `favourites_only` (already exposed in skwd's own FilterBar UI). Every rotation apply emits `applied` → palette follows automatically; there is no second authority because *theming reacts to the renderer* rather than racing it. The **evening variant** (prefer dark wallpapers after night-light onset) is one small systemd user timer that sends a single `wall.apply` JSON-RPC line for a curated `dark/` subset pick — ~15 lines of glue, listed in §9.
**Half-applied-state note:** wallpaper transitions (~600ms shader) and the palette commit (~1s later, animated 300ms) are deliberately sequential—the coordinated theme transition. Atomicity lives inside the palette fan-out (§4 transaction), which is where half-applied states actually hurt.
**skwd's internal Matugen** themes only its own UI; execution confirms its template output is scoped to its config dir and additionally points its UI scheme at our generated palette so the picker follows the active system theme. `QSG_RHI_BACKEND=vulkan` default: verify on Iris Plus (ANV), override to `opengl` in the wrapper if it misbehaves. **[GATE — wallpaper]** picker click → shader transition plays → whole OS recolors within ~1.5s → no consumer left stale (checklist: bar, Kitty *new window*, Chrome frame, Dolphin, Spotify, hyprbars, lock).

Entry points: System button → Wallpaper; desktop right-click → Change Wallpaper; launcher "wallpaper" action; `random_start` toggle inside skwd's own UI.

**Library:** Alex's wallpapers currently live in `~/Downloads`. Stage 4 imports the collection into `~/Pictures/Wallpapers` (skwd's library dir) via skwd's own import (`wall.import`) — originals untouched, the curated collection stays, and a `dark/` subset gets tagged for the evening variant. **Any wallpaper works:** the generator derives a complete light or dark color system from it. Red/gold/blue/green/monochrome/light images recolor surfaces and foregrounds as well as accents. gowall recolor-toward-palette remains an optional inverse tool for images that fight a chosen manual preset.

**Animated wallpapers (previously deferred — now a built-in toggle):** verified on disk, the skwd daemon natively plays **video wallpapers and Wallpaper Engine items** (`wall.apply` types `video`/`we`, with per-output audio/volume/mute). The §14 deferral stands as the *default* — a dual-core i3 doesn't decode video for free — but the capability ships with the picker we're installing anyway. Post-acceptance opt-in behind a perf gate, with policy: pause on battery, pause when a window is fullscreen/covering, static fallback image published to the palette pipeline.

**Built for the daemon's future (operator note on the v2 rewrite):** our entire integration is deliberately one thin seam — the `SkwdBridge` socket client + the `skwd.wall.applied` subscription + the packaged systemd unit. The picker app, the palette pipeline, and every surface are ignorant of the renderer. If the lighter-rendering v2 daemon ships and proves itself, adopting it is: bump the flake pin, re-verify the socket protocol against `SkwdBridge` (adapt that one file if the RPC changed), rerun the wallpaper gate. Nothing else in the OS knows the difference. v1 stays pinned until that check passes — proven code doesn't get swapped for release notes.

---

## 5. THE SURFACES

Every surface: what it is, where the code comes from, what changes, how Alex touches it.

### 5.1 The two bars — ilyamiro top widget bar + caelestia left application rail *(architecture corrected 2026-07-29)*

The final surfaces follow a strict role split:

```text
TOP — system information and independent widgets
[Search] [Bell] [WS 1][WS 2][WS 3][+]   [Now playing / EQ]   [Clock / Date / Weather]   [Tray/Lang] [Net] [BT] [Audio] [Battery] [Resources/System]

LEFT — applications and windows
[Launcher]
[Pinned apps]
[Current-workspace running apps]
[Current-workspace minimized apps — dimmed]
[Grouped previews for multi-window apps]
[Optional Kurve visualizer / app-centric footer]
```

#### Top bar — ilyamiro nearly 1:1

New `modules/topbar/`, persistent, using ilyamiro's actual independent-island composition and morphing widgets rather than merely borrowing its geometry.

- **Left:** search/launcher icon, notification bell, then workspace pills. Three workspaces are shown by default; `+` creates/reveals another. Active extra workspaces remain visible while in use. The responsive maximum is whatever fits comfortably between neighboring islands at the MacBook's 1707-logical width; after that the workspace island compacts/scrolls rather than bloating the bar. No fixed eight-workspace row.
- **Media island:** current source/app, track, elapsed time and transport controls. Click expands the final Music/EQ surface in §5.9.
- **Center:** clock/date/weather island, preserving ilyamiro's centered visual balance.
- **Right:** tray/language plus independent network, Bluetooth, audio, battery, and approved CPU/RAM/System islands. Each opens its own anchored detail panel. These are separate widgets, not one stacked right-side mega-popout.
- **Never on top:** pinned apps, running task buttons, minimized tasks, or active-window title. Those belong to the left rail.

The only structural additions to the ilyamiro reference are explicit project-required system entries such as CPU/RAM and the System action; they remain independent islands and may not rearrange the source into a Windows taskbar.

#### Left rail — caelestia app/work surface

Caelestia's vertical rail remains the structural owner, adapted around its app icons and window-preview service:

- launcher/app entry;
- pinned applications always visible;
- running and minimized windows from the **current workspace only**;
- minimized entries visibly dimmed but still active;
- one window: click focuses/restores;
- multiple windows: hover opens exact live previews, click a preview focuses/restores that window;
- right-click actions and optional drag/reorder/move-to-workspace behavior;
- optional Kurve visualizer/footer if it earns its space.

The final rail removes the stock duplicate workspace, tray, calendar/time, network, Bluetooth, audio, and battery stack because those are owned by the top bar. An "active elsewhere" indicator for pinned apps is optional later polish, not a Stage 2 requirement.

#### Visibility policy

The rail stays **persistent during implementation and Stage 2 acceptance**. Persistent versus immediate hover-reveal is decided only after the completed top bar and rail are viewed together at actual scale. Both modes remain a Nexus toggle; no default is pre-decided.

#### Bar gate

By mouse: top widgets open the correct independent panels; three-workspace-plus behavior is clear; rail pinned/running/minimized state is correct; grouped previews choose exact windows; minimized restore is one click; no app or system-status duplication; motion reads as one system; shell restart does not kill applications.

### 5.2 Popouts, previews, and the status panels

**System/status content uses caelestia services and proven popout internals, but its final anchors are the corresponding ilyamiro top islands — not duplicate icons on the rail.**

- **App/window previews:** carried `modules/windowinfo/` beside left-rail app groups. Hover is visibility-gated; preview selection targets an exact window. Context actions include focus/restore, close, close others, float, pin, and move to workspace.
- **Tray menus:** carried StackView drill-in, opened from the top tray island.
- **Network:** carried service and join flow, re-presented under the top network island; fix password transport and `NetworkUsage` bugs; show live traffic distinctly from an explicit WAN speed test.
- **Bluetooth:** top Bluetooth island; stable device order, battery and scan; deeper radial ilyamiro panel may open from it.
- **Audio:** top audio island; volume/mute/device/per-app fast controls; expanded ilyamiro audio/EQ surface for depth. OSD remains transient feedback.
- **Battery/power:** top battery island; percentage/time/profile/keyboard backlight fast controls; expanded ilyamiro battery presentation.
- **Display:** DMS `DisplayConfig`/`DisplayService` as the functional backend, presented from the top/System/Nexus rather than a rail duplicate.

**Independent expanded tier:** ilyamiro's battery, audio, Bluetooth, network and media compositions remain separate anchored widgets. They run on caelestia services, not shell-script pollers. First open may use staged choreography; repeat opens use normal panel speed.


### 5.3 The left-rail application stack — pinned, running, minimized, previews

**Primary structure:** caelestia `modules/bar/` app entries plus `modules/windowinfo/` preview machinery. **Behavior donors only where gaps remain:** DMS dock grouping/context/drag patterns and iNiR preview/performance guards. DMS is not the structural owner.

**Visual direction:** agridyne's persistent-glass/negative-space language and app-icon treatment, adapted onto the Caelestia rail. "Glass app tiles" means the app buttons themselves receive a restrained glass container/hover/active treatment; it is not a separate surface or a new dock architecture.

**Behavior:**

- pinned block: Chrome, Kitty, Dolphin, Spotify, Media Center;
- current-workspace running apps/windows below or integrated with pinned entries;
- current-workspace minimized windows remain in place but dim;
- click focused single window = leave focused; click unfocused/minimized single window = focus/restore;
- grouped app with multiple windows = hover live previews, click exact window;
- middle-click/new-window and right-click desktop actions where supported;
- task/window may be dragged to a top workspace pill once cross-surface drag is proven;
- no other-workspace running-window clutter in the current rail.

**Minimize integration:** the rail is the mandatory one-click recovery surface. It consumes explicit minimized state from §6.2 and must never infer minimize from a visible `special:min-*` workspace.

**Kurve:** optional rail-foot visualizer using the existing shared cava provider; stops when silent, hidden, or on battery. Its inclusion is visual/space-gated and does not block minimize recovery.

### 5.4 The Caelestia dashboard UI — retired; reusable backends only

The stock Caelestia dashboard drawer is **not part of the final desktop**. It duplicated the independently approved ilyamiro top widgets:

- calendar/date;
- media/lyrics;
- performance/storage/battery;
- weather forecast.

Therefore:

- disable the dashboard drawer UI;
- remove its top-edge hover/swipe trigger;
- do not bind any gesture or bar item to it;
- do not rebuild or restyle its duplicate tabs;
- keep only reusable services, models, or components that directly support the independent top widgets, Nexus, notifications, sysmon, or another approved surface;
- calendar event data belongs in the top calendar expansion;
- media/lyrics belong in the top media expansion;
- performance/storage depth belongs in resource expansions, Nexus System, or sysmon;
- weather detail belongs in the top weather expansion.

This is a source-role correction, not a loss of functionality: the information remains available in the independently approved surfaces without a second duplicate hub.

### 5.5 The launcher

**Source: carried `modules/launcher/`, full-fat** — real icons, fuzzy search-as-type, favorites, **appdb frequency ranking** and **qalculator inline calculator** (plugin is resident, so the shell-surfaces session's "drop these" trade is obsolete), actions (lock/sleep/scheme…), detached `DesktopEntry.execute()`. Click-away via the drawers' `HyprlandFocusGrab` (the §5 Escape-only bug dies by construction) and Escape.

Adaptation: drop `WallpaperList` mode (skwd-wall owns wallpapers; the "wallpaper" action launches skwd); keep scheme/variant modes (harmless, cut-listed); Papirus icons; rows sized for 1707-logical width; **triggers: Apps button, left-rail Apps entry, and Cmd+Space** (rebound from window-focus — the §5 bug). Emoji mode: `:` prefix (iNiR pattern) — see §5.7 for the button path. File results (§4.11): a `plocate`-backed file mode is budgeted glue (§9) — labeled "app/action/file search," honest about not being a content indexer.

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
7. **Applications & updates** *(new fallback page)* — shown only for applications whose native Linux build is **proven** to have no updater UI. It provides graphical Check / Update / Restart / Hold / Skip / Roll back actions per app, never opens a terminal, and never replaces an application's own updater when one exists. It does not emit universal app-update notifications; the page is the least-resistance fallback, not the normal path.
8. **System** *(new page — the capstone)* — **operating-system generations only**: generation list, **Check for system updates → `nh os build` diff view → Update / Update-at-boot**, **Roll back** buttons (`nixos-rebuild {switch,boot} --rollback`), disk/GC status + "Review generations" + known-good pin control, backup status line (restic last-run), health events (§8.4). Ordinary app updates do not require a NixOS rebuild and are not funneled through this page.
9. **Language, region & writing** — weather/location plus dictionaries, correction-suggestion language, candidate behavior and per-app exclusions; **About**.
10. **Bluetooth** page (carried: pairing, device info, battery).

Retheme: Blobs window chrome → plain glass container (keep the window factory); tokens ride the scheme. Nexus opens from: System surface, launcher "settings," System/top-bar settings action, `aurora shell ipc call nexus open`.

### 5.9 Music & EQ — ilyamiro top-island composition

**Stage 3 daily surface:** the top media island follows ilyamiro's source composition: artwork/source identity, track, elapsed time and usable transport controls. It is independent from the clock/weather and status islands.

Clicking it expands the final Music/EQ widget beneath the same anchor: large art, seek, transport, visual motion, 10-band EQ and presets from ilyamiro's `music/MusicPopup.qml`, adapted to the existing validated `equalizer-state`/EasyEffects backend. MPRIS, cava and lyrics use caelestia services; EasyEffects remains invisible. Per-device preset state is shown.

Synced lyrics and deeper listening context live inside the top media expansion itself. Music/EQ therefore ships with the Stage 3 top bar, not in a duplicate dashboard and not as a Stage 9 afterthought.

### 5.10 The lock screen — agridyne visual direction × Vast depth, with selected proven donors

**Corrected ownership:** `agridyne visual composition/negative-space/glass identity + Vast cinematic depth and gated unlock engine + selected ilyamiro clock/PIN/motion mechanics + iNiR/DMS status pills + DMS safety lifecycle`. Hyprlock stays installed as emergency fallback.

Built as aurora-shell's `modules/lock/` replacement:

- **Primary visual direction — agridyne:** restrained persistent-glass composition, negative space, monochrome/aurora cohesion, and the lock-screen visual treatment Alex previously selected. Agridyne is not reduced to a generic “glass tile” donor.
- **Depth + unlock — Vast:** two-plane wallpaper, focus zoom/blur build, and gated multi-beat exit whose final action alone releases the session lock.
- **Interaction/motion details — ilyamiro where they improve the result:** hero clock/date, avatar→PIN transformation, failure shake and motion curves; these are donors, not ownership of the whole visual face.
- **Status — iNiR/DMS:** battery and WiFi pills.
- **Lifecycle — DMS:** logind `LockedHint`, session-lock re-acquisition, bounded PAM retries, no release on missing resources/timeouts.
- **PAM:** `security.pam.services.aurora-lock = {};` before first enable.

**[GATE — lock]** retain the existing full crash/PAM/suspend/re-acquire test. If crash-safe lifecycle fails, Hyprlock ships temporarily and the composite remains open rather than being called complete.

### 5.11 Boot, greeter, and the session chain (§4.4)

Power-on → **no Option hold** (one-time t2linux Startup-Manager procedure: Option → hold Control → boot NixOS = persistent default; documented chore: redo after macOS updates; **never touch Startup Security**) → systemd-boot `timeout 0` (hold a key to reveal generations/macOS) → **Plymouth** aurora splash (theme: adapt a minimal spinner-class theme from `pkgs.plymouth-themes` recolored to the ladder; `quiet splash loglevel=3 rd.udev.log_level=3`, `boot.initrd.verbose = false`) → greetd auto-login → aurora-shell starts **locked** (lock-on-session-start), so the first thing Alex ever sees is the lock screen, not a terminal scroll. Unlock → desktop.

- **Logout path:** `regreet` themed via the GTK work + wallpaper background (session pick) — the recovery face of the OS; `tuigreet` on a spare TTY as the text fallback.
- **Keyring:** `security.pam.services.greetd.enableGnomeKeyring = true`; with auto-login the login keyring gets a **blank password** (single-user laptop, §15 defers hardening) so no gcr prompt ever appears — the LUKS-key recipe is the documented upgrade path.
- **[GATE — boot]** cold boot with no keys held lands on the lock screen with zero visible text; hold-key reveal still reaches macOS + old generations; `start-hyprland` warning (open bug) is resolved or root-caused at this gate.

### 5.12 Screenshots & recording (§4.10)

**Source: carried** `modules/areapicker/` (live region / frozen region / straight-to-clipboard modes) + `services/Recorder.qml` + utilities Record card + CLI `screenshot.py`/`record.py`.
- **Capture entry and mode selection:** `Cmd+Shift+S`, System → Screenshot, and the visible capture action all open one Windows-style top-centred toolbar with **Region · Window · Full screen** buttons and an obvious active mode. Alex's keyboard has no Print key, so `Print` is optional redundancy only and is never the required full-screen path. Region output goes to clipboard **and** a timestamped PNG in `~/Pictures/Screenshots`; Window captures the exact chosen window bounds; Full screen captures the entire active display with one click. The toolbar/picker are excluded from captures and the app rail, and cancel/completion restores the exact previously focused window rather than leaving focus on the capture target.
- **Recorder backend: `gpu-screen-recorder` with VA-API H.264** (`intel-media-driver`/iHD; `LIBVA_DRIVER_NAME=iHD`) driven by caelestia's Recorder. Any region fallback consumes geometry from the final Areapicker; **`slurp` is forbidden in the final capture/recording path** because its overlay caused the proven pink-film defect. **[GATE]** `vainfo` shows iHD encode; 10s recording stays low-CPU and smooth.
- **OCR (C6):** "Copy text" mode on the picker toolbar → tesseract → clipboard + toast.

### 5.13 Clipboard history (§4.3)

**Sources:** cliphist + wl-clipboard ingestion (caelestia main repo's dual watcher pattern); **iNiR** `services/deferred/Cliphist.qml` + `ClipboardPanel/ClipboardItem/CliphistImage` (lazy image decode, decode-only-when-visible); **ilyamiro** `clipboard/ClipboardManager.qml` grid presentation (3×4 pages, 250–300ms selected-card shared-geometry morph). Composed as an aurora-shell drawer surface: `Cmd+V`-equivalent (`Super+V`) + bar/System entry; click = copy/paste without keyboard; history survives reload; **no session-start deletion** (cxOrz anti-pattern excluded). Privacy policy layer (sensitive-type exclusion, expiry) is §15-deferred; the surface is not.

### 5.14 Polkit & privileged prompts (B8)

**Source: iNiR `modules/polkit/`** (155 lines — cleanest) over QuickShell's first-party `Quickshell.Services.Polkit.PolkitAgent`, restyled to tokens: the sudo-grade dialog **is** a project glass surface. Exactly one agent runs (no hyprpolkitagent/GNOME agent autostart). Live-check: `Quickshell.Services.Polkit` present in the pinned QuickShell rev.

### 5.15 The desktop layer

**Source: carried `modules/background/`** with `wallpaperEnabled = false` (skwd-paper renders the wallpaper): hosts the **desktop right-click menu** — iNiR's pattern (`Background.qml` ~l.1108–1144 + `common/widgets/ContextMenu.qml`): New Terminal · Change Wallpaper (→ skwd) · Display Settings (→ §5.2 panel), edge-aware, tokens shared with every other menu. Optional (cut-list): caelestia `DesktopClock`, background `Visualiser`, and iNiR's desktop-widget edit mode (C11 — restrained: clock + weather max).

### 5.16 Alt+Tab & overview (B1)

Alex's primary mouse switching is the left application rail; Alt+Tab is keyboard redundancy.

- **Alt+Tab:** live-content QuickShell cycler composed from carried `windowinfo/Preview.qml`, MRU order from the Hypr service, mouse-selectable, with ilyamiro selection motion.
- **Overview:** Hyprexpo's zoomed-out window/workspace navigator. **Four-finger up opens Overview.** A visible top-bar workspace/overview action opens it by mouse. The retired dashboard has no gesture or edge trigger.

snappy-switcher remains a cut-list fallback only if the final cycler fails.

### 5.17 The file manager — Dolphin (locked) + the file layer

- **Dolphin** (Qt/KF6): `inode/directory` handler; split view, tabs, undo, batch rename, built-in terminal panel; **Baloo disabled** (on-demand search only). Service menus: **Ark** (Extract Here/To, Compress) — archives' double-click opener (B10). Thumbnails via KIO providers (image/PDF/video, remote previews conservative).
- **Theming (§4.17):** Qt6/KF6 color roles + Kvantum from the generated scheme (iNiR Qt writers + agridyne's KDE mapping); GTK3/GTK4/libadwaita writers stay for non-Qt apps. The file layer follows the wallpaper-selected light/dark family and remains visually glass-adjacent, while staying honest that GTK/Qt application contents do not composite true desktop blur.
- **Devices & trash (§4.12):** UDisks2 + Solid; **one** headless `udiskie` for hotplug automount + notification; Dolphin owns mount/eject affordances; KIO Trash. **[GATE]** the §4.12 checklist live: insert USB → one notification, sidebar appears, writable, trash vs delete correct, safe eject; verify with no window open.
- **File-picker portal (B9):** `default=hyprland;gtk` with `org.freedesktop.impl.portal.FileChooser=kde` (matches Dolphin's world). **[GATE]** Chrome upload + Save-As: dark, parented, Recents, remembers directory; drag-from-Dolphin-into-page works.
- **Default apps (§4.1), declared once in Home Manager `mimeapps.list`:** dev-lane (code/md/json/logs/configs) → VS Code · images → Gwenview · video/audio → mpv · PDF → Okular · archives → Ark · web → Chrome · directories → Dolphin. Surfaced in Nexus › Default apps.

### 5.18 The system/process workspace (§6 system monitor)

`special:sysmon` — the dedicated full workspace, not a widget, in the canonical riced layout: the **fetch card** (aurora ASCII + OS info lines, persistent) on one side, **btop** (caelestia theme — the reactive CPU/RAM/net waveforms) as the centerpiece, plus `sensors` temps/fan RPM and PipeWire xrun visibility (`pw-top`) in flanking panes — the fan/thermal/audio legibility the guardrails ask for. Opened by: bar CPU/RAM pills (click), launcher "system monitor," `Cmd+Escape` bind, left-rail right-click. Spawned via the toggle orchestrator (§7.1) with a named Kitty (`--class sysmon`).

---

## 6. THE INTERACTION MODEL

### 6.1 The daily walk (the win condition, moment by moment)

1. Power → Aurora splash → lock screen.
2. Unlock → persistent top widget bar and left app rail appear as one system.
3. Open apps from the left rail/launcher or optional shortcut.
4. Manage windows with ordinary titlebars and borders. Minimize File Manager: it leaves the layout but remains dimmed in the same workspace's left rail. Click it once to restore.
5. Super+Left/Right creates exact two-pane work. When both halves are occupied, surplus windows minimize into that same workspace's rail. Restoring one dissolves the pair and returns to ordinary tiling.
6. Scroll a window under the pointer without stealing keyboard focus; click transfers typing focus.
7. Use independent top widgets for media/EQ, weather/calendar, network, Bluetooth, audio, battery and system information.
8. Use the independent top-widget expansions for calendar/weather/media/resources and Hyprexpo Overview for spatial window/workspace navigation.
9. Every normal action has a visible UI; shortcuts remain optional.

### 6.2 Window management (the full spec)

- **Per-window controls:** hyprbars, ABI-pinned with Hyprland. Close/maximize/minimize buttons; titlebar drag without modifier; double-click maximize; ordinary borders/corners resize.
- **Drag anchor:** carried narrow Hyprland patch prevents tiled-window pickup from jumping to center; floating drag/drop-to-retile behavior preserved.
- **Corner resize:** ordinary all-four-corner grow/shrink is mandatory. Carry the approved narrow compositor patch; Super+RMB remains redundancy, never fallback acceptance.
- **Focus and scrolling:** `follow_mouse = 2`: pointer interaction/scroll follows the window under the cursor, keyboard focus stays on the last clicked window, clicking transfers keyboard focus. `focus_on_close = 2`, `misc:focus_on_activate = true`.
- **Same-workspace minimize:** reject omarchy's final `special:min-*` model. Minimized windows retain original workspace, prior tiling/floating state and geometry where possible; they leave rendering/input/layout and remain represented in the left rail. One click restores/focuses. A restore-last hotkey may exist as optional redundancy but is not a primary or required path. Investigate native Hyprland minimized state / a narrow patch first; offscreen hiding is not accepted without explicit approval.
- **Deterministic two-pane snap:** `Super+Left` always makes the active window exact left 50%; `Super+Right` exact right 50%, independent of dwindle tree shape or number of windows. When a window snaps onto an occupied side, the previous occupant minimizes. When both halves are occupied, all other visible windows on that workspace minimize. The opposite half remains stable.
- **Pair dissolution:** restoring a surplus minimized window, dragging/unsnapping/maximizing either half, or closing a side dissolves the strict pair and returns the workspace to normal Hyprland tiling; prior placement/state is restored where technically possible. Clicking a restored window is expected to bring an additional window into view.
- **Snap gate:** one, two, and 3+ windows; target side already occupied; left/right; second-press return; restore surplus; drag; close; maximize; new window after pair.
- **Workspaces:** three visible baseline workspaces plus `+`; active extras appear dynamically up to responsive available space. `special:sysmon` and `special:dev` remain purpose-built; **no minimize workspaces**. Move by optional keybind and mouse drag from rail app/window to top workspace pill.
- **Gestures:** 3-finger horizontal workspace swipe; 3-finger vertical volume; 4-finger down sysmon; pinch zoom (operator-confirmed working, do not retest unless touched). 4-finger up opens Hyprexpo Overview as specified in §5.16.
- **DWT:** add hwdb match `touchpad:usb:v05acp0280:*` with `ID_INPUT_TOUCHPAD_INTEGRATION=internal`, then `disable_while_typing = true`; verify libinput changes from `n/a` to available/enabled and test with natural palm placement. Palm thresholds are measured, never guessed.
- **Input tuning:** repeat rate/delay and scroll factor remain Nexus rows. Touchpad two-finger scroll/tap/natural scroll are do-not-regress.

### 6.3 The placement map (B18)

**Top bar = system awareness and independent widgets · left rail = apps/windows/minimize recovery · System surface = actions · Nexus = configuration · launcher = everything by name · Overview = spatial window/workspace navigation.** Any ordinary action reachable only by hotkey is a bug.

### 6.4 The keymap (shortcuts are optional redundancy)

| Keys | Action (ordinary UI path) |
|---|---|
| `Cmd+Space` | Launcher (top search / left launcher) |
| `Cmd+Shift+S` / `Print` | Region / full screenshot (System surface) |
| `Super+V` | Clipboard history (top/System entry) |
| `Cmd+L` | Lock (power/System) |
| `Alt+Tab` | Window cycler (left rail / overview) |
| `Super+N` | Notification history (top bell) |
| `Super+Left` / `Super+Right` | Exact two-pane snap (window UI may expose snap actions) |
| `Super+Up` | Maximize toggle (titlebar maximize) |
| `Cmd+E` | Dolphin (left rail pinned app) |
| `Cmd+Return` | Kitty (left rail pinned app) |
| `Super+D` | Dev workspace (left rail/launcher) |
| `Cmd+Escape` | Sysmon workspace (top resource widget/launcher) |
| `Cmd+.` | Emoji (System/launcher) |
| `Super+=` / `Super+-` | Zoom magnifier (Nexus toggle) |
| Media/brightness Fn keys | OSD-confirmed (top widgets/sliders) |

Restore-last-minimized may be offered as an optional user-configurable bind, but it is intentionally absent from the canonical memorization list because one-click rail restore is the normal path.

Kitty: `confirm_os_window_close = 0`, context-aware Ctrl+C, Ctrl+V paste, 10k scrollback, clickable tabs, path hints, custom Aurora startup art.

---

## 7. THE DEV WORKSPACE (§7)

One action — `Super+D` or the left rail's code-glyph entry — reveals `special:dev`, the two-agent cockpit. Composed entirely from sourced mechanisms:

### 7.1 The spine
**caelestia CLI `toggle.py`** (read in full; vendored as `aurora toggle dev`): workspace-name → clients map, spawns missing clients **directly into** `special:NAME` (`[workspace special:dev] exec …`), moves matching strays, else toggles. `rules.lua` pins `class: dev-*` → `special:dev`.

### 7.2 The layout (spawned members)
- **Claude terminal:** `kitty --class dev-claude --title "Claude Code" --directory ~/nix` running zellij session `claude-nix` → inside it, `systemd-run --user --scope -p Slice=agent.slice --nice=10 -- claude --dangerously-skip-permissions`.
- **Codex terminal:** same shape, `--class dev-codex`, zellij `codex-nix`, `codex --yolo` (verified current flag; `--full-auto` is deprecated).
- **The fetch pane** (`--class dev-fetch`, persistent): the classic riced-fetch card — ASCII art on the left, OS info lines on the right (`alex@macbook · NixOS <ver> · linux-t2 kernel · Hyprland · uptime · packages · shell · 1707×1067 · CPU/GPU/mem`), caelestia's boxed blue-gradient fastfetch config as the base. **The art rotates like the wallpaper:** a curated `~/.config/fastfetch/logos/` set, one drawn at random per terminal spawn (a three-line wrapper around `fastfetch --logo`), every piece colored through the scheme's ANSI slots so whatever shows is wearing the current accents. Starting set (revised with Alex 2026-07-21; he curates at review): the **NixOS snowflake** (fastfetch built-in) · **saatvik's four shipped pieces, verified on disk at `saatvik333-hyprland-dotfiles/fastfetch/*.txt`** — `star`, `cyberpunk-mask` (the skeleton), the tall cross piece — **renamed `gothic-cross.txt` on vendor** (operator call) — and `illuminati` — all braille art already using fastfetch `$N` color-slot placeholders, so they palette-tint with zero adaptation · an **aurora-waves** piece *only if a genuinely well-designed one is found in the community archives* (quality bar, not a filler slot) · **two reserved slots for Alex's own uploads: the Erdtree and Night's Edge** — drop into the logos dir when ready, `$N`-slot them so they recolor too. Skipped by operator call: the Apple mark, and the AURORA wordmark (redundant — the name is already everywhere). It sits in its own section and stays.
- **btop pane** (`--class dev-btop`) — the reactive terminal-style meters (CPU/RAM/net graphs, caelestia btop theme) — and a **lazygit pane** (`--class dev-git`; Fish abbrs from caelestia's config ride along: `lg`, `gs`, `gd`, `ga`, `gc`). Together with the fetch pane this is the canonical two-terminal composition: art + identity on one side, live waveforms on the other.
- **Dolphin** (`--class dev-files`, window rule → `special:dev`): the file pane of the workspace — split view + its built-in terminal panel pointed at the active repo.
- Quick-spawn buttons for preset dirs (`~/nix`, active project): `kitty --class dev-term --directory <preset>`.

Per-class Papirus-mapped desktop entries give each terminal its own icon in the rail/top widgets; Kitty `window_logo_path` watermarks Claude vs Codex panes.

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

- **Disk truth:** iNiR `ResourceUsage` df poll in bar/sysmon + caelestia storage/resource service in Nexus/sysmon; thresholds on **free bytes**: amber <15GiB/85%, red <8GiB/92% (persistent + "Review generations"), re-arm at 18GiB. Never auto-deletes.
- **GC policy:** `nix.gc.automatic` weekly **after** a generation trimmer enforcing *keep ≥5 generations OR everything <30 days, whichever is more* (NixOS wiki trimmer adapted, dry-run action in Nexus › System); **no `--delete-older-than` on the GC itself.** A human-labeled **known-good GC root** pins the accepted closure (with its activation path recorded); "Mark current as known-good" is a Nexus button, never automatic. §15 lifecycle: delete gens 1–7 now; at acceptance, pin the accepted closure *first*, then wipe the era. `nh clean` covers user profiles.
- **Backup (B14):** `services.restic.backups.home` — **fully wired now, destination deliberately deferred (operator call 2026-07-21):** paths (`~/Documents`, `~/Pictures/Wallpapers`, project repos, `~/.local/share/mediacenter` — the Jellyfin data, `~/.local/state`), nightly `Persistent=true`, keep 7d/5w/12m, and the `createWrapper` restore/browse tooling all ship configured. The repository target (external disk and/or B2/rclone bucket) is the one missing input: until Alex sets it, the timer stays inert and Nexus › System shows **"Backup: choose a destination"** rather than a fake status; the moment a target + password file land in the secrets path, first run initializes and the status line goes live.
- **Health (B13):** `OnFailure=notify-failure@%n` template on user-relevant units (aurora-shell, skwd-daemon, restic, easyeffects, hypridle) → journal excerpt → **systembus-notify** bridge → notification history. The shell's own unit hardening (§2.2) makes "watchdog gave up" legible. restic failures ride the same channel.
- **Captive portals (B11):** NetworkManager connectivity check (plain-HTTP probe, single named setting) + `connectivity-change` dispatcher → user-unit handler → one actionable "This network needs a sign-in" notification (opens the probe URL); PORTAL ≠ LIMITED in the network panel.
- **System sounds (§4.9):** freedesktop sound theme, played by a small hook in the Notifs service, off by default, Nexus toggle.
- **Writing assistance (§4.5) — suggestions, not merely red underlines:** Hunspell dictionaries and every application's native correction menu remain the first layer. Stage 6 also selects and integrates one standard input-method candidate service (evaluate Fcitx5 versus IBus/Typing Booster against the physical coverage gate) so ordinary text fields that lack a useful native suggestion surface still receive spelling/completion candidates. Suggestions must be reachable by mouse and keyboard, support a custom dictionary, and remain disabled in passwords/secure fields. Automatic replacement stays off by default; Alex chooses a suggestion.
- **Coverage gate:** prove replacement suggestions—not only underlines—in Chrome, Discord/Electron, VS Code, a GTK text field, a Qt/KF6 text field, Dolphin rename, and another ordinary daily text field. Record real exclusions where a custom editor refuses standard input-method protocols; do not use that limitation to narrow coverage elsewhere. Fish command autosuggestions are a separate terminal feature with Right-Arrow/Ctrl-F acceptance and their own live check.
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
| **Media Center ("Moonfin") stack** | `~/.local/share/mediacenter/` (server.js, Jellyfin data/cache), `~/.local/bin/mediacenter`, `mediacenter.desktop`, `mediacenter-cache-cleanup.{service,timer}` | User-dir — survives rebuilds by construction. **Add to restic paths; pin the launcher in the left rail; never auto-start Jellyfin** (on-demand is the design) |
| **TV firewall rule** (LG TV MAC-accept) | **channel `/etc/nixos/configuration.nix`** — *not in the flake* | **Stage 0: read it (sudo), port the exact rule into `modules/nixos/media-center.nix`**, plus any other post-Jul-16 additions found in the same diff |
| BT pairings, keyring, Jellyfin ServerId | `/var/lib/bluetooth`, `~/.local/share/keyrings`, mediacenter data | State, not config — no rebuild touches them; do not regenerate machine identity |
| Bluetooth QML + `equalizer-state` edits | uncommitted in the repo | Commit; carry the equalizer-state backend into §5.9; port any BT panel improvements' *behavior* into the new BT popout before deleting the old tree |
| **Claude Code + Codex binaries/config/session state** | Claude currently has competing `~/.npm-global/bin/claude` and `~/.local/bin/claude`; Codex ownership must be verified live | **Immediate correction in the next compatible closure:** canonical Claude is the self-managed `~/.local/bin/claude` lane used by `claude update`; `~/.local/bin` wins before `~/.npm-global/bin`. Determine Codex's canonical user-owned lane from live evidence. Nix owns runtime/PATH declarations only and may never shadow, pin, replace, or downgrade either agent. Preserve credentials, settings and resumable sessions; neutralize stale duplicates only after the canonical command resolves correctly in current shell, fresh terminal and fresh login. |

**Stage 0 exists because of this table:** the machine currently has two config lineages (flake + channel edits) and pending work in the tree. Until they're reconciled into the flake, nothing else ships.

### 8.8 App lifecycle — native in-app updates, invisible Nix bridge (§4.2/§13/C3)

**The visible minimum is Windows-equivalent application behavior.** For every application whose native Linux build actually exposes update/check/install/relaunch UI, Alex remains inside that application and uses its own standard control. The backend adapts to the app; the app is not forced into a distro-shaped workflow.

#### Ownership lanes

- **System-coupled packages and low-churn utilities** remain declarative in the NixOS/Home Manager closure and update with the operating-system generation.
- **Fast-moving user applications** with independent release cadence use stable per-app launch paths plus versioned app roots/profiles. Updating one app may fetch/build/package that app only; it must not require a full NixOS rebuild, system activation, or reboot.
- The bridge may stage a vendor artifact into a new immutable store path or a controlled versioned user-app root, whichever preserves the application's native updater semantics. It **never mutates an existing `/nix/store` object in place**.
- App data, credentials, extensions, profiles and sessions remain outside disposable binary slots and survive update/rollback.

#### Native updater contract — primary and mandatory where it exists

For each app, inspect its Linux source/runtime/package behavior and implement the adapter it actually expects:

1. preserve or re-enable its native update detector and UI when packaging disabled it;
2. feed the native updater the vendor/package-manager/install state it expects;
3. let the application's own **Update / Install / New version available / Relaunch** control initiate or complete activation;
4. update only that application;
5. restart or relaunch only when Alex uses the application's normal control.

Background release checking, download or pending-slot staging may occur only to the same extent the application's normal updater requires. The currently running executable remains usable until its native flow performs the approved switch/relaunch.

**Not accepted when native Linux updater UI exists:** a browser extension, injected replacement control, Aurora titlebar button, global notification, terminal command, Nexus detour, software-center detour, or “run a system rebuild” instruction.

**Chrome acceptance is explicit:** a newer Chrome is staged where Chrome expects the installed version; Chrome itself shows its normal top-right/menu **new version available / Relaunch** state; clicking that native control restarts into the new version with tabs/profile intact. No Aurora-owned substitute UI.

The same bar applies app-by-app to Spotify, Discord, VS Code, Claude Desktop and every other GUI application that ships a real native Linux updater interface. “Nix normally updates packages centrally” is never evidence that an application's own UI cannot work.

#### Proven no-native-updater exception

A fallback is permitted only when source inspection, runtime tracing and package/build inspection establish that the native Linux build genuinely contains no updater UI or callable updater path.

Then use the next path of least resistance:

- a graphical app-specific updater surface where practical, otherwise Nexus › Applications & updates;
- Check / Update / Restart / Hold / Skip / Roll back by click;
- no terminal window and no command-copy workflow;
- no global app-update notification;
- no claim that the fallback is equivalent to a missing native UI.

The evidence and fallback choice are recorded per application before implementation.

#### Activation, rollback and retention

- User approval through the app's own native control—or the proven-exception graphical fallback—is required before the pending version becomes the version used on restart.
- After the new version launches successfully, retain **current + two previous versions maximum** for that app. Three binary versions total is an absolute default cap; older app profile generations/store roots are removed.
- Rollback is app-local and does not roll back the operating system.
- Hold/pin and skip-one-release state are app-local. A held current version still counts as the current slot; retention does not grow without an explicit named operator exception.
- Failed launch automatically leaves/reinstates the previous working slot and does not prune it.

#### Agent CLIs — native self-update and rebuild persistence

- **Claude Code:** canonical command is `~/.local/bin/claude` → the self-managed version tree under `~/.local/share/claude/versions/`; `claude update` remains the normal updater.
- **Codex:** retain its own supported user-owned update lane, determined from live command/path/version evidence. Do not assume nixpkgs ownership.
- Home Manager/Nix supplies Node/runtime/environment and deterministic PATH only. `~/.local/bin` precedes `~/.npm-global/bin`; a Nix rebuild may not make an older duplicate win.
- Gate current shell, fresh terminal, fresh graphical login and post-reboot resolution for both tools. Installed versions, credentials, config and resumable sessions persist.

#### System updates remain separate

`programs.nh` (`flake = "/home/alex/nix"`) and Nexus › System handle the operating system: check/build diff, Update, Update-at-boot and generation rollback using `nvd`/`nix store diff-closures`. That page does not become the normal updater for independent applications.

#### Stage 6 proof set

At minimum, complete the native/fallback determination and end-to-end update path for:

- Chrome;
- Spotify;
- Discord;
- VS Code;
- Claude Code;
- Codex;
- one application proven to lack native Linux updater UI, exercising the graphical fallback.

Each gate records: native UI present? adapter method; current/available/resulting version; restart behavior; data/session preservation; rollback; three-version retention; and proof that no NixOS rebuild or reboot occurred.

---

## 9. THE MANUAL-WORK REGISTER (honest scope — everything that is more than config)

Everything below is development or substantial adaptation. Unlisted development is a plan bug to flag, not absorb silently.

| # | Work | Size | Anchor |
|---|---|---|---|
| M1 | Ilyamiro-faithful top widget bar: independent islands, 3+ workspace model, centered clock/weather, top system widgets; no app tasks | **M–L** | §5.1–5.2 |
| M2 | Independent top-widget expansions on caelestia services, including media/EQ, audio, network, BT, battery, resources/System | **M–L** | §5.1–5.2/§5.9 |
| M3 | Cross-surface rail-window→top-workspace drag chain | S–M | §5.1/§5.3 |
| M4 | MPRIS→desktop-entry source-app resolver | S | §5.9 |
| M5 | Caelestia rail app stack adaptation: pinned/current running/current minimized, grouped previews, agridyne visual treatment, optional Kurve | **M** | §5.3 |
| M6 | Composite lock: agridyne visual direction × Vast depth × selected ilyamiro motion × DMS lifecycle/status | **L** | §5.10 |
| M7 | Top calendar/weather expansions, event dots and detailed forecast on shared services | M | §5.1–5.2/§5.4 |
| M8 | Ilyamiro top media/EQ composition on equalizer-state backend | M | §5.9 |
| M9 | Theme transaction wrapper + missing consumer templates | **M** | §4 |
| M10 | SkwdBridge subscriber + evening timer | S | §4.1 |
| M11 | Full wallpaper-derived semantic generator: auto light/dark, colored surface ladders, contrast/chroma guards | **M–L** | §3–§4 |
| M12 | Nexus pages and glass tuner | **M–L** | §5.8 |
| M13 | Notification filter + ingress cap | S–M | §5.6 |
| M14 | Network password-path and NetworkUsage fixes | S | §5.2 |
| M15 | Alt+Tab live cycler | M | §5.16 |
| M16 | Clipboard service/panel + ilyamiro grid/morph | M | §5.13 |
| M17 | Native/same-workspace minimize state + rail restore/dimming + snap-pair state integration | **M–L** | §5.3/§6.2 |
| M18 | Dev workspace toggle/status/launchers | S–M | §7 |
| M19 | Camera watcher + mic status | S | §8.1 |
| M20 | Health/captive portal wiring | S | §8.4 |
| M21 | Plymouth + regreet theme | S | §5.11 |
| M22 | Generation trimmer + known-good pin | S–M | §8.4 |
| M23 | keyboard-backlightd + idle dim | S | §8.1 |
| M24 | plocate launcher file mode | S–M | §5.5 |
| M25 | DMS DisplayConfig adaptation | M | §5.2 |
| M26 | Sudo session switch | S–M | §7.5 |
| M27 | Deterministic two-pane snap orchestration, surplus minimization, pair dissolution/restoration | M | §6.2 |
| M28 | Native application update bridge: stable per-app roots/profiles, vendor/package adapters, native updater handoff/detection, app-local activation/rollback and three-version retention | **L** | §8.8 |
| M29 | Broad writing-suggestion layer: native spell menus + selected standard input-method candidate service, secure-field exclusion, custom dictionary and per-app controls | **M** | §8.4/§5.8 |

Explicitly **not built as final architecture:** DMS as the primary rail; iNiR/top-bar task buttons; top-bar pinned/running/minimized apps; Caelestia duplicate rail status stack; omarchy `special:min-*`; a second palette authority; a QuickShell per-window-button overlay; `slurp` capture/record geometry; drag-to-edge Aero glue unless separately approved.

---

## 10. THE BUILD SEQUENCE

Each stage ends at a gate; later-stage work may proceed in isolated worktrees, but each deployed closure stays intentional and stage-pure.

- **Stage 0 — Reconcile & baseline.** Existing gate/debt remains.
- **Stage 1 — Chassis up.** Caelestia chassis/services/surfaces running; existing acceptance debt remains recorded. Glass A/B is not accepted here; it is Stage 4.
- **Stage 2 — Window model + minimum left-rail recovery slice.** Drag-anchor and corner patches; hyprbars ABI match; DWT; pointer-scroll/click-focus; deterministic two-pane snap; same-workspace minimize backend; the final left-rail pinned/running/minimized/one-click-restore slice; screenshot color-fidelity/final Areapicker; detached-launch cleanup. **[GATE]:** §6.2 plus rail recovery and screenshot gates. No top widget bar is required in the Stage 2 closure.
- **Stage 3 — Ilyamiro top widget bar + independent expansions.** M1–M4 and M8: nearly source-faithful top composition, workspace 3+ model, media/EQ, clock/weather, system widgets/panels. At this gate Alex views completed top+left together and chooses the default rail visibility; persistent and immediate hover-reveal remain configurable.
- **Stage 4 — Wallpaper & theme pipeline.** skwd, SkwdBridge, palette transaction/templates, imports, and the explicitly moved glass A/B gate.
- **Stage 5 — Desktop layer + clipboard + polkit + switcher.** M15–M16, desktop menu, Hyprexpo and supporting surfaces. The rail app stack is no longer deferred here.
- **Stage 6 — Files, apps, native updates & writing assistance.** Dolphin suite, apps, portals and MIME; M28's Windows-equivalent native in-app update bridge and proven-exception graphical fallback; app-local rollback/three-version retention; M29's broad replacement-suggestion layer and physical coverage gate. Ordinary app updates must not require a NixOS rebuild, reboot, terminal, global notification or central updater when native UI exists.
- **Stage 7 — Boot & lock.** Plymouth, greeter/keyring, composite lock and suspend/lid gates.
- **Stage 8 — Dev workspace & agents.** Full agent workspace and responsiveness gate.
- **Stage 9 — Guardrails & Nexus completion.** System guardrails and Nexus pages, including the OS-generation updater/rollback page, writing-assistance settings and the graphical Applications & updates fallback **only** for apps proven to lack native Linux updater UI. No dashboard UI is built; resource/calendar/weather depth already lives in approved top expansions, Nexus, and sysmon.
- **Stage 10 — Hardware truth & polish.** Remaining hardware/bonus acceptance and known-good pin.

**Batch rule:** before every expensive build the PM publishes the closure manifest. Build time is used for compatible work in the current stage and isolated later-stage work. Gen 27 from the 2026-07-29 session is a valid compile/staging milestone but not the final Stage 2 candidate because it predates the approved snap/minimize/rail/focus decisions.

### 10.1 Sequencing clarifications — carried forward

Carried from the 2026-07-28 operator decisions. The full decision text, with dates
and acceptance conditions, remains in `EXECUTION_LOG.md`; these are the binding
summaries plus the testable specifics, which must not be lost in condensation.

- **Screenshot colour fidelity remains a Stage 2 blocker** (decision 15, 2026-07-28).
  Final Areapicker architecture, no overlay baked into output, correct region *and*
  full-screen output, clipboard *and* timestamped PNG. No throwaway interim
  implementation may be retained (MASTER §1.6). *Root cause was found and proven on
  2026-07-28 — slurp's selection overlay composited into the frame; the full-screen
  path was never defective. See findings 19a–19c.*
- **Glass A/B remains explicitly Stage 4** (decision 16, 2026-07-28). The current
  glass is **not accepted** — live `size 8 / passes 2 / vibrancy_darkness 0.38` is an
  unratified interim value, not a shipped decision. The Stage 4 gate must run the
  complete matrix: `size 12 / 1-pass` versus `size 8 / 2-pass`; `xray = true` versus
  `false`; the optional `decoration:glow` rim accent; actual wallpaper visibility
  through the surfaces; and Alex's physical visual approval. Stage 4 cannot close
  without it.
- **Agent CLI ownership/PATH persistence is pulled into the next compatible closure.** The live evidence shows Claude Code 2.1.220 still installed under `~/.local`, while the rebuilt environment resolves the older npm-global 2.1.211 first. Correct deterministic ownership now; do not wait for Stage 6 or Stage 8. This correction shares the next already-required build/reboot and adds current-shell/fresh-terminal/fresh-login/post-reboot version checks to its gate; it does not justify a standalone generation.
- **Clipboard surface remains Stage 5**, placement unchanged, and is committed
  scope — `cliphist` + `wl-clipboard` ingestion, the iNiR service/panel, the ilyamiro
  grid/morph presentation, `Super+V`, a clickable bar/System entry, and persistent
  history across reload. **Only the privacy-policy layer** (sensitive-type exclusion,
  expiry) is deferred per MASTER §15. The surface itself is not optional.

### 10.2 Architecture decisions — 2026-07-29

Record in `EXECUTION_LOG.md` with the active generation and operator-decision numbers:

1. Top bar = ilyamiro system/widget surface; left rail = caelestia app/window surface.
2. No app duplication on top and left; no final system-status duplication on the rail.
3. Left rail displays pinned apps always and running/minimized windows from current workspace only.
4. Multiple windows use hover previews and exact selection.
5. Minimized windows retain original workspace; `special:min-*` rejected.
6. One-click rail restore is mandatory; restore hotkey optional only.
7. Exact left/right snap; occupied-side replacement minimizes prior occupant; completed pair minimizes all surplus same-workspace windows.
8. Restoring surplus or changing the pair dissolves it and resumes ordinary tiling.
9. `follow_mouse = 2` behavior is the default.
10. Three visible workspaces + `+`; active extras expand responsively.
11. Rail default visibility waits for a completed top+left visual A/B; both modes remain available.
12. Future-stage implementation may proceed in isolated worktrees during waits; current closure remains stage-pure.
13. Pinch zoom already physically passed; no retest unless touched.
14. Four-finger up opens Hyprexpo Overview; the Caelestia dashboard UI and its edge/gesture triggers are retired.
15. Aurora is the project/shell codename, not a palette; the teal/purple/green preset is named Northern Lights.
16. Auto theme is dark-preferred but switches to light for clearly light wallpapers; the entire semantic palette and every supported consumer recolor coherently.
17. Native Linux updater UI is the primary and required app-update surface wherever it exists; the invisible bridge adapts Nix/package state to that UI. A graphical fallback is allowed only for a proven no-native-updater application, never a terminal.
18. Independent apps retain current + two previous binary versions maximum and update/roll back without a NixOS rebuild or reboot.
19. Writing assistance requires actionable replacement suggestions across standard daily text fields; passive red underlines alone do not satisfy Stage 6.

---

## 11. THE BONUS ROSTER (generous by instruction — Alex cuts here, not us)

Already woven into §5–§8: OCR (C6) · lyrics (C8) · color picker (C9) · auto-cycling + evening variant (C10) · Chrome polish pack (C16: VA-API shipped, swipe-nav flag, PiP float rules) · micro-status (C17) · Tailscale slot (C18, free inside the VPN manager) · screen-share DND (C15) · cursor-zoom accessibility (C19) · calendar ICS dots (C20) · keep-awake (idle inhibitor) · hold-to-confirm fills · settings search · Run-once · smart auto-hide · battery refresh-downclock · agent Fish abbrs · fastfetch art.

Promoted out of this list 2026-07-21 (now shipped in §5.2): ilyamiro's radial Bluetooth expanded view and FocusTime (opt-in page). Added to the plan: the sudo session switch (§7.5) and animated-wallpaper opt-in (§4.1).

Optional layer (in the plan, first to cut):
- **Desktop widgets** (iNiR edit-mode; clock + weather only) — C11.
- **Bar pomodoro** (iNiR timers) — C12 tail.
- **KDE Connect** (C7) — included as module + firewall ports + indicator; **needs Alex's phone answer** (Android = full; iPhone = files/clipboard only).
- **hypr-kinetic-scroll** (macOS inertial feel; A/B vs scroll_factor fix) and **hypr-dynamic-cursors** (delight) — perf-gated.
- iNiR DockPreview alternative (only if Caelestia preview path fails/perf-gated); snappy-switcher trial; drag-to-edge Aero glue; `build-vm` update sandbox; caelestia scheme/variant launcher modes; background Visualiser + DesktopClock.
- **Deferred/default-off:** matrix boot theme, Alienware port, self-hosted music, clipboard privacy policy. Animated-wallpaper capability ships with skwd but stays default-off behind its performance policy. The WiFi password-path fix is required when the network UI is adapted and is not silently deferred here.

---

## 12. THE RESOLVED ARCHITECTURE QUESTIONS

1. **Wallpaper renderer:** full skwd-wall + daemon; awww retired.
2. **How much caelestia:** the complete shell chassis and selected services/surfaces, with the final rail pruned to applications/windows and system popouts re-anchored to top widgets.
3. **Top-bar owner:** ilyamiro structure/widgets nearly 1:1, with only explicit Aurora system additions; no running/minimized apps.
4. **Left-rail owner:** caelestia structure/app previews; DMS/iNiR supply missing behavior patterns only; agridyne supplies major visual direction.
5. **Palette chain:** skwd triggers; the project's patched caelestia engine generates and publishes the complete auto-light/auto-dark semantic palette; iNiR/agridyne map consumers; Hellwal is fallback; Matugen is not system authority. Aurora is a codename, not the color policy; Northern Lights is one preset.
6. **Minimize/snap:** same-workspace minimized state, left-rail recovery, deterministic two-pane pair with surplus minimize.
7. **Lock:** agridyne visual direction + Vast engine + selected ilyamiro interaction/motion + DMS lifecycle/status donors.
8. **Lid, agents, protected state:** existing §8 decisions remain unchanged.
9. **Application updates:** native app-owned UI first, invisible per-app Nix/vendor bridge underneath, graphical fallback only after proving no native Linux updater, three-version cap.
10. **Writing assistance:** native replacement menus plus one standard input-method candidate layer for broad practical coverage; secure fields excluded and limitations documented by actual app testing.

---

## 13. SOURCE MAP — ownership, use, and explicit boundaries

### 13.1 Active implementation donors

| Source | Used for | Explicitly not used / boundary |
|---|---|---|
| `caelestia/shell-main/shell-main` | Shell chassis, plugin, services, drawers, launcher, notifications, OSD, session, utilities, Areapicker, Nexus, window previews, vertical rail structure; reusable dashboard data/components only | Stock status-heavy rail and dashboard UI are not final; does not own top-bar structure, final lock face, or wallpaper renderer |
| `caelestia` main repo + CLI | Hyprland patterns, toggle/CLI, scheme fan-out, btop/fastfetch/Fish assets | Does not override explicit window/snap/minimize decisions |
| `ilyamiro-nixos-configuration` | Top bar nearly 1:1; independent widgets/expansions; media/EQ; system-panel presentation; motion; clipboard presentation; selected lock interaction details; FocusTime | Does not own running/minimized apps, left rail, shell backends, or one unrelated morphing hub |
| `agridyne-dotfiles-dt/rice-contents` | Major glass/negative-space visual language, rail app-button treatment, KDE/chrome mappings, visualizer reference, lock visual composition | Does not own bar information architecture or backend behavior |
| `liixini-skwd-wall` + daemon | Complete wallpaper UI/renderer/transitions/library/apply event that triggers full theme generation | Not semantic palette authority; internal Matugen remains scoped to picker UI |
| `dankmaterialshell` | DisplayConfig/DisplayService, drag/drop patterns, lock lifecycle/status/greeter safety donors | Not primary rail/dock owner; not top-bar owner |
| `snowarch/iNiR` | Polkit, Cliphist, emoji/context menus, notification caps, systemd/perf patterns, GTK/Qt/Kitty writers, selected status services | Not top-bar/task-list owner; not primary lock face |
| Vast shell | Lock depth planes and gated unlock engine | Not entire lock visual identity or shell architecture |
| `hyprwm/hyprland-plugins` | hyprbars, Hyprexpo; carried narrow patches with ABI-matched Hyprland | Super+RMB is not acceptance; Hyprexpo is overview, not dashboard |
| `luisbocanegra/kurve` | Optional left-rail cava visualizer | Not required for rail/minimize acceptance |
| `end4-dots-hyprland` | hypridle and selected animation/base snap references | Does not override approved deterministic pair rules |
| `cxOrz/dotfiles-hyprland` | Selected panel/service and OSD patterns | Not primary system-panel architecture |
| `linuxbeginnings-hyprland-dots` / ML4W | Diffuse radial wallpaper-derived gradient technique | Not overall theme authority; hues come from the active scheme |
| `saatvik333-hyprland-dotfiles` | Terminal/dev experience quality reference and sourced pieces where cited | Not shell/bar architecture |
| `abusoww/tuxmate` | Installer UX reference | Not package backend authority |
| omarchy | Historical hyprbars values and minimize research reference | `special:min-*` backend explicitly rejected as final |

### 13.2 Policy/visual references rather than primary code owners

| Source | Role | Boundary |
|---|---|---|
| `mubin-thinks/minimal-wm-config` | Whole-system cohesion quality reference and gowall discovery | Its pinned-dark-surface policy is explicitly not adopted; result/reference only, not runtime palette authority |
| `nathanhoulamy/macos-dotfiles` | Whole-system theming/cohesion reference | No primary component ownership assigned |
| `SherLock707/hyprland_dot_yadm` | Wallpaper color-picking/theming research reference | Incomplete read must not silently become final code |
| `snes19xx/surface-dots` | Launcher/widget sizing and terminal-startup reference | Rofi and its opacity are not final architecture |
| `elifouts`, `GlassesArch`, `Sharddots` | Historical bar/glass mechanics and geometry references | Waybar implementation retired |
| `ekremx25` | Display-panel row-layout visual reference | DMS remains functional Display backend |
| `angelobdev/t2-easyeffects-preset` + AutoEq | Speaker/headphone preset sources | Audio backend only |

### 13.3 Fallback, optional, deferred, or rejected

| Source/tool | Status |
|---|---|
| Hellwal | Named palette-generator fallback only if the patched caelestia generator fails acceptance; must feed the same semantic contract |
| Matugen | Rejected as system-wide authority; skwd-internal use may remain scoped to picker UI |
| Hyprlock | Installed emergency lock fallback only |
| gowall | Optional inverse wallpaper recoloring tool |
| snappy-switcher | Cut-list fallback for Alt+Tab only |
| Harshil-Anuwadia boot theme | Deferred; current bootloader path unchanged |
| Waybar, Rofi, awww, Waypaper | Retired from final architecture |
| DMS primary dock, iNiR top task list | Rejected ownership roles, though narrow donor patterns remain usable |
| omarchy `special:min-*` | Rejected minimize backend |

### 13.4 Named utility layer

nix-software-center/`nh`/`nvd`, the invisible per-app update bridge and its app-specific adapters, the selected input-method candidate service, restic, udiskie, systembus-notify, gpu-screen-recorder, t2fanrd, hyprsunset, hyprpicker, tesseract, zellij, fzf/bat/fd, Starship, LazyVim, regreet/tuigreet and plocate keep only the roles assigned in their sections; no utility becomes a surface owner by convenience. The app-update bridge is backend infrastructure, never a universal replacement UI.

**Palette-specific ownership:** patched caelestia engine = semantic authority; skwd = wallpaper/trigger; iNiR + agridyne = consumer mapping/cohesion donors; Hellwal = fallback; Matugen = not system authority. Aurora is only the project codename; Northern Lights is one optional preset.

---

## 14. NO-SESSION LIST ACCOUNTING (nothing vanished)

A1→§2.1/§5.1 · D1→§2.1 (comparison run, drawers win) · D2→§5.9 (staged) · D4→§5.2 (bug-fixed donor) · D5→§5.6/M13 · D7→§3.2 gate · process workspace→§5.18 · Ctrl+Shift+T→§7.4 · MIME map→§5.17 · CUPS→§8.4 · VA-API→§8.7/§5.12 · Chrome pack→§11/§6.2 · weather Austin→§5.1/§5.2 · purple film→§5.12 · capture/launcher binds→§6.4 · system sounds→§8.4 · USB/trash→§5.17 · C17/C15/C19→§3.4/§5.6/§6.2 · C9→§5.7 · generation cleanup→§8.4/§10 · glass alpha/palette slots/EasyEffects/detach/motion/ML4W→§3–§4 · C6/C8/C11/C12/C20→§11/§5.1–§5.2 · B18 map→§6.3 · deferred security items→§11 · **C7/C18 user questions→§11 (flagged for Alex)**.

## 15. BUG LOG TRACEABILITY (§5 of MASTER → where it dies)

Input: DWT→§6.2 hwdb · repeat/scroll→§6.2 · pointer-scroll focus→§6.2 `follow_mouse=2` · gestures/pinch→§6.2. Windows: drag jump→§6.2 patch · corner resize→§6.2 mandatory patch · third-window/two-pane behavior→§6.2 deterministic pair · minimize/recovery→§5.3/§6.2 same-workspace rail · workspace bloat→§5.1 dynamic 3+ · move-between-workspaces→§5.1/§6.2 cross-surface drag. Bars/panels: app duplication→§5.1 removed · rail status duplication→§5.1 removed · ilyamiro source fidelity→§5.1–§5.2/§5.9 · calendar/dashboard duplication→§5.1/§5.4 retired · CPU/RAM distinction→§5.1 · capture actions→§5.7. Visual: glass→§3.2/Stage4 · full wallpaper-derived light/dark palette→§3–§4 · lock source ownership→§5.10 · motion→§3.3. Capture: pink film/slurp→§5.12 · region/window/full toolbar and focus restoration→§5.12. Lifecycle/QoL: agent version shadowing→§8.7–§8.8/Stage2 clarification · native app updates and three-version retention→§8.8/Stage6 · actionable typo suggestions→§8.4/Stage6/Stage9. Launcher/files/notifications remain in their existing sections.

---

*Everything before this document collapses into it. Build the OS.*
