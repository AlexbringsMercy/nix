# Aurora desktop — visual component research

Author: Claude Code research pass, 2026-07-16
Companion: `OVERHAUL_PLAN.md` (root causes — accepted as input), `ISSUE_LOG.md`,
`~/Downloads/visual-design-reference.md` (design intent).

> **Read-list correction (2026-07-29).** All three companions above are now
> historical. `OVERHAUL_PLAN.md` and `ISSUE_LOG.md` live in `archive/`
> (`archive/superseded-handoffs/2026-07-28/` and
> `archive/superseded-docs/2026-07-29/`), and ISSUE_LOG's still-live items were
> migrated to `docs/issue-log-migration-2026-07-29.md`. The design-intent document
> is now `visual-design-reference.md` at the repository root, itself subordinate to
> `GRAND_PLAN.md`. This research pass remains valid as dated research; it is not
> current architecture authority.

> **Status: research only.** Nothing on the machine was changed. Every claim below
> is sourced; anything unverified is marked **[UNVERIFIED]**.

---

## 0. How to read this, and what changed vs the last session

**Method.** ~15 agents. Previews were **downloaded and viewed**, not read about. Source was
read from real clones. Where a repo was big, an agent was sent back to read it **in full** —
because the single lesson of this pass is:

> **A partial read produces a confident, well-formed, wrong answer.** That is worse than no
> answer, because it looks finished.

That failure mode recurred **five times** and was caught each time only by going back:

| # | Surface read | Wrong conclusion | Truth after full read |
|---|---|---|---|
| 1 | `caelestia/modules/sidebar/` alone | "just a notification drawer" | It's composed in `Panels.qml` from 3 modules (§1) |
| 2 | grep of `ilyamiro/Floating.qml` | ranked its morph pattern #1 **without opening the file** | pattern is real, but ~15k LOC went unread |
| 3 | matugen `prefer` from first principles | "kills the plan's root fix" | **Wrong — `prefer` is a real lever** (§2) |
| 4 | caelestia launcher README/deps | "needs a C++ SQLite plugin → build our own" | SQLite is **75 lines**, quarantined (§3) |
| 5 | agridyne `panel-layout.png` | read colours off it | **It's an Edit Mode screenshot** — the blue bars are Plasma UI, not design |

**Standing rule for Phase B: never cite a `file:line` you did not read.**

### Reference-repo corrections (supersedes `OVERHAUL_PLAN.md` §2)

| Repo | Prior verdict | Corrected |
|---|---|---|
| **caelestia** | "no dock, sidebar is a notif drawer, opaque by default" | **Two bars — its own UI says so.** Sidebar is a 3-module composite. Opacity is a **runtime one-liner**. §1 |
| **ilyamiro** | "not a glass reference, panels opaque" | Overstated. Bar pills are **alpha 0.75, border 0.08**. It isn't glass because it **never turns blur on** — `layerrule = blur` is applied to `ext-session-lock` **only**. §4 |
| **mubin** | "premise doesn't exist, 1/10" | Premise was never matugen. It's the **proof that cohesion = coverage**, and the control case for gowall. §2 |
| **agridyne** | "never was a usable reference" | Design ref, as briefed. Blur params now extracted. **Login screen genuinely does not exist.** §7 |
| **saatvik333** | "no ASCII art" | **Art exists** — in the nvim dashboard. Also kitty is `0.9`, not `1`; palette is Wallust-derived, not sepia. §8 |
| **surface-dots** | "not a glass model" | Not the question. Its **rofi theme is the best cost/value artifact found**. §4 |
| **skwd-wall** | "daemon fights ours" | **Substantially false** — they read the function, not the call site. §10 |
| **newmanls windows11-list-dark** | "was supposed to be our source" | **It is the source of the bug.** Structurally incapable of fixing it. §4 |

---

## 1. caelestia — architecture (the highest-value structural find)

**Repo:** `caelestia-dots/shell` @ `dbb6d6c` (current HEAD). **GPL-3**. Meta repo
`caelestia-dots/caelestia` is **unlicensed** — the Hypr Lua and Spicetify theme are exactly
the files we legally cannot vendor. Architecture and patterns are safe; QML files are not.

### Two bars — settled, and it's caelestia's own vocabulary

`nexus/pages/PanelsPage.qml:24-44` — the shell's own settings UI:

```
line 25-26:  icon: "dock_to_bottom"   label: "Taskbar"   → Config.bar
line 40-41:  icon: "dock_to_right"    label: "Sidebar"   → Config.sidebar
```

What prior passes called "the bar" is the **Taskbar** (`bar/Bar.qml:126-178` tags every child
`objectName: "taskbar*"`). The **second bar is the Sidebar** — 430px, full-height, right edge,
bound to **SUPER+N** (`caelestia/hypr/variables.lua:100` → `kbShowSidebar`). Symmetric reveal:
taskbar drags from the left edge, sidebar from the right (`Interactions.qml:113-117`, `:134-155`).

**Not orientable.** `barconfig.hpp` (166 lines, read in full) has no `position`/`orientation`/
`edge` key. Vertical-left is hardcoded (`BarWrapper.qml:41-49`, `Exclusions.qml:16`).
→ **Design our own `position` token from day one; caelestia gives us nothing here.**

### The sidebar is a 3-module composite

| Region | Module | LOC | Contents |
|---|---|---|---|
| top-right | `modules/notifications/` | 769 | live popups |
| middle | `modules/sidebar/` | 1273 | notif dock, groups, actions |
| bottom-right | `modules/utilities/` | **1522** | idle inhibit, **screen recorder**, quick toggles |

Wired by one line — `utilities/Wrapper.qml:27`: `shouldBeActive: screenState.sidebar || ...`.
They lerp widths together and cross-fade corner radii (`ContentWindow.qml:200-232`) so they
**weld into one seamless panel**.

**Why every agent missed it: across all 25 video frames, the sidebar never appears.** The only
preview is a **13-month-stale** video (June 2025). No current screenshots exist anywhere.

### ★ The idea worth taking: one window, N surfaces, one blur

Only **four** layer-shell roots exist (`shell.qml:29-34`). Every panel — bar, OSD,
notifications, session, launcher, dashboard, utilities, toasts, sidebar — is an `Item` inside
**one fullscreen layer window** (`ContentWindow.qml:68-78`, namespace `caelestia-drawers`),
with exclusive zones delegated to **four separate 1×1 dummy windows** (`Exclusions.qml:15-30`).

**One namespace = one blur target. N surfaces → 1 blur pass.** On a dual-core i3 / Iris Plus
that is the difference between affordable and not.

Also take: `ScreenState.qml:6-13` (flat bool set) + `Variants` over screens (`Drawers.qml:7-8`)
+ IPC `toggle(drawer)`/`list()`/`isOpen()` (`Shortcuts.qml:111-135`) — scriptable from Lua.

### **CONTESTED — do not act on without a test**

Two agents disagree on `plugin/src/Caelestia/Blobs/` (`blobshape.cpp`, `blob.frag` 12KB):
- Agent A: "GPU metaball system, batched into **one draw call**" → it *is* our diffuse-aurora spec.
- Agent B (read the composition root): "**per-frame SDF + deform matrices** on every panel, over
  a fullscreen layer, plus `MultiEffect` shadow `blurMax:15`. Wrong trade on Iris Plus. The blob
  welding exists to justify the blob engine."

**Unresolved.** Cheap to settle in Phase B: render it and measure frame time. Do not build the
aurora on it until then — §4 has a proven-cheap alternative.

### Other caelestia facts
- `appearance.transparency = { enabled: false, base: 0.85 }` (`appearanceconfig.hpp:298-300`) is
  **runtime-configurable** via `~/.config/caelestia/shell.json`. `base: 0.6` hits our spec with
  zero recompilation. This was never a reason to reject it.
- **No Spotify integration.** Zero hits for `spot` in the shell tree. It's generic MPRIS
  (`services/Players.qml:14-15`). The Spotify theming is a **separate Spicetify theme** + a fish
  inotify watcher, in the unlicensed meta repo. The showcase player is **Feishin**.
- **No dock** anywhere in the org (verified repo-wide).
- **Nexus** — a 48-file / 7497-LOC settings app in a `FloatingWindow`, undocumented, post-dates
  the video. Skip.
- Fonts: GoogleSansFlex + Rubik. Sizes 11/12/13/15/18/28 — **this table is literally our
  "text too small" complaint**. Their `appearance.font.scale` multiplier is the right fix shape.

---

## 2. Palette architecture — supersedes `OVERHAUL_PLAN.md` §5.1

### ★ The headline: cohesion is **coverage**, not extraction

All three "cohesive" references constrain the palette and force the wallpaper to comply.
**Two of the three literally recolor the wallpaper into the theme.**

| Repo | Palette source | Wallpaper |
|---|---|---|
| mubin | hand-written static, 4 themes | **gowall** recolors wallpaper → theme |
| nathanhoulamy | stock **Gruvbox** | **wallrice.xyz** colorizes wallpaper → theme |
| SherLock707 | hellwal, **surfaces pinned** | untouched; surfaces never move |

**The control case (viewed).** mubin's *same theme*, two showcases: the **dark** one has a
conformed wallpaper → reads as one designed system. The **light** one's wallpaper carries teal
the cream palette never picks up → reads as "a theme on top of a photo." Same configs, same
completeness. **Wallpaper conformance is the only variable.**

**No tool can bias extraction toward a hue family.** Verified: not matugen, not hellwal
(`hellwal.c:474-496` — no hue flag exists), not wallust. The criterion eliminates the category.

**Proof hellwal doesn't save us (viewed):** SherLock707's `home2.png` ≈ our aurora spec; but
`home1.png` (pink wallpaper) → **the whole palette goes pink**; `home3.png` → lavender. Its
cohesion survives because **all ~19 surfaces move together**, not because extraction is better.

### matugen `prefer` — SETTLED, and the plan item SURVIVES

An agent argued from first principles that `prefer` was the wrong intervention. It then **read
matugen's source and reversed itself**. The mechanism claim was right; the conclusion was wrong.

- `src/color/color.rs:199-260` — `get_source_color_from_image` returns **one** `Argb`.
- `color.rs:281-300` — `ClosestToFallback` does Lab-distance `min_by` over image-extracted candidates.
- `scheme.rs:173-183` — the scheme takes that single colour; the **+60° tertiary rotation lives
  downstream** in the `material_colors` crate, untouched by `prefer`.

**But tertiary derives *from* the source hue.** Biasing source → teal (~175°) moves tertiary to
~235° (blue), not ~300° (pink). **`prefer` is a real lever.** Its limits: it can only select a
colour already present in the wallpaper, and it does nothing about tone-80 pastels (that's
`set_lightness: 58`, an orthogonal fix).

### ★ The mechanism we were missing: `custom_colors` with `blend: false`

`src/scheme.rs:100-150`, `make_custom_color` — emits **your exact hex, untouched by M3**. This
is the deterministic way to force `#00d4aa`/`#7c3aed`/`#34d399`.

> Note `OVERHAUL_PLAN.md` §5.1 declared `blend = false` "DEAD" — but tested it on the **source
> colour**, not on `custom_colors`. Different mechanism. **[UNVERIFIED on our 4.0.0 — test first.]**

### Recommended architecture

1. **Coverage first, on matugen 4.0.** Template every surface (§2.1). Zero literals. This is the
   actual #1 failure, it is extractor-agnostic, and the work transfers.
2. **Pin surfaces centrally, constrain accents.** Surfaces from a fixed `#0a0e1a`→`#131729` ramp,
   never from the extractor. This is SherLock707's `--static-background`/`--static-foreground`
   idea (`ThemeEngine.sh:30-32`) — adopt the **pattern**, not hellwal.
   Our bug is the same pinning with opposite intent: we pin surfaces *accidentally, per-file*,
   so nothing recolors; he pins them *once, in the generator*, so everything recolors together.
3. **`prefer` for the derived ramp + `custom_colors {blend:false}` for guaranteed accents.**
4. **Add a `theme-only` escape hatch** — a lever we don't have. When a wallpaper produces
   garbage, drop to a static palette.
5. **gowall** the wallpapers at build time (§11).

### ★ ilyamiro's resolution of the fixed-vs-adaptive tension

Their widgets **never name a Material role** — they say `mocha.mauve`. The template is the only
place M3 roles appear. So this is a **one-file edit**:

```json
{ "base": "#0a0e1a", "mantle": "#0e1220", "crust": "#131729",
  "text": "#e2e8f0", "subtext0": "#94a3b8",
  "blue": "#0ea5e9", "teal": "#00d4aa", "mauve": "#7c3aed", "green": "#34d399",
  "accent": "{{colors.primary.default.hex}}"   ← the ONLY wallpaper-derived value
}
```

