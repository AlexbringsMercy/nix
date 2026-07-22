# Execution log

> **Current handoff:** the authoritative post-reboot state is recorded in
> “2026-07-16 — full implementation and handoff report” at the end of this
> file. Earlier statements that no live activation had occurred are historical
> and are superseded by that report.

## 2026-07-15 — migration started

- Cloned remote commit `4974921ba3d7d5602b3b2aa2513955f7ec0f770f`.
- Created branch `codex/macbook-desktop`.
- Backed up live NixOS and user desktop configuration to
  `/home/alex/.local/state/codex-backups/macbook-desktop-20260715-234753`.
- Preserved the active channel-based `/etc/nixos` configuration as recovery.
- Began pinned flake, Home Manager, and local-firmware-wrapper migration.
- No active system generation or live desktop configuration changed yet.

## 2026-07-16 — media, weather, and adaptive-theme slice

- Added native QuickShell MPRIS selection/metadata stabilization, visible-only
  position tracking, and an on-demand Cava service (28 bars at 30 fps).
- Added independent lazy music and calendar/weather panels using the shared
  `PanelHost` contract. The music panel includes rotating album art, transport,
  seek, real Cava data, ten EQ bands, and eight presets; the calendar remains
  useful offline and fetches weather only when opened or manually refreshed.
- Added atomic EQ state and EasyEffects preset generation. Validated the
  generated modern `equalizer#0` preset against pinned EasyEffects 8.2.4:
  it appeared in `--presets`, loaded with exit status 0, and was returned by
  `--last-loaded-preset output`.
- Added HTTPS Open-Meteo normalization with a 900-second XDG cache. Live Chicago
  retrieval returned 12 hourly and 7 daily entries; cached retrieval took 22 ms;
  a forced simulated outage returned the last valid data marked stale.
- Added Matugen, awww, Waypaper, and lock-screen integration. A real pinned
  Matugen 4.0.0 render from `aurora-glass-night.png` produced all eight consumer
  fragments with palette `#05060b`, `#0b0e16`, `#5cccff`, `#00f3c2`, `#8b93f7`.
  Pinned awww 0.12.1 exposes every transition option used by the wrapper,
  including 30 fps, grow position, duration, and cubic bezier easing.
- QuickShell 0.3.0 loaded both lazy panels in a live Wayland smoke with no QML
  assignment/runtime errors. Cava 0.10.7 accepted its real PipeWire config.
  ShellCheck 0.11.0, Bash syntax checks, Nix parse, and nixfmt checks passed.
- No active system generation or live Home Manager generation was switched by
  this slice; final integration/build/activation is tracked by the root run.

## 2026-07-16 — independent QuickShell control surface

- Added a lazy, independent `PanelWindow` architecture for notifications,
  Wi-Fi, Bluetooth, volume, power, music, and calendar. A central coordinator
  provides mutual exclusion, Escape dismissal, click-away dismissal, and a
  stable typed IPC contract (`panels toggle wifi`, `panels toggle volume`, and
  the remaining panel names) for Waybar.
- Implemented native QuickShell notification, networking, BlueZ, PipeWire,
  UPower, and power-profile services. Network and Bluetooth discovery run only
  while their panel is open; audio is hard-clamped to 100%; brightness targets
  `intel_backlight`; password input is passed directly to the native Wi-Fi API
  rather than exposed in a subprocess argument list.
- Added freedesktop-correct notification timeout, replacement, action, inline
  reply, transient, urgency, history, unread, and do-not-disturb behavior. The
  QuickShell notification server owns the D-Bus name during normal operation;
  Dunst is an inactive systemd fallback started only when the shell service
  fails, preventing dual-daemon contention.
- Live Wayland smoke tests loaded every surface, exercised panel IPC and
  focus-grab dismissal, and verified notification replacement, action, unread,
  and DND flows over D-Bus. Focused `qmllint` completed successfully; remaining
  diagnostics are known QuickShell 0.3 QML type-metadata gaps, not runtime
  failures. Nix parsing and prohibited-command scans also passed.
- No active system or Home Manager generation was switched by this slice;
  activation remains with the root integration run.

## 2026-07-16 — user wallpaper collection and safe theme activation

- Replaced the provisional downloaded/generated wallpaper batch with twelve images
  selected exclusively from Alex's existing `~/Downloads` collection. Originals
  remain untouched; verified copies live as untracked personal data in
  `~/Pictures/Wallpapers/aurora-collection/` and are excluded from Git.
- The first palette test set was selected by measured Matugen output rather
  than filenames alone. It spans red, orange, gold, olive, green, seafoam,
  cyan, blue, violet, purple, neutral dark, and neutral light. The initial
  default is `violet-nokstella-stars.jpeg`; Waypaper exposes the collection.
- Switched Matugen from extracted source index 1 to the dominant source index 0
  after an isolated matrix showed that index 1 washed strongly red and green
  images toward gray/lilac. Dark `scheme-content` output and stable near-black
  glass roles remain in place while semantic accents now follow each image.
- Hardened `apply-wallpaper --theme-only` to exit before touching the wallpaper
  daemon or live clients. Removed Kitty signaling permanently after establishing
  that `SIGUSR1` terminates this Kitty build; existing terminals remain untouched
  and new terminals read the generated include normally.

## 2026-07-16 — final integration and pre-cutover validation

- Completed mouse-path and runtime audits across Waybar, every QuickShell panel,
  Rofi, window controls, session actions, wallpaper selection, and screenshots.
  Added a persistent music/EQ button, pointer-accessible capture controls,
  single-click launcher activation, non-destructive task interactions, and a
  300 ms capture delay so the closing power panel cannot appear in screenshots.
- Ordered Waybar after the QuickShell service and added a bounded IPC-readiness
  probe. The Hyprland session import includes its instance signature, ensuring
  systemd-launched Waybar modules and `hyprctl` controls can reach the compositor.
- Removed duplicate output-volume OSDs: function keys now change PipeWire through
  `wpctl`, QuickShell owns the output OSD, and SwayOSD remains for brightness and
  microphone feedback. Startup backend changes are suppressed for 500 ms.
- Made residual Waybar, SwayOSD, and screenshot-selector accents consume the
  generated semantic palette. Normal wallpaper changes may restart only already
  active lightweight OSD/fallback services; theme-only activation cannot cross
  that runtime boundary.
- Passed flake evaluation, Home Manager builds, Hyprland native-Lua verification,
  generated systemd-unit verification, JSON/Rofi parsing, Bash/ShellCheck, focused
  QML lint, and isolated Matugen renders for all twelve wallpapers. Known QML
  diagnostics are QuickShell/Qt metadata inference warnings; there are no errors.
- Built the firmware-backed NixOS closure with linux-t2 6.18.35, all 163 local
  Broadcom firmware files, QuickShell 0.3.0, and `nix-ld` 2.0.6 present. No NixOS
  or Home Manager generation has been activated on the live desktop.

## 2026-07-16 — native Hyprland IPC cutover correction

- Installed the first validated closure as systemd-boot generation 8 without
  switching the running generation 7 desktop. The active session and its Kitty
  and Chrome processes remained untouched.
- The real installer-window launch exposed a final Hyprland 0.55 boundary: CLI
  `dispatch` calls are Lua expressions even though legacy dispatcher strings can
  survive static JSON and Nix validation. Audited every `hyprctl` invocation and
  converted Waybar float, pin, maximize, fullscreen, and close actions plus all
  Hypridle DPMS actions to native `hl.dsp.*` expressions.
- Confirmed every replacement against the pinned Hyprland dispatcher API and
  exercised the exact constructors through compositor IPC using a deliberately
  nonexistent window selector; all parsed and returned success without changing
  a live window. The display-enable form was also checked safely while the panel
  was already awake.
- Generation 8 remains a valid recovery entry, but it is superseded for the first
  reboot by the corrected generation built and installed after this audit.

## 2026-07-16 — full implementation and handoff report

This section is the durable current-state report for a proceeding Codex chat. It
records the implemented design, deployment history, verified live state,
failures, recovery points, and unfinished acceptance work. Read it together with
`BUILD_PLAN.md` for design intent and `SOURCES.md` for recorded community
provenance. When an older section conflicts with this one, this section wins.

### Executive state

