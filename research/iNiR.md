# iNiR — Full Research

## Repo overview

iNiR is a very large QuickShell/Qt 6 desktop shell whose primary compositor is Niri. It began as a fork of the end-4 Hyprland dots, retained substantial Hyprland support, and has since grown into two mutually exclusive shell families sharing one services layer:

- **Material ii**: top or vertical bar, sidebars, dock, overview/launcher, notifications, OSD, wallpaper tools, desktop widgets, and five visual styles named `material`, `cards`, `aurora`, `inir`, and `angel`.
- **Waffle**: a separate Windows 11-inspired bottom taskbar, Start menu, Action Center, notification center, Task View, widgets, and a separate visual-token system.

Research snapshot:

| Item | Snapshot read |
|---|---|
| Upstream | <https://github.com/snowarch/inir> |
| Commit | `01434067705d9dfce10709dbe680474dacc35261` |
| Commit date | 2026-06-11 |
| Declared version | 2.27.0 |
| Tracked files | 1,591 |
| QML | about 210,400 lines across 709 module QML files plus 87 service QML files |
| QML/JS/Python/shell/Nix/JSON/TOML combined | about 321,500 lines |

This scale matters. The guide's description of a roughly 210k-line shell is accurate for QML alone; the complete executable/configuration code is substantially larger. The repository is not a small set of widgets. It includes shell UI, runtime services, a large CLI/setup system, distribution support, color generation and app-theme writers, Niri defaults and editors, a Nix flake, translations, wallpaper/thumbnail infrastructure, web-app support, capture tools, and update/rollback logic.

The current README is candid about its status: this is a personal daily-use shell with messy areas, and it explicitly warns that it is not intended for low-spec machines. That warning is directly relevant to the target dual-core i3, Iris Plus GPU, and 8 GB RAM. The repository documentation estimates roughly 200–400 MB for a loaded shell, but that is an upstream estimate rather than a measurement on the target hardware.

The architecture is a single QuickShell process with no separate native backend daemon. `shell.qml` owns the root composition and loads services/panels in tiers. Critical configuration and services start first; lower-priority services are delayed by hundreds of milliseconds to reduce startup contention. Inactive shell-family panels are held behind source-based lazy loaders so their QML is not parsed until required. This is a strong large-shell startup pattern.

The repository has a current Nix flake with packages, a NixOS module, and a Home Manager module. The service can be wired to either `niri.service` or `wayland-wm@Hyprland.service`; the latter means the packaging already acknowledges Hyprland as a supported runtime. The Nix path is described as experimental and packages the source immutably while leaving preferences in the user's normal config/state directories.

Two guide claims need correction against the current source:

1. There is no approximately 40-line palette file that independently restyles the shell. Built-in palettes define roughly 54 Material semantic roles, and `Appearance.qml` derives hundreds of secondary color, typography, rounding, spacing, and motion tokens from them. `ThemePresets.qml` is 3,879 lines with 46 preset entries, not a small drop-in palette collection.
2. `aurora` and `angel` are visual styles, while `Angel` is also a separate named color preset. The stock Angel palette is warm amber/gold over a near-black brown-purple base, not the target blue/purple/teal palette. The useful result is the separation of style mechanics from palette roles, not adoption of Angel's colors.

## Visual impression

I viewed all eight current full-resolution README screenshots—six Material ii and two Waffle screenshots—and the repository's separate desktop-widget editor screenshot. The repository contains no current showcase video, and the README does not link a separate showcase post. The screenshots therefore establish layout, color cohesion, density, and static transparency, but they do not visually prove the runtime motion quality. Motion findings below come from source, not from inferring animation from still images.

Material ii is visibly more cohesive than the current target desktop described in the master requirements. Each screenshot carries one palette across the wallpaper, bar, dock, sidebars, popups, settings surfaces, charts, and controls. The red/pink screenshot is the strongest demonstration: the wallpaper color propagates into virtually every visible UI element without looking like unrelated widgets were themed separately. The dark blue screenshot shows a restrained, professional Material surface hierarchy. Other screenshots use smoky grey, deep red/black, or muted blue palettes consistently.

The actual glass result is mixed:

- The first two Material screenshots show broad wallpaper-tinted translucent sidebars, a slim edge bar, and a dock. The wallpaper remains visible through the surfaces, so this is real wallpaper-through transparency rather than an opaque black panel with blur behind it.
- The right sidebar in the dark blue screenshot and several cards in the red/black screenshot read much closer to opaque Material surfaces. iNiR can look like glass, but the stock gallery does not demonstrate a universally clear-glass treatment across every panel.
- Borders are thin and subtle, and surface separation is usually achieved with tint, tonal elevation, and restrained shadow rather than bright outlines. That part aligns well with §3.
- The large left sidebar is information-dense and visually dominant. It looks feature-rich, but it is less calm and more crowded than the target's Raycast-level restraint.

The screenshots do not label which Material ii image uses Aurora versus Angel, and they do not provide a controlled side-by-side comparison of those modes. It would be inaccurate to claim that the official gallery proves the exact visual difference between them. Source establishes that Aurora is configurable acrylic-like transparency and Angel is an Aurora-derived sharp neo-brutalist treatment with partial borders and offset “escalonado” shadows. The current Angel color preset itself is warm amber, which is visibly the wrong palette direction for §3 even though its deep surface values are useful reference points.

Waffle is a convincing Windows 11 interpretation: centered taskbar, Start menu, widgets, calendar/notification center, and quick settings use translucent acrylic panels, thin borders, and familiar spacing. It is coherent and functional, but intentionally derivative. It is not a useful visual basis for the target's distinctive aurora-glass identity, and adopting its second token system would multiply integration work.

The desktop-widget editor screenshot shows just how configurable iNiR is: clock, weather, resource rings, media player, quick status, and visualizer widgets can be positioned on a visible grid, resized, restyled, and configured in place. The red/pink palette is extremely cohesive across the edit handles and widgets. The editor view is naturally busy, but it is strong evidence that the shell treats mouse-driven configuration as a first-class feature rather than assuming JSON editing.

Overall visual verdict: iNiR is a strong reference for system-wide color propagation, live style controls, coherent component theming, and feature completeness. It is not the strongest reference for calm composition, guaranteed transparent glass, or proven cinematic morphing. Aurora's mechanics are valuable; Angel's stock colors and offset-shadow visual identity should not define the target.

## Structure

