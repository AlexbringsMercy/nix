# Cross-repository synthesis against `MASTER_REQUIREMENTS.md`

This document maps the requirements to the strongest implementation evidence in the five completed research reports: ilyamiro, Agridyne, Caelestia, iNiR, and cxOrz. Paths are relative to the named upstream repository unless a repository prefix (`main/`, `shell/`, or `cli/`) is shown. For ilyamiro, bare QML/widget paths such as `Main.qml`, `network/...`, `music/...`, or `clipboard/...` expand to `config/sessions/hyprland/scripts/quickshell/`; its bare `scripts/screenshot.sh` expands to `config/sessions/hyprland/scripts/screenshot.sh`. Agridyne `My Rice/...` paths are inside the repository's `My Rice.zip`; Kurve paths belong to the linked `luisbocanegra/kurve` companion source. “Adopt” means vendor/adapt the cited community implementation, not reproduce its appearance from scratch.

## Governing constraints and product architecture (§0–§2)

The five reports satisfy the research-side constraints: each is a full-repository pass with preview review, weaknesses are retained rather than hidden, and each component below is compared across candidates. The implementation constraints remain binding: community code is the starting point, every common action has a mouse path, hotkeys are redundant conveniences, popup dismissal works by click-away and Escape, and no temporary component is selected for later replacement.

### Independent surfaces, coordination, click-away, and progressive disclosure

**Requirement.** One coherent shell made of independent QuickShell `PanelWindow` surfaces; compact controls disclose detail without burying it; opening one interactive surface coordinates with the others; every popup closes on outside click and Escape.

| Candidate | Specific source | What it does | Research quality assessment |
|---|---|---|---|
| ilyamiro | `config/sessions/hyprland/scripts/quickshell/Main.qml`, `Floating.qml`, `qs_manager.sh` | `Main.qml` uses a screen-sized overlay, XOR input mask, background `MouseArea`, and one global `StackView`; `Floating.qml` is a genuinely independent edge surface. | Excellent coordination and morph reference, but the single global hub directly conflicts with the required independent-panel architecture. |
| Agridyne | KDE Control Station `FullRepresentation.qml`; Panel Colorizer `My Rice/Panel Colorizer/Main Setup/settings.json` | Large toggle tiles and direct sliders are mouse-first; spacer-delimited islands make related controls legible. | Strong information hierarchy and grouping, but Plasma-specific and not a QuickShell coordinator. |
| Caelestia | `shell/modules/drawers/ContentWindow.qml`, `Interactions.qml`, `ScreenState.qml`, `shell/services/ShellState.qml` | `HyprlandFocusGrab.active` follows interactive open state; `onCleared` closes launcher/session/sidebar/dashboard/popout/tray menus. Edge hover/swipe thresholds are about 50 px for launcher/dashboard and 80 px for sidebar. | Best focus-loss/click-away implementation. The enclosing full-screen SDF drawer is too coupled to adopt wholesale. |
| iNiR | `modules/sidebarLeft/SidebarLeft.qml`, `modules/sidebarRight/SidebarRight.qml`, `modules/wallpaperSelector/WallpaperSelector.qml` | Independent full-screen `PanelWindow`s close through an outside `MouseArea`, Escape, and `CompositorFocusGrab`; map-before-entry and animate-before-unmap avoid Wayland first/last-frame pops. | Best independent-surface lifecycle reference; the full-screen transparent overlays are broader than necessary. |
| cxOrz | `.config/quickshell/shell.qml`, `modules/controlcenter/ControlCenter.qml`, `modules/notifications/NotificationCenter.qml`, `modules/launcher/Launcher.qml`, `modules/powermenu/PowerMenu.qml` | Simple independent surfaces, explicit mutual exclusion, background click areas, Escape, 200 ms exit before unload. `FeatureTile.qml` splits a 64 px tile into 72% toggle and 28% drill-in zones. | Cleanest compact coordinator and strongest split-action tile; screen-sized exclusive input surfaces and embedded service/UI code need refinement. |

**Recommendation — combine, explicitly.** Use cxOrz's independent-surface/exclusivity model, Caelestia's `HyprlandFocusGrab` ownership and `onCleared` semantics, and iNiR's map/animate/unmap lifecycle. Retain cxOrz `FeatureTile.qml` for controls that need both a direct toggle and a detail page. Do not import ilyamiro's global hub or Caelestia's SDF blob window.

**Adaptation delta.** Each target panel gets its own bounded `PanelWindow`, stable namespace, open/closing state, 230–280 ms entry, and delayed unmap after its exit. A small coordinator owns only mutual exclusion and the list of windows passed to `HyprlandFocusGrab`; it does not own panel content. Outside clicks clear the same open-state set as Escape. Panel contents use the selected shared tokens, not their original Material/rose/green palettes. This converts iNiR/cxOrz's full-screen backdrop dismissal to compositor focus clearing where possible, avoiding an invisible screen-sized pointer interceptor.

## Core shell surfaces and components (§5–§7)

### Top bar (§5 Bar defects, §6 Top bar)

**Requirement.** One properly sized top bar: Apps and pinned Chrome/Kitty/file manager; clickable/drop-target workspaces; running tasks; title and window controls; usable media; correct CPU/RAM views; compact device/status controls; tray, notification bell, and a System group. All app launches survive bar reload.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `config/sessions/hyprland/scripts/quickshell/TopBar.qml`, `watchers/*`, `qs_manager.sh` | 48 logical px bar, 8 px top margin, 34 px pills, 4–8 px spacing; detached dispatch; tray menus; media/workspaces/status; 200/350 ms stretchy workspace highlight. | Best spacing and bar motion. Missing pinned launchers, tasks, title, controls, CPU/RAM, source-app icon, and workspace drops; media glyph buttons are only 24–28 px. |
| Agridyne | `My Rice/Panel Colorizer/Main Setup/settings.json`, `Main Blur/settings.json`, Panel Colorizer `CustomBackground.qml` | Spacer-delimited rounded islands; normal vs maximized/fullscreen visual states; 5 px radii and 5/2 margins; optional 250 ms `OutCubic` property animation. | Excellent composition/state pattern, but Plasma-specific and literal fills are too opaque. |
| Caelestia | `shell/modules/bar/Bar.qml`, `components/workspaces/*`, `components/ActiveWindow.qml`, `components/Tray*.qml`, `popouts/TrayMenu.qml`, `modules/windowinfo/*` | Clickable workspaces, active-window details/actions, tray with nested/right-click menus, status popouts. | Strong tray/context behavior. Current bar is a 40 px inner-width left rail, not the requested top bar; no current media source-launch path or workspace drops. |
| iNiR | `modules/bar/Bar.qml`, `BarContent.qml`, `BarTaskbar.qml`, `BarTaskbarButton.qml`, `Workspaces.qml`, `Media.qml`, `ActiveWindow.qml`, `modules/common/widgets/BarModuleOrderEditor.qml` | Five-zone responsive bar; connected or grouped backgrounds; pinned/running grouped tasks, preview/cycle/close/context actions; drag-reorderable modules; launches through `ShellExec` using `systemd-run --user --scope --collect`. | Strongest functional top-bar base and mouse customization. Stock taskbar replaces the title rather than coexisting; no per-window buttons, workspace window-drop, Mbps, or source-app launch. |
| cxOrz | `.config/waybar/config.jsonc`, `.config/waybar/style.css`, dead `.config/quickshell/modules/shelf/*` | Active 48 px shelf demonstrates comfortable grouped hit targets and title/status composition. | Useful geometry evidence only. Bottom-aligned, no tasks/pinned row/media/CPU/RAM/System group; QuickShell shelf is unwired. |

**Recommendation — combine.** Use iNiR's bar zone/layout model, `BarTaskbar*`, application grouping, previews, context actions, and `ShellExec`; ilyamiro's 48/34 px geometry, detached dispatch, tray spacing, and asymmetric workspace indicator; Caelestia's `Tray*.qml`/`TrayMenu.qml` for nested menus and focus ownership; Agridyne's spacer-delimited visual islands. iNiR outranks the unevaluated DankMaterialShell bar path because it is the only fully researched candidate with the required task behavior.

**Adaptation delta.** Keep task list and active title as separate simultaneously enabled modules; add dedicated min/max/close module slots without claiming these satisfy per-window controls. Make every media control at least 34 logical px. Add pinned Chrome/Kitty/file-manager entries on the left. Bind CPU and RAM to distinct target panel IDs. Feed network rate from Caelestia `NetworkUsage.qml`. Resolve MPRIS identity to a desktop entry before rendering the source-app icon; no reviewed repo contains this final link. Turn workspace delegates into `DropArea`s that dispatch the dragged window to the target workspace. Replace source fonts/icons centrally with Inter-like UI text, FiraCode Nerd Font for code/terminal, and Papirus. Preserve `systemd-run --user --scope --collect` or equivalent detached desktop-entry execution for every launch.

### Launcher (§5 Launcher defects, §6 Launcher)

**Requirement.** Community-sourced glass launcher with icons, search-as-type, mouse and keyboard navigation, click-away/Escape, Apps-button and Cmd+Space entry, and detached launches.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `quickshell/applauncher/appLauncher.qml`, `app_fetcher.py`, `Main.qml` | Desktop-entry scan, live filtering, keyboard navigation, 500 ms animated list and stretchy selection. | Respectable, but app-only and click-away depends on the rejected hub. |
| Agridyne | Zen pinned-site tiles shown in the showcase | Rounded Kagi/YouTube tiles supply a useful app-tile visual motif. | Not launcher code and not desktop app tiles; visual reference only. |
| Caelestia | `shell/modules/launcher/`, `plugin/src/Caelestia/appdb.*`, `qalculator.*`, `modules/launcher/services/Actions.qml`, `drawers/ContentWindow.qml` | Real icons, fuzzy field-prefix search, up to seven 600×57 rows, favorites, frequency ranking, calculator/actions, detached `DesktopEntry.execute()`, Escape, and verified click-away. | Best launcher in polish and behavior. Dependency slice is large and shared-drawer wrapper must be replaced. |
| iNiR | `modules/overview/SearchWidget.qml`, `SearchBar.qml`, `services/deferred/LauncherSearch.qml`, `services/AppSearch.qml`, `services/GlobalActions.qml` | Apps, actions, clipboard, emoji, calculations, shell commands, and web prefixes with mouse/keyboard use. | Broadest command surface, but no indexed files/full settings and the overview brings Niri-oriented window captures. |
| cxOrz | `.config/quickshell/modules/launcher/Launcher.qml`, `AppIcon.qml` | App grid, live search, five recents, keyboard grid, click-away/Escape, detached desktop-entry execution, 200 ms slide/fade. | Functional and lightweight, but alphabetic/unranked and its `resolve-icons.sh` repeatedly scans traditional icon roots, which is poor on NixOS. |

**Recommendation — combine.** Caelestia is the launcher source. Add iNiR's centralized action catalog/prefix model only where it remains mouse-discoverable; do not import the Niri overview. Agridyne tiles can inform favorite/pinned styling, not implementation.

**Adaptation delta.** Carry the coherent Caelestia launcher dependency slice rather than isolated QML; replace `Wrapper.qml` with the independent glass window; centralize colors/fonts/icons; set visible rows and logical dimensions for the 1707×1067 logical Retina surface; bind both Apps and Cmd+Space to its IPC action; retain `HyprlandFocusGrab`; remove wallpaper-picker mode because skwd-wall owns that function; expose app/actions/calculator modes but route file results to the future search provider. Keep `DesktopEntry.execute()` and delete cxOrz's filesystem icon scanner.

The surface-dots Rofi theme remains a visual fallback artifact only. The accepted Rofi 2.0 Wayland behavior cannot provide the mandatory click-away dismissal, so it cannot be the final functional fallback without changing the requirement.

### Sidebar / vertical dock (§6 Sidebar/dock)