| Item | State at 2026-07-16 03:15 CDT |
|---|---|
| Host / user | `macbook` / `alex` |
| Repository | `/home/alex/nix` |
| Branch | `codex/macbook-desktop` |
| Implementation commits | `ec87817`, `f32e320`, `c566923`, `25d26e5` |
| Remote state before this report | Local feature branch four commits ahead of locally recorded `origin/main`; not pushed and no upstream branch |
| Running system | Generation 9, `/nix/store/qb1wjwmh9pi0llyazp5hvaad4cz55cd5-nixos-system-macbook-26.11.20260616.567a49d` |
| System profile / next boot | Generation 10, `/nix/store/9lwy876aicmfpcy65q3g499fah2yg9gv-nixos-system-macbook-26.11.20260616.567a49d` |
| Live Home Manager | `/nix/store/kyl34kvnyja47jrc9fry53w25dq65kaa-home-manager-generation` |
| Kernel | `linux-t2 6.18.35` |
| Desktop | Hyprland 0.55.4 native Lua, Waybar 0.15.0, QuickShell 0.3.0 |
| Display | 2560x1600 at 60.001 Hz, 1.5 scale, 1707x1067 logical |
| Default wallpaper | `violet-nokstella-stars.jpeg` |
| System/user failed units | None at audit time |
| Main status | Implementation deployed; live functional acceptance is incomplete |

Generation 10 is already the systemd-boot default, but the machine has not
rebooted since it was installed. Therefore `/run/current-system` correctly still
points to Generation 9. Native Lua evaluation and a renderer reload applied the
Retina fix first; two direct Home Manager activation-package runs then persisted
it in the managed live configuration. Reboot is not needed to keep using the
current session. A coordinated reboot is still required to prove Generation 10
boots, activates its integrated Home Manager service correctly, and removes the
temporary Generation 9 plus standalone-Home-Manager split.

### User-approved architecture and design decisions

- QuickShell is present from day one. SwayNC was not installed. Dunst is a small
  permanent failure fallback and remains inactive while QuickShell owns
  `org.freedesktop.Notifications`.
- Waybar remains the permanent glass taskbar and the primary click surface.
  QuickShell supplies independent dropdown `PanelWindow` surfaces for Wi-Fi,
  Bluetooth, volume, power, notifications, music/EQ, and calendar/weather.
- The build deliberately rejects ilyamiro's single morphing hub. Different
  widgets do not morph into one another; individual panels may animate and
  progressively disclose their own contents.
- Community code and interaction patterns were inspected and adapted directly,
  including unlicensed repositories when technically useful. `SOURCES.md`
  records origins and revisions.
- Every phase is additive. No temporary SwayNC/control-center layer was built to
  be removed later.
- The visual direction is dark aurora glass: true and near blacks, deep blue and
  purple, teal/seafoam and dark green, wallpaper-derived accent light, smooth
  gradient bleed, translucency, blur, moderate rounding, and Raycast-like
  restraint. It is not a flat corporate-navy theme.
- Basic operations have pointer paths. Keyboard shortcuts are accelerators, not
  the only way to launch apps, manage windows, change system state, or reach
  controls.
- The MacBook exposes only workspaces 1 and 2. The configuration is for the
  internal Retina panel only; the future Alienware/dual-monitor port is a
  separate project.

### Repository and machine-local layout

- Public configuration repository: `/home/alex/nix`.
- Machine-local flake wrapper: `/home/alex/.config/nixos-local`. It injects the
  proprietary firmware tree as a non-flake input.
- Proprietary Apple/Broadcom firmware source:
  `/etc/nixos/firmware/brcm`, 163 files. It is not in Git.
- Personal wallpapers:
  `/home/alex/Pictures/Wallpapers/aurora-collection`, twelve curated copies from
  Alex's existing Downloads. The originals were not changed, and no wallpaper
  binary is tracked by Git.
- Pre-migration backup:
  `/home/alex/.local/state/codex-backups/macbook-desktop-20260715-234753`.
  It contains the old `/etc/nixos` configuration and the prior Hyprland,
  Waybar, Kitty, Rofi, and Fish files.
- The original channel-style `/etc/nixos` tree remains available as a recovery
  path. Do not delete it yet.
- Generated theme state is under `~/.cache/aurora-theme`; EQ state is under
  `~/.local/state/aurora-shell`; screenshots are under
  `~/Pictures/Screenshots`.
- Legacy inactive Hyprland files still exist at
  `~/.config/hypr/hyprland.conf` and
  `~/.config/hypr/hyprland.lua.hm-before-aurora`. The active entry point is the
  Home Manager symlink `~/.config/hypr/hyprland.lua`.

### NixOS and Home Manager platform work

- Replaced the old monolithic repository configuration with a pinned flake and
  module graph. `flake.nix` pins:
  - nixpkgs `567a49d1913ce81ac6e9582e3553dd90a955875f`;
  - nixos-hardware `fccfa9031a85b78a437f2f153c1f6449f3bc3185`;
  - Home Manager `165228b0efefc3e635e5174020c40ea64271dc25`.
- `lib.mkMacbook` supports a portable evaluation without local firmware and the
  actual machine-local wrapper build with firmware. The portable evaluation
  warns rather than pretending it contains the MacBook firmware.
- Home Manager is integrated into NixOS with `useGlobalPkgs` and
  `useUserPackages`. `backupFileExtension = "hm-before-aurora"` protects
  colliding user files.
- Preserved all critical invariants: Apple T2 nixos-hardware module,
  systemd-boot, no EFI-variable writes, macOS dual boot, local Broadcom
  firmware, `programs.nix-ld.enable = true`, `allowUnfree = true`, hostname
  `macbook`, user `alex`, Fish, NetworkManager, and Node.js 22.
- Added greetd auto-login through `start-hyprland`, PipeWire/Pulse compatibility,
  Bluetooth/Blueman, UPower, power-profiles-daemon, polkit, GNOME keyring,
  udisks/GVFS/tumbler, Hyprland and GTK portals, fonts, Chrome, Kitty, Thunar,
  zram, and laptop suspend policy.
- Chrome is the default HTTP/HTTPS browser and Thunar is the default directory
  handler. Chrome uses native Wayland through the system session variables.
- `~/.npm-global/bin` remains on the Home Manager session path. Live audit
  confirmed Codex CLI 0.144.4 and Claude Code 2.1.211 launch.

Important files:

- `flake.nix`: pinned system and Home Manager outputs.
- `hosts/macbook/`: host and hardware composition.
- `modules/nixos/base.nix`: boot, user, Nix, networking, and integrated HM.
- `modules/nixos/t2-firmware.nix`: machine-local firmware derivation.
- `modules/nixos/desktop.nix`: compositor and desktop services.
- `modules/nixos/laptop-power.nix`: zram and suspend behavior.
- `home/alex/default.nix`: Home Manager composition.
- `checks/preflight.sh`: portable evaluation plus firmware-backed closure gate.

### Hyprland implementation

- Hyprland 0.55 is configured exclusively through native Lua. The root file is
  `modules/home/hyprland/hyprland.lua`; modules under
  `modules/home/hyprland/hyprland/` cover environment, monitor/general,
  animation, input, window rules, keybindings, and autostart.
- Dwindle tiling is the default. Current geometry uses 5 px inner gaps, 8 px
  outer gaps, 2 px animated accent borders, 10 px rounding, snapping,
  border/corner resizing, and mouse move/resize fallbacks.
- Window open/close/move, workspace slide, fade, border, layer, and manual resize
  animations use coordinated curves adapted from the reference builds.
- The touchpad enables natural scrolling, tap-to-click, clickfinger right click,
  `disable_while_typing`, workspace swipes, and Apple-appropriate sensitivity.
- Only workspaces 1 and 2 are exposed. Three-finger horizontal swipe changes
  between them.
- Function-row volume, mute, brightness, keyboard-backlight, and media bindings
  are configured. Speaker volume uses `wpctl` and the QuickShell OSD; SwayOSD is
  retained for display brightness and microphone mute.
- Screenshots use Grim/Slurp and put PNG data on the clipboard as well as in
  `~/Pictures/Screenshots`.
- The lock key, mouse move/resize, float, maximize, fullscreen, close, workspace,
  application, screenshot, and power-panel bindings are documented in
  `docs/controls.md` and the operator guide.

#### Hyprland 0.55 IPC rule

Do not use legacy runtime dispatcher strings or `hyprctl keyword`. The Lua
parser rejects dynamic legacy keywords with “keyword can't work with non-legacy
parsers. Use eval.” Use native Lua forms:

```sh
hyprctl eval 'hl.config({ debug = { disable_scale_checks = true } })'
hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'
hyprctl dispatch 'hl.dsp.window.close()'
hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'
```

Static JSON, Nix, and even config parsing did not catch the original legacy
Waybar/Hypridle dispatch strings. Any new runtime action must be exercised over
the real compositor IPC before it is considered verified.

### Waybar implementation

Waybar is split visually into three glass groups across the top:

- Left: Apps, pinned Chrome/Kitty/Thunar, and running tasks.
- Center: workspaces 1/2, active title, float, maximize, fullscreen, and close.
- Right: CPU, memory, media transport/title, volume, Wi-Fi, Bluetooth, battery,
  clock/date, notification bell, tray, and settings-style status actions.

