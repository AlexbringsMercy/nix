# Caelestia — Complete Repo Read (shell + plugin + cli)

Extracted from the user-provided zips into `~/nix/repos/caelestia/{shell-main,plugins-main,cli-main}/` and read from disk. This supersedes every prior "the sidebar is just a notification bar" statement. See the reconciliation at the top.

## Totals (measured, `wc -l`)

| Repo | Files | Code lines (qml/cpp/hpp/h/py/js/nix/lua/shaders) |
|---|---:|---:|
| **shell-main** (`caelestia-dots/shell`) | 449 | **57,875** |
| **plugins-main** (`caelestia-dots/plugins`) | 1 | 0 — contains only `LICENSE`. The C++ plugin actually lives **inside the shell repo** at `shell-main/plugin/`. |
| **cli-main** (`caelestia-dots/cli`) | 100 | 4,918 |

The shell is ~35k lines of QML + ~15.8k lines of C++/GLSL (the `plugin/` tree) + Nix packaging. The CLI is ~4.9k lines of Python + schemes/templates.

---

## THE RECONCILIATION — why every session (including mine) got this wrong

**There are two different things both called "the sidebar," and sessions conflated them.**

1. **The code module literally named `modules/sidebar/`** — this is, verifiably, `Content.qml` = **42 lines**: one `NotifDock` + a 1px divider. It is notification history and nothing else. Files: `Wrapper.qml`(44), `Content.qml`(42), `NotifDock.qml`(210), `NotifDockList.qml`(156), `NotifGroup.qml`(248), `NotifGroupList.qml`(160), `Notif.qml`(203), `NotifActionList.qml`(203), `Props.qml`(7). Every prior session read this filename, saw "Notif*", and stopped. That narrow statement about the *file* was true.

2. **The left vertical surface you see running down every screenshot** — the icons, the live window preview, the tray menus, the drill-in submenus, the tabbed dashboard — is **NOT** that module. It is `modules/bar/` + `modules/windowinfo/` + `modules/dashboard/` + `modules/bar/popouts/` + the tray components. That surface is a full taskbar/control system.

**The failure:** answering "what is caelestia's left surface / what does caelestia do" by quoting the name of one 42-line module. That mistook a *filename* for the *surface on screen*, and it made everyone (me included) under-credit the bar, window previews, tray, and dashboard that are the actual left edge. You were right to be furious. Caelestia is a complete desktop shell — launcher, tabbed dashboard, media player with lyrics + visualizer, performance monitor, live window previews, nested system tray, notifications, OSD, session/power, utilities, a full Nexus settings center, and a QML lock screen — driven by 18 backend services and a 15.8k-line native C++ plugin.

### What each screenshot you sent actually is (code-traced)

| Your screenshot | What it shows | Code that renders it |
|---|---|---|
| `...F-WINDOW-PREVIEW.png` (feishin music app + floating preview) | **Live window-preview popout** off the left bar | `modules/windowinfo/Preview.qml` — a `ScreencopyView { live: true; captureSource: client.wayland }` real-time window capture + `WindowInfo.qml`(65)/`Details.qml`(163)/`Buttons.qml`(176), triggered from `modules/bar/components/ActiveWindow.qml`(137) via `Bar.qml`'s `checkPopout()` |
| `LOOKS-LIKE-ALOT-MORE...` (Bluetooth menu) | **Nested system-tray context menu** | `modules/bar/popouts/TrayMenu.qml`(228) — `StackView` + `QsMenuOpener`, recursive `SubMenu`, `chevron_right` drill-in. Backed by `modules/bar/components/Tray.qml`(126)/`TrayItem.qml`(34) |
| `MORE-THAN-A-F-NOTIFICATION-BAR-PROOF.png` (Dashboard/Media/Performance/Workspaces hub) | **Tabbed dashboard drawer** | `modules/dashboard/` — `Content.qml`(197), `Tabs.qml`(185), `Dash.qml`(104) with `dash/{Calendar,DateTime,Media,Resources,SmallWeather,User}.qml`, `Media.qml`, `Performance.qml`, `WeatherTab.qml` |
| `wow-app-toggles...` (Discord menu) | **Per-app tray menu** (Open/Check for Updates/Quit) | same `TrayMenu.qml` StackView |
| `wow-multiple-windows-in-a-single-sidebar.png` ("For 30 min / 1 / 2 / 3 hours / Until restart / ‹ Back") | **Drill-in submenu with Back button** | same `TrayMenu.qml` — the `‹ Back` row (chevron_left + "Back", lines 178–226) pops the StackView; this is a DND/keep-awake duration submenu of a tray item |