Use `accent` **solely** for the ambient blobs and gradient rings. **The wallpaper tints the
light, never the glass.** Aurora shifts hue with the wallpaper; the frosted window stays cold
and blue. Satisfies "everything recolors" *and* the fixed-palette spec.

### 2.1 The universal-theming surface checklist

Derived from SherLock707's fan-out. **~19 surfaces; 8+ are not config files at all** — they're
SVG rewrites, gsettings cycles, and per-app scripts. *That* is why our palette is half-applied.

**Tier 1 — compositor/shell:** window border focused/unfocused/urgent · titlebar · desktop
fallback solid colour · lock screen · compositor notify toasts
**Tier 2 — bar/widgets:** bar bg · bar border · module chip bg/border/fg · workspace
inactive/focused/urgent · battery warning/critical · tray tint · notification daemon · cava gradient
**Tier 3 — terminal:** bg/fg · **all 16 ANSI** · cursor · **live recolour of open terminals**
**Tier 4 — launcher:** bg · border · text · prompt · input · selection · blurred backdrop
**Tier 5 — GTK/Qt/files:** GTK3 colors.css · GTK4 colors.css+gtk-dark.css · Kvantum · Qt accent ·
file-manager palette · **folder icon SVG recolour** (the most-skipped surface) · icon accent ·
GTK hot-reload kick
**Tier 6 — browser (the confirmed nine):** Toolbar · Background · Search Bar · Tab Highlight ·
Popup Text · Toolbar Icons and Text · Background Tab Text · Search Text · Popup Background
**Tier 7 — apps:** editor · notes · mpv · btop · fastfetch · shell prompt · QuickShell palette

**mubin's anti-pink discipline, worth stealing:** his Alacritty theme **collapses ANSI onto the
ramp** — `red = green = cyan = #8c734e`. It refuses to let ANSI smuggle in hues the theme
doesn't own. Our terminals currently can.

**The nine browser surfaces (mubin `wiki.md`, Charcoal Monochrome Dark):**
```
Toolbar #1b140a · Background #120e08 · Search Bar #2a2012 · Tab Highlight #8c734e
Popup Text #d1b994 · Toolbar Icons/Text #d1b994 · Background Tab Text #b3976d
Search Text #d1b994 · Popup Background #120e08
```
Note `#1b140a` and `#2a2012` appear **nowhere else** — hand-mixed elevation tones. A real theme
needs more surface tones than 16 ANSI slots provide.

---

## 3. App Launcher

**Design intent:** Raycast-quality. Dark glass 55–65% over blurred wallpaper. Icons + names.
Top search. Clean list, **no alternating rows**. **Click-away dismiss.** Super+Space and a
Waybar button.

**Established:** Rofi 2.0.0's Wayland backend has **zero** `click-to-exit` references — the fix
(PR #2272) merged to `next` 2026-03-20 and is **unreleased**. Rofi cannot click-away, period.

### Candidates

| Name | Toolkit | Click-away (from source) | Theming | nixpkgs | License | LOC |
|---|---|---|---|---|---|---|
| **caelestia launcher** | QuickShell QML | **YES** — `HyprlandFocusGrab`, `modules/drawers/ContentWindow.qml:112`, `onCleared:127` | M3 schemes | ✗ (own flake, `homeManagerModules`) | GPL-3 | **1623** |
| **walker** | GTK4/Rust, service | **YES — the only *literal* one**: `click_to_close = true  # closes walker if clicking outside of the main content area` | GTK CSS | **✓ 2.16.2** + both modules | **MIT** | large |
| **vicinae** | C++/Qt layer-shell, daemon | YES but **focus-loss**: `m_closeOnFocusLoss`, `navigation-controller.cpp:342` | own JSON themes | **✓ 0.22.3** + both modules | GPL-3 | large |
| ilyamiro launcher | QuickShell QML | **NO** — shells out to `qs_manager.sh` on Escape | matugen | ✗ | **none** | **559** |
| DankMaterialShell | QuickShell QML | YES — `HyprlandFocusGrab` | **native matugen templates** | ✗ (own flake) | see repo | **9126** (586 `Theme.` refs) |
| end-4 | QuickShell QML | YES — `services/GlobalFocusGrab.qml` (**72 LOC**) | matugen | ✗ **no flake** | GPL-3 | 363 (search only) |
| fuzzel | C | **focus-loss only** (`doc/fuzzel.1.scd:413-422`) | ini | ✓ 1.14.1 | — | — |
| anyrun | GTK4/Rust | `close_on_click`, **default false** (`config.rs:145`) | `res/style.css` | ✓ 26.6.1 | GPL | 4604 |
| noctalia | **C++/meson, 0 QML** | — | — | ✓ 4.7.7 | MIT | — |
| surface-dots drawer | QuickShell QML | **NO** — zero `HyprlandFocusGrab` | — | ✗ | **none** | 1492 |
| cxOrz | **Rofi** | inherits Rofi's failure | — | ✗ | MIT | — |

**⚠ Packaging trap:** nixpkgs `sherlock` is a **different project** (OSINT username hunter). The
launcher is **`sherlock-launcher`**.

### Recommendation: **adapt `caelestia/modules/launcher/` (1623 LOC)**

The last session's blocker collapses under measurement. **The entire SQLite dependency is one
75-line file** — `modules/launcher/services/Apps.qml`, `AppDb {}` at line 68. The schema is a
single `id → frequency` table, `:memory:`. The app list already comes from QuickShell's
`DesktopEntries`. Excising it is a ~75-line rewrite that also **drops the whole C++ `plugin/`
build**. GPL-3 is a licensing decision, not an impossibility.

**Why it wins:** QuickShell is already resident → opens instantly, no fork-per-invocation on a
dual-core i3. `hyprland_focus_grab_v1` already works in 7 of our panels. You inherit fuzzy
search, calc, actions, icons, animations. Ships `homeManagerModules`.

**Honest verb: "adapt heavily."** It's coupled to the drawer/grab architecture and M3 scheme
system. Expect **400–600 LOC touched**. But the from-scratch estimate (200–350) is optimistic
against measured reality: end-4 needs **363 LOC for search alone**; surface-dots' drawer is 1492.

**Runner-up: walker.** MIT, in nixpkgs, real click-away, service mode. Cost stated plainly: it's
**ugly out of the box** — flat opaque panel, mint border — and needs a full retheme. It is not
pretty; it is *correct*.

### What to change
- Excise `AppDb` (75 LOC) → `DesktopEntries.applications`, `DesktopEntry.icon/execString/execute()`,
  `Quickshell.iconPath()`. Drops the C++ plugin.
- Click-away: lift into our own drawer wrapper, **or** graft end-4's `GlobalFocusGrab.qml` (72 LOC,
  the single most liftable file found).
- Colours: panel `#0f1420` @ **0.60**, border `1px rgba(255,255,255,0.10)`, radius 12, accents
  `#00d4aa`/`#38bdf8`, text `#e2e8f0`/`#94a3b8`, Inter.
- Triggers: one state property, two callers (Hyprland bind + Waybar `on-click` → `qs ipc`).

### ★ Lift from ilyamiro's launcher regardless (559 LOC, read in full)
- **Smart model diffing** (`:89-146`) — removes non-matches in reverse, then `move()`/`insert()`
  to reconcile in place instead of `clear()`+refill. **Without this, every ListView `add`/
  `remove`/`displaced` transition is dead code.** The non-obvious keystone.
- **Two-speed morphing highlight** (`:403-453`) — top and bottom edges animate at *different*
  speeds by direction (leading 250ms / trailing 450ms) so the pill **stretches then settles**.
  ~20 lines, `OutExpo` only. Gated `enabled: window.isKeyboardNav` — lag is wanted for keyboard
  nav, wrong when the list re-sorts under you.
- **Container shrink-to-fit** (`:198-218`) — `targetX` → `animatedX` (carries the Behavior) →
  `height` is the sum. Capped at 8 rows, collapses to a bare search bar. 15 lines. Raycast behaviour.
- **Icon tint matte** (`:499-523`) — accent overlay at **0.08 idle / 0.25 selected** over each
  icon. *This is the trick that makes a grab-bag of app icons read as one designed set.*
- Its weakness: search is plain substring `.includes()` on Name only. ~40 LOC to replace.

**From user's references:** snes19xx's "nice and modern" launcher is **Rofi** — see §4. Its
QuickShell `WideDrawer` (1492 LOC) has no focus grab and no license.

---

## 4. Rofi theme (fallback) + the launcher aesthetic

### ★ The theme our build was *supposed* to use is the source of the bug

**All 25 `newmanls/rofi-themes-collection` themes are incomplete.** Not one sets
`background-color` on `element normal` or `element alternate`. They rely on
`* { background-color: transparent; }`, which **loses on specificity** to Rofi's built-in
`element alternate.normal`. No theme in the repo uses `@theme`.

So `windows11-list-dark` would produce our exact alternating pink/beige rows. **It was never
capable of fixing this.** It's also 2-column, bottom-anchored, `#202020bf` (75%, above our band,
neutral gray, no blue undertone), Roboto 10.

Also: **`newmanls` and `lr-tech` are the same repo** — byte-for-byte identical, same HEAD.

### Candidates

| Theme | Complete (9 states)? | Genuine alpha | License | Look (VIEWED) |
|---|---|---|---|---|
| **adi1090x `type-1/style-6`** | **YES 9/9** | no (injectable) | GPL-3 | 800px centered, top search, 4 pill mode-switcher, 1-col icon list, **uniform rows** |
| adi1090x `type-1/style-5` | YES 9/9 | no | GPL-3 | same, mode-switcher inline — more Raycast-like |
| adi1090x `type-4/style-5` | YES 9/9 | no | GPL-3 | **visible row banding by design** — reject |
| **surface-dots `style-dark.rasi`** | — | `#a7c08070` hairline | **none** | **image-header + pill search + circular mode buttons** |
| Sharddots `nexus-glass` | **NO 0/9** | **yes** | **none** | not viewed |
| newmanls (all 25) | **NO 0/9** | partial | GPL-3 | reject — see above |
| GlassesArch | NO | yes | GPL-3 | **white** glass — inverted |

**adi1090x splits sharply: type-1 and type-4 are complete; type-2/3/5/6/7 are incomplete** and
would reproduce our bug.

### Recommendation: **adi1090x `type-1/style-6`**, restyled with surface-dots' image-header idea

Only candidate that is complete, single-column, icon-bearing, top-search, non-alternating, with
a clean 6-var matugen surface (`shared/colors.rasi`).

