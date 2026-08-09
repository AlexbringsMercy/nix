# MacBook NixOS + Hyprland Build Plan

Document status: implementation deployed; Generation 10 default; acceptance and two lifecycle fixes pending
Machine: `macbook` — 2020 Intel/T2 MacBook Air
User: `alex`
Created: 2026-07-15
Last revised: 2026-07-16
Workspace: `/home/alex`
Intended configuration repository: `/home/alex/nix`
Remote: https://github.com/AlexbringsMercy/nix

## Instructions for future Codex sessions

Read this document completely before modifying the machine.

This file is the durable project handoff. Do not reconstruct the plan from chat history. Before acting:

1. Inspect the current Git and system state because execution may have progressed since this revision.
2. Read the latest `EXECUTION_LOG.md` in `/home/alex/nix` if it exists.
3. Preserve every invariant in “Non-negotiable hardware and system invariants.”
4. Continue from the first unfinished stage; do not redo completed or user-tested work.
5. Never add the proprietary firmware directory to Git.
6. Use Hyprland 0.55 native Lua. Do not revive legacy `hyprland.conf` or `hyprctl keyword` workflows.
7. Treat the user as hands-off except for unavoidable sudo authentication, reboot, and physical acceptance testing.
8. Use subagents for bounded audits, source analysis, testing, and review where parallel work improves quality.

## Project goal

Turn the existing barely functional NixOS/Hyprland installation into a polished, mouse-accessible daily desktop for a Windows-oriented user while retaining:

- reliable T2 boot and hardware support;
- macOS dual boot;
- working Broadcom Wi-Fi and Bluetooth firmware;
- Codex and Claude compatibility through `nix-ld`;
- a declarative, pinned, portable Nix configuration;
- a Waybar status bar backed by independent QuickShell dropdown panels from the first activation;
- wallpaper-adaptive theming and lock-screen polish;
- direct, inspected adaptation of proven community QML rather than disposable bridge components.

The result must be complete enough for daily use, not a screenshot-only rice.

## User interaction and design contract

- Everything required for ordinary desktop use must be accessible by mouse.
- Hotkeys are optional accelerators, not the sole path to core functionality.
- The top bar is the primary control surface.
- Keep one or two workspaces, not a grid of mostly unused workspaces.
- Tiling remains the default, with easy mouse resizing and familiar window controls.
- Use progressive disclosure: compact status elements expand into useful controls.
- Avoid deep menus, gratuitous widgets, permanent visualizers, and hidden terminal-only operations.
- Favor deep near-black blue-black, true black, deep purple, teal, seafoam, and dark green.
- Build depth with soft purple/teal/green aurora light bleeding through frosted glass and smooth gradient blooms.
- Use Raycast as the interaction-quality reference: precise spacing, crisp type, refined hover/press states, and confident motion.
- Avoid flat corporate navy, generic blue dark mode, warm palettes, neon-garish accents, anime assets, and template-like solid color blocks.
- Visual effects must be smooth but appropriate for a dual-core i3, 8 GB RAM, and battery operation.

## Interpretation of source reuse, licensing, and safety

The user’s priority is code quality, compatibility, and safety—not whether a personal dotfiles repository has a formal license.

Project policy:

- An absent license is not evidence that code is malicious or low quality.
- For this personal machine, useful code may be locally adapted after inspection even when the source has no declared license.
- Never execute a third-party installer wholesale. Inspect and extract only the needed files or patterns.
- Inspect shell commands, subprocess use, password handling, network calls, polling, absolute paths, destructive behavior, and version assumptions.
- Record provenance and planning snapshots in `SOURCES.md` so later maintenance can identify origins.
- Licensing becomes a separate publication/redistribution decision if copied source is pushed to a public repository. It is not a blocker for local implementation.
- Do not let wallpaper licensing constrain a local personal wallpaper library.

Wallpaper policy:

- Use only the user's existing image collection in `~/Downloads`; do not fetch,
  generate, or substitute another wallpaper set.
- Curate a deliberately varied first batch (red, light, green, blue, purple,
  neutral, and mixed palettes) so Matugen can be judged across genuinely
  different sources.
- Preserve every original and copy only the chosen subset into
  `~/Pictures/Wallpapers/aurora-collection/` with stable, simple filenames.
- Keep the personal wallpaper library out of the public Git repository.
- The repository manages wallpaper tooling, selection state, and Matugen
  integration; machine-local images remain ordinary user data.

## Additive implementation rule

Every stage must accumulate toward the final architecture.

- Do not install SwayNotificationCenter.
- Do not build a temporary control center that will later be replaced.
- Waybar remains the status bar in the final MacBook design.
- QuickShell owns the final dropdown, notification, OSD, music, and calendar/weather surfaces from day one.
- Basic panel contents may be enriched later, but their service model, IPC contract, and surface ownership must remain stable.
- Dunst may be retained as a lightweight supervised notification fallback, but it must never contend for the notification D-Bus name while the QuickShell server is healthy.

## Non-negotiable hardware and system invariants

These must survive every build and activation:

- Apple T2 hardware module and T2-patched kernel.
- Current working kernel family: `linux-t2`; planning audit observed `6.18.35`.
- Runtime drivers:
  - `apple_bce`
  - `aaudio`
  - `brcmfmac`
  - `hci_bcm4377`
  - `i915`
