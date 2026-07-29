# Source ledger

Every imported idea or adapted component is reviewed before use. A missing
license is recorded as provenance; it is not treated as a quality or malware
signal for this personal installation.

## Vendored components

| Component | Upstream repo | Upstream path | Vendored path | Local delta |
|---|---|---|---|---|
| aurora-shell chassis | `github.com/caelestia-dots/shell` | `/` | `modules/home/aurora-shell/` | Attribution headers; path-input revision fallback build shim; aurora scheme defaults (ladder pinned, dark default, accent families); Stage 1C cutover — HM module renamed to `programs.aurora-shell` + unit `aurora-shell` (§2.2 hardening, `KillMode=process`), dunst fallback keeper carried with a static `assets/fallback-dunstrc`, write-if-absent `assets/aurora-scheme.json` state seed. <!-- # Aurora: Stage 1B/1C local delta. --> |
| window-minimize | `github.com/OnlyLyan/omarchy-desktop-shell` | `05-hyprbars-titlebar/files/window-minimize` | `scripts/window-minimize` | Vendored **verbatim** (upstream now cloned to `repos/omarchy-desktop-shell`); only an attribution header added — runtime deps come from the `writeShellApplication` wrapper. The same repo's `hyprbars.conf` traffic-light button values (red/yellow/green ✗/⌄/◇) are used in `modules/home/hyprland/hyprbars.lua.in`, translated to the native-Lua `hl.plugin.hyprbars.add_button` API. (Stage 2A) |

## Carried compositor and plugin patches

Narrow, isolated patches carried against pinned upstreams. Each is justified by a
proven mechanism read from the pinned source, applies with zero fuzz, and is
listed here before it is adopted.

| Patch | Upstream | Pinned revision | Touches | Why it is carried |
|---|---|---|---|---|
| `modules/nixos/patches/hyprland-drag-anchor.patch` | `github.com/hyprwm/Hyprland` | `0.55.4` (`a0136d8c`) | `src/layout/supplementary/DragController.cpp`, one hunk inside `if (m_dragThresholdReached)` | Restores Hyprland's own former behaviour: a tiled window picked up for a drag keeps the normalized grab anchor instead of jumping centre-under-cursor. Operator decision #10 (2026-07-22). |
| `modules/nixos/patches/hyprland-deco-border-grab.patch` | `github.com/hyprwm/Hyprland` | `0.55.4` (`a0136d8c`) | `src/managers/input/InputManager.cpp`, three hunks — `processMouseDownNormal` band, its input-decoration guard, and the matching `setCursorIconOnBorder` hover band | `processMouseDownNormal` measured the resize grab band outwards from the *client surface* (`m_realPosition`/`m_realSize`), so on a window carrying a reserved top decoration the band fell 18 px short of the visible top corners; and hyprbars cancels the event-bus button press for any point inside its own box (`hyprbars/barDeco.cpp:221`), which is why `extend_border_grab_area` provably could not reach through. The patch measures the band from `getWindowBoxUnified(RESERVED_EXTENTS)` — the idiom already used at `src/layout/LayoutManager.cpp:226` — and skips it over decorations flagged `DECORATION_ALLOWS_MOUSE_INPUT`, reusing the predicate `setCursorIconOnBorder` already applies, so the click band and hover cursor agree by construction. Upstream `hyprwm/hyprland-plugins#355` is open with no PR and no commit, and the causing code is unchanged on both `main` branches, so there is nothing to backport. Operator decision #19 (2026-07-28). |
| `modules/home/hyprland/patches/hyprbars-hover.patch` | `github.com/hyprwm/hyprland-plugins` | `v0.55.0` (`90e66baf`) | `hyprbars/` button hover state | Adds the button hover-highlight state the plugin does not implement. (Stage 2A) |

The chassis was vendored from the on-disk snapshot audited by the research corpus. The upstream remote `github.com/caelestia-dots/shell` is recorded for future diffs. A history graft was deliberately not performed so the audited bytes stay exact (PM decision, 2026-07-21).