The app launcher and every core status area has a pointer action. QuickShell
panel calls use the stable IPC form `qs -c aurora-shell ipc call panels toggle
NAME`. Waybar waits up to five seconds for QuickShell IPC readiness at startup.
The Hyprland instance signature is imported into the systemd user environment so
systemd-launched bar actions can reach the compositor.

Intentional destructive actions:

- Center-bar X closes the currently focused window.
- Middle-clicking a running task closes that task immediately.
- On this touchpad, a three-finger tap is a middle click.

Opening a new app should only retile existing windows. Tiling itself is not a
close operation.

### QuickShell implementation

One supervised `aurora-shell` QuickShell 0.3 process owns independent surfaces:

- Wi-Fi: current connection, signal, address, list/scan, connect, password input,
  and advanced editor handoff.
- Bluetooth: adapter state, scan, paired/nearby device list, connect/disconnect,
  and Blueman handoff.
- Volume: output state, slider, mute, and advanced PipeWire mixer handoff.
- Power: battery, brightness, power profile, lock/sleep/reboot/shutdown holds,
  wallpaper picker, and pointer-accessible screenshots.
- Notifications: freedesktop server, toasts, replacement, timeouts, actions,
  inline replies, history, unread state, clear, and DND.
- Music/EQ: MPRIS player selection and metadata, rotating album art, transport,
  seek, on-demand real Cava waveform, ten EQ bands, and Flat/Bass/Treble/Vocal/
  Pop/Rock/Jazz/Classic presets.
- Calendar/weather: clock with seconds, month navigation/date selection,
  current conditions, hourly data, five-day forecast, and offline cache state.

`PanelCoordinator` enforces one open dropdown at a time. `PanelHost` provides
placement, staged opacity/position/scale animation, outside-click dismissal,
Escape dismissal, and the common glass surface. Expensive discovery and polling
are lazy: Wi-Fi/Bluetooth scan only while needed, Cava runs only while the music
panel is visible and playing, and weather fetches on panel demand/refresh.

The notification daemon fallback is deliberately not a bridge. Dunst is an
inactive failure unit that starts only if the QuickShell service fails, avoiding
two owners of the notification D-Bus name.

### Theming, wallpapers, and visual pipeline

- Alex supplied all active wallpaper files. Twelve palette-diverse copies were
  selected from `~/Downloads`: red, orange, gold, olive, green, seafoam, cyan,
  blue, violet, purple, neutral dark, and neutral light. Exact filenames,
  original mappings, expected Matugen primaries, and SHA-256 hashes are in
  `docs/wallpapers.md`.
- Waypaper is the mouse-driven browser. Its post-command calls
  `apply-wallpaper`.
- `apply-wallpaper` takes a lock, renders Matugen 4.0 dark `scheme-content`,
  validates every generated fragment, installs them atomically, stores the
  selected path, and transitions the background through awww 0.12.1.
- Generated consumers are QuickShell, Waybar, Kitty, Rofi, Hyprland, Hyprlock,
  GTK, Dunst fallback, SwayOSD, and screenshot selection styling.
- Stable near-black surface roles preserve the dark frosted-glass foundation;
  dominant source colors drive semantic primary/secondary/tertiary accents.
- Matugen source index 0 was selected after a real palette matrix. Source index
  1 washed strong red/green images toward gray/lilac.
- A normal wallpaper change reloads Hyprland and Waybar presentation and may
  refresh already-active lightweight OSD/fallback services. `--theme-only`
  returns before touching wallpaper or live client services.
- Never send Kitty `SIGUSR1`: it terminates this Kitty 0.47.4 build. Existing
  Kitty windows intentionally keep the palette they started with; new Kitty
  windows read the latest generated include.
- The initial and current wallpaper is
  `~/Pictures/Wallpapers/aurora-collection/violet-nokstella-stars.jpeg`.

### Kitty, Rofi, lock, idle, and helper workflows

- Kitty uses FiraCode Nerd Font, dark generated colors, 0.88 opacity, Hyprland
  blur, 10,000 lines of scrollback, tabs, and `copy_or_interrupt` so Ctrl+C copies
  selected text but interrupts when nothing is selected. Ctrl+V always pastes.
- Rofi is a generated dark-glass application launcher with icons,
  search-as-you-type, pointer launch, Escape dismissal, Apps-button access, and
  bare-Super/Super+D access.
- Hyprlock uses the current wallpaper and Matugen fragment with blur, vignette,
  large clock/date, avatar/user, password field, battery, and network status.
- Hypridle stages dim, lock, display power-off, and suspend. Lock/suspend/lid
  behavior still requires deliberate physical acceptance testing.
- `weather-fetch` uses the Open-Meteo HTTPS endpoint and a 900-second XDG cache.
  It returns cached data marked stale when retrieval fails.
- `equalizer-state` validates state, locks updates, generates a ten-band modern
  EasyEffects `equalizer#0` preset, and applies it asynchronously.
- `screenshot-area` waits 300 ms after the power panel dismisses so the panel is
  not captured; both screenshot helpers save and copy image/png.

### Community source integration

`SOURCES.md` is the canonical implemented-source ledger. Some entries retain an
abbreviated planning revision or repository name instead of a full URL; do not
claim stronger provenance precision than the file records. The important
combinations are:

- end-4/dots-hyprland: native Lua organization and motion language.
- LinuxBeginnings/Hyprland-Dots: Waybar glass layout and styling patterns.
- Frost-Phoenix/nixos-config: Nix/Home Manager wiring patterns.
- newmanls/rofi-themes-collection: launcher structure.
- cxOrz/dotfiles-hyprland: control-center cards, notifications, power behavior,
  volume OSD, shelf interaction grammar, and QuickShell control patterns.
- ilyamiro/nixos-configuration: music/EQ composition, coordinated QML animation,
  palette binding, and calendar/weather presentation. Its hub architecture and
  yellow-green palette were not copied.
- QuickShell upstream/examples: native notification, networking, BlueZ,
  PipeWire, UPower, focus-grab, lazy-loader, and typed IPC contracts.
- DankMaterialShell, Caelestia, iNiR, and Noctalia: focused lifecycle, popup,
  glass, and palette references rather than wholesale installations.
- Matugen, awww, Waypaper, EasyEffects, Cava, and Open-Meteo supply the permanent
  theme/media/weather backends.

No referenced shell was installed wholesale. The implementation adapts pieces
to the independent-panel architecture and local T2 constraints.

### Build and verification record

Static and isolated validation completed before activation:

- Nix parse, nixfmt, flake output evaluation, and Home Manager builds.
- Hyprland 0.55 native-Lua `--verify-config`.
- JSON, Rofi, Bash syntax, ShellCheck, and focused QML lint.
- Generated systemd user-unit inspection.
- Real Matugen renders across all twelve local wallpapers.
- QuickShell live Wayland smoke loading every surface and exercising typed IPC,
  panel exclusion, outside/Escape dismissal, notification replacement/actions/
  DND, and service initialization.
- Real Cava PipeWire config validation.
- EasyEffects 8.2.4 accepted and loaded the generated `equalizer#0` preset during
  the isolated pre-cutover test.
- Open-Meteo returned 12 hourly and 7 daily entries; cached response took 22 ms;
  simulated network failure returned the last valid data marked stale.
- `./checks/preflight.sh` repeatedly evaluated the public flake and built the
  firmware-backed system with conservative concurrency.
- The final preflight for Generation 10 produced
  `/nix/store/9lwy876aicmfpcy65q3g499fah2yg9gv-nixos-system-macbook-26.11.20260616.567a49d`.
- Its closure contains linux-t2 6.18.35, the local Apple/Broadcom firmware
  derivation, QuickShell 0.3.0, and nix-ld 2.0.6. The source firmware tree has
  163 files and the runtime combined firmware directory contains the required
  Apple BCM4377 data.
- Git gates reject tracked firmware files and tracked wallpaper binaries.

Post-reboot/live verification completed:

- Auto-login reached Hyprland under user `alex`.
- NetworkManager, Bluetooth, UPower, power-profiles-daemon, greetd, PipeWire,
  WirePlumber, and desktop portal/keyring/polkit services are present.
- `aurora-shell`, `aurora-wallpaper`, Waybar, Hypridle, SwayOSD, EasyEffects,
  PipeWire, PipeWire Pulse, and WirePlumber are active.
- `aurora-wallpaper-init` completed successfully; the Dunst fallback is inactive
  as intended.
- No failed system or user units were present at the handoff audit.
- Hyprland reports no config errors.
- Loaded hardware modules include `apple_bce`, `applesmc`, `hid_appletb_bl`,
  `hid_apple`, `hci_bcm4377`, `brcmfmac`, and `i915`. The boot journal records
  successful `aaudio` initialization; `/proc/asound/cards` exposes
  `AppleT2x2 / Apple T2 Audio`, and PipeWire exposes the T2 speaker/headphone and
  built-in/headset microphone nodes even though `aaudio` is not shown as a
  separate `lsmod` entry.
