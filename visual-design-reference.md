# Visual Design Reference & Claude Code Directive

## How to Use This Document

This is the master visual reference for overhauling the MacBook NixOS desktop.
Read the EXECUTION_LOG.md and BUILD_PLAN.md on disk for infrastructure context.
The plumbing (flake, T2 integration, Hyprland Lua framework, QuickShell panel
coordinator, Matugen pipeline) is already built. What needs replacing is every
visual surface — Waybar CSS/layout, Rofi theme, QuickShell panel styling,
glassmorphism tuning, color application, animation quality.

**Strategy:** Web search for polished community implementations of each visual
component. Do NOT build visual UI from scratch — that's what produced the
current mess. Find proven themes/configs, evaluate them against this reference,
adapt and integrate. You may pull from as many sources as needed.

---

## What's Wrong Right Now (with screenshots on disk)

The current desktop looks like a half-decent custom Android build. Specific
problems:

### Waybar
- Three separated pill sections crammed into a small space instead of one
  continuous clean bar
- Every element is too small — media controls (play/pause/skip) are practically
  unusable at current size
- CPU button and Memory button both open the same CPU monitor window
- The sectioned layout itself is fine as a concept (ilyamiro uses it too) but
  the spacing, sizing, and padding are wrong — elements need room to breathe
- Compare: ilyamiro's bar has the same sectioned layout but with proper sizing,
  readable text, clickable controls, and visual balance. Current build has none
  of that

### Rofi App Launcher
- Alternating pink/beige rows on purple background with a dashed border
- Looks broken, not styled — the Matugen colors produced muddy pinks and mauves
- Was supposed to use newmanls/rofi-themes-collection windows11-list-dark but
  clearly wasn't applied properly
- Click-away dismiss doesn't work (must hit Escape)
- Should close when clicking on any other window or outside area

### QuickShell Panels
- Glassmorphism is too dark — panels look like opaque black rectangles, not
  frosted glass
- Calendar is a wall of text with no visual structure
- Wallpaper switcher is custom-built jank instead of using a proper pre-built
  picker like Waypaper
- Screenshot and wallpaper controls are under the battery/power panel — should
  be in a separate system/settings panel
- EasyEffects appears as a visible app window — it should be invisible
  background infrastructure

### General
- Color palette not cohesive — Matugen output doesn't match wallpaper well,
  gradients look cheap where applied
- No smooth animation morphing on panels or windows like we discussed
- Scrolling too sensitive outside terminal (fine in terminal, jumps everywhere
  else)
- Screenshot tool has a purple overlay covering the capture
- Window close/minimize/maximize buttons only in top bar, not on windows
  themselves. Going to top bar every time is tedious.
- No apps sidebar — only a top bar, which feels incomplete compared to
  community builds that use two UI surfaces

### Functional Bugs
- disable_while_typing STILL not working — cursor clicks into text while typing
- Workspace 2 button does nothing
- Border resize only works one direction (expand, not shrink)
- Opening 3+ windows causes existing ones to close after resize
- Cmd+Space opens window focus instead of app launcher
- Drag and drop requires holding Cmd — should work by dragging title bar
  natively like any OS
- Delete/backspace too fast — should be progressive (slow start, accelerate)
- Weather not set to Austin, Texas

### Missing Features
- Cmd+arrow keys for window movement/snapping
- Ctrl+T for new terminal tab, Ctrl+Shift+T for reopen last closed tab
- Proper system settings button (separate from battery) for screenshot,
  wallpaper, display settings
- Apps sidebar or dock on the side

---

## Visual Design Intent — Concrete Specifications

### The Vibe (for search context)
Dark glass with aurora light bleeding through. Northern lights seen through a
frosted window at night. Modern, refined, clean — think Raycast's UI quality
level. NOT corporate, NOT flat, NOT generic dark mode, NOT Android-ish.

The user has built apps and dashboards with deep dark blue/black/purple/teal
color schemes with glassmorphism and smooth animations. This desktop should
feel like a natural extension of that aesthetic.

