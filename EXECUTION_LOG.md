# Execution log


# ═══════════════════════════════════════════════════════════════════
# ⚠ CURRENT AUTHORITY — READ BEFORE THE HISTORICAL LOG
# ═══════════════════════════════════════════════════════════════════

> **This log contains two incompatible architectures.** Read chronologically and
> trust later entries over earlier ones.
>
> **The 2026-07-16 "full implementation and handoff report" section describes a
> RETIRED architecture.** It calls itself "the durable current-state report" and
> claims later sections lose to it. That claim expired on 2026-07-21. It
> describes Waybar as the permanent taskbar, independent custom QuickShell
> dropdown panels, matugen/awww/Waypaper theming, and workspaces 1–2. **None of
> that is the build.** Do not resume from it, cite it as current, or treat its
> "Instructions for the next chat" as live. (This header replaces the former
> "Current handoff" pointer that directed readers to that section.)
>
> **The current architecture is `GRAND_PLAN.md`:** caelestia forked as
> `aurora-shell` (one QuickShell instance, systemd-supervised), a new QuickShell
> top taskbar, caelestia's vertical rail retained, Waybar retired, skwd-wall as
> the wallpaper authority, staged gates controlling execution.
>
> **Start here:** `## Stage 0 — Reconcile & baseline (2026-07-21)`, then read
> forward to the end. Then read `CURRENT_STATE_AUDIT.md` for verified machine
> state — this log records what was *attempted*, not what is *running*.
>
> **Four corrections to entries below, proven against the machine:**
> 1. The 2026-07-22 close-out's batch line says "drag patch **(built)**". It was
>    **not built.** The same entry says so 30 lines earlier ("the build was
>    interrupted... builds owed"). The patched output is not a valid store path;
>    stock unpatched Hyprland is running.
> 2. The handoff's "gen 25 booted, gen 26 staged and NEVER TESTED" is stale. The
>    machine has since **booted into gen 26**. The 2D half-snap rework is
>    activated — but still not live-tested.
> 3. **Generation 26 is the active and default boot generation** (confirmed
>    2026-07-28). Any generation number stated earlier in this file is historical.
> 4. **Corner resize is non-negotiable and unresolved** — no implementation, no
>    research artifact (operator decision #11).
>
> **Stage 2 is NOT closed.** Conditional pass only. Report it as `STAGE 2 — OPEN`
> until its full close-out gate passes and Alex accepts it.
>
> **Governing documents for the incoming PM:** `CURRENT_STATE_AUDIT.md`,
> `PM_OPERATING_RULES.md`, `STAGE2_CLOSEOUT_WORK_ORDER.md`, `GRAND_PLAN.md`,
> `MASTER_REQUIREMENTS.md`, and the dated operator-decision entries at the end of
> this file.

# ═══════════════════════════════════════════════════════════════════


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

### Drag-fix deep research + carried patch (2026-07-22)

**Research (Codex xhigh, thread 019f88…, budget-corrected to ≤2 subagents; report
in scratchpad dragresearch-final.md):** the pickup jump is an upstream
REGRESSION. Hyprland's 2022 drag code preserved the grab vector
(`originalPosition + (currentMouse - beginMouse)`, floated only at drag END —
mirror commits 3e36f1c42c / 8a4f6d01f3); current code centers the new floating
box under the cursor (`cursor - size/2`, DragController.cpp L58-80 @ v0.55.4).
Upstream issue #3712 documents exactly this and was closed "not planned"
(PM-verified via direct fetch); 0.56 and post-0.56 main retain the centering
(release notes + source checked — the planned compositor bump inherits NO fix).
No config option, no community plugin, no downstream distro patch carries a fix
(per-lane coverage accounting in the report). The pre-float Lua wrapper is
partial by construction: it cannot intercept hyprbars (which enters
MBIND_MOVE from C++) and it breaks drop-to-retile. Operator's ruling that "a
fix exists" vindicated: the fix is Hyprland's own former behavior, forward-ported.

**Operator decision #10 (2026-07-22): carry the compositor patch.** Conditions
set by operator and verified before execution: (a) proven that older Hyprland
actually preserved the grab point — yes, in read source, not just the issue;
(b) strictly isolated, no scope opening — the patch touches only the
tiled-pickup placement inside `if (m_dragThresholdReached)`. Operator's
pre-float idea evaluated and declined for the two reasons above (hyprbars
unreachable, retile semantics lost).

**Execution (Codex xhigh, thread 019f8aa0…):**
`modules/nixos/patches/hyprland-drag-anchor.patch` — captures the normalized
anchor `(cursor - tiledTopLeft)/tiledSize` before `changeFloatingMode`, then
places the floating box at `cursor - anchor*floatingSize`; handles the 0.8489×
remembered-size shrink by construction; `m_draggingTiled` and all drop/retile,
resize, threshold, focus, fullscreen paths untouched (isolation audit in
report). Carried via a single nixpkgs overlay in flake.nix applied to BOTH
eval paths (homePkgs + nixosSystem module), so `pkgs.hyprland` AND
`pkgs.hyprlandPlugins.hyprbars` (plugin helper consumes top-level hyprland)
rebuild against the same patched compositor — no ABI drift. PM verified:
patch context matches pinned blob (ad68274 @ a0136d8c), dry-run applies with
zero fuzz, overlay live in real eval (`nixosConfigurations.macbook.pkgs.
hyprland.patches` lists the patch). Live gate matrix owed at re-test: 4 grab
points × short/tall windows × Super+LMB/titlebar; floating drag unchanged;
drop/retile intact.

### 2026-07-22 session close-out (PM handoff follows)

**Drag patch:** committed `df37152` (patch + overlay, PM-verified — see prior
entry). The build of both eval paths was interrupted before the patched
compositor compiled — only stock hyprland-0.55.4 is in the store. **Builds
owed** (nix resumes from store; re-run the two builds as-is).

**DWT ROOT CAUSE FOUND (live measurement, PM-run):** the T2 trackpad carries
`ID_INPUT_TOUCHPAD_INTEGRATION=external` (udev default for USB touchpads —
verified `udevadm info /dev/input/event7`), and libinput reports
`Disable-w-typing: n/a` — **DWT does not exist on this device**; Hyprland's
`dwt = true` has been a silent no-op the whole build. This supersedes all
prior "partially effective" framing. Evidence: live capture (keyboard event2 +
trackpad event7, tap+dwt enabled) during operator typing — 22 palm-taps fired,
most within ±0.15s of keypresses, some between keystrokes; log preserved at
`~/.local/state/aurora-build/pm/dwt-capture.log`. Fix (NOT yet implemented):
udev hwdb entry `touchpad:usb:v05acp0280:*` →
`ID_INPUT_TOUCHPAD_INTEGRATION=internal` (`services.udev.extraHwdb` in
desktop.nix; systemd's stock `70-touchpad.hwdb` documents the key; hwdb match
needs lowercase vid/pid). Second half: palm/thumb-tap classification — run
`libinput measure touch-size /dev/input/event7` with the operator's hands
(tool verified at `/nix/store/md7kljxi6ys3vbghgbliqcrp1x40mj1x-libinput-
1.31.3-bin/bin/libinput`; alex is in `input` group, no sudo needed) and fill
the 2D report's candidate quirk stanza with measured AttrPalmSizeThreshold /
AttrThumbSizeThreshold values.

**Operator decision #11 (2026-07-22): corner resize REOPENED — non-negotiable.**
The PM wrongly described the 2D fallback verdict as "closed"; the operator
never accepted it: "I want corner resize... just like the drag its a non
negotiable we dont just skip over." Fix path: research the hyprbars top-
decoration × resize_on_border interaction in the carried v0.55.0 hyprbars
source (we already patch it — hover patch precedent) and extend our carried
patch so corner grabs work reliably. Not started.

**Operator directive (standing): batch fixes — fewer rebuild cycles.** Group
file-work into batches; one build + one reboot per batch. Current batch:
drag patch (built) + DWT hwdb/quirk fix + corner-resize hyprbars patch, then
stage boot-only and re-test everything (incl. gen-26 snap rework) in ONE reboot.

**Stage 3 prep:** mapping prompt `codex-prompts/stage3-taskbar-mapping.md`
launched (component map, batch plan, dev-loop feasibility: second QuickShell
instance from the worktree for hot QML iteration). Session died mid-run at the
machine interruption; thread `019f8ad6-f360-7340-8c92-c17189e395b0` is
resumable (`codex exec [global flags] resume <id>` — flags BEFORE resume).
Partial event stream preserved at `~/.local/state/aurora-build/pm/
stage3prep-events.jsonl`.

---

# ═══════════════════════════════════════════════════════════════════
## OPERATOR DECISIONS — 2026-07-28 — ACTIVE GENERATION 26
# ═══════════════════════════════════════════════════════════════════

**Ground truth confirmed at the time of writing (read-only):** branch
`codex/macbook-desktop`, HEAD `6486742`, clean tree, 0 ahead / 0 behind
`origin/codex/macbook-desktop`. `/run/current-system` =
`/nix/store/92bdqiipmfazicpi1b1vy4hbn77wf33r-nixos-system-macbook-…`;
`/nix/var/nix/profiles/system` → `system-26-link` → the same store path.
**Active generation = default boot generation = 26.**

This entry is a governance and documentation session only. No implementation,
build, activation, service restart, or reboot occurred.

---

### Decision 12 — Stage completion means fully accepted

**Status:** APPROVED / BINDING
**Applies from:** 2026-07-28, generation 26
**Decision:** A stage is **not** complete merely because code was written, a
build succeeded, a generation was installed, a PM says most things work, or the
remaining issues appear small.

A stage is complete only when **all seven** of these are true:

1. Every requirement assigned to it is accounted for.
2. Every required implementation is written.
3. Every required output builds.
4. It is installed and activated.
5. Every physical or visual test is run.
6. Failures and skipped checks are resolved.
7. Alex passes the complete stage gate.

**Plan impact:** No `PASS`, `DONE`, `CLOSED`, `COMPLETE`, or equivalent wording
may be used for a stage before all seven conditions are true. "Conditional pass"
is a status, not a close. Stage 2 is therefore reported as `STAGE 2 — OPEN`.

**Acceptance condition:** Every stage close-out report carries the
requirement-by-requirement table defined in `PM_OPERATING_RULES.md`, with no row
removed, and Alex states his acceptance in his own words before the log records
the stage as closed.

---

### Decision 13 — No silent deferrals, cuts, or divergences

**Status:** APPROVED / BINDING
**Applies from:** 2026-07-28, generation 26
**Decision:** No session may silently move a requirement to another stage, defer
it, cut it, replace it with a weaker fallback, narrow its intended behaviour,
declare an issue impossible, treat a workaround as final, or start the next
stage with an unresolved gate.

Any change from `GRAND_PLAN.md`, any newly discovered incompatibility, and any
proposed deferral requires **Alex's explicit approval** before it takes effect.

**Plan impact:** Every approval, rejection, override, or deferral is entered into
this file **the same day**, with: date; active generation; decision status;
original plan requirement; approved change; reason; target stage or revisit
trigger; acceptance condition. Conversation memory is **not** an acceptable
decision record. This extends decision #6 (PM conduct) and makes the register
format mandatory rather than customary.

**Acceptance condition:** Any stage report containing a deferral that has no
matching dated entry in this log is rejected and the stage stays open.

---

### Decision 14 — PM communication level

**Status:** APPROVED / BINDING
**Applies from:** 2026-07-28, generation 26
**Decision:** Alex handles product and architecture decisions, tradeoffs, scope
changes, approval of deferrals, and visual/physical gate acceptance. Routine
implementation choices remain with the PM and the CLI agents.

**Plan impact:** The PM reports to Alex in plain, high-level language: what
decision is needed, why it matters, what the recommended choice is, what diverges
from the plan, and what remains unverified. Alex is not dragged through
command-by-command implementation detail unless his physical participation or a
real decision is required.

**Acceptance condition:** Alex is asked only for decisions and hands-on tests, and
every escalation states a recommendation rather than presenting an open menu.

---

### Decision 15 — Screenshot colour defect is urgent and is pulled into Stage 2

**Status:** APPROVED / BINDING — explicitly approved sequencing change
**Applies from:** 2026-07-28, generation 26

**Original plan requirement:** `GRAND_PLAN.md` §5.12 rebuilds the capture chain
onto the carried `modules/areapicker/` architecture at a later stage; the current
`screenshot-area` / `screenshot-full` bindings were the interim path.

**Observed facts:** Both region **and** full-screen screenshots contain a uniform
mauve/pink cast.

**Operator decision:** Screenshot colour fidelity becomes a **blocking Stage 2
close-out deliverable**, and the **final** §5.12 capture architecture is pulled
forward to satisfy it.

**Consequences, binding on the diagnosis:**

- The defect is **not** proven to be solely the region-selection overlay.
- Do **not** assume a palette root cause.
- Do **not** assume an Areapicker-only root cause.
- Diagnose whether the physical display itself is tinted or whether PNG capture
  changes the colours.
- Do **not** improve or preserve an interim screenshot implementation that will
  later be deleted (MASTER §1.6 — no throwaway bridges).
- Both region and full-screen paths must be correct; clipboard and saved-file
  output must both work.

**Acceptance condition:** Stage 2 cannot close while screenshots retain a uniform
tint or a capture overlay baked into output. Full acceptance list in
`STAGE2_CLOSEOUT_WORK_ORDER.md` §8.2 D.

---

### Decision 16 — Glass A/B remains in Stage 4 (explicitly approved, not waived)

**Status:** APPROVED / BINDING
**Applies from:** 2026-07-28, generation 26

**Original plan requirement:** `GRAND_PLAN.md` §3.2's glass A/B gate was listed as
a Stage 1 gate item. It was not run at the Stage 1 gate; it was deferred without
an explicit operator approval on record.

**Operator decision:** The deferral to Stage 4 is **now explicitly approved**,
because the final wallpaper and palette pipeline lands there, the present
configuration already visibly fails the intended glass standard, and tuning
temporary Stage 1 theming would duplicate work.

**Plan impact:**

- Stage 1's glass A/B deferral is explicitly approved — it is **not** silently
  waived, and Stage 1's acceptance is not retroactively reopened.
- **The current glass appearance is NOT accepted.** Live values
  (`size 8 / passes 2 / vibrancy_darkness 0.38`) are not a shipped decision.
- Stage 4 must run the **complete** §3.2 glass A/B matrix: `12/1-pass` vs
  `8/2-pass`; `xray = true` vs `false`; optional `decoration:glow` rim accent;
  actual wallpaper visibility.

**Acceptance condition:** Stage 4 cannot close without Alex physically approving
the glass result.

---

### Decision 17 — Stage 3 remains blocked

**Status:** APPROVED / BINDING
**Applies from:** 2026-07-28, generation 26
**Decision:** Stage 3 implementation cannot begin until the complete Stage 2
close-out gate passes.

**Plan impact:** A read-only Stage 3 **mapping** session may be scheduled later.
It produces no implementation, touches nothing, and **cannot be used to claim
Stage 3 has started**. The interrupted mapping thread is not resumed; a fresh
mapping session is preferred (`CURRENT_STATE_AUDIT.md` §9).

**Acceptance condition:** The first Stage 3 implementation commit is permitted
only after this log records the Stage 2 gate as passed with Alex's acceptance,
the date, and the active generation.

---

### Decision 18 — Archive superseded PM material

**Status:** APPROVED / BINDING
**Applies from:** 2026-07-28, generation 26
**Decision:** Superseded handoffs, kickoff prompts, and authority-conflicting
plans leave the repository root and move into a dated archive at
`archive/superseded-handoffs/2026-07-28/`.

**Plan impact:** They remain in Git history and in the archive for provenance, but
they must not be presented as active instructions. Archived documents lose to
`CURRENT_STATE_AUDIT.md`, the latest dated entries in this log, `GRAND_PLAN.md`,
and `MASTER_REQUIREMENTS.md`. Nothing is deleted.

**Acceptance condition:** The repository root presents exactly one unambiguous
active PM entry set: `CURRENT_STATE_AUDIT.md`, `GRAND_PLAN.md`,
`MASTER_REQUIREMENTS.md`, `SESSION_PREAMBLE.md`, `EXECUTION_LOG.md`,
`PM_OPERATING_RULES.md`, `STAGE2_CLOSEOUT_WORK_ORDER.md`, `SOURCES.md`.

---

### Unresolved acceptance debt as of 2026-07-28, generation 26

**None of the following is passed. None may be treated as an implied pass.**

| # | Item | State | Origin |
|---|---|---|---|
| 1 | **TV-from-couch reachability** (Media Center reachable from the living-room LG TV) | **UNVERIFIED** — never physically tested; deferred at the Stage 0 gate, never picked up at Stage 1. Inference-backed only (firewall rule verified in the flake and in the live firewall-start script). | Stage 0 gate |
| 2 | **Xbox controller pairing** | **UNVERIFIED** — never physically tested; same deferral, same status. BlueZ LE tuning is in the flake and `/var/lib/bluetooth` is untouched, but nobody has held the controller. | Stage 0 gate |
| 3 | **VA-API / iHD encode confirmation** | **UNVERIFIED** — configured (`hardware.graphics.enable` + `intel-media-driver`) but never objectively verified. `vainfo` is not in the current system closure, so `GRAND_PLAN.md` §5.12's check has never been runnable as written. | Stage 1 gate |
| 4 | **Stage 2D half-snap rework** | **ACTIVATED, NOT LIVE-TESTED** — live in generation 26; no record of Alex exercising it. | Stage 2D |
| 5 | **Screenshot bindings and colour fidelity** | **ACTIVE AND FAILING / UNVERIFIED** — uniform mauve cast on both region and full-screen output; no recorded retest of the MASTER §5 defect. Now blocking Stage 2 (decision 15). | Stage 2B / decision 15 |
| 6 | **Disable-while-typing (DWT)** | **ABSENT** — the touchpad is classified `ID_INPUT_TOUCHPAD_INTEGRATION=external`, so libinput reports `Disable-w-typing: n/a`. The feature does not exist on this device; `disable_while_typing = true` has been a silent no-op for the entire build. | Stage 2C/2D |
| 7 | **Drag-anchor patch** | **WRITTEN, NOT BUILT** — patch and overlay committed (`df37152`) and PM-verified; the patched output is not a valid store path. Stock unpatched Hyprland is running. | Decision #10 |
| 8 | **Corner resize** | **NO IMPLEMENTATION** — non-negotiable by decision #11; no patch, no research artifact, no prompt. | Decision #11 |
| 9 | **§3.2 glass A/B** | **NOT RUN** — deferral to Stage 4 now explicitly approved (decision 16); the current glass appearance is not accepted. | Stage 1 gate / decision 16 |
| 10 | **Key repeat, pinch zoom, launcher, OSD, click-to-focus, window buttons** | **ACTIVATED, NOT RE-TESTED** on the current chain — free riders for the Stage 2 close-out sitting. | Stage 2A/2B |

**Stage status after this entry: `STAGE 2 — OPEN`.** Work order for closing it:
`STAGE2_CLOSEOUT_WORK_ORDER.md`.

---

### Session record — 2026-07-28 documentation and housekeeping pass

Documentation-only session. Actions taken:

- Prepended the current-authority warning header to this file (replacing the
  stale "Current handoff" pointer to the retired 2026-07-16 report).
- Appended this dated operator-decision entry (decisions 12–18 + acceptance debt).
- Added `## EXECUTION GOVERNANCE — 2026-07-28` to `MASTER_REQUIREMENTS.md`.
- Added narrow sequencing clarifications to `GRAND_PLAN.md` §10 (Stage 2, Stage 4,
  Stage 5). The architecture was not altered.
- Created `PM_OPERATING_RULES.md` and `STAGE2_CLOSEOUT_WORK_ORDER.md`.
- Committed `CURRENT_STATE_AUDIT.md` (previously untracked) byte-for-byte
  unmodified.
- Archived superseded root material to `archive/superseded-handoffs/2026-07-28/`
  with a manifest (decision 18).

**Not done, by scope:** no Nix/Lua/QML/C++/shell/service/patch edits, no
`nix build`, no `nixos-rebuild`, no Home Manager activation, no profile set, no
compositor or shell reload/restart, no plugin load/unload, no reboot, no Stage 2
implementation, no Stage 3 work, no old thread resumed.

---

# ═══════════════════════════════════════════════════════════════════
## STAGE 2 CLOSE-OUT — 2026-07-28 (evening) — ACTIVE GENERATION 26
# ═══════════════════════════════════════════════════════════════════

**Ground truth confirmed by the PM at session start (read-only):** branch
`codex/macbook-desktop`, HEAD `fa23198`, clean tree, 0 ahead / 0 behind
`origin/codex/macbook-desktop`. `/run/current-system` = `/run/booted-system` =
`/nix/var/nix/profiles/system` → `system-26-link`. **Active generation =
default boot generation = 26.** 0 failed system units, 0 failed user units,
Hyprland 0.55.4 running with hyprbars loaded. All three match the work order's
documented baseline.

Implementation session against `STAGE2_CLOSEOUT_WORK_ORDER.md`.

---

### Decision 19 — Corner resize is fixed compositor-side, not in Hyprbars

**Date/time:** 2026-07-28 22:20 CDT
**Active generation:** 26  (`readlink -f /nix/var/nix/profiles/system`)
**Stage:** 2 close-out, workstream C
**Status:** APPROVED — BINDING

**Original requirement:** `STAGE2_CLOSEOUT_WORK_ORDER.md` §2 C directed the fix
to "extend the carried Hyprbars patch narrowly". Operator decision #11 (binding)
requires ordinary corner resize on all four corners of a floating window, both
directions.

**Operator decision (Alex, in his words):** *"Approve the second narrow Hyprland
compositor patch. The required outcome is reliable ordinary corner resizing; the
earlier Hyprbars-only direction was a proposed implementation path, not a
constraint. Keep the patch isolated to decoration/corner hit-testing, preserve
normal border resize, titlebar drag, buttons, floating drag, snap, and Super+RMB,
and document why Hyprbars cannot own the fix. Build both compositor patches and
ABI-matched Hyprbars in the same final closure. Record this decision in
EXECUTION_LOG.md with date and active generation."*

**Reason — why Hyprbars provably cannot own the fix (PM-verified against the
pinned sources, not inherited):**

1. `CInputManager::onMouseButton` (`InputManager.cpp:715`) emits the plugin event
   bus **first** and returns on `info.cancelled` (`:717-719`), before dispatching
   to `processMouseDownNormal` (`:735`, defined `:823`). `CHyprBar::handleDownEvent`
   sets `info.cancelled = true` unconditionally for any press inside the bar
   (`hyprbars/barDeco.cpp:221`). So `extend_border_grab_area` **cannot** reach
   through the bar at any value — the resize code is never reached there.
2. `processMouseDownNormal` measured the grab band outwards from the **client
   surface** (`m_realPosition`/`m_realSize`, `:847-848`), i.e. `C ± (border_size +
   extend)` = `C ± 14`. Hyprbars declares `edges = DECORATION_EDGE_TOP`,
   `priority = 10005` (precedence over border), `reserved = true`,
   `desiredExtents = {{0, 30}, {0,0}}` (`hyprbars/barDeco.cpp:56-66`), so the
   visible top corners sit ~32 px above the client box — **18 px outside the
   band**. Both top corners were therefore unreachable; bottom corners already
   worked.
3. The visible top corners lie **outside** hyprbars' own decoration box
   (`[X, X+W] × [Y-30, Y]`), so a plugin patch cannot place a grab zone there at
   all; and the only place inside the bar where a top-right corner zone could live
   is directly on top of the carried close/maximize/minimize buttons
   (`hyprbars.lua.in`, three size-24 right-aligned buttons). No ordering in
   `handleDownEvent` yields both a corner zone and a working close button.

**On the "only works in one direction" framing (MASTER §5):** the floating resize
math in `DragController.cpp:305-345` was read end to end and is **symmetric**;
`drag_threshold` and `resize_corner` both default to 0. No literal expand/shrink
asymmetry was found and none was invented. The reported symptom is explained by
both top corners being unreachable, so every successful resize was anchored
top-left. **Flagged for explicit re-check at gate rows F3/F6/F9/F12** — if
one-directionality survives the patch, this explanation is wrong and the item
reopens.

**Upstream status:** `hyprwm/hyprland-plugins#355` is **open, filed by fufexan,
no PR, no commit**. Both hyprbars `main` and Hyprland `main` were fetched and the
causing code is unchanged. **There is nothing to backport** — this is genuinely
ours to carry.

**Plan impact:** A second compositor patch,
`modules/nixos/patches/hyprland-deco-border-grab.patch`, is carried alongside
`hyprland-drag-anchor.patch` in the same `hyprlandOverlay` in `flake.nix`. Three
hunks, one file (`src/managers/input/InputManager.cpp`). Zero hyprbars lines
changed, so the hover patch and `patchedHyprbars` are byte-identical and **no
plugin ABI surface moves**. Recorded in `SOURCES.md`.

**PM verification performed before landing it** (authority rule 1 — verify, do
not inherit): every cited line range was read directly in the pinned trees;
`patch -p1 --dry-run --fuzz=0` applies clean; `<ranges>` and `<algorithm>` are
already included in `InputManager.cpp` (`:6-7`) with `std::ranges::` already used
4× in-file; `g_pDecorationPositioner` is already used in the same file (`:2075`);
`Desktop::View::RESERVED_EXTENTS` exists (`Window.hpp:61`); `CBox::copy()` and
`CBox::expand()` exist (hyprutils 0.13.1 `Box.hpp:105,108`); and
`getWindowBoxUnified(Desktop::View::RESERVED_EXTENTS)` — the exact idiom the patch
adopts — is already used in-tree at `src/layout/LayoutManager.cpp:226`.
**Not yet compiled** — that is the remaining risk and it is resolved by the build.

**Revisit trigger:** upstream shipping a real fix for #355, or a compositor
version bump (both patches must be re-verified at the bump).

**Acceptance condition:** all four corners of a **floating** window expand *and*
shrink reliably, with titlebar drag, titlebar buttons, hover highlight,
double-click, ordinary border resize and `Super+RMB` all unregressed. Tiled
windows are excluded — dwindle one-directionality there is expected
(`GRAND_PLAN.md` §6.2) and is not a failure.

---

### Finding 19a — Decision 15's observed facts are partly corrected; its requirement is not reduced

**Date/time:** 2026-07-28 22:25 CDT
**Active generation:** 26
**Stage:** 2 close-out, workstream D
**Status:** FINDING — recorded, requirement unchanged

**Decision 15 recorded:** *"Both region **and** full-screen screenshots contain a
uniform mauve/pink cast"*, and bound the diagnosis to not assume an
overlay-only cause.

**Measured root cause:** `slurp`'s selection overlay is baked into the captured
frame. `scripts/screenshot-area:18` passes `-s "${tertiary}55"` and
`-c "${primary}ff"`. `#f1b5db` = (241,181,219) at alpha `0x55` (= 85 = 255/3)
over black predicts a floor of exactly **(80.33, 60.33, 73.00)**; real
screenshots measure **(80,60,73)**. Top-left border pixel measures
**(194,192,247)** against slurp's `-c #c3c1f8` = **(195,193,248)** — off by one
compositing rounding step.

**PM re-verification, independent of the agent** (ImageMagick 7 over
`~/Pictures/Screenshots`, 29 files): the (80,60,73) floor and the ~(194,192,247)
border reproduce across the tinted set. A clean `Print` capture reaches **true
0,0,0 and true 255,255,255** — no cast at all.

**The correction:** the tinted 2560×1600 files **carry slurp's border**, so they
were whole-screen *region drags*, not `Print` captures. No tinted file lacks a
slurp border; no clean `Print` file is tinted. **The full-screen path was never
defective.**

**Both of decision 15's forbidden assumptions are correctly excluded by
measurement, not by assertion:** the palette is not the cause (a 12-swatch
known-colour chart through `grim -o eDP-1` returned **0 error on all 36 channel
values**; no screen shader, no gamma client, no ICC, XRGB8888/sRGB), and the
physical display is **not** tinted. **Alex's eyes are not needed for this** — the
measurement resolves it.

**Plan impact — none to scope.** The requirement is **not** narrowed by the
smaller root cause. Per decision 15 and MASTER §1.6 the **final** `GRAND_PLAN.md`
§5.12 architecture still ships: the carried `modules/areapicker/` picker (whose
hide → `hasContent` → save handshake makes overlay contamination structurally
impossible), clipboard + timestamped PNG, `Print` full-screen mode, a clickable
System/bar path, visible errors on failure, and deletion of the interim scripts.
Patching the slurp flags and stopping is explicitly **not** an acceptable close.

**Operator interference during measurement, disclosed:** Alex minimized the
agent's fullscreen colour reference mid-run. The agent caught it from impossible
deltas (a `#FFFFFF` swatch reading 25,25,24), discarded that capture set before
interpreting it, added a uniformity gate, and re-ran — 1 capture passed, 2 failed
and were discarded. The contaminated file is retained for audit. **No
contaminated measurement reached a conclusion.**

**Carried forward, not absorbed** (§13 — log, do not fix):
- `getWindowExtentsUnified(RESERVED|INPUT)` **double-counts** hyprbars' 30 px
  (62 instead of 32), inflating every hyprbars window's hit box 30 px above
  itself and skewing top-edge snapping. Changes hit resolution globally; needs
  its own test pass. **Not fixed in this batch.**
- `modules/home/lock/default.nix:37` still consumes the now-stale theming cache.
- If Stage 4 revives `scripts/apply-wallpaper`, `awww` must return.

**Coverage gaps honestly recorded (corner-resize research):** `code.hyprland.org`
returned HTTP 403, so pre-0.55 hyprbars revisions could **not** be
source-verified — **no claim is made** about whether a regression commit exists.
`Sevenings/hyprland-plugins-more-bars` returned no README body — **unread, not
absent**. Neither gap is load-bearing for the selected fix, which is argued from
the pinned source we actually build.

---

### Build and deployment mechanics — corrections to the inherited machinery

- **Codex CLI path is stale in the archived handoff.** It is no longer at
  `/home/alex/.npm-global/bin/codex`; it now lives at `/home/alex/.local/bin/codex`.
- **`path:/home/alex/nix#…` is a disk hazard on this machine.** The path fetcher
  copies the whole worktree including the gitignored 11 GB `repos/`, with only
  ~15 GB free. A **bare-path flakeref** (`/home/alex/nix#…`) resolves to
  `git+file:///home/alex/nix`, is git-aware (honours `.gitignore`), includes the
  dirty working tree, and cost **15 MB**. Same evaluated configuration.
  Consequence to remember: **new files must be `git add`-ed before they are
  visible to the build** — an untracked patch fails eval with "not tracked by Git".
- **`--max-jobs 1 --cores 2`, not 2/2.** Machine evidence at session start: 1.7 GB
  available RAM (dropping to ~1.0 GB under compile), load ~1.9 on 4 cores, disk
  87% full, operator actively using the machine, and a second agent lane running
  concurrently. §8 of the work order permits a safer value on current evidence.

---

### Workstream status at time of writing — generation 26 still active, nothing deployed

| Workstream | Written | Built | Installed | Activated | Tested |
|---|---|---|---|---|---|
| A — drag-anchor patch | Y (pre-existing, `df37152`) | in progress | N | N | N |
| B — DWT hwdb reclassification | **Y** | in progress | N | N | N |
| C — corner resize compositor patch | **Y** | in progress | N | N | N |
| D — screenshot final architecture | in progress | N | N | N | N |
| Cleanup — retired packages | in progress | N | N | N | N |

**Workstream B pre-verification (before any build, so a failed match cannot cost
a reboot):** the hwdb rule compiles clean under `systemd-hwdb update --strict`,
and `systemd-hwdb query` against the device's **actual composed key** —
`touchpad:usb:v05acp0280:name:Apple Inc. Apple Internal Keyboard / Trackpad:`,
built per `70-touchpad.rules` from live sysfs values (`ID_BUS=usb`,
`id/vendor=05ac`, `id/product=0280`) — returns
`ID_INPUT_TOUCHPAD_INTEGRATION=internal`, with a negative control returning
nothing. Root cause re-confirmed live this session:
`udevadm info /dev/input/event7` → `ID_INPUT_TOUCHPAD_INTEGRATION=external`,
libinput → `Disable-w-typing: n/a`. Device path shows `apple-bce`/`bce-vhci`, a
virtual USB host bridge, which is why udev's PCB-port heuristic classifies it
external.

**Stage status: `STAGE 2 — OPEN`.** Nothing is built, installed, activated or
tested yet. No profile has been set, no reboot has occurred, generation 26 remains
active and remains the fallback.

---

### Finding 19b — Region capture resamples; pre-existing, mitigated not solved

**Date/time:** 2026-07-28 23:10 CDT
**Active generation:** 26
**Stage:** 2 close-out, workstream D
**Status:** FINDING — mitigation applied, full fix OWED (not deferred silently)

**What was found.** `QQuickItemGrabResult` sizes its render target as
`int(logicalSize) * devicePixelRatio`. This output is **1707×1067 logical at dpr
1.5** (confirmed from `hyprctl layers`, not assumed), and **1707 is odd**, so a
2560×1600 capture is bilinearly stretched onto **2561×1601**. The sampling phase
drifts linearly and wraps exactly once, so the blur is worst in the **middle** of
the frame — where windows are — and sharp at the edges.

Measured magnitude (from Qt source, `qquickitemgrabresult.cpp`):

| | horizontal 2560→2561 | vertical 1600→1601 |
|---|---|---|
| max neighbour blend weight | 0.5000 | 0.5000 |
| destination lines with weight > 0.25 | 1281 (**50%**) | 801 (**50%**) |

A one-pixel black stem on white goes 0 → 128: **127/255 worst-case error, half
the contrast of a thin feature**.

**This is NOT a regression.** The retired `screenshot-area` resampled too —
`grim -g "300,5 400x30"` returned **599×44** where 600×45 was expected. The new
path is no worse, and `Print` is now strictly better (see below).

**The colour gate cannot detect this.** Averaging two identical pixels returns
that pixel, so flat swatches report 0/36 error while thin features blur.
**Consequence for the gate: the screenshot fidelity row must be tested with a
one-pixel checkerboard or text, not colour swatches.** A swatch-only pass is a
false pass and must not be recorded as `PASS`.

**Mitigation applied this session:** `smooth: false` on the `ScreencopyView` in
`modules/home/aurora-shell/modules/areapicker/Picker.qml`. If the type honours
it, sampling becomes nearest-neighbour and every pixel except one duplicated
column and row is bit-exact. If it ignores it, behaviour is exactly today's.
**The failure mode is benign in both directions**, which is why it was taken
without operator escalation (decision 14 — routine implementation choice).

**OWED, with a revisit trigger — this is not closed.** The proper fix is to pad
the grab to an even logical width (1708×1068) and size the `ScreencopyView` to
`sourceSize/dpr` — roughly six lines. It was **not** taken this session because
it depends on `ScreencopyView` stretching its texture across the full item rect
with no aspect-fit letterboxing, and that is **unverified**: Quickshell's source
is not on disk (build outputs only) and the type carries a `constraintSize`
property that exists precisely for fitting. Shipping an unverified geometry
change into a one-reboot batch was judged the worse risk.
**Revisit trigger:** the gate's checkerboard test. If region capture is still
soft after `smooth: false`, the padding fix is implemented in the next batch with
Quickshell source in hand.

---

### Finding 19c — `Print` moved to grim; PM rejected a proposed quality regression

**Date/time:** 2026-07-28 23:10 CDT
**Active generation:** 26
**Stage:** 2 close-out, workstream D
**Status:** FINDING — resolved in implementation

The first implementation routed `Print` through the QML picker, which by the
mechanism in 19b would have produced a resampled **2561×1601** full-screen
capture. It was reported to the PM as *"a resample, colour-neutral, and
expected."*

**Rejected.** Finding 19a established — and the PM re-verified with ImageMagick
over `~/Pictures/Screenshots` — that the full-screen path was **never defective**:
`grim -o eDP-1` is byte-exact, 0 error across all 36 channel values of the
reference chart, true 0,0,0 and true 255,255,255. Accepting the resample would
have taken the one capture path that provably worked and made it measurably
worse, inside a change whose stated purpose was fixing screenshots. That is
narrowing intended quality and governance rule 4.1 forbids it.

**Resolution:** `Print` now captures via `grim` invoked from the shell's
`Screenshotter` service against `Hypr.focusedMonitor.name` (follows focus rather
than hardcoding `eDP-1`), with a non-zero exit or zero-byte file raising a red
error toast. This matches `GRAND_PLAN.md` §5.12's own wording — *"capture happens
via grim after geometry"* — and is **not** a return to the interim path: the
standalone `writeShellApplication` scripts stay deleted and the service still
owns naming, clipboard, toasts, the keybind and the utilities card. It also
deleted the invisible-mapped-layer-window, the `keyboardFocus: None`/`mask:
empty` special-casing and a 4-second timeout, so the design got smaller.

**Honest limitation recorded:** the grim path's success toast reports the
compositor's output geometry, not a read-back of the saved file. Region measures
the file; `Print` does not. Exit code plus `test -s` are the real signal.

**Carried forward, not absorbed:** `grim` resolves through the inherited PATH
rather than the shell's `propagatedBuildInputs`. This is **consistent with the
existing vendored design** — the shell tree already execs `sh` (×11),
`notify-send` (×2) and `wl-copy` (×1) the same way — and `packages.nix:15` now
carries a "Do not remove" annotation. Hardening it into
`aurora-shell/nix/default.nix` would touch a vendored subflake and its lock
mid-batch, which §3 of the work order warns against. **Owed as a later low-risk
change.**

---

# ═══════════════════════════════════════════════════════════════════
## OPERATOR DECISIONS — 2026-07-29 — ACTIVE GENERATION 26
# ═══════════════════════════════════════════════════════════════════

**Ground truth confirmed by the PM (read-only):** branch `codex/macbook-desktop`,
HEAD `04cab49`, 0 ahead / 0 behind upstream, tree clean except the replacement
`GRAND_PLAN.md`. `/run/current-system` = `/run/booted-system` =
`/nix/var/nix/profiles/system` → **generation 26**. Zero failed system units, zero
failed user units, Hyprland 0.55.4 with hyprbars loaded, **zero config errors**.

**Generation 27 is a compile/staging milestone, not the Stage 2 candidate.** It
was built and staged boot-only on 2026-07-28, but it predates the architecture
decisions below. Per operator instruction it must not be booted.

**PM action taken on this basis, before any other work:** generation 27 was the
default boot target and the armed-resume flag was set, so any unplanned reboot —
including one initiated by the concurrent seedbox lane — would have booted it and
bypassed the gate. The profile was switched back to generation 26
(`nix-env --switch-generation 26` + `switch-to-configuration boot`) and the resume
flag was removed. Generation 27 remains a numbered generation and its store
outputs remain valid, so **the patched compositor and ABI-matched hyprbars will be
reused rather than recompiled**.

---

### Decision 20 — Corrected architecture, 2026-07-29

**Status:** APPROVED / BINDING
**Applies from:** 2026-07-29, generation 26
**Source:** operator architecture correction; `GRAND_PLAN.md` replaced the same day
and is authoritative. The full decision list is `GRAND_PLAN.md` §10.2; it is
recorded here because conversation memory is not a decision record (decision 13).

**Naming and palette**

1. **Aurora is the project/shell codename only — it is not a colour scheme.**
2. The teal/purple/green aurora-borealis palette is named **Northern Lights** and is
   one preset/result, **not** the system default.
3. Glass, cohesion, readability, geometry and motion **persist**; light/dark mode and
   the entire semantic colour system **follow the wallpaper**.
4. Auto mode is **dark-preferred** for dark/evening/shadowed wallpapers and **light**
   for clearly light/high-key wallpapers.
5. A dark red wallpaper must produce a cohesive **burgundy/oxblood/crimson system** —
   not black glass with a red outline. A light cream/yellow wallpaper must produce a
   coherent light cream/gold system with dark readable foregrounds.
6. Every supported consumer recolours: top bar, left rail, panels, notifications,
   lock, application chrome, terminal, file manager, borders, gradients, supported
   applications.
7. User theme control: **Auto from wallpaper / Force dark / Force light**.

**Palette ownership** — skwd-wall renders/applies and emits the apply event →
SkwdBridge opens one palette transaction → the project's **patched caelestia
semantic generator** chooses auto-dark/auto-light and derives the complete semantic
role set → atomic templates publish every consumer → `Colours.qml` animates the
shell scheme. iNiR and agridyne supply consumer mappings and cohesion patterns.
**Matugen is not the system-wide authority** (skwd-internal use may remain scoped to
the picker UI). **Hellwal is fallback only.** The generator must recolour real
surfaces and foregrounds, not merely accents.

**Surface ownership**

8. **Top bar — ilyamiro, nearly 1:1**: independent widget islands; three visible
   workspace pills plus `+`, active extras shown responsively; media/now-playing/EQ;
   centred clock/date/weather; tray/language, network, Bluetooth, audio, battery;
   approved resources/System additions. **No pinned, running or minimized
   applications.**
9. **Left rail — the caelestia app/window surface**: launcher; pinned applications
   always visible; running/minimized windows **from the current workspace only**;
   minimized entries dimmed; exact live previews for multiple windows; one-click
   focus/restore. **No duplicate workspace/calendar/tray/network/Bluetooth/audio/
   battery stack.**
10. Rail persistence versus immediate hover-reveal is decided **only after** the
    completed top and left surfaces are viewed together. Both remain configurable.

**Window model**

11. **`follow_mouse = 2`** — pointer scrolling follows the hovered window; keyboard
    focus remains click-controlled; clicking transfers keyboard focus normally.
12. Minimized windows **retain original workspace identity** and leave layout,
    render and input.
13. **`special:min-*` is rejected as the final backend.**
14. The **left rail is the mandatory one-click restore surface**; a hotkey is
    optional redundancy only.
15. `Super+Left` / `Super+Right` **always** mean exact left/right halves, regardless
    of window count or layout.
16. Snapping onto an occupied side **minimizes the previous side occupant**.
17. Completing a left/right pair **minimizes all surplus same-workspace windows**.
18. Restoring a surplus window, or dragging/unsnapping/maximizing/closing a pair
    member, **dissolves the pair** and returns to ordinary tiling, preserving prior
    state where possible. **No silent close or window loss.**

**Retired dashboard**

19. The Caelestia **dashboard UI is removed**: no drawer, no top-edge hover/swipe, no
    duplicate calendar/media/performance/weather tabs. Reusable data/services may
    still feed approved independent widgets, Nexus and sysmon. **Retiring the
    dashboard UI is not retiring caelestia as a donor.**
20. **Four-finger up opens Hyprexpo Overview**; a visible mouse path must also exist.

**Lock** — a deliberate multi-source composition: agridyne primary visual
composition; Vast depth planes and gated cinematic unlock; selected ilyamiro
clock/PIN/motion details; iNiR/DMS status; DMS lifecycle/safety; Hyprlock emergency
fallback only. **This must not be collapsed to a single owner.**

**Workflow**

21. Expensive builds start **only after a published frozen batch manifest**.
22. One coherent build, one boot-only deployment, one reboot, one gate, unless
    explicitly approved otherwise. Do not compile or stage a generation per small
    config/script/QML/doc fix. A validation-only compile must name the uncertainty it
    resolves and why cheaper static checks are insufficient.
23. **Reuse existing Hyprland/Hyprbars store outputs when the source patch set is
    unchanged.** Never trigger a compositor/plugin recompile merely because unrelated
    configuration or shell code changed.
24. Later-stage work may proceed in **isolated worktrees** during build/reboot/
    operator waits; deployed closures remain **stage-pure**.
25. **Sonnet-first** for narrow diagnosis, source location and straightforward
    implementation. The PM reviews the evidence and escalates only when justified.
26. **Pinch zoom is already physically PASS** and is not retested unless touched.

**Acceptance condition:** `GRAND_PLAN.md`, `MASTER_REQUIREMENTS.md`,
`STAGE2_CLOSEOUT_WORK_ORDER.md`, `PM_OPERATING_RULES.md`, `SOURCES.md` and
`docs/stage-gates/stage2-closeout.md` all reflect these decisions, and the
documentation correction is committed and pushed **before** implementation resumes.

---

### Finding 20a — same-workspace minimize backend: the mechanism already ships

**Date/time:** 2026-07-29 02:40 CDT
**Active generation:** 26
**Status:** FINDING — PM-verified; satisfies decision 20 items 12–14 without
offscreen hiding and without a special workspace

The compositor already contains the exact primitive pair, and it is not a novel
hack: `Actions::toggleSwallow()` (`src/config/shared/actions/ConfigActions.cpp`,
verified by direct read) hides a window with `setHidden(true)` +
`g_layoutManager->removeTarget(…->layoutTarget())`, and restores it with
`setHidden(false)` + `g_layoutManager->newTarget(…, pWindow->m_workspace->m_space)`.
It **reads** `m_workspace` rather than writing it — which is precisely why workspace
identity survives, and precisely how this differs from the rejected
`special:min-<address>` approach in `scripts/window-minimize`, which really does
move the window.

**Verified live on this machine, not inferred:** `hyprctl clients -j` already emits
`"hidden"` and the real per-window `"workspace"` for every client. **The rail needs
no new IPC** for the minimum viable version.

**Verified reachability** (this project has already paid for a dispatcher that
parsed and then failed at runtime under native-Lua config): `HL.PluginNamespace` in
the compositor's own installed stub `share/hypr/stubs/hl.meta.lua` is declared
`[string] any`, and hyprbars registers `hl.plugin.hyprbars.add_button` through
`LuaBindingsInternal.hpp` — so a plugin can expose Lua-callable functions by the
same route. The shell's rail click can also reach it over IPC independently of Lua.

**Chosen implementation:** an ABI-pinned plugin built exactly as hyprbars already
is, exposing minimize/restore. **This requires no compositor recompile**, because
the Hyprland patch set is unchanged and its built output is reused — which is what
decision 20 item 23 requires.

**Honest costs recorded, not buried:**
- Detaching a layout target removes it from `CSpace::m_targets`, so the **aggregate**
  `hyprctl workspaces -j` window count under-counts a workspace holding only
  minimized windows. The per-window `clients -j` listing stays correct. **The rail
  and the workspace pills must query `clients`, never the `workspaces` aggregate,
  for occupancy.** This also constrains the Stage 3 workspace-pill logic.
- This specific application is **compositor-source-native but not
  community-proven**: every public Hyprland minimize tool uses the special-workspace
  trick. The underlying primitives are old and stable, but the composition must get
  a live-test pass before the snap-surplus-minimize orchestration is trusted on it.

---

### Finding 20b — Hyprexpo does not exist in any source we have

**Date/time:** 2026-07-29 02:40 CDT
**Active generation:** 26
**Status:** FINDING — logged, **not absorbed**; not Stage 2 blocking

Decision 20 item 20 names Hyprexpo Overview. **Hyprexpo is not available**:

- not in the pinned `hyprland-plugins` v0.55.0 checkout (`90e66baf`), which contains
  only `hyprbars`, `hyprfocus`, `borders-plus-plus`, `csgo-vulkan-fix`;
- not anywhere under `repos/`;
- **not in nixpkgs' `hyprlandPlugins` at all.** The overview-class plugins nixpkgs
  does expose are **`hyprspace`** and **`hycov`**.

This gap was already flagged independently in `codex-prompts/stage2a-window-model.md`
and `research/window-input.md` and was never resolved. **This is the third time it
has been found.** It is recorded here so it stops resurfacing.

**Impact:** none on Stage 2 — Hyprexpo is Stage 5 scope (`GRAND_PLAN.md` §10). It
will block the Stage 5 desktop-layer gate unless resolved. **Requires an operator
decision before Stage 5**: adopt `hyprspace`, adopt `hycov`, source Hyprexpo from
upstream outside nixpkgs, or drop the overview requirement. **No substitution has
been made and none is implied.**

---

### Finding 20c — Stage 2 implementation calls, 2026-07-29

**Active generation:** 26 (nothing built or deployed for this batch yet)

**`Super+K` / dashboard binding — RETAINED, reversing an implementation session's
removal.** The snap session removed `Super+K` → `caelestia:dashboard` on the grounds
that the dashboard is retired architecture (decision 20 item 19), and correctly
surfaced the conflict with `STAGE2_CLOSEOUT_WORK_ORDER.md`, which had logged that
bind as "not fixed here". **PM verified the actual state of the machine rather than
the paperwork:** `modules/home/aurora-shell/modules/dashboard/` still contains **24
QML files** and `hyprctl globalshortcuts` still registers **`caelestia:dashboard`**
— the surface is retired on paper only. Removing the bind now would delete the sole
access path to calendar/media/performance/weather with **no replacement until the
Stage 3 top bar ships**. That is the same class of error the operator caught when
hiding `special:min-*` before the taskbar existed would have made minimize a one-way
trip. **The bind is restored, with an in-file comment recording that it retires
*with* the Stage 3 top bar, not before.** No requirement is narrowed; a functional
regression is avoided.

**Minimize interface contract — PM contract is authoritative.** The research report
suggested `minimizewindow`/`restorewindow`; the PM instead fixed the contract as
`hl.plugin.auroraminimize.minimize/restore` plus `aurora:minimize`/`aurora:restore`
dispatchers, **before** launching the dependent sessions, so the snap and rail work
could proceed in parallel instead of serialising behind the plugin. The snap session
coded to the PM contract and guarded the calls so an unloaded plugin no-ops rather
than erroring. The plugin session was given the same contract and instructed to stop
and report rather than silently substitute. **If the delivered plugin differs, only
two Lua functions need updating — the rest is decoupled.**

**Snap poll cost — checked, acceptable.** The 400 ms repeat timer runs
**in-process** (`hl.timer` → `reconcile_all_pairs`); it does not spawn `hyprctl`.
With no active pair it iterates an empty table inside one `pcall`, so idle cost on
this dual-core machine is negligible. No change made.

**Known limitation, recorded not hidden:** snap pair bookkeeping lives in
module-level Lua tables and **does not survive `hyprctl reload` or a Hyprland
restart**. Physical windows are unaffected — minimized state lives in the compositor
(`setHidden`), not in Lua — so **no window is stranded or lost**, and surplus windows
remain restorable from the rail. What is lost is only the pair association, meaning
a post-reload arrow press starts a fresh pair. **This becomes a gate row rather than
a silent assumption.**

**`follow_mouse = 2` verified from source, not from documentation habit.**
`ConfigValues.cpp:294-295` maps the option
`{disabled:0, follow:1, detached:2, separate:3}` — mode 2 is the named **detached**
mode, which is exactly the required "pointer scroll follows hover, keyboard focus
stays click-controlled" behaviour.

**Build economy confirmed by evaluation, not assumption:** with the config changes
applied, `nixosConfigurations.macbook.pkgs.hyprland.drvPath` still evaluates to
`sga9ci25…-hyprland-0.55.4.drv`, whose output `wrz9r718…` is already valid in the
store. **The final Stage 2 build will not recompile Hyprland or Hyprbars**, per
decision 20 item 23.

---

### Finding 20d — Hyprexpo resolved: retired upstream, community continuation exists

**Date/time:** 2026-07-29
**Active generation:** 26
**Status:** FINDING — the sourcing gap flagged three times is now explained

Finding 20b recorded that Hyprexpo was absent from the pinned `hyprland-plugins`
checkout, from `repos/` and from nixpkgs entirely, and that the gap had already been
raised twice in earlier prompts without resolution.

**Cause found:** Hyprexpo was **retired from upstream `hyprwm/hyprland-plugins`
around May 2026** (tracked upstream as `hyprwm/hyprland-plugins#672`). The pinned
checkout is commit `90e66ba` dated 2026-05-13, and its own README plugin list omits
hyprexpo — only a stale example snippet still references it, which is why every
previous search found the name but never the code. **It is not missing from our
sources by mistake; it no longer exists there.**

**A maintained community continuation exists** at `github.com/sandwichfarm/hyprexpo`,
installable via `hyprpm add`.

**Operator position, already given:** the requirement stands — four-finger-up opens
Hyprexpo Overview, with a visible mouse path. That is not reopened.

**Implementation status:** the Stage 3 top bar builds the **mouse entry point** (a
`grid_view` button beside the workspace pills, with hover label) dispatching the
plugin's real `hyprexpo:expo toggle` verb. It is **inert until a plugin build is
added** and is deliberately **not wired to a substitute** — `hyprspace` and `hycov`
exist in nixpkgs and were **not** silently swapped in.

**Owed before the Stage 5 gate:** package the community continuation as an
ABI-pinned plugin, exactly as `hyprbars` and `aurora-minimize` are built. This is a
new third-party source and must be recorded in `SOURCES.md` when adopted. **Not
Stage 2 scope; no substitution has been made.**

---

### Stage 3 progress — isolated worktree, stage-pure

**Branch `stage3/topbar`**, worktree `/home/alex/aurora-stage3`, pushed. **Verified
isolation:** the Stage 2 tree contains zero topbar files; the worktree diff is
`shell.qml` (+5 lines) plus the new `modules/topbar/` tree. **Nothing from Stage 3
enters the Stage 2 closure** (decision 20 item 24).

23 QML files, 11 islands, 8 expanded panels, built after reading ilyamiro's
`TopBar.qml` (1567 lines) and `Main.qml` (531 lines) in full and viewing all 16
preview images **before** any composition decision — the discipline
`SESSION_PREAMBLE.md` exists to enforce. Data is bound to caelestia's real services
rather than stubs. **No app tasks on the top bar; no dashboard UI rebuilt.**

Stubbed and flagged rather than silently dropped: the radial Bluetooth
constellation, the battery-ring composite, media width-morph, workspace overflow.

---

### Finding 20e — rail status entries restored; a severe regression caught pre-build

**Date/time:** 2026-07-29
**Active generation:** 26 (nothing deployed)
**Status:** FINDING — PM reversal, second of the same class today

The rail implementation session pruned `Bar.qml`'s rendered entries to
`logo` + `appRail`, **deleting the `DelegateChoice` blocks** for `workspaces`,
`activeWindow`, `tray`, `clock`, `statusIcons`, `power` and `spacer`, and stubbing
`closeTray()`/`checkPopout()` to no-ops. It was following its brief, which required
the rail to carry no duplicated system-status stack.

**That instruction was conditioned on the replacement existing. It does not.** The
ilyamiro top bar lives on branch `stage3/topbar` in an isolated worktree and is
**deliberately not in the Stage 2 closure** (decision 20 item 24). On the machine
Alex would actually boot, this deleted the only copy rather than de-duplicating
anything.

**Concretely, deploying it would have cost, with nothing in their place:** the
system tray and every tray application, the clock, network/Bluetooth/audio/battery
status and their popouts, the workspace indicator, and **the power menu — no GUI
logout, shutdown or reboot.**

**This is the third instance of the same error class on this project**, and the
second today: the operator caught it when hiding `special:min-*` before the taskbar
existed would have made minimize a one-way trip; the PM caught it earlier today on
the `Super+K` dashboard bind (finding 20c); and now here. **"Retired in the
architecture" is not "replaced on the machine."**

**Resolution.** Rather than patch the pruned file, `Bar.qml` was restored from
`HEAD` — a known-good base — and the `appRail` delegate re-added additively, so the
app rail now renders **alongside** the full status stack. `appRail` was added to the
`entries` default in
`modules/home/aurora-shell/plugin/src/Caelestia/Config/barconfig.hpp`, positioned
directly under logo/workspaces so the app stack owns the upper rail and the existing
spacers push status to the bottom. The in-file comment now states the truth: the
status entries are **retained until the Stage 3 top bar ships and retire with it**,
not before.

**Nothing built by that session was discarded** — `AppRail.qml`, `RailTile.qml`,
`RailGroupPreview.qml`, the `PopoutState.qml` properties and the `Content.qml`
popout case all stand, including its correct handling of the mid-flight IPC
correction and its visible-failure toast for a restore that returns
`unknown request` while the plugin is unbuilt.

**Verified after the reversal:** all eight entry ids have both a delegate and a
default entry; `qmlformat` parses `Bar.qml`, `AppRail.qml`, `RailTile.qml`,
`RailGroupPreview.qml`, `PopoutState.qml`, `Content.qml`, `Screenshotter.qml` and
`Picker.qml` cleanly.

**Consequence for the gate:** a row is added requiring that clock, tray, status
icons and the power menu are all still present and working after the reboot. That
check now exists precisely because this nearly shipped.

---

### Decision 21 — No surface is removed before its replacement is live

**Date/time:** 2026-07-29
**Active generation:** 26
**Stage:** standing rule, applies to every stage
**Status:** APPROVED / BINDING

**Original requirement:** `GRAND_PLAN.md` describes end-state ownership — the top
bar owns system status, the rail owns applications, the dashboard UI is retired,
`special:min-*` is rejected. Those statements are about the finished desktop.

**Operator decision:** *"yes thats corrrect"* — approving the PM's proposed standing
rule: **no surface may be removed until its replacement is live in the same
closure.** "Retired in the architecture" is not "replaced on the machine."

**Reason.** Three separate sessions each deleted a still-load-bearing surface while
**correctly following a brief that described the end state**:

1. `special:min-*` workspace visibility, before the taskbar existed — would have made
   minimize a one-way trip. **Caught by the operator.**
2. The `Super+K` dashboard bind — the dashboard UI is retired on paper but is still
   24 QML files with a live registered global, and the replacement widgets arrive
   with the Stage 3 top bar. **Caught in PM review** (finding 20c).
3. The rail's `workspaces`/`tray`/`clock`/`statusIcons`/`power` entries — the top bar
   that replaces them is on branch `stage3/topbar` and is not in the Stage 2 closure.
   Would have shipped a desktop with no tray, no clock, no status and **no GUI
   shutdown**. **Caught in PM review** (finding 20e).

The agents were not at fault. **The briefs were** — each stated the end state as
though it were the current target. That is a PM defect and is now corrected at the
source.

**Plan impact:**
- Recorded in `PM_OPERATING_RULES.md` §2 as a binding rule.
- **Every agent brief must state the *current* target, not the end state**, and must
  name explicitly what may not be removed yet.
- Anything retained past its architectural retirement carries an in-file comment
  naming the stage that retires it, so it is removed on schedule rather than
  forgotten.

**Revisit trigger:** none — final. The operator may still direct a specific early
removal case by case, accepting the interim loss knowingly.

**Acceptance condition:** the concrete test, applied before any removal ships:
**after this closure boots, can the user still do the thing the removed surface
did?** If not, it stays.

---

### Decision 22 — Dashboard UI entry paths disabled (approved exception to decision 21)

**Date/time:** 2026-07-29
**Active generation:** 26
**Status:** APPROVED / BINDING — **explicit operator exception to decision 21**

**Operator decision, in his words:** *"Disable every dashboard entry path now —
Super+K, top-edge hover/swipe and any clickable trigger. Backend services may remain
because future ilyamiro widgets need them, but the dashboard UI must not open. This
is an explicit operator-approved exception to the replacement-before-removal rule
because the dashboard itself is unwanted duplication, not a capability that needs
temporary preservation."*

**Why this is an exception and not a breach of decision 21.** Decision 21 exists to
stop a *capability* disappearing before its replacement is live. The dashboard is
judged by the operator to be **duplication rather than capability** — its content
(calendar, media, performance, weather) is being rebuilt as independent Stage 3 top
bar widgets, and its removal costs nothing that needs bridging. Decision 21 already
reserved this: *"the operator may still direct a specific early removal case by
case, accepting the interim loss knowingly."* This is that case, exercised
explicitly. **This reverses finding 20c**, which retained `Super+K` on
decision-21 grounds; that retention was correct under the rule and is now
superseded by the operator's exception.

**Four entry paths found and closed** — the search was exhaustive rather than
stopping at the obvious one:

1. **`Super+K` keybind** — removed from `keybinds.lua`.
2. **`caelestia:dashboard` global shortcut** — **registration removed** from
   `modules/Shortcuts.qml`. This matters more than unbinding: an unregistered global
   cannot be reached by a keybind, by `hyprctl`, or by any clickable surface that
   dispatches it.
3. **`caelestia:showall`** — previously toggled `v.dashboard` alongside launcher/osd/
   utilities; the dashboard term is dropped, the other three are unaffected.
4. **Top-edge swipe** (`drawers/Interactions.qml`) — **the one path neither
   `showOnHover` nor `enabled` reached**, because it sets `screenState.dashboard`
   directly on drag. Now gated on `Config.dashboard.enabled`.

**Plus two defence-in-depth defaults**, so a missed path still cannot raise the
surface: `Config.dashboard.enabled = false` (makes `dashboard/Wrapper.qml`'s
`shouldBeActive` false regardless of `screenState`) and
`Config.dashboard.showOnHover = false` (kills the hover reveal).

**Backend services untouched and still running.** `services/` was not modified —
verified by `git status` — so `Players.qml`, `Weather.qml`, `NetworkUsage.qml`, the
CPU/memory/storage services and the rest continue to run for the Stage 3 ilyamiro
widgets, exactly as the operator required. Only the UI surface and its entry paths
are dead; `modules/dashboard/` remains in the tree as a component source.

**Acceptance condition:** after reboot, `Super+K` does nothing, no top-edge hover or
swipe raises the dashboard, no clickable path opens it, and the Stage 3 widgets can
still read live media/weather/resource data when they arrive.

---

### Reboot — generation 31, 2026-07-29

**Operator approved the single reboot**, with the added requirement that the
working set return: this build terminal, the seedbox terminal, and Chrome.

**Honest constraint stated to the operator rather than glossed:** Wayland/Hyprland
has **no session manager**. Windows do not persist across a reboot and there is
nothing to "restore" — they must be **relaunched**. The armed-resume hook previously
brought back only the build terminal.

`scripts/aurora-resume-agent` now relaunches all three, each with its own working
directory because that is what decides which conversation `claude --continue`
resumes: Chrome first (slowest to paint; its own `restore_on_startup: 1` restores
the tabs), then a terminal in `~/Media-Center` for the concurrent seedbox lane, then
the build terminal in `$HOME`. Chrome is guarded so a browser failure cannot abort
the terminals. Still gated on the armed flag — an unplanned boot brings nothing back.

**Staged generation 31**, boot-only. Gen 26 remains the fallback. Zero compositor
recompiles across all four rebuilds in this sequence — the patch set never changed,
so `wrz9r718…` was reused throughout, as decision 20 item 23 requires.

**State at reboot:** zero failed system units, zero failed user units.

**Stage 2 remains OPEN.** The reboot is a runtime-validation pass; the physical gate
follows.

---

# ═══════════════════════════════════════════════════════════════════
## STAGE 2 RUNTIME GATE — FAILED — 2026-07-29 — GENERATION 31
# ═══════════════════════════════════════════════════════════════════

**Generation 31 booted and remains active** while the correction batch is
developed. **Generation 26 remains the fallback.** Operator halted further testing
for this generation — sufficient blocking evidence exists.

### Operator results, recorded verbatim

**Passed**
- Tiled titlebar drag remains under the cursor.
- Basic compositor minimize/restore works for an isolated single-app window.
- Natural palm placement does not move the cursor.
- Clock/tray/status/launcher/power basics appear intact.
- Super+K and the top-edge dashboard trigger are dead.

**Blocking failures**

1. **Corner resizing.** Corner drag only resizes horizontally. It does not provide
   diagonal grow/shrink. The accepted behavior must work from the normal window
   state without requiring Alex to perform an unexplained manual "float first"
   preparation step. Test both tiled split-resize semantics and freeform/floating
   resize. All four corners must move both relevant axes and support grow and
   shrink.
   **Operator correction to the test record:** *"Floating corner resize: PASS,
   incidental and not the acceptance target. Tiled corner resize: FAIL, Stage 2
   blocker."* The accepted requirement is ordinary mouse resizing on **normal tiled
   windows** — grabbing any corner must resize both applicable axes where
   neighboring layout space permits, **without first toggling the window floating
   and without requiring a memorized hotkey.** *"Do not treat working floating
   resize as resolution, and do not introduce 'float first' as the workflow. Alex
   does not ordinarily use floating windows and does not want floating behavior
   elevated into a prerequisite or primary window-management model."*

2. **Deterministic snap.** Current behavior is not a half snap: the selected window
   becomes floating; it is offset beyond the usable upper-left work area; it does
   not occupy the exact half; the existing surplus window remains tiled
   beneath/alongside it instead of minimizing. Must reconcile/minimize the existing
   occupant and surplus **before** final placement, then place into exactly 50% of
   the usable desktop area excluding rail/reserved margins. Must not rely on
   Hyprland opportunistically allocating a dwindle slot before the snap state
   machine finishes.

3. **Rail and grouped applications.** Single-window Thunar minimize/rail restore
   worked. Two windows of the same app failed: Kitty displayed one icon with two
   dots but no usable exact-window preview; minimizing one Kitty window left no
   distinguishable recovery item; clicking the grouped icon did nothing; grouped
   hover previews are a complete failure. The rail must expose **exact windows** for
   grouped apps, visibly distinguish minimized members, and restore the selected
   address — not merely operate on the application group.

4. **Brightness-to-zero rail bug.** Hovering/interacting around a valid minimized
   rail entry caused display brightness to fall to zero. **Severe; must be
   root-caused, not masked.** No ordinary hover may invoke brightness control.

5. **Floating-window focus.** `follow_mouse=2` behaves correctly for ordinary tiled
   windows, but merely hovering a floating window transfers keyboard focus.
   Tiled and floating must both: receive pointer scrolling under hover; retain
   keyboard focus on the last clicked window; transfer keyboard focus only on click.

6. **DWT clarification.** Palm rejection passed. Touchpad suppression during active
   typing may be normal DWT behavior — measure how quickly pointer control returns
   after typing stops. Do not classify as a failure unless suppression persists
   beyond a reasonable libinput delay.

7. **Screenshot lifecycle and UI.** Region/window screenshots can produce sharp,
   colour-correct output, but integration fails: closing/completing capture leaves
   the visibly focused prior window unable to receive typing until clicked again;
   selecting another window for capture can transfer subsequent typing into that
   window; automatic window bounds appear inconsistent for floating windows; **Alex
   has no Print key**, so "press Print" is not a valid full-screen path; a
   screenshot/image utility appears as a dead icon in the app rail.

8. **Boot time/network readiness.** After reboot, Chrome restored before time was
   reliably synchronized, produced a clock error and invalidated ChatGPT
   authentication. The resumed terminal harness also emitted an API error before its
   reboot-resume message. Treat as one likely boot-readiness problem but **verify
   rather than assume**. Fix the root boot ordering; **do not special-case ChatGPT**.

9. **Wallpaper replacement.** Wallpaper rendering works, but Alex could not locate
   the claimed picker/change path. Since Waypaper and awww were removed on the
   assertion that a live replacement exists, report the exact ordinary mouse path.
   **If it is not presently discoverable and usable, that cleanup gate remains
   failed.**

**Screenshot evidence:** image 1 visibly confirms the snap defect — offset floating
overlay rather than an exact usable half, with another window remaining behind it.
Image 2 contains only the selected terminal window and is sharp and colour-correct,
proving exact-window output can work in at least that case.

### Also approved for the next reboot

The already-approved one-time procedure making **NixOS the persistent default boot
target**, folded into the correction batch — **not** a separate reboot.

---

### Requirement addition — screenshot capture toolbar (2026-07-29)

**Operator requirement, added to the correction batch. Part of the final screenshot
architecture, not optional polish.**

When screenshot mode opens, a **compact toolbar centred at the top of the screen**
(Windows Snipping Tool in spirit) offering clearly clickable **Region · Window ·
Full screen**.

- Toolbar appears whenever screenshot mode opens; current mode is visually obvious.
- Region = manual rectangular selection. Window = highlights and captures only the
  selected window's **exact** bounds. Full screen = entire active display, one click.
- Completion or Escape closes the toolbar and **restores the exact previously
  focused window**.
- Hovering or selecting a capture target **must not** permanently transfer keyboard
  focus.
- The toolbar, picker and screenshot services **must never** appear as app-rail
  entries or in captured output.

**Alex has no Print key**, so full-screen capture must be reachable **directly from
this toolbar**. A keyboard shortcut is optional redundancy only — this supersedes
the earlier plan to solve the no-Print-key problem with a replacement bind.

**Two hazards flagged to the implementing session as already paid for:**
1. **The toolbar must not be captured.** This is the pink-film class of defect —
   slurp's overlay composited into the frame, proven arithmetically (alpha `0x55` =
   ⅓ → predicted floor (80.33, 60.33, 73.00) vs measured (80,60,73)). The toolbar
   must sit outside the captured subtree **by construction, not by timing**, and the
   full-screen path must not race its teardown.
2. **Focus.** The toolbar is another layer-shell surface able to take keyboard focus
   and must not become a second way to strand the operator's focus.

**Cross-session handoff owned by the PM:** the rail can only filter what it can
identify, so the screenshot session must give every shell-owned ephemeral surface a
stable, unambiguous namespace/objectName and list them; the PM hands those
identifiers to the rail session, which owns the filtering.
