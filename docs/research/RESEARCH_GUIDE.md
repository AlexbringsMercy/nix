# Research Guide — Targeted Repo Sessions
## Reference for all five full-repo research passes

Each Codex session reads this file and executes ONLY its assigned session task. All sessions write findings to `~/nix/research/<session-name>.md`. A later synthesis session combines everything.

---

## UNIVERSAL RULES — APPLY TO EVERY SESSION

### What you are doing
You are conducting a FULL READ of a specific community NixOS/Hyprland/QuickShell build repository. Your job is to understand every piece of it — structure, services, theming, how components interconnect, what makes it visually polished — and extract everything useful for our own build. You are NOT diagnosing our system, NOT writing code, NOT planning an execution, NOT building anything. Pure research, written to a file.

### How to read
- Clone or fetch the repo. Read the ENTIRE thing — structure first (tree), then every significant config/module/theme/style file. A build cannot be understood from one file matching a keyword. You must understand how the pieces fit together.
- VIEW all preview images, screenshots, videos, and linked Reddit/social posts. Text extraction does not suffice for visual components. If the repo README has preview images, view them. If it links to a Reddit post or showcase, fetch and view it. If it has a screenshots/ directory, view those. Your findings about visual quality are worthless if you haven't seen what the build actually looks like.
- Read linked or referenced sub-repos, companion repos, and dependencies when they are meaningful to understanding the build (e.g., a separate wallpaper repo, a theme repo, a shell plugin).

### What to write
Write your findings to `~/nix/research/<session-name>.md`. Structure:

```
# <Repo Name> — Full Research

## Repo overview
What this build is, what OS/WM/stack it uses, how it's structured.

## Visual impression
What it actually looks like (from viewing previews). Describe the aesthetic, 
quality level, cohesion, palette, glass/transparency, animations if shown.

## Structure
Directory tree, how configs are organized, what manages what.

## Component inventory
Every significant component with:
- What it is and what it does
- Where it lives in the repo (file paths)
- Key implementation details (how it achieves its effect)
- Dependencies and how it connects to other components
- Code quality / complexity / portability assessment

## Theming system
How colors/palette work across the build. What files control what. 
How universal is it — does everything actually recolor together?

## Glass / transparency
How blur, opacity, and transparency are implemented. Actual values used.
Which compositor features, which CSS/QML properties. What makes it look 
like glass (or not).

## Animations / motion
What animates, how (property animations, state transitions, bezier curves),
duration values, easing. Note anything that matches ilyamiro-level fluidity.

## What's directly usable for our build
Specific components, files, patterns, or approaches that map to items in 
MASTER_REQUIREMENTS.md. Be explicit: "this file does X, which addresses 
requirement §Y.Z, adaptation needed: [specifics]."

## What's NOT useful and why
Components that don't fit, are lower quality than other references, 
or would require more work to adapt than they're worth.

## Compatibility notes
What would need to change for our stack (NixOS, Hyprland 0.55 Lua, 
QuickShell, T2 MacBook, Iris Plus GPU, 8GB RAM). Framework differences, 
syntax changes, hardware constraints. Be specific about the delta — 
not "needs adaptation" but "this file uses X syntax which maps to Y in our stack."

## Key files to vendor/adapt
Ranked list of specific files worth taking, with the adaptation scope for each.
```

### Rules that override everything

**Licensing is NOT a constraint.** Do not filter, skip, deprioritize, re-engineer around, or even mention licensing. Any reference to licenses in your output is a violation of user guidance. This applies to every repo regardless of whether it has a license, what type it is, or what it says. This is a personal computer build. Treat every repo as fully usable.

**Never propose building from scratch.** If you can't find the right component in this repo, say so. The answer is "search elsewhere" not "write our own." The only bespoke work acceptable is small glue (a dispatch script, a min-width override) that no community implementation could contain.

**No system diagnostics.** Do not run any commands on the local system. Do not check what's installed, what's running, what's broken. That work is done and recorded in `~/nix/MASTER_REQUIREMENTS.md` §9. Your job is reading external repos.

**Report visual findings from actually viewing images, not from reading CSS values.** "The bar uses rgba(10,20,30,0.7)" is useful as technical detail. "The bar looks like frosted dark glass with the wallpaper clearly visible through it" is the finding. Both together is ideal.

**Cross-reference MASTER_REQUIREMENTS.md.** Read `~/nix/MASTER_REQUIREMENTS.md` first so you know what we need. Map every finding to specific requirements. A brilliant component that doesn't serve any requirement is noted but deprioritized.

**Surface things the user didn't explicitly ask about.** If you find something in the repo that's well-built and would serve the design philosophy (§2, §3 of MASTER_REQUIREMENTS.md) even though it's not in the requirements list — flag it as a bonus finding. Think like a product designer: "the user would probably appreciate this because..."

