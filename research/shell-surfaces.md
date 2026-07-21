# Shell Surfaces — Sidebar, Dock, Launcher Slice, Display Panel

Targeted research settling the two side surfaces + launcher packaging for the NixOS/Hyprland 0.55/QuickShell build (2020 T2 MacBook Air, i3 dual-core, Iris Plus, 8GB, 1.5x scale, single display).

Scope handled: (1) caelestia sidebar identity — contested claim settled · (2) dock three-way code+preview comparison and ranking · (3) sidebar visual spec · (4) caelestia launcher minimal-closure measurement (A3) · (5) display-panel rider (A5). Maps to MASTER §6 Sidebar/dock, §6 Launcher, §6 Dropdown panels (Display).

> **Access note.** Only the caelestia **main config repo** is cloned locally (`~/nix/repos/caelestia/`) — the `shell/` QML repo (`caelestia-dots/shell`) is **not** on disk. Its sidebar/launcher/drawer QML was read in the prior `caelestia.md` full-repo session (snapshot `dbb6d6c`, 2026-07-16). I corroborated its conclusions from on-disk main-repo evidence (keybinds/IPC) and previews. DankMaterialShell (DMS) and iNiR docks were read from disk in full. ekremx25/quickshell and noctalia-shell are **not** on disk — read via web (repo tree + README + viewed screenshots). Every ranking below was made after viewing previews, not on source alone.

---

## 1. SIDEBAR VERDICT — contested claim settled

**Claim under test:** "caelestia's sidebar is just a notification drawer." History: flip-flopped across sessions ("no dock" → "3-module composite" → "notification drawer").

### VERDICT (CORRECTED 2026-07-20): The *file* named `modules/sidebar/` is a 42-line notification drawer — but that is NOT caelestia's left surface, and stating it as "caelestia's sidebar is just a notification bar" was a naming-collision error that under-credited the whole left edge. Full code read written up in `caelestia-full-inventory.md`.

**Two different things were being called "the sidebar":**
1. **The code module `modules/sidebar/`** — verifiably `Content.qml` = **42 lines** (one `NotifDock` + a divider). Notification history only. True as a statement about *that file*.
2. **The left vertical surface seen in every caelestia screenshot** — icons, **live window previews** (`modules/windowinfo/Preview.qml`, a `ScreencopyView live:true`), **nested system-tray menus with drill-in submenus** (`modules/bar/popouts/TrayMenu.qml`, `StackView`+`QsMenuOpener`+`chevron_right`+`‹ Back`), a **tabbed dashboard** (`modules/dashboard/`, Dashboard/Media/Performance/Weather), the launcher, OSD, session, utilities, Nexus settings, and a QML lock. This surface is `modules/bar/` + `modules/windowinfo/` + `modules/dashboard/` + popouts — a full taskbar/control system, NOT a notification drawer.

Prior sessions (and my first pass) answered "what is caelestia / what is its left surface" by quoting the name of one 42-line module. That is the error. Caelestia is a complete desktop shell (57,875 shell LOC + 15.8k-line C++ plugin + 4.9k-line CLI). The dock-requirement finding is unaffected: the left surface still has no *pinned/running application dock* in the `§6` sense (that remains DMS/iNiR), but caelestia's left edge is emphatically far more than notifications.

**Evidence — on disk (current main repo, `~/nix/repos/caelestia/`):**
- `hypr/hyprland/keybinds.lua:9` binds the sidebar to `vars.kbShowSidebar` → IPC global `caelestia:sidebar`.
- `hypr/variables.lua:100` defines that var literally as `kbShowSidebar = "SUPER + N"` — **N for Notifications** — and it sits one line above `kbClearNotifs = "CTRL + ALT + C"` (line 101). The sidebar toggle and the notification-clear action are authored as a pair. That is a notification surface, not a dock.

**Evidence — shell QML (prior `caelestia.md` full read, snapshot `dbb6d6c`):**
- `shell/modules/sidebar/Wrapper.qml` — a 430-logical-px right-edge drawer, `showOnHover:false`, participates in `HyprlandFocusGrab` (click-away closes it).
- `shell/modules/sidebar/Content.qml` — contains a **notification dock and a separator, nothing else**. No pinned launchers, no running-task icons, no app groups, no visualizer.
- `shell/modules/sidebar/NotifDock.qml`, `NotifGroup*.qml`, `Notif.qml`, `NotifActionList.qml` — grouped notification history by app, expand/collapse, preview stacks, action buttons, body copy, close, swipe-to-dismiss, empty-state art; `Props.qml` persists expanded groups.