```text
inir/
├── shell.qml                         root composition and staged loading
├── FamilyTransitionOverlay.qml       full-screen ii ↔ Waffle transition
├── modules/
│   ├── common/
│   │   ├── Appearance.qml            ii semantic/derived visual tokens
│   │   ├── Config.qml                typed config schema and persistence
│   │   ├── ThemePresets.qml          46 preset entries and preset writer
│   │   ├── StylePresets.qml          size/rounding style metadata
│   │   ├── functions/                color, shell, file, session helpers
│   │   └── widgets/                  reusable controls, glass, notifications
│   ├── bar/ and verticalBar/         modular bar, taskbar, tray, media, status
│   ├── dock/                         pinned/running apps and previews
│   ├── sidebarLeft/                  apps/content/web services/widgets
│   ├── sidebarRight/                 quick controls and system widgets
│   ├── overview/                     launcher/search plus workspace overview
│   ├── mediaControls/                MPRIS cards and Cava visualizers
│   ├── wallpaperSelector/            grid and flat Cover Flow gallery
│   ├── clipboard/                    cliphist panel
│   ├── notificationPopup/            transient notifications
│   ├── background/                   wallpaper, effects, draggable widgets
│   ├── settings/ and controlPanel/   GUI configuration surfaces
│   ├── lock/ and sessionScreen/      shell lock/session UI
│   ├── regionSelector/               capture, annotation, OCR tooling
│   └── waffle/                       separate Fluent-style shell family
├── services/
│   ├── CompositorService.qml         compositor detection/shared facade
│   ├── NiriService.qml               Niri event/socket model
│   ├── HyprlandData.qml              supplemental hyprctl snapshots
│   ├── MaterialThemeLoader.qml       colors.json watcher and role application
│   ├── ThemeService.qml              auto/manual theme coordinator
│   ├── Audio.qml Network.qml         PipeWire and NetworkManager-facing logic
│   ├── BluetoothStatus.qml           BlueZ/QuickShell status facade
│   ├── Notifications.qml             server/history/grouping/persistence
│   ├── ResourceUsage.qml             demand-driven CPU/RAM/GPU/disk sensors
│   └── deferred/                     Cava, launcher, clipboard, package search
├── scripts/
│   ├── colors/                       palette generation and app fan-out
│   ├── cava/                         shared visualizer config/input selection
│   ├── images/ thumbnails/ videos/   wallpaper/capture support
│   ├── niri-config.py                large Niri configuration editor
│   └── inir                          runtime CLI
├── defaults/
│   ├── config.json                   authoritative shipped values
│   ├── niri/                         Niri config fragments
│   ├── gtk-3.0 gtk-4.0 kde/          generated-theme targets
│   ├── plugins/ widgets/             default manifests
│   └── matugen/                      legacy templates retained in the tree
├── dots/                             desktop/session files and themes
├── distro/ sdata/ setup              install/update/distribution machinery
├── translations/                     localized UI strings
├── docs/                              architecture and subsystem documentation
└── flake.nix                          package, NixOS module, HM module
```

### Runtime composition

`shell.qml` uses a single `ShellRoot` and a tiered startup sequence. Core configuration, appearance, directories, compositor detection, wallpaper state, audio, battery, networking, and IPC are initialized before panels. Expensive or nonessential services such as weather, voice, preview capture, game mode, font sync, and Cava theme support are delayed. The shell declares separate lazy panel sets for ii and Waffle; changing family swaps the set behind a full-screen transition overlay.

This is a mature response to a huge QML codebase. It does not make the shell lightweight, but it avoids paying the complete parse/service cost immediately. `ResourceUsage.qml` similarly starts sampling when a consumer requests it and stops after approximately 15 seconds without consumers, unless an always-visible component registers itself as persistent. `CavaService.qml` shares one Cava subprocess across all visualizers and debounces teardown, correcting an earlier one-process-per-widget design.

### Configuration and state

The normal configuration path is `~/.config/illogical-impulse/config.json`. `modules/common/Config.qml` is a 2,281-line typed schema with defaults, hot reload, migration-compatible access, and `setNestedValue` persistence. A 50 ms write/debounce path keeps GUI changes live. Many consumers depend on `Config.revision` because modifying nested JSON/QML objects by bracket lookup does not always emit a useful property notification.

The GUI settings surfaces write through the same API; they are not separate mock controls. This is why Aurora/Angel slider movement can update visible shell surfaces immediately and persist without restarting QuickShell.

### Two independent token families

Material ii reads `Appearance.*`. Waffle reads `modules/waffle/looks/Looks.qml` and related tokens. They share services and config but not visual primitives. This separation helps each family remain coherent, but it also means only the ii token system is relevant to the target. Trying to combine both would create duplicate color, typography, spacing, and motion authorities.

## Component inventory

### Top/vertical bar

Key files:

- `modules/bar/Bar.qml`
- `modules/bar/BarContent.qml`
- `modules/common/widgets/BarModuleOrderEditor.qml`
- `modules/settings/BarConfig.qml`
- `modules/bar/Workspaces.qml`
- `modules/bar/BarTaskbar.qml` and `BarTaskbarButton.qml`
- `modules/bar/Media.qml`
- `modules/bar/ActiveWindow.qml`

The ii bar can be top, bottom, or vertical and can use one connected background or separated groups. Its current layout model has five zones: left, center-left, center pivot, center-right, and right. The shipped arrangement places the left-sidebar/active-window area on the left, resources/media at center-left, workspaces at the center pivot, clock/utilities/battery at center-right, and sidebar/tray/timer/update/weather utilities at the right.

`BarModuleOrderEditor.qml` is a polished mouse-driven drag editor with real `DropArea`s, a lifted drag item, insertion marker, cross-zone movement, and persistent updates to `bar.layout.*`. The center pivot module—normally workspaces—is deliberately fixed. Bar geometry reacts to available width and can collapse modules or grant natural content width to centered pills. This is much stronger than a hard-coded three-pill bar.

The optional bar taskbar uses the dock's pinned-app list, shows pinned and running applications, provides hover previews, focuses/cycles windows on click, launches a new instance on middle click, and exposes pin/unpin, desktop actions, launch, and close in a context menu. Application launching routes through `ShellExec`, which tries `systemd-run --user --scope --collect` and falls back to an exec path. This directly avoids the target defect where restarting the bar kills apps (§5, §6 Top bar).

Important gaps against §6:

- Enabling the taskbar replaces the active-window title; the bar cannot show both through the stock configuration even though the target wants running tasks plus active title.
- `ActiveWindow.qml` displays app name/title only. It does not provide min/max/close controls.
- Workspace buttons are clickable and scrollable but are not drop targets for moving a dragged window (§4.16).
- The media item provides title, circular progress/play state, click-to-open controls, mouse buttons for transport, and wheel volume. It does not show a source-application icon that opens the themed source app (§4.17/§6).
- There is no dedicated display mode/resolution/refresh module.
- The network status module exposes SSID and signal percentage, not Mbps (§4.7).

Quality/portability: high for layout/editor mechanics and task behavior; medium as a direct top-bar candidate because several stock exclusivity decisions conflict with the requested composition. The reusable slice is still large because it depends on `Appearance`, `Config`, application lookup, shared toplevel models, tray, and compositor services.

### Dock

Key files:

- `modules/dock/Dock.qml`
- `modules/dock/DockApps.qml` (881 lines)
- `modules/dock/DockAppButton.qml` (549 lines)
- `modules/dock/DockPreview.qml`
- `modules/dock/DockContextMenu.qml`
- `modules/dock/DockPillItem.qml`, `DockMacItem.qml`, and backgrounds

The dock supports top, bottom, left, and right positions; pinned and running applications; grouped multiple windows; window-count/focus indicators; hover previews; several presentation modes; auto-hide; context menus; pin/unpin; launch-new; and close-all. Clicking cycles the application's windows. Long-press-then-move starts a reorder operation, and the pinned order is persisted. Running applications are stabilized to prevent focus changes from making icons reshuffle.