**Take from surface-dots (reimplement — no license; it's ~200 lines, ~1h either way):** the
**image-backed header** (`inputbar { padding: 40px 20px; background-image: url("jellyfish.jpg", width); }`
— the padding *is* what makes the photo banner), the **pill search** (`radius: 100%`) floating on
it, **circular mode pills**, gradient selection with a 1px accent border, `fzf` sorting. Its
`border-color #a7c08070` = a 1px hairline at 44% alpha — already our treatment.

### ⚠ What to change — the double-composite trap

adi1090x maps `normal-background: var(background)`. If `background` is 60% translucent, **every
row composites 60% on top of the window's 60% → ~84% effective, double-darkened, wallpaper
killed.** Rows must be **explicitly transparent** — explicit (so the theme stays complete) but
transparent (so the window's single alpha layer does all the work):

```rasi
normal-background:           #00000000;   /* explicit, NOT inherited → kills the pink/beige bug */
alternate-normal-background: #00000000;   /* identical → no alternation, ever */
selected-normal-background:  #00d4aa40;   /* teal @ 25% */
```
Belt-and-braces: `@theme "/dev/null"` as line 1. **Both, not either.**

| Property | Value |
|---|---|
| window bg / radius / border | `#0f142099` (60%) / `12px` / `1px solid #ffffff1a` |
| element radius / padding / icon | `10px` / `10px 14px` / **28px** |
| font | **Inter 11** (from JetBrains Mono 9 — fixes "too small") |
| listview | `columns: 1`, `lines: 8`, `spacing: 6px` |
| width | `760px` (45% of 1707) |
| `config.rasi:18` | `icon-theme: "Papirus-Dark"` |

Alpha hex: 55%=`8C` · **60%=`99`** · 65%=`A6` · 25%=`40` · 10%=`1A`

---

## 5. Waybar

**Design intent:** 40px, glass, readable, media controls actually clickable.

### Candidates

| Theme | `opacity:` antipattern | Genuine alpha | Gradients | Font | License | Look (VIEWED) |
|---|---|---|---|---|---|---|
| **elifouts/Dotfiles** | **0 — clean** | **`alpha(@background,.6)`** | none | **15px** | GPL-3 | 3 floating islands, **wallpaper clearly visible through** — proof .6 works |
| **cxOrz** | **0 — clean** | **`alpha()` ×17** | none | 14px | **MIT** | bottom bar, pill modules |
| ML4W-Glass-3d | **5 — present** | `alpha()` ×12 | **radial ×5** ✅ | 14px | GPL-3 | aurora arc `circle at 50% 250%` |
| GlassesArch | 0 | rgba + alpha() | **linear — BANNED** | 15px | GPL-3 | **white** glass, h=53 |
| Sharddots `glass` | **many** | gray rgba | none | 12px | **none** | gray; CSS unusable |
| NewbieSaibot/waybar-glass | 0 | none | **linear ×24** | — | MIT | **opaque** — reject |
| snes19xx | 0 | **none — opaque** | none | 13px | none | 3D bevel, radius 0 |
| **mubin** | 0 | none | none | 14px | MIT | **SWAY, not Hyprland** — dead |
| **nathanhoulamy** | — | — | — | — | none | **NO WAYBAR AT ALL** (sketchybar) — dead |

**All 50 LinuxBeginnings themes use `opacity:`** (1–21 each) and every one is 14px. Only
ML4W-Glass{,-3d} use `alpha()`/`radial-gradient`. LB's `layerrule = blur, waybar` is **confirmed
commented out** — the literal last line of `configs/LayerRules.conf`.

### Recommendation: the blend
- **elifouts** — `window#waybar { all: unset; }` + three `.modules-*` islands @ `alpha(@bg, 0.60)`
- **cxOrz (MIT)** — the alpha ramp: `0.06` border → `0.08` pill → **`0.12` hover (+0.04)**,
  brightness-only. Closest thing to our hover spec in the field.
- **GlassesArch** — pill geometry `4px 14px`, radius 15, font 15
- **ML4W-Glass-3d** — the radial technique, **opacity stripped**
- **Sharddots** — blur *parameters only* (numeric config, not copyrightable — sidesteps its
  missing license). It's the only repo with waybar blur actually enabled.

**Runner-up: cxOrz wholesale** — single-file, MIT, zero antipatterns, `alpha()`-native. Cheapest
path to correct; loses the aurora.

### ★ Three things the field cannot give us
1. **`min-width`/`min-height` on modules appears in ZERO of ~60 themes.** ML4W styles `#mpris`
   identically to `#network` — **as a text label, not a button.** *This is why our media controls
   are unusably small, and no candidate solves it. The fix is necessarily bespoke.*
2. **`shade()` appears in ZERO themes.** Our "hover = brightness" spec is correct per GTK3 but has
   **no community precedent** — every candidate changes hue, which our spec bans.
3. Community transitions are 0.3–0.5s; our 100ms is a deliberate departure.

### Geometry @ 1707×1067

| Property | Value |
|---|---|
| Bar height | **40** |
| `window#waybar` | `all: unset; background: transparent;` |
| Island bg / border / radius | `alpha(#0f1420, 0.60)` / `1px solid alpha(@foreground, 0.10)` / `12px` |
| Island margin / padding | `4px 12px` (→32px island) / `2px 6px` |
| Font | Inter — **14 base / 15 clock / 16 glyphs** |
| Module padding | **`4px 12px`** |
| **Media button** | **`min-width: 34px; min-height: 28px; padding: 4px 8px; font-size: 16px; radius: 8px`** — bespoke |
| Workspace button | `min-width: 32px; min-height: 28px; radius: 8px; margin: 0 2px` |
| Hover | `shade(alpha(@background,0.60), 1.15); transition: background 100ms ease-out;` |

**Aurora (ML4W technique, opacity stripped — multi-layer confirmed working in GTK3):**
```css
.modules-left, .modules-center, .modules-right {
  background:
    radial-gradient(circle at 20% 260%, alpha(#7c3aed, 0.18), alpha(#0f1420, 0.0) 60%),
    radial-gradient(circle at 80% 240%, alpha(#00d4aa, 0.15), alpha(#0f1420, 0.0) 60%),
    alpha(#0f1420, 0.60);
}
```
The ~250% Y-centre puts the blob origin below the bar → only a wide diffuse arc renders.
**[UNVERIFIED: syntax confirmed for GTK3; appearance at 1.5x not tested.]**

### Width budget — fits, 245px headroom
left 554 (5 ws + capped taskbar) · center 192 · right 672 · margins 44 → **1462/1707 = 85.6%**.
**`wlr/taskbar` cap is mandatory:** with titles at ~8 apps it reaches ~1360px alone. Set
`"format": "{icon}"`, `"icon-size": 20`, cap 10 → bounded at 356px.

### ★ Compatibility
- **LinuxBeginnings ships `config/hypr/lua/layer_rules.lua`** — real, working native-Lua
  `hl.layer_rule` for Hyprland 0.55. **The single most valuable artifact for our platform.**
- **`ignore_alpha = 0.15` for Waybar, not 0.10.** With a transparent `window#waybar` and floating
  islands, a lower value **blurs the entire bar rectangle including the gaps between islands** →
  visible blur slabs in empty space. Sweep both in the Stage-B0 `hyprctl eval` test.
- **⚠ Hyprland 0.55 layerrule syntax** — the old form is a **parse error**:
  `layerrule = [ "blur true, match:namespace ^(quickshell)$" ]`. And `quickshell` is only the
  *default* namespace; ours is `aurora-*`. Check `hyprctl layers`.
- `custom/` workspace modules need `"return-type": "json"` emitting a `"class"` field → Waybar
  applies `#custom-ws1.active`. **Without JSON return-type there is no way to style active state.**
- Licensing: adi1090x/elifouts/LB/GlassesArch are **GPL-3**; cxOrz and waybar-glass are **MIT**;
  Sharddots has **no license** — take only its numeric blur params.

---

## 6. QuickShell panel styling

### ★ "No community shell matches the aesthetic" is **factually refuted**

**`snowarch/iNiR`** — 1280★, **MIT**, v2.27.0, pushed 2026-07-16, ~210k LOC QML, **ships a flake**.

```qml
// modules/common/Config.qml:432
property string globalStyle: "material" // "material" | "cards" | "aurora" | "inir" | "angel"
// modules/common/Appearance.qml:76
readonly property bool auroraEverywhere: globalStyle === "aurora" || globalStyle === "angel"
```

`aurora` and `angel` are **purpose-built non-Material glass styles** — `angel` is commented
in-source as *"flagship neo-brutalism glass style (superset of aurora)"*. Material is the
**default**, not the architecture. There's a live GUI tuner: `AuroraStyleEditor.qml`, *"Aurora
Glass — Live Preview"*, presets Default/Frosted/Clear/Subtle.

**Real translucency (VIEWED):** wallpaper clouds visible through the bar and music card, with
film grain. Mechanism — `modules/common/widgets/GlassBackground.qml` (~113 lines, self-contained):
panel goes `color: "transparent"`, draws the wallpaper offset `-screenX/-screenY`, blurs via
`MultiEffect{blurMax:64}`, desaturates, tints, `OpacityMask` to the radius.

**⚠ Note:** that's a wallpaper-backdrop *self-blur*, not compositor blur. `OVERHAUL_PLAN` §5.2(e)
rejects that approach in favour of `xray` — which gives **the same aesthetic** (always wallpaper,
never windows) from a cached framebuffer. **Take iNiR's tokens and palette; keep `xray` for the
blur.** That drops their one perf liability.

### The field searched (auditable)
~70 shells enumerated via GitHub API (`q=quickshell` = 1623 repos, 3 pages), `topic:quickshell`,
plus glass/blur/niri/astal/ags variants. Screenshots **viewed**: nucleus×2, ambxst×2, vast,
skwd, iNiR×2 + 2 README assets, tide_cc2.

| Name | Translucent? | M3? | License | Look (VIEWED) |
|---|---|---|---|---|
| **snowarch/iNiR** | **YES — real self-blur** | **No — aurora/angel are non-M3** | **MIT** | translucent grainy bar + floating music card, wallpaper visible. **Closest by a wide margin.** |
| Axenide/Ambxst | No — opaque | custom | AGPL-3 | **best layout**: horizontal control center = music ‖ toggles ‖ calendar ‖ notifications |
| nucleus-hq | No — opaque `#0d0d0d` | flat dark | GPL-3 | near-opaque black cards, monospace |
| enhaoswen/Tide-island | No | iOS-style | GPL-3 | iOS Control Center clone |
| noctalia | **[UNVERIFIED — no raw image URLs in README]** | — | MIT | — |

### Exact values to copy

**Aurora transparency presets** (`AuroraStyleEditor.qml:85-99`) — these are *transparentize*
amounts, so opacity = 1−value:
```
default : overlay 0.30  subSurface 0.42  popup 0.32  tooltip 0.28  layer 0.32
frosted : overlay 0.25  subSurface 0.35  popup 0.30  tooltip 0.25  layer 0.28
clear   : overlay 0.60  subSurface 0.72  popup 0.58  tooltip 0.45  layer 0.60
subtle  : overlay 0.18  subSurface 0.28  popup 0.22  tooltip 0.18  layer 0.20
```
**`subSurface: 0.42` → 58% opacity — dead centre of our band.** Use `overlay: 0.40` (60%) for the
panel; default 0.30 (70%) is too solid.

**Angel glass** (`Appearance.qml:770-912`): `panel 0.28`, `card 0.40` (=60% ✓), `popup 0.28`;
blur `intensity 0.35`, `saturation 0.20`, `overlayOpacity 0.45`, **`noiseOpacity 0.15`**,
**`vignetteStrength 0.4`**; `borderWidth 1.5`, `cardBorderWidth 1`, `cardBorderOpacity 0.30`;
**rounding small 10 / normal 15 / large 25** → `small=10` exact, `normal` 15→**14**.

**Fonts** (`Appearance.qml:387-430`): 10/12/13/15/**16**/17/19/22 × `fontSizeScale`. Already above
our floor. Angel forces `"Oxanium"` + `"Rubik"` → **swap both to Inter**.

**Motion** (`Appearance.qml:454-530`) — maps onto our spec directly:
```
elementMoveEnter 400ms  emphasizedDecel [0.05,0.7,0.1,1,1,1]
elementMoveExit  200ms  emphasizedAccel [0.3,0,0.8,0.15,1,1]
expressiveFastSpatial    350ms [0.42,1.67,0.21,0.90,1,1]
expressiveDefaultSpatial 500ms [0.38,1.21,0.22,1.00,1,1]   ← 1.21 = deliberate overshoot
expressiveDefaultEffects 200ms [0.34,0.80,0.34,1.00,1,1]   ← no overshoot; use for opacity
```
Panel open 200–300 → `expressiveEffects` 200ms. Morph 400–600 → `expressiveDefaultSpatial` 500ms.

### ★ The palette slot already exists

`ThemePresets.qml` has `angelColors` as a **hand-authored fixed palette** — bypassing matugen
entirely. Precedent: a `tokyo-night` preset described *"Neon city lights on midnight blue."*

```
angelColors: m3background "#08070a", surfaceContainerLow "#0c0b0f",
  surfaceContainer "#121016", onSurface "#e6dfd6", outlineVariant "#3a3440", m3primary "#e8b882"
```
**Ours:** `m3background #0a0e1a`, `surfaceContainerLow #0f1320`, `surfaceContainer #131729`,
`onSurface #e2e8f0`, `onSurfaceVariant #94a3b8`, `outlineVariant rgba(255,255,255,0.10)`,
`m3primary #00d4aa`, `m3secondary #38bdf8`, `m3tertiary #7c3aed`.

**This converges with §2:** the theming research concluded every cohesive rice pins the palette
by hand — and iNiR already has that slot built. **A ~40-line preset swap, not a build.**

**Hit targets are our gap:** `PlayerControl.qml` play `40` (L443) → **56**; prev/next `32`
(L418/L472) → **40**.

**Perf:** `GlassBackground.qml:75` gates `layer.enabled` on `visible` — releases the FBO
(~16 MiB/instance) when hidden. **⚠ Its comment references a `BlurredWallpaperProvider` singleton
that does not exist in the tree — the comment is stale; each instance blurs its own copy.**

**Caveats:** iNiR is **Niri-first**; the README says its Hyprland code is inherited-from-end-4
legacy the author doesn't test. Irrelevant for skin-mining (`Appearance.qml`/`GlassBackground.qml`
are compositor-agnostic); **decisive against adopting the shell whole.** QuickShell version
unpinned — **[UNVERIFIED: 0.3.0 compat]**.

**Aurora blobs are NOT in iNiR** — its "aurora" means glass, not gradient blobs. See §7 for those.

### From cxOrz (MIT) — take the backends, not the skin
`Theme.qml` (181 LOC): `hoverOverlay rgba(1,1,1,0.08)` = **exactly our border spec**;
`animDuration 200`/`Fast 120` = our spec. But `panelBg` is **fully opaque** (only the shelf has
alpha, 0.85), and `panelRadius 24`/`tileRadius 20` are well outside our 10–14.

| Take | File | LOC | Why |
|---|---|---|---|
| 1 | `controlcenter/VolumeSection.qml` | **118** | **native `Quickshell.Services.Pipewire`** — cleanest file in the repo, near drop-in |
| 2 | `notifications/NotificationService.qml` | 118 | native `NotificationServer`; **strip `_killDunst` (:56) and `_waybarProc` (:62)** |
| 3 | `controlcenter/WifiSection.qml` | 656 | take the `nmcli` process/parse layer, discard UI |
| 4 | `controlcenter/BluetoothSection.qml` | 884 | take the `bluetoothctl` state machine, discard UI |
| 5 | `controlcenter/BrightnessSection.qml` | 126 | Volume's sibling |

**⚠ SECURITY BUG to fix on lift:** `WifiSection.qml:198` —
`["nmcli","dev","wifi","connect",ssid,"password",password]` puts the **PSK in argv**, readable
by any local process via `/proc/<pid>/cmdline`. Use `nmcli --ask` with stdin, or a connection profile.

**Verdict on the brief's "functional foundation, styled to match our glass specs":** still right,
and it **undersold** the visual gap. cxOrz is fully opaque, Chrome-OS shelf, Material-You —
precisely the "Android-ish" the brief rejects. Structure and backends are sound; the surface is ours.

---

## 7. Motion, aurora, and the glass mechanism (ilyamiro + agridyne)

### ★ ilyamiro isn't glass because it never turns blur on

`config/sessions/hyprland/config/rules.conf:12-13` — the **entire** blur config in that repo:
```
layerrule = blur, ext-session-lock
layerrule = ignorealpha 0.2, ext-session-lock
```
**Blur is applied to exactly one layer: the lock screen.** Not the bar, not the popups. Their
global `decoration:blur { size=8; passes=2 }` only affects windows. So the bar sits at
**alpha 0.75** (`TopBar.qml:582,770,904,1048,1148,1243,1511`, border `rgba(text, 0.05–0.15)`)
compositing over the **raw, unblurred wallpaper** — busy and low-contrast.

**We have working blur and opaque panels; ilyamiro has translucent panels and no blur.** Both
fail for opposite reasons. **Our spec is one `layerrule = blur` + `ignore_alpha` away from
something the #1 reference build never attempted.** Highest aesthetic ROI in this report.

### Zero beziers — and it doesn't matter

`easing.bezierCurve` = **0 occurrences** across 32,221 LOC. Census (n≈723): `OutExpo` **220** ·
`OutBack` **109** (with explicit `overshoot` 0.8–1.5) · `OutQuint` 85 · `InOutSine` 79 ·
`OutQuart` 74 · `OutCubic` 55. `states`/`Transition` essentially unused (**4 States in 32k LOC**).

`OutExpo` at 400–800ms *is* a near-perfect decelerate-and-settle. **Our §5.8a bezier work is
optional polish, not the mechanism.** The fluidity is choreography:

- **Single-driver progress morph** — `Floating.qml:248-263`. One animated `real` 0→1, every
  dependent geometry a **pure arithmetic binding** — nothing can desync. `Behavior { enabled:
  !disableAnim }` kills it during drags. **Adopt as the house pattern.**
  **[⚠ The agent that reported this had grepped, not opened, the file. Verify before building.]**
- **Two-speed edges** (§3) — the liquid trick.
- **Staged orchestration** — `MusicPopup.qml:140-186`: 8 properties, one `ParallelAnimation`,
  `PauseAnimation` offsets, **80ms stagger, ~760–860ms each, ~1.36s total**, each element entering
  from its own direction. **~2.5× slower than our 200–300ms budget — compress to 40ms stagger,
  260–320ms/element.**
- **De-synchronised durations on one gesture** — `Lock.qml:342-344`: offset 600ms/OutExpo,
  opacity 400ms/OutCubic, scale 500ms/OutBack. Three curves, one transition. Cheap; very effective.
- `visible: opacity > 0.01` drops faded nodes from the scene graph.

### ★★ The aurora recipe — already written, and nearly free

`Lock.qml:250-289` / `MusicPopup.qml:483-514`:
- **One 90-second global clock**: `NumberAnimation on globalOrbitAngle { from: 0; to: Math.PI*2;
  duration: 90000; loops: Animation.Infinite }`. Every blob reads `Math.cos(angle * k)` with a
  different `k` (×1.5, ×2, ×5, ×6) and sin/cos swaps → **incommensurate, never visibly loops**.
  One animation, N blobs, below the threshold of conscious notice. **4 lines.**
- Blobs: `width: parent.width * 0.8; radius: width/2`, **opacity 0.08 playing / 0.04 paused**,
  `scale: 1.0 ± 0.05` breathing on a faster harmonic, `Behavior on color { ColorAnimation
  { duration: 1000 } }`. **They dim when you start typing** (0.08→0.04) — ambience recedes for the task.
- Masked to the panel radius via `layer.effect: MultiEffect { maskEnabled; maskSource }`.

**This is literally "diffuse aurora blobs, NOT sharp linear gradients," and it costs almost
nothing** (position bindings, no repaint). Recolour mauve/blue → `#7c3aed`/`#00d4aa`.

### ★ Pre-bake the blur — do not compute it

`music_info.sh:86`:
```sh
convert "$tempArt" -blur 0x20 -brightness-contrast -30x-10 "$tempBlur"
colors=$(convert "$tempArt" -resize 50x50 -alpha off +dither -quantize RGB -colors 3 -depth 8 \
         -format "%c" histogram:info: | grep -E -o '#[0-9A-Fa-f]{6}' | head -n 3)
```
Cached by track hash. QML just draws an `Image`. **Zero GPU cost at runtime**, and the `-30x-10`
darkening is what keeps text legible over it. Point it at the *wallpaper* instead of album art.

### Hard-won QuickShell lessons (their comments, worth hours)
- `renderTarget: Canvas.FramebufferObject` — default Canvas is software-rastered.
- **Bloom via `layer.effect: MultiEffect{shadowEnabled}`, never `ctx.shadowBlur`** — the latter
  locks the CPU.
- `layer.enabled: true` — *"forces the background to render as a single hardware texture,
  preventing the UI from dragging and causing 'shadow boxes' during the StackView transition"*.
- *"Masks in MultiEffect strictly require `layer.enabled` to correctly capture the radius during scaling"*.
- `clip: true` — *"prevents the rotated gradient bounding box from bulging out the sides"*.

### ⚠ ilyamiro's theming defects to fix on lift
1. **`MatugenColors.qml` has no `pragma Singleton`** (contrast `Config.qml:1`, which does). Every
   consumer does `MatugenColors { id: _theme }` → **each instance spawns `cat /tmp/qs_colors.json`
   every 1000ms, forever.** Their own `Scaler.qml:40-55` already uses `inotifywait` correctly for
   a different file — they just never applied it to colours.
   **Our fix:** `pragma Singleton` + `FileView { watchChanges: true }` → zero polling, zero spawns.
2. **16 matugen templates is the whole "everything recolors" secret** — quickshell, kitty,
   hyprland, cava, gtk, qt5ct, qt6ct, qt5_style, qt6_style, neovim, discord, firefox, swayosd,
   github.css, youtube.css. We have 8. **Breadth, not cleverness.**
3. ~500 `ColorAnimation { duration: 1000 }` — why the desktop **cross-fades** instead of snapping.
   Nearly free. Keep.
4. **Do NOT copy** the mono-everything font stack (JetBrains Mono + Iosevka is the single biggest
   reason it reads "hacker" not "Raycast"), the 16ms lightning Canvas, the 5s full-panel rotating
   gradient, or `systemctl restart swayosd` (their own comment: it pops the audio).

**Scale system:** `WindowRegistry.js` (96 LOC, `.pragma library`) — design at 1920×1080,
`getScale = pow(min(w/1920,h/1080), 0.85)`. **Ours resolves to 0.905** → barHeight `s(48)`=**43px**,
radii **13/9/7/14** (already inside our 10–14 spec — take as-is), launcher rows **54px**, notif
width 317. A single-file layout table beats magic numbers across 30 files.

**v2.0.0 lands ~mid-2026**, rewriting it compositor-agnostic. Take the code, not the structure.
**License: none** — all rights reserved. Per user override, evaluated anyway; reimplement.

### agridyne — full read, all 10 images viewed

**★ THE BLUR PARAMETERS** (`kwin-effects-forceblur-1.png`, read off the dialog):
```
Blur strength 4 · Noise strength 5 · Brightness 25% · Saturation 0% · Contrast 105%
Force Contrast Parameters UNCHECKED · Corner Radius 0.00
```

**★ The glass-icon recipe — and two corrections:**
1. **The chips are NOT glass — they're opaque.** `alpha 1.0`, `blurBehind: false` on **all 15
   nodes in both presets**. The glass reads as glass because the **panel around them** is blurred
   and the chips are dark, opaque and rounded against it. **A figure/ground trick, not per-icon
   translucency.**
2. **`saturationValue 0` contributes nothing** — `saturationEnabled: false`. **Inert.** The
   monochrome comes from the **icon theme** (*Yet Another Monochrome Icon Set*). Proof: the CRT
   icon still renders yellow and the weather icon teal, because converting them is listed as WIP.
   A saturation effect would have caught those; an icon theme doesn't.

**Where the blur actually comes from** (nobody had this):
```
nativePanel.background:  Main Blur  {enabled: TRUE,  opacity: 0}
                         Main Setup {enabled: FALSE, opacity: 0}
```
Plasma's **native panel background registers the blur region with KWin**. `Main Blur` keeps it
enabled at **opacity 0** — invisible, but still requesting blur — then paints 80% black on top.
**That's the whole trick, and it's a Plasma workaround. Don't port it** — on Hyprland you get blur
from `layer_rule` directly.

**★ The state-adaptive inversion — the idea worth stealing** (complete 7-row mapping):

| Condition | Preset |
|---|---|
| Fullscreen / Maximized | **Main Blur** — panel 0.8 black + blur, **chips OFF** |
| Window touching panel / Active / ≥1 visible / Floating / Normal | **Main Setup** — panel transparent, **chips ON** (opaque, r5) |

**Exactly one layer carries the dark surface at any time. Never both.** ~30 lines of QuickShell:
```qml
readonly property bool solid: ToplevelManager.activeToplevel?.fullscreen
                           || ToplevelManager.activeToplevel?.maximized
readonly property color panelBg: solid ? Qt.rgba(0.04,0.055,0.10,0.65) : "transparent"
readonly property bool  chipsOn: !solid
```

**Deltas — do not copy his values:** alpha 0.8/1.0 → **0.55–0.65**; radius **5** → **10–14**;
**no borders anywhere** (`border.enabled: false` on every node) → we add 1px white — *a real
departure that will change the feel more than the radius change*; saturation 0 → **invert**.
**No hover styling exists** in his rice at all (all non-`normal` states disabled) — our hover
spec has no precedent here either.

**Measured geometry:** panel ≈44px (at 1707×1067 use **36–40**), chip height 28–30, island gap
10 (2×5 margin), glyph 32 in a 44 panel ≈ **0.72 ratio**. Islands are defined by **invisible
`panelspacer`s** — grouping expressed purely through **gaps**, zero borders. The grammar is
**negative space + opaque dark chips**.

**⚠ `panel-layout.png` is an EDIT MODE screenshot.** Every blue bar is Plasma's edit-mode widget
marker, not design; the light-grey bands are edit-mode placeholders. **Anyone reading colour off
it derives a rice that doesn't exist.** Trust the JSON.

**Blur translation → Hyprland** (different parameterisations; a starting point):
```
blur { enabled = true; size = 4; passes = 2; noise = 0.02; contrast = 1.05
       brightness = 0.85   # do NOT port his 25% literally — different meaning
       vibrancy = 0.17     # HIS IS 0 — invert; this is what makes aurora read as colour
       popups = true }
```

**Login screen: does not exist.** README:17 — *"Installed **Monochrome Plasma 6** by pwyde"*
(stock third-party, as-is), and WIP:64 — *"SDDM login screen … still working on this."* No theme
files, no config, no screenshot. **This repo cannot supply "login screen quality."** Redirect to
surface-dots' `sddm/themes/stellarium/` (§9).

**Zen `userChrome.css` is 40 bytes**, in full: `#browser {background-color: #40404066;}` — grey at
40% alpha. Browser chrome theming here is **not CSS work**; it's *make the window semi-transparent,
let the compositor blur behind it*. **Chrome has no `userChrome.css`, so that half is not portable** —
his stack leans on Firefox-only extensions. Our answer stays `BrowserThemeColor` (`OVERHAUL_PLAN` §5.6).

**His wallpaper is video** (Smart Video Wallpaper). Video wallpaper + blur on a dual-core i3 /
Iris Plus is the most expensive thing in his design. **His rice assumes hardware we don't have.**

**cool-retro-term "Monochrome"** — `windowOpacity 0.7531`. *The closest thing in that whole repo
to our 55–65% target — and it's the terminal, not the panel.*

---

## 8. Sidebar / Dock

**Design intent:** a second UI surface. Pinned apps (Chrome, Kitty, Thunar, Spotify, Claude.ai)
+ ideally a running-window switcher. Glass-consistent. Must not break tiling.

### Candidates

| Name | Toolkit | Blur? | Pinned + running | nixpkgs | License | Look (VIEWED) |
|---|---|---|---|---|---|---|
| **DankMaterialShell `Modules/Dock`** | **QuickShell QML** | yes — `WlrLayershell.namespace: "dms:dock"` | **both, grouped** — `buildGroupedItems(pinnedApps, sortedToplevels)` | ✗ (flake) | **MIT** | **dock UI not viewed** — desktop shot has it disabled. Ranked on source. |
| **ekremx25/quickshell** | QuickShell QML | yes | yes | ✗ | MIT | **VIEWED** — dark blue glass over blurred wallpaper, cyan toggles. **Closest to target of anything found.** Demoted: 7★, one maintainer. |
| end-4 dock | QuickShell QML | yes | yes | ✗ | GPL-3 | **bottom-only, hardcoded** — disqualified |
| **nwg-dock-hyprland** | GTK3/Go | *possible* — blur is compositor-side | yes | **✓** | MIT | **VIEWED** — flat opaque slab, **square corners**, reads ChromeOS |
| noctalia | **native Wayland/OpenGL ES, no Qt** | own stack | yes | ✓ | MIT | **architectural disqualifier** — its dock is `.cpp`; adopting = replacing our whole shell |
| Waybar 2nd vertical | GTK3 | via layerrule | **running only** | ✓ | MIT | not viewed |

**`ekremx25/quickshell` is real, not a hallucination** — MIT, 7★, active, genuine `Modules/bar/Dock/`.

### Two corrections to our established facts
1. **"Waybar has no window list" is wrong.** It ships `wlr/taskbar` (foreign-toplevel-manager).
   What it lacks is **pinned apps**. Viable-but-inverted: it gives the half we assumed it couldn't.
2. **nwg-dock's blur objection was wrong** — blur is compositor-side, so a `layer_rule` would blur
   it. Reject it instead for what was actually *seen*: flat opaque slab, square corners, and a
   GTK-CSS theme system that can't share tokens with our QML.

### Recommendation: **vendor DankMaterialShell's `Modules/Dock`**

Only candidate satisfying every hard constraint:
- **Left is a first-class position** — `SettingsData.Position.Left|Right|Top|Bottom`, `isVertical`
  branching, per-corner radii. end-4 hardcodes bottom.
- **It already solves our hardest constraint.** `DockGeometry.qml` computes `reserveZone`, and
  `Dock.qml` spawns a **separate `dms:dock-exclusion` layer window** that owns the exclusive zone
  while the visual dock floats free. That decoupling is exactly what we need next to a
  `PanelCoordinator` we must not join.
- Blur is a **one-line rename** → `aurora-dock` inherits our `aurora-.*` rule.
- **Their docs use Hyprland native Lua** — they ship `docs/Hyprland_Lua_Migration.md`.
- `buildGroupedItems()` folds running toplevels **into** their pinned icon — the hardest part.
- Static when idle. MIT. Flake.

**Vendor 4 files** (`Dock.qml`, `DockApps.qml`, `DockAppButton.qml`, `DockGeometry.qml`); stub
`Theme`/`SettingsData`/`CompositorService`. The rest is trash-can/context-menu chrome.

### What to change

| Property | Value | Note |
|---|---|---|
| `iconSize` / `spacing` / `borderThickness` | 40 / 4 / 1 | → `bodyThickness = 50px` |
| `margin` | 10 | → **`reserveZone = 60px`** |
| `dpr` | **1.5** | `px()` rounds to the device grid — pass this or you get half-pixel seams |
| `surfaceContainer` | **`#0f1420`** | |
| `backgroundTransparency` | **0.60** | **DMS default is `dockTransparency: 1` — must change, or opaque slab** |
| border / radius | `rgba(255,255,255,0.10)` 1px / **12px** | kill `usesConnectedFrameChrome` (it zeroes radii) |
| accents | running/hover `#00d4aa`, active `#38bdf8` | **hover = brightness**: `BrightnessContrast { brightness: 0.12 }`, not a hue swap |

Check: `1707 − 60 = 1647`; with `gaps_out 8`/`gaps_in 8` → `(1647−16−8)/2 = **811.5**` ✓ — matches
the established target and clears Chrome's 768 breakpoint.

Pinned: `["google-chrome","kitty","thunar","spotify","claude-ai"]`. Claude.ai needs a declarative
`xdg.desktopEntries.claude-ai` (`Exec=google-chrome-stable --app=https://claude.ai`) so
`DesktopEntries.byId()` resolves its icon.

**Strip:** `dockAutoHide: false`, `dockIsolateDisplays: false`, and delete
`CompositorService.hyprlandDockOverlapForSmartAutoHide()` + its Hyprland IPC polling — **the main
idle-CPU win**. Drop the `WindowBlur {}` block (DMS hedging for `ext-bg-effect-v1`; our layer rule
does the blur). **[UNVERIFIED: `WindowBlur` presence in QS 0.3.0.]**

### Dock vs sidebar — left, and they're the same object
The axis is the only real decision. **The tiebreaker is the window switcher:** a running-window
list grows with window count. Horizontally it competes with the top bar for a scarce 1707px and
forces icon-only truncation; vertically there's 1067px of near-empty edge at 48px/entry, and it
can carry a **text label** later without reflowing anything — which is what makes it a *switcher*
rather than a second row of icons. Bottom docks are the community default (end-4, 15k★) but their
users are on 15–27" displays where 60px costs ~5%; on 1067px logical it costs **10.3%**.

**Two surfaces on two different axes read as a composed system; two horizontal bars read as a mistake.**

### Auto-hide vs reserve — **reserve**
> *"An auto-hidden dock is by definition absent at rest — it restores the exact single-surface
> screen the user is unhappy with. You'd ship the feature and the complaint would survive intact."*

Also cheaper: a reserved static dock is drawn once, re-blurred only on damage. Auto-hide adds
pointer polling, a slide animation per reveal, and IPC geometry checks. **DMS itself defaults
`dockAutoHide: false`** — `shouldReserveSpace = dockVisible && !autoHide`. **60px is 3.5% of
horizontal width — buy the completeness.**

---

## 9. GTK theme

**Design intent:** Thunar + all GTK apps. Dark with **blue undertone**, not generic gray.

### The measurement REPRODUCED — and it survives decisively

Compiled all dark GTK3 stylesheets from real source (dart-sass 1.101; **adw-gtk3 v6.5 needs
sass ≥1.93**). Counts on **compiled** CSS:

| theme | literals | named refs | ratio |
|---|---|---|---|
| **adw-gtk3-dark** | **317** | **1313** | **4.14** |
| colloid / tokyonight / orchis | 1035 / 1043 / 870 | 92 / 93 / 92 | **0.089** |

**13 further themes surveyed** (Rose Pine, Nordic, Graphite, Fluent, Catppuccin, Dracula, Sweet,
WhiteSur, Layan, Materia, Gruvbox, Everforest, Colloid-Nord): the entire field lands
**0.028–0.141**. Gap to adw-gtk3: **29×–148×. No challenger.**

Three findings that *strengthen* the decision:
1. **Palette swap provably cannot fix override surface.** Colloid compiled twice from one tree
   (Mocha vs Nord) → **identical 1035/92**. The ~1000-literal wall is **structural, not
   palette-dependent**.
2. **`catppuccin/gtk` is ARCHIVED — for exactly our reason.** Their README: *"GTK… can only be
   described as a nightmare to consistently theme and maintain."* The biggest theming org in the
   space hit this wall and quit.
3. **The ecosystem converged on our architecture independently.** `lassekongo83/adw-colors` =
   a **96-line `@define-color` file** over stock adw-gtk3, recolouring the whole widget set with
   **zero compilation**. Same author as adw-gtk3. **This is the reference vocabulary.**

**Aesthetic crux:** nothing ships our surface. Everything is neutral gray (Graphite `#2C2C2C`,
Fluent, WhiteSur, Materia — B−R=0), wrong hue (Rose Pine violet, Gruvbox brown, Everforest green),
or blue-but-too-light (Nordic `#434c5e`, Catppuccin `#292c3c`, Dracula `#1e1f29`). Only **Sweet**
hits the undertone (`#161925`, B−R=+15) — and is simultaneously the **architecturally worst**
option (1596 literals) in candy-neon magenta. *The one theme that looks right is the one you could
least change.* **You author this; you don't adopt it.**

### Four corrections to the brief's premises
1. **`_defaults.scss` does not exist.** Real files: `src/stylesheet/_colors.scss`,
   `_compat-colors.scss`, `_palette.scss`.
2. **"GNOME grays with zero blue undertone" is imprecise — measured.** GNOME's grays are hue
   **240°** at saturation **0.07–0.11**. Ours: hue 225–229° at saturation **0.54–0.62**.
   **The bug is ~6× missing chroma, not missing hue.**
3. **Thunar is GTK3** (verified: Thunar 4.21.5 `dependency('gtk+-3.0')`). libadwaita CSS variables
   are **irrelevant to Thunar**. `@define-color` in `~/.config/gtk-3.0/gtk.css` is the entire
   mechanism. GTK3 `gtksettings.c`: user CSS = PRIORITY_USER (800) > theme (400) → **we win**.
4. **`accent_bg_color`/`accent_fg_color` are injected at runtime by C** (`adw-style-manager.c:172-173`)
   at PRIORITY_THEME (600), not by the stylesheet. **User CSS still beats it.**

**The mechanism split** — the real "dark holes" root cause:
- **GTK3** → `@define-color` only. **125 names.**
- **GTK4/libadwaita 1.9** → widgets consume `var(--window-bg-color)`, defined at `:root`. The docs
  state compat colors *"don't pick up overridden colors."* → **Set BOTH `@define-color` AND
  `:root{--var}`.** adw-gtk3's own `gtk4/libadwaita.css` does exactly this.

### ⚠ Quantified design tension — must decide

A ladder strictly inside `#0a0e1a`–`#131729` yields adjacent steps of **ΔL\* 0.81 / 1.27 / 0.96 /
1.10 (total 4.14)** vs GNOME's **13.23**. **That is at or below the JND** — elevation will be
near-invisible from fill alone.

**Resolution: separation must come from the 1px white borders, not value steps** — which is exactly
our glass-border language. Constraint and aesthetic are consistent, but *only if borders do the work*.
Escape hatch if dialogs read flat: lift S4 → `#171c30` (a flagged deviation above the ceiling).

**⚠ `#f43f5e` + white = 3.67:1 — fails WCAG AA. Use `#e11d48` (4.70:1).**

### The surface ladder (validated: hue 225.0→229.1°, sat 0.62→0.54)

| tier | hex | role |
|---|---|---|
| S0 | `#0a0e1a` | view / content canvas |
| S1 | `#0c101e` | window |
| S2 | `#0f1322` | sidebar, headerbar |
| S3 | `#111525` | dialog, popover |
| S4 | `#131729` | thumbnail |

Text `#e2e8f0` ≥14.4:1 on every tier; `#94a3b8` ≥6.9:1. All AA-pass.

### ★ The 19 GTK3-only names — the direct cause of Thunar's generic look

These have **no libadwaita equivalent** and are currently unset:
```
wm_title #e2e8f0 · wm_unfocused_title #94a3b8 · wm_highlight rgba(255,255,255,0.06)
wm_borders_edge rgba(255,255,255,0.08) · wm_bg_a #111525 · wm_bg_b #0f1322
wm_shadow rgba(0,2,8,0.45) · wm_border rgba(0,2,8,0.30)
wm_button_hover_color_a #131729 · wm_button_hover_color_b #111525
wm_button_active_color_a #0c101e · wm_button_active_color_b #0f1322 · wm_button_active_color_c #0f1322
panel_bg_color #0a0e1a · panel_fg_color #e2e8f0 · content_view_bg #0a0e1a · text_view_bg #0a0e1a
```

Key semantic names (full 125-name set is in the agent transcript; the load-bearing ones):
```
accent_bg_color #0ea5e9 · accent_fg_color #04121f · accent_color #38bdf8
destructive_bg_color #e11d48 · error_bg_color #e11d48 · success_bg_color #34d399 · warning_bg_color #f59e0b
window_bg_color #0c101e · view_bg_color #0a0e1a · headerbar_bg_color #0f1322
sidebar_bg_color #0f1322 · sidebar_backdrop_color #0c101e · sidebar_border_color rgba(255,255,255,0.10)
card_bg_color rgba(255,255,255,0.06) · dialog_bg_color #111525 · popover_bg_color #111525
thumbnail_bg_color #131729 · borders rgba(255,255,255,0.10) · unfocused_borders rgba(255,255,255,0.06)
theme_base_color #0a0e1a · theme_selected_bg_color #0ea5e9
brown_1..5 → remapped to slate #94a3b8/#64748b/#475569/#334155/#1e293b
```

**GTK4 also needs these `:root` vars — NOT backed by any `@define-color` (literal dark holes):**
```css
:root {
  --overview-bg-color: #0f1322;  --overview-fg-color: #e2e8f0;
  --active-toggle-bg-color: rgba(255,255,255,0.12);  --active-toggle-fg-color: #e2e8f0;
  --accent-blue:#0ea5e9; --accent-teal:#00d4aa; --accent-purple:#7c3aed; --border-opacity: 12%;
}
```
Plus 5 `secondary_sidebar_*` names libadwaita has and GTK3 doesn't.
**Not overridable (SCSS-baked, accept):** `$toast_bg_color #505053`, `$osd_bg_color rgba(0,0,0,0.7)`.

**Keep `*_shade_color` as transparent BLACK** — they drive scroll-undershoot gradients and
NavigationView transitions; white would glow. Only `borders`/`*_border_color`/`wm_highlight` go white.

### Changes for our build
- **Fix the floor violation:** `window_bg_color` `#05060b` → **`#0c101e`**. `#05060b` is both below
  our floor *and* nearly hueless — *this is why Thunar reads as generic dark mode.*
- Add the **19 GTK3-only names** and the **4 libadwaita `:root`-only vars**.
- `error`/`destructive_bg` → `#e11d48`, not `#f43f5e`.
- **libadwaita's accent portal snaps to the closest of 9 Oklch colors → `#00d4aa` is unreachable
  that way.** `@define-color accent_bg_color` is the only path.
- **Gradience is archived but unnecessary** — it worked by writing `gtk-4.0/gtk.css`, i.e. exactly
  `gtk.gtk4.extraCss`.

### Thunar selectors (verified from C source — all `gtk_style_context_add_class` → `.class` not `#id`)
```css
.thunar .shortcuts-pane { background:#0f1322; border-right:1px solid rgba(255,255,255,0.08); }
.thunar .standard-view  { background:#0a0e1a; }
.thunar .standard-view:selected { background:rgba(14,165,233,0.25); }
.thunar toolbar         { background:#0f1322; border-bottom:1px solid rgba(255,255,255,0.08); }
.thunar .path-bar-button { border-radius:10px; }
.thunar .split-view-inactive-pane { background:#0c101e; }
```
Also available: `.preview-pane`, `.location-button`, `.disk-space-usage-bar` (+`--normal`/`--warning`/
`--error`), `.ssh-indicator`.

**From user's references:** **nathanhoulamy has zero GTK content** (macOS-only). **SherLock707's
GTK is the exact anti-pattern** — `theme_gtk.css` imports `/home/itachi/.cache/hellwal/colors-waybar.css`
(hardcoded foreign home path), and its `*_breeze` names only bind to Breeze — useless for adw-gtk3.

---

## 10. Lock screen + greeter

**Recommendation: Hyprlock.** QuickShell *does* natively implement `WlSessionLock` + `PamContext`
(so "custom PAM lock" was the wrong frame) — but it blurs **per-frame** (`blurMax: 64`) vs
Hyprlock's **one-time cached framebuffer** (`Background.cpp:120,152` — a few ms at lock, then
zero), and it carries a documented lockout class including *"Lockscreen + Turning off Monitor =
crash."* **Disqualifying on a laptop.** ilyamiro's lock is 1,252 LOC of unlicensed QML on the one
path where a crash means you can't get back in.