- Wi-Fi is operational; Bluetooth is powered; zram is active; current power
  profile was Balanced.
- Codex, Claude, Chrome, Waybar, QuickShell, awww, Matugen, Kitty, and Node
  versions were confirmed from the live environment.

Expected nonfatal log noise observed during the live audit:

- QuickShell/playerctld warnings when no MPRIS player is active.
- Waybar tray items without an icon name or pixmap.
- Mission Center cannot report Intel GPU utilization and sometimes refuses its
  auxiliary socket.
- SwayOSD waits for an unavailable libinput backend but brightness OSD remains
  service-managed.
- PipeWire Pulse priority/peer-credential warnings and some T2 audio pointer
  noise.
- Duplicate NetworkManager-initrd bus-name and unused wired-DHCP attempts. Wi-Fi
  remains functional; these are later cleanup candidates rather than current
  blockers.

### Deployment and generation timeline

1. Cloned remote base `4974921` and created `codex/macbook-desktop`.
2. Backed up the live configuration before any activation.
3. Implemented and committed the complete Aurora desktop as `ec87817`.
4. Built the complete firmware-backed closure without changing the live
   Generation 7 desktop.
5. Installed Generation 8 as a boot-only entry. A real installer-window launch
   then exposed the Hyprland 0.55 legacy-dispatch incompatibility.
6. Replaced all affected Waybar and Hypridle runtime actions with `hl.dsp.*`
   native expressions and committed `f32e320`.
7. Built and installed corrected Generation 9, then rebooted into it.
8. The first reboot preserved T2 boot, Wi-Fi, the internal panel, auto-login,
   Home Manager, and the desktop services. The desktop initially showed gray
   right and bottom bands.
9. Live geometry proved the physical output and screenshot were 2560x1600 but
   all layer surfaces were only 1600x1000 at a reported scale of 1.5. That
   rendered 2400x1500 and left exactly 160 physical pixels on the right and 100
   on the bottom. A raw Grim compositor capture proved it was not wallpaper
   cropping or physical underscan.
10. The old working config had `debug.disable_scale_checks = true`; the new
    config had omitted it. Hyprland's clean-divisor validation produced logical
    geometry equivalent to 1.6 while still reporting/rendering the surface at
    1.5.
11. Tested the correction live through native Lua eval, then forced monitor-rule
    recomputation with `hl.dsp.force_renderer_reload()`. awww changed to
    1707x1067 and Waybar to 1691x40 without logging out or closing apps. A second
    raw compositor capture showed complete edge coverage.
12. Added the persistent setting in
    `modules/home/hyprland/hyprland/general.lua` and committed `c566923`.
13. Ran two direct Home Manager activation packages: the first persisted the
    dirty-source build of the fix at 02:51, and the second installed the final
    committed-source Home Manager generation at 02:54. The second is current
    generation 2, and both file trees contain the scaling correction.
14. Built the complete corrected system closure and installed it as Generation
    10, the current systemd-boot default.
15. Discovered that `switch-to-configuration boot` alone does not advance the
    numbered system profile. The correct sequence sets
    `/nix/var/nix/profiles/system` first and then writes the boot entry. Corrected
    `README.md` in commit `25d26e5`.

Correct boot-only installation sequence for Alex's default Fish shell:

```fish
set out (nix build --no-link --print-out-paths \
  path:/home/alex/.config/nixos-local#nixosConfigurations.macbook.config.system.build.toplevel \
  --override-input macbook-config path:/home/alex/nix \
  --override-input firmware path:/etc/nixos/firmware \
  --max-jobs 2 --cores 2)
sudo nix-env --profile /nix/var/nix/profiles/system --set "$out"
sudo "$out/bin/switch-to-configuration" boot
```

Keep the store path in a quoted variable or on one physical shell line. An
earlier pasted command was split at the version suffix, causing Fish to treat
the second half as a separate command.

Routine updates should use the integrated NixOS/Home Manager path. Do not use a
standalone `home-manager switch` as the normal deployment workflow. The two
direct activation-package runs were used only to persist the emergency display
fix in the already-booted Generation 9 session; Generation 10 integrates the
final matching Home Manager output.

### Retina scaling failure: final technical record

Broken state:

```text
physical output           2560x1600
configured/reported scale 1.5
client/layer geometry     1600x1000
rendered coverage         2400x1500
uncovered area            160 px right, 100 px bottom
```

Persistent fix:

```lua
hl.config({
    debug = {
        disable_scale_checks = true
    },
    -- existing settings
})
```

Verified fixed state:

```text
Hyprland monitor          2560x1600 @ 60.001, scale 1.50
awww background layer    0,0 1707x1067
Waybar layer             8,6 1691x40
debug scale check        true, explicitly set
Hyprland config errors   none
right/bottom bands       absent in raw 2560x1600 compositor capture
```

Do not change the scale to 1.6 merely to get an integer divisor unless the user
asks for a larger UI. The requested and now working design target is 1.5.

### Operator documentation and controls

The full operator guide and interactive checklist were created outside the Git
repo so they did not perturb the validated closure:

- Markdown: `/home/alex/AURORA_OPERATOR_GUIDE.md`.
- Interactive HTML: `/home/alex/.local/share/aurora-operator-guide/index.html`.
- Artwork: `/home/alex/.local/share/aurora-operator-guide/aurora-guide.svg`.
- Launcher entry:
  `/home/alex/.local/share/applications/aurora-operator-guide.desktop`.

These files are machine-local and unversioned. They were created after the
pre-migration backup, so that backup does not contain them.

The interactive guide stores approximately fifty checkbox states plus notes and
can copy an acceptance report. Its desktop entry and JavaScript syntax were
validated; Chrome rendered it successfully at the target logical resolution.

Documentation caveat: the operator guide was generated before the Retina fix
and identifies Generation 9 and its store path as the expected boot. Generation
10 is now the correct default/target. The controls remain accurate, but update
the generation label/path before using its exact closure assertion after the
next reboot.

Useful controls during testing:

- Command is Linux Super.
- Command+Shift+F toggles true fullscreen.
- Command+F toggles maximized state.
- Command+Space toggles float/tile.
- Command+left-drag moves; Command+right-drag resizes.
- Command+L locks.
- The center-bar X closes the focused window.
- A task-button middle click closes that task.

### Confirmed unresolved issues and priority order

#### P0 — detach applications launched from Waybar

Waybar currently launches Kitty, Chrome, Thunar, Mission Center, and related GUI
tools directly. A Kitty launched from the pinned Terminal icon was observed as a
child of `waybar.service`, whose `KillMode=control-group`. A future Waybar
service stop/restart/failure can therefore kill applications launched from the
bar. A normal Waybar CSS reload does not kill them.

Two Home Manager activations were also temporally associated with the initiating
Kitty scopes ending:

- `kitty-9151-0.scope` started at 02:42:09; `sd-switch` reloaded user systemd
  from that scope at 02:51:54; the scope ended at 02:51:56.
- `kitty-14385-0.scope` started at 02:52:12; a second `sd-switch` reload came
  from it at 02:54:29; the scope ended at 02:54:30.

A later Kitty scope ended without an `sd-switch` or Waybar service restart while
the user was testing window controls. The journal does not prove that later
cause; center X and task middle-click are plausible explicit paths but must not
be asserted as fact.

Next implementation should route every Waybar application launch through a
compositor-native exec path or a transient user service/scope that is not a
member of `waybar.service`. Then deliberately restart Waybar and verify Chrome,
Kitty, Thunar, and Mission Center survive before investigating any remaining
unexpected close report.

Relevant files:

- `modules/home/waybar/config.json`: direct `on-click` commands.
- `modules/home/waybar/default.nix`: service and environment.

Until fixed, do not restart `waybar.service` while important apps launched from
the bar are open. Launching a terminal through the Hyprland shortcut
Command+Enter is safer for maintenance.

#### P1 — update the EasyEffects preset location

`scripts/equalizer-state` currently writes
`~/.config/easyeffects/output/aurora_live_eq.json`. EasyEffects 8.2.4 treats
that as an old preset directory and migrates it to
`~/.local/share/easyeffects/output` every time the EQ is applied. Live logs at
02:46:17 and 02:46:18 show the copy/migration, and two output directories were
moved into `~/.local/share/Trash/files`.

The preset loads, so this did not invalidate the isolated functionality test,
but repeated migration is incorrect. Change `preset_root` to:

```sh
${XDG_DATA_HOME:-$HOME/.local/share}/easyeffects/output
```

Then verify preset listing, loading, last-loaded state, live band changes, and
that no additional Trash entries or migration logs appear.

#### P2 — finish physical acceptance

Automated and isolated checks are extensive, but the user has not completed and
returned the full operator-guide checklist. Remaining deliberate tests include:

- palm rejection/`disable_while_typing`, two-finger right click, and
  three-finger workspace swipe;
