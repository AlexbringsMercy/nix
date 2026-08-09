# Caelestia — Full Research

## Repo overview

Caelestia is not one monolithic repository. The main repository is a desktop-configuration bundle and installer manifest; its two most important runtime dependencies are separate repositories containing the QuickShell shell and the `caelestia` CLI. A full read therefore has to treat all three as one product.

Research snapshot:

| Source | Snapshot read | Role |
|---|---|---|
| `caelestia-dots/caelestia` | `2e5598c627734cc87089d5ea570e80db558a04f7` (2026-06-30) | Desktop configs, Hyprland Lua, app themes, component manifest |
| `caelestia-dots/shell` | `dbb6d6c029021145422255dee6cd7ba607be3a20` (2026-07-16) | QuickShell UI, services, native Qt/C++ plugin, Nix packaging |
| `caelestia-dots/cli` | `a4b4ccdf165540aa1eacd7fa588ecfca261b74dc` (2026-07-17) | Install/deploy, wallpaper and palette generation, theme fan-out, capture and recording helpers |

Upstream URLs:

- <https://github.com/caelestia-dots/caelestia>
- <https://github.com/caelestia-dots/shell>
- <https://github.com/caelestia-dots/cli>

The stack is Hyprland + QuickShell/Qt 6, with a custom C++ QML plugin. The main repository currently uses a modular Lua Hyprland configuration, which makes it unusually close to the target stack. The shell uses current QuickShell APIs for layer surfaces, Hyprland focus grabs, MPRIS, PipeWire, notifications, Bluetooth, system tray, and persistent QML state. The CLI is Python and generates palette-specific configuration for the shell, Hyprland, applications, and terminal tools.

The main repository had 95 tracked files at the snapshot. It is the integration layer rather than the bulk of the implementation: it contains Hyprland rules/keybinds, Fish, Foot, Fastfetch, btop, Thunar, Firefox, VS Code, Zed, Zen, Spicetify, Starship, UWSM, and the package/component manifest. The shell is much larger: about 37,000 lines of QML plus about 15,800 lines of C/C++ across a native plugin. The CLI is roughly 4,800 lines of Python plus palette templates and predefined schemes.

The default installation story is Arch-oriented, but the shell companion has first-class Nix packaging and a Home Manager module. Its flake follows `nixos-unstable`, pins a QuickShell git input, and offers a `with-cli` package because the shell requires the CLI for full functionality. This makes the shell viable on NixOS without adopting the main repository's package installer.

One source-truth correction matters for the later synthesis. The guide describes a hover popout top bar with a clickable Spotify source icon and a three-module sidebar. That description does not match the current main branches. The current persistent bar is a slim left vertical taskbar. Media is in a top-edge dashboard drawer, and its MPRIS service has player identity and player selection but no code that opens the source application. The current `modules/sidebar` is notification history. A visually joined right-edge composite also includes transient notifications and a utilities drawer, but it is not a pinned/running application dock. These may describe an older Caelestia revision or a visual interpretation of several joined surfaces; they are not features present in the snapshot read here.

## Visual impression

I viewed the official 49-second 1920×1080 showcase video linked from the shell README, both as a contact sheet and as individual full frames, as well as the repository wallpaper and image assets.

The shell is genuinely polished. Its defining visual device is not ordinary floating glass rectangles; it is a rounded border around the entire usable screen whose panels appear to grow out of the screen edge. A narrow vertical taskbar sits inside the left border. Opening the dashboard makes a broad, organically rounded shape bulge down from the top border; the launcher rises from the bottom border; notifications, OSD, and utilities deform the right border. This makes all shell surfaces feel physically related.

The showcase alternates between two strong looks:

- A light blush/cream theme over a mostly white ink-style wallpaper. Panels are pale pink/cream with subdued red accents and very little visual harshness. The dashboard, launcher, taskbar, and themed Spotify all match.
- A dark wallpaper-driven theme with near-black purple surfaces and vivid magenta, violet, and blue accents. The wallpaper remains visibly present behind the transparent terminal and launcher. This is much closer to the target's dark blue/purple direction, though the stock result is more pink and more wallpaper-variable than the pinned deep-blue surface system required by §3.

The top dashboard has excellent information composition. The overview combines weather, date/time, calendar, user/system identity, circular album art, and resource meters without looking like a dense admin dashboard. Other tabs show a large media view with radial audio visualization around circular album art, a performance view with circular meters and cards, and a weather view. The cards are spacious and consistently rounded.

The official Spotify frame is important evidence for §4.17: Spotify is not merely recolored at the edges. Its main background, side navigation, cards, active controls, search area, player chrome, and accent colors all visibly follow the same cream/pink palette as the shell. The source implementation confirms Spicetify palette generation plus a custom CSS layer.

The launcher is visually clean. It is a bottom-centered rounded surface with one search row and a compact result list. Application results use a real icon, name, secondary description, and favorite control. In wallpaper mode it becomes a horizontal thumbnail carousel with a dark scrim. The carousel is flat perspective with scale emphasis, not the 3D tilted Cover Flow required elsewhere in §6. In the dark frames the launcher reads as translucent near-black glass with the wallpaper visible behind it; in the light frames it reads as a soft opaque material card.

Right-edge UI is tasteful and restrained. Notifications emerge as small cards from the right border. OSD volume/brightness controls form compact rounded lobes instead of giant center-screen overlays. The notification history and bottom utilities can visually attach into a longer right-side surface. This is good organization language for the target's second UI surface, but it does not visually or functionally behave like an application dock.

Motion in the video is one of the build's strengths. Panels do not simply fade in. They stretch from an edge, their rounded background deforms, their content fades/slides, and the edge settles with a slight expressive overshoot. Dashboard tab changes and media controls remain smooth. The result feels like high-quality Material 3 Expressive rather than ilyamiro's slower cinematic multi-view morphing. It is professional and cohesive, but playful and springy where the target calls for a darker, calmer aurora character.

Overall quality assessment: excellent shell UI, excellent cohesion within its own design system, and unusually complete OS-facing services. Its highest-value contributions are interaction mechanics, notification grouping, app-theme propagation, animation tokens, and the launcher. Its screen-border/blob architecture and light Material styling are distinctive but should not be adopted wholesale for the independent glass `PanelWindow` dashboard architecture specified in §2 and §6.

## Structure

### Main repository

```text
caelestia/
├── README.md
├── manifest.json                 component/package installer manifest
├── hypr/
│   ├── hyprland.lua              modular Lua entry point
│   ├── hyprland/*.lua            env, input, decoration, animation, rules,
│   │                              gestures, keybinds, autostart
│   └── scheme/                   generated/current color modules
├── firefox/                      browser chrome, extension, native bridge
├── vscode/                       palette-watching extension and generated theme
├── spicetify/Themes/caelestia/   Spotify CSS
├── btop/ fastfetch/ fish/ foot/ micro/ starship/
├── thunar/                       file-manager CSS and preferences
├── zed/ zen/                     editor/browser integration
├── uwsm/
└── packages/                     Firefox theme package integration
```

