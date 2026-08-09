# Visual Design Reference — Aurora

## Subordination (read this first)

This document expresses **visual intent** only — mood, quality bar, atmosphere,
motion feel, typography, and the reference material that shaped them. It is
**subordinate to `docs/plans/GRAND_PLAN.md`** and can never override it. Where anything
below reads as architecture, surface ownership, or palette authority, and it
conflicts with `docs/plans/GRAND_PLAN.md`, **the Grand Plan wins, always** — this file is
not a second source of truth for what gets built or who owns a surface. Its
job is to keep the *feel* the plan is aiming for legible in one place.

**Provenance:** the original version of this file (654 lines, written during
the pre-Grand-Plan design phase) is preserved intact at
`docs/archive/superseded-docs/2026-07-29/visual-design-reference.md`. This
replacement was written on 2026-07-29 after `docs/plans/GRAND_PLAN.md` was revised
(architecture correction of the same date) so this reference stops asserting
superseded ownership and stale palette authority. Nothing in the original is
silently gone — see "What was dropped, and where it actually lives" below.

---

## The vibe (still the north star)

Dark glass with light bleeding through — the atmosphere of northern lights
seen through a frosted window at night, or an equally polished treatment of
whatever the active wallpaper's own colors call for. Modern, refined, clean:
**Raycast's UI quality level.** Not corporate, not flat, not generic dark
mode, not Android-ish. Every surface should feel like one deliberate system,
not a parts bin of default widgets.

This is a quality bar, not a fixed hex sheet — see the palette note below for
why the original document's fixed color values are gone.

## Palette authority has moved — this is the one real correction

The original document specified a **fixed** near-black palette (`#0a0e1a`–
`#131729`, teal `#00d4aa`/`#0ea5e9`, purple `#7c3aed`, etc.) with Matugen only
allowed to "reinforce" it. **That model is retired.** Current authority
(`docs/plans/GRAND_PLAN.md` §3.1, §4.0, decisions 15–16 in §10.2) is:

- The palette is **generated from the active wallpaper**, in full — not just
  an accent color. Background, surface ladder, foreground, borders, primary/
  secondary/tertiary, states, gradients, borders/glow, bars, rail, panels,
  notifications, application chrome, terminal, file manager, and lock screen
  all derive from it.
- **Auto mode is dark-preferred, not dark-forced.** Dark/evening/shadowed
  wallpapers produce a dark theme in their own color family (a dark red
  wallpaper reads as oxblood/crimson glass, not black-with-a-red-border).
  **Clearly light wallpapers produce a real light theme** — ivory/cream/pale
  surfaces with dark readable foreground, not a forced dark UI.
- **Aurora is the project/shell codename, not a palette.** The teal/purple/
  green aurora-borealis look this document was originally built around is
  **one optional saved preset, named "Northern Lights."** It is not the
  default and every wallpaper is not pulled toward it.
- **Matugen is not the system-wide authority.** It may still exist internally
  inside skwd-wall's own picker UI, pointed back at the published system
  palette; it does not own or reinforce anything system-wide.
- The invariant that *is* enduring: **if any surface doesn't recolor with the
  rest when the wallpaper changes, that surface's theming is broken** — this
  is stronger now than the original "universal color palette" ask, because
  it covers the full semantic system, not just accents.

Exact roles, ladders, contrast guards, and the Stage 4 gate live in
`docs/plans/GRAND_PLAN.md` §3.1 and §4.0. Do not restate hex values here; they are
wallpaper-derived and mode-aware, not fixed.

## Glass — the test hasn't changed, the numbers now flex by mode

The property that mattered most in the original document is still exactly
right and still the way to eyeball it:

> **Can you see the wallpaper through the panel? If yes, correct. If no, too
> opaque.**

What changed: the alpha/blur ranges are no longer fixed dark-mode numbers.
`docs/plans/GRAND_PLAN.md` §3.2 gives dark-auto and light-auto starting ranges per
surface class (top bar/rail/panels, popouts, inner cards, tooltips, terminal,
hover/selected) and reserves final tuning for the Stage 4 glass/palette gate,
tested against dark red, dark blue/green, Northern Lights, evening,
cream/yellow, and other real wallpapers from Alex's library. Blur stays
compositor-owned (Hyprland, one scoped pass) — never per-surface QML blur,
never a full-screen FBO.

