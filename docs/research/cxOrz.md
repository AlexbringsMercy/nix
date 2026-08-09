# cxOrz/dotfiles-hyprland — Full Research

Research snapshot: [`cxOrz/dotfiles-hyprland`](https://github.com/cxOrz/dotfiles-hyprland) at commit [`0961d64`](https://github.com/cxOrz/dotfiles-hyprland/commit/0961d64cf73dd61b6e8aac9a2ba0070c52c1afa2), dated 2026-07-05. This pass covered the complete functional repository tree: 68 tracked files, 9,209 lines in total, 5,195 lines of QML, every substantive configuration/script, the history relevant to the current components, and all eight preview assets under `examples/`. The QuickShell 0.3 service documentation was also checked where it changes the safest portability assessment.

## Repo overview

This is an Arch-oriented Hyprland desktop styled after ChromeOS with Material Design 3 geometry. The current implementation is a hybrid rather than one monolithic shell:

- Hyprland 0.55+ uses native Lua configuration in `.config/hypr/hyprland.lua`.
- Waybar is the actual persistent 48-pixel bottom shelf shown in the current desktop.
- QuickShell owns the launcher, control center, Wi-Fi and Bluetooth subpages, notification server/history/toasts, power menu, and volume OSD.
- PipeWire is accessed through QuickShell's native `Quickshell.Services.Pipewire` types.
- Wi-Fi, Bluetooth, brightness, DND, and power operations are command adapters around `nmcli`, `bluetoothctl`, `brightnessctl`, `dunstctl`, `systemctl`, and `hyprlock`.
- The theme system has six fixed palettes and pushes selected colors into QuickShell, Waybar, Kitty, Hyprland borders, and the old Rofi launcher theme.

The repository matters most as a compact set of panel interaction flows, not as a clean service library. Apart from `NotificationService.qml` and `Theme.qml`, service state, command execution, parsing, and UI are mostly combined in the same QML files. The Wi-Fi and Bluetooth “backends” therefore cannot be lifted as independent singletons without carrying or separating their UI files.

The current repo is active and recent, but it has visible migration residue. The README still describes Rofi as the launcher, Dunst as the notification daemon, and a QuickShell shelf as the bottom bar. Current source instead launches the QuickShell launcher, starts Waybar, starts Dunst and then kills it from the QuickShell notification singleton, and never instantiates `modules/shelf/Shelf.qml`. That source/documentation drift is relevant to how much confidence to place in unverified paths.

## Visual impression

I viewed every repo preview rather than inferring the appearance from color constants:

- `examples/desktop.webp`
- `examples/control-center.webp`
- `examples/app-launcher.webp`
- `examples/notification.webp`
- `examples/theme-panel.webp`
- `examples/lockscreen.webp`
- `examples/kitty-theme.webp`
- `examples/fcitx-theme.webp`

The desktop is a vivid purple/magenta anime wallpaper with a dark translucent shelf along the bottom. The wallpaper is genuinely visible through the shelf and panel backgrounds, so this is not an entirely opaque build. The overall visual language is immediately understandable: large rounded control-center tiles, a bottom-left grid launcher, bottom-right quick settings, top-right notification cards, rounded window borders, and small pill groups in the shelf.

The control center is the most coherent preview. It has generous 64-pixel tiles in a two-column grid, clear separation between the tile icon, label, subtitle, and drill-in chevron, and a large pill volume slider. Hit targets are substantially better than the cramped controls identified in `MASTER_REQUIREMENTS.md` §5. The hierarchy is clean and ChromeOS-like. It is not, however, Raycast-level aurora glass: the bright rose active tiles are flat and visually dominant, internal surfaces are opaque solid fills, typography is monospaced throughout, and there are no gradients, rim light, depth layers, or expressive content transitions.

The launcher is a large five-column app grid rising from the bottom-left. It exposes real app icons and names, a search field, a visible scrollbar, and enough spacing to be mouse-friendly. The wallpaper shows through the dark panel. The visual result is functional and tidy but less refined than the Caelestia launcher: long names truncate aggressively, the grid is visually uniform rather than ranked, and the current source's white circular icon backing is not clearly reflected by the stored preview.

Notification cards are compact dark burgundy rectangles with rounded corners, a small app label, title/body, a tiny close button, and a narrow accent treatment. They are legible but basic. There is no app icon, image, action row, grouped stack, swipe affordance, or rich priority treatment visible. The notification center shown on the desktop is a simple vertical stack plus “Clear all.”

The theme panel is a straightforward list of palette cards with five color swatches and a selected outline/checkmark. It communicates theme choice well but is not a live glass/palette tuner.

The lock screen uses the captured desktop as a heavily blurred, darkened full-screen background with a large central clock, date, and one outlined login pill. It has pleasant focus and strong legibility, but it is sparse: no avatar, circular vignette, PIN choreography, battery, Wi-Fi, or cinematic depth layering. It is below the required ilyamiro-inspired choreography in §6.

The Kitty preview demonstrates six coordinated fixed palettes across tiled terminal windows. The terminal surfaces themselves are effectively opaque dark fills; the wallpaper is visible mainly in Hyprland gaps. The Fcitx preview is a small static GitHub-dark candidate strip and does not participate in the six-theme pipeline.

One preview caveat is important. `app-launcher.webp` shows the launcher and control center open together, while current `shell.qml` explicitly closes one when the other opens. The asset therefore predates or bypasses the current coordinator. The previews are valid evidence of the repository's visual design, but not every multi-panel composition represents the current source exactly.

Overall visual rating: polished enough to use as a functional MD3 prototype and spacing reference; not polished enough to ship unchanged for the target's deep dark blue/purple/teal aurora-glass direction. The backend/UI separation is uneven, so visual restyling is easy for some components and invasive for the two largest panel files.

## Structure

The functional structure is:

```text
.
├── README.md
├── install.sh / uninstall.sh
├── examples/                         eight visual previews
├── .config/
│   ├── hypr/
│   │   ├── hyprland.lua              startup, input, animation, bindings, rules
│   │   ├── monitors.lua
│   │   ├── hyprlock.conf
│   │   ├── hypridle.conf
│   │   ├── hyprpaper.conf
│   │   └── scripts/                  portal and share-picker helpers
│   ├── quickshell/
│   │   ├── shell.qml                 module construction and mutual exclusion
│   │   ├── Theme.qml                 six fixed palettes and shared dimensions
│   │   ├── current-theme
│   │   ├── scripts/
│   │   │   ├── apply-theme.sh        Waybar/Kitty/Hyprland/Rofi propagation
│   │   │   └── resolve-icons.sh      launcher icon filesystem scan
│   │   └── modules/
│   │       ├── controlcenter/         main page, Wi-Fi, BT, sliders, themes
│   │       ├── launcher/              QuickShell app launcher
│   │       ├── notifications/         server, history, toast layer/cards
│   │       ├── osd/                   volume OSD
│   │       ├── powermenu/             full-screen overlay and action tiles
│   │       └── shelf/                 unwired QuickShell shelf prototype
│   ├── waybar/                        actual bottom shelf
│   ├── rofi/                          older/fallback launcher styling
│   ├── wofi/                          older power-menu implementation
│   ├── kitty/
│   ├── fcitx5/
│   ├── yazi/
│   └── flameshot/
└── .local/share/fcitx5/               static Rime/input theme
```

`shell.qml` creates five active UI modules plus the toast layer:

```text
PowerMenu
ControlCenter
NotificationCenter
NotificationToastLayer
Launcher
VolumeOsd
```

The QuickShell shelf is not imported or constructed. Waybar is launched from Hyprland instead. Rofi, Wofi, Flameshot, the share-picker helper, and parts of the README are retained migration artifacts rather than the primary current UX.

## Component inventory

### 1. Shell root and panel coordinator

**Files:** `.config/quickshell/shell.qml`

`ShellRoot` constructs the independent modules and reads `current-theme` through a `Process`. Four `Connections` blocks enforce mutual exclusion among the power menu, control center, notification center, and launcher. Opening any one assigns the other three visibility properties to false. Toasts and the volume OSD remain independent, which is appropriate for transient system feedback.

This maps well to the dashboard architecture in §6: distinct surfaces, independent IPC targets, and no forced single-hub navigation. The coordinator is explicit and easy to understand. It is also repetitive and knows every concrete panel property name, so adding panels grows the cross-coupling. For this target's finite set of dropdown panels that is acceptable as a source pattern, though a shared coordinator state from another community shell may scale better.

### 2. Control center shell

**Files:** `.config/quickshell/modules/controlcenter/ControlCenter.qml`, `FeatureTile.qml`

The control center owns a main quick-settings grid plus Wi-Fi, Bluetooth, and theme subpages. Its main state is:

- Wi-Fi enabled/connected SSID via `nmcli`.
- Bluetooth powered and connected count via `bluetoothctl`.
- DND status via `dunstctl`.
- Backlight availability via `brightnessctl`.
- Airplane mode inferred as both Wi-Fi and Bluetooth off.

It polls these commands every eight seconds only while visible and refreshes immediately on open. Actions are direct command invocations. The reusable `FeatureTile` has distinct 72% toggle and 28% drill-in zones, an especially useful progressive-disclosure pattern for §2. The 64-pixel default height is comfortably clickable.

The panel is a full-screen transparent `PanelWindow` on the overlay layer. A background `MouseArea` closes it on outside click, while a second mouse area over the panel blocks propagation. Escape closes a subpage first, then the panel. The visual panel is clipped above a 48-pixel shelf and slides upward from behind that shelf.

Subpages slide horizontally at 200 ms rather than morphing. `pageContainer.height` remains tied to the main page, so subpages inherit that height and scroll internally.

Quality assessment: the interaction shell and tile component are clean and portable. Service code is embedded in the same 519-line file. DND is currently functionally contradictory: `NotificationService.qml` kills Dunst so QuickShell can own the notification bus, but the tile still queries and toggles `dunstctl`. It therefore does not suppress QuickShell toasts or history. This must not be carried forward as a working DND implementation.

### 3. Wi-Fi panel

**File:** `.config/quickshell/modules/controlcenter/WifiSection.qml` (656 lines)

The panel provides:

- radio status and on/off toggle;
- automatic list refresh every ten seconds;
- manual rescan with a three-second wait;
- SSID, signal percentage, signal icon, and security icon;
- connected-first, signal-descending sorting;
- duplicate SSID collapse to the strongest access point;
- inline password input;
- connect, disconnect, and forget actions;
- loading, disabled, empty, and generic error states.

The backend is entirely `Quickshell.Io.Process` plus `StdioCollector` around `nmcli`. It is not NetworkManager D-Bus and not QuickShell's native NetworkManager wrapper. The list command is:

```text
nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list
```

The parser handles escaped colons in SSIDs, deduplicates by SSID, and keeps the highest signal value. This is useful compact logic, although it loses separate BSSID/band/channel choices and assumes SSID alone identifies the desired connection profile.

The latest commit added the inline disconnect/forget flow, but both use the SSID as the NetworkManager connection profile identifier. That often matches the profile name but is not guaranteed. Open networks can also be misclassified if `nmcli` supplies `--` rather than an empty security field.

Error handling discards stderr and reduces failures to “Connection failed” or an exit code. There is no connecting state, captive-portal state, IP address, device/interface name, gateway/DNS, link bitrate, or traffic rate. Therefore it does not meet §4.7 or the complete Network dropdown in §6.

The service/UI abstraction is weak: command objects, parser, `ListModel`, password state, and all presentation live in one file. The user flow can be adapted, but this is not a standalone backend module.

#### Confirmed password exposure

At `WifiSection.qml:196–203`, the code constructs:

```qml
connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
```

QuickShell correctly avoids shell interpolation by passing an argument array, so SSIDs are not being injected into a shell. The problem is different: the password becomes a process argument and is visible in that process's command line to local inspection interfaces while `nmcli` runs.

The best compatibility correction depends on the QuickShell version selected for the build:

1. QuickShell 0.3 provides the community-maintained `Quickshell.Networking` NetworkManager service and `WifiNetwork.connectWithPsk(psk)`. Adapting this panel's model/actions to that API removes the `nmcli` child process and its argv exposure while retaining the panel UI. The [0.3 Networking service](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Networking/) exposes NetworkManager-backed devices/connectivity, and [WifiNetwork](https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiNetwork/) provides saved-network `connect()` behavior plus `connectWithPsk()`.
2. If the packaged QuickShell lacks that module, the minimal safe compatibility path is `nmcli --ask ...` with `Process.stdinEnabled: true` and `Process.write()` after start, so the secret travels over stdin rather than argv. QuickShell officially exposes both capabilities in its [Process API](https://quickshell.org/docs/master/types/Quickshell.Io/Process/). Prompt handling must account for saved connections and any additional NetworkManager questions; it should not simply assume every prompt is the password.

In either adaptation, the QML password string should be cleared immediately on success, failure, cancellation, and panel close. The current code clears some state after process exit but leaves the field/state alive while the inline card remains open.

### 4. Bluetooth panel

**File:** `.config/quickshell/modules/controlcenter/BluetoothSection.qml` (884 lines)

This is the largest component. It supports:

- adapter power state and toggle;
- paired-device list;
- connected/not-connected labels;
- connect and disconnect;
- five-second discovery;
- unpaired-device list derived by subtracting paired devices from all known devices;
- pair → trust → connect sequencing;
- scan/pair status and generic error presentation;
- five-second paired-device refresh while visible.

The implementation uses `bluetoothctl` subprocesses rather than BlueZ D-Bus or `Quickshell.Bluetooth`. The presentation is more complete than the Wi-Fi page: distinct disabled/scanning/empty states, paired and nearby section headings, device cards, icon circles, action pills, and pairing status cards.

Several service issues materially limit reuse:

- A single `checkProc` is reused for every paired device. `listProc` loops through devices and repeatedly changes `checkProc.targetMAC`, its command, and `running = true`. A `Process` already running is not started again, and the target MAC can be overwritten before output returns. Multiple paired devices can therefore receive missing or incorrect connected-state updates.
- Clearing and rebuilding `pairedModel` every five seconds produces avoidable model/UI churn.
- A five-second discovery window is short, and `bluetoothctl devices` includes remembered/cache entries, not a strong guarantee that every displayed “nearby” device was seen in that scan.
- Pairing assumes noninteractive `bluetoothctl pair` succeeds. There is no agent/PIN/passkey/confirmation UI for devices that require interaction.
- There is no forget/unpair action, device-type-aware icon, battery percentage, signal, codec/profile, or connection-failure detail.

The missing battery directly fails §4.7 and §6. QuickShell 0.3's [BluetoothDevice API](https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothDevice/) already exposes paired, pairing, connected, trusted, forget, device icon, and optional battery state. Adapting the existing card/layout flow to those community service objects would eliminate polling and the single-process race while supplying the required battery data. If the target QuickShell build does not include that API, this CLI implementation needs a queued/per-delegate connection query and a separate BlueZ battery source from another community implementation.

Service/UI separation is poor here too: all polling, process state, diffing, pair sequencing, model state, and 600+ lines of presentation live together.

### 5. Volume slider and OSD

**Files:** `.config/quickshell/modules/controlcenter/VolumeSection.qml`, `.config/quickshell/modules/osd/VolumeOsd.qml`

These are the cleanest service-facing components in the repo. Both use `Pipewire.defaultAudioSink` and `PwObjectTracker`, so volume and mute are event-driven native QuickShell/PipeWire properties rather than CLI polling.

`VolumeSection.qml` provides the sink description, volume percentage, mute toggle, and a drag/click pill slider. It clamps the panel slider to 100%. `VolumeOsd.qml` listens to any default-sink volume/mute change, ignores startup population for 600 ms, slides/fades a 300×52 card above the shelf, and dismisses after two seconds.

Limitations:

- output only; no sink chooser, default-sink switching, input source/mic controls, per-app streams, balance, EQ link, or device profile;
- service logic and icon helpers are duplicated between the slider, OSD, and unwired shelf;
- the Waybar scroll control allows up to 130% while the control-center slider clamps at 100%, creating inconsistent state/interaction;
- the OSD uses a full-width bottom layer window. With no explicit input mask, its transparent strip can intercept pointer input across the bottom of the screen while visible; the final source should use a tightly sized surface or input region from a proven community pattern.

For §6's compact audio panel, the slider and native PipeWire tracking are directly valuable. Output/input selection and EQ must come from other sourced components.

### 6. Brightness slider

**File:** `.config/quickshell/modules/controlcenter/BrightnessSection.qml`

Brightness availability and values come from `brightnessctl`. The parser correctly matches brightnessctl's machine-readable order: device, class, current, percentage, maximum. The UI mirrors the volume pill and supports click/drag changes.

The main weakness is process reuse during a drag. Every pointer movement changes `setProc.command` and sets `running = true`; if the previous `brightnessctl` invocation is still running, another start is not guaranteed. Intermediate and even the final pointer value can be skipped. This needs a coalesced/queued write or a service object from another community source. There is also no brightness OSD.

### 7. Notification service, toasts, and history

**Files:**

- `.config/quickshell/modules/notifications/NotificationService.qml`
- `NotificationToastLayer.qml`
- `NotificationPopup.qml`
- `NotificationCenter.qml`
- `NotificationItem.qml`

`NotificationService.qml` is a real service singleton and the most separable backend in the repo. `NotificationServer` claims `org.freedesktop.Notifications`, retains incoming notification objects, prepends plain JS records into an in-memory array, emits a signal for the toast layer, and writes a count into `/tmp/qs-notif-count` for Waybar. The server supports body text but explicitly advertises no actions and no body markup.

The toast layer is a top-right 400-pixel-wide overlay containing 360-pixel cards. Each new notification gets an auto-dismiss timer. Auto-dismiss removes only the toast, intentionally retaining the history entry. Manual toast dismissal removes the history item too. The notification center is an independent bottom-right sliding panel with a scrollable list, relative timestamps, individual dismiss buttons, empty state, and clear-all.

What it does well:

- correctly uses QuickShell's notification server rather than scraping another daemon;
- clean singleton/view boundary compared with the other service areas;
- distinct transient and history surfaces;
- urgency is retained and critical notifications get error coloring;
- `keepOnReload: true` attempts to preserve tracked notification objects across shell reload;
- notification count is exposed to the persistent shelf.

What is missing or broken:

- `actionsSupported: false`; no action buttons, default action, inline reply, or resident behavior;
- app icons and notification images are captured only partially (`appIcon` is stored as `iconPath`) and never rendered;
- no grouping by application, collapsing, swipe dismissal, or body-copy action;
- no real DND flag or toast suppression; the control-center DND tile talks to the Dunst instance this singleton kills;
- no routine-event filter, including the home-Wi-Fi boot noise rejected in §5;
- no on-disk history; the plain JS list lasts only for the current QuickShell process generation;
- no history cap, so the array can grow without bound during a long session;
- no handling of the notification object's `closed` signal, so an application-requested close can leave stale JS history;
- transient notifications are added to history even though transient messages should normally skip persistence;
- notification replacement/update semantics are not modeled explicitly;
- no maximum toast count/height, and no toast exit animation;
- the service spawns a shell process to update a temporary count file and signal Waybar on every add/remove; bursts can race because a single `Process` instance is reused.

QuickShell's [`NotificationServer`](https://quickshell.org/docs/master/types/Quickshell.Services.Notifications/NotificationServer/) exposes the capabilities this implementation leaves disabled, while each [`Notification`](https://quickshell.org/docs/master/types/Quickshell.Services.Notifications/Notification/) exposes actions, images, transient/resident state, inline reply, close reasons, dismiss, and expiry.

#### Comparison with Caelestia

The cxOrz service is a useful minimal receiver, but Caelestia is materially more complete for the target notification UX already selected in §6:

| Capability | cxOrz | Caelestia research result |
|---|---|---|
| QuickShell notification server | Yes | Yes |
| Toast + separate history surface | Yes | Yes |
| Actions/default action | Disabled | Implemented |
| App grouping | No | Implemented with expandable groups |
| Images/icons | Not displayed | Implemented |
| DND | Broken external-daemon toggle | Native service policy |
| Persistent/history model | In-memory flat JS list | Persistent service/history data |
| Swipe/body copy | No | Implemented |
| Fullscreen/click policy | No | Implemented |
| Routine-event semantic suppression | No | Also still requires an added filter |

The most defensible combined use is cxOrz's small server ownership/count bridge only if synthesis values its simplicity, with Caelestia's notification model/actions/grouping behavior adapted on top. Caelestia's service may make even that cxOrz slice redundant after dependency comparison. The cxOrz visual cards are below the required quality without substantial restyling.

### 8. Power menu

**Files:** `.config/quickshell/modules/powermenu/PowerMenu.qml`, `PowerButton.qml`

The power menu is a full-screen dim overlay with a centered translucent box and four large keyboard/mouse-accessible tiles: shutdown, reboot, lock, suspend. Actions use QuickShell `Process.startDetached()`, so they are not tied to shell lifetime. Outside click and Escape close the surface; arrows/Tab select actions and Enter/Space invokes them.

The 0.93→1 scale plus opacity entrance is a good compact interaction reference. Closing sets the `Loader` inactive immediately, so there is no exit animation. There is also no confirmation/hold treatment for destructive actions, logout, battery detail, brightness/volume, power profiles, or display controls. It is a power action dialog, not the System/Power dropdown required by §6.

### 9. QuickShell launcher

**Files:** `.config/quickshell/modules/launcher/Launcher.qml`, `AppIcon.qml`, `scripts/resolve-icons.sh`

The current launcher is QuickShell-based despite the stale README. It uses `DesktopEntries.applications`, filters hidden entries, sorts alphabetically, and searches names, generic names, comments, and keywords. It stores five recent application names in `~/.cache/quickshell/recent-apps.txt`, offers keyboard grid navigation, executes desktop entries through QuickShell, and closes on launch.

The surface is an independent full-screen overlay with outside-click dismissal and Escape, so it meets the interaction principle better than the current Rofi launcher described in the bug log. It has a 200 ms upward slide/fade and 80–150 ms microinteractions.

The icon resolver is unsuitable for the target hardware and Nix store layout. At QuickShell startup it scans every desktop entry, then for each distinct icon name runs `find` across several traditional filesystem icon roots. This is potentially many complete directory walks, ignores XDG theme inheritance, assumes `/usr/share/icons`/`/usr/share/pixmaps`, and performs poorly on a dual-core system. QuickShell's native icon lookup or the selected Caelestia launcher stack is preferable. The launcher also lacks action/file/settings search, ranking, favorites/pinned apps, drag behavior, and the stronger animation/polish of the leading Caelestia candidate.

This launcher is a useful bonus finding but should not displace the established §6 candidate.

### 10. Shelf and Waybar

**Files:** `.config/quickshell/modules/shelf/*`, `.config/waybar/*`

There are two shelf implementations, but only Waybar is active.

The unwired QuickShell `Shelf.qml` is a 48-pixel bottom `PanelWindow` with a workspace indicator, centered search button, status area, and system tray. It does **not** contain pinned apps or running tasks. Its workspace dots animate width/color, and tray items support left activation and right menu display. `StatusArea.qml` polls Wi-Fi and Bluetooth every five seconds, reads a fixed `/sys/class/power_supply/BAT0`, tracks volume natively, and displays a clock. It duplicates service logic already present elsewhere. `SearchButton.qml` invokes Rofi through a hard-coded `/home/mcx/...` theme path. Because `shell.qml` never constructs `Shelf`, none of it is current runtime behavior.

The actual Waybar shelf has left launcher/workspaces, center active-window title, and right tray, notification count, date, clock, volume, network, Bluetooth, battery, and power icon. Network/Bluetooth/volume/battery clicks open the same control center. Its 48-pixel height and grouped pills look properly spaced in the previews, which is useful evidence for §5's bar hit-target concern.

It is not the target top bar: it is bottom-aligned, has no pinned quick launches, running-task region, media/source-app controls, CPU/RAM, separate panel dispatch, System group, draggable workspace targets, or window controls. The desktop-only custom power module has no click handler. For §6's vertical sidebar/dock, this shelf offers no pinned/running app model and should not compete with DankMaterialShell.

### 11. Theme switcher and peripheral configs

**Files:** `Theme.qml`, `ThemeSection.qml`, `scripts/apply-theme.sh`, Kitty/Hyprland/Waybar/Rofi/Fcitx configs

Six fixed themes are present: Cobalt Night, Sage Forest, Rose Quartz, Amethyst, Amber Dusk, and Arctic Mist. The theme page lists swatches and changes the singleton key. A control-center `Connections` handler concurrently saves the key and runs `apply-theme.sh`.

The script generates/reloads:

- Waybar colors;
- Kitty's full 16-color palette, foreground, background, cursor, and selection;
- Hyprland active/inactive border colors;
- Rofi panel/accent/text colors.

QuickShell surfaces update reactively from `Theme.qml`. Hyprlock, Fcitx, GTK, Qt, Wofi, Yazi, wallpaper, and application themes are outside the pipeline. The six palette definitions are duplicated between `Theme.qml` and the shell script, so changes can drift. The application is sequential and not atomic: QuickShell changes immediately, while separate processes write/reload other surfaces. This falls far short of §3's wallpaper-adaptive universal palette requirement, though its semantic token naming is a useful small reference.

### 12. Lock/idle and other repo-level features

`hyprlock.conf` uses a screenshot background, two blur passes, brightness 0.56, a 90-pixel clock, a 25-pixel date, and a centered 300×60 input field. `hypridle.conf` locks after ten minutes and powers displays off after fifteen. For NixOS, the required PAM service is absent because this repo is Arch-oriented; §6's `security.pam.services.hyprlock` safeguard remains mandatory.

The repository also includes cliphist ingestion/selection, screenshot annotation through grim/slurp/satty, Yazi, Fcitx/Rime, a three-finger workspace gesture, and basic Hyprland move/resize/workspace bindings. These are peripheral to the assigned panel research. Several miss target requirements: clipboard history is deleted at every session start, screenshots do not implement clipboard plus timestamped PNG, there is no recorder, and four-finger/pinch gestures are absent.

## Service backend matrix

| Area | Actual backend | Update model | Separation | Major target delta |
|---|---|---|---|---|
| Wi-Fi | `nmcli` via `Process` | open + 8/10 s polling | UI/parser/actions combined | remove argv secret; add IP and real Mbps |
| Bluetooth | `bluetoothctl` via `Process` | open + 5 s polling | UI/parser/actions combined | fix race; add battery/forget/pair auth |
| Volume | QuickShell PipeWire + `PwObjectTracker` | event-driven | duplicated but compact | sinks, sources, streams, EQ |
| Brightness | `brightnessctl` | read on creation, writes on drag | combined | coalesced writes + OSD |
| Notifications | QuickShell `NotificationServer` | event-driven D-Bus receiver | true singleton | actions, grouping, DND, policy, persistence |
| Power actions | `systemctl`, `hyprlock` | direct detached commands | embedded in dialog | full System/Power detail and profiles |
| Battery | Waybar or dead shelf `BAT0` sysfs | Waybar/dead 5 s poll | not a QuickShell service | UPower, health/time/profile details |
| App discovery | QuickShell `DesktopEntries` | model-backed | launcher-local | remove filesystem icon scan |
| Tray | Waybar; QuickShell tray only in dead shelf | event-driven | bar-owned | target bar/sidebar integration |

The central architectural conclusion is that the repo contains good *flows* but only two true backend abstractions: notifications and QuickShell's underlying PipeWire objects. Wi-Fi and Bluetooth are large screen components with embedded subprocess adapters.

## Theming system

`Theme.qml` is a singleton with one `_themes` object and a selected `_t` reference. Widgets consume named slots rather than raw colors in most current QuickShell files:

- surfaces: `panelBg`, `panelBorder`, `surface`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceBright`;
- primary/secondary roles and on-colors;
- active/inactive tile roles;
- slider track/fill/thumb;
- primary/secondary text;
- semantic connected/error/toggle-off roles;
- shelf background;
- dimensions, radii, spacing, font sizes, and animation durations.

This semantic approach is sound, but the implementation is not a single source of truth across the OS. `apply-theme.sh` repeats every palette and terminal color. Some current UI still uses literal white overlays and literal error RGBA values. Older Rofi/Wofi/Fcitx/Hyprlock files have static colors. GTK is only pointed at an external fixed theme, Qt is delegated to `qt6ct`, and app-level themes are absent.

No wallpaper color extraction or accent pipeline exists. A wallpaper change does not change any palette. The theme selection changes fixed dark bases and accents together, contrary to the target decision to pin deep dark surfaces and adapt only accents. The script also provides no transaction boundary or rollback if a later surface update fails.

Directly useful pattern: widgets reference semantic roles and common dimensions. Not useful as the final universal architecture: duplicated palette definitions, incomplete consumers, fixed presets, and non-atomic propagation.

## Glass / transparency

The repo uses compositor blur behind translucent layer surfaces. QML does not implement its own blur shader/background effect.

| Surface | Background alpha / treatment | Border | Blur source |
|---|---|---|---|
| Control center | themed `panelBg` at 0.78 | themed dark border at 0.50 | Hyprland layer rule |
| Notification center | themed `panelBg` at 0.78 | themed dark border at 0.50 | Hyprland layer rule |
| Launcher | themed `panelBg` at 0.78 | themed dark border at 0.30 | Hyprland layer rule |
| Power box | themed `panelBg` at 0.82; screen dim 0.35 | opaque themed border | Hyprland layer rule |
| Volume OSD | themed `panelBg` at 0.92 | themed dark border at 0.45 | Hyprland layer rule |
| Dead QuickShell shelf | themed shelf base at 0.85 | none | Hyprland layer rule |
| Active Waybar | themed base at 0.80 | top border at 6% text | Hyprland layer rule |
| Generated Rofi | themed base/container at 0.80 | theme-dependent | Hyprland layer rule |
| Internal cards/tiles | mostly opaque palette colors | selected/error cases | no local glass depth |

Hyprland's global blur uses size 4 and two passes. Relevant layer rules set `blur = true` and `ignore_alpha = 0.5`; Rofi uses 0.2. The lock screen separately uses two screenshot blur passes and brightness 0.56.

The previews confirm visible wallpaper through the large outer surfaces, especially the launcher and shelf. Internal cards remain flat and opaque, and the OSD is almost solid. Against `MASTER_REQUIREMENTS.md` §3, this is more opaque and much less diffuse than the starting target of roughly 0.55–0.65 surface alpha and 12–16 pixel blur. There is no luminous aurora border, background gradient, xray, noise, layered highlight, or wallpaper-adaptive tint. This repo is a functional glass baseline, not the glass quality reference.

## Animations / motion

The global QuickShell duration tokens are 120 ms fast and 200 ms standard. Exact component motion includes:

| Interaction | Properties | Timing / easing |
|---|---|---|
| Control/notification panel open | `y` from shelf edge | 200 ms OutCubic |
| Control/notification panel close | `y` into shelf | 200 ms OutCubic, then unload |
| Control-center page change | `x` | 200 ms OutCubic |
| Toggle switch | thumb `x`, track color | 200 ms InOutQuad / color |
| Feature tile state | color | 120 ms |
| Wi-Fi/BT scan | rotation | 1000/1200 ms linear loop |
| Volume fill | width | 80 ms |
| Launcher open | `y` + opacity | 200 ms OutCubic |
| Launcher close | `y` + opacity | 200 ms InCubic |
| App press | scale 1→0.93 | 80 ms OutCubic |
| Toast enter | `y -16→0` + opacity | 200 ms OutCubic / OutQuad |
| Toast exit | none | immediate removal |
| Volume OSD enter | `y 14→0` + opacity | 220 ms OutCubic / 180 ms OutQuad |
| Volume OSD exit | opacity | 200 ms InQuad |
| Power menu enter | scale 0.93→1 + opacity | 200 ms OutCubic |
| Power menu exit | none | immediate Loader destruction |
| Waybar workspace | width/color | 300 ms / CSS ease |

Hyprland defines `easeOutQuint`, `easeInOutCubic`, `linear`, `almostLinear`, and `quick` compositor curves, then applies them to windows, fades, layers, workspaces, borders, and zoom. Those compositor animation speeds use Hyprland units rather than QML milliseconds.

The everyday timing aligns well with §3's 160–300 ms control target. The motion vocabulary is basic: slides, fades, color changes, scale presses, and spinner rotation. There are no geometry/content morphs, coordinated cross-fades between subviews, spring effects, list insertion/removal transitions, or cinematic entrances. It does not approach ilyamiro-level fluidity. Missing exit motion on power and toast surfaces is especially noticeable in code quality terms.

## Coordinator / dismissal behavior

All four major interactive panels have explicit IPC handlers. Waybar and Hyprland call `qs ipc call <target> <method>`.

Mutual exclusion is handled centrally in `shell.qml`, while each component owns its own visibility/open-animation state. Control center, notification center, and launcher retain the layer window during their 200 ms exit and unload afterward. The power menu instead loads only while `menuOpen`, so closing destroys it immediately.

Click-away dismissal is real: every major popup creates a full-screen overlay `PanelWindow`, puts an outside-click `MouseArea` behind the visible panel, and blocks propagation inside. Escape works. This directly satisfies §2's behavior, but it differs from Caelestia's `HyprlandFocusGrab`: cxOrz takes exclusive keyboard focus in a full-screen layer window. That is simpler and works on the single target display, but each open panel temporarily owns a screen-sized input surface rather than allowing the compositor focus model to clear a smaller popup naturally.

The current coordinator does not include subpanels such as a separate audio/network/power set because those are pages inside one control center. For the target's independent dashboard panels, the shell-level mutual-exclusion pattern is portable, while the current control-center hub/page composition is not the desired final architecture.

## What's directly usable for our build

| Requirement | Repo artifact | Direct value | Required adaptation |
|---|---|---|---|
| §2 click-away + Escape | panel wrappers in `ControlCenter.qml`, `NotificationCenter.qml`, `Launcher.qml`, `PowerMenu.qml` | verified mouse dismissal and keyboard path | retain an independent surface per target panel; compare full-screen overlay cost with focus-grab candidate |
| §3 everyday motion | common 120/200 ms tokens and slide/fade/scale patterns | timings already in target range | replace flat slides with selected morph patterns; add exits |
| §5/§6 compact audio panel | `VolumeSection.qml` | native event-driven PipeWire volume/mute and good 44 px pill target | add sink/source selection, mic, EQ access; unify 100/130% policy |
| §6 Audio OSD | `VolumeOsd.qml` | reacts to external/default-sink changes, clear auto-dismiss | use a non-blocking/tightly sized input surface; retheme to target glass |
| §6 Network panel | `WifiSection.qml` | scan/list/sort/connect/disconnect/forget/radio user flow | remove argv secret, add saved-profile identity, IP and real Mbps, richer errors |
| §4.7/§6 Bluetooth | `BluetoothSection.qml` card/flow structure | power, paired/nearby, pair/trust/connect/disconnect | replace racing poller with current QuickShell BT objects or stronger sourced service; add battery and forget |
| §5/§6 notifications | `NotificationService.qml` | compact QuickShell DBus ownership, tracked objects, toast/history split | add Caelestia grouping/actions/DND/policy/persistence and routine suppression |
| §6 System/Power | `PowerMenu.qml` | detached power commands, large targets, keyboard and click-away | use only the action slice inside the richer sourced System panel; add confirmation semantics if source provides them |
| §6 dashboard architecture | `shell.qml` coordinator | independent major `PanelWindow` surfaces and explicit exclusivity | extend to the selected independent dropdown set rather than carrying control-center hub navigation |
| §3 token discipline | `Theme.qml` role names and shared dimensions | widgets mostly avoid raw palette literals | map to the selected universal palette source; do not carry duplicated preset script as authority |
| §5 bar sizing | Waybar 48 px shelf and 64 px control tiles | visual evidence of comfortable hit targets | geometry reference only; target bar contents/location differ |

Bonus finding: `FeatureTile.qml`'s split toggle/detail hit zones are a particularly good mouse-first control pattern. It avoids burying the radio toggle and the device list behind the same ambiguous click, directly supporting §2's progressive disclosure.

Bonus finding: `DesktopEntry.execute()` in the QuickShell launcher avoids the Waybar-child lifetime problem identified in §5. The selected Caelestia launcher remains stronger overall, but cxOrz independently confirms that a QuickShell-owned launcher can launch through desktop-entry semantics instead of fragile shell children.

## What's NOT useful and why

- **The visual theme unchanged:** rose/pastel MD3, monospaced UI, opaque inner cards, and flat fills do not meet the target's dark aurora glass or typography direction.
- **The QuickShell shelf as the target dock:** it is unwired, contains no apps/tasks, duplicates status polling, and has a hard-coded author home path. It cannot satisfy §6's sidebar/dock.
- **The complete control-center hub:** the target requires independent dropdown surfaces. Reuse flows/components, not the hub as the final information architecture.
- **The current DND implementation:** it controls Dunst after the QuickShell service kills Dunst. It has no effect on the actual toast/history path.
- **The current icon resolver:** repeated filesystem-wide icon scans are both Nix-incompatible and wasteful on the target CPU.
- **The theme script as universal palette infrastructure:** it duplicates palettes, updates only a subset of surfaces, has no wallpaper input, and is non-atomic.
- **The current notification cards as final UI:** they lack actions, icons/images, grouping, swipe behavior, rich policy, and polished exit motion. Caelestia is clearly stronger.
- **The Rofi/Wofi surfaces:** retained older implementations; the current shell already replaced them, and Rofi cannot provide the target click-away behavior.
- **The lock screen as the target design:** pleasant but too sparse and does not include the required choreography/status/avatar/vignette. Only its blurred screenshot legibility is a minor reference.
- **The installer:** it is an interactive Arch package/symlink installer, not a NixOS/Home Manager source. Individual config assets are the useful material.
- **Repo-wide Hyprland config replacement:** although current Lua syntax matches 0.55, it omits target-specific T2/hardware/input invariants and is not scoped as a component. Only relevant layer rules/IPC bindings are reference material.

## What's missing relative to `MASTER_REQUIREMENTS.md`

Within §6 Dropdown Panels, cxOrz covers only partial Network, Bluetooth, Audio, and power actions:

- **Network missing:** IP, actual link/traffic speed in Mbps, interface/device details, gateway/DNS, captive portal/connectivity state.
- **Bluetooth missing:** device battery, forget/unpair, reliable multi-device state, interactive pairing/passkey, device-specific icon/profile details.
- **Audio missing:** output selector, input selector, microphone controls, per-stream controls, EQ entry/integration.
- **System/Power missing:** battery details, time remaining, health, brightness integration in the actual power page, volume grouping, power profiles, logout, and a structured system page.
- **Display entirely missing:** resolution, refresh rate, scale, output selection.

Other major target gaps include media/MPRIS, EQ/cava, calendar, CPU/RAM/process views, source-app media controls, pinned/running dock, actual network throughput, battery backend, screen recording, full screenshot flow, app-level themes, wallpaper/palette pipeline, gestures beyond three-finger workspace, per-window controls, task drag/drop, removable-media UX, and system-wide search.

The notification backend does not satisfy action buttons, grouping, persistent history, working DND, or routine-event filtering. The power menu does not substitute for the required System button grouping.

## Compatibility notes

### Hyprland 0.55 Lua

The compositor configuration is already native Lua and explicitly targets Hyprland 0.55+, so namespace, layer-rule, and IPC-binding patterns are directly legible against the target. The relevant portable delta is small: retain the target's existing Lua configuration and adapt only layer rules for selected QuickShell namespaces plus dispatch bindings. The repo's full config must not replace target input, T2, display, or working-state invariants.

### QuickShell version

The repo does not pin a QuickShell release or provide a Nix package definition. It assumes APIs including `IpcHandler`, `NotificationServer`, `DesktopEntries`, `PwObjectTracker`, `PanelWindow`, and layer-shell enums. Those must be checked against the exact NixOS QuickShell derivation selected for the build.

QuickShell 0.3 materially improves the portability choice because it includes native NetworkManager and BlueZ-facing modules. For this target, adapting the cxOrz Wi-Fi/BT presentation to those current community APIs is safer and more complete than preserving CLI polling. If the selected NixOS package lacks the modules, the report's stdin fallback and a stronger community Bluetooth service remain necessary.

### NixOS service/package delta

The interactive installer and Pacman/AUR list are not used. The QML components require their commands/services to be declared in NixOS/Home Manager and available in QuickShell's runtime `PATH`: QuickShell, NetworkManager tools, BlueZ tools, PipeWire/WirePlumber, brightnessctl, Hyprlock, and the selected bar/notification ownership. Dunst must not be enabled alongside a QuickShell `NotificationServer` claiming the same bus name.

NetworkManager and BlueZ operations also depend on their system services and user authorization. Brightness writes depend on logind/udev permissions. These are configuration prerequisites, not reasons to embed privilege escalation in QML.

The repo's portal helper uses hard-coded `/usr/lib` executable paths that do not map to Nix store paths. It is unrelated to the panel slices and should not be carried.

### Paths and XDG layout

`resolve-icons.sh` searches `/usr/share/icons`, `/usr/share/pixmaps`, and a few fixed themes. NixOS packages commonly expose icons through profile paths/XDG data directories, so this resolver is not portable. `SearchButton.qml` hard-codes `/home/mcx`; it is also dead code. Other `$HOME/.config` paths are conventional but should map through the chosen Home Manager/source layout rather than assuming a mutable symlinked repo.

The dead shelf assumes `BAT0`. That name is not portable across laptop drivers. QuickShell's UPower service exposes a default laptop battery and fields such as percentage, time, health, and charge rate through [`UPowerDevice`](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/UPowerDevice/), which better matches §6 and avoids device-name assumptions.

### Retina scaling and typography

All sizes are fixed logical pixels with no density/font scale token beyond hard-coded font sizes. On a 1.5× 2560×1600 display, layer-shell logical coordinates should scale, but the five-column launcher's fixed 698-pixel width, 780-pixel cap, tiny 9–12 pixel secondary text, and monospaced UI require visual calibration. The source has no responsive column count or screen-size variant. The single-display target avoids its lack of per-screen `Variants`, but a future multi-display port would need a sourced multi-screen wrapper.

### Performance on dual-core i3 / Iris Plus / 8 GB

The ordinary panels use simple rectangles and low-cost property animations; no custom shaders are present. Their rendering burden is modest. The main avoidable costs are process polling and icon scanning:

- Wi-Fi, Bluetooth, DND, and brightness spawn repeated CLI processes while relevant panels are visible.
- The dead shelf would duplicate Wi-Fi/BT/battery polling continuously.
- The launcher icon resolver performs many recursive filesystem scans at startup.
- Hyprland blur is only size 4/two passes, explaining both the modest cost and the less diffuse visual result.

Native QuickShell NetworkManager/BlueZ/UPower objects remove much of the polling overhead. Any increase from the repo's blur settings toward the target visual specification still requires later hardware measurement, as required by §10; this research does not infer that cost.

### Target behavior invariants

No adaptation should import the repo's input choices wholesale. It uses `follow_mouse = 1`, only natural-scroll false, a three-finger workspace gesture, and no target-specific touchpad protections. Its session startup deletes clipboard history, contrary to §4.3. Its Hyprlock config has no NixOS PAM declaration. These are explicit incompatibilities, not candidate settings.

## Key files to vendor/adapt

Ranked by value for the target rather than raw visual size:

1. **`modules/controlcenter/VolumeSection.qml`** — strongest compact component. Carry native PipeWire tracking, mute, slider interaction, sink label, and icon thresholds. Adapt tokens, add selector/mic/EQ dependencies, and unify maximum-volume policy.
2. **`modules/notifications/NotificationService.qml`** — compact baseline for QuickShell bus ownership and tracked notification objects. Carry only after adding close/transient/replacement policy and comparing against Caelestia's more complete service; enable/actions/grouping/DND belong to the Caelestia-derived slice.
3. **`modules/controlcenter/FeatureTile.qml`** — reusable, well-sized split toggle/detail interaction. Retheme and use within independent panels/System controls.
4. **`modules/osd/VolumeOsd.qml`** — useful event-trigger and entrance/dismiss timing. Adapt to a tight/nonblocking surface and the chosen glass tokens.
5. **`modules/controlcenter/WifiSection.qml`** — carry the visible list/sort/inline interaction flow, not the current argv command. Prefer adapting its model/actions to QuickShell 0.3 Networking; add IP/Mbps and connection-profile identity.
6. **`modules/controlcenter/BluetoothSection.qml`** — carry the paired/nearby card hierarchy and pair/connect flow only. Replace the single-process polling backend with current community BlueZ objects, then add battery and forget.
7. **`shell.qml` plus the wrapper/state portions of `ControlCenter.qml` and `NotificationCenter.qml`** — source for IPC, mutual exclusion, outside click, Escape, clipped shelf-edge entrance, and unload-after-exit. Adapt the coordinator to independent target panels and compare full-screen overlays with HyprlandFocusGrab.
8. **`modules/powermenu/PowerMenu.qml` and `PowerButton.qml`** — carry detached command invocation and large keyboard/mouse action tiles into the selected System surface. Do not adopt it as the complete power panel.
9. **`Theme.qml`** — use its semantic role/dimension inventory as a cross-check only. Map widgets to the selected universal palette source instead of carrying the duplicated six-preset authority.
10. **`hyprland.lua:305–312` layer rules** — small compatibility reference for applying Hyprland blur to QuickShell namespaces. Retune alpha/blur through the target's selected glass architecture and hardware test gate.

Files not worth vending for the target are `modules/shelf/*`, `resolve-icons.sh`, the Rofi/Wofi remnants, the interactive installer, static peripheral themes, and the complete Hyprland configuration.

## Bottom line

cxOrz is valuable, but more narrowly than the guide's phrase “service backends” suggests. It supplies usable interaction flows and working system command adapters for Wi-Fi/Bluetooth, an actually clean native PipeWire volume slice, a small QuickShell notification receiver, independent overlay panels with real click-away dismissal, and well-sized MD3 controls.

It is not a drop-in backend suite. Wi-Fi and Bluetooth are tightly coupled CLI/UI files; the Wi-Fi secret is exposed in argv; Bluetooth multi-device checking races; notification DND is disconnected from the active server; the notification feature set is far behind Caelestia; the QuickShell shelf is dead code; and the palette/visual system needs major replacement. For synthesis, rank the volume component and split-tile/panel mechanics highly, treat Wi-Fi/BT as UI-flow sources that require current QuickShell service compatibility conversion, and treat notifications as a minimal backend candidate beneath Caelestia's grouping/policy layer.