### ★★ TWO INDEPENDENT AGENTS FOUND THE SAME LOCKOUT RISK — blocking build note
- **`programs.hyprlock.enable = true` must ALSO be set at system level**, not just Home Manager.
- **`security.pam.services.hyprlock = {}` is MANDATORY** — there is no NixOS `programs.hyprlock`
  module. **Without it you CANNOT unlock** (correct password rejected).

### Other Hyprlock traps
- **`fade_on_empty = false` is REQUIRED** — not for the cosmetic reason in `OVERHAUL_PLAN` §5.10,
  but because `markShadowDirty()` **re-blurs the full viewport PER FRAME**
  (`PasswordInputField.cpp:160,396`). Set `shadow_passes = 0` on the input field.
- Blur is one-shot + cached → **`blur_passes = 3–4` is affordable**.
- `input-field` has **no `shape` key**; the wiki is stale vs v0.9.5 (`check_color` is green
  `0xFF22CC88`). Gradients are borders-only.
- `path = screenshot` blurs the live desktop — the only real glass in the chain.

### Greeter
**Recommendation: SilentSDDM (`rei` preset)** — the only candidate whose native language *is* dark
glass (viewed). Vendor via `mkDerivation` into `/share/sddm/themes`; `themeConfig` → `.conf.user`
verified from SDDM's `ThemeConfig.cpp`. In 26.11 options live at `services.displayManager.sddm.*`.
**⚠ But `wayland.compositor` defaults to weston — a second compositor on 8GB.**