This is one of iNiR's strongest direct component candidates for §6 Sidebar/dock. It already operates through shared QuickShell toplevels and has explicit Niri/Hyprland branches. It is more complete than a simple four-file dock, but correspondingly more coupled. Visually, the stock dock is conventional and well polished; it does not provide agridyne-style bespoke glass app tiles or the requested sidebar audio-visualizer composition.

### Overview and launcher/search

Key files:

- `modules/overview/Overview.qml`
- `modules/overview/OverviewDashboard.qml`
- `modules/overview/SearchWidget.qml`
- `modules/overview/SearchBar.qml`
- `services/deferred/LauncherSearch.qml`
- `services/AppSearch.qml`
- `services/GlobalActions.qml`

The overview combines a workspace/window overview with a search surface. Search is live and debounced, uses desktop-entry icons, supports keyboard and mouse navigation, and exposes prefixes for applications, actions, clipboard history, emoji, calculations, shell commands, and web search. User scripts placed in the actions directory join the centralized action catalog. The content supports Escape and outside-click closure through the full overlay pattern; Hyprland focus grabbing is available where relevant.

This is a broader command surface than a simple app launcher and contributes to §4.11. It still does not provide indexed file search or a comprehensive settings-result model. Running arbitrary shell commands from a launcher prefix is powerful but should not be treated as a substitute for discoverable mouse-facing settings.

Visual quality is good Material UI, but the official screenshots do not isolate the launcher closely enough to rank its polish above the already-researched Caelestia launcher. iNiR's value here is breadth and shared action plumbing. Its overview also contains Niri scrolling-layout assumptions and live window captures, which are unnecessary if only the launcher is wanted.

### Sidebars and click-away behavior

Key files:

- `modules/sidebarLeft/SidebarLeft.qml` and `SidebarLeftContent.qml`
- `modules/sidebarRight/SidebarRight.qml` and `SidebarRightContent.qml`
- `modules/sidebarRight/CompactSidebarRightContent.qml`

Both ii sidebars are independent full-screen `PanelWindow`s containing an edge-aligned visible panel. A full-window `MouseArea` checks whether a click falls outside the content rectangle and closes the panel. Escape is handled by the surface. Under Hyprland, `CompositorFocusGrab` also closes the sidebar when focus clears. Because the transparent overlay owns the full screen while open, basic outside-click closure remains available even without the Hyprland grab.

Entry styles include slide, reveal, elastic, pop, drop, and swing. The panel is mapped before the state transition begins, preventing the common Wayland problem where the first frame appears at the final position. Closing animates first, then unmaps after 300 ms. Right-sidebar content can remain mounted for fast reopen; a first-valid-height latch avoids constructing it against a zero-height unmapped surface.

The left sidebar is extremely feature-rich: AI chat, YouTube Music integration, wallpaper browsing, anime schedules/content, Reddit, translation, software/package surfaces, web-app plugins, notes, status rings, quick launch, crypto, clocks, and draggable widgets. The right sidebar contains calendar/events, quick toggles, volume mixer, network and Bluetooth device dialogs, notifications, timers, todo, calculator, notepad, weather, screen time, and a compact system monitor.

Quality/portability: the window lifecycle and click-away patterns are excellent references for §2 and §6. The actual left-sidebar product is too broad and dense for the target. The right-sidebar subcomponents are more useful individually than as one monolithic side panel because the target explicitly requires independent dropdown `PanelWindow`s.

### Network

Key files:

- `services/Network.qml`
- `services/network/WifiAccessPoint.qml`
- `modules/sidebarRight/wifiNetworks/WifiDialog.qml`
- `modules/sidebarRight/wifiNetworks/WifiNetworkItem.qml`
- quick-toggle variants under `modules/sidebarRight/quickToggles/`

The service uses `nmcli`, with an `nmcli monitor` subscriber and a 200 ms debounce rather than blind polling. It tracks Wi-Fi enabled state, connection state, active name, signal strength, Ethernet status, scans, connection/disconnection, portal opening, and network lists. The dialog sorts networks and presents signal/security/connection UI.

There are two material defects for the target:

1. It has no link/internet throughput property. The displayed `networkStrength` is only signal percentage. A separate `NetworkStats` inside the system-monitor widget parses `/proc/net/dev` and computes local byte rates, so the repository contains rate logic, but it is not integrated into the network panel and is not an internet-speed measurement.
2. `changePassword()` passes the Wi-Fi secret as the final argument to `nmcli connection modify ... wifi-sec.psk <secret>`. That makes it visible in the process argument list while the command runs. This is the same class of defect already rejected in another candidate and means iNiR's network backend must not be transplanted unchanged.

Quality/portability: useful event/debounce and UI reference, but not the selected backend for §4.7/§6 without replacing its secret-handling path and adding real speed data.

### Bluetooth

Key files:

- `services/BluetoothStatus.qml`
- `modules/sidebarRight/bluetoothDevices/BluetoothDialog.qml`
- `modules/sidebarRight/bluetoothDevices/BluetoothDeviceItem.qml`

This layer uses QuickShell's Bluetooth/BlueZ objects. It tracks adapter availability/enabled state, connected device count, and device-specific icon types. The device row explicitly displays `batteryAvailable` and rounded battery percentage when the underlying device exposes it. This directly covers the Bluetooth-battery portion of §4.7. The dialog supports device discovery and connection management.

Quality/portability: a clean candidate for a compact Bluetooth panel, assuming target Broadcom/T2 behavior is verified later. It depends far less on Niri than the overview or bar.

### Audio, media, and visualizers

Key files:

- `services/Audio.qml`
- `services/MprisController.qml`
- `services/deferred/CavaService.qml`
- `modules/sidebarRight/volumeMixer/*`
- `modules/mediaControls/MediaControls.qml`
- `modules/mediaControls/PlayerControl.qml`
- `modules/mediaControls/presets/*`
- `modules/common/widgets/CavaVisualizer.qml` and `CavaWavyLine.qml`

`Audio.qml` wraps QuickShell PipeWire nodes, default sink/source, per-app streams, devices, mute, mic access state, volume, and device switching. It has fallback `wpctl` paths for hardware/device-route cases and recognizes EasyEffects virtual sinks so UI volume controls can still resolve a physical sink. The volume mixer exposes individual application streams and input/output selectors.

MPRIS support is extensive: player filtering/deduplication, active-player selection, artwork, seeking, volume fallbacks, transport actions, browser/YouTube edge cases, and several media-card layouts. Cava is now a shared demand-driven process; every visible visualizer subscribes to the same point stream. Rendering choices include bars and a smoothed wavy line, used in media cards, lock UI, bar media, and desktop widgets.

The shell has a quick toggle to start EasyEffects in service mode and integrates its virtual sink, but it does not contain an expandable multi-band EQ/preset panel comparable to ilyamiro's reference. Cava sensitivity, bars, stereo, frame rate, gradient, and appearance are configurable; these are visualization controls, not audio equalization. Therefore iNiR supplies good media/visualizer/service pieces but does not satisfy the full §6 Music/EQ component.

### Notifications

Key files:

- `services/Notifications.qml`
- `modules/notificationPopup/NotificationPopup.qml`
- `modules/common/widgets/NotificationItem.qml`
- `modules/common/widgets/NotificationGroup.qml`
- `modules/sidebarRight/notifications/NotificationList.qml`