`manifest.json` is the orchestration point. Its default components install the shell and CLI plus Hyprland, Fish, Foot, Fastfetch, btop, Micro, Thunar, Starship, Firefox, GTK/Qt styling, authentication, NetworkManager, BlueZ, PipeWire, clipboard tools, fonts, and command-line utilities. Optional components add Spotify/Spicetify, VS Code or VSCodium, Zed, Discord via Equibop, Todoist, UWSM, and Zen. Spotify setup selects the Caelestia Spicetify theme and palette and applies it.

The Hyprland Lua entry point loads a generated scheme and then separate modules for variables, environment, general behavior, input, decoration, animation, groups, startup, window/layer rules, gestures, and keybinds. This is clean and compatible with the target's exact-config invariant: individual tables can be compared or adapted without replacing the whole active Lua configuration.

### Shell repository

```text
shell/
├── shell.qml                     ShellRoot composition
├── modules/
│   ├── drawers/                  shared surface, regions, focus, interactions
│   ├── bar/                      left vertical taskbar and popouts
│   ├── launcher/                 apps/actions/calculator/wallpapers/schemes
│   ├── dashboard/                overview, media, performance, weather
│   ├── notifications/            transient notification cards
│   ├── sidebar/                  grouped notification history
│   ├── utilities/                inhibit, recorder, quick toggles
│   ├── osd/ session/ windowinfo/
│   ├── background/ areapicker/ lock/
│   └── nexus/                    full settings/control-center window
├── services/                     shell-facing service singletons
├── components/                   styled controls, containers, effects, images
├── utils/                        icons, network connection, resource helpers
├── plugin/src/Caelestia/
│   ├── Blobs/                    SDF blob geometry and shaders
│   ├── Config/                   live config, tokens, monitor overrides
│   ├── Services/                 audio/cava/beat/system/lyrics services
│   ├── Internal/                 buffers, indicators, Hypr helpers, sparklines
│   ├── Components/ Models/ Images/
│   └── appdb.*, qalculator.*     launcher ranking and calculator
└── nix/                          package and Home Manager module
```

`shell.qml` instantiates the background, drawers, area picker, lock, configuration toasts, global shortcuts, battery monitor, and idle monitors. `modules/drawers/ContentWindow.qml` is the central coordinator. Per monitor it creates one full-screen QuickShell layer surface named `drawers`, then uses an input region mask so only the visible border, bar, and panel areas receive pointer input.

All major edge panels live inside that one window. `modules/drawers/Panels.qml` positions the top dashboard, bottom launcher, right session panel, center-right sidebar, right OSD, top-right notifications, bottom-right utilities, and left taskbar popouts. `ScreenState.qml`/`services/ShellState.qml` hold per-screen open/closed state. `Interactions.qml` supplies edge hover and swipe thresholds. `Regions.qml` and `Exclusions.qml` compute input and reserved areas.

This coordination is why the visual edge deformations work so well. It is also the major architectural mismatch with §2 and §6: these are not independent `PanelWindow` surfaces. Porting a single panel out of this shell means replacing assumptions about shared geometry, SDF backgrounds, screen state, configuration, and input regions.

### CLI repository

```text
cli/src/caelestia/
├── subcommands/
│   ├── install.py update.py shell.py toggle.py
│   ├── wallpaper.py scheme.py
│   ├── screenshot.py record.py clipboard.py emoji.py
│   └── resizer.py
├── utils/
│   ├── theme.py wallpaper.py scheme.py colour.py colourfulness.py
│   ├── material/                 palette generation/scoring
│   ├── dots/                     manifest/deploy/state/diff/package handling
│   └── hypr.py paths.py io.py notify.py
└── data/
    ├── schemes/                  Caelestia and many named palettes
    └── templates/                app/tool output templates
```

The important runtime flow is:

```text
wallpaper selection
  → thumbnail analysis and light/dark + variant choice
  → Material palette generation
  → ~/.local/state/caelestia/scheme.json
  → QuickShell FileView reload + animated semantic colors
  → theme.py fans the same roles out to apps and tools
```

Most individual target files are written atomically, and a file lock prevents two theme changes from running concurrently. The complete multi-application update is sequential, however, so it is not a single all-or-nothing transaction.

## Component inventory

### Desktop integration and Hyprland configuration

- `main/manifest.json`: declarative component catalog, package groups, install/post-install hooks, optional applications, and dependencies. It explains how the three repositories are meant to become a desktop. Useful as an inventory, not as a NixOS deployment source, because its primary package flow assumes Arch/AUR.
- `main/hypr/hyprland.lua` and `main/hypr/hyprland/*.lua`: clean modular Lua configuration. Blur defaults to enabled, size 8, two passes, `xray = false`; window opacity is 0.95; rounding is 15; borders are 1 px; shadows use range 15/power 4. Startup includes polkit, keyring, two `cliphist` watchers, geoclue/gammastep, MPRIS proxy, trash maintenance, and the shell. The syntax is directly relevant to Hyprland 0.55 Lua.
- `main/hypr/hyprland/keybinds.lua`: dispatches shell global shortcuts, capture/record commands, clipboard, window operations, and named special workspaces. The launcher binding is Super/Super_L rather than Cmd+Space, so §5 and §6 require a binding change. Bar and shell launches use detached QuickShell/CLI calls where needed.
- `main/hypr/hyprland/gestures.lua`: four-finger horizontal workspace, three-finger special-workspace gestures, and a four-finger sleep action. This is partial reference material for §4.8; it does not solve pinch behavior.
- `main/hypr/hyprland/rules.lua`: modern Lua window/layer rules, shell tagging, opacity, special-workspace placement, and XWayland popup matching. It is useful as syntax reference but contains Caelestia-specific namespaces/classes.

### Shared drawer coordinator and click-away behavior

- `shell/modules/drawers/ContentWindow.qml`: the most valuable interaction file. `HyprlandFocusGrab.active` becomes true for the launcher, session panel, sidebar, a click-open dashboard, and deep tray menus. Its `onCleared` handler closes launcher, session, sidebar, dashboard, current popout, and tray menu. This is exact, verified click-away behavior for §2, §5, and §6. Escape is also wired within panels.
- `shell/modules/drawers/Interactions.qml`: supports mouse hover and touch/trackpad edge gestures. Default drag thresholds are approximately 50 px for launcher/dashboard and 80 px for sidebar. It also opens taskbar popouts by hovering the corresponding item. This is a strong progressive-disclosure pattern under §2.
- `shell/modules/drawers/ContentWindow.qml` plus `plugin/src/Caelestia/Blobs/*`: all surfaces share an SDF `BlobGroup`, `BlobRect`, and `BlobInvertedRect`. The GLSL-backed geometry lets panels merge into the screen border and deform as they enter. The implementation is sophisticated and tightly coupled.
- `shell/components/ScreenState.qml` and `shell/services/ShellState.qml`: per-monitor state registry. This is a good coordinator pattern, though the target wants independent surfaces rather than one physical layer window.

### Launcher