**Requirement.** A second, left-vertical surface with pinned and running apps grouped, mouse task actions, glass icon treatment, and a tastefully scaled audio visualizer.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `quickshell/Floating.qml`, `quickactions/SystemUsage.qml`, `Timer.qml` | Independent movable edge utility surface with pin/expand/relocate and good hide–teleport–show motion. | Useful edge mechanics, but not an app dock. |
| Agridyne/Kurve | Kurve `package/contents/ui/components/Visualizer.qml`, `package/contents/ui/code/drawCanvas.js`, `package/contents/ui/Cava.qml`; screenshots `kurve-settings-1.png`, `kurve-settings-2.png` | Existing Cava-driven left-edge block visualizer. Exact showcase: Left orientation, Blocks, rounded, bar width 4/gap 5, block height 5/gap 4, transparent background. | Best direct visualizer artifact and exact sizing source. The apparent sidebar and YouTube tile are not a dock/launcher implementation. |
| Caelestia | `shell/modules/bar/` left taskbar; `modules/sidebar/Wrapper.qml`, `Content.qml`, `NotifDock.qml`; `modules/utilities/*` | Left rail has workspaces/active window/tray/status; right composite organizes notifications/utilities. | Excellent organization language, but no pinned/running application dock in the researched snapshot. |
| iNiR | `modules/dock/Dock.qml`, `DockApps.qml`, `DockAppButton.qml`, `DockPreview.qml`, `DockContextMenu.qml` | Top/bottom/left/right dock; pinned/running grouped apps, stable ordering, hover previews, window count/focus, auto-hide, reorder, pin/unpin, launch-new, close-all, Hyprland branches. | Strongest sourced dock and more complete than the unevaluated four-file DMS lead. Coupled to iNiR services/tokens and visually conventional. |
| cxOrz | `.config/quickshell/modules/shelf/*` | Unwired bottom shelf with status/tray only. | Not a dock candidate. |

**Recommendation — combine.** Use iNiR's dock implementation as the functional base and Kurve's existing Canvas/Cava implementation as the edge visualizer. Use ilyamiro's independent edge-window/input-mask mechanics only if the dock wrapper needs them. Agridyne contributes the icon-tile restraint and visualizer scale, not missing code.

**Adaptation delta.** Fix the dock to left vertical; prune Mac/pill variants, live window capture if too costly, and unrelated Niri paths; map application lookup and launch to the target services; centralize Papirus icons and glass tokens; add the Kurve Canvas as a separate, noninteractive strip sharing one Cava process; stop/reduce Cava when silent, covered, or on the chosen battery policy. Pinned/running groups remain distinct. Glass tiles use the shared 0.60 outer tint and lower-alpha hover layer, not custom opaque gray. The DankMaterialShell dock remains a decision candidate only after its own code receives equivalent research; the current evidence supports iNiR.

### Network dropdown and truthful speed (§4.7, §6 Dropdown panels)

**Requirement.** SSID, IP, signal, actual useful Mbps, available networks, safe password entry, and click-away; not a percentage-only panel.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `network/NetworkPopup.qml`, `wifi_panel_logic.sh`, `eth_panel_logic.sh` | Polished Wi-Fi/Ethernet/Bluetooth modes; SSID, signal, security, IP, frequency; radial device visuals. | Excellent UI, but polls shell backends, has no Wi-Fi throughput, reports only negotiated Ethernet rate, and exposes Wi-Fi passwords via argv/quoted shell. |
| Agridyne/KDE Control Station | `FullRepresentation.qml` and TrafficMonitor files | 40-sample upload/download history and real bytes-per-second formatting in a compact quick-settings hierarchy. | Strong information-design comparator; service layer is Plasma-specific. |
| Caelestia | `shell/services/Nmcli.qml`, `NetworkUsage.qml`, `utils/NetworkConnection.qml`, `modules/bar/popouts/Network.qml`, `modules/nexus/pages/Network*`, `dashboard/performance/NetworkCard.qml` | Comprehensive profiles/details and actual `/proc/net/dev` RX/TX deltas with 30 samples, current rates/totals. | Best combined feature set. Current connection path exposes passwords in argv; `NetworkUsage` sums all non-loopback interfaces and is local traffic, not an external speed test. |
| iNiR | `services/Network.qml`, `network/WifiAccessPoint.qml`, `modules/sidebarRight/wifiNetworks/*`; sysmon `NetworkStats` | Event/debounced nmcli model, scan/list/connect UI; separate `/proc/net/dev` rate logic. | Good event model, but no integrated Mbps/IP details and password change exposes the secret in argv. |
| cxOrz | `.config/quickshell/modules/controlcenter/WifiSection.qml`, `FeatureTile.qml` | Good scan/list/dedupe/sort/connect/disconnect/forget/password flow and split toggle/detail interaction. Research identifies QuickShell 0.3 `Quickshell.Networking`/`WifiNetwork.connectWithPsk()`. | Best compact UI flow, but current CLI implementation lacks IP/Mbps and leaks password in argv. |

**Recommendation — combine.** Use cxOrz's user flow and `FeatureTile`, backed by QuickShell 0.3's NetworkManager service rather than any reviewed `nmcli ... password ...` path. Add Caelestia `NetworkUsage.qml` rate/history logic and Caelestia Nexus address/profile fields. Use KDE Control Station only to calibrate the visible hierarchy.

**Adaptation delta.** Bind rates to the default-route interface instead of summing loopback-excluded devices; show separate upload/download Mbps using `8 × byte_delta / elapsed_seconds / 1,000,000`; label this “live traffic,” not an internet speed test. Show SSID, signal, IPv4/IPv6, gateway/DNS, interface, connectivity/captive-portal state, and available/saved networks. Call `WifiNetwork.connectWithPsk(psk)` (or a stdin/secret-agent path if that exact API is unavailable), then clear the QML password on success, failure, cancellation, and close. Never retain the reviewed anti-pattern:

```qml
// Rejected in ilyamiro, Caelestia, iNiR, and cxOrz:
connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
```

### Bluetooth dropdown (§4.7, §6 Dropdown panels)

**Requirement.** Power, scan, paired/nearby devices, reliable connect/pair/forget, battery, and profiles.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `network/NetworkPopup.qml`, `bluetooth_panel_logic.sh` | Stable five-slot radial device model, battery/profile cards, 1,000–1,400 ms core dispersion, scan rings, 700 ms hold-to-disconnect. | Best distinctive Bluetooth presentation; backend JSON/shell handling is unsafe and expensive. |
| Caelestia | `modules/bar/popouts/Bluetooth.qml`, `modules/nexus/pages/Bluetooth*`, QuickShell Bluetooth service use | Native BlueZ-facing devices and clean compact/control-center layouts. | Strong service/UI separation, but battery is not prominent enough to count as verified final coverage. |
| iNiR | `services/BluetoothStatus.qml`, `modules/sidebarRight/bluetoothDevices/BluetoothDialog.qml`, `BluetoothDeviceItem.qml` | QuickShell/BlueZ objects; scan/connect management; explicitly renders `batteryAvailable` and rounded battery percentage. | Best straightforward backend/UI basis and direct battery evidence. |
| cxOrz | `.config/quickshell/modules/controlcenter/BluetoothSection.qml` | Paired/nearby cards and pair→trust→connect flow. | Good flow but a reused `Process` races multi-device status; no battery/forget/passkey/profile. |

**Recommendation — combine.** Use iNiR's QuickShell BlueZ service and device rows for correctness/battery, with ilyamiro's stable-slot radial presentation for the expanded device view. Caelestia provides the compact-row/control-center fallback. Do not use either CLI poller.

**Adaptation delta.** Replace ilyamiro shell models with `BluetoothDevice` objects; robustly render device-controlled names; provide forget/unpair and interactive confirmation/passkey states; retain stable `visualIndex` so refreshes never move devices; visibility-gate the 45 ms connector Canvas or reduce it to event-only animation. Keep the radial 1,000–1,400 ms “cell division” only for the expanded view; common open/close remains 230–280 ms.

### Audio dropdown and OSD (§5 Bar defects, §6 Dropdown panels)

**Requirement.** Compact click panel, output/input selection, mic, per-app streams, volume/mute, EQ access, plus a nonblocking OSD.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `volume/VolumePopup.qml`, `get_audio_state.py`, `audio_control.sh` | Output/input/per-application tabs, large liquid master orb, node cards, default/mute/sliders. | Best visual panel; 700–800 ms entrance is slow for a compact dropdown and backend repeatedly calls `pactl`/`wpctl`. |
| Caelestia | `shell/services/Audio.qml`, native audio collector/provider, `modules/bar/popouts/Audio.qml`, Nexus Audio pages, right-edge OSD | QuickShell PipeWire service, devices, compact popouts, native visualization state. | Strong service architecture and compact layouts; full Caelestia dependency graph is large. |
| iNiR | `services/Audio.qml`, `modules/sidebarRight/volumeMixer/*`, `services/deferred/CavaService.qml` | Default sink/source, per-app streams, devices/routes, mute/mic state, EasyEffects virtual sink recognition; one shared demand-driven Cava process. | Best complete audio backend and best hardware lifecycle. |
| cxOrz | `.config/quickshell/modules/controlcenter/VolumeSection.qml`, `.config/quickshell/modules/osd/VolumeOsd.qml` | Native `Pipewire.defaultAudioSink`/`PwObjectTracker`, clear 44 px pill slider, 600 ms startup suppression, 220 ms OSD entry and 2 s dismissal. | Cleanest compact slice. Output-only; OSD's full-width layer can intercept input. |

**Recommendation — combine.** Use iNiR's PipeWire service/mixer and shared Cava lifecycle; cxOrz's compact pill and OSD behavior; ilyamiro's liquid-orb/node-card presentation only in the expanded panel; Caelestia's device row hierarchy as a cross-check.