**Runner-up: greetd + ReGreet** — real synergy: it's **GTK**, so it inherits §9's theme
automatically. Genuinely the lower-risk pick if you want one palette to govern everything.
*But* **regreet viewed: flat opaque grey, square corners, yellow Login / red Power buttons** —
and **GTK3/GTK4 have no `backdrop-filter` at all**, so nothing in the greeter slot can do real glass.

**Autologin + hyprlock: recommended against** — Hyprlock has fail-open bugs; you'd trade real
security for zero aesthetic gain.

**SKIP plymouth:** `boot.plymouth` auto-adds `splash`; `boot.plymouth.black` **does not exist**;
`greetd.nix` sets `After=plymouth-quit-wait.service` → **the greeter blocks on it**. Per the
maintainer, Plymouth insists on finishing its animation — **worse the faster you boot**.
adi1090x themes are `ModuleName=script` = CPU-blitted, no GPU accel, on 2 cores; the package
installs **all 80 themes (~524M)** unless overridden, and has **no license**.

---

## 11. Wallpaper picker

**Design intent:** parallelogram card layout. User directive: *"USE THIS, adapt for compat. Don't
build a custom picker."*

**Premise correction (from `OVERHAUL_PLAN` §5.11):** there is no custom picker — `PowerPanel.qml:223-227`
just launches **Waypaper's GTK3 window**. "The custom-built jank" is Waypaper.