The QuickShell notification server supports actions, body markup/links/images, persistence, transient handling, per-app grouping, DND/silent mode, unread count, click/action invocation, images, and history. It rate-limits noncritical ingress to 20 notifications per second, debounces group reconstruction, caps long-lived popup display by default, and suppresses popups while the history surface is open or GameMode requests suppression. Critical notifications bypass ingress limiting. Persisted historical notifications correctly lose dead sender actions.

This is a strong candidate for §6 Notifications. It already supplies grouping and history rather than only toast rendering. The missing requirement is semantic routine-event suppression. The only hard-coded application/content filter is for Niri screenshot notifications used by preview capture. There is no general per-application/category ignore model that would suppress a routine home-Wi-Fi-connected event while allowing important network events. DND is broader than the required behavior.

### Clipboard history

Key files:

- `services/deferred/Cliphist.qml`
- `modules/clipboard/ClipboardPanel.qml`
- `modules/clipboard/ClipboardItem.qml`
- `modules/common/widgets/CliphistImage.qml`

The shell provides searchable cliphist history, copy/paste/delete actions, image detection, and actual lazy image decoding into a temporary cache. Image previews are real; a documentation statement implying only metadata is supported is stale relative to the current implementation. Sensitive previews can be blurred under configurable work-safety conditions. Decode subprocesses start only when a preview becomes visible, avoiding a burst for every historical image.

This is a solid mouse-facing Win+V-style basis for §4.3. The UI remains coupled to iNiR controls/tokens but its service boundary is understandable.

### Wallpaper selection and desktop widgets

Key files:

- `modules/wallpaperSelector/WallpaperSelector.qml`
- `modules/wallpaperSelector/WallpaperSelectorContent.qml`
- `modules/wallpaperSelector/WallpaperCoverflowView.qml`
- `services/Wallpapers.qml`
- `services/AwwwBackend.qml`
- `modules/background/Background.qml`
- `modules/background/widgets/AbstractBackgroundWidget.qml`

The wallpaper selector supports grid and full-screen “Cover Flow” modes, monitor targeting, thumbnails, video first-frame handling, random selection, click-away, Escape, and awww transitions. The Cover Flow implementation deliberately has no 3D Y-axis rotation; depth comes from scale, overlap, opacity, and dimming. A small image quantizer produces a locally blended accent for the gallery. This is more polished than a plain file picker but still does not match the required 3D skwd-wall interaction, and §6 already chooses skwd-wall.

The desktop-widget system is a bonus finding. Widgets can be freely dragged/resized or assigned to nine screen zones, locked, switched among layout presets, scaled without bitmap blur, given automatic contrast-aware colors based on their wallpaper region, and configured in place. Expensive color analysis and effects are gated by visibility/power state. Available widgets include clocks, weather, media, Cava, system monitor, battery, notes, and calendar. This is a high-quality mouse-accessibility pattern aligned with §0/§2 even though desktop widgets are not a primary required component.

### System monitor

Key files:

- `services/ResourceUsage.qml`
- `modules/sidebarRight/sysmon/SysMonWidget.qml`
- background system-monitor widget files

The service exposes CPU, RAM, swap, GPU where available, temperature, disk, histories, and demand-driven lifecycle. The right-sidebar monitor shows graphs and network byte rates. It does not provide a process table or a dedicated system/process workspace. It is a competent compact glance panel, not a solution for the full §6 system monitor.

### Capture, recording, system actions, and settings

The repository includes region screenshot, annotation, OCR, reverse-image search, screen recording, recording OSD, session actions, power actions, timers, app catalog/package search, polkit, on-screen keyboard, keybind cheatsheet, and extensive GUI settings. `services/GlobalActions.qml` centralizes these actions so a bar, launcher, IPC command, or custom user script can invoke the same behavior. Screen recording uses a shell pipeline around Wayland capture tools and includes region/fullscreen choices.

These features are a useful completeness inventory for §0 and §4.10. They should not override already-selected components without visual comparison in the synthesis. The repository's package installation surfaces are distribution-oriented and do not solve the declarative/imperative NixOS application-install experience required by §4.2.

### Lock and session screens

iNiR implements a QuickShell `WlSessionLock` screen with media/Cava and a fallback path. It is feature-rich, but the master requirements explicitly require Hyprlock for lockout safety. Only its layout, status placement, and animation language are reference material. Its executable QML lock must not be adopted as the target lock implementation.

### Waffle family

Waffle includes a complete taskbar, Start menu, action center, Wi-Fi/Bluetooth/audio controls, notification center/calendar, task view, clipboard, widgets, and Fluent-like tokens. It is technically impressive and shares the services layer cleanly. It is nevertheless the wrong visual identity and introduces an entirely separate token/component hierarchy, so it is lower-value than ii for this build.

## Theming system

### Role and token architecture

The core chain is:

```text
palette source
  → about 54 Material semantic roles (+ optional 16 terminal colors)
  → Appearance.m3colors mutable role object
  → Appearance.colors / aurora / angel / rounding / font / motion derivatives
  → all ii widgets consume semantic or derived tokens
```

`modules/common/Appearance.qml` is the authority for Material ii. It defines base Material roles such as background/surface/container levels, on-surface text, outline, primary/secondary/tertiary families, error/success, fixed colors, shadow/scrim, and terminal colors. It then derives layer backgrounds, hover/active colors, text levels, borders, shadows, control roles, style-specific transparency, sizes, font families, rounding, and animation classes.

This is a good semantic architecture: widgets usually ask for `colLayer1`, `colOnLayer1`, `colPrimaryContainer`, `colSubtext`, `colOutlineVariant`, and similar intent-based roles rather than embedding hex values. It supports live mutation because `Appearance.m3colors` is a runtime object. The cost is size and inconsistency risk: some modules branch explicitly among Material, Aurora, iNiR, and Angel, and several default sources duplicate values.

`ThemePresets.qml` contains 46 entries including Custom and many established palettes. A preset defines the full semantic role set, optional terminal colors, and metadata such as rounding scale or font style. `StylePresets.qml` separately provides six density/shape presets—Default, Compact, Spacious, Sharp, Soft, Minimal. Visual style, color preset, and density are therefore independent axes.

The stock Angel palette's useful surface values are:

| Role | Value |
|---|---|
| Background/surface | `#08070a` |
| Surface low | `#0c0b0f` |
| Surface container | `#121016` |
| Surface high | `#1a171f` |
| Surface highest | `#221f28` |
| Primary | `#e8b882` warm amber |
| Secondary | `#d4c4aa` warm neutral |
| Tertiary | `#b8c4d8` cool grey-blue |

The surface ladder is close to the desired depth; the accent family is not. Also, built-in presets are softened by default: any color above 5% saturation is multiplied to 60% of its original HSL saturation. That default can recreate the muted/pastel failure described in §3/§9. The target's luminous accents require disabling or retuning that behavior.

There is a small internal inconsistency around Angel typography. Angel preset metadata requests a serif-like style, but `Appearance.qml` forces the Oxanium family whenever the global style is Angel. Config/default/editor fallback values also diverge in several Angel settings. The actual config value wins when present, but the duplicated defaults make source reading and isolated vendoring risky.