### Color Palette — Actual Values
Do NOT use the word "navy." It produces flat corporate blue from LLMs.

- **Surface/base:** Near-black with blue undertone. #0a0e1a to #131729 range.
  NOT pure black (#000). NOT gray. There should be perceptible color depth.
- **Panel backgrounds:** The surface color at 15-25% opacity over a blurred
  wallpaper. You should be able to see the wallpaper through the panel. If
  you can't see through it, it's too opaque.
- **Primary accent:** Teal/cyan range. #00d4aa, #0ea5e9, #38bdf8 neighborhood.
- **Secondary accents:** Deep purple (#7c3aed range), seafoam green (#34d399),
  aurora greens.
- **Text primary:** Light gray, not pure white. #e2e8f0 range.
- **Text secondary/dimmed:** #94a3b8 range.
- **Borders:** 1px at rgba(255,255,255,0.08) to rgba(255,255,255,0.12)
- **Hover states:** Subtle brightness increase, not color change
- **Gradients:** Smooth blobs blending between accent colors. NOT sharp linear
  gradients. Think aurora — diffuse, soft-edged color transitions.
- **With Matugen:** The above is the baseline. Matugen should REINFORCE this
  palette from wallpaper colors, not OVERRIDE it with random extracted colors.
  If a wallpaper produces muddy pinks, the Matugen template should constrain
  output to stay within the dark/cool spectrum. Use Matugen's dark scheme and
  bias surface roles toward near-black.

### Glassmorphism — Actual Properties
This is the most important visual property and was done wrong (too opaque,
looks like solid dark rectangles).

```
/* Waybar, QuickShell panels, Rofi */
background: rgba(10, 14, 26, 0.55-0.65);  /* NOT 0.85+ */
backdrop-filter: blur(12-16px);
border: 1px solid rgba(255, 255, 255, 0.08);
border-radius: 10-14px;

/* Terminal (Kitty) */
background_opacity: 0.82-0.88
/* with Hyprland blur enabled behind it */

/* The test: can you see the wallpaper through the panel?
   If yes → correct. If no → too opaque. */
```

### Animations
- Window open: fade in (0→1 opacity) + slight scale up (0.95→1.0), ~200-300ms,
  ease-out curve
- Window close: fade out + slight scale down, ~150-200ms
- Window move/resize: smooth follow with slight easing, not instant
- Workspace switch: horizontal slide, ~300ms
- Panel open: fade in + slide down from anchor point, ~200-250ms
- Panel close: fade out + slide up, ~150ms
- Internal panel state changes (compact→expanded): coordinated property
  animation on position, size, opacity, ~400-600ms with bezier easing — this
  is the ilyamiro-quality animation target
- Hover effects: subtle, ~100ms transitions
- NO janky/instant state changes. Everything transitions smoothly.

### Typography
- Terminal/code: FiraCode Nerd Font, size appropriate for 1.5x Retina
- UI text: Inter, Roboto, or system sans-serif. Clean, readable.
- Clock displays: Light weight, large size, monospace or clean display font
- Status bar: Should be readable at a glance. If you have to squint, it's too
  small. The current Waybar text is too small.

---

## Primary Reference Builds (with links — VISIT THESE)

Claude Code: for each of these repos, fetch the README and view any preview
images/screenshots. These are the quality bar. Study them before building
anything.

### Tier 1 — Match This Quality

**ilyamiro/nixos-configuration**
https://github.com/ilyamiro/nixos-configuration
NixOS + Hyprland + QuickShell. Morphing panel animations, wallpaper-adaptive
theming, beautiful music/EQ widget, calendar/weather, lock screen. The
animation quality and panel sizing/spacing is the benchmark. Pull QML patterns,
animation code, and theming approach directly.

**agridyne/dotfiles-dt**
https://github.com/agridyne/dotfiles-dt
Top-tier cohesive build. Clean black/white/gray glass aesthetic. Sidebar with
audio visualizer properly sized. Glass-styled app icons. Clean login screen.
Glass-effect app windows. YouTube and other apps matching the glass style.
This is the reference for: sidebar implementation, glass cohesion across ALL
elements, app icon styling, login screen alternative, audio visualizer sizing
and placement.

**caelestia-dots/shell**
https://github.com/caelestia-dots/shell
Excellent sidebar organization, layout, design, and animation. This is THE
reference for the sidebar/dock component. Study how the sidebar is structured,
how items are organized, how the animation works. Adapt the color and
glassmorphism level to match our specs.

### Tier 2 — Pull Specific Components

**liixini/skwd-wall (Parallelogram wallpaper switcher)**
https://github.com/liixini/skwd-wall
Beautiful wallpaper picker with parallelogram card layout. USE THIS instead of
building a custom wallpaper switcher. Clone it, adapt for compatibility with
our Matugen pipeline, integrate with awww/mpvpaper for transitions. Do NOT
rewrite from scratch. Currently undergoing a Rust rebuild but existing version
should work. This replaces any custom wallpaper picker.

**mubin-thinks/minimal-wm-config (Universal color reference)**
https://github.com/mubin-thinks/minimal-wm-config
Theme: https://github.com/mubin-thinks/charcoal
This is what REAL universal color palette application looks like. Chrome title
bar is recolored. Terminal is recolored. Waybar is recolored. EVERYTHING
matches. Study this repo's Matugen/pywal template setup to understand how to
make palette truly universal across all components — not the half-applied mess
Codex produced.

**saatvik333/hyprland-dotfiles (Terminal experience)**
https://github.com/saatvik333/hyprland-dotfiles
Clean terminal windows with: ASCII art on startup, find-file button, session
restore button, system processes displayed terminal-style. Cleaner file
explorer (dark glass GTK theme). Reference for: terminal startup experience,
file explorer theming, system info display style. The user wants terminal
startup art and the file explorer from this build or similar.

**snes19xx/surface-dots (Widget structure)**
https://github.com/snes19xx/surface-dots/tree/main
Widget sizing and structure reference. Music currently-playing widget is well
sized. App launcher is modern and clean. Terminal startup system info. Pull
widget sizing patterns and app launcher reference.

**cxOrz/dotfiles-hyprland (QuickShell control panels)**
https://github.com/cxOrz/dotfiles-hyprland
QuickShell widget components for WiFi, Bluetooth, volume, notifications, power.
Already referenced in the existing build's SOURCES.md. These panel
implementations should be the functional foundation — but styled to match our
glass specs, not used as-is visually.

### Tier 3 — Specific Elements

**Harshil-Anuwadia/wintux-dualboot-grub-theme-updated**
https://github.com/Harshil-Anuwadia/wintux-dualboot-grub-theme-updated
Matrix red pill / blue pill dual-boot GRUB theme. Install for the macOS/NixOS
boot picker. Lower priority — cosmetic boot menu improvement.

### Search Evaluation Protocol

For each visual component, Claude Code MUST:
1. Search at least 3-5 different community implementations
2. Fetch and VIEW their screenshots/previews from the repos
3. Compare each against the reference images and concrete specs
4. Rank them with explicit reasoning about why one matches better
5. Only proceed to integrate the top choice
6. If nothing matches well enough, search with different terms and repeat

Do NOT grab the first search result. The current build's visual problems came
from using implementations without evaluating their visual quality against the
design intent. Every visual component needs a deliberate quality gate.

## Additional Requirements (from latest feedback)

### Live/Animated Wallpapers
The user wants animated wallpaper support. Use `mpvpaper` instead of or
alongside awww for video/animated backgrounds. People use MP4/WebM loops.
The static wallpaper pipeline (awww + Matugen) stays for still images;
mpvpaper is an additional option for animated ones.

### Internet Speed in WiFi Widget
The WiFi panel/indicator should show actual internet speed (download/upload
in Mbps), not just a signal percentage. Signal strength percentage is
meaningless to the user.

### Terminal Startup Experience
When opening a new terminal (Kitty), it should display:
- ASCII/terminal art (clean, stylized — reference saatvik333's terminals)
- System info (fastfetch or similar)
- The terminal should have personality, not just a blank prompt

### System Processes as Dedicated Workspace
System monitoring (htop/btop, process list, resource graphs) should be
accessible as workspace 2 content or a dedicated terminal-style view — NOT
a widget popup. Reference saatvik333's terminal-style process display. If
it opens as a panel/widget, it should look like a clean custom terminal view,
not a basic system monitor app window.

### File Explorer Upgrade
Current Thunar looks dated. Either:
- Apply a proper dark glass GTK theme (reference saatvik333's file explorer)
- Switch to Nautilus or Nemo with proper theming
- The file explorer must match the desktop's glass aesthetic

### Universal Color Palette (CRITICAL)
Reference: mubin-thinks/minimal-wm-config
The Matugen color palette MUST apply to ALL of these:
- Waybar (background, text, accents, hover states)
- QuickShell panels (all of them)
- Kitty terminal (new windows — existing windows keep their palette)
- Rofi launcher
- Chrome window chrome/title bar
- GTK apps (Thunar/file manager, any GTK app)
- Hyprland window borders
- Hyprlock lock screen
- Notification toasts
- Screenshot selector overlay
- Any other UI surface

If ANY element doesn't match the wallpaper-derived palette, the Matugen
template for that element is missing or broken. Fix it.

---

## Component-by-Component Reference

### Waybar — What Good Looks Like

**Reference: ilyamiro's bar** (see reference screenshots on disk and the
build spec's video analysis section)
- Three visual sections (left/center/right) IS fine as a concept
- But each section has proper internal padding and spacing
- Elements are sized for usability — media controls are clickable, not 8px
  icons
- The bar height is adequate (not cramped)
- Text is readable at the display's DPI
- The glass effect is visible — you can see wallpaper through the bar
- Accent colors highlight active/important elements (current workspace,
  playing track)

**Search terms for Claude Code:**
- "hyprland waybar glass theme"
- "waybar catppuccin mocha transparent"
- "waybar blur glassmorphism css"
- "hyprland waybar config reddit 2025 2026"
- r/unixporn search: "waybar" filtered by top/year
- LinuxBeginnings/Hyprland-Dots waybar CSS (this was supposed to be the
  styling source but wasn't applied properly)
- end-4/dots-hyprland waybar styling

**Requirements:**
- One continuous bar OR properly spaced sections (either is fine)
- Minimum ~36-44px logical height (current is too cramped)
- Left: Apps button (clickable → Rofi), pinned app icons (Chrome, Kitty,
  Thunar) — icons should be ~20-24px, clickable
- Center: Workspace indicators (clickable), active window title
- Right: Media (track name + play/pause/skip at usable size), system indicators
  (CPU, RAM, volume, WiFi, BT, battery), clock, notification bell
- Each right-side icon clickable to trigger corresponding QuickShell panel
- Glass background matching the specs above
- Proper Matugen color variable consumption

### Rofi — What Good Looks Like

**The current one is broken.** Replace entirely with a proven community theme.

**Search terms:**
- "rofi wayland theme dark glass"
- "rofi theme transparent blur hyprland"
- newmanls/rofi-themes-collection — specifically the dark list-style themes
- adi1090x/rofi — extensive theme collection
- "rofi hyprland rice reddit"

**Requirements:**
- Dark glass background (not opaque, not muddy pink)
- App icons alongside names
- Search bar at top
- Clean list layout — no alternating bright/dark rows
- Click on app → launches, panel closes
- Click outside panel → panel closes (not just Escape)
- Proper Matugen color integration
- Triggered by BOTH clicking "Apps" in Waybar AND pressing Super key

### QuickShell Panels — What Good Looks Like

**Reference: ilyamiro's panels** (the video analysis earlier in this chat
documented every panel in detail):
- Calendar/weather: full month grid, large clock with seconds, hourly weather
  on a curved timeline, upcoming events section. Clean layout with visual
  hierarchy, NOT a wall of text.
- Music/EQ: spinning vinyl disc album art, track info, transport controls
  (play/pause/skip at USABLE size), progress bar, 10-band EQ with presets,
  real-time cava waveform overlay when playing.
- WiFi: network name centered, signal strength, IP address, security type,
  band — information displayed in a radial or card layout, not a raw text dump
- Power: battery gauge (circular or bar), brightness slider, volume slider,
  power profile selector, lock/sleep/reboot/shutdown buttons
- Each panel: dark glass background matching glassmorphism specs, smooth
  open/close animation, click-away dismiss, Escape dismiss

**Reference: cxOrz/dotfiles-hyprland** QuickShell panels for control surface
patterns (WiFi, BT, volume, power, notifications)

**Additional search terms:**
- "quickshell hyprland panels"
- "quickshell qml widgets nix"
- "hyprland control center quickshell"
- r/hyprland search: "quickshell"

**Panel architecture (already built, keep it):**
- Each panel is an independent PanelWindow
- PanelCoordinator provides mutual exclusion (one open at a time)
- Waybar click dispatches: `qs -c aurora-shell ipc call panels toggle NAME`
- This architecture stays. Only the STYLING and LAYOUT of each panel changes.

### Wallpaper Management

**The current custom wallpaper picker is jank.** Either:
1. Use Waypaper (already installed) with a CLEAN configuration
2. OR search for: "hyprland wallpaper picker", "waypaper rice", wallpaper
   selector tools with actual UIs

**The wallpaper picker should NOT be hidden under the battery panel.** It should
be in a separate system/settings panel or accessible from the right-click
desktop menu.

**Wallpaper sources for the collection:**
- Wallhaven.cc — search by dark colors, filter to 2560x1600+, tags: aurora,
  northern lights, dark landscape, night sky, abstract dark
- r/wallpapers, r/wallpaper
- The existing 12 wallpapers in ~/Pictures/Wallpapers/aurora-collection/ stay

### Lock Screen (Hyprlock)

**Reference: ilyamiro's lock screen:**
- Wallpaper with gaussian blur + circular vignette (depth-of-field effect)
- Large clock centered, date below
- On interaction: profile avatar (circular), username, "ENTER PIN" label,
  pill-shaped input field with dots
- Minimal system indicators at bottom (battery, WiFi, temp)
- Smooth transition animation between locked state and login prompt
- The overall effect is cinematic — looks like a professional lock screen, not
  a Linux default

**Search terms:**
- "hyprlock config blur vignette"
- "hyprlock beautiful rice 2025 2026"
- "hyprlock glassmorphism"

### Apps Sidebar / Dock

**The user wants a second UI surface besides the top bar.** Many community builds
have either:
- A vertical sidebar on the left with pinned app icons and a file explorer
  tree
- A bottom dock with pinned apps (like macOS dock but styled)
- A slide-out sidebar with categorized app shortcuts and system controls

**This is a new element not in the current build.** Search for:
- "hyprland dock nwg-dock"
- "hyprland sidebar widget"
- "nwg-dock-hyprland" (common Hyprland dock)
- "hyprland panel sidebar quickshell"

**Requirements:**
- Pinned apps: Chrome, Kitty, Thunar, Spotify (when installed), Claude.ai
  bookmark
- Consistent with the glass theme
- Doesn't interfere with tiling (auto-hides or reserves space)

### File Manager (Thunar)

Current Thunar looks dated. Options:
- Apply a proper GTK theme that matches the desktop palette (Thunar respects
  GTK theming)
- Search: "gtk theme dark glass hyprland", "catppuccin gtk theme",
  "orchis gtk theme dark"
- The GTK theme should be set system-wide so ALL GTK apps match

---

## Reference Screenshots Analysis

These are from screenshots the user provided earlier in the design phase.
The user doesn't have links to all source posts, but the visual properties
are documented here for matching against community builds.

### What the User Liked Across All References

1. **Atmospheric wallpapers** with the desktop built around them — the wallpaper
   sets the mood and the UI complements it

2. **Information-dense status bars** that show useful telemetry (CPU temp, RAM
   usage, network speed, volume level, battery, clock, currently playing track)
   without being cramped — proper spacing and sizing

3. **Music integration** visible on the desktop — album art, playback controls,
   audio visualizer (cava). Multiple references had this as a prominent element.

4. **System info displays** (neofetch/fastfetch) in terminals with color blocks
   — terminal personality, not just a blank prompt

5. **Consistent color schemes** where the bar, terminal, widgets, and wallpaper
   all share the same palette. The color flows through every element.

6. **Dark palettes with luminous accents** — deep blues, purples, teals, cyans
   against dark backgrounds. The aurora/northern-lights quality.

7. **Functional widget panels** that surface controls without digging — quick
   settings, notification centers, media controls, weather, calendar. Things
   like the AwesomeWM build (reference image 10) that had hardware monitor,
   quick settings toggles, notification center, and a custom shutdown screen.

8. **Clean tiling layouts** where terminals and editors tile automatically but
   the setup isn't just "8 empty terminals with neofetch." Practical layouts
   with editors, browsers, terminals, and file managers tiled together.

### Specific Reference Builds (from earlier screenshots)

**Cozy music room Hyprland** (reference image 1 from earlier):
- Warm-toned bar at top with workspace indicators and system stats
- Single terminal with generous padding
- Atmospheric illustrated wallpaper
- Notification toast in corner
- WHY LIKED: The bar layout and spacing, the cozy integrated feel

**HyDE Arch Linux** (reference image 2):
- Arch + Hyprland + Kitty showing system fetch
- Purple/dark blue palette
- File manager tiled next to terminal
- WHY LIKED: The purple-blue color direction, the tiling layout

**Lofi koi pond Arch** (reference image 3):
- Arch + Hyprland with atmospheric illustrated wallpaper
- Music player visible, audio visualizer bars
- Multiple tiled elements
- WHY LIKED: Music + visualizer integration, the vibe

**Cyberpunk EndeavourOS** (reference image 4):
- Red accent on dark, highly atmospheric
- Minimal but dramatic
- WHY LIKED: The cinematic mood, how dramatic the single accent color is
  against near-black

**NixOS widget dashboard** (reference image 5):
- Left sidebar with app launcher, weather, favorite sites, music player
- Notification panel on right with volume/brightness sliders
- WHY LIKED: The sidebar layout with organized sections, persistent weather
  and music, the notification panel design

**Lavender Arch music** (reference image 6):
- Purple/lavender theme with music playlist and audio visualizer
- Mountain landscape wallpaper
- WHY LIKED: The audio visualizer integration, the purple palette

**Purple mountain multi-workspace** (reference image 7):
- Multiple workspace previews showing different layouts
- Purple gradient theme
- Clock overlay on clean workspace
- WHY LIKED: The clean workspace with large clock, the purple gradient

**Sunset terminal Fedora** (reference image 8):
- Warm sunset wallpaper with terminal and system monitor
- Functional, not over-designed
- WHY LIKED: The practical layout, readable terminal

**Cyberpunk Kali dual-view** (reference image 9):
- Neon pink/cyan on dark, cyberpunk aesthetic
- Organized app tiles in categories (Pentest, Stuff, Dev sites)
- File manager with matching theme
- WHY LIKED: The categorized app organization, the matching file manager
  theme, the cohesive neon palette

**AwesomeWM control panels** (reference image 10):
- Custom quick settings sidebar (hardware monitor, toggles, sliders)
- Custom notification center with actionable notifications
- Custom shutdown/power screen
- Music player with playlist
- WHY LIKED: The functional control panels — every system control accessible
  via mouse clicks, not hidden behind hotkeys. The notification center with
  action buttons. The quick settings with hardware monitoring and toggles.

**KDE Plasma dev setup** (reference image 11):
- Arch + KDE with clean developer workspace
- Terminal + VS Code tiled
- App launcher with text-based filtering
- Bottom status bar with full system info
- WHY LIKED: The practical developer layout, the information-dense bottom
  bar, the clean app launcher

### Primary Video Reference — ilyamiro NixOS + Hyprland + QuickShell

This build (github.com/ilyamiro/nixos-configuration) is the #1 visual
reference. Full frame-by-frame analysis was done earlier. Key things to
match:

- **Animation quality:** Smooth coordinated property animations on panel
  open/close/morph. ~1-1.2 second transitions with bezier easing curves.
  Nothing pops or snaps. Everything flows.
- **Panel sizing:** Panels are large enough to be usable. Controls are clickable.
  Text is readable. There's generous padding inside panels.
- **Glass effect:** You can see the wallpaper through panels. They're dark but
  translucent, not opaque.
- **Color cohesion:** Every element shares the palette. When he switches
  wallpapers, EVERYTHING recolors — bar, panels, sliders, accent dots, even
  the album art border.
- **Bar sizing and spacing:** Proper. Elements are not crammed. Media controls
  are full-sized and clickable. The bar has room to breathe.

---

## Bug Fix List (in priority order)

### Critical (affects daily usability)
1. disable_while_typing not working — cursor jumps into text while typing
2. Scrolling too sensitive outside terminal — needs scroll speed/sensitivity
   tuning in Hyprland input config
3. Border resize only works in expand direction, not shrink
4. Opening 3+ windows closes existing ones — tiling bug
5. Cmd+Space should open Rofi launcher, not window focus
6. Click-away dismiss for Rofi (clicking outside should close it)
7. Drag windows by title bar without holding modifier key
8. Screenshot tool has purple overlay covering captures

### Important (affects workflow)
9. Workspace 2 button does nothing
10. CPU and Memory buttons both open CPU monitor
11. Delete/backspace key too fast — should be progressive acceleration
12. Weather location: set to Austin, Texas (lat 30.2672, lon -97.7431)
13. Cmd+arrow keys for window movement/tiling
14. Ctrl+T new terminal tab, Ctrl+Shift+T reopen closed tab in Kitty
15. EasyEffects should not appear as a visible window — hide from launcher
    and taskbar, run as background service only
16. Wallpaper picker should be accessible from a system/settings button,
    not hidden under battery panel

### Nice to Have
17. Window close/minimize/maximize buttons on the windows themselves
    (consider Hyprland hyprbars plugin when stable, or at minimum ensure
    the Waybar window controls are properly visible and sized)
18. App sidebar / dock as second UI surface
19. Fastfetch / system info in terminal on open

---

## File Locations on Disk

Read these for infrastructure context:
- `/home/alex/nix/EXECUTION_LOG.md` — what was built and current state
- `/home/alex/nix/BUILD_PLAN.md` — design intent and source integration
- `/home/alex/nix/SOURCES.md` — community provenance
- `/home/alex/nix/docs/controls.md` — current keybinds and mouse paths
- `/home/alex/nix/docs/recovery.md` — rollback procedures

Config files to modify for visual overhaul:
- `modules/home/waybar/` — Waybar config and CSS
- `modules/home/hyprland/` — Hyprland Lua configs (animations, input, rules)
- `modules/home/rofi/` — Rofi theme
- `modules/home/kitty/` — Kitty terminal config
- QuickShell QML files — find under the modules/home structure
- Matugen templates — find under the modules/home structure
- GTK theme config — for Thunar and other GTK apps

DO NOT modify without understanding:
- `/etc/nixos/` — T2 hardware config (leave alone)
- `flake.nix` — input pins (leave alone unless updating packages)
- `modules/nixos/t2-firmware.nix` — firmware derivation (leave alone)