### Verdicts on the 5 skwd-wall claims

| Claim | Verdict |
|---|---|
| "Upstream abandons in ~7 days" | **CONFIRMED VERBATIM.** README: *"undergoing a complete rewrite to Rust… I have fully abandoned Quickshell… V2 released ~23/07/2026."* **Zero releases, zero tags. V2 does not exist publicly.** Last commit: *"Updates readme to reflect that this is not Skwd-wall-next (yet)."* Substantive work stopped ~2026-06-19. |
| "Its daemon fights ours" | **SUBSTANTIALLY FALSE — they read the function, not the call site.** `apply.rs:102-105` guards it: it fires **only when switching away from awww**. Pin `paper.engine = "awww"` and it never runs. `apply_awww` probes `awww query` first and **reuses a running daemon** — it *cooperates* with `aurora-wallpaper.service`. **Drop this objection.** |
| "Cost is inverted" | **CONFIRMED and understated.** **619 crates verified**; **no `flake.lock` in either repo**; **four** unpinned nixpkgs paths; builds **QuickShell from git master from source**; **no binary cache**. |
| "Fatal aesthetic mismatch" | **Diagnosis right, conclusion FALSE.** `Colors.qml:9-16` reads a plain `colors.json` via `FileView{watchChanges:true}`. Set `features.matugen: false`, ship a static teal `colors.json` → fixed identity. **Config change, not a fork.** Bonus: it declares `WlrLayershell.namespace: "wallpaper-selector-parallel"` → `layerrule = blur` gives real compositor glass. |
| "Positives all true" | **CONFIRMED, with a decisive caveat:** `pickOnlyMode`/`postProcessing`/`features.matugen` are consumed by the **Rust daemon**, not QML (`skwd-daemon/.../config.rs:45-46`), and `DaemonClient.qml` supplies the **wallpaper list and thumbnail cache**. **skwd-wall cannot run without the 619-crate daemon.** Its `nixosModules.default` exposes **only `enable`** — settings are a mutable JSON the in-app UI writes, which **fights Home Manager**. |

### ★ Recommendation: **vendor the slice, not the app** — this honours the directive

**The entire coupling to the 619-crate daemon is ONE LINE**: `SliceDelegate.qml:35`,
`DaemonClient.preheat(...)` inside a 120ms timer. **Delete it and the parallelogram is free.**

Reference counts inside `SliceDelegate.qml`: `Style` 33 (replace with our token singleton — its
`style.qml` is 56 lines and **colour-free**; anims 200/250/300/350ms and `radiusLarge: 12`,
`borderThin: 1` **already match our brief**), `Config` 10 (→ HM-generated singleton),
`ImageService` 8 (vendor as-is, 92 LOC), `FileMetadataService` 6 (drop), **`DaemonClient` 1 (delete)**.

Cost: ~868 LOC → trim to **~250–350** (drop the tag-editor back-face, QtMultimedia video preview,
WE badges) + 92 LOC ImageService. **MIT — legal with the notice retained.** We use their delegate,
their geometry, their look; we just don't import their distribution. **And it's the only option
immune to the V2 abandonment, because we own a frozen copy.**

**The "~10 lines of skew geometry" claim was wrong** — it's **38 lines** of derived properties
(`:71-108`) feeding a rounded-corner skewed `ShapePath`, repeated 4× (`:193/:240/:324/:806`) for
shadow/fill/image-clip/back-face. Defaults: `expandedWidth 768`, `sliceWidth 108`, `skewOffset 28`.

**Cheaper alternative** (ilyamiro, `WallpaperPicker.qml:550`, `:1165-1168`) — 4 lines, but no
rounded corners, and **no license**:
```qml
readonly property real skewFactor: -0.35
transform: Matrix4x4 { matrix: Qt.matrix4x4(1, s, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1) }
```
with a counter-skew (`s: -skewFactor`) on the inner image so the thumbnail isn't distorted.

### Adaptation steps
1. Clone at current `main` SHA; copy `qml/wallpaper/SliceDelegate.qml` + `qml/services/ImageService.qml`;
   **keep the MIT notice**.
2. Delete `:29-37` (the `_preheatTimer` + its lone `DaemonClient.preheat` call).
3. Strip: `onFlippedChanged` tag editing (`:39-55`), `FileMetadataService` Connections (`:61-69`),
   QtMultimedia video path, WE badge, back-face Shape (`:802-818`).
4. `Style` → teal singleton; keep its anim/radius scale verbatim.
5. `Config` → HM-generated singleton (`sliceWidth`/`expandedWidth`/`skewOffset`/radii).
6. Host in our own `PanelWindow`, ns `aurora-wallpaper-picker`; add
   `layerrule = blur, aurora-wallpaper-picker` + `ignorealpha 0.1`; scrim `Qt.rgba(0,0,0,0.45)`.
7. Apply via `Process { command: ["awww","img","--transition-type","fade", path] }` — no daemon,
   no engine switch, so `kill_awww_if_running` **can never fire**.

**Feed the list from `Qt.labs.folderlistmodel` over 12 files.** skwd-wall's headline features
(13-colour sorting, Wallhaven, Steam, Ollama auto-tagging) exist for people with **thousands** of
wallpapers. **We have twelve.**

### Alternatives ranked
| Name | Toolkit | Glass | License | Verdict |
|---|---|---|---|---|
| **skwd-wall slice** | QML | via layerrule | **MIT** | **vendor** |
| caelestia picker | QML, **~313 LOC** total | shell-wide | GPL-3 | proves a full picker fits in ~300 LOC. **[UNVERIFIED — not viewed]** |
| DankMaterialShell picker | QML, **80 LOC** + `BlurredWallpaperBackground` (434) | yes | MIT | **[UNVERIFIED — not viewed]** |
| Waypaper | Python/GTK3 | **no — opaque** | GPL-3 | our current jank |
| waytrogen / azote | GTK4 / GTK3 | no | Unlicense / GPL-3 | azote **stale since 2025-05** |