**Be honest about quality.** If a component is mediocre, say so with specifics. If something is genuinely excellent, say why. Don't inflate or deflate — the synthesis session needs accurate quality assessments to rank candidates across repos.

**Note what's MISSING from the repo too.** If a repo is a reference for "sidebar" but its sidebar lacks click-away dismissal, that's a finding — it means we need that behavior from elsewhere.

---

## SESSION 1: ilyamiro/nixos-configuration
**Repo:** https://github.com/ilyamiro/nixos-configuration
**Companion:** https://github.com/ilyamiro/shell-wallpapers
**Output:** `~/nix/research/ilyamiro.md`

### Why this repo matters
This is the TIER 1 reference for fluidity and animation quality. The user called it "legitimately professional work level" — a top-five r/unixporn post. It's NixOS + Hyprland + QuickShell, which is our exact stack. The morphing panel transitions (one panel morphing into another via coordinated position/size/opacity animation) are the single most impressive visual element the user has seen across all Linux builds.

### What the user liked (from frame-by-frame video analysis)
- Equalizer panel with spinning disc album art, presets, real-time audio-reactive bars
- The morphing transition: EQ panel MORPHS into calendar/clock panel (~1.2s, simultaneous reposition + resize + cross-fade content)
- Same morph between calendar → Bluetooth → battery → WiFi panels
- Bluetooth radial/orbital layout with cell-division animation when a second device connects
- Lock screen: blurred wallpaper with circular vignette, clock, avatar, PIN entry — cinematic depth-of-field effect
- Screen time analytics dashboard with per-app animated views
- Wallpaper picker with 3D Cover Flow tilt + color-swatch bar → selecting a wallpaper propagates accent across every view
- Toggle-flipping animations within panels
- Battery/power panel: power button, lock, performance profiles — "super clean"