**Where "3-module composite" came from (and why it's still not a dock).** The *right edge* visually joins three separate surfaces: transient notifications (`modules/notifications/*`, top-right) + the notification-history sidebar (middle) + the utilities drawer (`modules/utilities/*`, bottom). When history opens, utilities opens too and their backgrounds interpolate to join over a 500 ms transition — hence "composite." Inside utilities the three cards are **Keep-Awake, Screen-Recorder, Quick-Toggles** — still no application dock. So both "notification drawer" (the sidebar module proper) and "3-module composite" (the whole right edge) are correct descriptions of the same thing viewed at different scopes; **neither is a pinned/running app dock.**

**Interaction model:** explicit toggle (Super+N) or edge swipe (~80 px threshold, `Interactions.qml`); dismisses via `HyprlandFocusGrab.onCleared` (click-away) and Escape.

**Visual (prior viewing of the shell showcase video):** right-edge surfaces emerge as small rounded cards deforming out of the screen border; tasteful, restrained, wallpaper visible in dark theme. Good **organization language** for our second surface — but it is not, and never was, an app dock.

**Consequence for the build:** caelestia contributes the **notification grouping/history model** (already the pick in `caelestia.md` #3) and right-edge organization language. It contributes **nothing** to the dock. The dock must come from elsewhere (§2 below), and the sidebar's glass app-tile + visualizer composition must be **specified and assembled** (§3 below), because no caelestia surface provides it.

---

## 2. DOCK — three-way comparison + ranking

Requirement (MASTER §6 Sidebar/dock): **left-vertical**, **pinned + running grouped**, mouse task actions (**hover preview, click activate, right-click close/close-all, pin/unpin, launch-new**), **glass icon-tile treatment**, **auto-hide**, **stable ordering**.

iNiR's dock is the depth baseline (already in `iNiR.md`). I brought DMS and ekremx25 to equal depth: DMS read in full from disk (Dock.qml 882 / DockApps.qml 695 / DockAppButton.qml 670 / DockContextMenu.qml 383 + 6 more files, 3,520 lines total); ekremx25 read via repo tree + README + viewed settings/desktop previews (source not on disk).

### Feature matrix (verified)

| Capability (§6) | **DMS** (disk) | **iNiR** (disk/`iNiR.md`) | **ekremx25** (web) |
|---|---|---|---|
| Left-vertical | ✅ `isVertical = Left\|Right`, all anchors branch | ✅ top/bottom/left/right | ✅ "Bar position toggle (top/bottom/left/right)" |
| Pinned + running **grouped** | ✅ pinned block → separator → running block; **group-by-app toggle** (collapses per-app windows) | ✅ pinned+running, grouped multi-window | ⚠️ pinned + running indicators + `DockSeparator`; grouping less explicit |
| Click activate / cycle | ✅ activate; grouped>1 opens window menu | ✅ click cycles app's windows | ✅ (running indicators via socket2) |
| Right-click menu: close / close-all | ✅ Close Window / **Close All Windows** | ✅ close / close-all | ✅ `DockContextMenu.qml` |
| Pin / unpin | ✅ Pin/Unpin from Dock | ✅ | ✅ (pin state persisted `dock_config.json`) |
| Launch-new instance | ✅ middle-click launches new; desktop `.desktop` actions ("New Window") in menu | ✅ middle-click launch-new + desktop actions | ⚠️ context menu present; launch-new not confirmed |
| **Hover window preview (live thumbnail)** | ❌ **text tooltip only** (`DankTooltip`, name + title) | ✅ **`DockPreview.qml` live screencopy** (the one decisive iNiR win) | ❌ `DockTooltip.qml` (text) |
| Auto-hide | ✅ regular + **smart auto-hide (retracts only when a window overlaps the edge)**, Hypr/Niri/Mango branches | ✅ auto-hide | ✅ auto-hide + window-overlap detection |
| Drag reorder, persisted | ✅ long-press→drag, shift-animation, `SessionData.setPinnedApps` | ✅ long-press reorder persisted | ✅ drag-and-drop (`DockGhostIcon`) |
| Stable ordering | ✅ pinned order fixed; running appended | ✅ "running apps stabilized to prevent reshuffle" | ✅ alignment configurable |
| Extras | overflow+expand toggle, per-display isolation, trash button, optional launcher-in-dock | pill/Mac presentation modes | **module slots** (Weather/Volume/Tray/Power/Media/Notepad), macOS **zoom magnification** |
| Running indicator | dots or circles, focus→primary color, up to 4 per group; row(horizontal)/column(vertical) | window-count/focus dots | dot or line, configurable |
| Glass **per-icon tile** | ❌ (shared rounded glass pill + WindowBlur + optional 1px border) | ❌ (bare full-color icons — viewed) | ❌ (icons on translucent strip — viewed) |

### Visuals (what I SAW)
- **iNiR** (`inir-1.png`, viewed): bottom-center dock = **bare full-color app icons floating directly on the desktop, no tile/background behind each icon**. Confirms the contested claim **"iNiR dock is visually conventional / no bespoke glass tiles" → TRUE.** The left sidebar is a dense translucent widget dashboard (calm it is not).
- **DMS** (`dms-desktop.png` + `dms-control.png`, viewed): Material dark-glass — rounded `surfaceContainer` at `dockTransparency` alpha, `WindowBlur` behind, optional 1px primary/secondary/surfaceText border. The dock is a **single glass pill** holding icons, not per-icon tiles. Palette (purple/pink/blue) is the closest of the three to the target aurora direction.
- **ekremx25** (`settings-monitors.png` desktop chrome + settings-dock, viewed; hero is an MP4 I could not frame-extract): bottom horizontal dock, full-color icons on a translucent strip, running indicators, **media widget slot** on the right, macOS-style **zoom-on-hover magnification**.

None of the three ships agridyne-style **per-icon bespoke glass tiles**. That treatment is the acceptable "small glue" exception (§3) layered on top of whichever dock wins.

### RANKING (against §6, for THIS build)

**1st — DankMaterialShell.** Most complete and the best aesthetic fit. Left-vertical is first-class; pinned+running with separator AND a group-by-app toggle; the full task-action set (per-window activate/close, close-all, pin/unpin, desktop `.desktop` actions incl. New Window, middle-click launch-new); **smart auto-hide** (retract only on real window overlap — ideal on a single small screen); drag-reorder persisted; overflow, per-display isolation, and trash as bonuses; clean Material dark-glass with `WindowBlur` + configurable border. Weaknesses: hover is a **text tooltip, not a live thumbnail**; glass is a shared pill (per-icon tiles must be added). Coupling: `SettingsData`/`SessionData`/`CompositorService`/`Theme`/`Widgets` — real but self-contained and already Nix/Hyprland-native.

**2nd — iNiR.** Equally capable on task actions and the **only** candidate with **live window-thumbnail hover previews** (`DockPreview.qml`). If live previews are wanted, that is the piece to graft — but note: (a) live screencopy previews are **GPU/bandwidth-costly on Iris Plus** (`iNiR.md` flags this), a questionable default on a dual-core i3; (b) the dock is the most **coupled** option (210k-LOC shell, its services/tokens), Niri-first (Hyprland branches already present); (c) visually the most conventional (bare icons). Strong, but heavier to carry and less aligned with the calm/glass target.

**3rd — ekremx25.** A real, well-factored dock (11 files, backend/data-service split, context menu, drag ghost, module slots) and compositor-agnostic (Hypr/Niri/Mango). But its signature is a **macOS zoom-magnification** dock — playful, at odds with the target's calm aurora restraint — hover is a text tooltip (no live preview), pinned+running grouping is less explicitly documented than DMS/iNiR, launch-new unconfirmed, and I could not read its source from disk or view a still of the running dock (only settings panels + a video). Keep as a **fallback / idea source** (module slots and overlap-detection auto-hide are nice), not the base.

### Contested claim resolved: MASTER §6 ("DMS dock is the leading source") beats SYNTHESIS ("iNiR provisionally wins").
SYNTHESIS ranked iNiR first **only because DMS had not yet received equal-depth research** ("the DankMaterialShell dock remains a decision candidate only after its own code receives equivalent research; the current evidence supports iNiR"). Having now read DMS to greater depth than the SYNTHESIS had, DMS is **more** complete (overflow, group-toggle, smart-autohide, per-display isolation, trash), better matched to the calm/glass aesthetic, and less coupled than the 210k-LOC iNiR shell. **DMS is the dock base.** iNiR contributes exactly one optional graft — `DockPreview.qml` live previews — gated on an Iris Plus perf measurement.

### Adaptation delta (DMS base)
Fix position to Left. Map `Theme` roles to our fixed near-black-blue glass tokens (pin surfaces, adapt accent only). Swap Material icon set → Papirus. Add the **per-icon glass tile** treatment (§3) as a small delegate wrapper — the one bespoke piece no repo provides. Prune: connected-frame-chrome shaders, dGPU launch, Niri/Mango branches (keep Hyprland). Keep smart auto-hide (retract-on-overlap). Detached launch is already correct (`SessionService.launchDesktopEntry`). Optionally graft iNiR `DockPreview` only if Iris Plus frame budget allows; otherwise keep DMS tooltips. Add the Kurve Cava strip as a separate non-interactive sibling (§3), not inside the dock.

---

## 3. SIDEBAR VISUAL SPEC (half-page, buildable)

No stock sidebar matches intent (caelestia's is notifications; iNiR's is a widget dashboard; agridyne's is KDE Plasma panels). So the left surface is **assembled** from: DMS dock (task rail) + a bespoke glass-tile delegate (motif from agridyne) + the Kurve Cava strip (exact sizing from agridyne). Everything monochrome-glass-consistent per §3.

**Form.** One left-anchored vertical `PanelWindow`, ~64–72 logical px wide, full-height minus top-bar, auto-hiding (DMS smart auto-hide: retracts only when a window touches the left edge). Real glass: surface ~`rgba(10,14,26,0.55–0.65)`, blur 12–16px, 1px border at ~10% white (§3 spec). Wallpaper must show through.

**Glass app-tile treatment (motif = agridyne).** Viewed in `panel-layout.png`: agridyne's whole desktop is **monochrome glass** over a grayscale wallpaper; app affordances read as **rounded translucent tiles with a soft frosted fill and faint light rim**, not bare icons — a restrained, desaturated version of the "YouTube-tile" launcher look. Translate to each dock slot: a `~48px` rounded-square (radius ~12–14px) glass tile = translucent dark fill (one shared `0.60` outer tint), **1px ~10% white inner rim**, Papirus icon centered at ~28–32px, low-alpha hover layer (Material `StateLayer`, ~200ms) that brightens the tile rather than swapping color. Pressed/active tile gets a thin accent underglow (Hyprland 0.55 `decoration:glow` analogue). This is the piece to hand-build over the DMS delegate — the sanctioned "small glue" exception (§1.2).

**Group arrangement (top→bottom):** [Apps/launcher tile] → **pinned group** (Chrome, Kitty, Thunar…) → **1px ~15% separator** (DMS `createSeparator`) → **running group** (activate/close/cycle, running-dot indicator to the icon's side in vertical mode) → flexible spacer → **Kurve Cava visualizer strip** pinned at the bottom → (optional) tray/status micro-icons. Pinned order fixed & persisted; running appended in stable order (DMS guarantees both).

**Kurve Cava visualizer strip (exact, verified from `kurve-settings-1/2.png`):** Style **Blocks**, **Fill wave on**, Draw-inactive-blocks off, Circle mode off, **Orientation Left**, Centered-bars off, **Rounded bars on**, **Bar width 4**, **Bar gap 5**, **Block height 5**, **Block gap 4**; Bar-color source **System → Window / Highlight Color**, Alpha 1.00, Lightness contrast 1.00; **Desktop background Transparent**; and Kurve's **"Disable left click"** toggle exists — set it so the strip is **non-interactive/passive**. Place it as a bottom vertical band ~full-tile-width × ~120–160px tall, transparent background so the sidebar glass and wallpaper show through the blocks. It shares one Cava process with the music widget (SYNTHESIS: single demand-driven Cava); stop/reduce it when silent or on battery.

**Net:** left vertical glass rail = DMS task-dock mechanics + agridyne monochrome glass-tile skin + agridyne-spec Kurve block strip at the foot. Calm, dark, wallpaper-through, one visual system.

---

## 4. LAUNCHER SLICE MEASUREMENT (A3) — dependency ownership

Behavior/appearance already decided (MASTER §6): caelestia's launcher (real icons, fuzzy field-prefix search-as-type, favorites, frequency ranking, calculator, detached `DesktopEntry.execute()`, Escape + **verified click-away via `HyprlandFocusGrab`**). Open question = **what must we carry to run only the launcher.**

### The launcher is NOT a clean 5-file drop-in. Its closure:
**Launcher QML** (`shell/modules/launcher/`): `Wrapper.qml` (drawer geometry — **must be replaced** by our independent glass window), `Content.qml`, `AppList.qml`, `ContentList.qml`, `items/AppItem.qml`, `WallpaperList.qml` (**drop** — skwd-wall owns wallpapers, §15), `services/Actions.qml` (theme/scheme/wallpaper/lock/sleep actions).

**Hard shared-foundation deps** (imported by the above): Caelestia `Config` tokens (`plugin/src/Caelestia/Config/*`), `Components` (styled Button/TextField/containers/Material shapes), `services/Colours.qml` (semantic palette), `Images/*` caching image provider, and shared screen state (`ScreenState`/`ShellState`) + the `ContentWindow` `HyprlandFocusGrab` block.

**Native C++ plugin deps** (the expensive part): `plugin/src/Caelestia/appdb.*` (SQLite app-frequency ranking) and `qalculator.*` (libqalculate calculator). These are **not** separable per-module libraries — they compile as **one monolithic Qt6 QML plugin** whose build closure is **Qt6 tooling + libcava + libqalculate + aubio + libsensors + image/system libs** (i.e. the *whole shell's* native closure).

### The decision (concrete):
Because the native plugin is monolithic, **"carry just the launcher" still drags the entire C++ closure** the moment you keep `appdb` (frequency ranking) or `qalculator` (calculator). So the real fork is:

- **(A) Pure-QML slice — RECOMMENDED.** Drop the native plugin: replace `appdb` frequency-ranking with `DesktopEntries.applications` + a small QML MRU list, and drop/replace `qalculator` (a tiny QML calc or omit). Carry ≈ **7 launcher QML + ~12–15 shared Config/Components/Colours/Images QML ≈ ~20 QML files, ZERO compilation.** You keep glass, icons, search-as-type, favorites, click-away, detached launch. You lose SQLite frequency-ranking and native calc (both "nice-to-have," not core). **This slice is genuinely cheaper than the full shell.**
- **(B) Full-plugin path.** Keep frequency-ranking + calculator → you compile the entire ~15,800-line native plugin (Qt6 + libcava + libqalculate + aubio + sensors). At that point the "slice" buys nothing over the packaged shell in closure terms.

### Is carrying the slice cheaper than "run the configured shell with other modules disabled"?
**Two-part answer.** (1) In **build-closure** terms: slice-with-plugin (B) ≈ full shell (same monolithic C++), so no win; slice-**without**-plugin (A) is **materially cheaper** (pure QML, no libcava/libqalculate/aubio/sensors). (2) In **runtime-architecture** terms, "run the configured caelestia shell with modules disabled" is **not actually an option** here: our build runs **our own single QuickShell** (bar + independent panels + this dock). Two QuickShell instances both claiming Wayland layer surfaces is a conflict. So the launcher must be **absorbed as a module into OUR QuickShell config**, not run as a second shell.

### Recommendation
Vendor the **pure-QML launcher slice (A)** into our QuickShell config: ~20 QML files, no native build. Replace `Wrapper.qml` with our independent glass `PanelWindow`; keep the `HyprlandFocusGrab` click-away block verbatim; map `Colours` → our fixed dark-glass tokens; centralize Papirus icons; set rows/dimensions for the 1707×1067 logical Retina surface; bind **both** Apps-button and **Cmd+Space** to its IPC action (change from caelestia's Super_L). Route file results to the future search provider; keep app/actions modes. Only escalate to the native plugin (B) if SQLite frequency-ranking or the libqalculate calculator later prove worth the full C++ closure — treat that as a deliberate upgrade, not the default.

**Size estimate:** slice (A) ≈ 20 QML files, ~2–3k LOC, no compile. Full plugin (B) ≈ +~15.8k LOC C++ + 5 native build deps. Delta strongly favors (A).

---

## 5. DISPLAY-PANEL RIDER (A5)

Goal: make ilyamiro's `MonitorPopup` (SYNTHESIS' default-by-elimination for the Display panel) a **real** choice by comparing DMS and noctalia (and a bonus: ekremx25). Single display today; keep multi-monitor future (§14 Alienware port) in mind.

### DMS DisplayConfig (read in full from disk) — the strongest option
Files: `Modules/Settings/DisplayConfig/` (`OutputCard.qml` 406, `DisplayConfigState.qml` **2,726**, `HyprlandOutputSettings.qml` 321, `NiriOutputSettings.qml` 382, `MonitorCanvas.qml`, `MonitorRect.qml`, `MonitorIdentifyOverlay.qml`, …) + `Services/DisplayService.qml` (1,784).

Verified controls: **Resolution & Refresh** (per-output mode list), **Scale** (presets + custom), **Transform** (Normal/90/180/270 + all Flipped variants), **VRR/adaptive-sync** (off/on/fullscreen), **Mirror**, **Disable output**, **draggable arrangement** (`MonitorCanvas`/`MonitorRect` with snap), **Identify** overlay, plus Hyprland extras (HDR, color gamut, 10-bit). Application is **real** and compositor-branched: wlr-randr mode overrides for Hyprland, `NiriService.applyOutputConfig` for Niri; pending-changes → apply model; **profiles persisted and restored on reconnect**. Bonus: `DisplayService` does **battery-aware refresh downclock** (drops to 60Hz on battery) — directly useful for the dual-core i3's battery life.

### noctalia-shell (web) — capable but caveated
Display config supports **scale, mode, refresh rate, VRR, transform, position**, applied at runtime via compositor IPC (`niri msg`, `hyprctl`, `swaymsg`). But: **v5 is native C++/OpenGL ES, NOT QuickShell** (v4 was QuickShell/QML) — so v5 isn't QML-adoptable and v4 is legacy. Open bugs: resolution not updated live in the UI until manual reload (#1845); persisting monitor settings to the compositor config was still a **feature request** (#2344), i.e. persistence was incomplete. Weaker and less adoptable than DMS.

### ekremx25 (web, viewed `settings-monitors.png`) — BONUS, genuinely excellent UI
`Modules/bar/System/`: `MonitorsPage`, `MonitorDisplaySettings`, `MonitorColorSettings`, `MonitorLayoutCanvas`, `MonitorLayoutLogic.js`, `MonitorGeometry.js`, Hypr/Niri/Mango `*MonitorCommands.js`, `MonitorsApplyFooter`, `apply_monitors.sh`. Viewed panel: draggable "Rearrange your displays" canvas with snap, per-display card (Mode/Scale/Layout/Color + "This is my main display"), **resolution row**, **refresh-rate row** (165/144/120/100/60/59.9/50), **scale row** (50–200% + custom), **position nudge** (X±/Y±/reset), **Advanced color** (HDR toggle, 8/10-bit, VRR off/on/fullscreen), **Revert/Saved** apply model, "layout looks healthy" check. The **best-looking** display panel of all candidates and compositor-agnostic — but source isn't on disk (couldn't read depth) and it's embedded in ekremx25's settings window.

### Rider verdict
**ilyamiro `MonitorPopup` is no longer the default — DMS `DisplayConfig` is the recommended Display-panel source.** DMS decisively out-capabilities MonitorPopup (VRR, transform, mirror, HDR/bit-depth, real per-compositor apply, reconnect persistence, battery-aware downclock, AND its own draggable arrangement canvas), is already QuickShell/Nix/Hyprland-native, and is on disk to vendor. Cost: it couples to `DisplayConfigState` (2,726 lines) + `CompositorService` + `SettingsData` — heavier than MonitorPopup, but justified. **ekremx25's monitor panel is the visual/UX reference** (its resolution/refresh/scale button-rows and health-check read cleaner than DMS's dropdowns) — mine its layout even if DMS is the code base. Keep ilyamiro `MonitorPopup` only as a lightweight fallback if the DMS state-singleton coupling proves too costly to port. For **today** (single display), expose just Mode + Refresh + Scale + Transform; keep the arrangement canvas code dormant for the multi-monitor future.

---

## 6. BONUS FINDS (flagged; fit §0/§2/§3)

- **DMS smart auto-hide (retract-on-overlap)** — the dock stays visible until a window actually reaches the edge, then retracts. On a single 13" screen this is materially better than time-based auto-hide (§0 "is it hidden or tucked away?" balanced against space). Adopt for the sidebar rail.
- **DMS battery-aware refresh downclock** (`DisplayService`) — auto-drop to 60Hz on battery. Cheap daily win on the dual-core i3 (adjacent to §10 perf budget). Not requested; worth having.
- **ekremx25 dock module slots** (Weather/Volume/Tray/Media/Notepad on the dock's ends) and **overlap-detection auto-hide** — a tidy pattern if we ever want status affordances on the rail itself.
- **ekremx25 Displays panel UX** — the button-row resolution/refresh/scale layout + "layout looks healthy" reassurance is a Raycast-grade settings presentation (§0/§3); use as the visual template for our Display panel regardless of code base.
- **DMS per-app running indicators** (row vs column auto-swap by orientation, up to 4 dots per grouped app, focus→accent) — clean, cheap, correct for a vertical rail.
- **Caelestia utilities cards** (Keep-Awake / Recorder / Quick-Toggles) as the right-edge "System" grouping — already noted in `caelestia.md`, reinforced here as the counterpart surface to the left dock.

---

## 7. WHAT I ACTUALLY READ/VIEWED vs WHAT I DIDN'T

**Read from disk (full):**
- caelestia **main repo** — `manifest.toml`, `hypr/hyprland/keybinds.lua`, `hypr/variables.lua` (settled the sidebar IPC/keybind evidence).
- DMS dock — `Dock.qml` (882), `DockApps.qml` (695), `DockAppButton.qml` (670) in full; `DockContextMenu.qml` actions extracted; file inventory of all 11 dock files.
- DMS display — `DisplayService.qml` + `DisplayConfig/*` capabilities (resolution/refresh/scale/transform/VRR/mirror/arrangement/battery-downclock) confirmed by grep across `OutputCard.qml`, `HyprlandOutputSettings.qml`, `NiriOutputSettings.qml`, `DisplayConfigState.qml`.
- Prior research files: `SYNTHESIS.md` (sidebar/launcher/display sections), `caelestia.md` (full), `iNiR.md` (dock section), `MASTER_REQUIREMENTS.md`.

**Viewed (previews):**
- agridyne `panel-layout.png` (monochrome glass desktop / tile motif), `kurve-settings-1.png` + `kurve-settings-2.png` (exact visualizer config — all values verified).
- DMS `dms-desktop.png` (top bar/OSD, palette) + `dms-control.png` (Material glass control center).
- iNiR `inir-1.png` (bottom dock = bare colored icons, no tiles — settled the "conventional" claim; left widget-dashboard sidebar).
- ekremx25 `settings-monitors.png` (full Displays panel + desktop chrome incl. bottom dock + media slot).

**Read via web (not on disk):**
- caelestia **shell** QML — **not cloned**; relied on prior `caelestia.md` full read (snapshot `dbb6d6c`) corroborated by on-disk main-repo IPC/keybind evidence.
- ekremx25/quickshell — repo tree (11 dock files, monitor-config files), README (dock features, orientations, deps).
- noctalia-shell — search results + docs/issue references (capabilities + v5-is-native caveat + persistence/live-update bugs).

**Did NOT do / could not do:**
- Could **not** read caelestia shell QML, ekremx25 dock QML, or noctalia display QML **from source** (not on disk / web-only) — depth for those rests on prior reads, repo trees, and viewed previews, not line-by-line source this session.
- Could **not** frame-extract ekremx25's hero (it's an MP4; no ffmpeg used) — ekremx25 dock visual rests on its settings screenshots + README + the monitors-panel desktop chrome, not a still of the running dock.
- Did **not** measure any of this on target hardware (Iris Plus perf of live dock previews, blur passes, Cava cost) — flagged as measurement gates, per §10, not resolved here.
- Did **not** re-read DMS `DockLauncherButton`/`DockTrash*`/`DockGeometry`/`DockOverflowButton` line-by-line (inventoried and behavior-confirmed via `DockApps.qml` wiring, not fully read).
