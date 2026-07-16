# Execution log

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