- `shell/modules/launcher/Wrapper.qml`: bottom-center geometry, open/close offset, opacity, margins, and keyboard focus. It is embedded in the drawer surface rather than being an independent window.
- `shell/modules/launcher/Content.qml`: search field, keyboard navigation, result cap, mode/prefix parsing, and result list. The default visible maximum is seven results; result rows are about 600×57 logical pixels. Up/down, Enter, and Escape work, with optional Vim bindings.
- `shell/modules/launcher/AppList.qml` and `ContentList.qml`: application filtering and animated result-container sizing. Search is live as the user types. App modes include normal fuzzy search and field prefixes for ID, category, description, executable, startup class, generic name, keywords, and terminal apps.
- `shell/modules/launcher/items/AppItem.qml`: real desktop-entry icon, name, comment, and favorite affordance. Activation uses the desktop entry's execute function or a terminal wrapper, then closes the launcher. Execution is detached, directly addressing the process-lifetime defect in §5.
- `shell/plugin/src/Caelestia/appdb.*`: SQLite-backed frequency data and app ranking. This is more capable than a simple `DesktopEntries.applications` filter and helps frequently used applications rise naturally.
- `shell/plugin/src/Caelestia/qalculator.*`: native libqalculate integration. The action prefix supports calculator results alongside apps.
- `shell/modules/launcher/services/Actions.qml`: actions for theme mode, scheme, wallpaper, random wallpaper, lock/sleep, and optional dangerous power actions. Dangerous actions are disabled by default. This gives the launcher limited settings/actions search relevant to §4.11, but it is not system-wide file search.
- `shell/modules/launcher/WallpaperList.qml`: horizontal `PathView` with current-item scale and opacity. It is visually good enough for an in-launcher preview but lacks the 3D tilt and swatch interaction of the required wallpaper picker. §6 explicitly retains skwd-wall, so this is not a replacement.

Portability assessment: the launcher is the best functional match in this repository, but it is not a five-file drop-in. It imports Caelestia Config, Components, service singletons, Material shapes, AppDb, Qalculator, image caching, and shared screen state. The practical source choices are either the packaged shell with unused modules disabled, or a coherent launcher slice including its native plugin and shared controls. The visuals and focus-grab pattern are highly reusable; isolated QML copying would be brittle.

### Sidebar and the actual right-edge composite

- `shell/modules/sidebar/Wrapper.qml`: a 430-logical-pixel right-edge drawer. It can appear by explicit action/swipe; `showOnHover` defaults to false. It participates in `HyprlandFocusGrab`, so clicking elsewhere closes it.
- `shell/modules/sidebar/Content.qml`: contains a notification dock and separator, not applications. There are no pinned launchers, running-task icons, app groups, or audio visualizer.
- `shell/modules/sidebar/NotifDock.qml`, `NotifGroup*.qml`, `Notif.qml`, and `NotifActionList.qml`: grouped notification history by application, expand/collapse, preview stacks, action buttons, body copy, close, horizontal swipe-to-dismiss, clear gestures, and empty-state art. `Props.qml` persists expanded application groups.
- `shell/modules/notifications/*`: transient notification cards at the upper right. These are a separate surface from history but use the same notification data.
- `shell/modules/utilities/Content.qml` and `cards/*`: a bottom-right drawer with three actual cards: Keep Awake, Screen Recorder, and Quick Toggles. When notification history opens, utilities also opens and its background width interpolates to join the sidebar over an expressive 500 ms spatial transition.

Therefore the closest defensible interpretation of "three-module composite" is the complete right edge: transient notifications at top, notification-history sidebar in the middle, and utilities at bottom. Inside utilities, the three cards are idle inhibit, recording, and toggles. Neither interpretation yields the application dock required by §6. Caelestia is useful for right-edge organization language; DankMaterialShell remains the better stated code source for pinned/running application behavior.

### Bar, workspaces, task state, and popouts

- `shell/modules/bar/BarWrapper.qml` and `Bar.qml`: a left vertical bar, not a top bar. Default logical inner width is 40 plus padding. It can be persistent or hover-revealed; persistent is the default.
- Default entries are OS/logo, workspaces, spacer, active window, spacer, tray, clock, status icons, and power. Entry order is configurable.
- `components/workspaces/*`: clickable normal and special workspaces, occupied-window icons, active indicator, and scrolling between workspaces. It does not implement dropping a dragged window onto a workspace, so it covers only part of §4.16.
- `components/ActiveWindow.qml` plus `modules/windowinfo/*`: a vertical active-title/icon item opens a preview/details popout with maximize, float, pin, and close controls. This is useful interaction reference but does not put controls on every window as §4.15 requires.
- `components/Tray*.qml` and `popouts/TrayMenu.qml`: QuickShell system-tray integration with nested menus and right-click behavior. This is strong reference material for §4.13.
- `components/StatusIcons.qml`: audio/microphone, keyboard state, network, Ethernet, Bluetooth, and battery indicators.
- `popouts/Audio.qml`, `Network.qml`, `Bluetooth.qml`, `Battery.qml`, and `LockStatus.qml`: compact device/control panels. Audio exposes sources/sinks and settings. Network exposes available networks, connection state, address information, and password flow. Bluetooth exposes devices. Battery exposes power profiles. These are good service/UI patterns, though they are left-rail popouts rather than the target's independent dropdown panels.
- `popouts/ActiveWindow.qml`: window details and actions on bar hover/click.

There is no media item in the current default bar, and no current code path from MPRIS identity to launching Spotify or another source app. Thus the exact source-app icon behavior cited in §6 cannot be taken from this snapshot.

### Dashboard and media

- `shell/modules/dashboard/Wrapper.qml`, `Content.qml`, and `Tabs.qml`: top-edge dashboard with four tabs—Dashboard, Media, Performance, Weather—and both click and horizontal-swipe navigation.
- `dashboard/dash/*`: structured overview with calendar, date/time, small weather, user/system identity, CPU/RAM/storage progress, and compact media controls.
- `dashboard/media/CoverVisualiser.qml`: standout component. It renders roughly 60 radial Qt shape paths driven by Caelestia's native cava provider around Material-shaped cover art. `CoverArt.qml` rotates the cover while playing on a 23.5-second linear cycle.
- `dashboard/media/Details.qml`, `LyricsAndSelector.qml`, and `LyricList.qml`: title/artist, shuffle, previous/play/next/repeat, wavy seek control, player selector, and synchronized lyrics. Native service code handles lyrics and media analysis.
- `services/Players.qml`: wraps QuickShell MPRIS. It selects a manual player, configured default identity, or first available player; supports identity aliases, YouTube thumbnail fallback, media global shortcuts, now-playing toasts, and IPC play/pause/next/previous/stop. It does not expose a desktop entry, source-app icon, or launch action.
- `dashboard/performance/*`: CPU, GPU, memory, storage, network, and battery cards. The network card has separate upload/download sparklines, current rates, and totals. This is a polished overview, not a process list or dedicated monitor workspace; it cannot replace the §6 system-monitor requirement.
- `dashboard/WeatherTab.qml` and `services/Weather.qml`: current conditions, sunrise/sunset, humidity, temperature, wind, and forecast.

The dashboard is high quality but architecturally a single multi-tab hub. The target explicitly wants independent dashboard surfaces. Individual content cards and the media visualizer can be references or adapted slices; adopting the dashboard coordinator would conflict with §2/§6.

### Notifications

- `shell/services/Notifs.qml`: QuickShell `NotificationServer`, persistent/history data, close handling, actions, images, fullscreen policy, click-action policy, DND, expiry, and IPC clear.
- `shell/services/NotifData.qml`: notification model data used by popup and history views.
- `shell/modules/notifications/Notification.qml`: styled transient card with actions and close behavior.
- `shell/modules/sidebar/NotifGroup*.qml`: grouping and history model that §6 specifically identifies as desirable.