### gowall — **adopt** (§2)
Theme format confirmed (`internal/image/themes.go:129-131`) — a flat JSON hex list, arbitrary
length. Our palette expresses cleanly:
```json
{ "name": "aurora", "colors": ["#0a0e1a","#131729","#00d4aa","#0ea5e9","#38bdf8","#7c3aed","#34d399","#e2e8f0","#94a3b8"] }
```
In nixpkgs, MIT, one-time per wallpaper, offline, trivial on this CPU.
**⚠ [UNVERIFIED]:** `config/config.go:86` hardcodes `$HOME/.config/gowall/config.yml`. A separate
JSON loader takes an `io.Reader`, which *suggests* `-t /nix/store/…/aurora.json` works — **CLI
wiring not confirmed.** Worst case, HM writes the config from Nix (declarative source, mutable target).
**Caveat:** quantisation posterizes — ideal for aurora/abstract, wrong for photos.

**mpvpaper:** unchanged from `OVERHAUL_PLAN` §5.11 — **opt-in, AC-only, ≤1080p, after the VA-API
fix, or drop.** Native-res software decode burns half the machine continuously.

---

## 12. Terminal, OSD, notifications, misc

### Terminal startup art — the user was right, the last session was wrong
**Art exists** in `saatvik333/hyprland-dotfiles`, in the **nvim config**: `nvim/lua/plugins/dashboard.lua`,
`nvimdev/dashboard-nvim`, `theme = "doom"`. A **21-line braille-rendered coffin/reaper** with
`IuseNVIM` **spliced into the braille on line 3**. Four more in `nvim/lua/plugins/asset/`
(`coffin-logo`, `death-star-logo`, `illuminati-logo`, `skull-fuck-you`) — **referenced by nothing**
(`grep -rn "asset/"` → zero hits): an unused swap library. Plus 4 in `fastfetch/`, and an ASCII
banner in `kitty.conf`'s comment header.

**⚠ Tone mismatch:** coffins, reapers, Death Star, illuminati, satan-cross. **Aesthetically opposite
to northern lights.** Take the **mechanism** (dashboard-nvim doom theme + external `.txt` header +
padded menu + startup-time footer); braille art of an **aurora ridgeline in `#38bdf8`** hits our
target through the identical path. **`nvim/` is Apache-2.0 — the only copy-safe code in the three
design-ref repos.**

**Other corrections:** saatvik's kitty is **`background_opacity 0.9`, not 1**. His palette is **not
warm sepia** — it's **Wallust-derived**: with a blue Death Star wallpaper the whole system renders
**dark slate blue** (*closer to our target than anything else in this research*); with cherry
blossom it goes warm. **Same config, opposite palettes.** 16 Wallust templates. **Do not adopt
Wallust** — it will drift with the wallpaper and fight our fixed palette.

**File explorer:** **Yazi, and it is completely unstyled.** `yazi.toml` is the only Yazi file —
no `theme.toml`, no `flavors/`. Its appearance is stock Yazi + the terminal palette. **There is no
file-explorer design to lift here.** The `[opener]` block is genuinely useful (glow for markdown,
exiftool EXIF, archive peek) but that's UX, not appearance. `OVERHAUL_PLAN` §5.12's "stay on Thunar"
stands.

**fastfetch:** unchanged from §5.9 — drop `packages` (70ms warm/338ms cold, nix is 100% of it),
replace `wm` (61ms) with a Nix-injected static string → **~10–25ms**. Use **ANSI palette indices**
(`"keyColor": "36"`), not hex, so it inherits kitty's recoloured palette free.

**kitty `background_blur` is a guaranteed no-op on Hyprland** — confirmed twice. Hyprland never
implemented `kde_kwin_blur` (0 hits); `ext-background-effect` is on main but **not in any 0.55.x
release**. Leave unset — **no double-blur risk**. Even when it lands, Hyprland **intersects** blur
regions (`OpenGL.cpp:2069-2078`) — stacking is impossible.

### OSD — **QuickShell, not SwayOSD**

**Two factual errors in the brief inflate SwayOSD:**
1. **"brightness via logind" is FALSE.** `login1.rs` contains **only** `PrepareForSleep`. Brightness
   **shells to `brightnessctl`** (`brightness_backend/brightnessctl.rs:65`). **QuickShell would do
   exactly the same — symmetric.**
2. **"per-device volume" is not exclusive.** QuickShell has a **native in-process PipeWire binding**
   with `volumesChanged` signals and per-node/device volumes (`qml.hpp:231/241`, `device.hpp:31`) —
   **better than SwayOSD's libpulse**.