**Adaptation delta.** Make the summary dropdown immediately expose output volume/mute, mic state, and current devices; morph to sink/source/app lists inside the same panel using the 210–300 ms shared morph. Give EQ a first-level action opening the Music/EQ surface. Unify maximum volume policy (100% default, explicit opt-in amplification rather than cxOrz's conflicting 100/130%). Replace cxOrz's full-width OSD with a tightly bounded/no-input surface. Drive all views from one service—no duplicate `pactl` polling.

### System / power panel and System button (§5 Bar defects, §6 Dropdown panels)

**Requirement.** Battery detail, brightness, volume, profiles, lock/sleep/reboot/shutdown, plus a distinct System group for capture, recording, wallpaper, and settings.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `battery/BatteryPopup.qml` | Animated battery ring, uptime, brightness/volume sliders, profiles and power actions with staged 800–1,400 ms presentation. | Strongest visual composition, but combines notifications with power and is too slow for routine opening. |
| Caelestia | `modules/utilities/cards/{IdleInhibit,Record,Toggles}.qml`, `modules/session/*`, battery popouts, Nexus | Keep-awake, recording, toggles, session actions, battery/profile settings; good System grouping. | Best product organization. Current surfaces live in shared drawers. |
| iNiR | right-sidebar quick controls, battery/resource services, `services/GlobalActions.qml` | Rich system controls and centralized actions callable from bar/launcher/IPC. | Broad and mouse-accessible, but monolithic sidebar is too dense. |
| cxOrz | `.config/quickshell/modules/powermenu/PowerMenu.qml`, `PowerButton.qml`, `BrightnessSection.qml` | Large keyboard/mouse power tiles; `Process.startDetached()`; simple brightness slider. | Good detached action slice; lacks battery/profile/system details and exit animation. |

**Recommendation — combine.** Use ilyamiro's battery/profile visual composition, Caelestia's System-card grouping, iNiR `GlobalActions` ownership, and cxOrz's detached action invocation. Notifications remain a separate surface.

**Adaptation delta.** Shorten routine panel entry to 260–300 ms and keep only optional section choreography below 700 ms. Back battery data with UPower rather than a fixed `BAT0`. Put capture, record, skwd-wall, settings/Nexus-style control center, idle inhibit, and DND in the System group; keep brightness/volume/profile and session actions in the power panel. Destructive actions use ilyamiro's 700/1,200 ms hold-to-confirm liquid-fill pattern rather than cxOrz's immediate tile. Every command is detached from the bar/shell owner.

### Display panel (§6 Dropdown panels)

**Requirement.** Resolution, refresh, rotation, and display arrangement in a mouse-facing independent panel.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `monitors/MonitorPopup.qml`, monitor support in `Config.qml` and `SettingsPopup.qml` | `hyprctl monitors -j`, draggable monitor metaphor with perimeter snapping, resolution/rate cards, 0/90/180/270 dial. | Only complete candidate. Geometry is strong; its 1,200–1,800 ms entry and generated `.conf` persistence are unsuitable. |
| Caelestia | Nexus has panel/style/device settings but no researched resolution/refresh page. | Partial settings architecture only. | No display solution. |
| iNiR | No dedicated display mode module. | None. | Explicit gap in research. |
| cxOrz | None. | None. | Explicitly missing. |

**Recommendation.** Adapt ilyamiro `MonitorPopup.qml` and its monitor geometry/snap math.

**Adaptation delta.** Move it into an independent panel; reduce reveal/monitor travel to 260–450 ms; keep the single-display view simple while preserving future layout code; translate runtime/persistence calls to the target Hyprland 0.55 Lua configuration boundary rather than generating `.conf` fragments. Keep resolution and refresh as distinct choices and expose current scale/transform.

### Music, media, Cava, and EQ (§6 Music/EQ)

**Requirement.** Album art, metadata, source/player selection, controls, real audio-reactive Cava, and an expandable EasyEffects EQ with presets.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `music/MusicPopup.qml`, `music_info.sh`, `player_control.sh`, `equalizer.sh` | 220 px vinyl art/8 s rotation, 10-band controls, eight presets, 350 ms band motion, staged 760–1,360 ms entrance, finite lightning sweep (650 ms + 150 ms hold + 800 ms fade). | Visual/EQ quality bar. Its “waveform” is event-driven, not Cava; 500 ms shell polling and old EasyEffects output path need replacement. |
| Agridyne/Kurve | `Visualizer.qml`, `drawCanvas.js`, `Cava.qml` | Proven Cava parser and blocks/waves/circle Canvas renderer. | Best reusable edge/linear visualizer, not an EQ. |
| Caelestia | `shell/modules/dashboard/media/`, `CoverVisualiser.qml`, `Details.qml`, `LyricsAndSelector.qml`, `components/widgets/CoverArt.qml`, `services/Players.qml`, native Cava/audio/lyrics services | Roughly 60 radial audio-reactive paths, MPRIS selection, lyrics, seek and controls; cover rotates on a 23.5 s cycle. | Best real music service/visualizer. No EQ and no source-app launch. |
| iNiR | `services/Audio.qml`, `MprisController.qml`, `services/deferred/CavaService.qml`, `modules/mediaControls/*`, `CavaVisualizer.qml`, `CavaWavyLine.qml` | Extensive MPRIS, one shared demand-driven Cava, PipeWire/EasyEffects virtual-sink awareness, multiple card styles. | Best lifecycle/backend. EasyEffects integration is only service-mode, not a band/preset editor. |
| cxOrz | Volume only; no MPRIS/Cava/EQ. | None beyond audio volume. | Not a music candidate. |

**Recommendation — combine, explicitly.** Ilyamiro supplies the EQ UI, preset map, vinyl/lighting composition, and staged expanded entrance. Caelestia supplies MPRIS, lyrics/player selection, true radial Cava, and cover-art handling. iNiR supplies the single demand-driven Cava and PipeWire lifecycle. Kurve supplies the separate sidebar visualizer.

**Adaptation delta.** Replace ilyamiro's 500 ms subprocess polling with the selected MPRIS service; replace its pseudo-wave as the always-visible visualization with Caelestia's true Cava data while retaining the finite preset-apply lightning as feedback; write/load EasyEffects presets under the current XDG data directory and run EasyEffects only in service mode; visibility-gate 60-path rendering and reduce path count/frame rate if the target profile requires it. Keep everyday transport feedback 150–250 ms; use the 760–1,000 ms choreography only on the first expanded-EQ entrance. Add a separately sourced desktop-entry resolver for the source-app icon; none of these repos implements it.

### Notifications (§5 Bar defects, §6 Notifications)

**Requirement.** QuickShell-owned top-right glass cards, actions, grouping/history, DND, click/swipe dismissal, durable state, and semantic filtering of routine events.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `notifications/NotificationPopups.qml`, `battery/BatteryPopup.qml`, `Main.qml` NotificationServer | Actions/images, in-memory history, app grouping/collapse/clear, DND, 400–500 ms toast entry. | Strong visual model, but history is not durable and boot suppression is only 500 ms. |
| Agridyne | KDE Control Station notification state | Quick-setting placement only. | No transferable notification implementation. |
| Caelestia | `shell/services/Notifs.qml`, `NotifData.qml`, `modules/notifications/*`, `modules/sidebar/Notif*.qml` | Persistent/history data, actions/images, DND, grouping, expand/collapse, body copy, close, swipe, fullscreen/click policy. | Best fit and visually verified; still lacks semantic routine-event filtering. |
| iNiR | `services/Notifications.qml`, `notificationPopup/NotificationPopup.qml`, `NotificationItem.qml`, `NotificationGroup.qml`, `NotificationList.qml` | Actions/markup/images, persistence, grouping, DND, unread, 20/s noncritical ingress cap, history, GameMode/fullscreen suppression. | Equally strong service candidate with better ingress/lifecycle controls; no general per-app/category ignore model. |
| cxOrz | `.config/quickshell/modules/notifications/NotificationService.qml`, toast/history files | Small true singleton, separate toast/history, urgency, count bridge. | Useful minimal receiver only; actions disabled, no grouping/persistence/working DND, unbounded flat history and no exit motion. |

**Recommendation — combine.** Use Caelestia's service/data model and popup/history UI as the primary source; add iNiR's noncritical ingress limit and suppression/lifecycle rules. cxOrz is redundant once that coherent slice is carried. Ilyamiro remains a card-motion comparator.

**Adaptation delta.** Restyle to the fixed glass roles; place transient cards top-right and history behind the bell; add a semantic policy keyed by application/category/event so routine home-network connect and similar boot noise is recorded silently or dropped while failures remain visible; persist only appropriate non-transient records; cap history; keep action invocation/default action/body copy; use 200–300 ms entry and a real 180–250 ms exit; register popup/history windows with the common focus coordinator.

### Lock screen (§6 Lock)

**Requirement.** Hyprlock—not a QML lock—with blurred wallpaper, circular vignette, large clock/date, avatar/PIN, battery/Wi-Fi, cinematic entry, and PAM configured before first enable.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `Lock.qml`, `lock.sh`, `hypridle.nix` | Strongly blurred wallpaper, rings/orbits, 140 px clock, avatar/auth transition, status pills, 750 ms entry, 400–600 ms clock→auth, red three-step 120 ms failure shake. | Best choreography; executable QML/PAM lifecycle is explicitly rejected and has no unlock animation. |
| Agridyne | Plasma lock + Smart Video Wallpaper; Monochrome SDDM | Cinematic result driven largely by animated eye wallpaper; standard avatar/password layout. | Visual placement reference only; SDDM is flat/opaque and animated wallpaper is deferred. |
| Caelestia | `shell/modules/lock/*` | QML lock with blur, weather, PAM/fingerprint/face. | Wrong technology and expanded authentication risk. |
| iNiR | `modules/lock/*`, session screens | Feature-rich QML lock with media/Cava. | Wrong technology; layout/status ideas only. |
| cxOrz | `.config/hypr/hyprlock.conf`, `hypridle.conf` | Actual Hyprlock: screenshot background, two blur passes, brightness 0.56, 90 px clock, 25 px date, 300×60 input. | Safest technology match but visually too sparse and lacks status/avatar/choreography. |

**Recommendation — combine.** Use cxOrz's Hyprlock technology/config boundary, restyled with ilyamiro's composition and timing. Other QML locks are visual references only.

**Adaptation delta.** Declare the PAM service before activation:

```nix
security.pam.services.hyprlock = {};
```

Use the current wallpaper as a Hyprlock background, target blur/dim to preserve depth, add circular rings/vignette, large clock/date, avatar/PIN and battery/Wi-Fi fields, and translate the 750 ms ring/orb plus 400–600 ms authentication choreography only through supported Hyprlock animation/config facilities. Do not vendor any `WlSessionLock` QML or PAM loop. Successful unlock must not depend on a shell process.

### Wallpaper picker, transitions, and apply pipeline (§5 Visual, §6 Wallpaper)

**Requirement.** skwd-wall parallelogram picker with compatibility-only changes, awww transitions, palette generation/fallback, optional gowall steering, and an atomic wallpaper→palette→all-surfaces change.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `wallpaper/WallpaperPicker.qml`, `qs_manager.sh`, `matugen_reload.sh` | 2D sheared cards, 500 ms list transitions, thumbnail manifest/video settle, fixed color buckets, `swww` at one second/144 fps. | Polished but not skwd-wall; pipeline runs wallpaper and Matugen concurrently and is non-atomic. |
| Agridyne | Smart Video Wallpaper Reborn; grayscale preprocessing reference | Video crossfade/pause policies and manual media color steering. | Deferred and Plasma-specific; preprocessing idea supports gowall-style palette steering. |
| Caelestia | `cli/utils/wallpaper.py`, `scheme.py`, `theme.py`, `shell/services/Wallpapers.qml`, main app integrations | Wallpaper analysis, scheme generation, watched `scheme.json`, per-file atomic writes, broad fan-out. | Best integrated palette propagation; global update is sequential and can leave partial state. |
| iNiR | `modules/wallpaperSelector/*`, `services/Wallpapers.qml`, `AwwwBackend.qml`, `scripts/colors/switchwall.sh`, `generate_colors_material.py`, `MaterialThemeLoader.qml` | Grid/flat Cover Flow, awww, robust temp-and-rename generated contracts, validation/retry and broad app fan-out. | Strongest defensive generator path and correct awww backend; built-in picker is below skwd-wall and manual-preset path is not atomic. |
| cxOrz | Fixed theme switcher only. | No wallpaper input or transition pipeline. | Not a candidate. |

**Recommendation — combine.** Keep the already selected skwd-wall picker and its `SliceDelegate.qml` compatibility-only path; use iNiR's `AwwwBackend.qml`, validated generated-contract flow, and loader defensiveness; use Caelestia/iNiR app fan-out; expose gowall-style preprocessing as an inverse option. Generator selection remains Matugen only if the installed behavior is verified; otherwise the accepted fallback is hellwal.

**Adaptation delta.** Remove both built-in pickers from ownership of selection. skwd-wall emits one selected path into a single transaction owner. That owner stages fixed-surface plus adaptive-accent contracts and all generated app files before visible state changes; awww, palette state, QuickShell token file, and app reload signals publish from that coherent state, with the previous state retained on failure. Do not run wallpaper and palette application concurrently as ilyamiro does. Do not allow generated Material surface roles to replace the fixed dark ladder. Animated wallpaper remains deferred.

### Terminal / Kitty (§6 Terminal)

**Requirement.** Existing Kitty retained with glass, clickable tabs, Ctrl+T/Ctrl+Shift+T, 10k scrollback, file-path hints into the editor, named/icon terminals, system-info art, find-file, session restore, Fish suggestions, and themed Starship.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `config/programs/kitty/`, Matugen Kitty template, Cava wrapper | Live palette include and broad theme integration. Kitty is opacity 1.0; Cava is separate. | Useful theme template only; not the required terminal UX. |
| Agridyne | `My Rice/Terminal/cool-retro-term-monochrome.json` | Exact translucency 0.7531 and deliberate CRT effects. | Good opacity calibration, but wrong terminal and high-effect cyberpunk treatment conflicts with clean Kitty. |
| Caelestia | `main/foot/`, `fastfetch/`, `fish/`, `starship/`, CLI terminal OSC fan-out | Cohesive prompt/system-info/theme ecosystem. | Strong userland reference, but Foot is the configured terminal and Kitty output is absent. |
| iNiR | `scripts/colors/targets/` Kitty and Starship targets; terminal/app contracts | Explicit Kitty/Starship writers in broad semantic fan-out. | Best theming source; no evidence for target tabs/hints/session workflow. |
| cxOrz | `.config/kitty/`, `apply-theme.sh` | Six fixed coordinated terminal palettes. | Small theme reference; nonadaptive and incomplete UX. |

**Recommendation — combine.** Keep the working target Kitty config; use iNiR's Kitty/Starship target writers and the chosen semantic contracts; use Caelestia's Fastfetch/Fish/Starship composition as the startup-content reference. Do not use cool-retro-term or its CRT artifacts.

**Adaptation delta.** Set Kitty background from the fixed glass token rather than compositor-wide opacity; preserve Ctrl+C/V; add the required tab/reopen/hints/scrollback bindings; make `kitten hints` resolve paths to the selected editor; bind named launcher profiles for agent terminals. Exact find-file/session-restore/system-info implementation is not supplied by these five repos and remains a gap rather than something to synthesize from theme files.

### File manager (§4.12, §4.17, §6 File manager)

**Requirement.** Choose themed Thunar vs Nemo vs Nautilus; modern dark-glass-adjacent presentation, thumbnails, trash, and automount.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | GTK/Qt Matugen templates | Broad toolkit recoloring. | No file-manager evaluation or automount/trash proof. |
| Agridyne | Dolphin shown in previews; Monochrome KDE toolkit coverage | Cohesive near-opaque dark file manager. | Visual reference only and KDE/Qt-heavy for the target. |
| Caelestia | `main/thunar/`, CLI GTK/Thunar theme output | Thunar CSS/preferences tied to semantic palette; app manifest integrates file manager. | Best direct Thunar candidate, but research does not prove thumbnails/automount/trash or full libadwaita coverage. |
| iNiR | GTK3/GTK4/libadwaita and Qt target writers; Nautilus restart in GTK/KDE apply script | Comprehensive toolkit theming and a Nautilus-aware apply path. | Strong theming infrastructure, not a visual/functional file-manager comparison; forced restart is undesirable. |
| cxOrz | Yazi config only. | Terminal file manager. | Does not satisfy GUI file-manager requirement. |

**Recommendation.** Retain Thunar provisionally using Caelestia's Thunar CSS/preferences plus iNiR's complete GTK3/GTK4/libadwaita role writer. The evidence is not sufficient to claim Thunar beats Nemo/Nautilus; record that as a decision/gap.

**Adaptation delta.** Map Thunar CSS to fixed surfaces/adaptive accents, add the validated GTK3 named-color and libadwaita root-variable coverage, and remove disruptive app restarts. Thumbnails, UDisks automount exposure, default handlers, and trash behavior need independent verification/source work; no reviewed repo closes those pieces.

### Dedicated system/process workspace (§6 System monitor)

**Requirement.** A full, terminal-style processes workspace, not a cramped widget.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `Floating.qml` `SystemUsage.qml`, `SysData.qml`; `focustime/*` | Glance telemetry and high-quality activity analytics. | Useful peripheral data, no process table/workspace. |
| Agridyne | KDE monitor/HUD widgets | Decorative persistent readings. | Visually cohesive but redundant and not process-centric. |
| Caelestia | `main/btop/`, `dashboard/performance/*`; named special-workspace patterns in Hyprland Lua | Cohesive btop config and strong aggregate cards. | Best terminal-monitor artifact; dashboard has no processes. |
| iNiR | `services/ResourceUsage.qml`, `modules/sidebarRight/sysmon/SysMonWidget.qml` | Demand-driven CPU/RAM/GPU/disk/history. | Excellent lifecycle, but no process list or dedicated workspace. |
| cxOrz | No process monitor. | None. | Gap. |

**Recommendation — partial combination.** Use Caelestia's btop configuration inside a named dedicated workspace, and use iNiR's demand-driven compact metrics only for bar/panel summaries. No reviewed repo supplies the complete workspace integration, so this remains partially uncovered.

**Adaptation delta.** The bar CPU and RAM buttons target distinct views/workspace actions; the full workspace owns btop/process interaction and optional file/agent status panes. Do not elevate ilyamiro/iNiR compact graphs into a substitute process UI.

### Daily two-agent development workspace (§7)

**Requirement.** One-action workspace with named/icon terminals, Claude/Codex launchers, preset directories, clickable paths/file pane, monitor, Git state, agent-session state, and easy window movement.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `WindowRegistry.js`, FocusTime service/UI, system-usage surface | Scaling, analytics, and glance telemetry. | Useful supporting pieces only. |
| Caelestia | modular Hyprland Lua special workspaces; launcher actions; btop/Fastfetch/Fish/Starship | Named workspaces and cohesive terminal userland. | Best organization/tooling substrate, but no agent workspace. |
| iNiR | dock/taskbar, `ShellExec`, `GlobalActions`, system monitor summaries | Detached launches and task management. | Useful launch/task pieces only. |
| cxOrz | Desktop-entry launcher and independent panels | Detached launch proof. | No development workflow. |

**Recommendation.** No repo closes §7. Reuse Caelestia's named-special-workspace Lua patterns, iNiR `ShellExec`/task controls, and the selected terminal/system-monitor pieces only after a dedicated community source is researched.

**Adaptation delta.** None can be responsibly specified beyond those partial bindings without violating the no-from-scratch rule. File search/view, Git summary, agent-session status, named/icon Kitty profiles, and click-through path workflow are all explicit gap-research targets.

## OS fundamentals (§4)

### File opening, associations, and developer file opener (§4.1)

**Requirement.** Complete XDG default-app map; double-click works for code/text, images, video, PDF, and archives; developer-oriented find-file/open surface.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| Caelestia | `shell/components/filedialog/*`, `main/thunar/`, app manifest | Coherent internal file picker and a configured GUI file manager. | Does not define the target MIME/default-app map or terminal-style project file search. |
| iNiR | launcher web/action/command prefixes; file dialogs and app search | Broad action plumbing. | No indexed file provider or association solution. |
| Others | No relevant implementation in the reports. | — | Uncovered. |

**Recommendation.** None of the five is sufficient. Caelestia's file dialog is reusable only inside shell configuration surfaces; it is not the OS association layer.

**Adaptation delta.** The required MIME map and saatvik333-style developer file opener need gap research. Do not mislabel launcher app search as file search.

### Application install/update and permanent CLI-global path (§4.2, §13)

**Requirement.** Mouse-friendly NixOS application installation comparable to mainstream desktop stores, plus reliable update paths and a permanent npm-global location for agent CLIs.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `updater/UpdaterPopup.qml` | Remote version display and 1,200 ms hold-to-update. | Rejected: evaluates a remotely downloaded imperative installer and does not solve app discovery/install. Only the hold interaction is reusable. |
| Caelestia | `main/manifest.json`, `cli/subcommands/install.py`, `update.py` | Broad component/app catalog and cohesive installer UX. | Arch/AUR-oriented; not a NixOS GUI store or npm-global solution. |
| iNiR | distro/setup/app-catalog/package-search surfaces | Very broad distribution setup UI. | Distribution-oriented and explicitly not a solution for declarative/imperative NixOS application UX. |
| cxOrz | `install.sh` | Interactive Arch package/symlink setup. | Not relevant to NixOS. |

**Recommendation.** No candidate closes the requirement. Use the visual interaction lessons only after tuxmate/nix-software-center/nix-profile/npm-global gap research identifies the actual community implementation.

**Adaptation delta.** All §13 applications remain an install-path acceptance list, not something any reviewed manifest satisfies on NixOS.

### Clipboard history (§4.3)

**Requirement.** `cliphist` + `wl-clipboard` with a searchable, visual text/image Win+V-style panel.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `clipboard/ClipboardManager.qml`, `clip_fetcher.py` | Pages of 24, text/image decode, three-column/four-row grid, keyboard navigation, lazy paging, 250–300 ms selected-card→preview geometry morph. | Best visual interaction. Dismissal depends on global hub and service is script-heavy. |
| Caelestia | main dual `cliphist` watcher startup; `cli/subcommands/clipboard.py` | Correct text/image ingestion plus decode/delete backend. | Final chooser is text-only Fuzzel, below visual requirement. |
| iNiR | `services/deferred/Cliphist.qml`, `modules/clipboard/ClipboardPanel.qml`, `ClipboardItem.qml`, `CliphistImage.qml` | Search, copy/paste/delete, real lazy image decoding, work-safety blur, decode only when preview is visible. | Best complete service/lifecycle candidate and strong visual basis. |
| cxOrz | cliphist startup/selection remnants | Basic clipboard capability. | Session startup deletes history, directly conflicting with the requirement. |

**Recommendation — combine.** Use iNiR's service, lazy image decode, and sensitive-preview policy with ilyamiro's grid, paging, and selected-card shared-geometry morph.

**Adaptation delta.** Put the combined content in its own independent panel with the common focus grab; preserve history across login/reload; cap storage according to the selected source's policy; make activation copy/paste without requiring a keyboard; retain image thumbnails and full text preview. Remove any session-start history deletion.

### Boot experience (§4.4)

**Requirement.** No Option hold, hidden systemd-boot menu with recovery key, branded Plymouth, and seamless power-on→lock.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `config/programs/plymouth/` | Contains an ordinary Plymouth config. | No evidence for target branding, T2 default boot, hidden menu, or macOS `nvram`/`bless`. |
| Agridyne | Monochrome SDDM theme | Login styling only. | Not boot configuration and not the selected lock/login path. |
| Others | None. | — | Uncovered. |

**Recommendation.** Gap research is required for the T2 boot-default fix and final Plymouth/systemd-boot behavior. The existing ilyamiro Plymouth files are at most a theme-format reference.

### Text input intelligence (§4.5)

**Requirement.** System-level spellcheck/autocorrect for GUI fields and a documented Fish autosuggestion accept key on the Mac keyboard.

Caelestia has `main/fish/` and cxOrz has Fcitx/Rime theme assets, but none of the reports identifies a cross-application spellcheck/autocorrect architecture or proves the Fish accept key. **Recommendation: uncovered.** Styling an input method does not satisfy text intelligence.

### Low-latency gaming input/video/audio (§4.6)

**Requirement.** Deliberate controller-driver, compositor/frame, and PipeWire-quantum solution verified end-to-end.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| Caelestia | `shell/services/GameMode.qml`, utilities game-mode toggle | User-facing mode/toggle and effect policy. | No controller driver or measured frame/audio latency pipeline. |
| iNiR | GameMode effect/animation/panel suppression | Reduces shell cost during games. | Useful adjunct only; no xpadneo/xone or PipeWire tuning evidence. |

**Recommendation.** Entire low-latency pipeline remains uncovered. GameMode can later consume the result but is not the result.

### Gesture map (§4.8 and current input defects)

**Requirement.** Preserve three-finger workspace swipe; add deliberate four-finger and pinch behavior.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| Caelestia | `main/hypr/hyprland/gestures.lua` | Four-finger horizontal workspace gestures, three-finger special-workspace gestures, and four-finger sleep action. | Only current native-Hyprland-Lua candidate; partial because pinch is absent and it changes the current finger mapping. |
| iNiR | `CompositorService.qml`, Hyprland branches and GlobalActions | Compositor-aware actions that gestures can target. | No researched complete target gesture map. |
| cxOrz | `.config/hypr/hyprland.lua` | Three-finger workspace gesture. | Existing baseline only; four-finger and pinch missing. |

**Recommendation.** Use Caelestia's Lua gesture syntax/action plumbing, but retain the target's existing three-finger workspace swipe. Assign four-finger actions only after resolving the workspace-vs-sleep conflict. Pinch remains uncovered.

**Adaptation delta.** Merge gesture tables rather than replacing the active Lua config; do not copy touchpad scroll/focus/repeat settings. Mouse-accessible equivalents remain mandatory for every gesture action.

### Optional system sounds (§4.9)

Ilyamiro includes sound assets, but the research does not identify a complete freedesktop sound-theme integration, event policy, or user toggle. **Recommendation: uncovered.** Assets alone are not a system-sound implementation.

### Screenshot and screen recording (§4.10, §5 Capture & keys)

**Requirement.** Clickable System action; region and full-screen recording; Cmd+Shift+S adjustable region→clipboard + timestamped PNG; Print full-screen; no purple film in output.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `ScreenshotOverlay.qml`, `scripts/screenshot.sh` | Adjustable region/resize handles, fullscreen, screenshot/edit/video modes, desktop+mic audio, mic choice, QR, toolbar; `grim`, `satty`, `wl-copy`, `gpu-screen-recorder`; 350 ms region motion. | Most complete capture UI. Complex temporary audio-loopback cleanup and 60 fps recorder need hardware validation. Overlay tint is not baked because `grim` captures separately. |
| Caelestia | `modules/areapicker/*`, `cli/subcommands/screenshot.py`, `modules/utilities/cards/Record.qml`, `RecordingList.qml`, `services/Recorder.qml`, `cli/subcommands/record.py` | Freeze/region screenshot, Swappy, full/region record, pause/stop/elapsed/recent list, notification actions, timestamped MP4. | Best recorder lifecycle/product integration; uses `gpu-screen-recorder`, whose Intel path remains unverified. |
| iNiR | `modules/regionSelector/*`, capture/annotation/OCR/reverse-search, recording/OSD and `GlobalActions.qml` | Broad capture toolset with region/fullscreen choices. | Strong completeness inventory, but not visually ranked above the two leaders and backend details need selection. |
| cxOrz | grim/slurp/satty configuration | Screenshot/annotation only. | No recorder; current flow does not prove clipboard plus timestamped PNG. |

**Recommendation — combine.** Use ilyamiro's adjustable overlay and audio-mode UI with Caelestia's record state/history/notification-action lifecycle and System grouping. iNiR OCR/annotation is a bonus extension. Recorder backend remains a hardware-dependent decision because the reports do not establish `gpu-screen-recorder` on Iris Plus.

**Adaptation delta.** Bind both bar System tile and mandated keys to one `GlobalActions` capture owner; set selection tint in the overlay only and capture through `grim` after geometry selection; always produce clipboard data and timestamped PNG for region capture; give full-screen Print its own direct action. Recorder teardown must recover orphaned temporary audio nodes after crashes. The backend must be selected from an existing implementation after target-hardware evidence, not invented here.

### System-wide search (§4.11)

**Requirement.** Apps plus files, settings, and actions.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| ilyamiro | `applauncher/*` | Applications only. | Insufficient. |
| Caelestia | `modules/launcher/*`, `Actions.qml`, `appdb.*`, `qalculator.*` | Apps, frequency ranking, calculator, wallpaper/scheme/session actions. | Best polished base; no files and limited settings model. |
| iNiR | overview search, `LauncherSearch.qml`, `AppSearch.qml`, `GlobalActions.qml` | Apps, centralized actions, clipboard, emoji, calculations, shell/web prefixes. | Broadest providers; still no indexed files or complete settings results. |
| cxOrz | launcher | Applications only. | Insufficient. |

**Recommendation — combine.** Caelestia launcher UI/ranking plus iNiR action-provider catalog. Add files and explicit settings only after a researched provider exists.

**Adaptation delta.** Keep result types visually distinct and mouse-selectable; do not expose arbitrary shell commands as the discoverability answer. File results must open through the future XDG association/editor policy. Until file/settings providers exist, label this app/action search rather than claiming system-wide completion.

### Removable media and trash (§4.12)

Caelestia performs trash maintenance and configures Thunar; iNiR has extensive file-manager/toolkit integration. None of the reports proves UDisks automount, insert notification, file-manager surfacing, eject, or delete-to-trash semantics. **Recommendation: uncovered.** This must remain in gap research even if the chosen file manager normally supports some pieces.

### Right-click everywhere (§4.13)

**Requirement.** Context menus on desktop, file manager, taskbar tasks, and tray.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| Caelestia | `modules/bar/components/Tray*.qml`, `popouts/TrayMenu.qml`, active-window popouts | Real nested tray menus, right-click, click-away, window actions. | Best tray implementation. |
| iNiR | `DockContextMenu.qml`, `DockAppButton.qml`, `BarTaskbarButton.qml` | Pin/unpin, launch/new, desktop actions, focus/cycle, close/close-all. | Best task/dock context behavior. |
| Agridyne | Plasma defaults | Desktop/panel context behavior in KDE. | Not portable evidence for QuickShell/target file manager. |
| cxOrz | dead QuickShell shelf tray | Right menu display in unwired code. | Below Caelestia and not current runtime. |

**Recommendation — combine.** Caelestia tray menus plus iNiR task/dock context menus. Desktop and chosen file-manager context menus remain uncovered and must not be assumed.

### Printing (§4.14)

No reviewed repo configures or verifies CUPS + HPLIP for the HP printer. **Recommendation: completely uncovered.**

### Per-window Min/Max/Close (§4.15)

**Requirement.** Buttons on every window, potentially hover-revealed; minimize may use a special workspace.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| Caelestia | `components/ActiveWindow.qml`, `modules/windowinfo/*` | Popout with maximize, float, pin, close. | Useful action semantics but controls live in the bar/popout, not each window. |
| iNiR | task/dock context menus and Niri minimize emulation | Task-level close/actions. | Does not supply per-window titlebar controls under Hyprland. |
| Others | None. | — | No solution. |

**Recommendation.** Uncovered. Neither a bar control nor a context menu satisfies “on every window.” Hyprbars/current alternatives require dedicated research.

### Window movement, workspace transfer, and snapping (§4.16)

**Requirement.** Hotkey and mouse movement between workspaces, drag-to-workspace button, Cmd+arrows, edge snapping, and modifier-free titlebar dragging.

| Candidate | Specific source | What it does | Quality assessment |
|---|---|---|---|
| Caelestia | `main/hypr/hyprland/keybinds.lua`, `gestures.lua`, bar workspace components | Current Lua dispatch examples and clickable workspaces. | Useful syntax/actions; workspace delegates are not window drop targets. |
| iNiR | `Workspaces.qml`, dock/taskbar, `BarModuleOrderEditor.qml` | Clickable/scrollable workspaces; polished `DropArea` mechanics for rearranging bar modules. | Drop mechanics are transferable only as a pattern; no dragged-window→workspace implementation. |
| cxOrz | `.config/hypr/hyprland.lua` basic move/resize/workspace bindings | Basic keyboard actions. | No target mouse/titlebar/drop/snap solution. |

**Recommendation — partial combination.** Use Caelestia's native Lua dispatch patterns and iNiR's `DropArea` interaction pattern for the eventual bar workspace target. The complete behavior remains uncovered.

**Adaptation delta.** A workspace delegate must accept a real window/task drag payload and dispatch that window, not merely activate the workspace. Cmd+arrow mappings, edge snap, and modifier-free titlebar dragging require a sourced decoration/window-management solution; do not infer them from module-reorder drag code.

### App-level theming (§4.17)

The full candidate comparison and recommendation are in **Palette & Theming Architecture** below. In brief: Caelestia provides the best verified Spotify/VS Code/Firefox live integrations; iNiR provides the broadest app/toolkit writers including Kitty, GTK3/4/libadwaita, Qt, Chromium, editors, Discord/Vesktop, Spicetify and Starship; ilyamiro provides a small alias boundary and useful templates; Agridyne proves the value of chrome/content separation; cxOrz is too narrow.

## Current defect traceability (§5 and accepted §9 findings)

This matrix prevents overlapped defects from disappearing inside the component recommendations. “Gap” means none of the five reports supplies a sourced fix.

| Current defect / required correction | Best sourced response | Concrete delta / status |
|---|---|---|
| `disable_while_typing` ineffective | None | Gap: requires empirical input-focused research; preserve working tap/two-finger behavior. |
| Delete repeat too fast/nonprogressive | None | Gap: no repo supplies validated target delay/rate. |
| Chrome/general scrolling too fast | None | Gap: do not copy candidate input tables wholesale. |
| Four-finger dead; pinch inconsistent | Caelestia `gestures.lua` partial | Four-finger Lua syntax is reusable; pinch remains a gap. |
| Third+ window resizes/closes another | None | Gap: no report diagnoses the rule/layout cause. |
| Corner resize expands but cannot shrink | None | Gap. |
| Hover focus makes bar close hard to target | Per-window control research plus focus policy | Bar actions do not solve §4.15; gap until decoration source is chosen. |
| Workspace 2 button does nothing | Caelestia/iNiR workspace delegates | Replace binding/model with selected shared workspace service; root defect still needs target-specific fix evidence. |
| Cannot move windows between workspaces | Caelestia dispatch + future iNiR-style drop | Partial; drag payload/target and modifier-free titlebar path are gaps. |
| CLI agents cannot close terminals | No repo-specific source | Remove the target's confirm-on-close setting; exact responsible configuration is outside these reports. |
| Apps die on Waybar restart | iNiR `ShellExec`, Caelestia/cxOrz desktop-entry execution, ilyamiro detached dispatch | Use `systemd-run --user --scope --collect` or `DesktopEntry.execute()` for every bar/launcher action. |
| Bar cramped/tiny media controls | ilyamiro `TopBar.qml`, cxOrz 48 px shelf | 48 px bar, 34 px minimum controls, 4–8 px spacing; retain grouped islands. |
| CPU and Memory open same view | iNiR/Caelestia distinct metrics plus panel coordinator | Give each module a separate action/target ID; full processes workspace remains partial. |
| Calendar is wall of text | ilyamiro `CalendarPopup.qml`, Caelestia dashboard calendar | Use structured date/calendar/weather cards and restrained hierarchy; avoid ilyamiro's user-specific schedule. |
| No compact audio panel | Combined iNiR/cxOrz audio selection | Covered by Audio recommendation. |
| Screenshot/wallpaper under battery | Caelestia utilities grouping | Move capture/record/wallpaper/settings to System group. |
| Notifications ugly/routine spam | Caelestia + iNiR | Covered visually; semantic filter is an explicit adaptation, not present upstream. |
| Launcher pink/beige/dashed/broken | Caelestia launcher | Replace current surface; map to fixed glass tokens/Papirus. |
| Launcher Escape-only | Caelestia `HyprlandFocusGrab` | `onCleared` and Escape close it; Apps + Cmd+Space call same action. |
| Cmd+Space bound to focus | Caelestia launcher action | Change the Lua binding to launcher IPC; do not keep conflicting focus binding. |
| Glass near-opaque | iNiR Aurora + native Hyprland blur | Apply alpha-bearing surface tokens and scoped native blur; see Glass section. |
| Palette not universal/cheap gradients | iNiR/Caelestia fan-out; gradient gap | Universal palette covered; target-quality diffuse aurora gradient remains partially uncovered. |
| EasyEffects window visible / old preset path | ilyamiro EQ + iNiR service-mode awareness | Run service-only; move presets to XDG data path; never launch the UI from volume startup. |
| Thunar dated | Caelestia Thunar + iNiR toolkit writers | Provisional retheme; Nemo/Nautilus decision unresolved. |
| Wallpaper switcher custom jank | Accepted skwd-wall source | Replace with skwd-wall; existing repo pickers do not compete. |
| No smooth/morphing animation | ilyamiro morph + Caelestia/iNiR tokens | Covered by Motion recommendation. |
| Purple film baked in screenshots | ilyamiro `grim` separation | Keep selection tint overlay-only; capture from geometry after selection. |
| Cmd+Shift+S / Print semantics | ilyamiro/Caelestia action owners | Bind exact region and full-screen actions; region outputs clipboard + timestamped PNG. |
| Kitty Ctrl+T / Ctrl+Shift+T | None of the reports | Small target config delta, but not sourced by these repos. |
| Weather wrong city | ilyamiro/Caelestia weather settings | Set target location to Austin through the selected weather service; do not copy ilyamiro's city ID. |
| Chrome software video decode / VA-API absent | Accepted finding in MASTER only | No one of the five research files adds stronger implementation evidence; retain as a gap-plan input, not re-diagnosis. |
| `vibrancy_darkness` direction and native glow | Accepted findings in MASTER only | Preserve `0 = maximum effect`; Hyprland glow may provide a cheap rim accent, but none of the five reports evaluates a target configuration. |

## Required applications and preserved invariants (§10–§14)

The application list in §13 remains a product acceptance list. Caelestia/iNiR manifests demonstrate that coherent themes/configs exist for many entries, but neither supplies the required NixOS GUI installation path. T2 modules/firmware, `nix-ld`, hostname/user, NetworkManager, PipeWire, Fish, state version, systemd-boot recovery, zram, and the untouched channel-based system configuration are invariants—not candidates for replacement by any full repo config.

Working font rendering, cursor states, tap-to-click, two-finger scroll, boot Wi-Fi, Kitty Ctrl+C/V, rollback, agent execution, and Chrome Wayland must be preserved. Animated wallpaper, the matrix boot menu, Alienware port, self-hosted music, and optional Neovim remain deferred; no attractive candidate above promotes them into the current scope.

## Palette & Theming Architecture

### Candidate comparison

| Repo | Specific source and mechanism | Strengths | Weaknesses / adaptation delta |
|---|---|---|---|
| ilyamiro | `config/sessions/hyprland/scripts/quickshell/MatugenColors.qml`; `config/programs/matugen/templates/qs_colors.json.template`; templates for Kitty, Vesktop/Discord, Firefox, Neovim, Cava, SwayOSD, GTK, Qt5/6, and Hyprland | Very small shell-facing boundary: 22 aliases loaded from a 24-line JSON template. Widgets consistently consume `base`, `surface0`, `text`, `mauve`, `blue`, `teal`, etc. Good compatibility layer for vendored widgets. | Several aliases collapse (`blue`/`mauve`→primary, `green`/`teal`→secondary, overlay0/1/2→inverse surface). `/tmp/qs_colors.json` is polled every second. Surface values follow Material and large panels are opaque. Keep the alias boundary, replace mapping/polling and do not make it the universal authority. |
| Agridyne | Monochrome KDE system roles; `My Rice/Panel Colorizer/*/settings.json`; Kurve system highlight; Zen `userChrome.css` | Strong static cohesion result because Plasma, Qt/Kvantum, GTK, decorations, panels, SDDM and selected apps refer to system roles. Exact base roles: background `#1e1e20`, foreground `#aaaaac`, selection `#727274`, focus `#505052`, hover `#6e6e70`. | Static grayscale, manually prepared wallpaper, no extraction, named accent contract, global transaction, or universal app reload. Use its “one shared role system” and chrome/content separation, not its palette. |
| Caelestia | `cli` state `~/.local/state/caelestia/scheme.json`; `shell/services/Colours.qml`, `components/CAnim.qml`, typed Config; `cli/src/caelestia/utils/theme.py`, templates; main VS Code, Firefox, Spicetify integrations | Full Material/terminal semantic state, live `FileView` watch, animated role propagation, per-monitor overrides, and broad fan-out. Particularly strong verified Spotify whole-window theming and live VS Code/Firefox consumers; Chromium managed frame support and Papirus folder hue. | Stock policy changes surface colors and permits light mode. Kitty is not explicit; GTK/libadwaita target coverage must be reconciled with the validated role set. Each file is atomic but global fan-out is sequential and errors can leave a partial desktop. Pin surfaces, add Kitty/complete toolkit roles, and wrap consumers in one authority. |
| iNiR | `modules/common/Appearance.qml`, `ThemePresets.qml`, `StylePresets.qml`, `services/MaterialThemeLoader.qml`, `ThemeService.qml`; `scripts/colors/generate_colors_material.py`, `switchwall.sh`, `applycolor.sh`, `scripts/colors/targets/` | Richest architecture and coverage: about 54 base semantic roles, hundreds of derived surface/text/control/glass/type/motion tokens, 46 palettes, separate style/density axes, validated/debounced live loader, Kitty/Starship/GTK3/GTK4/libadwaita/Qt/Chromium/editors/Discord/Spicetify and more. Wallpaper-generator path uses temp files and successful renames. | Huge authority with duplicated fallbacks/style branches. Stock generation changes surfaces and multiplies saturated colors to 60% of original HSL saturation, risking the muted failure. Manual-preset path writes final files directly despite an atomicity claim. Extract a coherent ii token slice, disable softening, pin surfaces, and repair the single transaction boundary. |
| cxOrz | `.config/quickshell/Theme.qml`, `ThemeSection.qml`, `scripts/apply-theme.sh` | Compact semantic names and shared sizes; six fixed themes propagate to QuickShell, Waybar, Kitty, Hyprland borders and old Rofi. | Palettes are duplicated between QML and shell, nonadaptive, non-atomic, and omit GTK/Qt/Hyprlock/apps. Useful role-name cross-check only. |

### Recommendation: a single-authority hybrid

Adopt the **mubin result policy** from the master requirement—fixed dark surfaces, adaptive accents—but implement it with the strongest reviewed code:

1. **Authority and contracts:** an extracted iNiR Material-ii token/contract slice (`Appearance.qml`, generated JSON contracts, `MaterialThemeLoader.qml`/`ThemeService.qml`) is the one semantic authority. The entire Waffle hierarchy, automatic surface recoloring, Angel offset-shadow identity, and default 60% saturation softening stay out.
2. **Compatibility facade:** ilyamiro's small `MatugenColors.qml` alias boundary maps imported widgets onto the authority. It is a facade, never a second palette source.
3. **Application consumers:** iNiR `scripts/colors/targets/` supplies breadth; Caelestia supplies the strongest application-specific pieces—Spicetify CSS/templates, VS Code watcher, Firefox native bridge, Chromium frame handling, Thunar CSS—and visual verification.
4. **Atomicity:** iNiR's temp/validate/rename generator flow is the baseline, but neither repo provides the required single global commit. The final architecture must stage the shell contract and every generated consumer before changing visible wallpaper/palette state, retain the previous coherent state on failure, and report failed consumers rather than swallowing them.

The fixed surface ladder should preserve iNiR Angel's useful depth separation while shifting it to the required blue-black direction. Recommended authority values are:

| Target role | Fixed value | Source reasoning |
|---|---|---|
| `background` | `#080b14` | Near-black base; analogous depth to iNiR Angel `#08070a`, without its brown cast. |
| `surfaceLowest` | `#0a0e1a` | Matches the master glass RGB starting point exactly. |
| `surfaceLow` | `#0f1526` | First visible blue-black elevation. |
| `surface` | `#151d33` | Mid container; still dark enough for translucent treatment. |
| `surfaceHigh` | `#1c2742` | Highest fixed container for selected/elevated state. |
| `onSurface` | `#e6edf7` | High-contrast clean text; fixed, not wallpaper-derived. |
| `onSurfaceMuted` | `#aab6c8` | Secondary text; fixed for predictable contrast. |
| `primary`, `secondary`, `tertiary` | wallpaper-derived purple, teal/seafoam, deep-green/cool-blue roles | Only these families and their on/container variants adapt. Clamp luminance/saturation; do not apply iNiR's 60% saturation multiplier. |

The accepted pink/mauve defect is a lightness problem: tone-80 output destroys saturation. Accent selection must therefore clamp tone/lightness before any hue judgment; do not “correct” the palette by rotating hues while leaving the destructive tone policy intact.

A thin widget facade should look like this in principle:

```qml
// One-way aliases for imported widgets; the values are not generated here.
readonly property color base: Theme.surfaceLowest
readonly property color mantle: Theme.background
readonly property color surface0: Theme.surfaceLow
readonly property color surface1: Theme.surface
readonly property color surface2: Theme.surfaceHigh
readonly property color text: Theme.onSurface
readonly property color subtext0: Theme.onSurfaceMuted
readonly property color blue: Theme.primary
readonly property color mauve: Theme.primary
readonly property color teal: Theme.secondary
readonly property color green: Theme.tertiary
```

Application-specific decisions:

- **Spotify:** Caelestia `main/spicetify/Themes/caelestia/user.css` plus CLI dark-slot mapping wins; add a guaranteed palette-change apply/reload hook.
- **VS Code:** Caelestia `main/vscode/caelestia-vscode-integration/` wins; write generated theme data outside immutable store paths.
- **Discord/Vesktop:** use the iNiR target writer for the fixed contract, with Caelestia templates as a visual comparator; do not depend on ilyamiro's remotely imported theme as the authority.
- **Chrome/Chromium:** keep browser policy declarative; feed the fixed frame role and adaptive accent without runtime permission mutation. Agridyne's conceptual boundary remains important: chrome may be translucent/themed while web/video content stays opaque. Its exact Zen rule is worth retaining as evidence:

```css
#browser { background-color: #40404066; } /* 40% frame tint, not whole-window opacity */
```

- **GTK/Qt/libadwaita/Thunar:** use iNiR's comprehensive writers, preserving the already validated GTK3 named colors and four libadwaita root variables, then layer Caelestia Thunar CSS. Avoid forced Nautilus restarts.
- **EasyEffects:** theme it through the Qt6/Kirigami path, not GTK assumptions, while keeping it service-only in normal use.
- **Kitty/Starship/Cava/btop:** use iNiR targets; map opacity separately from palette so a theme change cannot accidentally make the terminal opaque.

## Motion & Animation Patterns

### Complete technique inventory by interaction class

| Interaction class | Repo/source | Exact pattern and values | Assessment/use |
|---|---|---|---|
| Panel first open | ilyamiro `Main.qml` | Geometry 230 ms `OutCubic`; opacity 160 ms `OutCubic`. | Excellent compact reference, but extract from global hub. |
| Panel close | ilyamiro `Main.qml` | Width/height collapse to 1 and opacity falls over 160 ms `InCubic`; stack clears after 200 ms. | Good speed; do not literally collapse every independent window to 1 if it distorts anchoring. |
| Independent panel open/close | cxOrz wrappers | Open/close y travel 200 ms `OutCubic`; launcher opens 200 ms `OutCubic`, closes 200 ms `InCubic`; unload after exit. | Correct daily speed and simple lifecycle. |
| Independent sidebar lifecycle | iNiR sidebars | Entry translation normally 400 ms deceleration; exit about 200 ms; unmap after 300 ms; slide/reveal/elastic/pop/drop/swing variants. | Keep map/animate/unmap, shorten common entry. |
| Expressive drawer | Caelestia `Anim.qml`, token config | Default spatial 500 ms `(0.38, 1.21, 0.22, 1)`; fast 350 ms `(0.42, 1.67, 0.21, 0.9)`; slow 650 ms `(0.39, 1.29, 0.35, 0.98)`; effect 150/200/300 ms. | Excellent token system; ordinary 500 ms drawer is too slow/springy for target mood. |
| Hover/state layer | ilyamiro/Caelestia/iNiR/cxOrz | Ilyamiro 150–300 ms; Caelestia effect/ripple 150–300 ms; iNiR fast 200 ms; cxOrz tile color 120 ms. | Standardize at 150–200 ms; 120 ms is acceptable for color-only feedback. |
| Toggle | cxOrz | Thumb x and track color 200 ms `InOutQuad`; feature-tile state color 120 ms. | Directly suitable. |
| Press | cxOrz launcher | Scale 1→0.93 over 80 ms `OutCubic`. | Keep as tactile down-state; release should recover around 120–160 ms. |
| Directional selection morph | ilyamiro bar/network tabs | Leading boundary 200 ms, trailing 350 ms, `OutExpo`, producing stretch/catch-up. | High-value signature interaction for workspaces, tabs, and modes. |
| Master geometry/content morph | ilyamiro `Main.qml` | x/y/w/h 210 ms `OutCubic`; replace-enter opacity 0→1 `OutQuint` + scale .98→1 `OutCubic`; replace-exit opacity `InQuint` + scale 1→.98, all 210 ms. | Primary compact↔expanded/subview morph engine. |
| Card→detail shared geometry | ilyamiro clipboard | Selected real delegate x/y/w/h/radius→preview over 250–300 ms `OutExpo`. | Use for clipboard, device detail, album/EQ expansion where geometry is stable. |
| Launcher mode swap | Caelestia | Content out 200 ms opacity 1→0 + scale 1→.9, delegate swap, content in 200 ms scale .9→1; list size/insert/remove also animated. | Good content-mode transition; scale delta may be reduced to .96 for calmer motion. |
| Count-driven radial morph | ilyamiro Bluetooth | Multi state 1,200 ms `InOutExpo`; active core count 1,000 ms; positions/angles 1,000–1,400 ms; central control 800 ms `InOutQuint`. | Use only inside an expanded, infrequent device view; too slow for panel open. |
| EQ band response | ilyamiro music | All ten sliders 350 ms `OutQuart`; finite Canvas sweep 650 ms `OutSine`, 150 ms hold, 800 ms `OutQuad` fade; handles surge 1,000–1,500 ms. | Keep as intentional apply feedback; event-only rendering is hardware-conscious. |
| Cinematic widget entrance | ilyamiro music | Main 760 ms; cover +70/810 `OutBack`; text +150/760; controls +230/760; separator +310/660; EQ header +370/710; sliders +430/860; presets +550/810. Last settles ~1.36 s. | Quality bar; shorten final target to roughly 900–1,100 ms except first/full expansion. |
| Lock choreography | ilyamiro lock | Three ring stages 250/300/350 ms; icon latch sequence; total entry ~750 ms; clock→avatar 400–600 ms; failure shake 3×120 ms. | Adopt as Hyprlock choreography reference. |
| Full-family cinematic | iNiR `FamilyTransitionOverlay.qml` | Wallpaper blur builds, scale 1.05→1, staggered identity content, family swap under 200 ms hold; total ~1.2 s; colors snapshotted first. | Best example of cinematic coordination and palette-snapshot safety, not an everyday widget transition. |
| Continuous visualizer | Kurve / Caelestia / iNiR | Kurve Cava blocks; Caelestia ~60 radial paths; iNiR shared demand-driven Cava. | Use one shared analyzer; distinct renderers for dock and music; stop/reduce while hidden or idle. |
| Ambient movement | ilyamiro/Caelestia | Cover rotation 8 s (ilyamiro) or 23.5 s (Caelestia); ilyamiro blobs 90–200 s; border gradient 5 s. | Prefer slower Caelestia cover cycle; omit/gate infinite blob layers on Iris Plus. |
| Panel state by window state | Agridyne Panel Colorizer | Optional 250 ms `OutCubic` property animation; normal grouped islands vs maximized/fullscreen continuous strip. | Useful state model, not a general morph system. |
| Velocity/spring following | iNiR `Appearance.qml` | `SmoothedAnimation` velocity classes at 1,400 and 2,600 units; spring 3.2, damping .28, mass 1, epsilon .25. | Keep available for drag-follow and physical indicators, not routine panel mapping. |
| iNiR core motion classes | iNiR `Appearance.qml` | 200 ms fast/effect `[.34,.80,.34,1,1,1]`; exit 200; scroll 200; resize 300 emphasized spline; menu 350 `OutExpo`; enter 400; click bounce 400; move 500 `[.38,1.21,.22,1,1,1]`; slow spatial 650 `[.39,1.29,.35,.98,1,1]`. | Extract the token table; shorten enter/move for daily use. |
| Caelestia standard tiers | Caelestia `tokens.hpp`, `Anim.qml` | 200/400/600/1,000 ms standard tiers around `(0.2,0,0,1)` plus acceleration/deceleration variants; colors animate 300 ms through `CAnim.qml`. | Strong centralized vocabulary; use 1,000 ms only for cinematic states. |
| Calendar/weather state | ilyamiro `calendar/CalendarPopup.qml` | Old content exits 250–300 ms; new state enters 450–600 ms `OutQuart`/`OutBack`; full section entry 800–1,150 ms. | Keep the two-stage state idea, reduce repeated-state travel. |
| Wallpaper carousel | ilyamiro `wallpaper/WallpaperPicker.qml` | Card width/height/scale/opacity/highlight 500 ms `InOutQuad`; new online item 400 ms from scale .5; video preview waits 250 ms settle. | Picker not adopted, but settled-preview and manifest behavior are good references. |
| Volume/device list entrance | ilyamiro `volume/VolumePopup.qml` | Main 700–800 ms `OutExpo`/`OutBack`, cards stagger. | Too slow for compact audio; reserve presentation ideas for expanded view. |
| Display entrance | ilyamiro `monitors/MonitorPopup.qml` | General 900 ms; monitor scale 1,200; vertical travel 1,800; screen light 1,500. | Explicit anti-target for repeated control use; geometry survives, timing does not. |
| Focus analytics views | ilyamiro `focustime/FocusTimePopup.qml` | Charts settle up to 1,300 ms; day/week/app focus changes 550 ms `OutExpo`. | Appropriate for optional dashboard data, not shell controls. |
| Capture geometry | ilyamiro `ScreenshotOverlay.qml` | Region and toolbar section geometry 350 ms `OutExpo`; mode selection uses 200/350 ms stretch highlight. | Directly useful. |
| Right-edge join | Caelestia sidebar/utilities | Background width joins notification history and utilities over 500 ms expressive spatial interpolation. | Good shared-edge idea, but target panels remain independent. |
| Caelestia state layer | Caelestia `StateLayer.qml` | Hover about 200 ms plus longer Material ripple/fade sequence. | Keep hover; make ripple optional/subtle for the calmer target. |
| cxOrz toast/OSD/power | cxOrz notification/OSD/power files | Toast enters from y −16→0 + opacity over 200 ms but exits immediately; OSD y 14→0 over 220 ms and opacity 180 ms, exits 200 ms; power scale .93→1 + opacity 200 ms but is destroyed immediately on close. | Retain entries and add real 180–200 ms exits. |
| cxOrz scanners | cxOrz Wi-Fi/Bluetooth | Spinner loops at 1,000/1,200 ms linear. | Fine while an actual scan is active; stop immediately with service state. |
| Agridyne micro/ambient motion | Control Station, Monochrome SDDM, Kurve, Zen, cool-retro-term | Control Station view swap roughly 20/50/20 ms; SDDM field color ~300 ms; Kurve continuous Cava; Zen “Smooth Flow” tab/URL animation; CRT flicker/noise/jitter continuous. | Only Kurve is adopted. Control Station is too abrupt; SDDM is ordinary; CRT effects are rejected. |
| Hyprland reference curves | ilyamiro/cxOrz/Caelestia Lua/config | Ilyamiro supplies custom `0.05, 0.9, 0.1, 1.05`; cxOrz defines `easeOutQuint`, `easeInOutCubic`, `linear`, `almostLinear`, `quick`; Caelestia coordinates windows/layers/workspaces/borders/fades in Lua. | Merge only the selected curve tables into the existing target Lua; QML milliseconds and Hyprland speed units are not interchangeable. |

### Recommended target motion vocabulary

| Target token | Value | Use |
|---|---|---|
| `effectFast` | 120–150 ms, nonovershooting ease-out | Color, icon, pressed state. |
| `effect` | 180–200 ms, standard `(0.2,0,0,1)` or `OutCubic` | Hover, toggle, simple opacity. |
| `panelOpen` | 260 ms `OutCubic`; opacity begins immediately; translation 8–16 logical px and scale .97→1 | Daily popup/dropdown open. |
| `panelClose` | 180–200 ms `InCubic` | Daily close, followed by unmap. |
| `morph` | 210–260 ms `OutCubic`; content opacity `OutQuint`, scale .98→1 | Compact↔expanded and subview changes. |
| `selectionStretch` | leading 200 ms / trailing 350 ms `OutExpo` | Workspace/tab/preset indicators. |
| `layout` | 300–350 ms `OutExpo`/`OutQuart` | List height, card arrangement, EQ bands. |
| `cinematic` | 750–1,000 ms staged | Lock and first expanded-widget entrance only. |
| `reducedMotion` | 0–120 ms opacity/color; no travel/scale/ambient loops | User setting and performance mode. |

Representative morph pattern worth carrying from ilyamiro:

```qml
Behavior on x      { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }
Behavior on y      { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }
Behavior on width  { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }
Behavior on height { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }

// Replace content in the same event turn as geometry changes.
// Enter: opacity 0→1 OutQuint, scale .98→1 OutCubic, 210 ms.
// Exit:  opacity 1→0 InQuint,  scale 1→.98 OutCubic, 210 ms.
```

The token authority should follow Caelestia/iNiR, not repeat numbers in every component. Add a reduced-motion/duration-scale setting from day one: ilyamiro lacks it, while iNiR already exposes global effect/animation flags and Caelestia has a duration scale. Visibility-gate infinite motion, merge all Cava consumers onto iNiR's shared lifecycle, and keep expensive Canvas/shader effects event-driven wherever possible.

## Glass & Transparency

### Values and visual-quality ranking

| Rank for this target | Repo | Actual values / mechanism | Visual assessment |
|---:|---|---|---|
| 1 | iNiR Aurora | Shipped transparentize: overlay `.38`→alpha `.62`, sub-surface `.52`→`.48`, popup `.42`→`.58`, tooltip `.35`→`.65`, generic layer `.40`→`.60`. `AuroraStyleEditor.qml` has 0–1/.01 live sliders and presets. Current renderer aligns a full-screen wallpaper image per surface and applies `MultiEffect blurMax: 64`. | Best opacity taxonomy and live tuner; official images prove real wallpaper-through glass. Per-instance full-screen blur FBO is the worst hardware risk and must be bypassed with native blur. |
| 2 | Caelestia | Transparency default off; when enabled base `.85`, layer `.4`; light mode effective base `.75`. Hyprland blur size 8/two passes/xray false; `ignore_alpha ≈ base - .03`; normal window opacity `.95`; `MultiEffect blurMax: 15` shadow. | Dark preview shows convincing real glass and excellent live alpha/rule synchronization. Base is too opaque and SDF/full-screen shell is too coupled. |
| 3 | Agridyne | Zen `#40404066` (40% tint) plus Better Blur strength 4, noise 5, brightness 25%, saturation 0%, contrast 105%; cool-retro-term opacity `.7531`. Panel islands alpha 1.0; continuous panel alpha .8 with zero lightness. | Best application-specific chrome glass and strong restraint; grayscale/desaturation would kill the target aurora bleed. Panels themselves are not the reference. |
| 4 | cxOrz | Control/notification/launcher outer surfaces `.78`; power `.82`, OSD `.92`, Waybar `.80`; Hyprland size 4/two passes; layer `ignore_alpha .5`; inner cards mostly opaque. | Real wallpaper transmission and low complexity, but too opaque, flat and weakly diffused. Functional baseline only. |
| 5 | ilyamiro | Top bar ~`.75`, floating edge `.95`, lock menu `.95`; music blurred-art background `.9`; compositor size 8/two passes; large widgets and Kitty effectively opaque. | Not a glass reference. Excellent internal glow/shape composition can be layered over a different glass base. |

### Recommended Iris Plus configuration

Use iNiR's opacity classes and tuner UI, but route blur through **one scoped Hyprland compositor pass**, not repeated QML wallpaper `MultiEffect`s and not Caelestia's full-screen SDF drawer. The initial target configuration is:

| Element | Recommended starting value |
|---|---|
| Main bar/panel tint | `rgba(10,14,26,0.60)` / `#0a0e1a99` |
| Popup/history tint | alpha `.58` / `#0a0e1a94` |
| Sub-card tint | fixed `surfaceLow` RGB at alpha `.48` |
| Tooltip tint | alpha `.65` |
| Border | 1 logical px, white at 10% / `#ffffff1a` |
| Blur | native Hyprland size 12, one pass initially, `xray = false` |
| Layer threshold | `ignore_alpha ≈ 0.57` for a `.60` base, following Caelestia's `base - .03` synchronization pattern |
| Color transform | brightness 1.0, saturation 1.0, contrast about 1.05; do not copy Agridyne's 25% brightness/0% saturation |
| Rim accent | restrained per-window native glow using an adaptive accent; preserve the accepted `vibrancy_darkness = 0` direction |

Conceptual Hyprland-Lua values:

```lua
decoration = {
  blur = {
    enabled = true,
    size = 12,
    passes = 1,
    xray = false,
    contrast = 1.05,
    brightness = 1.0,
    vibrancy_darkness = 0,
  },
}
-- Apply blur only to stable QuickShell layer namespaces.
-- Pair each .60 panel fill with ignore_alpha near .57.
```

This is a hardware-conscious starting point, not a claim of measured final performance. If one pass cannot achieve the required diffusion, the first comparison is size 12–16 with two passes on only the visible named shell layers—not enabling blur globally or restoring per-surface QML blur. The glass tuner must edit the same central opacity classes, preview actual wallpaper-backed panels, and synchronize fill/`ignore_alpha` ordering as Caelestia does (30 ms coalescing and delayed rule change after its 300 ms color transition). Opaque web/video content remains opaque; browser chrome/content separation follows Agridyne's evidence.

## Other visual-system requirements (§3)

### Diffuse aurora gradients and restrained depth

**Requirement.** Cohesive, diffuse purple/teal/deep-green illumination across surfaces—not isolated cheap blobs or flat Material fills.

| Candidate | Specific source | Contribution | Assessment |
|---|---|---|---|
| ilyamiro | `MusicPopup.qml`, ambient backgrounds across major widgets | Blurred album art at about .9, 90 s orbiting blobs, 5 s rotating border gradient, faint .03–.08 orbit circles, finite glowing Canvas strands. | Best internal depth/luminous composition; large panels still opaque and many infinite effects need gating. |
| Caelestia | `plugin/src/Caelestia/Blobs/*`, shared SDF background, semantic `tPalette` | Joined edge shapes, wallpaper-aware translucent roles, shadow depth. | Sophisticated geometry, not the desired independent-surface radial-aurora technique; shader stack is too coupled. |
| iNiR | Aurora/Angel roles, partial borders, inset top glow, glass tuner | Good tint hierarchy and optional tasteful edge accents. | Angel offset shadow establishes the wrong identity and can add another full-screen blur FBO. |
| Agridyne | Strong negative space, wallpaper-led composition, selective browser blur | Demonstrates that small surfaces and unbacked visualizer areas let the wallpaper supply atmosphere. | Excellent restraint; no dynamic gradient implementation. |
| cxOrz | Flat opaque internal tiles | None beyond basic translucency. | Below target quality. |

**Recommendation — combine.** Let the wallpaper carry the broad aurora field; use fixed translucent surfaces, a restrained native rim glow, and ilyamiro-style low-opacity accent layers only inside high-value expanded widgets. Adopt Agridyne's negative-space discipline. Do not import Caelestia's shared blob shell or iNiR's offset glass shadows.

**Adaptation delta.** Long-running ambient layers must be visibility/power gated and limited to one or two large diffuse shapes per expanded surface. Static/diffuse radial gradient construction at the ML4W quality bar is not actually present in these five reports, so the exact community CSS/QML implementation remains a gap rather than being recreated from the screenshots.

### Typography, icons, density, and Retina scaling

| Candidate | Specific source | Contribution | Assessment |
|---|---|---|---|
| ilyamiro | `WindowRegistry.js`, `Scaler.qml` | Fits a 1920×1080 design space using the smaller ratio: `r^0.85` below 1, `r^0.5` above 1, lower clamp .35, then user scale. On the target logical surface it yields about .90. | Best compact responsive-scale formula; interactive targets still need independent minimums. |
| Caelestia | typed size/font tokens and `shell-tokens.json` | Central dimensions and fonts, current default Google Sans Flex/Material icons. | Strong replace-once boundary; source families/icons do not match target. |
| iNiR | `Appearance.qml` font ladder and `appearance.typography.sizeScale`; `QT_SCALE_FACTOR=1` | Logical font ladder 10/12/13/15/16/17/19/22/23, global live size factor, central families/icons, avoids double scaling. | Best Retina scaling policy; one factor also scales large geometry, so density and type may need separate roles. |
| Agridyne/cxOrz | JetBrainsMono/monospaced UI | Cohesive within those builds. | Conflicts with clean sans UI requirement and hurts dense interface readability. |

**Recommendation — combine.** Use iNiR's `QT_SCALE_FACTOR=1` and logical token model with ilyamiro's fit function for responsive surface geometry. Replace UI/icon tokens centrally with Inter (or equivalent clean sans), FiraCode Nerd Font for terminal/code, and Papirus. Enforce a 34 logical px minimum on interactive bar/media controls independently of visual scaling; do not allow ilyamiro's .35 decorative clamp to shrink mouse targets.

## Bonus Finds

These are sourced features that fit the design philosophy without displacing a requirement.

1. **Mouse-reorderable bar modules — iNiR.** `modules/common/widgets/BarModuleOrderEditor.qml` has real `DropArea`s, lifted drag item, insertion marker, cross-zone movement, and persistent updates. This is exactly the kind of discoverable configuration that makes the desktop feel like an OS. Adopt after the fixed required modules are protected from accidental removal.

2. **Desktop widget edit mode — iNiR.** `modules/background/widgets/AbstractBackgroundWidget.qml` and the editor support drag/resize, nine zones, locking, layout presets, wallpaper-region contrast, and power/visibility-gated effects. This is a strong later addition for clock/weather/media/status without turning the permanent desktop into a dense dashboard.

3. **FocusTime analytics — ilyamiro.** `focustime/FocusTimePopup.qml`, `focus_daemon.py`, and `get_stats.py` form a complete event-driven Hyprland+SQLite usage system with daily/weekly/month heatmap/top-app views and 550 ms view transitions. It is unusually polished and useful, but should remain opt-in and must not replace the process workspace.

4. **Hold-to-confirm liquid fill — ilyamiro.** Network disconnect uses 700 ms fill; updater uses 1,200 ms. This provides clear destructive intent for shutdown/reboot/disconnect without a modal confirmation maze.

5. **Nexus-style graphical settings — Caelestia.** `shell/modules/nexus/*` and its typed rows make normally hidden shell settings mouse-accessible. A target settings center built from selected pages would directly serve the governing standard; avoid importing the entire Caelestia service graph for appearance alone.

6. **Usage-ranked apps and native calculator — Caelestia.** `plugin/src/Caelestia/appdb.*` and `qalculator.*` make the launcher progressively more useful without losing mouse access. Both belong in the selected launcher slice.

7. **Idle inhibit / “Keep Awake” — Caelestia.** `modules/utilities/cards/IdleInhibit.qml` plus `services/IdleInhibitor.qml` is a small but important OS-quality control that users otherwise discover only after a sleep interruption. Put it in System quick toggles.

8. **Browser chrome/content separation — Agridyne.** The Zen result proves that transparent controls and opaque media/content are more legible than whole-window compositor opacity. Even with Chrome retained, this is the correct criterion for browser theming.

9. **Demand-driven services — iNiR.** `ResourceUsage.qml` stops after about 15 seconds without consumers; `CavaService.qml` shares one process and debounces teardown; `shell.qml` tier-loads/lazily loads families. These are valuable patterns on a dual-core machine and should influence every selected service.

10. **Responsive scale registry — ilyamiro.** `WindowRegistry.js` keeps component geometry in one place and makes the target 1.5× display predictable. Pair it with independent minimum hit targets.

11. **Split toggle/detail tiles — cxOrz.** `FeatureTile.qml`'s 72% direct toggle / 28% chevron detail areas solve a recurring ambiguity in network, Bluetooth, DND, and microphone controls.

12. **Hide–teleport–show edge relocation — ilyamiro.** `Floating.qml` moves an edge surface only while hidden, avoiding an awkward full-screen diagonal animation. Useful if the user later allows dock-edge customization.

13. **Palette-safe cinematic transition — iNiR.** `FamilyTransitionOverlay.qml` snapshots source/destination colors before its 1.2 s sequence, preventing theme changes from flickering mid-animation. The same snapshot principle is useful for lock/wallpaper transitions even though the family swap itself is not adopted.

14. **Real network history cards — Caelestia and KDE Control Station.** Caelestia `NetworkUsage.qml` plus Control Station's 40-sample chart show that a small status surface can communicate actual traffic rather than a decorative percentage.

## Uncovered Gaps

This list is deliberately granular. It includes complete requirements with no solution and unresolved subrequirements where the repos offer only partial coverage.

### Entirely uncovered OS fundamentals

- **Complete XDG MIME/default-app policy** for Markdown/code/JSON/config/logs→editor, images→viewer, video→mpv, PDFs→viewer, archives→manager, including “Open with.”
- **Developer find-file/open surface** comparable to the named saatvik333 reference, plus file-path/session integration in Kitty.
- **NixOS GUI app installation/update UX** matching tuxmate ease; the choice among tuxmate-style frontend, software-center class GUI, and `nix profile` is not researched here.
- **Permanent npm-global path and update UX** for Claude Code/Codex under the Nix store model.
- **Boot-default repair on the T2 Mac** (`nvram`/`bless` side), hidden systemd-boot menu/recovery reveal, and a final branded Plymouth path.
- **Cross-application GUI spellcheck/autocorrect** and a proven Fish autosuggestion accept key on the Apple keyboard.
- **End-to-end gaming latency stack:** xpadneo vs xone, controller latency, compositor/frame latency, and PipeWire quantum/audio latency, measured together.
- **Tasteful, optional, toggleable system sound theme.** Ilyamiro's sound assets do not constitute integration.
- **UDisks removable-media flow:** automount, notification, file-manager appearance, safe eject, and tested USB behavior.
- **Verified trash semantics** in the selected file manager.
- **CUPS + HPLIP printer integration** for the HP printer.
- **Per-window Min/Max/Close implementation** under current Hyprland, including minimize semantics. Bar/popout actions do not satisfy this.
- **Complete modifier-free titlebar dragging, edge snapping, Cmd+arrow movement, and dragged-window→workspace target behavior.**

### Search, workspace, terminal, and file-management gaps

- **Indexed file provider and complete settings provider** for system-wide search. Current candidates cover apps/actions/calculator/clipboard/emoji/web only.
- **Entire daily two-agent workspace implementation:** named/icon Kitty windows, one-click privileged-mode agent launchers, preset directories, file viewer/search, click-through paths, Git summaries, agent-session status, and effortless movement in/out.
- **Dedicated process workspace integration.** Caelestia btop is a component, not the complete named workspace and bar routing.
- **Kitty UX beyond colors:** Ctrl+T, reopen-tab binding, 10k scrollback, clickable editor paths, named/icon windows, startup art, find-file, and session restore are not sourced by these five reports.
- **Thunar vs Nemo vs Nautilus evidence.** There is no full visual/functional comparison, and thumbnails/automount/trash are unverified.
- **Desktop and file-manager right-click coverage.** Only tray/task contexts are solved.
- **Clickable media source-app icon.** All reports explicitly lack a complete MPRIS identity→desktop-entry→launch path.

### Input/window defect gaps

- `disable_while_typing` empirical fix without regressing tap-to-click/two-finger scroll.
- Progressive, sane Backspace/Delete repeat delay/rate.
- Cross-application scroll-speed normalization, especially Chrome.
- Pinch gesture behavior and the final four-finger map.
- Root cause of third+ window resizing/closing another window.
- Bidirectional corner resize failure.
- Broken Workspace 2 target in the current system.
- Exact Kitty/Hyprland confirmation responsible for agent terminals that cannot close themselves.
- A sourced focus policy that coexists with per-window controls and avoids hover-targeting errors.

### Visual/palette/integration gaps

- **Exact target-quality diffuse radial aurora implementation.** The five reports supply depth pieces, but not the ML4W-class community gradient artifact named in the master map.
- **True global atomic theme transaction.** iNiR and Caelestia atomically write individual files, but neither commits wallpaper, shell and every app as one recoverable state.
- **Final palette-generator choice.** Matugen custom-color behavior must be verified; hellwal fallback and gowall inverse path are accepted candidates but are not evaluated in these five reports.
- **Semantic notification suppression** for routine network/boot events. Every complete notification source still lacks the precise rule layer.
- **External/internet speed truth.** Caelestia/KDE/iNiR can show local interface throughput; none provides a sourced WAN speed-test model. Product wording must distinguish live traffic, link rate, and measured internet speed.
- **Iris Plus recorder backend evidence.** All strongest recorder UIs currently front `gpu-screen-recorder`; wf-recorder/OBS alternatives are not compared here.
- **Hyprland native glow configuration** appropriate to the target palette/hardware. The capability is an accepted finding, not a researched visual preset.
- **Chrome VA-API Nix implementation details** are accepted as a needed fix but not supplied by these five reports.
- **Complete Papirus integration across every custom shell control.** Token replacement is clear; actual app/source icon fallbacks and symbolic recoloring need verification.

### Functional gaps inside otherwise selected components

- **Network:** safe credential API availability in the exact packaged QuickShell, captive portal/connectivity semantics, and distinction among live traffic/link/WAN rate.
- **Bluetooth:** interactive passkey/confirmation behavior and target-device battery/profile verification.
- **Screen recording:** chosen encoder/backend, crash recovery for temporary audio nodes, and measured CPU/GPU impact.
- **Wallpaper:** the strict transaction coordinator and generator-version resolution.
- **Notifications:** durable storage format/cap and semantic filters.
- **Top bar:** actual workspace drop payload and source-app resolver.
- **System monitor:** process-workspace shell integration and distinct CPU/RAM target views.
- **File manager:** selection and functional integration.
- **Lock:** what Hyprlock can reproduce from ilyamiro's choreography without introducing another executable lock layer.
- **App install inventory:** a working GUI install/update route for every §13 app.

## Conflicts & Decisions Needed

These are genuine competing approaches or unresolved ownership choices; they cannot all be active simultaneously.

1. **Dock code owner — iNiR vs DankMaterialShell.** iNiR is fully researched and supplies every functional dock behavior. DankMaterialShell is the master document's prior leading candidate but is not evaluated in these five reports. Current recommendation: iNiR provisionally. Decision: accept iNiR now or require an equivalent DMS source pass before ownership is fixed.

2. **Launcher packaging boundary — coherent Caelestia slice vs configured Caelestia shell with unused modules disabled.** The isolated slice still brings Config, controls, AppDb, Qalculator and native plugin pieces; running the packaged shell reduces extraction risk but imports more shell authority. The visual/behavior choice is already Caelestia; the unresolved decision is dependency ownership.

3. **Notification service owner — Caelestia vs iNiR.** Only one `NotificationServer` can own the bus. Recommendation: Caelestia service/model/UI as owner, port iNiR ingress limiting/suppression policies into it. Choosing two running services is invalid.

4. **Audio service owner — iNiR vs Caelestia.** Both offer mature PipeWire/native layers. Recommendation: iNiR because it already has per-app streams, EasyEffects virtual-sink awareness and one shared Cava lifecycle. If the Caelestia native plugin is already retained for the launcher/media, reusing its audio provider may reduce dependency duplication; this is a closure/ownership tradeoff.

5. **Network service API — QuickShell 0.3 native Networking vs safe nmcli stdin/secret-agent fallback.** Native service is the cleaner recommendation. The exact packaged QuickShell capability decides whether that path exists; argv passwords are not an option.

6. **File manager — themed Thunar vs Nemo vs Nautilus.** Current evidence supports a low-cost Thunar retheme, but not a definitive usability/appearance winner. This needs a user-visible comparison after gap research, not an assumption.

7. **Recorder backend — `gpu-screen-recorder` vs wf-recorder/OBS-class source.** Ilyamiro and Caelestia provide better UIs around the former; the target hardware evidence is missing. The UI can be selected independently, but backend ownership cannot be finalized from these reports.

8. **Palette generator — Matugen vs hellwal; gowall as optional inverse.** The token/fan-out architecture is generator-independent. Matugen remains conditional on verified installed-version behavior; hellwal is the fallback. gowall is an optional preprocessing mode, not a simultaneous second palette authority.

9. **Theme fan-out owner — extracted iNiR targets vs Caelestia `theme.py`.** Running both would duplicate writes/reloads. Recommendation: iNiR is the single broad target runner; Caelestia's application-specific integrations are imported as targets under it.

10. **Glass blur budget — one scoped pass vs two scoped passes.** The visual target starts at size 12/one pass for Iris Plus. Two passes may look better but must be a measured choice; per-surface QML blur and full-screen SDF blur are excluded either way.

11. **Motion character — calm `OutCubic` vs expressive overshoot.** Recommendation: calm daily panels, with Caelestia's overshoot reserved for small spatial indicators and rare expressive transitions. If the user wants Caelestia's playful Material character, the 350/500 ms overshoot tokens become more prominent but move away from the stated dark, restrained direction.

12. **System search power — arbitrary shell-command prefix or discoverable actions only.** iNiR exposes shell commands; Caelestia defaults to structured actions. Recommendation: structured actions by default. Exposing arbitrary commands is a user choice, not a substitute for settings/files results.

13. **Bluetooth presentation — radial ilyamiro expanded view vs conventional list only.** Both can share the same iNiR/QuickShell BlueZ service. The radial view is visually distinctive but costs more; list-only is calmer and cheaper. Recommendation: conventional compact list with radial expansion on explicit detail.

14. **File/application translucency policy.** Agridyne proves content-aware chrome translucency; whole-window opacity harms video/text. Recommendation: translucent shell/browser chrome/terminal where supported, opaque normal content. Any broader compositor opacity policy needs explicit user preference.

15. **Wallpaper accent strategy.** Default: derive accents from wallpaper while pinning surfaces. Optional: use gowall to steer the wallpaper toward the selected accent family. These are different creative controls and should be user-selectable rather than both silently applied.