This is one of the strongest direct sources in the repository. It provides the grouping/history layer that can sit above the selected notification backend. It does not contain a semantic suppression rule for routine events such as the home Wi-Fi connection at boot; DND and category/toast toggles are broader controls, so §5's no-routine-spam behavior still needs filtering elsewhere.

### OSD, utilities, capture, and session controls

- `shell/modules/osd/*`: right-edge volume/brightness/microphone indicators with compact entry/exit motion.
- `shell/modules/utilities/cards/IdleInhibit.qml`: user-facing keep-awake control backed by `services/IdleInhibitor.qml`.
- `shell/modules/utilities/cards/Record.qml` and `RecordingList.qml`: full-screen or region recording, pause/stop state, elapsed time, recent recordings, and delete confirmation.
- `shell/services/Recorder.qml` plus `cli/subcommands/record.py`: wraps `gpu-screen-recorder`. Full-screen captures the focused output at its refresh rate; region mode uses a selected geometry and the maximum refresh of intersecting monitors; optional default-output audio is supported. On stop it moves the result to a timestamped MP4, can copy its URI, and offers watch/open/delete notification actions. This covers much of §4.10's interaction model, although the backend differs from the requested wf-recorder/OBS-class candidate and needs hardware validation on Iris Plus.
- `cli/subcommands/screenshot.py` plus `modules/areapicker/*`: full-output screenshot to clipboard/cache and a custom freeze/region picker feeding Swappy. The main Hyprland keybinds expose capture commands. The flow is relevant to §5's capture UX, but the target's exact timestamped-PNG and key behavior must be checked during synthesis.
- `shell/modules/utilities/cards/Toggles.qml`: Wi-Fi, Bluetooth, microphone, settings, game mode, DND, and optional VPN toggles. This is a useful System-control grouping pattern for §5/§6.
- `shell/modules/session/*`: lock/sleep/logout/reboot/shutdown confirmation drawer.

### Nexus settings center

- `shell/modules/nexus/*`: a substantial floating settings/control-center window, not a token demo. Pages cover applications, audio devices, Bluetooth, network, wallpaper/style, panels, services, language/region, and About.
- Configuration rows are reusable controls: toggles, sliders, steppers, selectors, popups, connected rectangles, and device lists.
- Network pages include Wi-Fi scanning/connection, hidden networks, saved profiles, Ethernet details, addressing, DNS, and autoconnect.
- `WallpaperAndStyle.qml` previews the wallpaper and changes light/dark mode, palette variant, wallpaper behavior, and transparency enabled state.

Bonus finding under §2: Nexus makes normally hidden shell configuration mouse-accessible and gives the desktop the feel of a product rather than a collection of keybinds. It is too bound to Caelestia services to drop in wholesale, but its page/row architecture is an excellent settings-surface reference.

### Background, lock, area picker, and miscellaneous surfaces

- `shell/modules/background/*`: wallpaper rendering, fade transitions, optional desktop clock, optional audio-reactive background visualizer, and per-output handling.
- `shell/services/Wallpapers.qml`: watches state and invokes CLI wallpaper changes.
- `shell/modules/lock/*`: full QML lock with blurred background, clock/weather, password input, PAM, fingerprint, and face-auth states. It is visually competent, but §6 mandates Hyprlock and explicitly rejects a QML lock implementation. Only spacing/choreography ideas are relevant.
- `shell/modules/areapicker/*`: custom selection overlay supporting frozen screenshots and geometry output.
- `shell/modules/windowinfo/*`: live window preview/details/action controls used by the taskbar popout.
- `shell/components/filedialog/*`: coherent custom file picker used for profile/background choices.

### Service and native-plugin layer

- `services/Audio.qml`: QuickShell PipeWire facade; native audio collector/provider supports visualization and device state.
- `services/Brightness.qml`: brightness controls via system tools/DDC paths.
- `services/Nmcli.qml` and `utils/NetworkConnection.qml`: comprehensive NetworkManager CLI wrapper for scanning, profiles, connection, Ethernet, saved networks, DNS/addressing, and state monitoring. Important defect: Wi-Fi passwords are inserted directly into `nmcli` argument arrays (`password`, `802-11-wireless-security.psk`). This exposes secrets through process arguments. Do not reuse this connection path unchanged; use the safer backend selected for §6 or convert credential delivery away from argv.
- `services/NetworkUsage.qml`: reads `/proc/net/dev`, excludes loopback, sums receive/transmit counters, computes byte-per-second rates from timestamped deltas, and retains 30 history samples. This is actual local interface throughput, not the meaningless signal percentage rejected by §4.7. It is not an external speed test and sums all non-loopback interfaces.
- Bluetooth uses QuickShell's native Bluetooth API in the UI rather than shelling out. Connected-device battery display depends on the properties exported by BlueZ/QuickShell; the current bar popout focuses on device connection and icon state rather than making battery a prominent verified field, so §4.7 is only partially covered.
- `services/Notifs.qml`, `Players.qml`, `Weather.qml`, `VPN.qml`, `GameMode.qml`, `Recorder.qml`, and system resource services separate backends from most UI.
- `plugin/src/Caelestia/Services/*`: native CPU/GPU/memory/storage sensors, cava/audio provider, beat tracking, and lyrics. The native layer improves efficiency and capability but increases build/port scope.
- `plugin/src/Caelestia/Config/*`: typed defaults, file watching, per-monitor overrides, animation/color/font/geometry tokens, and debounced persistence. QML setters save after roughly 500 ms; external config edits reload after a short debounce.
- `plugin/src/Caelestia/Images/*`, `Components/*`, and `Internal/*`: caching image provider, lazy views, wavy line, circular/linear indicators, circular buffers, sparkline item, and Hyprland helpers. These are the shared foundation behind the visible polish.

### CLI utilities and desktop configs

- `cli/subcommands/clipboard.py`: `cliphist list` through Fuzzel dmenu, then decode/copy or delete. Main Hyprland startup separately records text and image clipboard MIME types. This supplies a working backend for §4.3, but Fuzzel text rows are not the rich visual Win+V history UI required; use it only as backend/reference.
- `main/foot`, `fastfetch`, `btop`, `fish`, `starship`, `micro`, and `thunar`: a cohesive supplied userland. Foot uses transparency, but §6 requires Kitty, so the Foot config is visual reference only. The Thunar CSS benefits from generated palette roles but does not by itself prove the named-color/libadwaita completeness demanded by §4.17.
- `main/vscode`, `firefox`, `spicetify`, and CLI theme templates are covered in the theming section below.

## Theming system

Caelestia's theming is one of its strongest systems. It is not a handful of manually coordinated colors; it is a semantic palette pipeline with both live shell consumers and generated application outputs.

### Palette production and shell consumption

The CLI stores current palette state at `~/.local/state/caelestia/scheme.json`. A scheme includes name, flavor, light/dark mode, Material variant, Catppuccin-like named accents, complete Material 3 roles, and terminal colors. It can come from bundled named schemes or be generated from a wallpaper using `materialyoucolor` logic.