- systemd-boot.
- `boot.loader.efi.canTouchEfiVariables = false`.
- EFI mount at `/boot`.
- Existing root and boot filesystem UUIDs from `hardware-configuration.nix`.
- macOS dual boot remains untouched.
- Firmware source remains `/etc/nixos/firmware/brcm/`.
- Firmware derivation remains present in the activated closure.
- `nixpkgs.config.allowUnfree = true`.
- `programs.nix-ld.enable = true`.
- Hostname `macbook`.
- User `alex` with Fish as the login shell.
- User groups: `wheel`, `networkmanager`, `video`, and `input`.
- NetworkManager.
- PipeWire with ALSA and PulseAudio compatibility.
- `system.stateVersion = "26.11"`. Never raise this during ordinary upgrades.
- Current default browser remains Google Chrome unless the user later requests otherwise.
- `~/.npm-global/bin` remains on the user PATH so Codex and Claude continue to work.

## Audited current state

### NixOS

- Current NixOS version: `26.11.20260616.567a49d`.
- Exact nixpkgs revision: `567a49d1913ce81ac6e9582e3553dd90a955875f`.
- `/etc/nixos` is not currently a Git worktree.
- `/home/alex/nix` did not exist at planning time.
- The remote GitHub repository contained a single older `configuration.nix` and was not the live machine source of truth.
- The current T2 module is fetched from an unpinned `nixos-hardware/master` tarball.
- The existing channel-based configuration is working and must remain a recovery path until the flake generation survives reboot.
- `sudo` requires interactive authentication.

### Firmware

- `/etc/nixos/firmware/brcm/` contained 163 files totaling approximately 27.7 MB at audit time.
- Files were root-owned and readable.
- Do not print firmware contents.
- Do not commit `.bin`, `.ptb`, `clm_blob`, or `txcap_blob` files.

### Display and graphics

- Internal display: `eDP-1`.
- Native mode: `2560x1600@60`.
- Scale: `1.50`.
- Only one display is present.
- Intel Iris Plus is using `i915`.

### Input and battery

- Apple internal keyboard/trackpad is detected.
- Battery is exposed as `BAT0`.
- AC adapter is exposed as `ADP1`.
- Intel P-state is active.
- No swap or zram was enabled at audit time.

### Live Hyprland configuration

- Hyprland version at audit: `0.55.4`.
- `~/.config/hypr/hyprland.lua` is the live config.
- `~/.config/hypr/hyprland.conf` is ignored and is a drift hazard.
- `hyprctl configerrors` was empty.
- The live Lua config already enables:
  - natural scrolling;
  - tap-to-click;
  - tap-and-drag;
  - clickfinger behavior;
  - `disable_while_typing = true`.
- Three-finger workspace gestures are not configured.
- A stale startup command still calls `hyprctl keyword` for the background even though the same value is declarative.
- Chrome is incorrectly forced to float.
- Workspaces 1 through 9 are configured.
- Greetd launches the raw Hyprland binary as `default_session`.
- The current login is registered as a greeter-class session, which is unsuitable for polished lock/idle integration.

### Current desktop components

- Waybar, Rofi, Kitty, Chrome, Thunar, Fish, PipeWire, brightnessctl, grim, slurp, and wl-clipboard are present.
- Kitty already has:
  - FiraCode Nerd Font;
  - 0.90 opacity;
  - 10,000-line scrollback;
  - `Ctrl+C = copy_or_interrupt`;
  - `Ctrl+V = paste_from_clipboard`.
- Missing or incomplete:
  - notification daemon;
  - notification center;
  - wallpaper daemon;
  - Matugen;
  - lock and idle services;
  - BlueZ/Bluetooth UI;
  - media controls;
  - power-profile UI;
  - polkit agent;
  - proper Thunar volume/thumbnail integration;
  - cohesive GTK theming;
  - supervised user services;
  - QuickShell;
  - saved screenshot directory and save workflow.

## Source map

Commit IDs below are planning snapshots, not an instruction to update blindly.

### Destination and structure

#### AlexbringsMercy/nix

- URL: https://github.com/AlexbringsMercy/nix
- Planning snapshot: `4974921ba3d7d5602b3b2aa2513955f7ec0f770f`.
- Role:
  - destination repository;
  - eventual source of truth;
  - host modules, Home Manager modules, scripts, checks, and documentation.

#### Misterio77/nix-starter-configs

- URL: https://github.com/Misterio77/nix-starter-configs
- Planning snapshot: `fe4c4b136e0e073c71d8190a791ba03ccb47c5ac`.
- Pull:
  - `standard/flake.nix` structure;
  - `standard/nixos/configuration.nix` organization;
  - `standard/home-manager/home.nix` organization;
  - reusable module/overlay/check layout.
- Do not pull:
  - 25.11 pins;
  - unchanged example hostnames;
  - unnecessary multi-platform boilerplate.

### Nix platform

#### NixOS/nixpkgs

- URL: https://github.com/NixOS/nixpkgs
- Initial pin: `567a49d1913ce81ac6e9582e3553dd90a955875f`.
- Rationale: separate the desktop migration from a package-set upgrade.

#### NixOS/nixos-hardware

- URL: https://github.com/NixOS/nixos-hardware
- Pull:
  - `apple/t2` hardware module.
- Keep the same upstream family currently booting successfully.
- Pin it through the flake instead of fetching moving `master` at evaluation time.

#### nix-community/home-manager

- URL: https://github.com/nix-community/home-manager
- Pull:
  - integrated NixOS Home Manager module;
  - current Hyprland native Lua support;
  - `wayland.windowManager.hyprland.configType = "lua"`;
  - modular `extraLuaFiles`;
  - program and systemd-user-service modules.

### Desktop configuration sources

#### Frost-Phoenix/nixos-config

- URL: https://github.com/Frost-Phoenix/nixos-config
- Planning snapshot: `66cc581645bef74898bd3eb36d9f4138d1069d02`.
- Pull/adapt:
  - `modules/home/waybar/` decomposition;
  - `modules/home/rofi/`;
  - `modules/home/hyprland/hyprlock.nix`;
  - `modules/home/waypaper.nix`;
  - wallpaper/power-profile helper patterns.