- pointer border/corner resizing, floating move/resize, pin, maximize,
  fullscreen/restore, and close on disposable windows;
- function-row volume/mute, display brightness, keyboard-backlight, and media;
- Wi-Fi scan/connect UI without disrupting the active connection;
- Bluetooth scan and real-device pairing;
- notification replacement, action, history, DND, and timeout behavior;
- real MPRIS metadata/seek/transport, Cava, and audible EQ behavior;
- calendar/weather refresh and cached offline behavior;
- red, green, cyan, neutral-light, and preferred wallpaper palette changes
  across Waybar, QuickShell, Rofi, new Kitty, Hyprland borders, and lock;
- region/full screenshot file and clipboard behavior;
- Hyprlock unlock, idle sequence, lid suspend/resume, and Wi-Fi/audio/panel
  recovery;
- battery and power-profile behavior.

Do not perform reboot, suspend, shutdown, Wi-Fi disconnect, or destructive power
testing while a future Codex session is operating in the only important
terminal unless the user coordinates it explicitly.

#### P3 — optional cleanup and future work

- Update the operator guide's Generation 9 closure assertion to whichever
  corrected generation is installed as the default after P0/P1. If acceptance
  happens before those fixes, the immediate target is Generation 10.
- Investigate duplicate NetworkManager-initrd bus-name noise and unused wired
  DHCP attempts only after Wi-Fi acceptance is complete.
- Add Spotify only if requested. It is not installed. The pinned Nixpkgs exposes
  `spotify` version `1.2.86.502.g8cd7fb22`; `allowUnfree = true` already permits
  it. The declarative location is `modules/home/packages.nix`, and its MPRIS
  interface should feed the existing media panel.
- The Alienware/NVIDIA/dual-monitor port remains a separate Phase 4 project.

### Recovery and rollback

- Generation 7 is the deliberate pre-Aurora boot fallback.
- Generation 8 is an Aurora build before the native IPC correction; retain it
  for history but prefer Generation 7 for pre-cutover recovery.
- Generation 9 is the currently booted native-IPC build but does not contain the
  Retina fix in its integrated Home Manager service. The current session is fixed
  only because the corrected Home Manager generation was activated separately.
- Generation 10 is the desired corrected boot default.
- Standalone Home Manager generations are visible with
  `nix-env --profile ~/.local/state/nix/profiles/home-manager --list-generations`.
  Generation 1 is `/nix/store/g8067nmlc1dm7al3drdlvn9p687zk6jj-home-manager-generation`;
  generation 2 is the current committed build. Both contain the Retina fix, so
  switching from 2 to 1 is only a narrow activation rollback, not a pre-Aurora
  restore. See `docs/recovery.md` for the guarded command and use the timestamped
  backup for a true pre-Aurora user-configuration restore.
- At systemd-boot, select an older generation with the arrow keys. Holding Option
  at power-on opens Apple's macOS/NixOS picker.
- Symlink-safe dotfile restore and channel rebuild commands are in
  `docs/recovery.md`. Do not copy over Home Manager symlinks in place.
- The full backup path is
  `/home/alex/.local/state/codex-backups/macbook-desktop-20260715-234753`.
- The previous `/etc/nixos` configuration remains intact.
- Never add `/etc/nixos/firmware`, wallpaper images, credentials, or generated
  caches to Git.

### Instructions for the next chat

1. Read `BUILD_PLAN.md`, this final report section, `SOURCES.md`, and
   `docs/recovery.md` before changing the machine.
2. Re-audit Git, `/run/current-system`, the system profile, boot default,
   Home Manager profile, failed units, Hyprland geometry, and current app
   cgroups; do not assume the user has rebooted since this report.
3. Preserve all T2, firmware, `nix-ld`, unfree-package, user, boot, and dual-boot
   invariants.
4. Fix Waybar application launch isolation first, then the EasyEffects preset
   path. Test each in isolation and run the full preflight before installation.
5. Avoid live service restarts that can kill the user's active terminal until
   launch isolation is fixed. Use Command+Enter for a maintenance Kitty rather
   than the pinned Waybar Terminal button.
6. Use Hyprland native Lua eval/dispatch only. Do not revive legacy
   `hyprland.conf` or `hyprctl keyword` workflows.
7. Keep Home Manager integrated with NixOS for routine activation. Remember that
   setting the system profile is required to create a numbered boot generation.
8. After the two priority fixes, update the operator guide to the newly
   installed/default generation and coordinate the remaining acceptance
   checklist with Alex.
9. Do not push, merge, rebase, update flake inputs, remove old generations,
   delete backups, or touch the macOS partition without explicit user approval.

### Definition of the present stopping point

The requested MacBook desktop implementation is materially complete and running:
the T2 machine boots, Generation 10 is installed, the live Retina geometry is
correct, the glass Waybar and independent QuickShell panels are active, the
wallpaper-adaptive theme pipeline is in place, and the complete source and
recovery history is local. It is not yet reasonable to call the project fully
accepted because two lifecycle defects need correction and the physical
operator checklist has not been completed.

## Stage 0 — Reconcile & baseline (2026-07-21)

Reconciled the two config lineages (flake + channel edits) per GRAND_PLAN §8.7
and §10 Stage 0. The flake is the sole authority from these commits forward.

### Commits

1. `5931205` fix(hw): commit live hardware tuning — Xbox BLE intervals, t2fanrd 50/75 curve, VA-API (iHD)
2. `15bacf1` fix(shell): Bluetooth panel reliability + EasyEffects 8 preset path
3. `f6093ee` feat(stage0): port channel config into the flake — TV MAC-accept rule + Plex; add gh
4. `4eeaf4b` docs(stage0): land the Grand Plan, research corpus, and repo hygiene
5. (this commit) docs(stage0): execution log entry

### Ported channel blocks (→ modules/nixos/media-center.nix, imported by hosts/macbook)

- LG TV MAC-accept firewall rule: `networking.firewall.extraCommands` /
  `extraStopCommands` inserting/removing an `nixos-fw` iptables accept for MAC
  `40:2f:86:81:26:3e` (both directions reachable; survives TV IP changes).
- Plex Media Server: `services.plex` enabled, running as `alex:users`,
  `openFirewall = true` (DV Direct Play evaluation).

### Parity-sweep verdict