`cli/utils/wallpaper.py` creates/uses thumbnails, analyzes average tone and colorfulness, chooses a light/dark mode and Material variant, generates the palette, updates wallpaper state, and applies colors. Its simple defaults are sensible: brighter images tend toward light mode, low-colorfulness images toward neutral, moderately colorful images toward content, and colorful images toward tonal-spot.

`shell/services/Colours.qml` watches `scheme.json` through a QuickShell `FileView`. Widgets do not hard-code the chosen source colors. They consume named roles such as `m3surface`, `m3surfaceContainer`, `m3primary`, `m3onSurface`, and `m3outline`. The service also creates a transparency-aware palette (`tPalette`) for surfaces and animates color changes through `CAnim`. This directly embodies §3's requirement that widgets reference named slots.

The target design nevertheless needs a policy change. Caelestia allows the whole Material surface system to vary with wallpaper and mode. §3 says the deep blue/black surfaces should remain pinned while only accents adapt. The useful architecture is its semantic role boundary and live reload, not the stock dynamic surface values. Map Caelestia's surface roles to the target's fixed near-black blue tokens and feed wallpaper-derived colors only into primary/secondary/tertiary/accent roles.

### Theme fan-out

`cli/utils/theme.py` uses the same palette to update:

- terminal foreground/background/cursor/selection and ANSI colors by writing live OSC sequences to active pseudo-terminals;
- Hyprland generated scheme as Lua when a Lua configuration is detected, otherwise as `.conf` variables;
- Discord-family clients through generated SCSS/CSS;
- Pandora;
- Spotify/Spicetify `color.ini`;
- Fuzzel;
- btop, nvtop, htop;
- GTK 3 and GTK 4 CSS plus Thunar CSS, dconf light/dark preference, icon theme, and Papirus folder hue;
- Qt through qtengine color/config outputs;
- Warp terminal;
- Chromium-family managed frame color and color-scheme policy, followed by policy refresh;
- Zed;
- Cava;
- arbitrary user templates from `~/.config/caelestia/templates` into the Caelestia state theme directory.

The main repository adds watchers for applications that benefit from live integration:

- `main/vscode/caelestia-vscode-integration/src/extension.ts` watches `scheme.json`, regenerates a detailed VS Code workbench/editor theme, and synchronizes Catppuccin icon flavor between light and dark.
- `main/firefox/native_app/app.fish` watches the state file and sends framed JSON to the browser extension. `firefox/.../src/extension.ts` maps semantic roles across browser frame, tabs, toolbar, fields, new-tab page, popups, and sidebar, calls `browser.theme.update`, and updates Dark Reader when present. `userChrome.css` supplies further browser-chrome styling.
- Zed is generated directly by the CLI.

### Spotify

Spotify uses Spicetify, confirming the mechanism requested by §4.17. `cli/data/templates/spicetify-dark.ini` and `spicetify-light.ini` map semantic roles to Spicetify slots: text, subtext, main, cards, sidebar, player, elevated layers, rows, buttons, disabled controls, notifications, and shadow. `main/spicetify/Themes/caelestia/user.css` adds 200 ms hover transitions, Material-colored home filters and sticky top bars, elevated search/dropdown backgrounds, simplified playlist gradients, cover shadows, rounded scrollbars, and assorted layout cleanup. `manifest.json` selects the theme/color scheme and runs `spicetify apply` during setup.

The official video confirms the result is cohesive rather than theoretical. A caveat is that `theme.py` rewrites `color.ini` but does not itself call `spicetify apply` on every palette change. Whether a running Spicetify setup hot-reloads that file depends on its environment; a post-hook or watcher may be required for guaranteed live propagation.

### Cohesion and atomicity assessment

Coverage is broad enough to make Caelestia a leading implementation reference for §3 and §4.17. Shell, browser, editors, Spotify, Discord clients, GTK, Qt, file manager, terminals, system monitors, and Cava all speak the same semantic vocabulary. The showcase demonstrates the payoff.

It is not a perfect universal or atomic pipeline:

- Kitty is not directly generated. Live OSC colors may affect supporting terminals, and user templates can fill gaps, but the required Kitty config needs an explicit target.
- Zen is present in the main repo, but its own manifest note says theming currently does not work.
- GTK/Thunar styling is useful, but the target's previously validated 19 GTK3 named colors and four libadwaita root variables still need to be checked and preserved rather than assumed covered.
- Each generated file is written atomically, and a lock prevents concurrent palette jobs, but outputs are applied sequentially. There is no staging directory plus one global commit/rollback. An error is often logged/swallowed per target, allowing a partially updated desktop. This does not meet §6's strict "wallpaper → palette → every surface together, no half-applied states" requirement.
- Wallpaper state is updated separately from the later fan-out. The architecture is close, but synthesis should retain the atomic coordinator requirement rather than calling this solved.

## Glass / transparency

Caelestia has real compositor blur when configured, but stock settings are not the target's glass recipe.

Exact shell defaults from `plugin/src/Caelestia/Config/appearanceconfig.hpp`:

- transparency `enabled = false`;
- base opacity `0.85`;
- nested layer opacity `0.4`.

In light mode, `Colours.qml` subtracts 0.1 from base, so the effective default base becomes 0.75 if transparency is enabled. Layer zero uses the base alpha. Higher semantic container layers use the configured layer blend/alpha while also adjusting luminance relative to the wallpaper. The shared SDF background is painted with the transparent `m3surface` color; compositor blur supplies the frosted backdrop.

`Colours.reloadHyprRules()` sends live Hyprland rules for the `caelestia-drawers` namespace. It toggles blur and sets `ignore_alpha` to approximately `base - 0.03`. It supports both Lua evaluation and ordinary keyword syntax. A 30 ms cooldown coalesces updates, and when opacity increases or transparency is disabled it waits for the 300 ms color transition before changing the compositor rule, preventing a visible ordering glitch.

The main Hyprland config enables blur with size 8, two passes, no xray, and blur for popups/input methods. Normal windows use 0.95 opacity; Foot uses a more visibly transparent background. The shell also applies a `MultiEffect` shadow with `blurMax: 15` around its shared blob background.

The resulting dark showcase does look like real dark glass: wallpaper colors are clearly visible through the terminal, launcher, and border, with soft diffusion and strong rounded separation. The light showcase is much less glass-like because pale materials and a pale wallpaper reduce visible depth. The shell does not use the target's consistent 1 px ~10% white glass edge; its visible outline is primarily the geometry of the colored screen border and shadow.

For §3, the required base alpha is about 0.55–0.65 with a 12–16 px blur reference. Caelestia's configured 0.85 is too opaque, and transparency is off by default. Its compositor `size = 8, passes = 2` is also not a literal match, although Hyprland blur size is not a direct CSS pixel-radius comparison. The transferable pieces are the central alpha roles, `ignore_alpha` synchronization, live rule update, and animated color transition.

Runtime configurability is real but narrower than the guide suggests. `shell.json` is watched and reloaded live, and QML setters persist after a debounce. Base and layer values can therefore be edited while the shell runs. Nexus currently exposes a transparency on/off row and displays the current base/layer values, but it does not provide opacity sliders. This is not an iNiR-style live glass tuner. Adapting Nexus's existing `SliderRow` controls to those typed properties would be small glue, but the current feature should be recorded as live config reload plus GUI toggle, not a finished GUI opacity tuner.