- Reject:
  - its legacy Hyprlang configuration;
  - `disable_while_typing = false`;
  - hardware- and host-specific assumptions.

#### end-4/dots-hyprland

- URL: https://github.com/end-4/dots-hyprland
- Planning snapshot: `c04b0bbc8143a2b2166c1f699f7583cb28ff78fe`.
- Pull/adapt:
  - `dots/.config/hypr/hyprland.lua` loader pattern;
  - `hyprland/general.lua` expressive curves and animation organization;
  - `hyprland/keybinds.lua` mouse, media, brightness, and screenshot patterns;
  - `hyprland/rules.lua` Lua rule syntax;
  - touchpad DWT and natural-scroll settings.
- Strip:
  - QuickShell-only global binds;
  - large workspace set;
  - blur size 10 / 3 passes;
  - 18 px rounding;
  - constant or hidden-widget polling;
  - unnecessary AI, OCR, KDE, gaming, and desktop-specific features.

#### LinuxBeginnings/Hyprland-Dots

- URL: https://github.com/LinuxBeginnings/Hyprland-Dots
- Planning snapshot: `bca86bb`.
- Pull/adapt:
  - `config/waybar/configs/TOP-Default-Laptop-glass`;
  - `config/waybar/Modules`;
  - `ModulesCustom`;
  - `ModulesGroups`;
  - `ModulesWorkspaces`;
  - `style/Crystal-Clear-Glass.css`;
  - `style/Colorful-Aurora.css`;
  - Hyprlock layout ideas.
- Do not use its Hyprland config as the base because it remains legacy-first and contains `hyprctl keyword` calls.

#### newmanls/rofi-themes-collection

- URL: https://github.com/newmanls/rofi-themes-collection
- Planning snapshot: `43ec2f5`.
- Pull/adapt:
  - `themes/windows11-list-dark.rasi`.
- Changes:
  - replace gray/black constants with near-black glass and harmonized purple/teal/seafoam Matugen tokens;
  - preserve icons, mouse cursor support, search, and familiar layout;
  - use current `pkgs.rofi`, not removed `rofi-wayland`.

### Theming and wallpaper sources

#### InioX/matugen and matugen-themes

- URLs:
  - https://github.com/InioX/matugen
  - https://github.com/InioX/matugen-themes
- Matugen-themes planning snapshot: `901efeb1dfbcb436c327d581e176cc145654c990`.
- Pull/adapt:
  - `templates/colors.css`;
  - `templates/hyprland-colors.lua`;
  - `templates/rofi-colors.rasi`;
  - `templates/kitty-colors.conf`;
  - `templates/quickshell.qml` and JSON for immediate QuickShell use.
- Implement one orchestrating theme wrapper rather than racing per-template post-hooks.

#### LGFae/awww

- URL: https://codeberg.org/LGFae/awww
- Planning snapshot: `25ea4fd`.
- Role:
  - maintained replacement for archived `swww`;
  - smooth wallpaper transition daemon;
  - transition cap around 30 FPS for this laptop.

#### anufrievroman/waypaper

- URL: https://github.com/anufrievroman/waypaper
- Planning snapshot: `f2d2fa0`.
- Role:
  - mouse wallpaper browser;
  - invoke the Matugen theme wrapper after selection.

#### Wallpaper library

- Primary selection constraint: visual fit, not repository license.
- Candidate sources:
  - ilyamiro wallpaper collection;
  - community Hyprland wallpaper directories;
  - wallpaper sites and search results;
  - KDE Plasma wallpapers;
  - generated originals.
- Local directory: `~/Pictures/Wallpapers/`.
- Git behavior: ignored/untracked.

### QuickShell runtime and service model

#### quickshell-mirror/quickshell

- URL: https://github.com/quickshell-mirror/quickshell
- Runtime pin: nixpkgs QuickShell `0.3.0`.
- Use as the authoritative API contract for:
  - `Quickshell.Networking` and NetworkManager-backed Wi-Fi objects;
  - `Quickshell.Bluetooth`;
  - `Quickshell.Services.Pipewire`;
  - `Quickshell.Services.UPower`;
  - `Quickshell.Services.Mpris`;
  - `Quickshell.Services.Notifications`;
  - typed `IpcHandler` entrypoints for Waybar;
  - `HyprlandFocusGrab` for click-outside dismissal.
- Keep one supervised process and one shared service layer. Hidden panels stop animations and optional processing.

#### tripathiji1312/quickshell

- URL: https://github.com/tripathiji1312/quickshell
- Role: module/service/config separation and robust notification-owner configurability.
- Do not install its complete shell or pywal pipeline.

### Primary visual reference

#### ilyamiro/nixos-configuration

- URL: https://github.com/ilyamiro/nixos-configuration
- Planning snapshot: `d66c4a5915d2991d2e1cebe16f4c9b21f9fa0e6e`.
- It has no declared license at the planning snapshot. That does not make it malicious or unusable for this personal build.
- Do not run or install it wholesale. Its README itself says the current build needs NixOS adaptation.
- Directly adapt good and compatible QML after inspection; absence of a declared license is not a reason to discard useful code for this personal machine.
- Primary reference paths:
  - `config/sessions/hyprland/scripts/quickshell/Main.qml`;
  - `TopBar.qml`;
  - `music/MusicPopup.qml`;
  - `calendar/CalendarPopup.qml`;
  - `Lock.qml`;
  - `wallpaper/WallpaperPicker.qml`;
  - `config/programs/matugen/config.toml`.