### Wallpaper-driven pipeline

The auto-theme path is substantial:

```text
wallpaper or explicit seed
  → scripts/colors/switchwall.sh
  → scripts/colors/generate_colors_material.py
  → colors.json, palette.json, app-palette.json,
    terminal.json, theme-meta.json, material_colors.scss
  → services/MaterialThemeLoader.qml watches colors.json
  → validates JSON, maps snake_case keys to m3 camelCase roles
  → Appearance roles update immediately
  → delayed scripts/colors/applycolor.sh fans the palette to applications
```

The Python generator uses `materialyoucolor`, not the legacy template mechanism still present under `defaults/matugen`. It can automatically choose among tonal, neutral, content, fidelity, rainbow, expressive, and monochrome schemes based on image statistics. It contains contrast/readability logic, terminal harmonization, application-palette generation, and a template renderer.

`switchwall.sh` writes the generated contracts to temporary files and moves successful nonempty results into place. A failed color generation retains the previous `colors.json`. The Material loader debounces file events by 50 ms, validates nonempty JSON with a background role before mutation, retries missed reads, and delays external fan-out by 600 ms. This is careful defensive engineering.

The manual-preset route is weaker. `ThemePresets.qml` comments that it writes all generated files atomically, but the generated shell command performs a sequence of direct `printf > final-path` writes. There are no temporary files or final renames in that path. A process interruption can therefore leave a partial contract set, and application fan-out is not an all-or-nothing transaction. This falls short of §6's “no half-applied states” invariant even though the wallpaper-generator path is individually atomic.

### Application theme fan-out

`scripts/colors/applycolor.sh` reads enabled target manifests and runs modules in parallel at low CPU/I/O priority. Parallelism defaults to half the CPU count but is clamped to 2–4 jobs. This is considerate on normal systems, though a minimum of two concurrent jobs may still be aggressive on the target dual-core i3.

Current target manifests cover:

- Kitty, Alacritty, Foot, WezTerm, Ghostty, Konsole, Starship, oh-my-posh, btop, lazygit, and yazi.
- GTK3, GTK4/libadwaita, KDE globals, Darkly color files, qt5ct, and qt6ct.
- VS Code and several forks, OpenCode, optional Neovim, and Zed.
- Chromium-family browser policy/theme colors.
- Spicetify.
- Discord/Vesktop through a separate System24 generator path.
- Firefox/Pywalfox color output through the GTK/KDE application script.
- SDDM, Steam through Millennium, Pear Desktop/YouTube Music CSS with live CDP injection, and optional Cava gradients.

The breadth is genuinely strong and directly relevant to §3 cohesion and §4.17. It is not universally enabled: Spicetify, Steam, Neovim, and Cava are off in the shipped config, while several other targets default on. README claims and current target manifests are not perfectly synchronized, so the source manifests/scripts are more reliable than the feature list.

The GTK/KDE script is particularly comprehensive: it emits GTK3 semantic named colors, GTK4/libadwaita root variables, KDE colors, and Qt bridge files. It restarts Nautilus at the end, which is disruptive for a general live-theme operation. The Chromium script can update `BrowserThemeColor`, but it also contains mutable-host behavior involving privilege escalation and broadening policy-directory permissions. On NixOS the browser policy should remain declarative rather than adopting that mutable path.

The key mismatch with §3 is conceptual: iNiR's automatic Material generation recolors surface roles as well as accents. The target requires deep dark surfaces to remain pinned while only accents adapt. The reusable artifact is its named-role schema and target fan-out; the generator output contract must be constrained so background/surface/container/outline roles remain fixed and wallpaper analysis only changes primary/secondary/tertiary/accent-derived roles.

## Glass / transparency

### Aurora values and live tuner

`ColorUtils.transparentize(color, p)` preserves the original RGB and multiplies alpha by `1 - p`. Therefore a value of 0.38 means approximately 62% remaining tint alpha, not 38% opacity.

The shipped `defaults/config.json` Aurora transparentize values are:

| Surface class | Transparentize | Resulting alpha for an opaque input |
|---|---:|---:|
| Overlay/panel | 0.38 | 0.62 |
| Sub-surface/card | 0.52 | 0.48 |
| Popup | 0.42 | 0.58 |
| Tooltip | 0.35 | 0.65 |
| Generic layer | 0.40 | 0.60 |

These values land remarkably close to §3's starting target of roughly 0.55–0.65 for the main surface tint. Aurora's `clear` preset is much more transparent; `frosted` and `subtle` are more opaque. The built-in editor presets are:

| Preset | Overlay | Sub-surface | Popup | Tooltip | Layer |
|---|---:|---:|---:|---:|---:|
| Default | .30 | .42 | .32 | .28 | .32 |
| Frosted | .25 | .35 | .30 | .25 | .28 |
| Clear | .60 | .72 | .58 | .45 | .60 |
| Subtle | .18 | .28 | .22 | .18 | .20 |

The shipped config does not match the editor's named Default preset; its `.38/.52/.42/.35/.40` values sit between Default and Clear. That is another reason to treat live config as authoritative.

`modules/settings/AuroraStyleEditor.qml` is a real live tuner. Sliders range from 0 to 1 in .01 steps and persist through `Config.setNestedValue` on movement. It offers quick presets, reset, and a serialized custom preset. Its preview is a set of colored rectangles, not a real wallpaper/blur test, so final tuning still has to be performed on actual panels.

### Angel values and tuner

Angel is a superset of Aurora with configurable blur intensity/saturation, tint, panel/card/popup/tooltip transparency, partial borders, inset top glow, sharp or rounded profiles, accent bars, and offset glass shadows. Shipped main values include:

- Blur intensity .50, saturation .15, overlay transparentize .35.
- Panel .35, card .50, popup .35, tooltip .25 transparentize.
- 1 px surface borders, zero global rounding, no stock glow.
- Main escalonado offset 1×1 and hover offset 7×7.
- Color strength .60.

`AngelStyleEditor.qml` is 1,037 lines and exposes four profiles: Default, Ethereal, Monolith, and Crystalline. Ethereal is the most transparent/rounded/glowing; Monolith is dense, sharp, and disables the glass shadow; Crystalline uses the strongest blur with moderate rounding. It supports the same immediate persistence, custom snapshot, load, and reset approach as Aurora.

Two source defects matter:

- `noiseOpacity` and `vignetteStrength` exist in config, `Appearance`, presets, and editor sliders, but no current QML renderer consumes them. The controls are visually inert in the inspected implementation.
- Several Angel fallback values differ among `Config.qml`, `defaults/config.json`, `Appearance.qml`, and editor presets. Vendoring isolated files without the full config contract can silently change the look.

### How the blur actually works

iNiR does not currently use compositor-native blur for Aurora/Angel. `Appearance.compositorBlurActive` is hard-coded `false` with a comment indicating a future compositor hook. Instead, each glass surface generally:

1. Places a full-screen wallpaper `Image` inside the panel.
2. Offsets it by the panel's screen coordinates so the visible pixels align with the real wallpaper.
3. Applies `MultiEffect` with `blurMax: 64`, normalized blur amount, and optional saturation.
4. Clips the result through an opacity mask matching the panel radius.
5. Draws a semantic tint overlay and optional border/glow on top.