Performance matters on the target Iris Plus/8 GB machine (§10). Caelestia combines compositor blur, a full-screen shared layer, SDF blob shaders, Qt `MultiEffect`, image caching/effects, and—in media views—many animated shape paths. The source is thoughtfully native-accelerated, but the full visual stack is not automatically cheap. Blur passes, background visualizer, radial media visualization, shadow blur, and always-loaded surfaces need measurement on target hardware. The central configuration makes features disableable, which is a positive compatibility trait.

## Animations / motion

Caelestia has a coherent tokenized animation system rather than arbitrary per-component timings.

`shell/components/Anim.qml` selects curves and durations from `plugin/src/Caelestia/Config/tokens.hpp`. Defaults:

| Token | Duration | Default curve/control points | Typical character |
|---|---:|---|---|
| standard small/normal/large/extra-large | 200/400/600/1000 ms | standard `(0.2, 0, 0, 1)` or accel/decel variants | ordinary state/geometry |
| expressive fast spatial | 350 ms | `(0.42, 1.67, 0.21, 0.9)` | quick overshooting movement |
| expressive default spatial | 500 ms | `(0.38, 1.21, 0.22, 1)` | drawer/panel motion |
| expressive slow spatial | 650 ms | `(0.39, 1.29, 0.35, 0.98)` | larger spatial change |
| expressive fast/default/slow effects | 150/200/300 ms | non-overshooting effect curves | opacity/color/ripple |

The expressive spatial curves intentionally exceed 1 on the Y control point, producing a spring-like overshoot without a physics simulation. The full emphasized token is a two-segment curve; standard, acceleration, and deceleration variants are also centralized. `shell-tokens.json` can override curves, durations, spacing, sizes, and rounding, while an appearance duration scale adjusts the system globally.

Important applications:

- Drawer wrappers animate edge offset and opacity. Many use the 500 ms expressive default spatial token, which produces the characteristic organic settle.
- The SDF background deforms at the same time, making entry feel like shape morphing rather than an unrelated panel sliding over the desktop.
- Launcher result modes transition out over 200 ms with opacity 1→0 and scale 1→0.9, swap delegates, then transition in over 200 ms with scale 0.9→1. List insertion/removal/movement and container height are also animated.
- Dashboard tabs animate selection, content position/opacity, and geometry. Horizontal swipe is supported.
- Sidebar/utilities joining uses a 500 ms spatial interpolation.
- `CAnim.qml` animates color changes for 300 ms, making wallpaper/palette changes less abrupt.
- `StateLayer.qml` gives controls an animated Material hover state around 200 ms and a longer ripple/fade sequence.
- Cover art rotates linearly over 23.5 seconds while playing; the surrounding cava paths react continuously.
- Hyprland itself uses coordinated custom curves for windows, layers, workspace switches, borders, and fades. Speeds are expressed in Hyprland animation units, not milliseconds.

Against §3, control/effect durations of 150–300 ms align well. The common 500 ms drawer motion is slower than the specified 160–300 ms everyday target, though it feels responsive in the official video because the surface starts moving immediately. The 600–1000 ms standard tiers exist for larger choreography. No current Caelestia interaction shown matches ilyamiro's deliberate ~1.2-second geometry-plus-content morph between radically different views; Caelestia's strength is consistent edge morphing and expressive micro-motion.

For the target, the best adaptation is the token architecture and the paired geometry/opacity pattern. Reduce ordinary open/close spatial tokens toward 220–300 ms, keep 150–200 ms effects, and reserve 700–1000 ms for the explicitly cinematic states. The overshooting curves may also need damping to fit the darker, calmer aurora direction.

## What's directly usable for our build

1. **Launcher behavior and visual structure — §2, §5 Launcher, §6 Launcher.** Use `shell/modules/launcher/*`, `plugin/src/Caelestia/appdb.*`, and the shared search/control dependencies as the leading community source. It has real icons, search-as-type, keyboard navigation, favorites, detached launch, Escape, and verified click-away through `HyprlandFocusGrab`. Adaptation: bind the target Cmd+Space and Apps button to the launcher IPC/global action; place it in the target's independent surface architecture; map colors to fixed dark glass roles; bring the coherent dependency slice rather than copying one QML file.

2. **Click-away coordinator — §2 and every §6 popup.** The `HyprlandFocusGrab` block in `modules/drawers/ContentWindow.qml` is a precise implementation pattern: activate only for interactive open surfaces, list owned windows, and clear all relevant state in `onCleared`. This directly fixes the current Escape-only launcher defect. For independent windows, each panel coordinator should register the appropriate windows with the same pattern.

3. **Notification grouping/history — §5 Notifications and §6 Notifications.** `services/Notifs.qml` plus `modules/notifications/*` and `modules/sidebar/Notif*.qml` provide popup cards, actions, DND, close, persistence/history, app grouping, expansion, and swipe dismissal. Adaptation: retheme to target glass, retain the selected backend/coordinator from synthesis, and add routine-event suppression.

4. **Semantic palette and live shell reload — §3 cohesion.** `services/Colours.qml`, `CAnim.qml`, `plugin/.../Config`, and `scheme.json` establish named roles, a watched state file, animated propagation, per-monitor overrides, and typed live settings. Adaptation: pin surface roles to deep near-black blue and allow only accent roles to follow wallpaper.

5. **Application theme fan-out — §3 and §4.17.** `cli/utils/theme.py`, its templates, and the main Firefox/VS Code/Spicetify integrations are concrete sources for Spotify, VS Code, Discord, Firefox/Chromium frame, GTK, Qt, Thunar, system monitors, Cava, and terminal color propagation. Adaptation: add Kitty explicitly, preserve the validated GTK/libadwaita role set, guarantee app reloads, and wrap fan-out in the target's atomic pipeline.

6. **Spotify theme — §4.17 and §6 media source app.** Vendor/adapt the Spicetify light/dark role templates and `user.css`. The official preview verifies whole-window cohesion. Add a reliable apply/reload hook after palette changes. This supplies the themed app half of the desired source-app interaction; the clickable MPRIS source icon itself is absent and must come from another community source.

7. **Actual network throughput model — §4.7 and §6 Top bar/Network.** `services/NetworkUsage.qml` is compact and separable: `/proc/net/dev` counter deltas, rates, totals, formatting, and circular history buffers. Adaptation: choose the active/default-route interface or clearly label aggregate traffic, convert to Mbps where required, and surface it in the target bar/dropdown. It is actual interface traffic, not signal strength.

8. **Media visualization and controls — §6 Music/EQ.** `dashboard/media/CoverVisualiser.qml`, `Details.qml`, shared cover art, native cava provider, and MPRIS service are excellent sources for album art, controls, seek, lyrics, player selection, and an audio-reactive radial view. Adaptation: use in an independent music surface, reduce GPU cost if needed, and connect to the selected EasyEffects EQ UI. It is not itself an EQ/preset editor.

9. **System grouping and recorder UX — §4.10, §5 Bar & panels, §6 Top bar.** The utilities drawer cleanly groups keep-awake, screen recording, and quick toggles rather than hiding capture controls under battery. The recorder supplies full-screen/region, pause, stop, elapsed status, recordings, and notification actions. Adaptation: evaluate/replace `gpu-screen-recorder` with the selected backend for Iris Plus, then expose it from the target System button.