- Pull/adapt directly:
  - `music/MusicPopup.qml` vinyl, track hierarchy, EQ controls, presets, and coordinated entrances;
  - `Main.qml`, `MusicPopup.qml`, and `CalendarPopup.qml` animation patterns;
  - `MatugenColors.qml` and the Matugen QuickShell template binding approach;
  - selected weather/calendar composition patterns.
- Preserve:
  - coordinated geometry/opacity/scale animation;
  - information-dense bar hierarchy;
  - semantic full-system recoloring;
  - cinematic lock composition;
  - internal widget choreography.
- Reject or rewrite:
  - single master hub/StackView architecture;
  - hard-coded usernames and author paths;
  - unsafe SSID/password interpolation;
  - plain-HTTP weather key handling;
  - obsolete `hyprctl keyword monitor`;
  - half-second `playerctl` polling;
  - global `/tmp` theme files;
  - school portal, Selenium, Firefox-profile, and Obsidian assumptions;
  - custom PAM lock until separately crash-tested.

### Primary QuickShell control implementation source

#### cxOrz/dotfiles-hyprland

- URL: https://github.com/cxOrz/dotfiles-hyprland
- Planning snapshot: `0961d64`.
- Pull/adapt from the first implementation stage:
  - `modules/controlcenter/ControlCenter.qml`;
  - `FeatureTile.qml`;
  - `WifiSection.qml`;
  - `BluetoothSection.qml`;
  - `VolumeSection.qml`;
  - `BrightnessSection.qml`;
  - notification, power, launcher, shelf, and OSD modules.
- Rewrite:
  - polling backends;
  - password-in-argv handling;
  - BAT0 hard-coding where a native service is available.
- Each section becomes an independent `PanelWindow` rather than one control-center hub.

### Selective robustness references

- AvengeMedia/DankMaterialShell: mature notification/network/Bluetooth/audio state handling patterns only.
- caelestia-dots/shell: popup positioning and shell-surface behavior only.
- noctalia-dev/noctalia-shell: low-cost animation, theming, and notification lifecycle patterns only.
- Do not install any of these complete shells or their companion daemons. Record exact paths and revisions in `SOURCES.md` only when code is actually adapted.

## Target repository architecture

```text
/home/alex/nix/
├── flake.nix
├── flake.lock
├── README.md
├── SOURCES.md
├── EXECUTION_LOG.md
├── hosts/
│   └── macbook/
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── nixos/
│   │   ├── t2.nix
│   │   ├── desktop.nix
│   │   ├── services.nix
│   │   └── laptop-power.nix
│   └── home/
│       ├── default.nix
│       ├── hyprland/
│       ├── waybar/
│       ├── quickshell/
│       ├── kitty/
│       ├── rofi/
│       ├── wallpaper/
│       ├── matugen/
│       ├── hyprlock/
│       ├── hypridle/
│       └── gtk/
├── scripts/
├── checks/
└── docs/
    ├── controls.md
    ├── recovery.md
    └── updating.md
```

Local, untracked machine adapter:

```text
/home/alex/.config/nixos-local/
├── flake.nix
└── flake.lock

/etc/nixos/firmware/brcm/
└── existing proprietary firmware
```

The public repo exports the MacBook host modules. The local adapter supplies `/etc/nixos/firmware` as a non-flake input. This keeps the public configuration portable and the firmware machine-local.

## Configuration architecture

### Flake

- Pin nixpkgs to the currently running revision for the first migration.
- Pin Home Manager and nixos-hardware.
- Integrate Home Manager into the NixOS configuration so one system activation manages both layers.
- Also expose a Home Manager build/check target for user-layer testing before root activation.
- Add formatter and checks.
- Do not add unrelated overlays without a concrete need.

### Hyprland

- Use Home Manager native Lua generation.
- Split Lua into:
  - environment;
  - monitor;
  - input and gestures;
  - appearance;
  - animations;
  - bindings;
  - window/layer/workspace rules;
  - startup/session integration.
- Keep only one live entrypoint: `hyprland.lua`.
- Back up and then remove/disable the ignored `hyprland.conf`.
- Use `hl.config`, `hl.bind`, `hl.gesture`, and Lua rule APIs.
- For live palette changes, regenerate a Lua fragment and run `hyprctl reload config-only`.
- Never depend on `hyprctl keyword`.

### Session lifecycle

- Replace greetd’s raw `default_session` auto-login with a proper `initial_session`.
- Launch `start-hyprland` rather than the raw compositor binary.
- Retain automatic first login for `alex`.
- Provide a normal greeter after logout.
- Import the Wayland environment into D-Bus and the user systemd manager.
- Tie desktop services to `graphical-session.target`.
- Supervise long-running desktop processes with systemd user services instead of unsupervised `exec-once` commands where practical.

### Firmware

- Preserve the existing derivation behavior.
- Pass the local firmware tree through the root-owned adapter.
- Confirm the firmware derivation appears in the new system closure.
- Add a Git check that fails if firmware extensions are tracked.

## Phase 0 — safety, repository, and migration foundation

### Actions

1. Clone the user repository into `/home/alex/nix`.
2. Fetch but do not overwrite remote state.
3. Create branch `codex/macbook-desktop`.
4. Record the starting remote commit.
5. Create a mode-0700 timestamped backup:
   - `/etc/nixos/configuration.nix`;
   - `/etc/nixos/hardware-configuration.nix`;
   - relevant `~/.config` directories;
   - no firmware duplication into Git;
   - no secret/token output.
6. Import the exact live hardware configuration into the repo.
7. Build the flake/module skeleton from the proven starter structure.
8. Create the local firmware adapter.
9. Add `SOURCES.md` and `EXECUTION_LOG.md`.
10. Add `.gitignore` entries for local wallpaper/state/generated files and firmware patterns.