(Note: your dashboard shot has a **Workspaces** 4th tab; the current snapshot's 4th tab is **Weather** — a version difference. The multi-tab hub is the same thing either way.)

---

## SHELL — file-by-file (grouped; every file, with line count + role)

### Root
- `shell.qml` (42) — `ShellRoot`; instantiates background, drawers, area picker, lock, config toasts, global shortcuts, battery + idle monitors.
- `flake.nix` (65), `nix/default.nix` (180), `nix/hm-module.nix` (136) — Nix package + `programs.caelestia` Home-Manager module. `CMakeLists.txt`(94), `extras/version.cpp`(27), `extras/CMakeLists.txt`(9) — build + version string.

### `modules/bar/` — the LEFT taskbar surface (your "sidebar")
- `BarWrapper.qml` (91) — per-screen bar container, persistent-vs-hover reveal.
- `Bar.qml` (201) — the bar itself: a `ColumnLayout` of configurable entries (logo, workspaces, activeWindow, tray, clock, statusIcons, power, spacers), scroll actions (scroll workspaces / volume top-half / brightness bottom-half), and `checkPopout()`/`closeTray()` hover dispatch.
- `components/OsIcon.qml` (47) — distro/logo button. `Clock.qml` (124) — vertical clock. `Power.qml` (33) — power button → session. `ActiveWindow.qml` (137) — active-title/icon entry, opens the window-info popout. `StatusIcons.qml` (267) — audio/mic/keyboard/network/ethernet/bluetooth/battery indicators, each hover-mapped to a popout. `Tray.qml` (126)/`TrayItem.qml` (34) — SNI system tray, compact/expand.
- `components/workspaces/` — `Workspaces.qml` (152), `Workspace.qml` (117), `ActiveIndicator.qml` (100, stretchy highlight), `OccupiedBg.qml` (103, occupied-window pips), `SpecialWorkspaces.qml` (374, special/scratchpad workspaces).
- `popouts/` — the hover-popout system: `Wrapper.qml` (219) + `Content.qml` (218) + `PopoutState.qml` (8) host the popout; content types: `ActiveWindow.qml` (100), `Audio.qml` (113), `Battery.qml` (225), `Bluetooth.qml` (204), `Network.qml` (396), `TrayMenu.qml` (228, nested tray menus), `WirelessPassword.qml` (622, Wi-Fi auth flow), `LockStatus.qml` (16), `ClipWrapper.qml` (65), and `kblayout/KbLayout.qml` (210)/`KbLayoutModel.qml` (221, keyboard-layout switcher).

### `modules/windowinfo/` — live window previews (your image #2)
- `WindowInfo.qml` (65) — popout host. `Preview.qml` (96) — **live `ScreencopyView` window capture**. `Details.qml` (163) — title/monitor/geometry. `Buttons.qml` (176) — maximize/float/pin/close controls per window.

### `modules/dashboard/` — the tabbed hub (your image #4)
- `Wrapper.qml` (54), `Content.qml` (197), `Tabs.qml` (185) — top-edge drawer, tab bar (Dashboard/Media/Performance/Weather), animated indicator + swipe.
- `Dash.qml` (104) + `dash/`: `Calendar.qml` (259), `DateTime.qml` (59), `Media.qml` (180), `Resources.qml` (75), `SmallWeather.qml` (57), `User.qml` (276, avatar/system identity).
- `Media.qml` (151) + `media/`: `CoverVisualiser.qml` (82, radial cava around cover), `CoverArt.qml`(via components), `Details.qml` (194), `LyricList.qml` (327), `LyricsAndSelector.qml` (79), `LyricsInfo.qml` (208), `BackgroundShapes.qml` (97).
- `Performance.qml` (146) + `performance/`: `HeroCard.qml` (148), `MemoryCard.qml` (93), `NetworkCard.qml` (197, up/down sparklines), `StorageCard.qml` (135), `BatteryTank.qml` (147).
- `WeatherTab.qml` (278) — full weather/forecast.

### `modules/launcher/` — app/action/calc/scheme/wallpaper launcher
- `Wrapper.qml` (60), `Content.qml` (125), `AppList.qml` (305), `ContentList.qml` (170), `WallpaperList.qml` (97).
- `items/`: `AppItem.qml` (89), `ActionItem.qml` (66), `CalcItem.qml` (127), `SchemeItem.qml` (102), `VariantItem.qml` (78), `WallpaperItem.qml` (102).
- `services/`: `Apps.qml` (75, ranking via native `appdb`), `Actions.qml` (54, theme/scheme/wallpaper/lock/sleep), `Schemes.qml` (88), `M3Variants.qml` (85).

### `modules/sidebar/` — notification HISTORY (the 42-line module the name refers to)
- `Wrapper.qml` (44), `Content.qml` (**42**, just NotifDock+divider), `NotifDock.qml` (210), `NotifDockList.qml` (156), `NotifGroup.qml` (248), `NotifGroupList.qml` (160), `Notif.qml` (203), `NotifActionList.qml` (203, per-notification action buttons), `Props.qml` (7, persists expanded groups).

### `modules/notifications/` — transient popup cards
- `Wrapper.qml` (24), `Content.qml` (220), `Notification.qml` (525, styled card w/ actions, image, swipe-dismiss).

### `modules/utilities/` — right-edge cards (Keep-Awake / Recorder / Toggles)
- `Wrapper.qml` (91), `Content.qml` (78), `Background.qml` (54).
- `cards/`: `IdleInhibit.qml` (121, keep-awake w/ duration submenu — matches your image #6 pattern), `Record.qml` (291), `RecordingList.qml` (238), `Toggles.qml` (163, Wi-Fi/BT/mic/DND/game-mode toggles).
- `RecordingDeleteModal.qml` (215), `toasts/Toasts.qml` (154), `toasts/ToastItem.qml` (135).

### `modules/nexus/` — full settings / control center (43 files)
- Shell: `Nexus.qml` (113), `NexusState.qml` (36), `NavPane.qml` (50), `navpane/NavLocations.qml` (134), `Pages.qml` (96), `PageRegistry.qml` (93), `PageCompRegistry.qml` (221), `WindowFactory.qml` (60).
- `common/` (reusable rows/controls, 21 files): `AnimatedLogo.qml` (513), `ToggleRow.qml` (83), `SliderRow.qml` (89), `SelectRow.qml` (66), `StepperRow.qml` (66), `PopupRow.qml` (122), `NavRow.qml` (72), `InfoRow.qml` (80), `ItemList.qml` (121), `NetworkList.qml` (176), `AudioDeviceList.qml` (97), `EthernetSection.qml` (257), `WallItem.qml` (105), `StackPage.qml` (122), `PageBase.qml` (78), `BlobPopup.qml` (127), `ConnectedRect.qml` (15), `SectionHeader.qml` (18), `NavRow`/`SelectRow` etc.
- `pages/`: `AppsPage.qml` (174) + `apps/{AllApps(101),AppInfo(171)}`, `AudioPage.qml` (130) + `audio/AppVolumes(70)`, `BluetoothPage.qml` (245) + `bluetooth/{BluetoothPairing(193),BtDeviceInfo(257)}`, `NetworkPage.qml` (461) + `network/{NetworkDetailPage(486),EthernetDetailPage(348),AddNetworkPage(253),AddVpnPage(223),AllNetworksPage(168),SavedNetworksPage(116)}`, `WallpaperAndStyle.qml` (198) + `wallandstyle/{WallpaperSelect(188),WallpaperCategory(53),ColourSelect(47)}`, `ServicesPage.qml` (227) + `services/NotificationsPage(191)`, `PanelsPage.qml` (53) + `panels/{DashboardPanel,LauncherPanel,SidebarPanel,UtilitiesPanel,TaskbarPanel}` and `panels/taskbar/{BarActiveWindow,BarClock,BarStatusIcons,BarTray,BarWorkspaces}`, `LanguageAndRegion.qml` (172), `AboutPage.qml` (157).

### `modules/lock/` — QML lock screen (24 files)
- `Lock.qml` (74), `LockSurface.qml` (225), `Content.qml` (60), `Center.qml` (53) + `center/{Clock(93),InputField(236),PasswordInput(168),ProfilePic(56),StateMessage(233)}`, `Pam.qml` (292, PAM/fingerprint/face auth), `Fetch.qml` (179), `Media.qml` (111), `Resources.qml` (183), `NotifDock.qml` (142), `NotifGroup.qml` (343), `WeatherInfo.qml` (53) + `weather/{BriefInfo(63),Forecast(105)}`.

### Other modules
- `drawers/` — the shared full-screen coordinator: `ContentWindow.qml` (349, `HyprlandFocusGrab` click-away + input-region mask), `Panels.qml` (155), `Interactions.qml` (313, edge hover/swipe), `Regions.qml` (84), `Exclusions.qml` (40), `Drawers.qml` (26).
- `osd/` — `Wrapper.qml` (113), `Content.qml` (132) volume/brightness/mic OSD.
- `session/` — `Wrapper.qml` (40), `Content.qml` (172) power/lock/logout/reboot/shutdown.
- `background/` — `Background.qml` (165), `Wallpaper.qml` (134), `DesktopClock.qml` (161), `Visualiser.qml` (94, optional desktop audio-reactive bg).
- `areapicker/` — `AreaPicker.qml` (133), `Picker.qml` (304) region/screenshot picker.
- `Shortcuts.qml` (172), `IdleMonitors.qml` (77), `BatteryMonitor.qml` (57), `ConfigToasts.qml` (39), `GSFLoader.qml` (6).

### `components/` — shared UI kit (60 files)
- Animation: `Anim.qml` (63), `AnimLoader.qml` (42), `AnchorAnim.qml` (51), `CAnim.qml` (7, color-anim), `StateLayer.qml` (198, Material hover/ripple).
- Primitives: `StyledText.qml` (40), `StyledRect.qml` (11), `StyledClippingRect.qml` (12), `MaterialIcon.qml` (11), `Logo.qml` (70), `ScreenState.qml` (18).
- `controls/` (29 files): `ButtonBase`, `IconButton`, `IconTextButton`, `TextButton`, `SplitButton`, `Menu`(198)/`MenuItem`, `SearchBar`(99), `StyledTextField`(299), `TextFieldBase`, `StyledSlider`(193)/`FilledSlider`(128)/`StyledSpinBox`(152)/`StyledSwitch`(172)/`StyledRadioButton`, `StyledScrollBar`(192)/`StyledProgressBar`(247), `CircularProgress`(122)/`CircularIndicator`(110)/`LoadingIndicator`(116), `CustomMouseArea`.
- `containers/` (5): `StyledFlickable`, `StyledListView`, `StyledWindow`, `VerticalFadeFlickable`(72), `VerticalFadeListView`(73).
- `effects/` (4): `ColouredIcon`, `Colouriser`, `Elevation`, `Mask`.
- `images/` (3): `CachingIconImage`, `CachingImage`, `FadeImage`(75).
- `filedialog/` (8): `FileDialog`(105), `FolderContents`(224), `HeaderBar`(140), `Sidebar`(114), `CurrentItem`(102), `DialogButtons`(90), `Sizes`.
- `widgets/` (3): `CoverArt`(107), `ExtraIndicator`(51), `WavyTopRect`(47).
- `misc/`: `CustomShortcut`, `Ref`.

### `services/` — 18 backend singletons
`Audio.qml`(192, PipeWire), `Brightness.qml`(237, DDC/backlight), `Colours.qml`(306, semantic palette + live reload + CAnim), `GameMode.qml`(76), `Hypr.qml`(229, Hyprland IPC + Lua/keyword dispatch), `IdleInhibitor.qml`(56), `NetworkUsage.qml`(229, /proc/net/dev rates), `Nmcli.qml`(**1780**, NetworkManager wrapper — has the argv-password issue), `NotifData.qml`(243), `Notifs.qml`(174, NotificationServer + history/DND), `Players.qml`(183, MPRIS), `Recorder.qml`(82, gpu-screen-recorder), `Screens.qml`(14), `ShellState.qml`(100), `Time.qml`(29), `VPN.qml`(961), `Wallpapers.qml`(125), `Weather.qml`(282).

### `utils/`
`Icons.qml`(252), `Paths.qml`(38), `Images.qml`(12), `NetworkConnection.qml`(116), `Searcher.qml`(55), `Strings.qml`(26), `SysInfo.qml`(138), `scripts/fzf.js`(1307) + `scripts/fuzzysort.js`(705, fuzzy search engines).

### `plugin/` — native C++/QML plugin (~15.8k lines)
- `Config/` (typed live config, 40 files): `rootconfig.cpp`(312)/`.hpp`, `config.cpp`(119), `configobject.cpp`(320), `configattached.cpp`(96), plus one header per surface — `barconfig.hpp`(166), `launcherconfig.hpp`(135), `dashboardconfig.hpp`, `sidebarconfig.hpp`(21), `notifsconfig.hpp`, `osdconfig.hpp`, `sessionconfig.hpp`, `utilitiesconfig.hpp`(89), `winfoconfig.hpp`, `backgroundconfig.hpp`(84), `generalconfig.hpp`(109), `serviceconfig.hpp`, `nexusconfig.hpp`, `lockconfig.hpp`, `borderconfig.hpp` — and `appearanceconfig.cpp`(206)/`.hpp`(330), `tokens.hpp`(390)/`tokensattached.cpp`(130), `anim.cpp`(117), `font.cpp`(269)/`fontbuilder.cpp`(92), `monitorconfigmanager.cpp`(64), `userpaths.hpp`.
- `Services/` (native sensors + audio, 30 files): `cpu.cpp`(117), `memory.cpp`(58), `gpu.cpp`(360), `storage.cpp`(330), `diskinfo.cpp`(67), `sensorslib.cpp`(166), `audiocollector.cpp`(262), `audioprovider.cpp`(81), `cavaprovider.cpp`(143), `beattracker.cpp`(60), `lyrics.cpp`(**1067**)/`lyriccandidate.cpp`(65), `sessionmanager.cpp`(204), `tickingservice.cpp`(51), `service.cpp`/`serviceref.cpp`/`usagefmt.cpp`.
- `Blobs/` (SDF drawer geometry + shaders): `blobshape.cpp`(415), `blobrect.cpp`(305), `blobinvertedrect.cpp`(184), `blobgroup.cpp`(112), `blobmaterial.cpp`(102), `shaders/blob.frag`(269)/`blob.vert`(29).
- `Components/`: `lazylistview.cpp`(**1108**), `wavyline.cpp`(255), `buttonrow.cpp`(132).
- `Internal/`: `sparklineitem.cpp`(216), `circularindicatormanager.cpp`(217), `visualiserbars.cpp`(198), `hyprextras.cpp`(228), `hyprdevices.cpp`(134), `linearindicatormanager.cpp`(119), `circularbuffer.cpp`(94).
- `Models/`: `filesystemmodel.cpp`(458). `Images/`: `imagecacher.cpp`(159), `cachingimageprovider.cpp`(120), `iutils.cpp`(42).
- Root: `appdb.cpp`(324, SQLite app frequency ranking), `qalculator.cpp`(148, libqalculate), `imageanalyser.cpp`(231), `cutils.cpp`(225), `requests.cpp`(58), `toaster.cpp`(115).

---

## CLI — file-by-file (100 files, ~4.9k Python)
- Entry: `__init__.py`(16), `__main__.py`(4), `parser.py`(206, arg parser).
- `subcommands/`: `install.py`(266), `update.py`(260), `shell.py`(63, start/kill shell + IPC), `toggle.py`(164, toggle drawers), `scheme.py`(120), `wallpaper.py`(21), `screenshot.py`(67), `record.py`(140), `clipboard.py`(25, cliphist→fuzzel), `emoji.py`(94), `resizer.py`(481, image resize/crop).
- `utils/`: `theme.py`(478, app-wide palette fan-out), `scheme.py`(247), `wallpaper.py`(222, thumbnail analysis + mode/variant), `colour.py`(28)/`colourfulness.py`(41), `hypr.py`(71), `io.py`(139), `paths.py`(85), `version.py`(77), `notify.py`(20).
- `utils/material/`: `generator.py`(278, Material palette gen), `score.py`(70), `__init__.py`(51).
- `utils/dots/`: `manifest.py`(231), `packages.py`(268), `deployer.py`(84), `diff.py`(153), `source.py`(123), `legacy.py`(100), `state.py`(58), `misc.py`(39).
- `data/schemes/` (bundled palettes) + `data/templates/` (per-app output templates), `completions/caelestia.fish`(140), `default.nix`(87), `flake.nix`(41), `pyproject.toml`(28).

---

## CAPABILITIES & CONTROL SURFACE (verified by reading the code, not filenames)

These are things caelestia *does* that a file listing doesn't make obvious — confirmed by reading the relevant files this session.

### Scriptable IPC API — 13 targets (`caelestia shell ipc call <target> <function> [args]`)
The entire shell is drivable from scripts/keybinds. Handlers found in `modules/Shortcuts.qml`, `modules/areapicker/AreaPicker.qml`, `modules/lock/Lock.qml`, and the `services/*` singletons:

| Target | Functions |
|---|---|
| `mpris` | `getActive(prop)`, `list()`, `play()`, `pause()`, `playPause()`, `previous()`, `next()`, `stop()` |
| `brightness` | `get()`, `getFor(query)`, `set(value)`, `setFor(query,value)` — **per-monitor** |
| `notifs` | `clear()`, `isDndEnabled()`, `toggleDnd()`, `enableDnd()`, `disableDnd()` |
| `audio` | `cycleOutput()` |
| `hypr` | `refreshDevices()`, `cycleSpecialWorkspace(direction)`, `listSpecialWorkspaces()` |
| `gameMode` | `isEnabled()`, `toggle()`, `enable()`, `disable()` |
| `idleInhibitor` | `isEnabled()`, `toggle()`, `enable()`, `disable()` |
| `wallpaper` | `get()`, `set(path)`, `list()` |
| `lock` | `lock()`, `unlock()`, `isLocked()` |
| `picker` | `open()`, `openFreeze()`, `openClip()`, `openFreezeClip()` — screenshot: live region / frozen-frame region / straight-to-clipboard |
| `drawers` | `toggle(drawer)`, `list()`, `isOpen(drawer)` — drawers: `bar, osd, session, launcher, dashboard, utilities, sidebar` |
| `nexus` | `open()` |
| `toaster` | `info(title,msg,icon)`, `success(...)`, `warn(...)`, `error(...)` — programmatic in-shell toasts scripts can raise |

### Built-in global shortcuts — 22 (`modules/Shortcuts.qml` + `modules/utilities/Content.qml`)
`nexus` (open settings) · `showall` (toggle launcher+dashboard+osd) · `dashboard` · `session` · `launcher` · `launcherInterrupt` · `sidebar` · `utilities` · `screenshot` · `screenshotFreeze` · `screenshotClip` · `screenshotFreezeClip` · `lock` · `unlock` · `mediaToggle` · `mediaPrev` · `mediaNext` · `mediaStop` · `refreshDevices` · `brightnessUp` · `brightnessDown` · `clearNotifs`. (These are `CustomShortcut`s registered under app id `caelestia.qml.shortcuts`; the Hyprland side binds keys to the matching IPC globals.)

### Subsystems deeper than their names suggest
- **Multi-provider VPN manager** — `services/VPN.qml` (961 lines): separate adapters for **WireGuard, Cloudflare WARP, NetBird, Tailscale**; add/update/delete/select/connect providers, persisted config; full "Add VPN" flow in Nexus (`pages/network/AddVpnPage.qml`).
- **Time-synced lyrics** — `plugin/src/Caelestia/Services/lyrics.cpp` (1067 lines): fetches synced (LRC) lyrics from **LRCLIB and NetEase** with proper headers/referer, candidate search, backend fallback; rendered by `dashboard/media/LyricList.qml`.
- **Own file dialog + live filesystem model** — `plugin/.../Models/filesystemmodel.cpp` (458 lines): `QFileSystemWatcher`-backed, recursive-watch, async futures; powers `components/filedialog/*` (caelestia ships its own file picker).
- **Keyboard-layout switcher** — `modules/bar/popouts/kblayout/KbLayout.qml` (210) + `KbLayoutModel.qml` (221): lists xkb layouts, click to switch.
- **GUI-configurable shell** — Nexus `PanelsPage` + `panels/taskbar/{BarActiveWindow,BarClock,BarStatusIcons,BarTray,BarWorkspaces}`: toggle/reorder the bar entries, sidebar, launcher, and utilities from a settings GUI, no config-file editing.
- **Wi-Fi auth flow in the bar** — `bar/popouts/WirelessPassword.qml` (622): full password-entry connection flow from the tray/status popout.
- **Native perf/audio pipeline** — GPU sensor (`Services/gpu.cpp` 360), **beat tracker + cava + audio-collector** (`beattracker.cpp`/`cavaprovider.cpp`/`audiocollector.cpp`), `LazyListView` (1108 lines, scroll perf), `sparklineitem`/`wavyline` (native sparklines + animated seek bar), SDF **Blob shaders** (`Blobs/shaders/blob.frag`) that morph panels out of the screen border.
- **Screenshot/area tooling** — `modules/areapicker/` (region + frozen-frame + clipboard modes), plus the CLI: image **resizer/cropper** (`resizer.py` 481), **emoji picker** (`emoji.py` 94), clipboard history (`clipboard.py`).
- **GameMode service** (`services/GameMode.qml`), **idle inhibitor with duration submenu** (`utilities/cards/IdleInhibit.qml`), **weather + forecast** (`services/Weather.qml` 282 + `WeatherTab.qml` 278).

## Bottom line
Caelestia is a **complete desktop shell**. The left surface alone does live window previews (`ScreencopyView`), a nested DBus system-tray with drill-in submenus, and a tabbed dashboard — plus a launcher, notifications, OSD, session, utilities, a full Nexus settings center, and a QML lock, over 18 services and a 15.8k-line C++ plugin. The only thing that was ever "just a notification drawer" is the single 42-line `modules/sidebar/Content.qml` — and that filename should never again be used to describe what caelestia is or what its left edge does.
