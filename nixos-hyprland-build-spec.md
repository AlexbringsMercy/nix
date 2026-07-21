# NixOS + Hyprland Build Spec

## Overview

Full desktop migration from Windows 10 (Alienware 14) to NixOS with Hyprland.
Declarative system config, custom QuickShell widgets, dual-monitor dashboard layout.

Reference build: [u/ilyamiro's NixOS config](https://github.com/ilyamiro/nixos-configuration) — fork and customize, don't build from scratch.

---

## Decisions Locked

| Component | Choice | Rationale |
|-----------|--------|-----------|
| **Distro** | NixOS (flakes + Home Manager) | Declarative, atomic rollbacks, reproducibility, repo-based system backup. Best community rices are NixOS-based. AI assistance mitigates Nix learning curve. |
| **Window Manager** | Hyprland (Wayland) | Tiling compositor, smooth animations, maximum ricing potential. Every reference screenshot gravitates here. |
| **Widget Framework** | QuickShell (QML) — primary | Highest animation ceiling. QML built for fluid reactive UI. Reference build (ilyamiro) uses it. Can mix AGS/EWW widgets if a pre-built community widget uses those. |
| **Shell** | Fish (interactive) / Bash (scripts) | Fish: autosuggestions, syntax highlighting, zero config. Bash: POSIX-compatible for scripts. |
| **Terminal** | Kitty | GPU-accelerated, configurable, standard in Hyprland community. |
| **Color Theming** | Matugen (Material You) | Auto-extracts harmonized accent palette from wallpaper. All widgets bind to generated theme values. No manual hex picking. |
| **Status Bar** | Custom QuickShell bar or Waybar | Top bar with workspace indicators, media controls, weather/time, system tray. Clickable icons trigger dropdown panels. |
| **App Launcher** | Rofi (themed) | Keybind-triggered (Super key), searchable, CSS-styled to match theme. |
| **Lock Screen** | Custom QuickShell (reference: ilyamiro) | Blurred wallpaper vignette, clock, profile avatar, PIN entry. Cinematic depth-of-field effect. |
| **Wallpaper** | Swww or Hyprpaper + custom picker | Carousel-style wallpaper selector with Matugen integration for auto-theming. |
| **Notifications** | Dunst or Mako | Themed to match palette. |
| **File Manager** | Thunar or Dolphin | Themed to match palette. May build custom file explorer later. |
| **Editor** | VS Code initially, Neovim exploration later | VS Code for familiarity. Neovim (LazyVim/AstroNvim) as optional migration for deeper terminal integration. |

---

## Visual Design Direction

**Palette:** Deep navy / teal / aurora borealis gradient tones. Dark base, luminous accents. NOT the green/nature palette from ilyamiro — swap to cool dark blues and cyans.

**Effects:** Glassmorphism on panels and widgets (frosted glass, transparency, blur). Smooth property animations on all state transitions. Reactive/interactive elements over minimalism.

**Typography:** Clean monospace for terminal (FiraCode Nerd Font or similar). Sans-serif for widget UI text.

**Philosophy:** Everything accessible without memorizing keybinds. Click-friendly UI with cursor interaction as the default. Keybinds optional/supplementary, not required. Progressive disclosure — compact states expand on interaction. No deep panel nesting for basic controls.

---

## Widget Architecture (Dashboard Model)

**Differs from ilyamiro's hub model.** Independent QuickShell PanelWindow surfaces per widget, not one unified morphing container. Internal morphing transitions within individual widgets (compact ↔ expanded states). Widgets can coexist with different frameworks if pre-built community widgets use AGS/EWW.

### Top Status Bar (both monitors)
- Workspace indicators (clickable)
- Media: current track, play/pause/skip, slim visualizer
- Clock / date / weather summary
- System tray: WiFi, Bluetooth, battery, volume — each clickable to toggle dropdown panel
- Notification bell

### Dropdown Panels (main monitor, on-demand)
Triggered by clicking corresponding status bar icon. Anchored below icon. Dismiss by clicking elsewhere or same icon.

- **Network Panel:** WiFi connection info (SSID, IP, signal, security), available networks list
- **Bluetooth Panel:** Connected devices, battery, scan. Orbital layout (reference: ilyamiro) or simplified list — TBD
- **System/Power Panel:** Battery gauge, brightness slider, volume slider, power profile (Performance/Balanced/Saver), lock/sleep/reboot/shutdown buttons
- **Display Panel:** Resolution picker, refresh rate slider, monitor layout
- **Screen Time / Analytics Panel:** Per-app usage stats, daily/weekly charts — nice to have, lower priority

### Persistent Widgets (laptop screen — dashboard mode)

**Layout approach (decide during build):**
- **Option A:** Full dashboard workspace on laptop screen (workspace 1 = widgets only, workspace 2 = tiled window). One keybind to swap.
- **Option B:** Reserved dashboard strip (top ~200-250px) on laptop screen, tiled windows fill remaining space below.
- **Option C:** Full dashboard always visible, only use main monitor for windows.

Test all three during build, commit to whichever feels right.

**Persistent widget candidates:**
- Music player: album art, track info, playback controls, audio visualizer (cava integration), EQ controls (expandable)
- Clock / calendar / weather (detailed view with hourly forecast)
- System stats: CPU, RAM, temps, processes
- Dev workflow launcher: quick-launch buttons for Claude Code, Codex invocation commands with preset permissions

### Custom Dev Widget (future build)
A QuickShell panel for dev workflow:
- Launch Claude Code session (with --dangerously-skip-permissions or configured perms)
- Launch Codex session
- Show active agent sessions and their status
- Quick terminal spawn with preset working directories
- Git status summary for active repos

---

## Dual Monitor Layout

**Monitor 1 — Alienware AW2723DF (27", 1440p, 240Hz via DP):** Primary work screen. Full tiling workspace. Top status bar with dropdown panels. Workspaces: 1 = primary work, 2 = debug/admin (htop, logs, admin terminal).

**Monitor 2 — Alienware 14 laptop screen (14", 1080p):** Dashboard / secondary. Persistent widgets or secondary tiling area depending on chosen layout option. Workspaces: 5 = dashboard, 6 = secondary window (if using workspace-swap approach).

Hyprland config binds specific workspace numbers to specific monitors. Workspaces don't float between screens.

---

## System Configuration (NixOS)

### Nix Flake Repo Structure
```
nixos-config/
├── flake.nix                  # Entry point
├── flake.lock                 # Pinned dependencies
├── hosts/
│   └── alienware/
│       ├── default.nix        # Machine-specific config
│       └── hardware.nix       # Hardware detection
├── modules/
│   ├── hyprland.nix           # WM config, keybinds, rules
│   ├── waybar.nix             # Status bar (if using Waybar)
│   ├── kitty.nix              # Terminal config
│   ├── fish.nix               # Shell config
│   ├── audio.nix              # PipeWire setup
│   ├── nvidia.nix             # Legacy 470.xx driver config
│   ├── bluetooth.nix          # BT config
│   ├── networking.nix         # WiFi, firewall
│   └── packages.nix           # System-wide packages
├── home/
│   ├── default.nix            # Home Manager entry
│   ├── shell/                 # Fish config, aliases, env
│   ├── editor/                # VS Code / Neovim config
│   └── gtk.nix                # GTK theme for Firefox, etc.
├── quickshell/                # Widget source code
│   ├── bar/                   # Status bar QML
│   ├── panels/                # Dropdown panel QML
│   ├── widgets/               # Persistent widget QML
│   ├── lockscreen/            # Lock screen QML
│   ├── launcher/              # App launcher QML
│   └── themes/                # Matugen integration
└── wallpapers/                # Curated wallpaper collection
```

### Hardware-Specific Notes (Alienware 14)
- **GPU:** NVIDIA GT 750M (Kepler) — legacy 470.xx proprietary driver. Nouveau as fallback. No Vulkan ray tracing. Fine for desktop compositing and video.
- **CPU:** Intel i7-4700MQ (Haswell, 4th gen). No TPM 2.0. This is why Windows 11 won't install.
- **RAM:** 8GB — Linux idles at ~500MB-1GB vs Windows 10's ~3GB. Major practical improvement.
- **WiFi:** Intel chipset (excellent Linux support, kernel drivers included).
- **Battery:** Dead (AC only). Sleep/hibernate config unnecessary.
- **Display:** 1080p laptop panel + 1440p external via DisplayPort.

### Kernel Optimization (CachyOS-style)
Consider custom kernel compilation later for responsiveness on this older hardware. NixOS supports custom kernel configs declaratively. Not a day-one priority but worth revisiting once the base system is stable.

---

## Migration Plan

### Phase 1: Live USB Test
- Download NixOS minimal ISO
- Flash to USB drive (using Rufus on Windows or Ventoy for multi-ISO)
- Boot from USB on Alienware
- Verify: display output, WiFi, Bluetooth, dual-monitor detection
- Get a feel for the terminal and Nix basics

### Phase 2: Base Install
- Partition drive (keep Windows dual-boot option initially or full wipe — decide at install time)
- Install NixOS with flakes enabled
- Configure hardware module (NVIDIA legacy driver, Intel WiFi)
- Set up user account, Fish shell, Kitty terminal
- Verify: boots cleanly, networking works, audio works (PipeWire), both monitors detected

### Phase 3: Hyprland + Basics
- Install and configure Hyprland
- Set up basic keybinds (terminal, launcher, close window, workspace switching)
- Install Rofi for app launcher
- Install and configure Waybar or QuickShell bar (basic version first)
- Install browser (Firefox or Chrome), VS Code, basic apps
- Verify: tiling works on both monitors, app launching works, basic workflow functional

### Phase 4: QuickShell + Theming
- Fork ilyamiro's nixos-configuration repo
- Study QuickShell QML code structure
- Set up Matugen color generation
- Build or adapt status bar with clickable panel triggers
- Build dropdown panels (system, network, Bluetooth)
- Apply aurora/glassmorphic theme across all components
- Build lock screen

### Phase 5: Dashboard + Polish
- Build persistent widgets for laptop screen (music, clock, system stats)
- Build dev workflow launcher widget
- Configure wallpaper picker with Matugen integration
- Fine-tune animations, blur levels, transparency
- Add custom Rofi theme
- Configure per-app window rules in Hyprland

### Phase 6: Ecosystem Integration
- Configure NAS mount points (NFS to future Unraid NAS)
- Configure SSH for remote LLM inference box (future)
- Set up Git repo for dotfiles/flake, push to GitHub
- Windows VM setup (KVM/QEMU) for RGB software and occasional Windows testing
- Install Steam + Proton for gaming

---

## Apps to Install

### Development
- VS Code, Neovim (optional)
- Git, GitHub CLI
- Claude Code, Codex CLI
- Python 3.x, pip, venv
- Node.js, npm
- Rust toolchain (rustup, cargo) — for Tauri/Mercy dev
- Docker

### Browsers & Communication
- Firefox or Chrome/Chromium
- Discord
- Telegram (if used)

### Media & Audio
- Spotify (or self-hosted music with EQ — future project)
- mpv (video player)
- PipeWire (system audio)
- cava (audio visualizer, feeds into QuickShell widgets)
- Audacity

### System & Utilities
- htop / btop (process monitor)
- fastfetch (system info display)
- thunar or dolphin (file manager)
- grim + slurp (screenshot tools for Wayland)
- wl-clipboard (clipboard manager)
- NetworkManager (WiFi management)
- bluez (Bluetooth)

### Gaming
- Steam (native)
- Proton / Proton-GE (Windows game compatibility)

---

## Open Questions (Decide During Build)
- Laptop screen layout: full dashboard workspace vs reserved strip vs always-visible?
- Waybar vs full QuickShell bar? (QuickShell gives more animation control but more work)
- Exact Rofi layout and theming
- Which community widgets to use as-is vs build custom
- Dual-boot Windows or full wipe? (Can set up Windows VM later either way)
- Neovim migration timing — during initial build or later project?