## Motion — the vocabulary that made ilyamiro the benchmark

This is one of the two things (with glass) that most directly carried
forward unchanged. The original animation numbers below were written into
this document first and are now the literal source for `docs/plans/GRAND_PLAN.md` §3.3's
token table — nothing here contradicts current authority, it's where current
authority's numbers came from:

- Window open: fade in + slight scale up (0.95→1.0), ~200–300ms, ease-out.
- Window close: fade + scale down, ~150–200ms.
- Workspace switch: horizontal slide, ~300ms.
- Panel open: fade + slide from anchor, ~200–260ms; panel close faster.
- Compact↔expanded internal state changes: coordinated position/size/opacity
  animation, ilyamiro-quality — this is now the `morph` token.
- Hover: subtle, ~100–150ms.
- **Nothing pops or snaps. Everything transitions.**

Current authority names, times, and curves precisely (`effectFast`, `effect`,
`panelOpen`/`panelClose`, `morph`, `selectionStretch`, `layout`, `cinematic`,
`reducedMotion`) in `docs/plans/GRAND_PLAN.md` §3.3, one token table owned by the theme
and consumed everywhere. Use that table, not adjectives, when implementing.
The one addition since this document was first written: cinematic
(700–1200ms staged choreography) is reserved for the lock screen and first
expansion of a rich widget — repeat interactions of the same surface always
run at ordinary `panelOpen` speed, and motion never queues input.

## Typography — unchanged