### Phase 0 gates

- Remote history preserved.
- No unrelated user files modified.
- No firmware tracked.
- Flake evaluates.
- Current `/etc/nixos/configuration.nix` remains usable.
- Current systemd-boot generation remains present.

## Phase 1 — functional desktop

Phase 1 is the immediate “usable tonight” deliverable.

### NixOS system layer

Preserve all invariants, then add:

- Home Manager integration.
- BlueZ and Blueman.
- UPower.
- power-profiles-daemon.
- Hyprland polkit agent.
- GNOME keyring and greetd PAM integration.
- UDisks, GVfs, and Tumbler.
- required GTK and Hyprland portals.
- zram swap sized conservatively for 8 GB RAM.
- Inter UI font.
- Papirus icons.
- libnotify.
- QuickShell 0.3.0 and the complete `aurora-shell` configuration.
- Dunst package and a disabled/supervised fallback unit; never a second concurrently enabled notification owner.
- Hyprlock and Hypridle, configured additively from the first managed build and activated after the normal-session gate.
- current `rofi` package; do not use the removed `rofi-wayland` name.
- `awww`; do not use the renamed `swww` alias in new configuration.

### Greetd/session correction

- Use `initial_session` for automatic user login.
- Use `start-hyprland`.
- Retain a fallback greeter for logout.
- Confirm `loginctl show-session` reports a normal user session rather than `Class=greeter`.
- Do this before enabling idle locking.

### Hyprland behavior

- Monitor: `eDP-1, 2560x1600@60, 1.5`.
- Dwindle tiling by default.
- Remove the browser float rule.
- Persistent workspaces: 1 and 2 only.
- Smart gaps:
  - 4–5 px inside;
  - 5–8 px outside;
  - reduced gaps for a single tiled window if the result remains visually coherent.
- Border size: approximately 2 logical px.
- `resize_on_border = true`.
- Extended border grab area appropriate for Retina scaling.
- Snap behavior enabled.
- Rounded corners: 8–12 px.
- Moderate shadow.
- Native client titlebars retained.

### Touchpad

- `natural_scroll = true`.
- `tap-to-click = true`.
- `tap-and-drag = true`.
- `disable_while_typing = true`.
- `clickfinger_behavior = true`.
- two-finger/clickfinger right-click.
- tune scroll factor and sensitivity for the Apple trackpad.
- three-finger horizontal gesture switches between workspaces 1 and 2.
- do not allow gesture-driven creation of endless workspaces.

### Mouse-accessible window management

- Core applications retain native client-side titlebars and close/maximize controls.
- Dragging a client titlebar must request compositor movement normally.
- Window borders/corners resize by pointer.
- Waybar task buttons:
  - left click activates or minimizes/raises;
  - right click closes.
- Center active-window cluster includes visible pointer targets for:
  - floating/tiled toggle;
  - maximize/fullscreen;
  - close.
- Optional shortcuts remain available.

Do not enable `hyprbars` in the initial build. Current upstream issues affect double decorations, `resize_on_border`, XWayland pointer events, and button reliability. Reconsider only after an updated matched package is available and can be tested without compromising mouse resizing.

### Keybindings

Keep the list small and Windows-familiar:

- bare Super: toggle app launcher.
- Super+Return: terminal.
- Super+E: file manager.
- Super+B or Super+W: browser.
- Super+1 / Super+2: workspaces.
- Super+Shift+1 / Super+Shift+2: move active window.
- Super+Space: floating/tiled toggle.
- Super+F: maximize/fullscreen.
- Alt+F4 and optional Super+Q: close.
- Super+L: lock once Phase 2 is enabled.
- Super+Shift+S: region screenshot.
- Print: full-screen screenshot.
- Ctrl+Alt+Delete: power/session menu.
- Super+left mouse: optional move fallback.
- Super+right mouse: optional resize fallback.

### Function keys and OSD

- XF86 volume up/down/mute.
- XF86 microphone mute when present.
- XF86 brightness up/down.
- XF86 play/pause/next/previous.
- Use PipeWire/WirePlumber and `playerctl`.
- Use SwayOSD for visible feedback.
- Bind repeatable controls with the correct Lua flags.

### Screenshot workflow

Region screenshot:

1. Ensure `~/Pictures/Screenshots/` exists.
2. Let `slurp` select the region.
3. Cancel cleanly if selection is aborted.
4. Capture exactly once.
5. Save a timestamped PNG.
6. Copy that same PNG to the clipboard.
7. Notify success with the saved path.

Full-screen screenshot follows the same save-and-copy behavior.

### Chrome

- Tile by default.
- Native Wayland through the current Ozone environment.
- Default browser for HTTP, HTTPS, HTML, and common web MIME associations.
- Preserve native browser buttons and independent launches.
- Avoid a rule that floats all browser windows.

### Kitty

- FiraCode Nerd Font.
- Retina-appropriate font size.
- Background opacity around 0.88.
- Compositor blur behind transparency.
- 10,000-line scrollback.
- clickable tab bar.
- `Ctrl+C = copy_or_interrupt`.
- `Ctrl+V = paste_from_clipboard`.
- Matugen color fragment include.
- Keep remote-control exposure restricted to the minimum required for safe theme reloads.

### Rofi

- Clickable Waybar Apps button and bare Super both toggle it.
- `drun` applications with icons.
- search-as-you-type.
- Escape closes.
- click outside closes.
- familiar modern list/grid derived from the Windows 11 dark theme.
- blue-black/true-black glass with purple, teal, seafoam, and dark-green aurora styling.
- generated Matugen color import.
- no terminal-only app-launch requirement.

