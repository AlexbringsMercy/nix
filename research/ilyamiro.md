# ilyamiro/nixos-configuration — Full Research

Research snapshot: target repository `d66c4a5915d2991d2e1cebe16f4c9b21f9fa0e6e` (2026-06-02), companion wallpaper repository `4b940811d375a5553ac97ac8824e571b9a5bace7` (2026-04-30). Sources: [nixos-configuration](https://github.com/ilyamiro/nixos-configuration) and [shell-wallpapers](https://github.com/ilyamiro/shell-wallpapers).

This report is based on a complete structure pass, the significant QML/config/backend files, all ten repository screenshots, all nine built-in guide previews, the companion preview, contact-sheet review of the full companion image corpus, and frames across its only video. It is repository research only; no local-build diagnosis or implementation is included.

## Repo overview

This is a highly animated QuickShell desktop layer for Hyprland. The checked revision contains a NixOS/Home Manager configuration, but its README now explicitly says the Nix configuration needs adaptation and should not be installed as a complete NixOS configuration. The author is moving the maintained shell toward a compositor-portable v2; the existing Arch-oriented line is v1.7.6. Accordingly, this repository is strongest as a source of QuickShell interaction and visual patterns, not as an importable NixOS system.

The repository is substantially larger than the “15k LOC” figure in the research brief:

- 339 tracked files and about 65.8 MB.
- 30 QML files totaling 32,221 lines.
- One 96-line JavaScript layout registry.
- Roughly 6,043 lines of Nix, shell, Python, templates, and supporting configuration.
- Ten full desktop screenshots, nine smaller in-shell guide previews, sound assets, fonts, and theming templates.

The principal stack is:

- QuickShell/QML with `Quickshell.Io`, `Quickshell.Wayland`, notifications, PAM, system tray, Qt Multimedia, Qt Shapes, and Qt Effects.
- Hyprland plus layer-shell surfaces and `hyprctl` runtime control.
- Matugen for wallpaper-derived Material colors.
- `swww` for still wallpapers and `mpvpaper` for video.
- NetworkManager/`nmcli`, BlueZ/`bluetoothctl`, PipeWire tools, `playerctl`, `cliphist`, ImageMagick, EasyEffects, and several small Python/shell services.

The user-facing shell has three surface families:

1. `TopBar.qml`: an independent per-screen bar.
2. `Main.qml`: one full-screen overlay that owns one morphing `StackView` of large widgets.
3. `Floating.qml`: an independent draggable edge sidebar for drawing, system usage, and timer tools.

The second item is the “one hub” architecture that our requirements reject. Its animation pattern is still valuable for intra-panel state changes.

Several claims in the repository's own guide and in earlier impressions need correction at this revision:

- The master widget-to-widget morph is 210 ms, not approximately 1.2 seconds. The professional, cinematic impression comes from slower 600–1,350 ms choreography inside the destination widgets while the outer geometry changes quickly.
- The music panel does not consume Cava data and is not audio-reactive. Its glowing “waveform” is a preset/apply-triggered Canvas lightning effect derived from EQ slider positions. Cava is configured separately as a terminal visualizer.
- The wallpaper picker is a 2D sheared `ListView`, not a perspective 3D Cover Flow implementation.
- Its visible swatches are fixed semantic color filters. ImageMagick extracts one dominant color for thumbnail categorization; the swatches are not an extracted palette from the selected wallpaper.
- The lock has a detailed lock-entry animation, but successful authentication exits immediately; there is no unlock animation.

## Visual impression

The desktop is genuinely polished. The quality comes from consistent geometry, typographic hierarchy, staged motion, large calm shapes behind dense information, and unusually good transitions between states. It looks like a coherent product rather than a pile of unrelated widgets.

The ten main screenshots show:

- A properly spaced, sectioned top bar. Small dark pills are arranged into left actions, workspaces, media, centered time/weather, tray/language, and system status. The active workspace and current wallpaper accent are obvious without overpowering the rest.
- A very wide calendar/weather dashboard with a large clock, orbital hourly forecast, left calendar, right weather metrics, and a lower schedule stream.
- A full-width wallpaper carousel with tilted parallelogram cards and a simple color-filter strip.
- A circular-album-art music panel with track metadata, transport, a ten-band EQ, presets, and luminous curve effects.
- A network/Bluetooth panel whose central connected device fans information into radial cards with animated “electrical” connectors.
- A screen-time dashboard with weekly bars, month heatmap, app usage, and detailed per-app views.
- A combined notification and battery/power panel with a large battery ring, volume and brightness controls, system actions, and performance profiles.
- A display panel with a physical-monitor metaphor, resolution cards, a clock-like rotation control, and refresh-rate control.
- A compact edge system-usage surface.
- A movie discovery/stream-source surface.

The built-in guide previews show an earlier or alternate blue-accent version over a mountain wallpaper. Comparing those to the current salmon-accent screenshots confirms that the shell really does recolor broadly from wallpaper changes. The visual grammar survives the palette change: rounded dark containers, thin low-contrast borders, accent-colored selection, JetBrains Mono/Iosevka typography, and slow ambient circles.

This is not a glass reference. In screenshots, most widget surfaces read as opaque or nearly opaque dark cards. Abstract colored circles and blurred album art create depth inside the surfaces, but the desktop wallpaper usually does not remain visibly legible through them. The bar has some translucency; large panels do not present the desired transparent aurora glass.

The companion wallpaper repository contains 323 tracked files and about 888 MB:

- 320 still-image files overall: 319 under `images/` and the root `preview.png`.
- 318 of the `images/` files decode as images. `images/ddg_1774782672860867551.jpg` begins with HTML rather than JPEG data and should be rejected during ingestion.
- One 14.4-second, 1920×1080, 30 fps H.264 video. It depicts a moss-covered fallen-world scene with rain, fog, a small cloaked figure, and subtly changing red glow. It is a wallpaper asset, not a shell showcase.

The corpus is predominantly high-resolution landscape imagery: mountains, alpine lakes, roads, forests, fog, snow, sunsets, dark teal scenes, and autumn color. There are also purple nebulae, minimal gradients, city scenes, a few cars and characters, and occasional anime/stylized art. It is broader than the green/nature palette associated with the repo, but many files repeat similar mountain/road compositions and several appear to be alternate or duplicate downloads. It is useful as test material for palette extraction, not as a curated set to import wholesale.

## Structure

The important structure is:

```text
configuration.nix                  whole-machine NixOS config (machine-specific)
home.nix                           Home Manager config (hardcoded user/home)
config/
  programs/
    cava/                          terminal Cava base config and wrapper
    kitty/                         terminal config; includes Matugen output
    matugen/
      config.toml                  template destinations
      templates/                   QuickShell, GTK, Qt, Kitty, Firefox,
                                   Discord, Neovim, Cava, SwayOSD, Hyprland
    neovim/ plymouth/ rofi/ ...    supporting application configs
  sessions/hyprland/
    default.nix                    packages and out-of-store config links
    hypridle.nix                   lock/suspend timers
    config/                        Hyprland source files
    templates/                     generated settings/keybind/autostart/monitor files
    scripts/
      qs_manager.sh                shell startup, IPC routing, prep jobs
      screenshot.sh                screenshot/recording backend
      lock.sh                      launches standalone QML session lock
      quickshell/
        Shell.qml                  loads Main, TopBar, Floating
        Main.qml                   overlay, notification server, widget coordinator
        TopBar.qml                 bar and data watchers
        Floating.qml               movable edge utility surface
        WindowRegistry.js          widget geometry/scaling registry
        Config.qml                 settings and monitor persistence
        MatugenColors.qml          live semantic palette singleton
        Caching.qml                XDG cache/state/run/log paths
        Scaler.qml                 responsive UI scaling
        SysData.qml                subscriber-aware system polling
        Lock.qml                   standalone WlSessionLock/PAM UI
        ScreenshotOverlay.qml      region/capture/record controls
        applauncher/
        battery/
        calendar/
        clipboard/
        focustime/
        guide/
        monitors/
        movies/
        music/
        network/
        notifications/
        quickactions/
        settings/
        stewart/
        updater/
        volume/
        wallpaper/
        watchers/
```

The runtime path for large widgets is:

```text
TopBar click / keybind
        ↓
qs_manager.sh (prepares network or wallpaper data when needed)
        ↓ QuickShell IPC
Main.qml::handleCommand()
        ↓
single currentActive value + WindowRegistry geometry
        ↓
animated x/y/width/height container + one StackView
        ↓
exactly one large widget is visible
```

`Main.qml` is itself a screen-sized overlay `PanelWindow` on `WlrLayer.Overlay`. Its background `MouseArea` implements click-away dismissal. The input region uses an XOR mask to leave the top bar reachable, with left/right margins animated when the settings panel touches the bar. This is a clever integrated-shell solution but not an appropriate ownership model for our independent `PanelWindow` dashboard.

`qs_manager.sh` ensures the shell is running, routes actions over native QuickShell IPC, starts/stops Bluetooth scans, rescans Wi-Fi, incrementally prepares wallpaper thumbnails, and closes the active widget before switching workspaces. This separation keeps most bar clicks cheap, but it also produces a large shell-script coordination layer.

## Component inventory

### Shell coordinator and morph system

Files: `quickshell/Shell.qml`, `Main.qml`, `WindowRegistry.js`, `qs_manager.sh`.

`Shell.qml` only instantiates `Main`, `TopBar`, and `Floating`. `Main.qml` owns a single `currentActive` string and a single `StackView`; this is the mutual-exclusion mechanism. `handleCommand(cmd, targetWidget, arg)` supports open, close, toggle, legacy direct calls, and changing a widget's `activeMode` without closing when the target remains the same.

The geometry is four bound properties—`animX`, `animY`, `animW`, and `animH`—on the clipping item around the `StackView`. Each has an independent `Behavior` using a `NumberAnimation`, but all share `morphDuration`, so they begin together. A widget switch updates geometry and calls `StackView.replace()` in the same event turn. This coordinates spatial morph and content cross-fade without a single explicit `ParallelAnimation` wrapping both systems.

Exact outer timing:

- First open: x/y/width/height 230 ms, `OutCubic`.
- Existing-widget switch: 210 ms, `OutCubic`.
- `StackView.replaceEnter`: opacity 0→1 with `OutQuint` and scale 0.98→1 with `OutCubic`, both 210 ms.
- `replaceExit`: opacity 1→0 with `InQuint` and scale 1→0.98 with `OutCubic`, both 210 ms.
- Close: width and height collapse to 1 over 160 ms; container opacity also falls over 160 ms with `InCubic`; the stack clears after 200 ms.
- Open opacity is 160 ms `OutCubic`.

The container's final width/height can be overridden by a loaded widget's `targetMasterWidth`/`targetMasterHeight`, used by the calendar when its optional schedule exists. There is a cache/preload facility, but the current preload list includes `search` and `help`, which are not registered widget names; in practice only settings is meaningfully preloaded.

Quality: excellent as a compact motion reference; tightly coupled as a shell coordinator. The reusable part is the synchronized bounding-box + content-transition pattern, not the global overlay.

### Shared scaling, paths, settings, and data

Files: `WindowRegistry.js`, `Scaler.qml`, `Caching.qml`, `Config.qml`, `SysData.qml`.

`WindowRegistry.getScale()` fits the surface into a 1920×1080 design space. It takes the smaller width/height ratio, applies `r^0.85` below 1 and `r^0.5` above 1, clamps the lower result at 0.35, and multiplies by the user's UI scale. This is materially better than scattered hardcoded DPI assumptions.

Base widget geometries before scaling include:

| Widget | Base size and anchor |
|---|---|
| Battery | 801×760, top-right at y=60 |
| Network | 900×700, top-right at y=60 |
| Volume | 450×700, top-right at y=60 |
| Launcher / clipboard | 800×700, centered |
| Monitors / Stewart | 800×650, centered |
| FocusTime | 900×700, centered |
| Guide | 1200×750, centered |
| Calendar | 1450×750, centered at y=60; can shrink to 510 high |
| Updater | 950×850, centered |
| Wallpaper | full screen width × 650, vertically centered |
| Music | 700×650, top-left at x=5, y=60 |
| Movies | 1370×850, centered along bottom |
| Settings | 450 wide, full height, left edge |

`Caching.qml` consistently assigns XDG cache/state/runtime/log directories. `Config.qml` loads and saves shell settings, keybinds, startup commands, weather values, and monitor state. It also emits Hyprland configuration fragments. `SysData.qml` is a good optimization: it only runs its two-second system poll while at least one consumer is subscribed. The rest of the repo does not consistently follow that model; many widgets own separate polling processes.

### Top bar

File: `TopBar.qml`, plus `watchers/*` and `qs_manager.sh`.

The bar is a separate per-screen `PanelWindow`, roughly 48 logical pixels high with 8 px top and 4 px horizontal margins. Its dark surface uses the wallpaper palette at roughly 0.75 alpha, with very faint 0.05–0.08 text-colored borders. Most inner pills are about 34 px high with 4–8 px spacing. This sizing is why the sectioned layout looks composed rather than cramped.

It contains:

- Left: help/search, settings, and update affordances depending on config.
- Workspace pill with clickable numbered workspaces.
- Media pill with album art/title/position and transport.
- Centered clock and weather.
- Right: system tray with left/middle/right click and QuickShell menus, keyboard layout, network, Bluetooth, volume, battery, and recording state.

Bar clicks dispatch through `qs_manager.sh`; application/widget processes use detached execution, so bar reload should not own ordinary children. Data comes from small fetch/wait scripts, `dbus-monitor`/MPRIS and `playerctl`, Hyprland, `nmcli`, BlueZ, PipeWire tools, sysfs, and a 150-second weather update.

The bar's startup is deliberately staged: left section 600 ms `OutExpo`; workspaces 500 ms `OutBack` with 60 ms staggering; center 800 ms `OutBack`; right 800 ms `OutBack` with cascading system pills; media width 400 ms `OutQuint` and content travel 700 ms. Hover feedback mostly falls in the 200–300 ms range. The active workspace highlight independently animates its left and right edges at 200/350 ms `OutExpo`, producing a stretchy directional morph.

Gaps relative to our required bar are substantial: no pinned launcher row, running tasks, active window title, per-window controls, source-application media icon, CPU/RAM buttons, or workspace drag targets. Media buttons are generally 24–28 px rather than the required practical minimum of about 34 px. The bar is therefore a spacing/motion reference, not a complete source for §6.

### Music and EQ

Files: `music/MusicPopup.qml`, `music_info.sh`, `player_control.sh`, `equalizer.sh`.

This is the strongest single widget in the repository visually. It combines:

- 220 px circular album art, masked and tinted, with a 40 px black center hole to create a vinyl/disc.
- Continuous 360° rotation over 8 seconds while playback is active.
- A 0.90→1 play/pause scale response over 800 ms `OutElastic`.
- Track metadata, source/device text, animated marquee, progress, transport, and a ten-band equalizer.
- Eight presets: Flat, Bass, Treble, Vocal, Pop, Rock, Jazz, and Classic.

`music_info.sh` polls MPRIS through `playerctl` every 500 ms. For new art it downloads/caches the image, creates a dark blurred background (`blur 0x20`, brightness/contrast reduction), quantizes three dominant colors, and derives an opposing color for text. The QML uses that blurred art at about 0.9 opacity, slow 90-second orbiting blobs, a five-second rotating border gradient, and a 1,200 ms perimeter “charge” mask.

The entry choreography is where the apparent cinematic duration comes from:

- Main 760 ms `OutQuart`.
- Cover after 70 ms, 810 ms `OutBack`.
- Text after 150 ms, 760 ms `OutQuart`.
- Controls after 230 ms, 760 ms `OutBack`.
- Separator after 310 ms, 660 ms.
- EQ header after 370 ms, 710 ms.
- EQ sliders after 430 ms, 860 ms `OutExpo`, internally staggered.
- Presets after 550 ms, 810 ms `OutBack`.

Thus the last major element settles around 1.36 seconds even though the outer panel has already morphed in 210 ms.

Preset selection immediately assigns all ten QML slider targets. Each slider has a 350 ms `OutQuart` value animation, so the bands travel together. Manual adjustments are pending until Apply; the backend constructs a 32-band EasyEffects IIR preset using selected positions from the ten controls and loads `live_eq`.

The luminous curve is a `Canvas` framebuffer effect drawn at 60 fps only during its event animation. Four jittered strands—wide translucent mauve, pink, lavender, and a thin white core—pass through the ten handle points. The sweep runs to its target over 650 ms `OutSine`, holds 150 ms, then fades for 800 ms `OutQuad`; each crossed handle gets a 1,000–1,500 ms surge/ring response. It reacts to preset/application events, not the audio signal.

There is a separate 60 fps Cava config with a three-color Matugen gradient and Monstercat smoothing, but nothing in `MusicPopup.qml` starts or reads Cava. The built-in guide's “Cava visualizer and live lyrics” description is stale at this revision.

Portability concerns: numerous subprocesses every 500 ms; ImageMagick and network activity on album changes; current EasyEffects output path is under `~/.config/easyeffects/output`, conflicting with the requirement to use the current XDG data path; and EasyEffects loading must remain invisible. Visually, however, this is the quality bar for §6 Music/EQ.

### Network, Wi-Fi, Ethernet, and Bluetooth

Files: `network/NetworkPopup.qml`, `wifi_panel_logic.sh`, `bluetooth_panel_logic.sh`, `eth_panel_logic.sh`.

The unified panel has Wi-Fi, Ethernet, and Bluetooth modes. It polls backend scripts at one- to three-second intervals, keeps device identities stable across refreshes, and preserves five visual “core” slots.

Bluetooth's radial presentation is count-driven rather than a named state machine:

- `multiTransitionState` animates 0→1 over 1,200 ms `InOutExpo` when multiple devices are present.
- `smoothedActiveCoreCount` changes over 1,000 ms `InOutExpo`.
- Each device begins overlapped at the center, shrinks from a 200 px core as count rises, and moves to an elliptical orbit (approximately 180×110, slightly larger beyond two devices).
- Base angle is `visualIndex / activeCount`; core angle and position move over 1,000–1,400 ms using `InOutExpo`/`OutExpo`.
- The entire system rotates extremely slowly over 200 seconds.

This simultaneous shrink, opacity/scale change, and radial dispersion is the apparent “cell division.” There is no particle split; the visual metaphor is achieved by interpolating every core from one shared center to stable orbital slots.

Connected-device detail cards sit around the cores. A Canvas redraws about every 45 ms and renders jittered glowing connectors, producing the electrical-lightning look. Scan rings radiate every two seconds with 400 ms staggering. Holding a connected core fills it with a 700 ms liquid wave before disconnecting; release drains the hold. The central power control morphs from a 160 px core to a 48 px bottom-right button over 800 ms `InOutQuint`. Bottom tabs reuse the bar's asymmetric 200/350 ms stretch highlight.

Functionally, Bluetooth shows name, MAC address, battery percentage when BlueZ supplies it, paired/connected state, and audio profile. Wi-Fi shows SSID, signal, security, IP, and frequency, plus connect/disconnect and scan. Ethernet reads `/sys/class/net/.../speed`, which is negotiated link rate.

It does not satisfy §4.7 network truth: Wi-Fi has no actual transfer or internet Mbps; the Ethernet number is link negotiation, not measured throughput. More seriously, password connection builds a `bash -c` string containing the password. This makes the password visible in process arguments and allows an apostrophe to break command quoting. The adaptation must replace that call path with a non-argv secret flow.

The Bluetooth script also constructs JSON around device data without robust JSON escaping and sources cached shell data, so arbitrary device names need defensive handling. The UI is excellent; the shell backends should not be carried over unchanged.

### Battery, notifications, and power

Files: `battery/BatteryPopup.qml`, `notifications/NotificationPopups.qml`, and the `NotificationServer` in `Main.qml`.

The battery widget is a two-column notification center plus hardware/power dashboard. Its right side includes uptime, a large animated battery gauge, brightness and volume sliders, logout/lock/suspend/reboot/shutdown controls, and power profiles. Its color pairing changes with battery state and profile. The battery value itself eases over 1,200 ms `OutQuint`.

Entry choreography runs from 800 ms to roughly 1.4 seconds: base 800 ms, top 100+800, notifications 150+850, central core 250+900, sliders 350+800, actions 450+800, profiles 550+850. Exit collapses the pieces in 150–400 ms.

Notifications are received by QuickShell's `NotificationServer`, stored in an in-memory history model, and mirrored into temporary top-right popups. Body, images, and actions are supported. The center groups by application, makes actionable cards sort upward, supports per-group collapse/clear, individual dismissal, and DND state. Popup cards enter with a 400–500 ms opacity/x/scale motion and leave in 350–400 ms; summary/body reveal duration scales with text length.

Limitations: history is not durable across shell restarts, the startup suppression period is only 500 ms, and there is no policy layer to suppress routine network events. The combined notification+power layout is visually strong but conflicts with the requirement for focused independent dropdown panels.

### Calendar, weather, diary, and schedule

Files: `calendar/CalendarPopup.qml`, `weather.sh`, `diary_manager.sh`, `schedule/*`.

The calendar is a very wide composition around a central clock and orbital hourly forecast. Weather view changes use a two-stage 3D-like spin: content exits in 250–300 ms, the new state enters over 450–600 ms with `OutQuart`/`OutBack`, while the numeric temperature animates independently. The main entry stages ambient background, clock/orbit, calendar, weather, and optional schedule from 800 to about 1,150 ms.

Weather data comes from OpenWeather via API key and city ID saved in the shell settings. The script maintains caches and keeps the old valid cache when requests fail. The optional lower schedule is not generic: it uses Selenium/Firefox against a particular Danish school timetable, a hardcoded resource ID, a hardcoded Firefox profile under `/home/ilyamiro`, and an 08:30–15:40 school day. When the script does not exist the widget reduces its master height from 750 to 510.

The calendar/weather visuals are worth referencing for hierarchy and state transition. The schedule backend is user-specific and should be omitted unless a later requirement identifies a replacement community calendar source.

### Wallpaper picker and companion wallpapers

Files: `wallpaper/WallpaperPicker.qml`, `ddg_search.sh`, `get_ddg_links.py`, `matugen_reload.sh`, plus `qs_manager.sh` thumbnail prep and the companion repo.

The carousel is a horizontal `ListView`. Delegates apply a `Matrix4x4` shear of approximately -0.35, while the image inside applies the reverse shear so its content remains visually upright. The active card expands to about 600×450; inactive cards compress to about 200×420 at 0.6 opacity. Width, height, scale, opacity, and highlight travel use 500 ms `InOutQuad`; newly fetched online items fade and spring from scale 0.5 over 400 ms.

The picker supports local stills and videos, multi-monitor target selection, DuckDuckGo full-HD image search, streaming thumbnails, and a Qt Multimedia video preview that begins after selection settles for 250 ms. Thumbnail preparation is incremental and manifest-based.

For categorization, ImageMagick boosts saturation, reduces a thumbnail to 1×1, and records a dominant color marker. The top swatches are fixed red/orange/yellow/green/blue/purple/pink/monochrome buckets that filter by that one value. They are not the current wallpaper's palette.

Applying a still uses `swww` with a random selection among fade, directional, wipe, grow, center, outer, and wave transitions at 144 fps for one second. Video uses `mpvpaper` with looping, no audio, hardware decode, display resampling, interpolation, and oversample timing. The chosen wallpaper is copied into a cache for the lock screen. Matugen is run against the thumbnail, not the original file, then a reload helper updates some consumers.

The pipeline is not atomic. Wallpaper application and Matugen/reload work are launched concurrently, so a transient half-applied visual state is possible. QuickShell notices `/tmp/qs_colors.json` on a one-second timer. Kitty and Cava receive signals/rebuilds; SwayNC reloads CSS; SwayOSD is restarted. Several other generated outputs rely on application startup or native file watching rather than a coordinated commit.

Our requirements already select `skwd-wall`, so this picker should not replace it. Its thumbnail manifest, video-preview settling, and palette-bucket logic remain useful reference material.

### FocusTime analytics

Files: `focustime/FocusTimePopup.qml`, `focus_daemon.py`, `get_stats.py`, `launch_daemon.sh`.

This is a notable bonus component. A local Python daemon listens to Hyprland's event socket, identifies active application classes/titles, and writes daily, hourly, 30-minute, and minute-level usage into SQLite. The UI provides total time, daily average, comparison with yesterday, weekly bars, a month heatmap, top apps, a 24-hour per-app chart, a full week heatmap, and peak hours.

The UI's chart fills are tied to a shared `introAppBars` property and settle over as much as 1,300 ms. Daily/week/app view changes use 550 ms `OutExpo` focus values. This accounts for the convincing “data dashboard comes alive” quality seen in the preview.

The daemon is event-driven for focus changes but still queries `hyprctl` when the event arrives and records window-derived metadata locally. It already recognizes Hyprlock, although the repo's own active lock process is QuickShell, which makes that check inconsistent. The concept is portable and the result is high quality, but this is a substantial service/UI feature rather than small glue and should remain a bonus candidate, not displace the dedicated system/process workspace.

### Volume mixer

Files: `volume/VolumePopup.qml`, `get_audio_state.py`, `audio_control.sh`.

The mixer has output, input, and per-application tabs. A large top orb represents the active/default node; a custom liquid wave fills the circle according to volume, and a larger slider controls the master. Other nodes appear as cards with mute, set-default, and per-node sliders. It uses `wpctl` for default master operations and `pactl` for node lists/default selection and background streams.

The intro runs 700–800 ms with `OutExpo`/`OutBack`; item cards stagger. The visual level is good and the three-mode separation maps directly to a compact audio dropdown. Backend polling runs a Python process that calls `pactl -f json` and `wpctl`, so a service abstraction from a later candidate may be more efficient.

### Display/monitor panel

Files: `monitors/MonitorPopup.qml`, monitor support in `Config.qml` and `SettingsPopup.qml`.

The monitor UI reads `hyprctl monitors -j`, models single and multi-display arrangements, supports dragging with perimeter snapping, resolution selection, refresh-rate selection, and 0/90/180/270-degree transform through a clock-dial metaphor. It applies changes with runtime Hyprland monitor commands and writes generated monitor configuration.

The entry is unusually slow: general reveal 900 ms, monitor scale 1,200 ms, vertical position 1,800 ms, and screen light 1,500 ms. It looks cinematic in the screenshot, but 1.8 seconds is too slow for repeated control use. The geometry/snap math is useful. Persistence must be translated away from generated `.conf` fragments for our native Lua setup.

### Application launcher

Files: `applauncher/appLauncher.qml`, `app_fetcher.py`.

The launcher scans desktop entries with Python, filters as the user types, supports keyboard navigation, and launches with `hyprctl dispatch exec --`. The result list grows/shrinks over 500 ms `OutExpo`; entries animate opacity/scale; selection uses a two-edge stretch highlight and a 500 ms `OutBack` icon emphasis. Click-away comes from the encompassing `Main.qml` overlay, not from a self-contained focus grab.

It only searches applications. It does not provide files, settings, and actions required by §4.11, and its dismissal mechanism depends on the rejected global hub. It is visually respectable but not a better source than the already selected launcher candidates.

### Clipboard manager

Files: `clipboard/ClipboardManager.qml`, `clip_fetcher.py`.

This is a strong, previously underemphasized component. It reads `cliphist` in pages of 24, detects and decodes image entries into an XDG cache, searches text, shows a three-column/four-row grid, supports keyboard navigation, and copies through `wl-copy`. Selecting a card can morph that card's exact grid rectangle into a full text preview using animated x/y/width/height/radius over 250–300 ms `OutExpo`.

The UI has 600 ms entry motion, 250–400 ms item motion, automatic loading of more history, image thumbnails, and both Escape and click-away through `Main.qml`. It directly addresses §4.3. To use it as an independent panel, carry the list/preview implementation while replacing hub dismissal with a self-contained focus/click-away mechanism.

### Floating utility surface

Files: `Floating.qml`, `quickactions/DrawAction.qml`, `SystemUsage.qml`, `Timer.qml`, `SysData.qml`.

`Floating.qml` is an independent layer surface that can attach to the left, right, or bottom edge. A one-pixel edge trigger peeks after 300 ms; it hides after 800 ms, with a three-second grace period following a drag. The user can pin, expand, drag, or rotate it between edges. It maintains a Wayland input mask around the visible area.

Reveal uses 300 ms `OutExpo`; expansion uses 450 ms `OutQuart`; edge relocation hides over roughly 350 ms, teleports with animation briefly disabled, then shows. The active-tab highlight again animates its two edges asymmetrically at 200/350 ms. The surface is about 0.95 opaque, not glass, and lacks universal background click-away; it relies on focus/auto-hide and can be pinned.

Modules:

- `DrawAction.qml`: a zoomable/pannable Canvas with pen/brush/eraser, undo/redo, hue/SV picker, swatches, size controls, copy, and clear. It is feature-rich but outside current requirements.
- `SystemUsage.qml`: CPU, memory, temperature, disk, and network display. Values smooth over 800 ms and disk detail shells out to `df`/`du`. It is useful for glanceable telemetry but does not replace the required dedicated process workspace.
- `Timer.qml`: persistent timer, stopwatch with laps, and configurable Pomodoro. It continues ticking while hidden and emits notifications. This is a polished bonus utility.

The independent surface architecture is more relevant to our dashboard than `Main.qml`, but its edge-peek interaction is a utility sidebar, not the pinned/running application dock required by §6.

### Screenshot, recording, editing, and QR

Files: `ScreenshotOverlay.qml`, `scripts/screenshot.sh`.

The standalone overlay provides adjustable region selection, resize handles, cached geometry, maximize/fullscreen toggle, screenshot/edit/video mode, desktop and microphone audio controls, microphone selection, QR scan, and a toolbar. Region geometry moves over 350 ms `OutExpo`; toolbar sections expand over 350 ms; screenshot/video selection reuses the asymmetric stretch highlight.

The backend uses `grim` for images, `satty` for editing, `wl-copy`, and `gpu-screen-recorder` through the portal at 60 fps for video. It can mix desktop and microphone audio by creating temporary PipeWire/Pulse compatibility null sinks and loopbacks, then cleans them when recording stops. Recording state is exposed to the bar. The same trigger toggles stop/finalization and sends an actionable notification.

This directly addresses §4.10 more completely than the repo's headline widgets and is a serious candidate for adaptation. It needs careful compatibility/performance validation on Iris Plus, and its shell implementation has complex cleanup responsibilities. The overlay tint is presentation-only; image capture occurs through `grim`, so it should not bake the selection film into the result.

### Settings

Files: `settings/SettingsPopup.qml`, `Config.qml`, `templates/*.conf.template`.

At 4,384 lines, settings is the largest QML file. It includes global search, General/Weather/Keybinds/Monitors/Startup tabs, UI scale, bar/guide options, keyboard layout/options, wallpaper directory, workspace count, OpenWeather credentials/unit, editable keybinds, editable startup commands, and full monitor layout controls. It supports mouse and extensive keyboard navigation.

The panel itself enters over 600 ms and exits over 200 ms. It dynamically writes settings JSON and generates Hyprland text fragments. This is capable but monolithic, and the generated-Hyprland workflow conflicts directly with our native Lua configuration. Individual control patterns are useful; wholesale adoption is not.

There is also a command/path suggestion implemented with shell `eval` around user input, which should not be retained. Keybind/startup command editing intentionally permits commands, but the UI must make that trust boundary explicit if adapted.

### Lock screen

Files: `Lock.qml`, `lock.sh`, `hypridle.nix`.

The lock is a standalone QuickShell `WlSessionLock` using `PamContext`. It covers every monitor with a cached current wallpaper, maximum Qt blur (`blurMax` scaled from 64, `blur: 1.0`), a 0.25 black dimmer, two very large low-opacity orbiting accent circles, and four concentric fine rings. Idle state shows a huge 140 px clock and date. Clicking or typing transitions to a horizontal avatar/authentication composition; the clock moves/fades/scales out and auth moves in over 400–600 ms.

The password field is visually represented as animated characters/dots. Characters can be briefly revealed for a configurable 100–3,000 ms before becoming dots. Failed auth changes rings/borders red and shakes the field in three 120 ms moves. Bottom pills show keyboard layout, battery, and weather. A near-opaque 0.95 power/settings menu includes password-reveal controls plus reboot, suspend, and power off.

Exact lock-entry choreography:

1. Lock orb scales 0→1 over 300 ms; opacity over 200 ms. Three rings expand/fade over 250, 300, and 350 ms.
2. After 300 ms, unlocked icon contracts/fades while locked icon springs from 1.6→1 over 200 ms `OutBack`; the orb gets a short 40+120 ms vertical latch motion.
3. After a further 50 ms, the orb expands to 1.8 and the overlay fades over 100 ms.
4. Main screen content enters from 30 px down over 100 ms.

The overall entry is about 750 ms. On PAM success, however, `rootLock.locked` becomes false and `Qt.quit()` runs immediately. There is no visual unlock exit. PAM is started through a 50 ms deferral and restarted after failure.

This implementation must not be used on our laptop. The value is the composition and timing as a Hyprlock reference: heavy wallpaper blur, circular vignette/rings, huge clock, avatar-to-PIN state transition, red failure shake, and peripheral status pills. Our required implementation remains Hyprlock with its PAM service configured before activation.

### Movies, Guide, Updater, and Stewart

- `movies/MovieWidget.qml` is a polished movie/series search and history interface backed by Cinemeta metadata and a long list of external browser embed sources. It is unrelated to the desktop requirements, adds network/privacy/security surface, and should not enter the build.
- `guide/GuidePopup.qml` is an attractive interactive tour with system information and module previews. It is useful evidence of design-system consistency, but several descriptions are stale: music claims Cava/live lyrics, FocusTime is described as Pomodoro, and wallpaper names an `awww` backend while the code uses `swww`.
- `updater/UpdaterPopup.qml` fetches remote version data, videos, and commit history, then uses a 1,200 ms hold-to-update liquid-fill button. The final action opens a terminal and evaluates a remotely downloaded installer. It targets the author's imperative dotfile installer, not our declarative system, and must not be reused. The hold-to-confirm interaction itself is attractive.
- `stewart/stewart.qml` is a reserved/disabled assistant visualization. It contains a well-made multi-phase glowing core transformation with particles, refraction, shockwave, and calm idle motion, but no assistant service. It is visual experimentation, not a functional component.

### Supporting application/system configs

- Matugen templates cover QuickShell, Kitty, Vesktop/Discord, Firefox plus GitHub/YouTube CSS, Neovim, Cava, SwayOSD, GTK, Qt5, Qt6, and Hyprland borders.
- Kitty is opaque (`background_opacity 1.0`) and includes a generated color file.
- Cava is 60 fps with automatic bar count, 3 px bars, Monstercat smoothing, and generated gradient colors.
- The GTK template defines 23 named colors, which is good coverage, but it does not include the additional libadwaita root-variable layer required by §4.17.
- Qt has a generated 21-color palette and broad QSS. Text inputs are deliberately not globally styled to avoid breaking Telegram.
- Discord imports a remote Midnight theme and supplies generated variables.
- Firefox output is hardcoded to one profile directory, so it is not portable as written.
- Hyprland's supplied settings use blur size 8, two passes, 4 px rounding, 4 px gaps, and a `0.05, 0.9, 0.1, 1.05` custom window/layer curve. These are not the desired final glass parameters.
- Plymouth, Rofi, Neovim, zsh, Kitty, and SwayOSD configs are ordinary supporting dotfiles rather than standout sources for this session.

## Theming system

The core verification is positive: widgets consume semantic aliases, and Material role names are confined to the template layer.

`MatugenColors.qml` defines 22 palette properties with fallback colors. Every major widget instantiates or inherits it and references names such as `base`, `surface0`, `text`, `mauve`, `blue`, and `teal`. A `Process` reads `/tmp/qs_colors.json`; a one-second timer reruns the read so an already-running shell changes colors live.

`config/programs/matugen/templates/qs_colors.json.template` is only 24 lines including braces and defines these 22 mappings:

| QuickShell alias | Material role |
|---|---|
| base | `surface_container_lowest` |
| mantle | `surface_container_low` |
| crust | `surface` |
| text | `on_surface` |
| subtext0 | `on_surface_variant` |
| subtext1 | `outline` |
| surface0/1/2 | `surface_container` / `high` / `highest` |
| overlay0/1/2 | all `inverse_surface` |
| blue, mauve | both `primary` |
| sapphire | `primary_container` |
| peach | `tertiary` |
| pink | `tertiary_container` |
| green, teal | both `secondary` |
| yellow | `secondary_container` |
| red | `error` |
| maroon | `error_container` |

This confirms the earlier “single small palette file” finding. Replacing this mapping can change the entire QuickShell aesthetic without touching each widget. It also exposes a weakness: several aliases collapse to the same role, reducing the intended Catppuccin-like semantic diversity. Our deep blue/purple/teal aurora mapping can be installed at this boundary, subject to the already accepted Matugen-version behavior in the master requirements.

Wallpaper application invokes Matugen and emits all configured templates. Coverage is broad:

- Shell surfaces and accents.
- Kitty and Cava.
- GTK named colors.
- Qt5/Qt6 palettes and QSS.
- Vesktop/Discord.
- Firefox chrome variables and site CSS for GitHub/YouTube.
- Neovim.
- SwayOSD.
- Hyprland border colors.

“Everything recolors together” is directionally true in the screenshots and template coverage, but runtime propagation is incomplete. QuickShell polls a temporary file; some applications are explicitly signaled/restarted; some simply receive a rewritten config for next launch; Firefox uses a hardcoded profile; GTK and Qt surfaces remain opaque; and no transaction makes wallpaper plus every consumer visible at the same instant. This is a good token architecture and a partial universal pipeline, not a fully atomic theme service.

## Glass / transparency

The repo confirms the research brief's distinction: ilyamiro is the motion reference, not the glass reference.

Observed/implemented values:

- Top bar main dark surface: approximately `base` at 0.75 alpha, faint border around 0.05–0.08.
- Floating edge surface: approximately 0.95 alpha.
- Lock power menu: approximately 0.95 alpha.
- Lock wallpaper dim: black at 0.25 over a strongly blurred wallpaper.
- Lock decorative orbit circles: roughly 0.03–0.08 opacity.
- Music background: locally generated blurred album art around 0.9 opacity, not desktop wallpaper transmission.
- Screenshot overlay dim: crust at 0.50; selection tint: mauve at 0.05.
- Hyprland compositor config: blur size 8, two passes; ordinary windows are opacity 1.0.
- Kitty: background opacity 1.0.

Most large widget roots use opaque `base` or `surface` colors and create depth with internal ambient circles, borders, gradients, blur, and glow. The actual wallpaper is not visibly readable through the calendar, network, battery, or settings surfaces in the previews. The lock does show genuine depth-of-field because it explicitly renders and blurs the cached wallpaper behind its content.

For our build, only the shape/border/ambient-layer composition should transfer. Surface colors must be replaced with the required translucent blue-black values, and compositor blur must be tuned independently. Copying ilyamiro's values would reproduce near-opaque panels, not the requested aurora glass.

## Animations / motion

The repository's most reusable design system is implicit rather than centralized: common duration/easing families repeat across components.

### Timing vocabulary

| Purpose | Common values | Typical easing |
|---|---:|---|
| Color/hover/control feedback | 150–300 ms | `OutExpo`, `OutBack`, simple color interpolation |
| Directional stretch highlight | leading edge 200 ms, trailing edge 350 ms | `OutExpo` |
| List/item/layout adjustment | 350–550 ms | `OutExpo`, `OutQuint` |
| Master widget geometry switch | 210 ms | `OutCubic` |
| Open/close shell opacity | 160 ms | `OutCubic` / `InCubic` |
| Major panel section entry | 700–900 ms | `OutQuart`, `OutQuint`, `OutBack`, `OutExpo` |
| Full staged reveal | approximately 900–1,400 ms | mixed, delayed sections |
| Slow ambient drift | 8–200 seconds | linear/sine, infinite |

This maps well to §3: fast controls, medium layout changes, and cinematic one-time entrances. Some repeated entrances—especially the monitor panel's 1.8-second travel—are longer than advisable.

### High-value patterns

1. **Bounding-box morph plus content cross-fade.** Four geometry `Behavior`s and `StackView.replace()` start together. The content only scales 2%, avoiding a cheap zoom effect.
2. **Asymmetric selection pill.** Store logical left/right targets separately. Change one boundary over 200 ms and the other over 350 ms based on navigation direction. The pill stretches toward the new item and catches up instead of sliding rigidly.
3. **Shared intro progress properties.** Each major panel exposes section progress values (`introCore`, `introSliders`, etc.), driven by one parallel set of delayed animations. Child opacity, scale, and translation bind to those values, keeping choreography legible.
4. **Count-driven radial layout.** Bluetooth core count controls size, angle, radius, and opacity; stable `visualIndex` preserves identity so devices do not jump between slots.
5. **Event-triggered Canvas burst.** Music keeps the expensive glow effect finite rather than permanently redrawing a visualization that is not visible.
6. **Hide–teleport–show for edge changes.** Floating sidebar relocates only while hidden, avoiding an awkward full-screen diagonal travel.
7. **Hold-to-confirm liquid fill.** Network disconnect and updater actions make destructive intent visible through fill progress.
8. **Card-to-detail morph.** Clipboard expands from the selected delegate's real grid geometry, preserving spatial continuity.

### Motion shortcomings

- There is no reduced-motion preference in the shell's settings.
- Many ambient animations run indefinitely even when their widget is loaded; visibility gating is inconsistent.
- Network connector Canvas redraws every 45 ms while active, and several panels layer multiple GPU effects.
- Most panel-specific exit animations are bypassed when `Main.qml` immediately replaces or collapses the outer stack; several files define exit state that is not clearly coordinated by the master.
- The master motion is tied to one global overlay, so it cannot be transplanted verbatim into independent panels.

## What's directly usable for our build

The following are repo-derived candidates, ordered by fit. “Usable” means vendor/adapt the existing community implementation or its contained pattern, not create a replacement from nothing.

1. **Music/EQ visual implementation — §6 Music/EQ, §3 motion.** Adapt `MusicPopup.qml`, `music_info.sh`, `player_control.sh`, and the EQ preset mapping. Keep vinyl masking/rotation, art-derived local accents, staged sections, ten-band preset motion, and finite lightning sweep. Replace the event-only pseudo-visualizer with a community Cava data bridge during synthesis; move EasyEffects presets to the current XDG data location and keep its UI hidden.

2. **Intra-panel morph pattern — §2 interaction, §3 motion, §6 dropdown panels.** Extract the synchronized geometry behaviors and 0.98-scale cross-fade from `Main.qml`, but place the pattern inside each independent panel for compact/detail or device/list transitions. Do not import the full-screen coordinator.

3. **Palette alias boundary — §3 visual system, §4.17 app theming.** Adapt `MatugenColors.qml` and `qs_colors.json.template` as the thin QuickShell token layer. Replace collapsed aliases with the chosen blue/purple/teal aurora roles and connect them to the final verified palette generator. The small template is exactly the right place to change the shell globally.

4. **Broad app-template coverage — §4.17.** Vendor/adapt the Kitty, Discord, Firefox, Neovim, Cava, SwayOSD, GTK, Qt, and Hyprland templates selectively. Fix hardcoded paths, add the required libadwaita root variables, use the final app reload strategy, and introduce transparency only where supported.

5. **Bluetooth radial UI and count transition — §6 Bluetooth.** Adapt the stable-slot/count-driven core layout, device battery/profile cards, scan rings, and hold-to-disconnect interaction from `NetworkPopup.qml`. Connect it to the selected safer Bluetooth service backend. This is the repo's best distinctive network contribution.

6. **Clipboard manager — §4.3.** Vendor the paginated `cliphist` grid, image decoding, keyboard search/navigation, and card-to-preview morph. Convert it to its own `PanelWindow` and add self-contained focus/click-away handling.

7. **Screenshot/record overlay — §4.10 and §6 System button.** Evaluate `ScreenshotOverlay.qml` and `screenshot.sh` as a complete community solution for region/full capture, clipboard/save, editing, recording, mic/desktop mix, QR, and recording status. Adapt package paths and validate the recorder path against the MacBook's Intel GPU budget before selection.

8. **Top-bar sizing and selection motion — §5 bar defects, §6 Top bar.** Reuse the 48 px bar/34 px pill geometry, 4–8 px spacing rhythm, tray menu handling, detached dispatch, and stretch-workspace highlight. The missing required modules mean the bar itself is not a drop-in.

9. **Volume panel presentation — §6 Audio.** Adapt the master liquid orb, output/input/app tab structure, and node card design. Prefer the selected service backend instead of copying continuous `pactl`/Python polling unchanged.

10. **Battery/power composition — §6 System/Power.** Reuse the battery ring, brightness/volume dock, performance profile control, and power-action choreography as a design source. Separate notifications from power in our independent-panel architecture.

11. **Monitor layout math — §6 Display.** Vendor/adapt resolution/refresh/rotation controls and multi-monitor perimeter snapping. Replace generated Hyprland text persistence with the native Lua configuration interface chosen for our stack.

12. **Responsive scale function — hardware/scaling invariant.** `WindowRegistry.getScale()` is compact and directly useful for consistent 1.5× Retina behavior. Keep a single scale owner so bar, panels, and hit targets agree.

13. **FocusTime — bonus serving §2/§3.** This is a polished optional analytics feature the user explicitly admired. If selected later, vendor the daemon, stats query, and UI together; do not reduce it to a new ad-hoc tracker. It complements but does not replace the required process workspace.

14. **Floating tab microinteractions — bonus.** The edge relocation and asymmetric tab highlight are good interaction references. The surface itself is not the required app dock.

15. **Lock choreography only — §6 Lock.** Translate the 750 ms rings/orb entry, 400–600 ms clock-to-avatar transition, blurred wallpaper, large clock, avatar, status pills, and red failure shake into Hyprlock-supported mechanisms. Do not vendor `Lock.qml`, `lock.sh`, or its PAM lifecycle.

## What's NOT useful and why

- **The global hub architecture.** `Main.qml` is elegant but directly conflicts with independent dashboard `PanelWindow` surfaces. Its screen-sized focusable overlay also couples all dismissal and input behavior to one owner.
- **The QML session lock implementation.** It is excluded by the laptop lockout-risk requirement. It also lacks unlock choreography and starts/restarts PAM inside the QML process.
- **The wallpaper picker as our picker.** `skwd-wall` is already the selected source and offers the desired parallelogram picker. Ilyamiro's implementation is a convincing 2D shear, but its online search, thumbnail pipeline, and Matugen apply path add complexity without superseding that choice.
- **The full NixOS/Home Manager configuration.** It is unpinned, non-flake, machine-specific, stateVersion 25.11, hardcodes user `ilyamiro`, `/home/ilyamiro`, `/etc/nixos/config`, a Firefox profile, hardware, GNOME/GDM, broad packages, and passwordless sudo. The repo itself says it needs adaptation.
- **Generated Hyprland `.conf` management.** Our target is native Hyprland 0.55 Lua. The UI concepts can stay; the settings/keybind/autostart/monitor template layer cannot.
- **Movies widget.** It is outside requirements and depends on numerous changing third-party embed services.
- **Updater.** It is tied to an imperative remote installer and executes downloaded content in a terminal, the opposite of our declarative update flow.
- **Guide.** It is a product tour, not a required surface, and its feature descriptions have drifted from the code.
- **Stewart assistant.** It is explicitly reserved/disabled and has no service implementation. Keep only as optional visual inspiration for an ambient assistant state if a sourced assistant appears later.
- **School schedule scraper.** It is hardcoded to the author's institution, resource, profile path, and school-day layout.
- **Live wallpaper playback for the initial build.** The repository's `mpvpaper` quality settings are aggressive for a dual-core i3/Iris Plus system, and animated wallpaper is explicitly deferred in the master requirements.
- **Cava wrapper as the music visualizer.** It is only a terminal Cava setup and is disconnected from the music QML. A different existing Cava-to-QML bridge is required if true audio response is selected.
- **System usage sidebar as the system monitor.** It is glanceable telemetry, not the dedicated process/workspace experience required by §6 and §7.
- **Launcher as the final system-wide search.** It only searches desktop applications and inherits click-away from the rejected overlay.
- **Current palette values and large-panel opacity.** The green/nature-derived color result and opaque surfaces do not match the deep dark blue/purple/teal aurora glass target.

## Compatibility notes

### NixOS and repository state

The repo does not provide a flake or version pin for QuickShell/Hyprland. Its Nix tree combines a complete machine configuration with mutable out-of-store links and runtime-written files. Adaptation should select files into our existing modules rather than importing `configuration.nix`, `home.nix`, or the full Hyprland session.

Hardcoded paths requiring replacement include `/home/ilyamiro`, `/etc/nixos/config`, one Firefox profile name, school schedule profile/state, and several `~/.config/hypr/scripts` assumptions. Python runtime dependencies include Selenium for the optional schedule, SQLite for FocusTime, and standard-library HTTP helpers. Fonts require JetBrains Mono plus the included Iosevka Nerd Font glyphs.

### Hyprland 0.55 native Lua

Runtime commands such as `hyprctl monitors -j`, `activewindow -j`, workspace dispatch, device queries, and keyword application remain conceptually compatible with Hyprland; they do not depend on text-config syntax. Generated `settings.conf`, `keybinds.conf`, `autostart.conf`, `monitors.conf`, and Matugen border config do depend on the author's text configuration layout and need a Lua-compatible persistence/application mapping.

The focus daemon uses Hyprland's `.socket2.sock` event socket path with both current runtime and older `/tmp/hypr` fallbacks. Verify event names/path against the packaged Hyprland 0.55 during implementation, but the service boundary is narrow.

### QuickShell/API delta

The code uses recent modules including `Quickshell.Services.Pam`, `WlSessionLock`, `NotificationServer`, system tray menu anchors, layer-shell masks, and `QtQuick.Effects.MultiEffect`. It contains a comment addressing Qt 6.11 initialization, suggesting a recent environment. Because no QuickShell revision is pinned, every selected file needs an import/API compatibility pass against the packaged QuickShell revision. The ordinary `PanelWindow`, `Process`, `IpcHandler`, `StackView`, Shapes, and Multimedia uses are otherwise conventional.

### 2560×1600 at 1.5 scale

If QuickShell reports the expected approximately 1707×1067 logical surface, `WindowRegistry.getScale()` produces roughly 0.90 at user scale 1.0. Approximate resulting logical sizes are:

- Music 633×588.
- Network 814×633.
- Battery 724×687.
- Calendar 1,312×678.
- Launcher/clipboard 724×633.
- Settings 407 px wide.
- 34 px inner bar controls become about 31 logical px, approximately 46 physical px at compositor scale.

The fit is reasonable, but the bar's smaller media glyph buttons remain below our desired logical hit target. The minimum 0.35 scale also risks very small controls on unusual surfaces; our adaptation should clamp interactive targets independently of decorative scale.

### CPU/GPU/RAM budget

The repo has several cost centers relevant to a dual-core i3, Iris Plus, and 8 GB RAM:

- Music polls a shell script every 500 ms and may invoke multiple `playerctl` calls; album changes run ImageMagick and possibly a download.
- Network polls multiple shell backends and redraws connector lightning around 22 fps while open.
- Music's lightning Canvas runs at 60 fps during a finite burst; multiple `MultiEffect` blur/glow layers are present.
- Many widgets maintain 90–200 second infinite orbit animations.
- Lock blurs a full-screen image with a high blur radius.
- `mpvpaper` enables interpolation and high-quality resampling.
- FocusTime maintains SQLite aggregation but sensibly uses the Hyprland event socket for focus changes.
- The screenshot recorder targets 60 fps and may create multiple audio loopbacks.

None of these measurements were performance-tested in this research session. During implementation, selected components should be visibility-gated, polling should be consolidated into subscriber-aware services, blur/effect counts should be reduced where visual loss is negligible, and 60/144 fps assumptions should be calibrated to the target hardware.

### Backend and safety deltas

- Replace Wi-Fi password-in-argv/`bash -c` construction with a secret-safe NetworkManager path.
- Properly JSON-escape Bluetooth names and never source device-controlled text as shell data.
- Do not use settings path completion based on shell `eval`.
- Do not import the remote-eval updater.
- Keep screenshot recorder teardown robust across crashes; temporary audio modules need a startup recovery path as well as normal-stop cleanup.
- Notification history needs durable storage if history across shell restarts is required, and event filtering must suppress routine boot/network noise.
- Palette application needs a staged/atomic coordinator so wallpaper and all visible surfaces do not diverge during refresh.

### Requirement gaps that this repo does not close

This repo does not supply the required application dock/sidebar, complete top-bar task model, workspace drag targets, per-window buttons, real Wi-Fi/internet throughput, system-wide files/settings/actions search, low-latency gaming stack, removable-media flow, printing, system autocorrect, bootloader experience, or a dedicated btop-class process workspace. Those remain for their assigned research sources; ilyamiro should not be stretched beyond its strengths.

## Key files to vendor/adapt

Ranked by expected value:

1. `config/sessions/hyprland/scripts/quickshell/music/MusicPopup.qml` — strongest visual component; adapt into independent Music/EQ panel.
2. `music/music_info.sh`, `music/player_control.sh`, `music/equalizer.sh` — supporting behavior, with process consolidation and EasyEffects path changes.
3. `Main.qml` — extract only geometry/cross-fade, click-away-mask, and mutual-exclusion ideas; do not vendor the global owner.
4. `MatugenColors.qml` and `config/programs/matugen/templates/qs_colors.json.template` — thin live palette boundary.
5. `network/NetworkPopup.qml` — extract Bluetooth stable-slot radial UI, core split, scan/disconnect/power motion; replace connection backends.
6. `clipboard/ClipboardManager.qml` and `clipboard/clip_fetcher.py` — complete visual clipboard history and preview morph.
7. `ScreenshotOverlay.qml` and `scripts/screenshot.sh` — unusually complete capture/record UX; evaluate as a unit.
8. `TopBar.qml` — spacing, pill geometry, tray behavior, detached dispatch, workspace/media startup choreography.
9. `WindowRegistry.js` and `Scaler.qml` — unified responsive scaling and base geometry registry.
10. `volume/VolumePopup.qml` — compact audio structure and liquid master indicator; reconnect to chosen service layer.
11. `battery/BatteryPopup.qml` — battery ring, controls, power profiles, and staged layout; split notification ownership.
12. `monitors/MonitorPopup.qml` — monitor visualization, rotation control, resolution/rate selection, and snapping math.
13. `focustime/FocusTimePopup.qml`, `focus_daemon.py`, `get_stats.py` — optional but complete analytics feature.
14. `Floating.qml` — independent edge-surface mechanics, input region, edge relocation, and tab highlight.
15. `notifications/NotificationPopups.qml` plus the `NotificationServer` section of `Main.qml` — visual/action/grouping reference, pending comparison with the designated notification backends.
16. `wallpaper/WallpaperPicker.qml` and `qs_manager.sh` wallpaper-prep section — reference only for shear math, settled video preview, manifest thumbnails, and dominant-color categorization.
17. `Lock.qml` — design/timing reference only; translate its composition to Hyprlock and do not execute it.
18. Matugen application templates under `config/programs/matugen/templates/` — select and correct GTK/Qt/Kitty/Discord/Firefox/Neovim/Cava/SwayOSD coverage.

The central conclusion is precise: ilyamiro is the correct Tier 1 motion and widget-choreography reference. Its best code is the Music/EQ panel, Bluetooth radial model, clipboard morph, capture overlay, scaling system, and small semantic palette boundary. Its global hub, QML lock, opaque surfaces, unsafe Wi-Fi secret handling, mutable machine config, and non-atomic theme pipeline should not carry into the build.