This produces genuine wallpaper-through glass even without compositor blur. It also creates the main performance risk. `GlassBackground.qml` claims in a comment that one shared blur FBO is provided, but its actual code creates a full-screen image and `MultiEffect` layer per instance. Qt can share the decoded cached pixmap, and hidden components release their layer, but it does not share the per-surface blur render target. `EscalonadoShadow.qml` can create another full-screen wallpaper blur layer for the offset shadow behind a single card.

At 2560×1600 logical/physical combinations, multiple full-screen RGBA render targets and blur passes can be expensive on Iris Plus. This mechanism should not be copied unchanged across the requested bar, dock, independent dropdowns, notifications, and widgets. The repository already contains conditional checks to skip these wallpaper layers when `Appearance.compositorBlurActive` is true; making that flag Hyprland-aware would allow native compositor blur to carry the common background work while retaining iNiR's tint/border tokens. That is a small compatibility conversion of the existing design, not a new visual implementation.

The master spec's 12–16 px blur cannot be directly mapped to iNiR's `MultiEffect.blur` value because the latter is normalized against `blurMax`, not expressed as a compositor pixel radius. It requires visual/performance tuning rather than copying `.5` or `1.0` as though those were pixels.

Glass verdict: Aurora's opacity classes and live tuner are excellent matches for §3. The QML per-surface blur renderer is not suitable unchanged for the target hardware. Angel's partial border/inset glow may provide tasteful accents, but the offset-shadow system and dead noise/vignette settings lower its value.

## Animations / motion

### Token system

`Appearance.qml` defines reusable curves and duration classes rather than scattering every transition value:

| Class | Duration | Curve/use |
|---|---:|---|
| Expressive effects / fast | 200 ms | `[0.34, .80, .34, 1, 1, 1]` |
| Element exit | 200 ms | emphasized acceleration |
| Scroll | 200 ms | standard deceleration |
| Resize | 300 ms | emphasized multi-point spline |
| Menu | 350 ms | OutExpo |
| Expressive fast spatial | 350 ms | overshooting `[.42, 1.67, .21, .90, 1, 1]` |
| Element enter | 400 ms | emphasized deceleration |
| Click bounce | 400 ms | expressive spatial |
| Element move | 500 ms | `[.38, 1.21, .22, 1, 1, 1]` |
| Expressive slow spatial | 650 ms | `[.39, 1.29, .35, .98, 1, 1]` |

It also exposes velocity-driven `SmoothedAnimation` classes at 1,400 and 2,600 units and a spring with spring 3.2, damping .28, mass 1, epsilon .25. `calcEffectiveDuration()` and global effect/animation flags allow GameMode or user settings to reduce/disable motion.

The target requires common controls/panels around 160–300 ms. iNiR's fast, exit, scroll, and resize classes fit; its default 400 ms enter and 500 ms move are slower than desired for routine interactions. Its core token table tops out at 650 ms, so it does not by itself provide the requested 700–1200 ms cinematic class.

### Applied panel motion

The sidebars use coordinated state transitions rather than opacity alone. Depending on selected style, they animate translation, opacity, scale, vertical drop, horizontal swing scale, or reveal clipping. Entry translation is normally 400 ms with a decelerating spline; exit is about 200 ms. The surface stays mapped through the exit and is hidden after a 300 ms timer. This is solid everyday motion, although the large full-height panel makes 400 ms feel more defensible than it would on a small toggle.

Media controls combine translation, opacity, and scale, generally using the 400/200/300 ms classes. The overview fades/scales from about .95 to 1 with fast timing. The bar and dock slide from off-edge margins over roughly 400 ms. The wallpaper selector uses scale .93→1 plus fade over 250 ms on open and 180 ms on close. Hover, drag-lift, indicator, color, and progress behaviors are pervasive.

The most cinematic choreography is `FamilyTransitionOverlay.qml`, used only when swapping the entire ii/Waffle family. A full-screen wallpaper blur builds while the wallpaper scales from 1.05 to 1, family-specific content enters in staggered phases, the panel family swaps under a 200 ms hold, then content and background recede. The complete sequence is approximately 1.2 seconds. It snapshots both families' colors before starting so a simultaneous palette change cannot flicker the overlay. This is excellent transition coordination but is not a reusable compact↔expanded widget morph by itself.

There is no source evidence of ilyamiro-level panel-to-panel geometry morphing across ordinary dashboard views. iNiR animates many individual properties and has a sophisticated full-family transition, but most everyday view changes remain fades, slides, scales, and stateful resizing. It is a useful motion-token source, not the primary morph engine for §3.

## Font sizing

The launcher deliberately forces `QT_SCALE_FACTOR=1`, clears inherited DPI variables, and uses `RoundPreferFloor`. Shell scale is controlled entirely by live QML config at `appearance.typography.sizeScale`, default 1.0. This avoids Qt and compositor scaling both applying to layer-surface geometry.

The ii font ladder is 10, 12, 13, 15, 16, 17, 19, 22, and 23 logical pixels multiplied by `sizeScale` and rounded. Spacing, bar height, sidebar widths, notification width, media size, and other major dimensions use the same factor. This keeps text and hit targets proportional and is directly relevant to the 1.5× Retina environment.

Default families are Roboto Flex for UI, Gabarito for titles, Rubik for numbers, JetBrainsMono Nerd Font for monospace, Readex Pro for reading, Space Grotesk for expressive text, and Material Symbols Rounded for icons. Angel forces Oxanium. The target specifies a different UI/code/icon family set, but the family token boundary makes replacement straightforward.

For a compositor already presenting 1.5× logical coordinates, keeping Qt scale at 1 and tuning the QML size factor is the sound part of this approach. Exact `sizeScale` cannot be selected from source alone. One caveat is that a single factor changes both typography and large geometry; it is convenient but less granular than separate type and density scales.

## What's directly usable for our build

### §3 palette cohesion and §4.17 application theming

`modules/common/Appearance.qml`, the generated JSON contracts, and `scripts/colors/targets` demonstrate the right division of responsibility: semantic UI roles feed every widget, while separate application writers consume stable palette files. This is iNiR's highest-value contribution. Adaptation required: retain fixed deep surface roles, allow wallpaper-driven accent roles only, disable/tune default saturation softening, and make the generated-contract transaction safe across both auto and manual themes.

The app writers provide concrete coverage for terminals, Starship, GTK3/4/libadwaita, Qt/KDE bridges, Chromium, VS Code-family editors, Zed, Discord/Vesktop, Firefox/Pywalfox, Spicetify, YouTube Music, and optional ancillary apps. They are stronger evidence for universal cohesion than merely changing shell colors.

### §3 real glass and live tuning

`modules/settings/AuroraStyleEditor.qml` plus `Appearance.aurora` is a direct feature match. It supplies per-surface opacity classes, live persistence, presets, custom snapshot, and immediate feedback. The opacity values are already near the target starting range. Adaptation required: connect the existing compositor-blur bypass to Hyprland and preview actual wallpaper-backed surfaces rather than relying only on colored sample rectangles.

### §3 motion tokens