| Source | Planning revision | Use |
|---|---|---|
| AlexbringsMercy/nix | `4974921` | Original host configuration and repository |
| NixOS/nixpkgs | `567a49d1913ce81ac6e9582e3553dd90a955875f` | Pinned package/system base |
| NixOS/nixos-hardware | `fccfa9031a85b78a437f2f153c1f6449f3bc3185` | Apple T2 module |
| nix-community/home-manager | `165228b0efefc3e635e5174020c40ea64271dc25` | User configuration |
| end-4/dots-hyprland | `c04b0bbc8143a2b2166c1f699f7583cb28ff78fe` | Hyprland Lua organization and motion |
| LinuxBeginnings/Hyprland-Dots | `bca86bb` | Waybar glass layout/style patterns |
| Frost-Phoenix/nixos-config | `66cc581645bef74898bd3eb36d9f4138d1069d02` | Nix/Home Manager wiring patterns |
| newmanls/rofi-themes-collection | `43ec2f5` | Launcher layout |
| cxOrz/dotfiles-hyprland | `0961d64cf73dd61b6e8aac9a2ba0070c52c1afa2` | QuickShell control/power/notification UI |
| ilyamiro/nixos-configuration | `d66c4a5915d2991d2e1cebe16f4c9b21f9fa0e6e` | Music/EQ, animation, palette, calendar/weather QML |
| quickshell-mirror/quickshell | `59e9c47b0eb48a9e4bcf9631fa062ee939bd2e83` / nixpkgs `0.3.0` | Native shell/service/IPC APIs |
| quickshell-mirror/quickshell-examples | `c6d1236efe265ae34e8c78a27ee9e196ea19d895` | Native mixer and service examples |
| AvengeMedia/DankMaterialShell | `fe1a783ec210071f6c71453e18479bfe3f2496d2` | Hardened service-lifecycle reference |
| caelestia-dots/shell | `172fdd3b662eeae94b32bac27d7fc669e6061e8f` | Popup motion/positioning reference |
| snowarch/iNiR | `01434067705d9dfce10709dbe680474dacc35261` | Glass edge/surface treatment reference |
| noctalia-dev/noctalia-shell | `3abfa1fc09b62dc4cdeeb7b787886f075696f0b7` | Eldritch palette and lifecycle reference |
| InioX/matugen | upstream research `4112d352914742ba69f6380fd07984adba02d376`; runtime nixpkgs `4.0.0` | Wallpaper-derived palette generation; templates use the pinned 4.0 syntax |
| LGFae/awww | nixpkgs `0.12.1` | Wallpaper transitions |
| anufrievroman/waypaper | `f2d2fa0` / nixpkgs `2.7-unstable-2026-01-13` | Mouse-driven wallpaper picker and post-command handoff |
| wwmm/easyeffects | tag `v8.2.0` (`469a51700aeb18bf2c1d7810de2846f898bdfd0a`) | Validated modern `equalizer#0` output-preset schema and service loading |
| karlstav/cava | nixpkgs `0.10.7` | On-demand 28-bar, 30 fps raw visualizer stream |
| Open-Meteo Forecast API | `https://api.open-meteo.com/v1/forecast` | HTTPS weather data normalized into a 15-minute offline cache |
| Alex's existing local wallpaper collection | twelve verified, machine-local copies; not tracked by Git | Palette-diverse Waypaper/Matugen test set and lock-screen backgrounds |

## QuickShell component adaptation notes

- `cxOrz/dotfiles-hyprland`: reviewed `modules/controlcenter/`
  (`ControlCenter`, `FeatureTile`, `WifiSection`, `BluetoothSection`,
  `BrightnessSection`, and `VolumeSection`), `modules/notifications/`,
  `modules/osd/VolumeOsd.qml`, `modules/powermenu/`, `modules/shelf/`,
  `shell.qml`, and `Theme.qml`. The build adapts its progressive control-card,
  notification-stack, power-confirmation, and transient-OSD interaction grammar
  to native QuickShell services and the Aurora palette; it does not copy its
  shell wholesale. Its persistent shelf role maps to the permanent Waybar
  launcher, pinned apps, tasks/workspaces, and status controls, while the
  progressive cards map to independent `PanelHost` dropdowns. This deliberately
  avoids a second dock without dropping any shelf function.
- `ilyamiro/nixos-configuration`: the shared motion tokens and `PanelHost`
  coordinate opacity, scale, and translation using the reference build's staged
  animation quality, but retain the requested independent-surface dashboard
  model rather than its unified morphing hub.
- `quickshell-mirror/quickshell` and `quickshell-examples`: validated the native
  notification, networking, BlueZ, PipeWire, UPower, power-profile, focus-grab,
  lazy-loader, and typed IPC contracts against the pinned QuickShell 0.3.0 API.
  Source inspection also established replacement-notification refresh behavior
  and freedesktop notification timeout units before those semantics were
  implemented locally.

Additional component-level sources are added here before their code is adapted.
