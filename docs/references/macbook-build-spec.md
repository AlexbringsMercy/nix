# NixOS + Hyprland Build Spec — MacBook Air 2020

## Machine
- 2020 MacBook Air Retina 13-inch
- Intel Core i3 1.1GHz dual-core, Intel Iris Plus GPU
- 8GB LPDDR4X RAM, 250GB SSD (120GB macOS / 121GB NixOS dual-boot)
- 2560x1600 Retina display (run at 1.5x fractional scaling)
- T2 security chip — uses t2linux kernel patches, Broadcom WiFi firmware extracted from macOS
- Apple keyboard layout (Command key = Super in Linux)
- Single monitor only (no external display on this machine for now)

## Current State
- NixOS 26.11 installed, Hyprland launches, Chrome works, Codex and Claude Code installed
- WiFi working via Broadcom firmware in /etc/nixos/firmware/brcm
- Fish shell set as default
- Desktop is barely functional — needs full configuration from community dotfiles
- Existing /etc/nixos/configuration.nix has T2 imports and firmware derivation that MUST be preserved

## Design Philosophy

### Interaction Model
- EVERYTHING must be accessible via mouse/cursor clicks. Hotkeys exist as optional shortcuts but are never the ONLY way to do something.
- The user's stance: "it's the user's choice whether they want to use a button or remember a hotkey — that's how all OS's should be"
- No memorizing a dozen hotkeys to do basic things. Clickable buttons, taskbar icons, and visual controls for all common actions.
- Progressive disclosure: compact elements expand on interaction. No deep panel nesting for basic controls.
- This is NOT a keyboard-warrior minimal rice. It's a functional, beautiful desktop that happens to also have hotkeys.

### Visual Design Direction
- **Palette:** Deep navy / teal / aurora borealis gradient tones. Dark base with luminous accents. Cool dark blues and cyans. NOT black, NOT green/nature.
- **Effects:** Glassmorphism on panels and widgets (frosted glass, transparency, blur). Smooth property animations on ALL state transitions. Reactive/interactive elements.
- **Typography:** FiraCode Nerd Font for terminal. Clean sans-serif for UI text.
- **Animations:** Smooth bezier curves on window open/close/move/resize. Workspace transitions should feel fluid. Reference: ilyamiro's QuickShell build had buttery smooth morphing transitions — that level of polish is the target, not the janky defaults.
- **Consistency:** Every component (bar, launcher, terminal, notifications, lock screen) should share the same color scheme. Matugen (Material You color generation) auto-extracts palette from wallpaper and applies everywhere.

### What the User Likes (from reviewing community screenshots and videos)
- Dark atmospheric desktops with rich color accents (not neon-garish)
- Functional status bars packed with useful telemetry (CPU, RAM, network, volume, battery, clock, media)
- Music player integration visible on desktop — album art, playback controls, visualizer
- Weather and clock widgets always accessible
- Tiling that auto-organizes workspaces but with easy mouse override
- Glass/blur effects on panels and terminal backgrounds
- System dashboards for quick access to WiFi, Bluetooth, power, display settings
- Beautiful lock screens with blurred wallpaper vignette effect

### What the User Dislikes
- Having to memorize hotkeys for basic operations
- Minimalist setups where you can't see or access anything without keyboard shortcuts
- Workspaces where you flip between 8 different pages constantly
- Panels buried layers deep (like macOS hiding settings behind terminal commands)
- Generic black-on-black themes with no personality
- Anime-themed rices (cool to look at but not practical)

## Architecture

### Status Bar (Waybar or QuickShell)
Top bar across the screen functioning like a proper taskbar:
- **Left:** Clickable app launcher button ("Apps" or icon) that opens Rofi, quick-launch clickable icons for Chrome, Terminal, File Manager
- **Center:** Workspace indicators (clickable to switch), window title
- **Right:** Media controls (current track, play/pause/skip), volume (clickable), WiFi status (clickable), battery, clock/date, system tray, notification indicator

Each right-side icon should be clickable to toggle a dropdown panel or popup with more detail/controls (like clicking WiFi to see available networks, clicking volume for a slider, etc.)

### Dropdown Panels (on-demand, triggered from bar clicks)
- **Network Panel:** Current WiFi info, available networks list
- **System/Power Panel:** Battery detail, brightness slider, volume slider, power profile selector, lock/sleep/reboot/shutdown buttons
- **Bluetooth Panel:** Connected devices, scan button

### App Launcher (Rofi)
- Opens from both clickable bar button AND Super+D hotkey
- Closes with Escape
- Dark themed to match palette
- Search-as-you-type to filter apps
- Clean modern layout

### Window Management
- Tiling by default — windows auto-arrange
- But ALSO: drag windows with mouse to reposition, drag edges to resize
- Floating windows supported (toggle with hotkey or right-click option)
- Window borders/edges grabbable for resize without any modifier key (resize_on_border)
- Apps that draw their own title bars (Chrome, etc.) keep their close/min/max buttons