### QuickShell surfaces and notification ownership

- Run one supervised `aurora-shell` QuickShell process.
- Expose independent Wi-Fi, Bluetooth, audio, battery/power, notification, music, and calendar/weather surfaces.
- Each surface has its own `PanelWindow`/popup state, fixed Waybar anchor, internal compact/expanded transitions, and `HyprlandFocusGrab` outside-click dismissal.
- Waybar invokes typed IPC calls; no shell interpolation of SSIDs or passwords.
- QuickShell is the sole notification D-Bus owner while healthy.
- Notification cards appear top-right, expire correctly using `expireTimeout`, retain critical items, support click dismissal and advertised action buttons, and feed a history/DND panel.
- On first-start notification-server failure only, a watchdog may start Dunst and keep the rest of QuickShell running. Dunst exits before QuickShell retries notification ownership.
- Volume uses native PipeWire, Bluetooth uses the native Bluetooth service, Wi-Fi uses native Networking, battery uses UPower, and media uses MPRIS.
- Hidden panels perform no recurring polling and stop optional animations/Cava processing.

### Waybar layout

Target logical width is approximately 1707 px, so every module needs bounded width and sensible truncation.

#### Left

- Apps button.
- Chrome quick launch.
- Kitty quick launch.
- Thunar quick launch.

#### Center

- Workspace 1 and 2 buttons.
- task buttons.
- truncated active window title.
- floating/maximize/close pointer controls.

#### Right

- media title.
- previous/play-pause/next.
- CPU.
- RAM.
- volume.
- Wi-Fi.
- Bluetooth.
- battery/power.
- clock/calendar.
- system tray.
- notifications.

#### Click map

| Element | Primary click | Secondary action |
|---|---|---|
| Apps | Toggle Rofi | — |
| Chrome/Kitty/Files | Launch app | — |
| Workspace | Activate | — |
| Task | Activate/minimize-raise | Close |
| Active-window X | Close active | — |
| CPU/RAM | Open Mission Center | Optional tooltip details |
| Media buttons | Player control | — |
| Volume | Toggle QuickShell volume panel | Open PwVuControl |
| Wi-Fi | Toggle QuickShell network panel | Connection editor |
| Bluetooth | Toggle QuickShell Bluetooth panel | Blueman manager |
| Battery/power | Toggle QuickShell power panel | Wlogout fallback |
| Clock | Toggle QuickShell calendar/weather | Calendar tooltip |
| Notification | Toggle QuickShell history | Toggle DND |

### Phase 1 visual baseline

- Near-black aurora-gradient fallback palette with violet shadow, teal/seafoam highlights, and true-black glass.
- One selected local atmospheric wallpaper through `awww`.
- Semi-transparent Waybar.
- Hyprland layer blur for Waybar, QuickShell surfaces, and Rofi where supported.
- Moderate animation curves.
- 30 FPS cap for wallpaper transitions.
- System metric intervals around 3–5 seconds.
- Cava is on-demand and only runs while the visible music panel needs it.
- No animated wallpaper.
- One supervised QuickShell process; hidden windows disable rendering updates and optional work.

## Phase 1 verification

### Static and build checks

```bash
nix flake check /home/alex/nix

out=$(nix build --no-link --print-out-paths \
  /home/alex/.config/nixos-local#nixosConfigurations.macbook.config.system.build.toplevel)

nix-store -q --requisites "$out" |
  rg 'linux-t2|brcm-firmware|hyprland|nix-ld'
```

Also:

- format Nix files;
- lint shell scripts;
- validate Waybar JSON;
- validate Rofi theme loading;
- inspect Home Manager activation output;
- compare current and new closures;
- scan Git for firmware extensions and likely secrets.

### Activation strategy

1. Build user-layer configuration without activation.
2. Back up live dotfiles.
3. Activate/reload the user layer while the current generation remains booted.
4. Check `hyprctl configerrors` immediately.
5. Restore the previous user config if the Lua reload fails.
6. Run root dry activation.
7. Obtain one sudo authentication.
8. Install the first system migration as a boot generation to avoid restarting greetd under the active desktop.
9. Reboot only after all pre-reboot gates pass.

### Post-activation automated checks

```bash
hyprctl configerrors
hyprctl getoption input:touchpad:disable_while_typing
hyprctl getoption input:touchpad:natural_scroll
hyprctl getoption general:resize_on_border
hyprctl monitors all

systemctl --user --no-pager --full status \
  waybar.service aurora-shell.service awww.service swayosd.service

systemctl is-active \
  NetworkManager bluetooth power-profiles-daemon

command -v playerctl bluetoothctl hyprlock matugen notify-send awww
xdg-settings get default-web-browser
codex --version
claude --version
```

### Post-reboot hardware checks

```bash
readlink -f /run/current-system/kernel | rg 'linux-t2'
lsmod | rg 'apple_bce|aaudio|brcmfmac|hci_bcm4377|i915'
lspci -nnk | rg -A3 'VGA|Network controller|T2 Bridge'
brightnessctl g
wpctl get-volume @DEFAULT_AUDIO_SINK@
test -d ~/Pictures/Screenshots
hyprctl configerrors
```

### Firmware privacy/integrity check

```bash
git -C /home/alex/nix ls-files |
  rg 'firmware/brcm|\.bin$|\.ptb$|clm_blob|txcap_blob' &&
  echo 'FAIL: firmware tracked' || true
```

Confirm the activated closure contains a non-empty `brcm` firmware directory without printing firmware contents.

### Manual acceptance checklist