The motion classes in `Appearance.qml` are a coherent source for hover, scroll, exit, resize, spring, and spatial-follow behavior. Fast/exit/resize tokens map well to routine controls. Adaptation required: shorten routine entry/move timings and obtain the main intra-widget morph choreography from the stronger ilyamiro reference. `FamilyTransitionOverlay.qml` is valuable specifically as an example of color snapshotting and staggered 1.2-second cinematic coordination.

### §2 click-away and progressive disclosure

`SidebarLeft.qml`, `SidebarRight.qml`, `WallpaperSelector.qml`, and overview/media overlays show robust full-surface click-away plus Hyprland focus-grab enhancement, Escape, map-before-animate, and animate-before-unmap. This directly addresses the interaction philosophy and current launcher defect. These patterns are compositor-aware but not Niri-dependent.

### §6 dock and top-bar task behavior

`DockApps.qml`, `DockAppButton.qml`, `BarTaskbar.qml`, and `BarTaskbarButton.qml` provide pinned/running grouping, cycling, hover previews, drag reorder, context actions, close, and detached launch. The vertical dock is a credible alternate code candidate in the later multi-repo comparison. Adaptation required: target visual tokens/icons, requested sidebar composition, and potentially simplification to reduce GPU/widget cost.

`BarModuleOrderEditor.qml` is directly useful product-design reference even if the final bar comes from elsewhere. A mouse user can rearrange modules without touching source, consistent with §0 and §2.

### §4.3 clipboard

`Cliphist.qml`, `ClipboardPanel.qml`, `ClipboardItem.qml`, and `CliphistImage.qml` form a complete searchable text/image history implementation with real image previews. It is a stronger basis than a text-only picker.

### §4.7 Bluetooth battery

`BluetoothDeviceItem.qml` already renders the battery percentage exposed by QuickShell's BlueZ device object. The network half does not meet the requirement.

### §6 audio/media and notifications

`Audio.qml` plus the volume mixer is a strong PipeWire reference for a compact output/input/per-app panel. The shared `CavaService.qml` lifecycle is particularly suitable for limited hardware. The MPRIS cards and Cava renderers can contribute to a music panel, while the missing actual EQ must come from the stronger source.

`Notifications.qml` plus grouping/history widgets is a strong complete notification layer. Adaptation required: target visual tokens and real routine-event filters.

### §6 NixOS/Hyprland runtime

`flake.nix` already packages the shell for NixOS/HM and can attach its service to Hyprland. `CompositorService.qml` and `HyprlandData.qml` prove that most service/UI code can run on Hyprland without emulating Niri. The Nix flake also demonstrates patching source-tree `/usr/bin` assumptions only in the packaged copy and supplying runtime dependencies through the wrapper.

### Bonus: demand-driven services and desktop widget editing

`ResourceUsage.qml`, `CavaService.qml`, tiered `shell.qml` loading, and source-based family lazy loaders are excellent performance/lifecycle patterns for a full OS shell. `AbstractBackgroundWidget.qml` and the desktop editor are an unusually good mouse-accessible customization system. They serve §0/§2 even though they are not explicit primary components.

## What's NOT useful and why

- **Whole-shell adoption:** the repository is Niri-first, enormous, and upstream warns against low-spec hardware. Adopting it wholesale would conflict with the selected independent-panel architecture and import hundreds of unrelated services/features.
- **Stock Angel color preset:** warm amber/gold is the wrong accent direction. Only its deep surface ladder and some border ideas are relevant.
- **Angel escalonado glass shadows unchanged:** they can add an additional full-screen blur FBO per surface and establish a sharp offset-shadow identity not requested by §3.
- **Per-surface QML wallpaper blur unchanged:** visually valid, but too risky for Iris Plus/8 GB when repeated across many independent surfaces. The existing native-blur bypass should be activated instead.
- **Waffle family:** polished but deliberately Windows-derived and governed by a second token system. It adds complexity without advancing the aurora identity.
- **QML lock implementation:** incompatible with the explicit Hyprlock safety decision.
- **Built-in wallpaper selector as final component:** its Cover Flow explicitly avoids 3D rotation, while skwd-wall is already the required higher-quality source.
- **Compact system monitor as final monitor:** no process list or dedicated process workspace.
- **Network backend unchanged:** no Mbps and exposes a Wi-Fi secret through a process argument during password change.
- **Built-in EasyEffects surface as the required EQ:** it is only a service-mode toggle/integration, not the required expandable preset/band UI.
- **Full left sidebar:** visually and functionally overpacked relative to the desired restrained second surface.
- **Automatic Material surface recoloring unchanged:** violates the pinned-dark-surface/accent-only adaptation rule.
- **Default softening:** multiplying saturation to 60% is directly opposed to the desired luminous accent behavior.
- **Mutable Chromium policy path:** broad host permission changes and runtime privilege prompts do not fit declarative NixOS policy management.

## Compatibility notes

### Niri → Hyprland 0.55 delta

The delta is smaller than the README's “old Hyprland code” wording suggests for many components:

- `CompositorService.qml` detects Hyprland first from `HYPRLAND_INSTANCE_SIGNATURE`, Niri from `NIRI_SOCKET`, and exposes shared toplevel sorting/current-workspace filtering and DPMS actions.
- `HyprlandData.qml` supplements QuickShell's Hyprland objects with JSON snapshots from `hyprctl clients`, monitors, layers, workspaces, and active workspace. It refreshes on Hyprland raw events.
- Bar workspaces, dock/taskbar, active-window display, wallpaper selector monitor selection, sidebar focus grab, and many session actions already contain explicit Hyprland branches.
- QuickShell `PanelWindow`, MPRIS, PipeWire, Bluetooth, tray, notifications, and file/config facilities are compositor-agnostic.
- `CompositorFocusGrab` activates the Hyprland path for modal panels; transparent backdrop click areas provide an all-compositor fallback.

The genuinely Niri-specific areas are the scrolling-column workspace model, Niri overview/window-coordinate logic, Niri IPC/event socket, Niri keybind/config parsing/editor, minimized-window emulation, some browser-navigation fallbacks, and Niri default configuration. These should be excluded or routed through existing Hyprland branches rather than converted wholesale.

Hyprland 0.55 native Lua configuration is outside iNiR's main integration model. The repository's Niri KDL editor/scripts are not useful for the active Lua config. Shell actions should call the existing Hyprland dispatch abstraction or small Lua-compatible integration points; the visual/service QML generally does not need Lua awareness.

The most important missing Hyprland hook is blur. `Appearance.compositorBlurActive` is permanently false even though bar, vertical bar, dock, and widget surfaces already check it. Making this existing switch reflect native blur availability is the clearest hardware-oriented compatibility conversion.

### NixOS

The flake packages both x86_64 and aarch64, patches hard-coded `/usr/bin/` prefixes in the packaged runtime, wraps a runtime `PATH`, and exposes NixOS/Home Manager options. This is valuable scaffolding, but the shell still contains distribution setup/update/app-catalog logic and mutable app-theme scripts that should not become configuration authorities on the target.

For selected-file adaptation, the target's existing Nix tree remains the authority. iNiR's flake demonstrates required dependencies and service environment, but vendored components need only the coherent service/token slices they actually import. The target is x86_64; iNiR's broad architecture support does not imply T2-specific integration.