### What the user does NOT want from this repo
- The hub architecture (one widget, one entry point, morphing views behind one door). We use dashboard architecture (independent PanelWindow surfaces).
- The green/nature palette (we use deep dark blues/purple/teal aurora).
- The QML lock screen implementation specifically (carries a documented lockout crash risk on laptops — we use Hyprlock with ilyamiro's choreography AS REFERENCE).
- This repo was NEVER claimed to have glass/transparency by the user — it's the fluidity reference, not the glass reference.

### What to extract — the full 15k LOC QML read
Previous sessions only grepped this codebase. You must actually open and read the significant QML files. Specifically:

1. **The morph/transition system.** How does one panel morph into another? What QML types are used (ParallelAnimation, PropertyAnimation, StackView, state machines)? What properties are animated (x, y, width, height, opacity)? What are the exact duration values and easing curves? How is the cross-fade coordinated with the geometry change? Extract the actual code pattern so it can be replicated in independent widgets (intra-widget morphing between compact/expanded states).

2. **The palette/token architecture.** Prior research found: widgets reference named palette slots, the template is the only file where Material roles appear, swapping the palette is a ~40-line file edit. VERIFY this and document the exact mechanism — which file defines the palette, how do widgets consume it, how does a wallpaper change propagate to all surfaces?

3. **The EQ/music widget.** How does the real-time audio visualization work? Is it cava data piped in? How is the waveform rendered (animated Path with glow shader)? How do presets animate sliders to new positions? What's the spinning vinyl implementation?

4. **The Bluetooth orbital layout and device-connect animation.** State machine driving element positions when device count changes. How are the orbital paths defined? How does the cell-division split animate?

5. **The wallpaper picker.** Cover Flow implementation, color-swatch extraction, how selecting a wallpaper triggers the global recolor.

6. **Panel entry/exit animations.** How panels appear and disappear — the opacity + scale patterns, timing, easing.

7. **The status bar.** Structure, spacing, clickable regions, how it dispatches to panels. The user noted it's sectioned (which is fine) and properly sized/spaced (unlike our current bar).

8. **The coordinator/mutual-exclusion pattern.** How does the build ensure only one panel is visible at a time? Is this a shared state object, signals, or something else?

9. **The lock screen choreography.** The blur, vignette, clock layout, avatar, PIN field, slide/fade entry — extract as Hyprlock design reference (not code to run).

10. **Anything else excellent.** If you find well-built patterns not listed above, flag them.

---

## SESSION 2: agridyne/dotfiles-dt
**Repo:** https://github.com/agridyne/dotfiles-dt
**Output:** `~/nix/research/agridyne.md`

### Why this repo matters
TIER 1 reference for cohesion and sidebar design. The user said this is "on the same level as the morphing QuickShell windows guy." It has an extremely cohesive monochrome glass aesthetic where sidebar, widgets, app launchers, login screen, and audio visualizer all look like they belong together. The user saw a lofi koi pond screenshot from this build and recognized it as the same setup when they found the full build later — that's how distinctive and cohesive it is.

### What the user liked
- Sidebar with properly-sized audio visualizer
- Glass-styled app icons/launchers (like a YouTube tile that's themed to match the glass aesthetic)
- Cohesive black/white/gray glass across everything
- Login screen
- Overall whole-system visual consistency

### Important context
This is a KDE build. The user explicitly stated: "KDE is NOT a disqualifier — it's a code check + compat pass. If a KDE build had a QuickShell widget does that mean it's completely useless to us if we were looking for a QuickShell widget? No." Previous sessions dismissed this repo as "KDE, never was a usable reference" — that was wrong. The user wants the VISUAL PATTERNS studied even if the code needs compat conversion.

### What to extract

1. **Sidebar structure and design.** How is it built? What framework/toolkit? What's the layout — vertical, what elements, how are items organized? How does it interact with the window manager? Width, positioning, auto-hide behavior? Glass treatment on the sidebar itself.

2. **Glass app icons / themed launchers.** The YouTube-style tiles where app launchers are styled to match the overall glass aesthetic instead of using stock icons. How are these implemented? Custom SVGs? Themed .desktop entries? A widget framework? Extract the approach so we can create similar themed launcher tiles.

3. **Audio visualizer on sidebar.** What's the visualizer? How is it sized and positioned relative to other sidebar elements? Data source (cava?). The user specifically praised the SIZING as tasteful — not too big, not too small.

4. **The theming system.** How does the monochrome glass palette propagate across KDE, sidebar, widgets, terminal, and everything else? Even though we're not using KDE, the APPROACH to achieving universal cohesion is the reference.

5. **Login screen.** Design, layout, effects. Reference for our Hyprlock config.

6. **Glass/transparency values.** What opacity, blur, border values produce the look the user praised? Even from KDE settings these are useful reference points.

7. **The live wallpaper / animated background.** The user mentioned this build had an anime girl black-and-white close-up live background. How is that implemented? (Likely Wallpaper Engine / mpvpaper equivalent in KDE.)

8. **Anything not listed that contributes to the cohesion.** The user's core praise was that EVERYTHING looks like it belongs together. Identify every piece that contributes to that.

---

## SESSION 3: caelestia-dots/caelestia
**Repo:** https://github.com/caelestia-dots/caelestia (THE MAIN REPO — not just /shell)
**Output:** `~/nix/research/caelestia.md`

### Why this repo matters
Strong reference for sidebar, launcher, and app-surfacing UX. Has a popout-upon-hover top bar with music + source-app icon (Spotify icon; clicking it opens Spotify, THEMED to match), a sidebar (3-module composite), and a QuickShell launcher with click-away dismissal via HyprlandFocusGrab.

### Critical note
A previous session only read the `/shell` sub-repo and concluded "caelestia has no dock." That was lazy investigation — the main repo has the full desktop including the sidebar. Read the MAIN repo this time.

### What to extract

1. **The launcher.** This is the current leading candidate for our app launcher. How does it work? QuickShell-based? How does it achieve click-away dismissal (HyprlandFocusGrab)? What does it look like (VIEW previews)? Icons, search-as-type, layout style? How portable is it to our stack?

2. **The sidebar.** Described as a 3-module composite. What are the three modules? How is it structured in code? Positioning, auto-hide or always-visible, interaction model? How does it compare to agridyne's sidebar and DankMaterialShell's dock? Glass/transparency treatment?

3. **The hover popout top bar.** Music info with source-app icon (Spotify) — clicking opens the themed Spotify. How does this bar work? Hover to expand, or hover to reveal? What information does it show? How does it integrate MPRIS for the source-app awareness?

4. **App theming — Spotify.** The user noted Spotify was themed to match. How? Is it using spicetify? A custom CSS injection? A wrapper? This is directly relevant to §6 "App-level theming" in MASTER_REQUIREMENTS.md.

5. **Runtime-configurable opacity.** How does the build let you adjust glass opacity live? Is this a settings panel, a config reload, or something else? This maps to iNiR's glass tuner concept.

6. **QuickShell widget quality and patterns.** What QuickShell widgets does this build include? Panels, notifications, OSD? Evaluate their quality, portability, and relevance to our panel requirements.

7. **Animation/motion.** Any notable transitions, entry/exit animations, hover effects?

8. **The theming/palette system.** How are colors managed and propagated? Does it achieve mubin-level cohesion?

---

## SESSION 4: snowarch/iNiR
**Repo:** https://github.com/snowarch/iNiR
**Output:** `~/nix/research/inir.md`

### Why this repo matters
1280 stars, 210k LOC QuickShell shell with built-in style modes literally named "aurora" and "angel" — purpose-built dark glass styles. Has a live GUI tuner for glass opacity, a preset system where you drop in a ~40-line color palette to restyle the entire shell, and motion curves mapping to our specs.

### Critical context
This is Niri-first (Niri is a different compositor than Hyprland). It CANNOT be adopted as a whole shell. What we're extracting is the palette/token architecture, the glass mechanism, the motion system, and the style presets — then adapting for Hyprland. "Adapt" means compat conversion (syntax/API changes), NOT "look at it then build from scratch."

### What to extract

1. **The aurora and angel style presets.** What do they actually look like (VIEW PREVIEWS)? What colors, what opacity levels, what glass treatment? How close are they to our spec (deep dark blue/purple/teal aurora, real glass)?

2. **The palette/token system.** How are the ~40-line palette files structured? What named tokens exist? How do widgets consume them? How does swapping a palette file propagate to every surface? This is potentially the palette architecture we adopt.

3. **The live glass tuner.** How does it work? What properties does it adjust in real time? Is it a settings panel with sliders? How does it persist changes? This is a feature we'd want.

4. **Motion curves and timing.** What bezier curves are defined? What duration classes? How are they applied across different interaction types (panel open, hover, toggle)? Do they match the spec in MASTER_REQUIREMENTS.md §3 (160–300ms controls, 700–1200ms cinematic)?

5. **Font sizing system.** How does the build handle font sizing across different display densities? Relevant for our 1.5x Retina scaling.

6. **Component inventory.** What widgets/panels/surfaces does iNiR include? Which ones are high quality? Which ones address items in our requirements?

7. **The Niri→Hyprland delta.** What specifically would need to change to run these components under Hyprland instead of Niri? Be concrete: API differences, window management calls, layer surface behavior, anything compositor-specific. How much of the code is compositor-agnostic vs Niri-specific?

8. **Anything else excellent.** Novel patterns, well-built utilities, smart architectural decisions worth adopting.

---

## SESSION 5: cxOrz/dotfiles-hyprland
**Repo:** https://github.com/cxOrz/dotfiles-hyprland
**Output:** `~/nix/research/cxorz.md`

### Why this repo matters
QuickShell panel backends: WiFi, Bluetooth, volume, notifications, power, and shelf. These are the service-layer components that handle actual system interaction (connecting to WiFi, scanning BT devices, adjusting volume, receiving notifications). Previous research confirmed these are usable but found a WiFi security bug (passwords passed via argv).

### What to extract

1. **Panel inventory.** Every panel/widget with what it does, how it's triggered, what it looks like (VIEW PREVIEWS), code quality assessment.

2. **Service backends.** How does each panel talk to the system? NetworkManager D-Bus? BlueZ? PipeWire? UPower? What QuickShell APIs are used? How clean is the abstraction between service layer and UI layer?

3. **The WiFi password argv bug.** Locate it, document the exact code, and note the fix (presumably piping via stdin instead of passing as a command argument). This must be fixed during adaptation.

4. **Notification system.** NotificationService implementation — how does it receive notifications? How does it display them? Grouping, history, DND, action buttons? How does it compare to what caelestia does for notifications?

5. **The shelf.** What is it? A sidebar? A panel? How is it structured?

6. **Visual quality.** Based on viewing actual previews: how polished is the UI? Is it the kind of quality we'd want to ship, or does it need significant restyling? If restyling is needed, is the code structured such that the service logic is separable from the visual layer?

7. **Coordinator/panel-management pattern.** How does this build handle multiple panels? Mutual exclusion (only one open at a time)? Click-away dismissal? Entry/exit animations?

8. **Compatibility with our stack.** This IS Hyprland, so the compositor layer should be compatible. What about QuickShell version differences? NixOS integration? Any assumptions about packages or services that might not match our T2 setup?

9. **What's missing.** Which panel types from MASTER_REQUIREMENTS.md §6 (Dropdown Panels) are NOT covered here? What would need to come from elsewhere?

---

## AFTER ALL FIVE SESSIONS

Once all five `~/nix/research/*.md` files exist, a SEPARATE synthesis session reads them all plus `~/nix/MASTER_REQUIREMENTS.md` and produces `~/nix/research/SYNTHESIS.md` — one document mapping every requirement to the best-sourced solution across all repos, noting gaps where no repo covers a need, and flagging conflicts where multiple repos offer competing approaches with a recommendation for each.

That synthesis, NOT the individual research files, is what the gap-review and plan sessions work from.