- Type continuously while resting a palm on the trackpad; the pointer must not jump.
- Test clickfinger/two-finger right click.
- Test three-finger workspace swipe in both directions.
- Click every Waybar element.
- Launch all three pinned apps.
- Verify bare Super opens and closes Rofi.
- Tile multiple Chrome, Kitty, and Thunar windows.
- Drag native titlebars.
- Resize from every window edge/corner.
- Test Waybar close/maximize/float controls.
- Test all volume, brightness, and media keys.
- Confirm OSD feedback.
- Take a region screenshot and verify both clipboard and saved file.
- Take a full-screen screenshot and verify both outputs.
- Send an actionable notification and activate its action.
- Connect/disconnect Wi-Fi through the pointer UI.
- Pair or inspect a Bluetooth device.
- Confirm battery percentage/status changes.
- Confirm Codex and Claude still launch.

## Phase 2 — polish, Matugen, wallpaper management, and lock screen

Start only after Phase 1 survives reboot and passes the functional acceptance checklist.

### Wallpaper workflow

- Create `~/Pictures/Wallpapers/`.
- Curate the first palette-diverse set from the user's existing `~/Downloads`
  images and copy it into `~/Pictures/Wallpapers/aurora-collection/` without
  modifying the originals.
- Do not commit the personal wallpaper library.
- Configure Waypaper for pointer selection.
- Configure `awww` transitions:
  - approximately 0.8–1.0 seconds;
  - approximately 30 FPS;
  - static final wallpaper with no continuous animation.

### Atomic theme pipeline

Create one `apply-wallpaper` command:

1. Validate and canonicalize the selected path.
2. Acquire a lock so two theme changes cannot race.
3. Apply the wallpaper through `awww`.
4. Run Matugen in dark mode.
5. Write generated files atomically under `$XDG_CACHE_HOME/matugen/`.
6. Generate:
   - semantic CSS colors;
   - Hyprland Lua colors;
   - Kitty colors;
   - Rofi colors;
   - QuickShell semantic palette singleton/data;
   - Wlogout colors;
   - Hyprlock colors;
   - GTK colors;
   - Dunst fallback colors.
7. Reload:
   - Waybar;
   - QuickShell palette through an atomic watched file;
   - Kitty colors;
   - Hyprland config-only;
   - other safe consumers.
8. Persist the current wallpaper path.
9. Notify success or a clear failure.

Avoid:

- global `/tmp` palette files;
- one-second palette polling;
- multiple independent post-hooks;
- flat corporate navy or warm palette drift where harmonization can retain the black/purple/teal/seafoam aurora direction.

### Glass and animations

Initial performance-conscious targets:

- blur size around 4–7;
- two passes;
- low noise;
- restrained vibrancy;
- Waybar/panel alpha around 0.72–0.88 depending on readability;
- window rounding 8–12;
- routine UI motion 160–250 ms;
- window open/close around 180–280 ms;
- workspace slide around 250–350 ms;
- longer 700–1200 ms choreography only for cinematic lock or large expanded-widget entrances.

Measure idle CPU/GPU behavior and battery impact before raising blur cost.

### Hyprlock

Deliver:

- current wallpaper background;
- generated blurred/vignette lock image or native blur where adequate;
- large clock;
- date;
- user avatar placeholder that can later be replaced;
- username;
- password/PIN field;
- Caps Lock warning;
- battery percentage/status;
- Wi-Fi/SSID status;
- coherent Matugen colors.

Do not use ilyamiro’s custom PAM-backed QuickShell lock in Phase 2. Hyprlock is the crash-safe initial implementation.

### Hypridle

Configure:

- lock before suspend;
- display dim;
- lock timeout;
- display power-off timeout;
- resume DPMS;
- lid suspend behavior;
- conservative battery-friendly defaults;
- no lock/idle activation until the session is confirmed as a normal user session.

Exact timeouts may be tuned after user testing, but initial targets should be reasonable rather than aggressive.

### Phase 2 acceptance

- Change wallpaper entirely with the pointer.
- Confirm transition completes smoothly.
- Confirm Waybar, Rofi, Kitty, every QuickShell surface, Hyprland borders, lock screen, and GTK recolor.
- Confirm no consumer is left with stale colors.
- Confirm concurrent wallpaper changes cannot corrupt output.
- Lock and unlock repeatedly.
- Suspend/resume through lid and power menu.
- Confirm Wi-Fi returns after resume.
- Confirm lock screen reports battery and network correctly.
- Check idle CPU and memory use.
- Check no orphaned Matugen, playerctl, or wallpaper processes remain.

## Phase 3 — advanced QuickShell contents and refinement

The independent surfaces and their final service/IPC architecture are part of the first activation. This stage enriches those same components; it does not introduce or replace a shell.

### Architecture

- Retain Waybar as the permanent status bar and QuickShell as its permanent surface layer.
- Use one shared state/service layer.
- Use multiple independent `PanelWindow` surfaces:
  - network;
  - Bluetooth;
  - audio;
  - power;
  - display;
  - music/EQ;
  - weather/calendar;
  - notifications;
  - wallpaper picker.
- Each panel:
  - has its own position;
  - has its own visibility state;
  - is opened by a clickable status icon;
  - dismisses on outside click or repeat click;
  - can morph internally between compact and expanded states.
- Do not morph between unrelated widget types.
- A small coordinator may dismiss other panels, but it must not become a master hub.

### Backends

- Prefer native QuickShell services:
  - PipeWire;
  - UPower;
  - Bluetooth;
  - Networking;
  - MPRIS;
  - Hyprland;
  - notification APIs.
- Avoid constant shell polling.
- Never put Wi-Fi passwords in process arguments.
- Stop timers, waveforms, and animations when a panel is hidden.

### Music panel