### Terminal (Kitty)
- Dark theme with navy background, slight transparency (0.85-0.9 opacity) with blur
- FiraCode Nerd Font
- Ctrl+C = copy when text selected, interrupt when not
- Ctrl+V = paste always
- Scrollback 10000 lines
- Proper font size for 1.5x retina scaling

### Touchpad (critical for MacBook)
- disable_while_typing = true (CRITICAL — prevents cursor jumps while typing)
- Natural scrolling on
- Tap to click on
- Two-finger right click
- Sensitivity tuned for Mac trackpad

### Function Keys (Mac-specific)
- Volume up/down/mute via XF86Audio keys
- Brightness up/down via XF86MonBrightness keys
- These must work with the Mac function key row

### Screenshots
- Super+Shift+S = area select to clipboard (like Windows Snip Tool)
- Print = full screen to clipboard

### Copy/Paste
- Ctrl+C = copy (when text selected in terminal, send interrupt when not)
- Ctrl+V = paste
- This must work in terminal (Kitty) AND in GUI apps (Chrome, etc.)

### Chrome
- Runs on Wayland natively (ozone-platform=wayland in chrome-flags.conf)
- Has its own title bar with close/min/max buttons
- Launches independently — not tied to a parent terminal process
- Default browser

## Component Choices

| Component | Choice |
|-----------|--------|
| Distro | NixOS 26.11 with flakes |
| Window Manager | Hyprland (Wayland) |
| Shell | Fish (interactive) / Bash (scripts) |
| Terminal | Kitty |
| Browser | Google Chrome (allowUnfree) |
| Status Bar | Waybar initially, QuickShell later for advanced widgets |
| App Launcher | Rofi |
| Color Theming | Matugen (Material You) — future. Manual dark navy theme for now. |
| Notifications | Dunst or Mako |
| Lock Screen | Hyprlock or custom — future |
| Wallpaper | Swww or Hyprpaper |
| File Manager | Thunar |
| Audio | PipeWire (already configured) |
| Cursor Theme | Adwaita (changes to I-beam over text, pointer over clickable) |

## Packages to Install

### Essential (need now)
- google-chrome, kitty, thunar, rofi
- waybar, swww or hyprpaper
- dunst or mako (notifications)
- brightnessctl (screen brightness)
- wl-clipboard, grim, slurp (clipboard and screenshots)
- adwaita-icon-theme (cursor theme)
- xdg-utils
- git, nano, curl, wget
- nodejs_22 (for Claude Code / Codex)
- fish
- FiraCode Nerd Font, Noto fonts

### Nice to Have (install when functional)
- btop (system monitor)
- fastfetch (system info)
- cava (audio visualizer)
- spotify
- mpv (video player)
- discord

### Development (install later)
- VS Code
- Python 3, pip
- Rust toolchain
- Docker
- Claude Code, Codex CLI (already installed via npm)

## NixOS Constraints
- T2 MacBook hardware imports and Broadcom firmware derivation in configuration.nix MUST be preserved
- programs.nix-ld.enable = true must stay (needed for Claude Code / Codex)
- nixpkgs.config.allowUnfree = true must stay (needed for Chrome)
- Package names may differ in NixOS 26.11 — verify before adding
- User: alex, hostname: macbook, shell: fish
- GitHub config repo: https://github.com/AlexbringsMercy/nix

## Reference Builds
- **Primary:** https://github.com/ilyamiro/nixos-configuration — NixOS + Hyprland + QuickShell, beautiful animations, the user's favorite. But uses hub architecture (single morphing panel) while user wants dashboard architecture (independent widgets). Pull animation quality, theming approach, and QuickShell patterns.
- Search for other polished NixOS + Hyprland community builds to pull from for waybar configs, rofi themes, hyprland.conf best practices, and general dotfile structure.

## Phases

### Phase 1: FUNCTIONAL DESKTOP (this is where we are — need this NOW)
- All basic OS operations work via mouse
- Proper taskbar with clickable everything
- Tiling works, windows resizable/movable with mouse
- Copy/paste works normally
- Touchpad works without mangling text
- Function keys work
- Chrome works properly
- Apps launch from bar and launcher
- Dark themed, not ugly

### Phase 2: POLISH AND AESTHETICS (next session)
- Glassmorphic effects
- Smooth animations tuned
- Matugen color generation
- Beautiful wallpapers with auto-theming
- Lock screen
- Notification styling

### Phase 3: CUSTOM WIDGETS (future)
- QuickShell music player with visualizer
- Weather widget
- System dashboard panels
- Dev workflow launcher
- Per the widget architecture described above

### Phase 4: PORT TO ALIENWARE (future)
- Same setup on the Alienware 14 with dual-monitor layout
- Adapt for Nvidia GPU and dual screens