Inter for UI, FiraCode Nerd Font for terminal/code, light-weight large
numerals with tabular figures for hero clocks (lock screen, top-bar clock).
Base UI size 14–15 (13px reads too small at this display's 1.5x scale).
Status/bar text must be readable at a glance — if you have to squint, it's
too small. Papirus icons everywhere for visual consistency. Hit targets
≥34px for bar controls, 40×40 grid cells, 44px primary actions, independent
of visual scale. All of this matches `docs/plans/GRAND_PLAN.md` §3.4 as written.

---

## Where the surfaces this document asked for actually live now

The original document treated the "apps sidebar," the lock screen, the file
manager, and wallpaper management as open asks. They are no longer open —
each has a specific, plan-owned answer:

| What this doc asked for | Current owner | Where |
|---|---|---|
| "Apps sidebar or dock, second UI surface" | The left application rail: launcher, pinned apps, current-workspace running/minimized windows, grouped previews, agridyne glass-tile treatment on the app buttons | `docs/plans/GRAND_PLAN.md` §5.1, §5.3 |
| Readable, spacious, clickable top status bar | The top widget bar: independent glass islands (search/bell, workspaces, media, clock/weather, tray, network, Bluetooth, audio, battery, system), ilyamiro composition nearly 1:1 | §5.1 |
| "Cinematic" Hyprlock-style lock screen | Composite lock: agridyne visual direction (glass/negative-space) × Vast depth planes and gated unlock × selected ilyamiro clock/PIN/motion details × iNiR/DMS status pills and safety lifecycle. Hyprlock stays installed as emergency fallback only | §5.10 |
| Dark-glass-themed file manager (was: theme Thunar) | Dolphin (Qt6/KF6), themed from the generated scheme via Kvantum + the Qt writers; Thunar is not the file manager | §5.17 |
| Custom-built wallpaper picker replaced by a real picker (was: Waypaper) | The full skwd-wall application + Rust daemon: shader transitions, library, favorites, animated/video wallpaper support (opt-in, perf-gated) | §4.1 |
| Music/EQ widget (vinyl art, transport, 10-band EQ, cava) | Top media island (ilyamiro composition); click expands into the full Music/EQ surface — large art, seek, transport, 10-band EQ/presets, lyrics | §5.9 |
| Calendar/weather as a rich, structured panel (not "a wall of text") | Top clock/date/weather island and its expansion, not a dashboard drawer | §5.2, §5.4 |
| WiFi panel showing real internet speed, not just signal % | Top network island: live traffic distinct from an explicit WAN speed test | §5.2 |
| Terminal personality (ASCII art / fastfetch on open) | Bonus-roster item (fastfetch art) plus the dedicated `special:sysmon` fetch-card workspace | §11, §5.18 |
| System processes as a real workspace, not a popup | `special:sysmon`: fetch card + btop + sensors + PipeWire xrun, opened by bar CPU/RAM pills or a dedicated bind | §5.18 |

None of these were dropped. Every one graduated from "open ask" to a
plan-owned, sourced surface.

## Primary reference builds — quality bar, now with bounded roles

The original document pointed at these repos as open-ended quality
inspiration ("study before building anything, evaluate 3-5 candidates per
component"). They remain the visual quality bar; what changed is that each
now has a **specific, bounded role** instead of a free-floating "match this"
mandate — see `docs/plans/GRAND_PLAN.md` §2.1 and §13 for the authoritative table.

- **ilyamiro/nixos-configuration** — still the #1 visual reference. Top-bar
  structure and independent widgets, media/EQ, motion/choreography, selected
  lock interaction details, clipboard presentation. The animation-quality
  paragraph in the original doc ("smooth coordinated property animations,
  nothing pops, everything flows, ~1–1.2s choreography on first open") is
  exactly the `morph`/`cinematic` tokens today.
- **agridyne/dotfiles-dt** — glass/negative-space visual direction, rail
  app-button treatment, KDE/Chrome color mapping, visualizer reference, lock
  visual composition. Not the bar's information architecture.
- **caelestia-dots/shell** — no longer just "the sidebar reference": it is
  the shell chassis itself (forked as `aurora-shell`) — plugin, services,
  drawers, launcher, notifications, OSD, session, utilities, window previews,
  and the rail's structural foundation.
- **liixini/skwd-wall** — the complete wallpaper system (§4.1), not a
  component to adapt piecemeal.
- **mubin-thinks/minimal-wm-config** — still the cohesion reference ("does
  the palette really touch everything"); its own fixed-dark-surface policy
  is explicitly not adopted — reference/result only.
- **saatvik333/hyprland-dotfiles, snes19xx/surface-dots** — terminal
  startup/dev-experience and widget-sizing references; not shell or bar
  architecture.
- **cxOrz/dotfiles-hyprland** — selected panel/OSD patterns, not primary
  panel architecture.
- **Harshil-Anuwadia GRUB theme** — still deferred/low priority.

Dropped as source-role owners (see below for why): **elifouts, GlassesArch,
Sharddots** — Waybar geometry/mechanics references, retired along with
Waybar itself; kept only as historical references per `docs/plans/GRAND_PLAN.md` §13.2.

## Screenshot observations — the mood references, preserved

These describe screenshots the user had reacted to during the design phase.
They're mood/atmosphere data, not architecture, and nothing here conflicts
with current ownership — they're kept as-is.

**What was liked across all of them:**
1. Atmospheric wallpapers the whole desktop is built around.
2. Information-dense status bars (CPU temp, RAM, network speed, volume,
   battery, clock, now-playing) that still have room to breathe.
3. Visible music integration — album art, transport, cava-style visualizer.
4. Terminal personality — neofetch/fastfetch color blocks on open, not a
   blank prompt.
5. One color scheme running through bar, terminal, widgets, and wallpaper.
6. Dark palettes with luminous accents — deep blues/purples/teals/cyans; the
   aurora/northern-lights quality (now one named preset, not the default).
7. Functional widget panels — quick settings, notification center, media
   controls, weather, calendar reachable without digging.
8. Clean tiling layouts with real work (editor + terminal + browser + file
   manager together), not "eight empty terminals with neofetch."

**Specific reference builds (why each was liked):**

| Reference | Why liked |
|---|---|
| Cozy music-room Hyprland | Bar layout/spacing, the cozy integrated feel |
| HyDE Arch Linux | Purple-blue color direction, the tiling layout |
| Lofi koi-pond Arch | Music + visualizer integration, the overall vibe |
| Cyberpunk EndeavourOS | How dramatic a single accent reads against near-black |
| NixOS widget dashboard | Sidebar with organized sections; persistent weather/music; notification panel with sliders |
| Lavender Arch music | Audio-visualizer integration, the purple palette |
| Purple mountain multi-workspace | Clean workspace with a large clock, the purple gradient |
| Sunset terminal Fedora | Practical, readable, not over-designed |
| Cyberpunk Kali dual-view | Categorized app tiles, file manager matching the theme, cohesive neon palette |
| AwesomeWM control panels | Functional quick-settings/notification-center/shutdown-screen — every control reachable by mouse |
| KDE Plasma dev setup | Practical dev layout, information-dense bottom bar, clean launcher |

---

## What was dropped, and where it actually lives (no silent deletions)

Per instruction, nothing named here as a real visual requirement was cut —
each row below is either superseded by something *better* (a graduated
answer) or migrated to the document that now owns it.

| Original content | Status | Where it lives now |
|---|---|---|
| Fixed hex palette (`#0a0e1a`–`#131729`, teal/purple accents as *the* system) | **Dropped** — was a fixed dark identity; contradicts wallpaper-derived, mode-switching palette | `docs/plans/GRAND_PLAN.md` §3.1, §4.0 |
| "Matugen should reinforce this palette" | **Dropped** — Matugen is not system-wide authority at all now | §4.0, §13.3 |
| Waybar component ownership (layout/sizing/CSS direction) | **Dropped** — Waybar is retired; superseded by the top widget bar | §2.2 (retired units), §5.1 |
| Rofi component ownership (theme, click-away, layout) | **Dropped** — Rofi is retired; caelestia's own launcher owns this role, with click-away by construction (`HyprlandFocusGrab`), not a ported fix | §2.2, §5.5 |
| Thunar theming ownership | **Dropped** — Thunar isn't the file manager; Dolphin is, themed via Qt6/KF6 + Kvantum | §5.17 |
| Caelestia stock dashboard drawer (calendar/weather/media/performance tabs) | **Dropped as one hub** — retired as a duplicate; its data/services feed independent top-bar expansions instead. Explicitly "a source-role correction, not a loss of functionality" | §5.4 |
| Functional/input bug list (disable_while_typing, scroll sensitivity, border resize, tiling bug, Cmd+Space, drag-by-titlebar, backspace acceleration, Cmd+arrow snapping, Ctrl+T, weather location, CPU/Memory button dupe, EasyEffects visibility, wallpaper-picker location, screenshot overlay) | **Migrated in full** — these are functional/input bugs, not visual design, so this document (now scoped to visual intent) doesn't restate them | `ISSUE_LOG.md`; traced item-by-item in `docs/plans/GRAND_PLAN.md` §15 |
| "Search 3-5 community implementations, view previews before ranking" protocol | **Migrated** — this is now a standing execution rule, not visual-doc content | `docs/prompts/SESSION_PREAMBLE.md`, `docs/instructions/PM_OPERATING_RULES.md` |
| Live/animated wallpaper ask (mpvpaper) | **Upgraded, not dropped** — skwd-wall's own daemon natively plays video/Wallpaper-Engine items; ships as an opt-in behind a performance gate | §4.1 |

---

## Genuine tension a human should look at

One thing in the original document is in real tension with current
authority and isn't a clean "dropped, moved to X" — flagging it rather than
resolving it myself:

- The original doc's Tier-1 framing put **agridyne** and **caelestia-dots/
  shell** on close to equal footing with ilyamiro as "match this quality"
  references, and separately named caelestia as *the* sidebar/dock
  reference. Current authority (`docs/plans/GRAND_PLAN.md` §2.1) is more surgical:
  caelestia owns the rail's *structure* (it's the forked chassis), agridyne
  owns the rail's *visual language* (glass tiles, negative space), and
  neither is described anywhere as matching "quality" in the open-ended way
  the original doc invited. This isn't a contradiction so much as the plan
  having done the arbitration the original doc left open — but if Alex's
  mental image of "the caelestia sidebar quality bar" was closer to
  caelestia's own visual polish than to agridyne's negative-space direction,
  that's worth a sentence of confirmation at the Stage 4/bar gate rather
  than assuming the plan's arbitration matches his original intent.

---

## File locations

- `docs/plans/GRAND_PLAN.md` — design and architecture authority; this document is
  subordinate to it on every point above.
- `docs/plans/MASTER_REQUIREMENTS.md` — the requirements ledger.
- `ISSUE_LOG.md` — the functional bug register (see migration table above).
- `docs/references/SOURCES.md` — community provenance ledger.
- `docs/instructions/controls.md` — current keybinds and mouse paths.
- `docs/instructions/recovery.md` — rollback procedures.
- `docs/instructions/wallpapers.md` — wallpaper library/import notes.
- `docs/archive/superseded-docs/2026-07-29/visual-design-reference.md` — the
  original, unmodified, full version of this document, for provenance.