SwayOSD gives free **exactly one** thing: event-driven caps/num/scroll-lock via libinput. Hyprland
emits **no IPC event** for lock state (`InputManager.cpp` — only `activelayout`); `hyprctl devices`
reports `capsLock`/`numLock` (`HyprCtl.cpp:794-795`) but **polling only** (#7271 closed "not planned").
**And NixOS doesn't even wire that freebie** — HM's `services.swayosd` only ExecStarts
`swayosd-server`; `swayosd-libinput-backend.service` ships in-package but **no module exposes it**
(HM #6347 **open**, no workaround).

**Net: a second daemon + a GTK4 stack + a second theming language, on 2 cores/8GB, to buy one
unwired feature — while QuickShell already owns the bar and notifications.**
→ **~120-line `Osd.qml` in our existing QS config.** Steal caelestia's pattern + motion tokens.
**Runner-up:** SwayOSD with a from-scratch `style.css` (**no `@import`**) only if caps-lock OSD is
load-bearing.

**Fix our existing defect:** `swayosd.css:1` imports waybar.css then `:6` **overrides it** with
hardcoded `rgba(3,3,8,0.88)`, and `:45` is a **banned sharp linear gradient** running pink →
lavender → grey. Either way, that file dies.

**elifouts OSD geometry (best structural CSS found):** radius 18, bg alpha 0.65, border 1px alpha
0.25, box-shadow `0 4px 16px`, icon 24px `scale(0.8)` min 28, label 11px/600 min-width 30, bar
min-width 160 / min-height 6 / radius 999, trough alpha 0.12, progress transition 80ms.
**⚠ But it `@import`s pywal's `colors-waybar.css` — the exact anti-pattern we're removing.**

### Notifications
We already own these in QuickShell (`NotificationPanel.qml`) with an inactive dunst fallback.
Take **cxOrz's `NotificationService.qml`** (118 LOC, native `NotificationServer`) and
**caelestia's grouping model** (`NotifGroup`/`NotifGroupList`). Skin per §6.

### ★★ decoration:glow — a new aurora lever nobody knew about
**New in Hyprland 0.55** (verified at `v0.55.0 ConfigValues.cpp:211-215`):
```
enabled false · range 10 (0-100) · render_power 3 (1-4)
color 0xee33ccff          ← THE DEFAULT IS LITERALLY CYAN
color_inactive 0x0033ccff
```
`inner_glow.glsl` **discards outside the band → 1 draw per window, rim only = cheap.** It has its
own `fadeGlow` animation node. **A better aurora knob than `vibrancy`, and it costs almost nothing.**
Not mentioned anywhere in `OVERHAUL_PLAN`.

### ★ Blur corrections to `OVERHAUL_PLAN` §5.2
- **`vibrancy_darkness` default `0` is INVERTED** (`blur1.glsl:118`): **0 = MAXIMUM effect on
  darks.** Our plan proposes `0.30`, which would *reduce* the effect on exactly the dark surfaces we
  care about. **Raise `vibrancy`; LEAVE `vibrancy_darkness` at 0.**
- `vibrancy` (default 0.1696) touches **saturation only** — `hsl[2]` passes through verbatim.
- **Dual-Kawase: `size` is FREE** (uniform, fixed 5/8 taps). **Buy radius with `passes`** (cost
  decays 1/4^i). The renderer **clamps passes to 1–8** though config accepts 0–10 — **`passes = 0`
  does NOT disable blur.**
- **`xray = true` + `new_optimizations = true` = the biggest iGPU win.** Target `passes 2`,
  `size 8–12`, `special = false`. (Confirms §5.2(c).)

### Cursor / icons / fonts
- **Cursor: keep Adwaita@24.** Adwaita ships **[24,30,36,48,72,96]** — **36 = 24×1.5**, exactly right
  for our fractional scale. Bibata-Modern-Ice has **no 36**. Switching would be a **regression**.
  Use `home.pointerCursor` + `.gtk.enable` + `.x11.enable` + `.hyprcursor.enable`; **do not ALSO set
  `gtk.cursorTheme`** (explicit beats HM's `mkDefault` and silently wins).
- **Icons:** `papirus-icon-theme.override { color = "teal"; }` — nixpkgs runs `papirus-folders`
  **inside the derivation**, fully declarative. **Add the folder-SVG recolour** from SherLock707's
  template idea (§2.1) — the most-skipped surface.
- **Fonts:** Inter 4.1 ships **Inter Display**. Keep Inter + FiraCode NF.
- **Qt:** `qt.platformTheme.name = "qtct"` + `qt.style.name = "kvantum"` + `qt.kvantum.*` are
  **first-class now** — `xdg.configFile."Kvantum/kvantum.kvconfig"` is obsolete.

### Misc Nix/HM corrections found in passing
- `programs.git.delta.*` **moved to** `programs.delta.*`
- `programs.fzf.colors` is an **attrset**, not `--color=` flags
- fish: `set -g` in `interactiveShellInit` **shadows universals**
- kitty `.themeFile` **cannot** take a custom palette → use `settings`
- greetd: `pkgs.tuigreet`, **not** `pkgs.greetd.tuigreet` (stale); `useTextGreeter = true`
  **mandatory**; `services.greetd.vt` **removed**
- **`programs.chromium.commandLineArgs` does not exist**; `~/.config/chrome-flags.conf` is an Arch
  launcher convention that **does nothing on NixOS**
- **[UNVERIFIED]** Lua gradients: >10 stops appear to overrun a `vec4[10]` uniform with no clamp in
  `LuaConfigGradient.cpp` — **stay ≤10**.

### Wallpapers
Curated dark/aurora sets: `dharmx/walls`, `FrenzyExists/wallpapers`, wallhaven.cc (aurora /
northern lights / dark abstract, ≥2560×1600). **Selection criterion, from §2:** dark, chromatic,
blue/teal/purple-dominant. **Achromatic images collapse our palette to dead gray** — and per §2,
**run every candidate through gowall first**, which makes the criterion much less critical.

### Starship
**[GAP — not researched.]** The agent covering it was stopped before reporting. Nothing here is
sourced; do not guess. `programs.starship.settings` is TOML-in-Nix. Fish-specific behaviour and
per-prompt cost on a dual-core i3 (esp. `git status`, `command_timeout`) remain open.

---

## 13. Honest gaps

| Gap | Status |
|---|---|
| **ilyamiro full read** | **Stopped in flight.** ~15k LOC never opened: SettingsPopup (4384), NetworkPopup (2366), WallpaperPicker (1826), MovieWidget (1818), plus ~15 more. **`Floating.qml` was greped, never opened — yet its pattern is ranked #1 in §7. Verify before building.** |
| **SherLock707 full read** | **Stopped in flight** (rate-limited on per-file fetches). Only 3 dirs were ever read. Its ~19-template fan-out is the basis of §2.1 — the map is from partial evidence. |
| **surface-dots full read** | **Stopped in flight**, ~complete. ~10 images never viewed (`hyprlock.png`, `lock.png`, `stella.png`, `powermenu*`, `cassini*`, `layers.jpg`, `reading.png`). |
| **Starship** | **Never researched.** §12. |
| **caelestia launcher appearance** | **Never viewed by anyone** — our §3 #1 pick is ranked on source alone. |
| **DMS dock in vertical/left mode** | Never viewed — §8 ranked on source. |
| **noctalia** | Never viewed (README has no raw image URLs). |
| **caelestia Blobs cost** | **CONTESTED** — two agents directly conflict. §1. |
| **pywal16** | Never examined; ranked on general knowledge only. §2. |
| **vicinae wallpaper-click dismiss** | Needs the live machine. §3. |
| **iNiR QS 0.3.0 compat** | Unpinned upstream; untested. §6. |
| **gowall Nix store-path theme** | CLI wiring unconfirmed. §11. |
| **matugen `custom_colors{blend:false}` on 4.0.0** | Read in 4.1 source; untested on our version. §2. |
| **Multi-layer radial aurora at 1.5x** | Syntax verified; appearance not. §5. |
| Nothing was rendered or benchmarked | **No perf claim here is measured on the i3-1000NG4.** All are read off loop/shader structure. |

**Licensing summary:** MIT/permissive — **iNiR**, **DankMaterialShell**, **cxOrz**, **skwd-wall**,
**mubin**, **walker**, **gowall**, **hellwal**, ekremx25, nwg-dock. GPL-3 — **caelestia shell**,
**adi1090x**, **elifouts**, **LinuxBeginnings**, **GlassesArch**, end-4, vicinae, Waypaper.
**NO LICENSE (all rights reserved)** — **ilyamiro**, **agridyne**, **surface-dots**,
**saatvik333** (except `nvim/` = Apache-2.0), **SherLock707** (unconfirmed), **Sharddots**,
**caelestia meta repo**, **nathanhoulamy**.
→ For the unlicensed ones, **reimplement from the measured specs above.** Dimensions and techniques
aren't copyrightable; files are.

---

## 14. What this changes in `OVERHAUL_PLAN.md`

| § | Change |
|---|---|
| §2 | Reference verdicts superseded — see §0 above. |
| §5.1 | **Root fix survives** but is **insufficient alone**: coverage first, then `prefer` + **`custom_colors{blend:false}`**. Add SherLock707's central-pinning pattern and the `theme-only` escape hatch. Consider gowall. |
| §5.2 | **`vibrancy_darkness` 0.30 → 0** (inverted). Add **`decoration:glow`** (default cyan). `ignore_alpha` **0.15 for Waybar**, not 0.10. **Layerrule syntax changed in 0.55** — old form is a parse error. |
| §5.3 | Dock: **vendor DMS `Modules/Dock`**, not build. Left, 60px reserve → 811.5px halves ✓. |
| §5.5 | Launcher: **adapt caelestia's (1623 LOC)** — the SQLite blocker is 75 lines. Runner-up **walker** (MIT, nixpkgs, real click-away). |
| §5.8 | **"No community shell matches the aesthetic" is REFUTED** — `snowarch/iNiR` `globalStyle: "aurora"|"angel"`, MIT, flake. The skin is a **~40-line palette preset swap**. |
| §5.8a | Beziers are **optional polish** — ilyamiro proves `OutExpo` @400–800ms suffices. iNiR's curve set is better sourced. |
| §5.10 | **Two blocking lockout notes** (system-level `programs.hyprlock.enable` + `security.pam.services.hyprlock`). `fade_on_empty=false` for a **perf** reason. |
| §5.11 | skwd-wall: the **daemon objection is false**; **vendor `SliceDelegate.qml`** (delete 1 line to free it from the Rust daemon). |
| §5.12 | Yazi is **unstyled** — nothing to lift. Thunar decision unaffected. |
| — | **New:** `decoration:glow`; the 19 GTK3-only `@define-color` names; the media-button `min-width` fix (bespoke, no precedent); the Rofi double-composite trap; the cxOrz PSK-in-argv security bug. |

---

## 15. Handoff — independent verification tasks

One self-contained brief per session. **Ordered by (load-bearing × uncertainty).** Each states
the claim, why it matters, and the exact check.

**Standing rule for every task below:** read the file before citing it; view the image before
describing it; report "couldn't verify" rather than inferring. Five wrong conclusions in this
pass came from surface reads that looked finished.

### TIER 1 — load-bearing, unverified, cheap to settle

**V1. `matugen custom_colors { blend: false }` on OUR 4.0.0** — *§2*
Claim: emits our exact hex untouched by M3 (`src/scheme.rs:100-150`, `make_custom_color`), giving
deterministic `#00d4aa`/`#7c3aed`/`#34d399`. This was read in **4.1 source but never run on 4.0.0**.
It is now the **keystone of the palette architecture**, and `OVERHAUL_PLAN` §5.1 separately declared
`blend = false` "DEAD" (having tested it on the *source colour*, a different mechanism).
**Check:** run our shipped matugen 4.0.0 with a `[custom_colors]` block, `blend = false`, against 3+
wallpapers incl. a pink/red one. Does the output hex equal the input hex exactly? Does it survive
`set_lightness`/`set_alpha` piping? If it doesn't exist in 4.0.0, say so — that forces the 4.1 upgrade.

**V2. `xray` + `passes=2` on the Iris Plus** — *§6, §12; `OVERHAUL_PLAN` §5.2(c), §7-B0*
**The single biggest open risk in the whole plan, and it's measurable in minutes.** Everything
downstream assumes compositor blur is affordable. **Nothing in this research was benchmarked.**
**Check:** live `hyprctl eval` A/B on a named rule (no file edits, no reload):
```sh
hyprctl eval 'hl.layer_rule({name="aurora-panels", match={namespace="aurora-.*"}, blur=false})'
hyprctl eval 'hl.layer_rule({name="aurora-panels", match={namespace="aurora-.*"}, blur=true, ignore_alpha=0.10, xray=true})'
```
Screenshot both; measure frame time. Also sweep `ignore_alpha` 0.05/0.10/0.15/0.20 — §5 argues
**0.15 for Waybar** (island gaps get blurred below that) vs the plan's global 0.10. Settle both.

**V3. Hyprland 0.55 layerrule + Lua syntax** — *§5*
Claim: the old `layerrule = blur, waybar` form is a **parse error** in 0.55; correct form is
`layerrule = [ "blur true, match:namespace ^(quickshell)$" ]`. If true, **every layerrule in every
reference repo is stale**, and our own may be silently dead.
**Check:** confirm against our installed Hyprland. Then confirm the **native-Lua** equivalent
(`hl.layer_rule({...})`) field names against `LuaBindingsConfigRules.cpp`. Cross-check
`LinuxBeginnings/Hyprland-Dots` → `config/hypr/lua/layer_rules.lua` — flagged as the best real-world
native-Lua artifact found. Also: **[UNVERIFIED]** do >10 Lua gradient stops overrun a `vec4[10]`
uniform (no clamp in `LuaConfigGradient.cpp`)?

**V4. The two Hyprlock lockout notes** — *§10*
Two agents independently found: (a) `programs.hyprlock.enable` must ALSO be system-level, not just
HM; (b) `security.pam.services.hyprlock = {}` is mandatory or **you cannot unlock**. **Getting this
wrong locks Alex out of his laptop.**
**Check:** verify both against nixpkgs 26.11 module source and hyprlock v0.9.5's PAM path. Confirm
`fade_on_empty = false` is required for the stated perf reason (`markShadowDirty()` re-blurring the
full viewport per frame — `PasswordInputField.cpp:160,396`). **Test unlock on a VT you can escape
from, never on the only session.**

**V5. `vibrancy_darkness` is inverted** — *§12*
Claim: default `0` = **maximum** effect on darks (`blur1.glsl:118`), so `OVERHAUL_PLAN` §5.2's
proposed `0.30` would *reduce* the effect on exactly our dark surfaces.
**Check:** read `blur1.glsl` and confirm the direction. Then confirm `decoration:glow` exists in our
0.55 (`ConfigValues.cpp:211-215`), its default is cyan `0xee33ccff`, and `inner_glow.glsl` discards
outside the band (rim-only, 1 draw/window). If both hold, glow is a cheap aurora lever the plan misses.

### TIER 2 — incomplete reads (the agents were killed mid-flight)

**V6. ilyamiro — finish the full read** — *§7, and this is the one I'd prioritise*
**~15k LOC never opened**: SettingsPopup (4384), NetworkPopup (2366), WallpaperPicker (1826),
MovieWidget (1818), BatteryPopup, CalendarPopup, VolumePopup, NotificationPopups, SysData,
SystemUsage, Caching, stewart, FocusTimePopup, GuidePopup, DrawAction, ScreenshotOverlay, Timer,
ClipboardManager, Updater, MonitorPopup.
**⚠ `Floating.qml` was GREPED, NEVER OPENED — yet its single-driver morph pattern is ranked #1 in
§7.** Verify `expandProgress` and the `Behavior { enabled: !disableAnim }` guard actually exist as
described before anything is built on them.
NetworkPopup and CalendarPopup are panels **we are actively rebuilding** — read them.
Also settle: how many live `MatugenColors{}` instances exist (is the 1s `cat` poll ×N or ×1)?
Repo: `github.com/ilyamiro/nixos-configuration`, shell at
`config/sessions/hyprland/scripts/quickshell/`. **No license — read, don't copy.**

**V7. SherLock707 — finish the full read** — *§2, §2.1*
Rate-limited on per-file fetches (**skip the OpenRGB log dirs; try the tarball archive**). Only 3
dirs were ever read, yet its ~19-template fan-out is **the basis of the entire coverage checklist**.
Read every template and every post-hook script **in full**, and produce the definitive
**surface → template → consumer → reload-mechanism** map. `colors-hyprland.lua` (native Lua!) and
`qml_color.json` (QuickShell) matter most — both of our exotic consumers are already solved there.
**Settle the license** (unconfirmed — decides copy vs reimplement).
Repo: `codeberg.org/SherLock707/hyprland_dot_yadm`.

**V8. surface-dots — finish (was ~90% done)** — *§4, §10*
~10 images never viewed: `hyprlock.png`, `lock.png`, `stella.png`, `powermenu*`, `cassini*`,
`layers.jpg`, `reading.png`, `new_reading.png`, `pixel.png`, `cs.gif`.
Read `sddm/themes/stellarium/` (9 QML files) **in full** — it is our **best login-screen reference**,
and agridyne's (the briefed one) **does not exist**. Also settle: the user called its launcher "nice
and modern" — is that the **Rofi** theme (`style-dark.rasi`) or the **QuickShell `WideDrawer`**
(1492 LOC, no focus grab)? View both. **No license — reimplement.**

**V9. Starship — never researched at all** — *§12*
The agent was stopped before reporting. **Nothing in this doc is sourced.** Find 5+ aurora/dark
configs, view them, rank. Criteria: teal/cyan/purple fit, FiraCode NF glyphs, **fast on a dual-core
i3** (name the expensive modules — `git status` in big repos; `command_timeout`), fish-specific
behaviour, and expressibility in `programs.starship.settings` (TOML-in-Nix).

### TIER 3 — appearance never verified by eye

**V10. caelestia's launcher** — *§3*. **Our #1 launcher pick, and nobody has ever seen it.** The
org's only preview is a 13-month-stale video. Build/run it, or find a current screenshot
(Discord, r/unixporn, forks). If it's ugly, walker (§3 runner-up) is the fallback.

**V11. DankMaterialShell's dock in vertical/left mode** — *§8*. Our dock pick, ranked on source
alone; their README is badge-only and the site's desktop shot has the dock disabled. Toggle
`Position.Left` and look.

**V12. iNiR `globalStyle: "angel"` on QuickShell 0.3.0** — *§6*. **The whole "the skin exists" claim
rests on this.** Its QS version is unpinned upstream. Does `GlassBackground.qml` even load on 0.3.0?
Then: does the ~40-line palette preset swap actually produce our aurora, or does M3 leak back in?
**Also settle the CONTESTED caelestia Blobs question (§1) here** — two agents directly conflict on
whether it's one batched draw call or per-frame SDF. Render and measure.

**V13. noctalia** — never viewed (README exposes no raw image URLs). MIT, 8.7k★. Ruled out
architecturally (0 QML, native C++/OpenGL) but never assessed visually — worth 10 minutes as a
design source.

### TIER 4 — cheap, low-risk

**V14. gowall store-path themes** — *§11*. `config/config.go:86` hardcodes
`$HOME/.config/gowall/config.yml`, but a separate JSON loader takes an `io.Reader`. **Does
`gowall convert -t /nix/store/…/aurora.json` work?** Decides fully-declarative vs HM-writes-a-dotfile.

**V15. pywal16** — *§2*. Never examined; ranked on general knowledge. Almost certainly dominated by
hellwal/wallust, but the ranking is currently unsourced.

**V16. vicinae wallpaper-click dismiss** — *§3*. Needs the live machine. Its dismiss is
`closeOnFocusLoss` — does clicking the **wallpaper** (which may not transfer keyboard focus) close
it? If yes, vicinae jumps on aesthetics (it's a literal Raycast clone).

**V17. Multi-layer radial aurora in GTK3 at 1.5x** — *§5*. Syntax verified, appearance never
tested. Does `radial-gradient(circle at 20% 260%, …)` stacked ×2 over `alpha(#0f1420, 0.60)`
actually read as a diffuse aurora arc, or as banding?

### Deliberately NOT worth a session
- Re-litigating adw-gtk3-dark (§9) — reproduced from source, 13 themes surveyed, 29×–148× gap,
  and the palette-swap escape was **provably** closed (Colloid compiled twice → identical counts).
- Re-checking that Rofi 2.0.0 can't click-away — verified twice from source.
- kitty `background_blur` — confirmed a no-op twice, from two directions.
- Whether newmanls themes are incomplete — all 25 checked mechanically.
- caelestia's "two bars" / sidebar composition — settled from HEAD with file:line (§1).