Every channel setting in `/etc/nixos/configuration.nix` has a flake equivalent:
boot.loader (3 lines), networkmanager, hostName, timeZone, allowUnfree, user
alex + groups, experimental-features, hyprland, fish, greetd, fonts (flake adds
inter), pipewire (alsa+pulse), openssh, nix-ld, stateVersion 26.11, the
nixos-hardware apple-t2 import, and the brcm firmware wrapper (machine-local
adapter at ~/.config/nixos-local supplies /etc/nixos/firmware/brcm, matching
the channel's path reference). The two previously missing blocks are the two
ported above. Only intentional systemPackages drift remains: xdg-utils is
nowhere in the flake; fish/waybar/rofi/wl-clipboard/grim/slurp/brightnessctl
moved to programs.* or home packages; waybar/rofi/thunar retire in later
stages by design. No change made.

### start-hyprland warning

Root cause (ISSUE_LOG.md §19): the flake's greetd launches the
`start-hyprland` wrapper where the channel launched bare `Hyprland`, so the
wrapper's outside-a-managed-session warning entered the boot path with the
flake lineage; cosmetic because hyprland-session.target + autostart.lua already
provide the lifecycle; fix lands in Stage 7's session-chain rebuild (§5.11).

### Build verification

`nix build ~/nix#nixosConfigurations.macbook.config.system.build.toplevel`
succeeded (portable output, expected firmware warning):
`/nix/store/h5lcbhhcxn31hld03lnixcgic0djlkj7-nixos-system-macbook-26.11.20260616.567a49d`

### PM verification amendments (same day)

- Commit 6: restored `xdg-utils` (the one true parity gap — the channel carried
  it in systemPackages, the flake had it nowhere; home packages now carry it)
  and made the `MACBOOK_NIXOS_HYPRLAND_BUILD_PLAN.md` symlink relative (it was
  absolute, which breaks any clone outside /home/alex/nix).
- Machine-local wrapper (`~/.config/nixos-local`, not in Git): `macbook-config`
  input changed from `path:` to `git+file:///home/alex/nix`, lock refreshed
  (the Jul 16 lock predated the t2fanrd input entirely). Reason: the `path:`
  fetcher copies the whole worktree into the store — including the 11 GB
  `repos/` research clones — while the git fetcher ships the committed tree
  only. Its stale `result` GC root (Jul 16 toplevel) was removed.
- Gate deploys via the wrapper using the boot-only sequence recorded above
  (profile --set, then switch-to-configuration boot), with the store path baked
  into a single sudo line. Final toplevel + tick results land in the Stage 0
  close-out entry after the gate.

- Commit 7 (operator-requested mid-gate): build harness. Scoped NOPASSWD
  sudoers rules for the deploy verbs only (nix-env, canonical
  switch-to-configuration, systemctl reboot/poweroff, reboot,
  nix-collect-garbage — everything else still prompts) in
  modules/nixos/build-harness.nix, plus an armed-resume loop:
  `~/.local/state/aurora-build/resume-armed` is set by the agent before a
  planned reboot; autostart.lua runs aurora-resume-agent, which consumes the
  flag and relaunches the agent via `claude --continue` in Kitty. Un-armed
  boots do nothing. Explicitly temporary: removal is a Stage 10 line item;
  the §7.5 sudo session switch supersedes it for daily use from Stage 8.
  First activation still needs the operator password (the rule ships with
  the new generation).

### Stage 0 close-out (2026-07-21) — GATE PASSED

- Deployed: gen 16 (boot-only + operator reboot), then gen 17 — the first
  fully autonomous deploy (resume-loop fix; built and activated passwordless
  through the harness). Booted hha12kk… (gen 16), current y236h6d0… (gen 17).
- All commits pushed to github.com/AlexbringsMercy/nix (codex/macbook-desktop).
- Generations 1–7 deleted, boot menu pruned; 8–17 remain (15 = last
  channel-lineage build, kept as the rollback anchor until the Stage 10 wipe).
  nix-collect-garbage freed 9.7 GiB (7,792 store paths); disk now 73G/120G.
- Ticks: desktop boot OK; WiFi OK (firmware via the git+file wrapper
  confirmed working). NO start-hyprland warning observed on the gen 16 boot —
  better than the root-caused expectation; watch subsequent boots
  (ISSUE_LOG §19 stands). Deferred to the Stage 1 gate as formalities
  (operator away from the TV): TV-from-couch reachability and Xbox pairing —
  risk accepted because the TV MAC rule is verified inside the live
  firewall-start script, firewall.service and plex.service are active, and
  the BlueZ LE settings + /var/lib/bluetooth pairings are untouched.
- Incident + policy: the gen 17 live activation was SIGKILLed together with
  the agent terminal (likely memory pressure; the kernel journal is
  off-limits to the scoped sudo list by design). The activation completed as
  root regardless. POLICY: every future activation runs detached from the
  agent terminal (setsid + log file), or boot-only + armed-resume reboot for
  anything that touches the session.
- Resume loop: first live run mis-aimed (untrusted ~/nix, no conversation in
  that project) — fixed in eb09b64 (home project dir + kitty --hold), live
  as of gen 17.

## Stage 1 — Chassis (2026-07-21, in progress)

### 1A — Vendor (DONE)

- Codex session 1 (thread 019f84ba…): 449 files vendored to
  modules/home/aurora-shell, 437 attribution headers, SOURCES.md ledger
  entry, parent-flake path-input wiring. Its sandbox mounts .git read-only —
  division fixed permanently: Codex edits, the PM commits.
- PM verification: header count + sample-file byte checks passed; caught an
  invalid double dynamic-attr `packages.${system}` definition (fixed in
  commit); one pkill self-match incident on the PM side, no damage, redone.
- Build GREEN: nix build .#aurora-shell →
  /nix/store/2sc3i9j9s0q7i6qjh6bf38ljq0zaywwz-caelestia-shell-1.0.0
  (quickshell 0.3.0 compiled from caelestia's pin, plugin compiled clean).
  Pushed through 4b768fe.
- PM deviations, logged per §0.5: (1) snapshot vendor instead of a subtree
  history graft — the audited bytes win over history; upstream remote
  recorded in SOURCES.md for future diffs. (2) M11's generator-clamp half
  lives in the caelestia CLI (a pinned flake input, not vendored) and is not
  exercised until wallpaper-driven regeneration exists — it lands in Stage 4
  with its first real consumer. 1B covers the shell-side scheme now.

### 1B — Scheme (launched)

- codex-prompts/stage1b-aurora-scheme.md → session codex-stage1b: ladder
  defaults pinned, dark default, accent family defaults, ledger update.

### 1B — Scheme (DONE)

- Codex session 2: Colours.qml fallback palette is the authority (plugin holds
  no palette — zero C++ changes). Ladder pinned per §3.1 with an explicit
  role-mapping table (highest/variant alias the #1c2742 ceiling — no sixth
  rung exists); dark hard-set; accents defaulted to cyan #38bdf8 / purple
  main lifted #7c3aed → #9b6ff8 (3.4:1 → 5.5:1 against the glass RGB, the
  §3.1 luminous-not-pastel intent) / seafoam #34d399. 46 Aurora-marked lines
  across 2 files; PM hex-count verification matched the mapping table exactly.
- Structural caveat (Codex finding, correct): a pre-existing state
  scheme.json overrides the QML fallback — 1C must seed clean aurora state at
  cutover; the CLI's own Catppuccin default gets replaced in Stage 4.
- Build GREEN → 46jqdy8svnx719hw1ybcz5db40nggbfs-caelestia-shell-1.0.0.
  Pushed through 9f64c36.

### 1C — Cutover (DONE, file work; activation pending the gate)

- Codex session 3 (thread 019f860d…, prompt `codex-prompts/stage1c-cutover.md`):
  renamed the vendored HM module `programs.caelestia` → `programs.aurora-shell`
  and its unit `caelestia` → `aurora-shell` with the §2.2 hardening —
  **`KillMode=process`** (a shell restart never kills user apps — the P0
  Waybar-cgroup class dies here), `SuccessExitStatus=143`, `LimitCORE=0`,
  `StartLimitIntervalSec=30`/`Burst=3`. Threaded the module into **both** HM
  eval paths (`base.nix` `home-manager.sharedModules` — `inputs` added to its
  signature — and `flake.nix` `homeConfigurations.alex`) and enabled it (+ cli)
  in `home/alex/default.nix`. Retired `modules/home/{waybar,rofi,quickshell,
  wallpaper}` (42 files, 6273 lines); carried the **dunst
  aurora-notification-fallback** keeper into the aurora-shell module with a
  static, palette-independent `assets/fallback-dunstrc` (the old one was
  matugen-rendered by the retiring wallpaper tree). Seeded a **write-if-absent**
  `~/.local/state/caelestia/scheme.json` (`assets/aurora-scheme.json`) via an
  HM activation, mutable so Stage 4 scheme changes still overwrite it.
- PM verification: diff scope matched the report exactly (4 M, 2 new assets,
  42 D); rename clean (zero stray `programs.caelestia`/`services.caelestia`);
  **seed = the 1B palette exactly** (24/24 unique hexes both directions,
  44/44 roles); no surviving module sets a retired option; `preflight.sh` edit
  clean. App internals (`caelestia-shell` binary, `caelestia/` config+state,
  `caelestia` CLI) deliberately unchanged — only namespace + unit name flipped.
- Build GREEN, **both eval paths**: home-manager-generation
  `fi5py6wflyg4s0v71r62nampii102dsa` + portable toplevel
  `j4y0rw9mai26pjglnd4izx7s7s1j2pd0` (firmware warning expected on the portable
  output). `caelestia-cli` + the `with-cli` plugin compiled clean;
  `aurora-shell.service` and `aurora-notification-fallback.service` .drvs both
  built. Committed 18b5182; pushed at the sub-stage per §2.3.
- Codex deviations, logged per §0.5: (1) `.git` mounts read-only in the sandbox
  → PM staged and committed (the permanent Codex-edits/PM-commits division).
  (2) removed `preflight.sh`'s retired `aurora.wallpaper.defaultWallpaper` gate
  — Stage 4 adds the skwd-wall replacement gate. (3) seed carries
  `variant:"tonalspot"` + `flavour:"default"` — the vendored CLI's Scheme
  constructor needs `variant`; the shell's `Colours.qml` `load()` ignores extra
  top-level keys, so it is harmless to first light and defensive for the CLI.
- Transitional state after 1C (flagged, not absorbed — retires on schedule):
  `packages.nix` still installs waybar/rofi/quickshell/awww/waypaper and
  `hyprland` still declares rofi-toggle/SwayOSD (Stage 2 window-model sweep);
  `modules/home/lock` still points at `~/.cache/aurora-theme/hyprlock.conf` and
  the matugen `theming` tree stays intact (Stage 4 / Stage 7). **Caelestia's own
  `background` module renders the wallpaper at the Stage 1 gate** (skwd takes the
  layer at Stage 4); the `~/.cache/aurora-theme` gtk.css `@import` is dormant
  until then. All cosmetic, all sequenced by the plan.

NEXT: **Stage 1 visual gate — Alex present.** Deploy the built closure via the
wrapper (refresh lock → build via `path:/home/alex/.config/nixos-local` →
profile `--set` → `switch-to-configuration boot` + armed-resume reboot, or a
fully detached switch — never a live switch attached to the agent terminal).
**Pre-gate step (seed is write-if-absent):** remove any pre-existing non-aurora
`~/.local/state/caelestia/scheme.json` before first activation so the aurora
seed lands. Then the §3.2 glass A/B (evening), VA-API `vainfo` check, and the
Stage 0 leftovers deferred to this gate (TV-from-couch reachability, Xbox
controller pairing). Gate checklist: shell runs supervised; launcher /
dashboard / notifications / OSD / session / utilities / Nexus all open; IPC
works; nothing dies on `systemctl --user restart aurora-shell`.

### Stage 1 gate — RAN 2026-07-21 (Alex live)

- **Deployed:** gen 18 (boot-only + armed-resume reboot), then gen 19 (Plex
  removed via a live **detached** switch — no second reboot). Cutover HEALTHY:
  shell supervised + active, 0 failed units, 0 hyprland configerrors, seed
  `scheme.json` = aurora/dark, `KillMode=process` proven (the shell restarted
  mid-session and the agent terminal survived — the Waybar-cgroup P0 class is dead).
- **Operator fixes landed the same session:** Plex removed (`d87090e`) — a
  channel-era leftover mistakenly ported in Stage 0, unused, burning compute and
  blocking reboots at service-stop (TV firewall MAC rule kept, Moonfin untouched);
  `aurora-resume-agent` now launches `--dangerously-skip-permissions`; duplicate
  `nm-applet`/`blueman-applet` tray applets retired from `autostart.lua` (killed
  live + permanent) — the shell owns network/BT natively, and they were the
  duplicate wifi/bt icons + the stuck-"connecting" rail spinner.
- **Gate findings → staged (ISSUE_LOG §20–28):** the cutover works; the polish
  and features Alex surfaced belong to later stages and are NOT Stage-1 defects.
  Palette completeness + quality → **Stage 4** (Raycast quality bar, accents are
  wallpaper-derived and "aurora" is one mode — memory `aurora-palette-direction`;
  13 of 54 m3 roles were unpinned → warm-Material clash, §20). Double brightness
  OSD (SwayOSD still live), launcher keybind, brightness → **Stage 2** keymap
  (coupled — brightness keys must rebind off swayosd onto the shell OSD). Top bar
  + wifi/bt placement → **Stage 3**. Wallpaper + real glass → **Stage 4**. Lock
  polish → **Stage 7**. T2 RTC boot-clock skew broke the resume's first API
  connect (§28) — investigate for the Stage 7 boot chain.
- **NEXT: Stage 2 — the window model + keymap.** Sweeps SwayOSD retire +
  brightness/volume-key ownership, Cmd+Space→launcher, detached-launch, hyprbars +
  minimize + focus policy + input tuning, and retests the §5 input/window bug list.

## Stage 2 — Window model + keymap (2026-07-21)

Split into 2A (window model) + 2B (input/keymap/OSD). **2A DONE, gen 22 live.**

### 2A — Window model (DONE)

- **hyprbars** (nixpkgs `hyprlandPlugins.hyprbars`, ABI-matched) per-window
  titlebar buttons: close/maximize/minimize, clean monochrome glyphs, transparent
  bg, size 24. Operator direction: NOT the plan's §6.1 "red/yellow/green"
  traffic-lights (Fable wording, overridden), NOT a Windows/macOS copy — clean
  modern monochrome (memory `aurora-palette-direction`).
- **Button/double-click/snap/minimize actions converted to Hyprland 0.55
  native-lua dispatch** (`hl.dsp.window.close()`, `.fullscreen({...})`,
  `.move({window="address:..",workspace,follow=false})`, `focus({window=..})`) —
  the legacy `hyprctl dispatch killactive`/`fullscreen 1`/`movetoworkspacesilent`
  strings PARSE fine but the 0.55 Lua parser rejects them AT RUNTIME, so every
  button/snap/minimize silently did nothing until caught live at the gate. Forms
  verified against caelestia's own `windowinfo/Buttons.qml`.
- **Minimize** = OnlyLyan/omarchy-desktop-shell `window-minimize` vendored
  verbatim (per-window `special:min-<addr>`, LIFO restore), internal dispatches
  lua-adapted. `follow_mouse=0` click-focus, `focus_on_close=2`, workspaces 1–5,
  `Super+Q` close / `Super+F`+`Super+Up` maximize / `Super+Down` minimize /
  `Super+Alt+M` restore; move via `Super+drag` or titlebar drag.
- **Hover state = PATCHED hyprbars.** Codex-authored C++ patch
  (`modules/home/hyprland/patches/hyprbars-hover.patch`) adds a hover highlight on
  the hovered button + a tunable `plugin:hyprbars:hover_color` (default
  `rgba(ffffff22)`). Built from the **v0.55.0** hyprland-plugins source
  (`patchedHyprbars` overrideAttrs; PM caught Codex's first pass targeting
  HEAD/0.56 → ABI-wrong). Operator confirmed: hover works and "looks clean."
- **Deferred to Stage 3 (with the taskbar):** hiding `special:min-*` workspaces
  from caelestia's switcher — the switcher is currently the ONLY *visible* restore
  path for minimized windows, so hiding it before the taskbar exists would make
  minimize a one-way trip (operator caught this). The 1-line filter is ready in
  `codex-prompts/stage2a-hide-min-workspaces.md`; deploy WITH the Stage-3 taskbar.
  Also deferred: `Super+Left/Right` half-snap (needs a verified 0.55 exact-resize
  lua form).

### Hover crash — expensive lesson (paid for with a compositor SIGSEGV + safe mode)

Deploying the patched plugin via a **live hot-swap** (`hyprctl plugin unload old`
+ `plugin load patched` + `hyprctl reload`, which re-runs the config's
`hl.plugin.load`) left **TWO hyprbars loaded at once**. hyprbars uses process-wide
singletons (`g_pGlobalState`, one `PHANDLE`); two `PLUGIN_INIT`s collide and
re-register the same `plugin:hyprbars:*` config names (return ignored) → the old
plugin's `barHeight` `CConfigValue` went unbound → `getPositioningInfo()` →
`barHeight->value()` null-deref → SIGSEGV → Hyprland **safe mode** (stripped
desktop, "failed to save config"). The backtrace + a Codex adversarial re-audit
confirmed the **patch was sound**; the **double-load was the bug**.

**LESSON — never hot-swap a compositor plugin.** `hyprctl reload` does not reload
plugins but DOES re-run `hl.plugin.load` in the config, so unload+load+reload
double-loads and corrupts singleton state. The only safe path is a **clean single
load = a normal boot of the generation** (config loads it once). Test compositor
plugins by rebooting into the gen (previous gen stays selectable as fallback) or
in an isolated nested Hyprland — NEVER by live-swapping on the operator's session.
Recovery from the crash: `nix-env --rollback` to the pre-patch gen + switch +
reboot into a clean gen; then set the patched gen boot-only and reboot for the
clean single load (which worked — gen 22, hover live, zero crashes).

### Boot friction (operator, recurring — we reboot a lot)

The T2 firmware defaults to **macOS** as the startup disk, so NixOS needs
Option→Apple picker→"EFI Boot", and that handoff is flaky (black screen → Apple
logo → macOS recovery; took 3 tries once). **Fix (§5.11, one-time, no macOS):** at
the Apple boot picker hold **Control** on the EFI Boot entry → the arrow becomes ⟳
→ press it → NixOS becomes the persistent default startup disk. Redo after macOS
updates; never touch Startup Security. NixOS cannot set this itself
(`canTouchEfiVariables = false`, T2 constraint) — it is a firmware-picker action.
systemd-boot's own default is already NixOS (gen 22); optional later polish:
`timeout 5→0` + prune old boot entries.

**NEXT: Stage 2B** — the keymap (**Cmd+Space→launcher**, the §6.4 map), input
tuning (DWT libinput quirk, `scroll_factor 0.3`, `repeat 22/350`), gestures,
**SwayOSD retire + brightness/mic/media key rebind onto the shell OSD** (kills the
double brightness OSD), detached-launch sweep, `rules.lua` dead-namespace cleanup.
Then the Stage 2 gate (§6.2 checklist + the §5 input/window bug list).

### 2B — Keymap / OSD / input (DONE except items below; commits 29fedce, 262472b)

- Landed: **Cmd+Space → launcher**, SwayOSD retired with brightness/media keys
  rebound onto caelestia's own OSD (double-OSD dead), input tuning (repeat 22/350,
  natural scroll), `shell.json` made writable, detached-launch sweep, rules cleanup.