### Iris Plus, dual-core i3, and 8 GB RAM

Risk ranking:

1. Per-instance full-screen blur layers and Angel glass shadows are the largest GPU/memory concern.
2. Live screencopy previews in overview, dock previews, and task view can add GPU/bandwidth pressure.
3. 60 fps Cava is avoidable; the shared process and configurable frame rate make it tunable.
4. WebEngine-backed left-sidebar plugins, animated/video wallpaper, background blur, and numerous mounted sidebar widgets are optional and should not be in the selected slice.
5. App-theme fan-out runs at low priority but at least two jobs concurrently; that minimum is worth lowering on a dual-core machine.

Useful upstream mitigations already exist: GameMode can disable effects/animations or hide panels, visualizers are demand-driven, resource polling auto-stops, inactive family QML is not parsed, images load asynchronously, clipboard images decode lazily, and video/animated blur is off by default in several contexts.

No performance claim in this report is a target-hardware measurement. Source shows both significant risks and sensible mitigations; later execution gates must measure the chosen subset.

### 1.5× Retina scaling

The `QT_SCALE_FACTOR=1` plus live QML size factor approach is compatible with a compositor already supplying logical coordinates at 1.5×. Fonts, spacing, hit targets, and panel widths scale together. The exact factor needs visual testing, and the target font/icon substitutions must preserve current rendering quality (§11).

### Source inconsistencies to account for

- README feature claims, current target manifests, and retained legacy templates are not always synchronized.
- The manual-preset writer claims atomic behavior that it does not implement.
- `GlassBackground.qml` claims a shared blur FBO that the code does not contain.
- Angel noise/vignette controls are currently unused.
- Angel and Aurora defaults differ between schema fallbacks, shipped config, and editor preset names.
- Some documentation describes clipboard images more narrowly than current source.

These are not reasons to reject the repository; they are reasons to vendor coherent slices and trust executable source over comments/feature lists.

## Key files to vendor/adapt

Ranked by value to this build, not by repository prominence:

1. **`modules/common/Appearance.qml`** — semantic/derived ii tokens, type scale, surface hierarchy, motion classes, Aurora/Angel roles. Adaptation: extract a coherent token slice; pin surface roles; replace fonts/icons; shorten common motion; connect compositor blur.
2. **`scripts/colors/generate_colors_material.py`, `switchwall.sh`, and generated JSON contracts** — mature wallpaper/seed pipeline, contrast logic, terminal/app contracts, successful temp-and-rename path. Adaptation: accent-only output, transactional manual preset parity, target generator choice, reduced concurrency.
3. **`scripts/colors/targets/`, `modules/`, and app-theme writers** — broad §4.17 cohesion coverage. Adaptation: select target apps, use declarative browser policy, avoid disruptive app restarts/host permission mutation.
4. **`modules/settings/AuroraStyleEditor.qml`** — live per-surface glass tuner. Adaptation: target config keys/tokens and a real wallpaper-backed preview.
5. **`services/MaterialThemeLoader.qml` and `ThemeService.qml`** — validated live reload, debounce/retry, manual/auto coordinator. Adaptation: one authoritative transaction and no duplicated surface recoloring.
6. **`modules/dock/DockApps.qml`, `DockAppButton.qml`, `Dock.qml`, and support files** — mature pinned/running dock with reorder, previews, context actions, close, and both compositors. Adaptation: target geometry/visuals and prune expensive modes.
7. **`modules/common/widgets/BarModuleOrderEditor.qml` plus bar layout model in `BarContent.qml`** — excellent mouse-facing bar customization and responsive zone layout. Adaptation: allow the requested task/title composition and target module catalog.
8. **`modules/common/functions/ShellExec.qml` and `services/AppSearch.qml` launch path** — detached systemd-scope application launching, directly addressing §5. Adaptation: Nix-resolved command paths rather than source-tree absolute paths.
9. **`services/Notifications.qml` and notification group/list widgets** — actions, persistence, grouping, history, DND, images, ingress limiting. Adaptation: semantic ignore rules and target glass cards.
10. **`services/Audio.qml`, volume-mixer files, and `services/deferred/CavaService.qml`** — PipeWire device/app control and one shared visualizer process. Adaptation: target compact panel and combine with the selected external EQ UI.
11. **`services/BluetoothStatus.qml`, `BluetoothDialog.qml`, and `BluetoothDeviceItem.qml`** — small, compositor-independent Bluetooth slice with device battery.
12. **`services/deferred/Cliphist.qml`, `ClipboardPanel.qml`, `ClipboardItem.qml`, and `CliphistImage.qml`** — complete text/image clipboard history.
13. **`modules/sidebarLeft/SidebarLeft.qml` and `modules/sidebarRight/SidebarRight.qml`** — map/animate/unmap and click-away/focus-grab patterns. Adapt the lifecycle pattern to independent target panels, not the monolithic contents.
14. **`FamilyTransitionOverlay.qml`** — snapshot colors, build blur/scale, stagger identity content, swap under hold, then exit. Use as cinematic choreography reference; it is not the everyday morph engine.
15. **`modules/common/Appearance.qml` font/size section and runtime scale setup in `scripts/inir`/`flake.nix`** — logical-pixel scaling reference for Retina. Adapt family names and separate density if necessary.
16. **`services/CompositorService.qml` and `HyprlandData.qml`** — explicit proof and helpers for the Hyprland compatibility boundary. Adapt path resolution and avoid refreshing all `hyprctl` snapshots on every raw event if only a subset is needed.
17. **`modules/background/widgets/AbstractBackgroundWidget.qml`** — bonus mouse-driven placement/resizing, auto contrast, and effect gating. Valuable if desktop widgets enter scope later.

Files intentionally below the cut: `AngelStyleEditor.qml` is informative but much of its unique surface identity is unsuitable and two controls are inert; Niri configuration editors/services are compositor-specific; Waffle is a separate design system; the lock is not the selected technology; the built-in wallpaper selector is below skwd-wall for the stated requirement.

## Bottom-line assessment

iNiR should be treated as a design-system, theme-pipeline, lifecycle, and selected-component source—not as a shell to install wholesale. Its strongest verified contributions are:

- a genuinely universal semantic-role and app-theme fan-out architecture;
- live per-surface Aurora opacity controls with values already near the target glass range;
- mature detached app launch, click-away, panel lifecycle, notification, dock, audio, Bluetooth, and clipboard implementations;
- coherent reusable motion and density tokens;
- unusually thoughtful lazy/demand-driven service patterns for a huge shell.

Its main conflicts are equally clear:

- automatic surface recoloring rather than pinned dark surfaces;
- expensive repeated QML blur targets;
- stock Angel's wrong accent identity;
- routine motion classes slower than §3;
- no ilyamiro-class everyday geometry morph system;
- missing network Mbps, display panel, source-app media icon, workspace drag targets, per-window controls, true EQ UI, and dedicated process workspace;
- an unsafe Wi-Fi password-update argument path;
- several comments/default sources that do not match executable behavior.

The repository is high-value precisely because these boundaries are identifiable. Its core patterns can be adapted with comparatively small compatibility conversions, while the target's component gaps continue to come from the stronger references already named in the master requirements.