- Album art/vinyl presentation.
- Track metadata.
- previous/play-pause/next.
- volume and device selection.
- EQ presets.
- real Cava data only when visible and playing.
- throttle rendering for the MacBook.
- EasyEffects integration only after preset changes can be applied and rolled back safely.

### Weather/calendar

- HTTPS provider such as Open-Meteo.
- location configured explicitly or with user-controlled geolocation.
- cache results.
- no embedded keys.
- optional ICS/CalDAV later.
- no author-specific school portal or Obsidian assumptions.

### Notifications hardening

- Exercise notification actions, history, DND, replacement IDs, resident/critical behavior, and expiry semantics.
- Validate QuickShell ownership before enabling the Dunst failure fallback.
- Never start both notification owners concurrently.

## Phase 4 — Alienware port

Future separate host:

- reuse shared home modules and semantic theming;
- add Alienware host module;
- NVIDIA legacy 470-series constraints;
- dual-monitor layout;
- 27-inch primary workspace display;
- laptop display as persistent dashboard;
- enable persistent QuickShell widgets only on the laptop panel;
- keep MacBook-specific T2 and firmware logic isolated to `hosts/macbook`.

## Rollback strategy

### Before activation

- Git feature branch.
- timestamped local backup.
- current `/etc/nixos` untouched.
- old Home Manager/dotfile state recoverable.

### If user-layer activation fails

- restore the timestamped `~/.config` backup;
- reload the previous Lua config;
- restart only affected user services;
- do not proceed to root activation.

### If the system build fails

- current running generation is unchanged;
- repair in the feature branch;
- rerun checks.

### If the new boot fails

- choose the previous NixOS generation in systemd-boot;
- restore the channel configuration if needed;
- do not alter macOS partitions or EFI variables.

### Known-good configuration

Keep `/etc/nixos/configuration.nix` and the current system generation until:

1. the flake build succeeds;
2. the new generation boots;
3. T2 modules load;
4. Wi-Fi works;
5. the user completes Phase 1 acceptance;
6. at least one rollback path has been demonstrated/documented.

## Definition of done

### Phase 1 complete

- Boot and T2 hardware are intact.
- Wi-Fi, Bluetooth, audio, brightness, battery, trackpad, and suspend basics work.
- Codex and Claude still run.
- The desktop is declarative and pinned.
- Bare Super and the Apps button launch applications.
- Core desktop operations are mouse accessible.
- Only two workspaces are presented.
- Waybar is coherent, clickable, and supervised.
- Media/function keys work with OSD.
- Screenshots save and copy.
- Notifications and action buttons work.
- Chrome tiles and remains the default browser.
- Recovery documentation exists.

### Phase 2 complete

- Wallpaper selection is pointer driven.
- Wallpaper changes recolor the full desktop atomically.
- Glass and animation polish is coherent without unacceptable idle load.
- Hyprlock and Hypridle are reliable.
- Lock, lid suspend, resume, and Wi-Fi recovery pass.
- No stale or duplicated daemons remain.

### Project handoff complete

- `README.md` explains installation and routine updates.
- `SOURCES.md` records origins and important adaptations.
- `EXECUTION_LOG.md` records completed stages, test outcomes, and current blockers.
- `docs/controls.md` documents pointer actions and optional shortcuts.
- `docs/recovery.md` contains exact rollback steps.
- Git history is clean and logically staged.
- The public repo contains no proprietary firmware, credentials, personal wallpaper images, or generated cache files.

## Execution status

At this revision:

- Read-only machine audit: complete.
- Primary-reference audit: complete.
- Community-source audit: complete.
- Source and architecture plan: complete.
- Durable plan file: complete.
- Architecture amendments approved: QuickShell from day one, direct ilyamiro/cxOrz adaptation, additive stages, and corrected aurora-glass palette.
- Execution branch: `codex/macbook-desktop` from remote commit `4974921ba3d7d5602b3b2aa2513955f7ec0f770f`.
- Pre-migration backup: `/home/alex/.local/state/codex-backups/macbook-desktop-20260715-234753`.
- Phase 0 implementation: complete and validated.
- Pinned flake and machine-local firmware adapter: complete; both portable and
  firmware-backed evaluations pass.
- Phase 1 QuickShell/Waybar/Hyprland implementation: complete and validated in
  isolated/static tests.
- Phase 2/3 permanent-component enrichment: complete for this MacBook build,
  including adaptive colors, lock/idle, music/EQ/Cava, weather/calendar, and all
  independent control surfaces.
- Curated wallpaper set: twelve verified copies selected solely from Alex's
  Downloads collection and kept outside Git.
- Full T2 system closure: builds successfully with linux-t2 6.18.35, 163 local
  Broadcom firmware files, QuickShell, and `nix-ld` present.
- First reboot and live Home Manager activation: performed. Generation 9 is the
  currently booted system; corrected Generation 10 is installed as the next-boot
  default, and the matching Home Manager configuration is already live.
- Retina scaling correction: complete and live at 2560x1600, scale 1.5,
  1707x1067 logical. The right/bottom dead bands were fixed by restoring
  `debug.disable_scale_checks = true`.
- Remaining implementation defects: detach Waybar-launched apps from the
  Waybar service cgroup and move generated EasyEffects presets from the legacy
  config path to the XDG data path. See the final section of `EXECUTION_LOG.md`.
- Physical/operator acceptance: in progress; the complete checklist has not yet
  been returned.
- Phase 4 Alienware port: future separate project.

The next actions are the two isolated lifecycle fixes recorded in
`EXECUTION_LOG.md`, a full preflight and corrected boot-generation install, then
coordinated physical acceptance. Do not restart Waybar while important apps
launched from it are open until launch isolation has been fixed.