10. **Compact audio/network/Bluetooth/battery popout layouts — §6 Dropdown panels.** Bar popouts and Nexus device pages are well-structured references for sink/source choice, Wi-Fi lists and details, Bluetooth devices, password flow, and power profiles. Adapt the UI/service separation but do not take `Nmcli.qml` credential handling unchanged.

11. **Tray and nested context-menu handling — §4.13 and §6 Top bar.** `Tray.qml`, `TrayItem.qml`, `TrayMenu.qml`, and the focus-grab special case handle real QuickShell tray models, nested menus, right-click, and click-away. These are a better source than a visual-only tray mockup.

12. **Nexus settings page architecture — §2, bonus product-quality finding.** Its navigation, row components, device lists, and live typed configuration demonstrate how to make shell internals fully mouse-accessible. Adapt selected patterns/pages after the target panels and settings ownership are settled; do not import the entire service graph merely for appearance.

13. **Animation/token framework — §3 Motion.** `Anim.qml`, `CAnim.qml`, `StateLayer.qml`, and `plugin/.../tokens.hpp` provide named durations/curves and global overrides. Adapt the architecture and lower everyday spatial durations. This is directly useful even if the SDF shell background is not used.

14. **Hyprland Lua configuration fragments — §4.8, §5, §10.** Animation, gesture, blur, startup, rule, and keybind modules use the same config language as the target. Adapt individual tables into the exact active config; do not replace the target file wholesale.

15. **Clipboard ingestion backend — §4.3.** The dual `cliphist` watchers and CLI decode/delete flow are a usable backend slice. The visual chooser is below the required Win+V experience, so pair the backend with a better sourced visual history UI.

16. **Wallpaper-to-palette generation concepts — §3 and §6 Wallpaper system.** Thumbnail analysis, mode/variant selection, watched semantic state, and broad fan-out are valuable. Keep skwd-wall and awww as required; use Caelestia as palette/application propagation reference, not as the picker replacement.

## What's NOT useful and why

- **The current sidebar as dock code:** it is notification history. It has no pinned/running applications, grouping, task activation, themed launcher tiles, or sidebar visualizer. It cannot satisfy §6's dock. Retain only its organization language and notification model.
- **The claimed clickable source-app media icon:** it is not in the current source. `Players.qml` knows MPRIS identity and controls playback, but no desktop-entry resolution or source-launch code exists. Do not cite this repo as implementation proof for that top-bar requirement.
- **The current bar as the target bar:** it is vertical, left-edge, and omits the required horizontal layout, pinned quick-launch set, center running-task region, source-app media, notification bell/System group composition, and drag-target workspaces. Individual subcomponents are useful; the full bar is the wrong form.
- **The shared full-screen blob drawer architecture:** visually excellent but conflicts with independent `PanelWindow` surfaces required in §2/§6. Pulling it would also bring custom shaders, geometry coordination, input-region computation, and extensive native/plugin dependencies.
- **Launcher wallpaper carousel as the final picker:** it is a flat thumbnail `PathView`, not skwd-wall and not 3D Cover Flow. §6 already fixes the picker choice.
- **QML lock:** the target explicitly uses Hyprlock. Caelestia's PAM/fingerprint/face implementation expands security and failure surface and should not be adopted.
- **Foot terminal configuration:** the target terminal is Kitty. Colors and transparency can inform values, but the configuration format and feature set do not map.
- **Performance dashboard as system monitor:** it shows aggregate resources, sparklines, disks, and battery but no processes. §6 requires a dedicated full workspace.
- **Current clipboard chooser as final UI:** Fuzzel text dmenu is functional but not the visual, preview-capable Win+V history requested in §4.3.
- **Current network credential path:** `Nmcli.qml` passes passwords in argv. Its broader network model is impressive, but this connection implementation is unsuitable unchanged.
- **Current opacity UI as a live tuner:** Nexus exposes only an enable toggle. Base/layers live-reload from config, but there are no GUI sliders.
- **Stock palette policy:** Caelestia dynamically changes surface colors and offers light themes. The target wants pinned deep dark blue/black surfaces and adaptive accents only.
- **Stock daily animation speed:** 500 ms expressive drawer motion is attractive but above §3's normal 160–300 ms interaction budget. Retain tokenization and curves after tuning.
- **Zen theme integration:** the main repository itself marks it as not currently working, so it should not be treated as solved coverage.
- **Main repository deployment/install framework on NixOS:** the manifest is package-manager-oriented around Arch/AUR. Use the shell flake/Home Manager module and express final packages declaratively in the target Nix setup.

## Compatibility notes

### NixOS and QuickShell

The shell companion is already Nix-capable. Its flake provides packages and a Home Manager module under `programs.caelestia`; the default package omits the CLI, while `with-cli` and the Home Manager defaults provide full behavior. For the target, pin the shell/CLI revisions in the flake rather than tracking moving main branches.

The shell explicitly requires the git version of QuickShell rather than the latest tagged release. Compatibility must be checked against the QuickShell revision already selected by the target build. Native plugin compilation also requires Qt 6 tooling and its declared dependencies including libcava, libqalculate, sensors, aubio, image and system libraries. This is a larger closure than a pure-QML launcher.

The Home Manager module is the lowest-risk way to evaluate a coherent component slice. If only launcher/notifications are ultimately adopted, synthesis should compare the maintenance cost of carrying the native plugin against running a configured Caelestia shell with unused surfaces disabled.

### Hyprland 0.55 Lua

The main repo's modular Lua is directly relevant. `Colours.qml` also detects Lua and sends evaluated Lua layer-rule updates; otherwise it uses ordinary `keyword layerrule`. Adapt exact rule tables into the target's active Lua config and confirm namespace spelling. The QML window has `name: "drawers"`, while the live blur rule targets namespace `caelestia-drawers`; QuickShell's configured app/namespace prefix is part of that resolution and should not be guessed when extracting a panel.

The supplied blur values are a starting reference, not target values. Keep `xray = false`; tune size/passes and alpha on the Iris Plus rather than adopting desktop defaults. Window/layer rules and XWayland matches are current enough to be useful syntax references.

Launcher keybinds must change: current Caelestia uses a Super key/global action, whereas §5/§6 mandates Cmd+Space plus the Apps button. This is a one-line dispatch-level adaptation once the shell action is installed.

### Independent surfaces

Every major Caelestia drawer assumes the shared `ContentWindow`, blob group, `ScreenState`, and masked full-screen layer. The target's independent `PanelWindow` architecture changes:

- anchors and geometry from child coordinates to each layer surface's anchors/margins;
- focus grab from one window to the set of independent windows belonging to an interaction;
- SDF shared background to each surface's glass container;
- open/close state from `ScreenState` panel booleans to the target coordinator;
- pointer masks/regions, since an independent panel can usually use its own window bounds;
- panel joining/deformation effects, which should be omitted unless another sourced independent implementation provides them.

Content components that are mostly `Item`/layout based—launcher lists, notification cards/history, media details, network throughput, controls—are more portable than wrappers and drawer backgrounds.