- This close-out is written retroactively by the incoming PM — the prior session
  landed the commits but never logged them. Process gap noted below.

### Operator decisions register (backfilled 2026-07-21; log these inline from now on)

Standing rule, operator-mandated: every decision Alex makes lands in this log the
day it's made — not buried in a commit message. Backfill of recent calls:

1. **Snap/window keys on bare Super+arrows — no Ctrl.** Windows-style. (2A, d47ae38.)
2. **Titlebar buttons: clean modern monochrome** — not the plan's traffic-light
   red/yellow/green wording. (2A; also in memory `aurora-palette-direction`.)
3. **scroll_factor 0.6**, not the plan's 0.3 — 0.3 far too slow on this trackpad;
   tune further by feel at the gate. (2B, 262472b.)
4. **The 3-finger vertical live-volume gesture is NOT cut.** The prior session
   "dropped" it when a lua-function gesture action faulted at runtime. Operator
   ruling: parked-is-not-fixed; restore it from a verified, sourced native form.
   Cutting planned features to silence a bug is never a fix on this project.
5. **Super+drag spring: root cause is CONTESTED — settle it live, not on paper.**
   The Codex investigation (proposal-only, 2026-07-21) blamed the tiled-pickup
   recenter amplified by `animate_mouse_windowdragging=true` overshoot; the
   operator suspects scaling/rendering (the plan's `false` note is about GPU lag,
   not a half-screen throw — don't pattern-match them together). Both are
   config-level and live-testable: at the Stage 2 gate, A/B the animation flag
   live, then a 10-second scale-1.0 drag check. Evidence decides; nothing ships
   as "the fix" before then.
6. **PM conduct (operator, binding):** full grounding reads + a stated read list
   before any work; decisions logged; fixes come from community sources, never
   from cutting scope or hand-patching upstream first; PM communicates plain and
   high-level. (Also in PM memory.)

**NEXT: Stage 2C — close out the window model.** One Codex session:
(1) restore 3-finger vertical live-volume from a verified native 0.55 form,
(2) half-snap on bare **Super+Left/Right** (verified exact-resize form — the 2A
deferral comes due), (3) the DWT libinput quirk (`AttrKeyboardIntegration=internal`,
bus-matched on this machine) so `disable_while_typing` actually works.
Then the **Stage 2 gate, Alex present**: §6.2 checklist + §5 input/window bug list
+ the drag-spring live A/B (decision #5) + launcher/dashboard animation lag
observation (open from 262472b).

### 2C — Window-model close-out (file work DONE; commits below)

- Codex session codex-stage2c (thread 019f87af…, prompt
  `codex-prompts/stage2c-window-model-closeout.md`):
- **Half-snap SHIPPED** — bare Super+Left/Right (decision #1), a lua half_snap()
  composed entirely from verified in-repo forms: caelestia's own callback-bind +
  float→resize→move dispatch chain (functions.lua:52-75, keybinds.lua:109-119,
  execs.lua:32-37) + end-4's `"exact"` resize marker (keybinds.lua:359). Floats
  tiled windows explicitly first (dwindle nodes can't half-snap in-tree). Logical
  geometry 1707×1067 from scale 1.5, complementary 853/854 halves. PM re-verified
  every citation against the actual files + installed 0.55.4 stub; luac parse OK.
- **DWT quirk SHIPPED** — `/etc/libinput/local-overrides.quirks` via desktop.nix:
  `AttrKeyboardIntegration=internal` matched narrowly to the T2 internal keyboard
  (USB 05ac:0280, MatchUdevType=keyboard excludes the same-name trackpad).
  `libinput quirks validate` passed. HONEST CAVEAT (Codex, correct to raise):
  libinput 1.31.3 already ships a broader Apple internal-keyboard rule, so the
  attribute may already apply and DWT's ineffectiveness may have another cause —
  the gate's `libinput debug-events` before/after decides; do not pre-declare
  this fixed.
- **Volume gesture ESCALATED, not shipped** (the hard rule worked): pinned
  Hyprland 0.55.4's gesture API takes only `string|function` actions — the
  continuous start/update action table in the current wiki does not exist in
  0.55.4 (verified against installed hl.meta.lua:444-454 + the C++ header). The
  one-shot lua-callback form exists but is the same class that faulted in 2B, and
  the shell exposes no volume IPC target to route through. Options for Alex at
  the gate: (a) one-shot swipe = volume-step via callback, tested in a nested
  Hyprland first (never the live session); (b) park until the compositor bump
  whose newer gesture API does continuous natively — logged deviation, feature
  stays owed. Plan-vs-reality gap flagged per authority order; NOT a cut.

NEXT: **Stage 2 gate — Alex present** (deploy = boot-only + armed-resume reboot;
keybinds are config but desktop.nix needs the system rebuild anyway). Checklist:
§6.2 + the §5 input/window bug list + half-snap on disposable windows + DWT
debug-events A/B + the drag-spring live A/B (decision #5) + volume-gesture call
(above) + launcher/dashboard animation lag observation.

### Stage 2 gate — RAN 2026-07-21 evening (Alex live; gen 25)

Mechanical: gen 25 booted clean, 0 failed units both scopes, shell supervised,
0 configerrors, quirk file landed, snap binds registered.

**Root cause PROVEN live — Super+drag / titlebar-drag jump (decision #5 settled):**
tiled-window *pickup placement*. With drag animation toggled off live the jump was
identical (animation theory dead); at unchanged scale a *floating* window dragged
perfectly (scaling theory dead). The compositor centers a tiled window under the
cursor when plucking it from the layout — grab offset discarded. Both drag paths
(Super+drag, titlebar) hit it; floating windows never do.

**Half-snap (2C): works but two defects, one family.** (1) Placement drifts out of
frame top-left (decoration/gap space likely uncounted). (2) The snapped window
STAYS floating forever — new windows then tile *underneath* it (this was the whole
"windows go somewhere else after 5" report — nothing goes to another workspace)
and its floater covered another window's close button. Snap needs a release path
back into the layout.

**Operator decisions (register):**
7. **scroll_factor 0.6 FINAL** — full live A/B loop 1.0/0.8/0.7/0.6; 0.6 wins on
   feel. Choppiness at low factors is quantization (proven at 1.0-smooth); kitty's
   line-scroll texture is kitty-side, minor polish note.
8. **animate_mouse_windowdragging = false permanent** — the plan's value,
   live-confirmed irrelevant to the jump; operator kept the rigid feel.
9. **Volume gesture DEFERRED by operator** until the Hyprland bump whose newer
   gesture API does continuous natively. Not cut — owed, revisit at the bump.

**Other findings:** third-window-closes bug DEAD (repro attempt failed — Waybar
cgroup fix held). DWT typing-protection only partially better — quirk may have
been pre-applied by libinput's stock Apple rule; deeper diagnosis needed (palm
attrs), live A/B at the re-check. Corner resize hit-or-miss — the plan's
predicted hyprbars×resize_on_border interaction (#355); investigate, else apply
the plan's documented fallback (Super+RMB + document). Launcher/dashboard
animation lag unchanged → Stage 3 motion pass (surfaces retime onto our tokens
there anyway).

**Gate status: CONDITIONAL PASS.** Window model core proven; Stage 2 closes when
the 2D batch lands (drag pickup, snap geometry+release, DWT diagnosis, corner
resize verdict) and the operator's 5-minute re-check confirms feel.

### 2D — Window-lifecycle fixes (file work DONE; verified)

- Codex session codex-stage2d (thread 019f87ec…): **shipped** — drag animation
  false permanent (caelestia misc.lua:6 is the community precedent);
  **half-snap reworked**: decoration-aware geometry (client box at y=38 —
  8px gap + 30px reserved hyprbars extent — 843px halves, 5px center gap, all
  edges in frame) + the release path (arrow press on a snapped window retiles
  it; dragging a snapped float works normally, next arrow re-snaps). PM
  verified every citation (caelestia misc.lua, installed default float-toggle
  form, stub window fields) + luac on both files.
- **Drag-pickup ESCALATION (evidence complete):** 0.55.4 has NO config option
  for pickup placement (exhaustive metadata read); upstream main STILL centers
  tiled windows under the cursor (DragController — a compositor bump inherits
  no fix); caelestia/end-4/DMS/installed-default all bind the dispatcher raw
  and live with it; the pre-float bind wrapper was correctly NOT shipped
  (mouse press/release semantics through a lua callback unverifiable
  statically). Real fix = compositor-source patch. Operator decision pending.
- **DWT verdict:** stock libinput 1.31.3 already applies keyboard-integration
  AND the corrected T2 palm-size threshold (1600) — the 2C override was
  redundant-but-harmless. Remaining palm leaks need per-device measurement
  (`libinput measure`, operator's hands) before any further quirk ships;
  report-only candidate stanza recorded in the 2D report.
- **Corner resize verdict:** the known hyprbars top-decoration conflict; no
  config-level repair exists (extend_border_grab_area can't reach through the
  bar's event handling). Plan's pre-authorized fallback stands: Super+RMB
  corner resize (already bound) + document in Nexus Input help (Stage 9 page).