### Display scale and layout

The official preview is 1920×1080 and the shell uses logical token sizes such as 600-pixel launcher rows, 430-pixel right drawers, and a 40-pixel bar inner width. On the target Retina display at 1.5 scale, verify logical rather than physical dimensions. The typed token system and `shell-tokens.json` make this manageable. Text uses Google Sans Flex/Material icons by default; §3 requires Inter or similar plus Papirus and FiraCode Nerd Font. Replace font/icon tokens centrally rather than per widget.

### Iris Plus, dual-core i3, 8 GB RAM

Potentially expensive features are compositor blur with two passes, full-screen SDF blob rendering, `MultiEffect` shadows, radial cava shape paths, background visualizer, animated image effects, live thumbnails/previews, and 1-second hardware sensor polling. Native C++ providers and ref-counted services are positives, but performance should be measured with representative panels open and closed.

Likely first reductions are: disable the desktop visualizer, avoid the shared blob shell, reduce blur passes/size if frame time requires it, reduce visualizer bar/path count or refresh rate, slow resource polling, and keep expensive loaders inactive while hidden. These are configuration/adaptation deltas, not reasons to discard the useful components.

`gpu-screen-recorder` support on Intel/Wayland and its encoding path must be validated before choosing it. The target requirements already permit wf-recorder/OBS-class alternatives; the Caelestia UI can front a different sourced recorder backend.

### Network, Bluetooth, and secrets

`NetworkUsage.qml` works on NixOS because `/proc/net/dev` is stable, but it aggregates every non-loopback interface. On machines with VPNs, containers, or simultaneous Wi-Fi/Ethernet, displayed speed can double-count or misrepresent the active path. Bind it to the default-route interface for the bar and make the units explicitly Mbps if that is the product requirement.

`Nmcli.qml` assumes NetworkManager and the `nmcli` binary, both compatible with the intended stack, but its passwords appear in process arguments. Use a D-Bus/secret-agent backend or a safe input mechanism from the chosen community source. Do not carry this flaw into the target.

Bluetooth UI relies on QuickShell/BlueZ. Verify that the target devices export `Battery1` and that the chosen panel visibly renders it; Caelestia's current compact popout does not by itself close §4.7.

### Palette and application updates

The CLI detects and emits Hyprland Lua correctly. It can be packaged as a palette fan-out engine, but final integration needs:

- a staged/global atomic coordinator around wallpaper and all outputs;
- fixed dark surface roles with adaptive accent roles;
- Kitty output;
- the previously established complete GTK3/libadwaita variables;
- guaranteed Spicetify and application reload hooks;
- no privileged runtime writes for Chromium policy if a declarative Nix policy can own the same file;
- failure reporting rather than silently leaving half-updated apps.

The Firefox native bridge depends on Fish, `jq`, and `inotifywait`; all are packageable. VS Code's extension writes its own installed theme JSON, which may conflict with immutable Nix store installation if installed unpacked in the store. Package it so its writable theme output lives outside the store or generate the theme declaratively/statefully at an allowed path.

### Hardware-specific and invariant notes

Do not import the QML lock or its PAM files; keep the required Hyprlock path and its explicit PAM service. Do not replace the exact active Hyprland Lua file wholesale. Caelestia's touchpad factors, repeat values, focus behavior, and gestures are references only and must not regress the working target input behaviors in §11.

The main repository's special workspaces for system monitor, music, communications, and Todoist are useful organization ideas, but workspace names and rules must map onto the target's existing workspace semantics rather than taking Caelestia's set verbatim.

## Key files to vendor/adapt

Ranked by expected value to the target:

1. **`shell/modules/launcher/` + `shell/plugin/src/Caelestia/appdb.*` + `qalculator.*`** — leading launcher source. Carry the complete dependency graph needed for real app ranking, actions, icons, and animated lists; replace shared-drawer wrapper with the selected independent glass surface.
2. **`shell/modules/drawers/ContentWindow.qml` (`HyprlandFocusGrab` block) and `ScreenState.qml`/`services/ShellState.qml`** — adapt the click-away and per-screen coordinator pattern, not the full SDF window.
3. **`shell/services/Notifs.qml`, `NotifData.qml`, `modules/notifications/`, and `modules/sidebar/Notif*.qml`** — notification popup, grouping, history, actions, DND, and dismissal model.
4. **`cli/src/caelestia/utils/theme.py` and `cli/src/caelestia/data/templates/`** — broad application fan-out. Add atomic orchestration, Kitty, complete GTK/libadwaita roles, and reliable reloads.
5. **`main/spicetify/Themes/caelestia/user.css` plus CLI Spicetify templates** — verified Spotify cohesion with modest adaptation to the final dark palette.
6. **`main/vscode/caelestia-vscode-integration/` and `main/firefox/`** — live editor/browser palette consumers. Adjust writable paths and packaging for NixOS.
7. **`shell/services/Colours.qml`, `components/CAnim.qml`, and `plugin/src/Caelestia/Config/{config.*,appearanceconfig.*,tokens.*}`** — semantic palette, transparency roles, watched typed config, persistence, and token override architecture. Pin target surfaces.
8. **`shell/components/Anim.qml`, `CAnim.qml`, `StateLayer.qml`, and `plugin/.../tokens.hpp`** — unified curves/durations and hover/ripple behavior. Retune everyday motion to §3.
9. **`shell/services/NetworkUsage.qml` and `modules/dashboard/performance/NetworkCard.qml`** — actual rate calculation, history, and presentation. Select active interface and convert units/placement.
10. **`shell/modules/dashboard/media/`, `components/widgets/CoverArt.qml`, `services/Players.qml`, and native cava/audio services** — high-quality music surface and visualizer. Add source-app launch from another verified source and connect the selected EQ backend.
11. **`shell/modules/utilities/cards/Record.qml`, `RecordingList.qml`, `services/Recorder.qml`, and `cli/subcommands/record.py`** — recorder interaction model and UI; retain only after backend/hardware evaluation.
12. **`shell/modules/bar/components/Tray*.qml` and `modules/bar/popouts/TrayMenu.qml`** — tray icons, nested menus, right-click, and click-away.
13. **`shell/modules/bar/popouts/{Audio,Network,Bluetooth,Battery}.qml`, `modules/nexus/pages/{Audio,Bluetooth,Network}*`, and shared Nexus row controls** — dropdown/control-center layout references. Pair with safe selected services; exclude password argv handling.
14. **`shell/modules/utilities/cards/Toggles.qml` and utilities layout** — System-group organization for settings, DND, networking, microphone, recording, and keep-awake.
15. **`main/hypr/hyprland/{animations,decoration,gestures,keybinds,rules,execs}.lua`** — current Hyprland Lua examples. Merge only exact relevant fragments into the active target configuration.
16. **`cli/subcommands/clipboard.py` plus main `cliphist` watcher commands** — backend-only clipboard history slice to pair with a better visual community UI.

Bottom line for synthesis: Caelestia remains the strongest launcher candidate and a top-tier source for notification grouping, application-wide palette propagation, Spotify theming, and coherent motion tokens. It is not the application dock source, not the current source-app-icon implementation, and not the independent-panel shell architecture. Those distinctions should drive component selection rather than treating Caelestia as a whole-shell transplant.
