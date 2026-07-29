# Aurora desktop overhaul — plan

Author: Claude Code Phase A run, 2026-07-16
Companion documents: `ISSUE_LOG.md` (evidence for every defect), `EXECUTION_LOG.md`
(what exists), `BUILD_PLAN.md` (original design intent), `SOURCES.md` (provenance).

> **Status: Phase A. Nothing has been changed on the machine.** No config file was edited,
> no service restarted, no live setting altered. Everything below is a proposal awaiting
> Alex's approval.

---

## 1. Executive summary — what this pass actually found

The infrastructure is sound. The visual failure has a **small number of deep root causes**,
not a hundred shallow ones, and most of them are cheaper to fix than they look.

**The five findings that matter:**

0. **The palette config targets a matugen version we do not ship.** `aurora.toml` sets
   `prefer = "closest-to-fallback"` with `fallback_color = "#04d1f9"` — which in matugen
   **4.1.0** selects the wallpaper colour with minimum CIE Lab distance to teal. We ship
   **4.0.0**, where that key does not exist and serde **silently discards it**. Verified:
   matugen 4.0.0 accepts `prefer = "TOTAL-GARBAGE-NOT-REAL"` and exits 0. **The teal bias
   Alex asked for was configured, and has never once executed.** (`ISSUE_LOG.md` §3)

1. **The muddy pink is structural, not a bad wallpaper — but it is also not what I first
   thought.** Verified across all twelve wallpapers: **not one** produces a saturated accent,
   so switching wallpaper cannot fix it. The initial diagnosis (M3's +60° `tertiary` rotation
   makes pink inevitable) was only half right. The real defect is **lightness**: M3 dark
   accent roles are tone-80 pastels by design, and tone-80 destroys saturation. A 24-hue
   sweep of `blend: anchor, 0.7 | set_lightness: 58` yields **primary never pink, 24/24**.
   The hues were fine all along. (`ISSUE_LOG.md` §3, plan §5.1)

2. **Glass: the blur already works — the panels are just opaque.** `hyprctl layers` confirms
   our `aurora-.*` rule matches both `aurora-taskbar` and every `aurora-panel-*` surface. The
   compositor has been faithfully blurring the wallpaper behind panels rendered at **alpha
   1.0**, so none of it can be seen. We have been paying the iGPU cost of blur for zero
   benefit. **This is a template alpha fix, not a blur re-architecture.** (§4, §4a)

3. **Waybar owns the cgroup of every app launched from it.** Confirmed live: Kitty's master
   process and all of Chrome's renderers sit inside `waybar.service`, which has
   `KillMode=control-group`. This is both a daily-usability bug and a constraint on how Phase
   B may be executed. It also supplies a precise mechanism for "3+ windows close" that is
   *not* a tiling bug. (§1, §15)

4. **Nine of the reference builds do not contain what the brief believes they contain.**
   See §2. This is the single most important outcome of the research pass, because the plan
   the brief implies **cannot be executed as written** — and because two of the charges
   against Codex turn out to be unfair (`ISSUE_LOG.md` §16a).

**Method note — why these findings differ from the brief's.** Every claim above was checked
against the running machine or the actual source, not against a README. Previews were
*downloaded and viewed*, not read about (caelestia ships only a 49s video, so it was
decomposed into 12 frames with ffmpeg and each frame inspected). Where a subagent asserted
something load-bearing, it was re-verified independently — the matugen version claim, the
pink window borders, the QuickShell launcher APIs and the Rofi Wayland backend were each
re-tested here before being written down. **Three of my own intermediate conclusions were
wrong and are recorded as corrections in `ISSUE_LOG.md` rather than quietly dropped**
(the touchpad "inert block" theory, the Rofi XWayland theory, and the Rofi
"incomplete theme" mechanism). That discipline is the entire difference between this pass and
the one that produced the current desktop.

**The dependency that shapes everything:** the palette is the root. Waybar CSS, Rofi,
QuickShell panels, GTK, Chrome, Hyprlock, notifications, the screenshot overlay and the
Hyprland borders all consume Matugen output. Restyling anything before the palette
architecture is fixed means doing it twice — which is very likely what happened the first
time, and is the strongest available explanation for why Codex's output looked half-applied.

---

## 2. Reference builds — corrections to the brief (read this before anything else)

Every reference was inspected by downloading its previews and **looking at them**, then
reading the source. Where a repo had no stills, we went further: caelestia ships only a 49s
video, so its previews were extracted to 12 frames with ffmpeg and viewed individually.

| Repo | Brief says | What it actually is | Verdict |
|---|---|---|---|
| **ilyamiro/nixos-configuration** | Tier 1 — "the quality bar", glass + animation benchmark | Panels are `color: root.base` — **fully opaque**. No layer blur on any QS namespace. Its "depth" is faked with gradient blobs painted *inside* the opaque panel and a pre-blurred copy of the album art. Palette is **not** yellow-green (that briefing is stale) — it is warm salmon, 100% wallpaper-derived. **No cava at all**; its "waveform" is a decorative Canvas. Zero bezier curves — stock easings only. | **Not a glass reference.** Treating it as one reproduces our exact defect. Real value: bar/panel **sizing** (its `barHeight` resolves to ~43px on our display — in spec) and animation *durations*. **6/10** |
| **caelestia-dots/shell** | Tier 1 — "THE sidebar reference" | **Has no dock.** `modules/sidebar/` is a notification drawer duplicating our `NotificationPanel.qml`. Ships `transparency.enabled = false`, `base = 0.85` — opaque by default, and 0.85 is the value our spec rejects. Its "second surface" feel comes from its **bar being vertical-left**. Architecture is a single morphing drawer — the thing we ruled out. | **Best single source anyway** — see §3. **8/10** |
| **mubin-thinks/minimal-wm-config** | Tier 2 — **"CRITICAL"**, "study its Matugen/pywal template setup", "Chrome title bar is recolored" | **Zero** occurrences of matugen, pywal, template, chrome, or gtk in all 32 files. It is a **Sway** config whose theming is four hand-written static palettes copied by an `install.fish` that runs `rm -fr` over `~/.config`. The "Chrome" story is **Firefox**, recolored by hand-typing nine hex values into a third-party GUI add-on. Opaque, `border-radius: 0`, warm brown; remaps cyan and blue **to brown**. | **The assigned premise does not exist.** **1/10** |
| **agridyne/dotfiles-dt** | Tier 1 — sidebar, glass cohesion, app icons, login screen | **KDE Plasma** (Kurve + YoRHa HUD + Panel Colorizer). Not Hyprland. Not portable. | **Never was a usable reference.** The brief's criticism that Codex "didn't reference agridyne at all" is unfair — it could not have. |
| **Harshil-Anuwadia/wintux…grub-theme** | Tier 3 — dual-boot GRUB theme | We boot **systemd-boot 260.1**; there is no GRUB (`boot.loader.systemd-boot.enable = true`, `canTouchEfiVariables = false`, no `/boot/grub`, no `grub-install`). Adopting it means replacing the bootloader on a T2 Mac. The macOS/NixOS picker Alex uses is **Apple's firmware picker** anyway — neither GRUB nor systemd-boot. | **DROP.** Cosmetic gain, boot-path and dual-boot risk, on the one thing the invariants say to leave alone. |
| **mubin-thinks/charcoal** | Tier 2 — "the theme used by minimal-wm-config" | **The repository does not exist.** 404 on both `main` and `master`. "Charcoal" is merely the name prefix of two theme *folders* inside minimal-wm-config (`charcoal-monochrome-dark` / `-light`). Not a GTK theme, not base16, not a generator. | **The link in the brief is dead.** |
| **end-4/dots-hyprland** | Tier 2 — "waybar styling source" | **Contains zero waybar files** — it is fully QuickShell now. Its motion curves are 6–12-point Bézier splines that **GTK3 cannot express** (CSS `cubic-bezier` takes 4 args). | Waybar value: **none**. Portable subset: `cubic-bezier(0.2,0,0,1)` and `cubic-bezier(0.34,0.8,0.34,1)`. |
| **saatvik333/hyprland-dotfiles** | Tier 2 — "ASCII art on startup", terminal experience | **Its terminal has no ASCII art**: a bare `saatvik333 ~ $` prompt, warm sepia via Wallust, no fetch, no blur. Aesthetically the opposite of aurora dark glass. | The cited feature does not exist. Terminal-art design is ours (§5.9). |
| **snes19xx/surface-dots** | Tier 2 — widget sizing, terminal system info | Its screenshots are **lock screens** (near-black, sage-green, serif — genuinely refined, but green, not teal). Its `kitty.conf` sets **`background_opacity 1`** — fully opaque. | Not a glass model. Real value is its **config**: nerd-font glyph keys, `" ▐ "` separators, named ANSI colours. |
| **LinuxBeginnings/Hyprland-Dots** | Tier 2 — "was SUPPOSED to be our waybar styling source but wasn't applied properly" | `Crystal-Clear-Glass.css` is **white** glass (`rgba(255,255,255,0.25)` + the `opacity:` antipattern). `Colorful-Aurora.css` is a **bright pastel candy gradient with black text** (`linear-gradient(45deg,#95e6cb,#59c2ff,#d2a6ff)`) — the exact sharp linear gradient the spec bans; the name is a coincidence. **And its `layerrule = blur, waybar` is commented out** under "Optional" — so even a faithful copy renders **unblurred**. | That commented-out layerrule is very likely the literal meaning of "wasn't applied properly". Real value: its **`ML4W-Glass-3d.css`**, which owns the diffuse-aurora technique. |

**What this means.** The brief's plan — "copy ilyamiro's glass, take caelestia's sidebar,
study mubin's Matugen templates, use agridyne's cohesion, take end-4's and LinuxBeginnings'
waybar styling" — resolves to: a glass reference with **no glass**, a sidebar that **doesn't
exist**, a template system that was **never written**, a **KDE** rice, a repo with **zero
waybar files**, a dead link, and a glass CSS whose blur rule is **commented out**.

**Nine of the reference builds do not contain what the brief believes they contain.** This
is the central result of Phase A, and it is why the brief's plan cannot be executed as
written.

It also substantially **exonerates Codex** on two of the seven charges against it. "The
ilyamiro QuickShell code was barely used" and "the agridyne sidebar style wasn't referenced
at all" read as negligence — but agridyne is a KDE Plasma rice that *cannot* be referenced
from Hyprland, and ilyamiro is a single-morphing-hub build whose architecture our own
`BUILD_PLAN.md` explicitly rejects. Codex's real failure was different and more specific: it
did not **verify**, so it inherited a hardcoded-literal palette, an `@import` that never
discarded Rofi's default theme, and a `prefer` key its matugen could not read.

**The aurora dark-glass look Alex wants is rarer in the wild than the brief assumes, and
largely has to be specified by us rather than copied.** That is not licence to build from
scratch — it is a reason to be precise about the few things genuinely worth taking, and to
verify each one against the running machine rather than against a README.

The one exception is genuinely valuable: caelestia is a **maintained** repo that already
speaks Hyprland 0.55 **native Lua** (`Hyprland.usingLua`, `hl.dsp.focus({...})`,
`hl.layer_rule({ ... blur = true })`) — the exact form our constraints mandate, working, in
production. That is rare and is the strongest reason to pull from it.

---

## 3. What gets REPLACED vs MODIFIED vs KEPT

### KEEP — do not touch
- Every T2 invariant: `linux-t2` 6.18.35, 163 Broadcom firmware files, `apple_bce`,
  `brcmfmac`, `hci_bcm4377`, `i915`, systemd-boot, `canTouchEfiVariables = false`, macOS
  dual boot, `nix-ld`, `allowUnfree`.
- **`debug.disable_scale_checks = true`** — load-bearing for Retina geometry. Removing it
  reintroduces the dead bands.
- Pinned flake + module graph, machine-local firmware adapter, `checks/preflight.sh`.
- Hyprland native-Lua module split.
- **QuickShell `PanelCoordinator` / `PanelHost`** architecture, lazy panels, native services,
  typed IPC. Only styling and layout change.
- The **`apply-wallpaper` pipeline mechanism** (lock, staged render, validate, atomic
  install). It is well built. Only the template *content* is wrong.
- `CavaService`'s on-demand gating (`running: active && MprisService.isPlaying`) — this is
  good engineering and several proposals below are rejected specifically to preserve it.
- Notification ownership model with the inactive Dunst fallback.
- Waybar as the bar.

### MODIFY
- All 8 Matugen templates (content, not pipeline).
- Waybar CSS + config (sizing, glass, workspaces module).
- QuickShell panel styling/layout (calendar structure, music sizing, WiFi content, power
  panel reorganisation).
- Hyprland: blur brightness, `ignore_alpha`, dead layer rules, keymap, input tuning.
- `screenshot-area`, `weather-fetch`, `equalizer-state` (P1 path fix).

### REPLACE
- The Rofi theme, wholesale (a complete theme, not a partial one).
- The custom wallpaper picker, and its location (out of the power panel).

### ADD
- Sidebar/dock; terminal startup experience; system-monitor view; a system/settings panel.

---

## 4. Bug fixes — root cause, fix, verification

Full evidence for each is in `ISSUE_LOG.md`. Ordered by severity.

### B1 — Waybar app-launch isolation (P0, gates everything)
- **Broken:** apps launched from the bar join `waybar.service`'s cgroup
  (`KillMode=control-group`). Restarting Waybar kills Chrome's renderers and Kitty.
- **Root cause:** `config.json` `on-click` runs commands as Waybar children.
- **Fix:** route every launch through a compositor-native exec so Hyprland is the parent:
  `hyprctl dispatch 'hl.dsp.exec_cmd("kitty")'`. The mechanism is already proven on this
  machine — Hyprland's own keybinds use `hl.dsp.exec_cmd`. Alternative:
  `systemd-run --user --scope`. **This same `hyprctl dispatch` change also fixes B2.**
- **Verify:** launch each app from the bar, confirm it is **absent** from
  `waybar.service`'s `cgroup.procs`, then deliberately restart Waybar and confirm all
  survive with tabs intact.

### B2 — Every workspace button is dead
- **Broken:** clicking workspace 2 does nothing (and 1 only *appears* to work).
- **Root cause:** Waybar's **built-in** `hyprland/workspaces` emits the legacy dispatcher
  string from compiled C++; Hyprland 0.55's Lua parser rejects it. Proven live:
  `hyprctl dispatch workspace 1` → `error: ')' expected near '1'`;
  `hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'` → `ok`. Not fixable from config.
- **Fix:** replace the built-in module with `custom/` modules calling the native form.
  **Cost:** we lose the module's automatic active/urgent state classes, so the active-state
  pill must be driven another way (a `custom` module with `exec` + `return-type: json`, or
  drawing workspaces in QuickShell). **This is a real design decision, not a one-liner.**
- **Verify:** click workspace 2; confirm the pill still tracks the real workspace when
  changed by `Super+2` and by a three-finger swipe.

### B3 — Screenshot "purple overlay"
- **Root cause:** `screenshot-area:18` — `slurp -s "${tertiary}55"` fills the **selection
  region** with tertiary at 33% alpha, and tertiary is currently pink.
- **Note for Alex:** the saved PNG is *not* tinted; slurp only draws the overlay and grim
  captures after it exits. It is a "can't see what I'm selecting" bug, not corrupted output.
- **Fix:** `-s '#00000000'` (transparent selection fill), keep `-b` dim and `-c` accent.
- **Verify:** region-select over a photo; the selection shows true colours.

### B4 — Weather is Chicago
- **Root cause:** `weather-fetch:10-13` (41.8781/-87.6298/"Chicago") and
  `WeatherService.qml:12,13,25,26`.
- **Fix:** Austin — **lat 30.2672, lon -97.7431**. Keep `America/Chicago` (correct for
  Austin). Value is duplicated in 4 places — collapse to one source of truth.
- **Verify:** panel reports Austin conditions; cache still serves stale data on failure.

### B5 — CPU and Memory open the same window
- **Root cause:** identical `"on-click": "missioncenter"` in both modules.
- **Fix:** split them. Destination depends on the system-monitor decision (§5, pending).
  Mission Center is a weak target regardless: it cannot report Intel GPU utilisation on this
  hardware and sometimes refuses its auxiliary socket.

### B6 — EasyEffects is a visible app
- **Root cause (two):** `rules.lua:20-33` gives it a float+center rule at 72% — the config
  explicitly styles it as a visible window; and its `.desktop` entry lacks `NoDisplay=true`,
  so it appears in the launcher.
- **Fix:** keep the service, remove the float rule, mask the desktop entry, never focus.
- **Verify:** absent from Rofi; never appears as a window; EQ still applies.

### B7 — Cmd+Space and the keymap
- **Root cause:** `keybinds.lua:27` binds `SUPER+Space` to **float toggle**. `SUPER+arrow`
  is **focus**; `SUPER+SHIFT+arrow` is move.
- **Note:** this is *intentional* today and documented in `docs/controls.md` — a design
  change, not a regression. Alex wants Spotlight muscle memory.
- **Fix:** design the keymap as a whole (Cmd+Space → launcher, Cmd+arrow → move/snap,
  rehome float-toggle). Piecemeal patching will collide. Update `docs/controls.md` with it.

### B8 — Rofi's illegible rows
- **Root cause:** `config.rasi:129-132` sets `text-color` for `element alternate.normal` but
  **never its `background-color`** — so those rows inherit Rofi's built-in **light** default
  while keeping light text. The dashed border is the same bug (`listview` sets no `border`).
  One root cause, two symptoms: **an incomplete theme inheriting Rofi's light defaults.**
- **Fix:** adopt a complete theme (§5, pending) rather than patching properties.

### B9 — Scrolling too sensitive
- **Status: STRONG.** `scroll_factor = 0.78` *is* applied — only a 22% reduction, nowhere
  near enough. "Fine in terminal" fits: Kitty consumes discrete line steps; GTK/Chrome
  consume continuous deltas and amplify.
- **Fix:** lower to ~0.3–0.5, tune by feel.

### B10 — disable_while_typing
- **Status: OPEN — needs one empirical test before any fix.** The setting is genuinely
  applied. The kernel exposes a proper touchpad (`PROP=5`, `EV_ABS`). Most likely libinput's
  DWT **keyboard pairing** declines to pair, because both nodes sit on `apple_bce`'s virtual
  USB host (`usb-bce-vhci`) sharing vid/pid `05AC:0280`.
- **One question from Alex settles it:** *do tap-to-click and two-finger scrolling work
  today?* They live in the same `touchpad{}` block — if they work, the block applies and the
  pairing theory holds.
- **Do not ship a fix without a before/after.**

### B11 — Delete/backspace acceleration — **NOT POSSIBLE as asked**
Wayland/libinput's repeat model is a fixed delay + fixed rate (`wl_keyboard.repeat_info`
carries two integers). There is no acceleration curve. Options: tune to `repeat_delay 400`,
`repeat_rate 20-25` (**recommended**), or add an evdev remapper (keyd/xremap) in the input
path of the laptop's only keyboard — a real reliability risk for a cosmetic gain.
**Recommend tuning. Do not promise acceleration.**

### B12 — Kitty Ctrl+Shift+T — **CONFIRMED NOT IMPLEMENTABLE**
Ctrl+T → `new_tab_with_cwd` is trivial (Kitty's default new-tab is ctrl+shift+t; Ctrl+T
currently does nothing).

**"Reopen last closed tab" does not exist and cannot be faithfully built.** Triple-confirmed:
`reopen` / `undo_close` / `last_closed` / `restore_tab` return **zero hits** in the Kitty
source; the complete tab-method list in `boss.py` is close/detach/goto/move/new/next/previous/
select/set_title — no undo. Kitty keeps **no state whatsoever** on close (`close_tab` →
`confirm_tab_close` → gone). It is a known gap in the space (Ghostty has an open request for
exactly this).

A custom kitten could at best record cwd on close and open a *fresh* tab there — **not** the
process, scrollback or splits. That is not "reopen last closed tab"; it is "new tab, somewhere
I once was". **Shipping it under that binding would be a lie to muscle memory.**

**Recommendation:** `map ctrl+t new_tab_with_cwd`; leave Ctrl+Shift+T as a second, cwd-less
`new_tab`. **Do not fake the undo.**

### B13 — "3+ windows close after resize"
**The brief files this under tiling; the evidence points elsewhere.** With Chrome's renderers
inside Waybar's cgroup, `OOMPolicy=stop` + `KillMode=control-group` means: memory pressure →
OOM killer takes a Chrome renderer → systemd stops the **whole unit** → **everything in the
cgroup dies at once**. That reads exactly as "opening more windows closed my windows".
**Not proven** — it did not reproduce this session (`NRestarts=0`, no OOM events). Fixing B1
removes the mechanism entirely. **Verify by reproduction after B1**, not by assertion.

### B15 — VA-API hardware video decode is not installed (found unprompted; take this regardless)
- **Broken:** `/run/opengl-driver/lib/dri/` contains d3d12, nouveau, r600, radeonsi, virtio_gpu
  — and **no iHD/i965**. Zero VA-API configuration exists across all 19 `.nix` files. On an
  **Intel Iris Plus G4 (Ice Lake Gen11)**.
- **Impact:** this is the direct cause of the `vaInitialize failed: unknown libva error` in our
  journal. **Chrome has been software-decoding all video since day one** — measured at **53% of
  a core for 1080p30**, on a dual-core i3, on battery.
- **Fix (~4 lines):** `hardware.graphics.extraPackages = [ pkgs.intel-media-driver ]` +
  `LIBVA_DRIVER_NAME=iHD`. Proven without a rebuild by loading the driver from the store:
  `va_openDriver() returns 0`, *Intel iHD 26.1.6*, H.264/HEVC Main10/VP9 VLD available (no AV1
  — Gen11 predates it).
- **Verify:** `vainfo` reports iHD; the Chrome error disappears; measure a 1080p YouTube tab's
  CPU before/after.
- **Note:** unrelated to the visual overhaul. It is simply a real, cheap, daily-use win that
  the audit surfaced.

### B14 — EasyEffects preset path (P1, inherited)
`equalizer-state` writes `~/.config/easyeffects/output/`; EasyEffects 8.2.4 treats that as
legacy and migrates it on every apply. Change `preset_root` to
`${XDG_DATA_HOME:-$HOME/.local/share}/easyeffects/output`.

### Deferred / needs reproduction
- Border resize shrink (B: dwindle outer-edge behaviour — needs a repro to distinguish).
- Titlebar drag without modifier (needs per-app establishment: Chrome CSD vs Kitty).
- `hyprbars` — remains rejected per `BUILD_PLAN.md` until proven stable.

---

## 5. Component decisions

> **Status of this section.** Palette, glass, Waybar, launcher, Chrome, dock, QuickShell panel
> layouts, motion, WiFi speed, Kitty and wallpaper are **DECIDED** and evidence-backed.
> GTK/icons/cursor (5.7), Hyprlock (5.10) and file-explorer/system-monitor (5.12) were still in
> research when Phase A was presented; what is already established for each is recorded there,
> and what remains open is stated as open. **Nothing is guessed.** None of the three changes the
> dependency order or the B0/B1/B2 sequence.

### 5.1 Palette architecture — the root fix — **DECIDED**

**The architecture is currently backwards.** The surfaces are already **hardcoded literals**
(`"panel": "#0b0e16"`, `@define-color aurora_background #05060b`, kitty `background
#05060b`) — they are *not* Matugen-derived at all. So the brief's instruction to "bias
surface roles toward near-black" is **already true**. The actual problems are the inverse of
what the brief assumes:

- **accents unconstrained** → pink;
- **surfaces fixed** → *nothing recolors*, which is precisely what kills the ilyamiro
  "everything recolors" feel Alex wants;
- and the opacity defect (§4) is a **hardcoded literal**, not a Matugen limitation.

Quantified across all eight templates — every one mixes hardcoded surfaces with derived
accents, which is the inversion stated above:

| template | hardcoded hex | matugen vars |
|---|---|---|
| `quickshell.json` | **8** (every surface) | 9 (every accent) |
| `gtk.css` | 8 | 9 |
| `kitty.conf` | 11 | 20 |
| `waybar.css` | 5 | 7 |
| `rofi.rasi` | 4 | 7 |
| `dunstrc` | 4 | 6 |
| `hyprland.lua` | 0 | 5 |
| `hyprlock.conf` | 0 | 6 |

Note the last two: `hyprland.lua` and `hyprlock.conf` are **fully derived** — which is
exactly why the window borders went pink (5.1b) while the panel backgrounds never move.

**The pastels are hue-correct, just too light.** This corrects my own earlier framing. It is
not that M3's +60° rotation makes pink unavoidable — it is that tone-80 lightness destroys
saturation. `set_lightness: 55` turns `#c3c1f8` into a saturated `#3731e8`. **That single
filter is most of the fix.**

Verified by sweeping **24 hues** through `blend: anchor, 0.7 | set_lightness: 58`:
**primary never lands pink — 24/24.** Two honest failure modes remain, both **detectable**:

- spring-green sources (~180° from the violet anchor) → tertiary magenta `#ff52ff`, because
  `blend` interpolates hue in HCT and a 180° target is direction-ambiguous;
- achromatic sources (`#ffee00`, `#ffffff`) collapse to dead grey `#949494`.

Gate both in `apply-wallpaper` (primary lightness ≥ 95 or saturation 0 → fall back).

**Rejected options, with reasons:**
- **`blend = false` to preserve the anchor — DEAD.** Source: `let value = if color.blend {
  harmonize(value, source) } else { value }`, then `{name}` is `MaterialDynamicColors::primary()`
  of a scheme built *from* it. Proven live: `blend=false` → `#9be7ff`, still pastel.
  `_source` and `_value` are identical raw anchors and are only usable as fixed constants.
- **Changing scheme type — does not save us.** `scheme-expressive` gives a lovely `#84d7b0`
  on *this* wallpaper, but that is luck: it deliberately rotates hue and yields `#ffaedd`
  (pink) for `#ffee00`. Worth noting: `scheme-vibrant`/`fruit-salad` *do* give a genuinely
  blue-undertone surface (`#13121c`) vs scheme-content's neutral `#131316`.
- **True in-template hue clamping — IMPOSSIBLE on 4.0.0.** Matugen 4.0 has **no arithmetic
  and no comparison operators**; `if` is truthiness-only.

**Recommended architecture (verified end-to-end, valid output):**

1. **Upgrade matugen 4.0.0 → 4.1.0** so `prefer = "closest-to-fallback"` finally works —
   biasing *source selection* toward teal at the root, which is real adaptivity rather than a
   fixed anchor. **Requires `apply-wallpaper` to stop passing `--source-color-index 0`**, and
   note `prefer` becomes mandatory for non-interactive runs on 4.1.0.
2. **Templates** do `blend` + `set_lightness` + `set_alpha`.
3. **`apply-wallpaper`** gates the achromatic / hue-antipode cases.

```json
"panel":   "#9e{{ aurora.panel | to_color | format: "hex_stripped" }}",
"primary": "{{ colors.primary.default.default | blend: {{ aurora.accent | to_color }}, 0.7 | set_lightness: 58 | format: "hex" }}"
```

→ `"panel": "#9e0a0e1a"`, `"primary": "#65c3b8"` (**teal, from the violet wallpaper**),
`"tertiary": "#a86ee3"` (**violet, not pink**).

**Matugen 4.0 syntax notes that will bite otherwise** (4.0 uses its own engine, **not Tera** —
all older Tera documentation is wrong):
- `.default.default` is the **pipeable colour object**; `.hex` is a plain string. You must
  pipe the object.
- Colour arguments need nested `to_color`: `blend: {{ "#00d4aa" | to_color }}, 0.7`.
- `hex` emits lowercase but `hex_alpha` emits **UPPERCASE**.
- **Never** pipe hex through `lower_case` — it word-splits into `rgba(00 d 4 aaff)`.

### 5.1a Alpha per consumer — and a QML trap

⚠️ **QML uses `#AARRGGBB`; matugen's `hex_alpha` emits `#RRGGBBAA`. QML will silently
misread it.** Use the `"#9e" + hex_stripped` concatenation for QuickShell.

| Consumer | Emit | Result |
|---|---|---|
| QuickShell | `"#9e{{… \| format:"hex_stripped"}}"` | `0x9e` = 0.62 |
| Waybar / GTK | `{{… \| set_alpha: 0.62 \| format: "rgba" }}` | `rgba(10,14,26,0.62)` |
| Rofi | `{{… \| set_alpha: 0.62 \| format: "hex_alpha" }}` | `#0A0E1A9E` |
| Hyprland Lua | `rgba({{… \| set_alpha: 0.62 \| format: "hex_alpha_stripped" }})` | `rgba(0A0E1A9E)` |

0.62 sits mid-window and clears `ignore_alpha`.

### 5.1b Missing consumers — enumerated

| Surface | State |
|---|---|
| **Chrome** | **Nothing at all.** See 5.6. |
| **SwayOSD** | `swayosd.css:1` imports waybar.css, then `:6` **overrides it** with hardcoded `rgba(3,3,8,0.88)`. Worse, `:45` is `linear-gradient(90deg, @aurora_tertiary, @aurora_primary 56%, @aurora_secondary)` — a **sharp linear gradient** (banned by the spec) running **pink → lavender → grey**. |
| **Screenshot selector** | `screenshot-area` shells to `jq` at runtime, hardcodes `-b '#030308cc'`, and uses `tertiary` — currently pink (B3). |
| **Hyprland borders** | Consumes the palette, and **tertiary is the first gradient stop** — confirmed live: `colors = { "rgba(f1b5dbff)", "rgba(c3c1f8ff)", "rgba(c6c4dcff)" }`. **Your window borders are literally pink → lavender → grey**, overriding the correct hardcoded aurora colours in `general.lua`. |
| Kitty | Fine — all 16 ANSI colours present. |

**Mechanical acceptance gate (belongs in `checks/`):** re-render all twelve wallpapers and
assert every generated primary/secondary/tertiary sits within the intended hue window and
above a minimum saturation. Not an eye check — **the eye is what failed last time.**

### 5.1c One idea worth considering: invert the pipeline

mubin's wiki recommends **`gowall`**, which converts *the wallpaper to match the theme* —
the exact inverse of Matugen. `gowall convert wall.jpg -t <theme>` then Matugen on the
converted image would make pink **structurally impossible**. It is the one genuinely
interesting idea salvaged from that repo. It does change how the wallpaper itself looks,
which may or may not be acceptable to Alex — worth a decision, not a silent adoption.

### 5.2 Glass — **DECIDED**, with one latent bug and one large perf win

Blur plumbing is correct (§1.2, verified live). Required changes:

**(a) Emit alpha from the templates.** The 6-digit hex is the primary bug. ⚠️ **Qt hex is
`#AARRGGBB`, not `#RRGGBBAA`** — a very common mistake, and matugen's `hex_alpha` emits the
*wrong* order for QML. Use the `"#99" + hex_stripped` concatenation. Values: 0.55=`8C`,
0.60=`99`, 0.65=`A6` → `#990a0e1a`. Also note `#0b0e16` is **truthy**, which is why
`palette.panel || fallback` always picks the opaque value.

Targets: panels **0.55–0.65**; Waybar likewise; **terminal stays 0.82–0.88** (deliberately
more opaque — you must be able to read code; do not naively push Kitty to 0.55).

**(b) `ignore_alpha = 0.50` is a latent second bug — fix it to `0.10`.**
Semantics confirmed in `ConfigValues.cpp:241` ("if pixel opacity is below set value, will not
blur"). But the shader detail matters. In `surface.frag`, the fade multiplier is applied
**first** (`pixColor *= alpha`), and only then is the discard tested — so in the blur path the
real test is:

> `(bufferAlpha × fadeAlpha) <= ignore_alpha`

At `ignore_alpha = 0.50` with a 0.55 panel: statically it blurs, but with only **9% margin**;
and during *any* fade it crosses 0.50 at fade = **0.909**, so **blur snaps on in the last 9%
of the panel's fade-in — a visible pop** on every open. This directly couples to the panel
open animation (5.8).

`0.10` gives 5.5× headroom under a 0.55 floor while still discarding near-zero alpha.
Hyprland's own internal fallback is `valueOr(0.01)` ("ignore the alpha 0 regions"). The knob's
only job is discarding the transparent surround and outside-the-rounded-corner pixels.
**Caveat: do not paint QML drop-shadows outside the panel rect** — anything above 0.10 alpha
gets blurred into a halo.

This **supersedes** caelestia's `base - 0.03` idiom, which is precisely the too-tight setting
that causes the fade pop.

**(c) `xray = true` — the big perf win we are currently missing.**
`OpenGL.cpp:1053`: a layer with `xray` uses the monitor's **precomputed `m_blurFB`** — the
pre-blurred wallpaper, computed once when the background changes and cached — instead of
running live dual-Kawase **every frame**. Requires `decoration:blur:new_optimizations = true`.

This is *literally* "northern lights through a frosted window": always the wallpaper, never
the windows behind it. On a dual-core i3 / Iris Plus this is plausibly the difference between
affordable and not. **Trade-off:** a window behind the panel will not show through — which is
exactly the aesthetic Alex asked for anyway.

```lua
hl.config({ decoration = { blur = {
  enabled = true,
  new_optimizations = true,        -- REQUIRED for xray
  size = 8, passes = 2,            -- start at 2; raise to 3 only if frame time holds
  brightness = 1.0,                -- was 0.84, which darkened the blur
}}})

hl.layer_rule({
  name = "aurora-panels",          -- named => re-callable to update in place
  match = { namespace = "aurora-.*" },
  blur = true,
  ignore_alpha = 0.10,
  xray = true,
})
```

Valid Lua field names confirmed in `LuaBindingsConfigRules.cpp:178-189`: `no_anim, blur,
blur_popups, ignore_alpha, dim_around, xray, animation, order, above_lock, no_screen_share`.

**(d) Do NOT use QuickShell's `BackgroundEffect.blurRegion`.** QuickShell 0.3.0 *does* ship it
(via `ext-background-effect-v1`), but **Hyprland 0.55.0 does not implement that protocol** —
verified against its full CMake protocol list and a repo-wide grep. `BackgroundEffectManager::
instance()` returns nullptr and the property **silently does nothing**.

**(e) Do NOT attempt a QML-side blur fallback.** The key conceptual point: **a QuickShell
surface cannot see what is behind it** — that is exactly why the protocol above exists.
`MultiEffect`/`FastBlur` can only blur pixels inside your own scene, so a "QML fallback" means
loading the wallpaper yourself, cropping to the panel's screen rect and drawing a **replica**.
That is what ilyamiro's `Lock.qml` does, and it works there only because the lock surface owns
the whole screen. For panels it is strictly worse than `xray`: same aesthetic result, but you
pay the blur in-process every frame *and* must track wallpaper changes, scale and per-monitor
position yourself. Keep MultiEffect for the lock screen only.

**(f) Clean up the five dead layer rules** (§4a) so the config stops implying coverage it
does not have.

**Live A/B verification** (`hyprctl eval` runs arbitrary Lua; re-calling a *named* rule updates
it in place — so this needs no reload and no file edit):

```sh
hyprctl eval 'hl.layer_rule({name="aurora-panels", match={namespace="aurora-.*"}, blur=false})'
hyprctl eval 'hl.layer_rule({name="aurora-panels", match={namespace="aurora-.*"}, blur=true, ignore_alpha=0.10, xray=true})'
```

Screenshot both. This doubles as the live `ignore_alpha` sweep.

**Acceptance:** panel over a **sharp wallpaper edge**. Smeared = frosted (correct).
Crisp-but-dimmed = alpha only, rule not matching. Solid = neither (palette bug).

> **Note on a near-miss.** The research initially concluded our namespace regex `quickshell:.*`
> could never match, since QuickShell 0.3.0's *default* namespace is the bare literal
> `quickshell` and Hyprland matches with `RE2::FullMatch`. That is true and valuable — but it
> **is not our bug**, because `PanelHost.qml:83` sets `WlrLayershell.namespace:
> "aurora-panel-" + panelName` explicitly, and `hyprctl layers` confirms `aurora-taskbar` live.
> Our `aurora-.*` rule matches. The `quickshell:.*` rule is simply dead weight (§4a).
> Recorded because it is exactly the kind of plausible-but-wrong finding that must be checked
> against the running machine rather than adopted.

### 5.3 Sidebar / dock — **DECIDED**
**QuickShell-native, left-anchored, 56px, space-reserving, static.** Not nwg-dock.

- **Why QuickShell:** a new `aurora-dock` namespace inherits `blur = true` from the existing
  `aurora-.*` glob with **zero new config** (confirmed live), plus `Tokens.qml` hot-reload
  and shared motion curves. nwg-dock inherits none of it: a 4th Matugen template, GTK CSS
  (which cannot do backdrop blur anyway), a separate process, and unstyled GTK context menus.
- **Must NOT join `PanelCoordinator`** — that is a modal, mutually-exclusive, top-right host.
  A dock that closes the music panel by existing is a bug. Build a sibling window.
- **Left, not bottom:** width is the abundant axis; height is already taxed by the 46px bar.
  Left dock → tiling halves of ~811px (clears Chrome's 768 breakpoint). Bottom dock → Kitty
  ~468px ≈ 26 lines, and total vertical chrome 110px = 10.3% of 1067.
- **Reserve, don't auto-hide:** the complaint is *aesthetic* ("feels incomplete"). An
  auto-hidden dock is invisible and therefore cannot fix a visual problem.
- **Content: pinned apps + running windows ONLY.** That gap is real (Waybar has no window
  list; Rofi is a launcher, not a switcher). Everything else proposed —
  visualiser/music/weather/launcher/notifications — **duplicates an existing panel**. A
  permanent cava visualiser additionally breaks `CavaService`'s on-demand gate.
- **Perf:** a static dock is ≈free — Hyprland only re-blurs on damage. An animated one is
  the trap.
- **Adapt from:** `ekremx25/quickshell` dock QML (discard its runtime `dock_config.json` —
  it writes at runtime and will fail on read-only Nix store symlinks); caelestia's
  reserve-vs-hover and slide idioms.

### 5.4 Waybar — **DECIDED**

**Recommendation:** elifouts *mechanics* + GlassesArch *geometry* + LinuxBeginnings'
`ML4W-Glass-3d.css` *radial-gradient technique* + Sharddots *blur params* + a **fixed**
(non-wallpaper-derived) accent identity.

Height 40 is **in spec** — the brief is right that density, not height, is the problem.

| | Ours | Best candidate | **Proposed** |
|---|---|---|---|
| bar height | 40 | auto (elifouts) | **40** (keep) |
| section bg | `rgba(5,6,11,0.82)` | `alpha(@bg,.6)` | **`rgba(10,14,26,0.60)`** |
| border | `alpha(@purple,0.24)` | — | **`1px rgba(255,255,255,0.08)`** |
| radius | 10 | 12–15 | **12 sections / 8 modules** |
| font | Inter 12/600 | Inter 15 | **Inter 13/500** |
| module padding | `0 7px` | `4px 14px` | **`0 10px`** |
| **media button** | **min-width 24, `0 6px`** | — | **min-width 32, `0 8px`** |
| workspace button | min-width 25 | 30 | **34** |
| hover | colour→teal, 160ms | — | **`rgba(255,255,255,0.06)` + `shade()`, 100ms** |

Replacing the banned sharp linear gradient with diffuse aurora (the ML4W technique):

```css
background:
  radial-gradient(ellipse 120% 180% at 30% 140%, alpha(@teal,0.55), transparent 70%),
  radial-gradient(ellipse 100% 160% at 75% -40%, alpha(@cyan,0.45), transparent 65%),
  alpha(@raised, 0.5);
```

**GTK3 facts that change the plan:**
- **There is no `backdrop-filter` in GTK3.** The spec's "blur(12-16px)" is not a CSS
  property — blur comes *only* from `hl.layer_rule({ ... blur = true })`.
- **`ignore_alpha` is a threshold**: "makes blur ignore pixels with opacity of `a` **or
  lower**". A 0.55 bar with `ignore_alpha 0.6` gets **zero blur**. It must sit strictly
  between 0 (transparent gaps) and the lowest surface alpha — **recommend 0.3**; our current
  0.50 against a 0.60 target is uncomfortably tight.
- **`opacity:` composites the whole widget** and fades text with it. Use `alpha()`.
  (Crystal-Clear-Glass, Sharddots and ML4W all commit this.)
- `radial-gradient` **is** supported. `shade(@c, 1.15)` exists → the spec's "hover =
  brightness, not colour".
- **GTK3 ignores fractional scale** (no `wp_fractional_scale_v1`), so Waybar renders at an
  integer scale and Hyprland rescales to 1.5 → mild softness. Unavoidable; note it.

**Width @1707:** proposed padding lands ≈**1570/1707** — fits, but `wlr/taskbar` is
**unbounded** and at ~8 apps reaches ~1698. **The taskbar must be capped and the clock
shortened** (`󰥔 {:%H:%M}`, date → tooltip).

**On B2:** `custom/` modules with `return-type: json` **do** support `class` (string or
array) → `#custom-ws1.active`, plus `{alt}` + `format-icons` and `:hover`. Use one module
per workspace with a persistent `-F`-style listener. Note **every** candidate's workspace
styling dies here (all use `#workspaces button.active`), so this is a wash and must not
drive the candidate choice.

**To test:** whether GTK3's `alpha()` *sets* or *multiplies* on an already-alpha colour —
our `@base` bakes in 0.82. Safer: make `@base` opaque in the template and apply alpha in the
stylesheet.

### 5.5 Launcher — **DECIDED: build a QuickShell-native launcher**

The X11 theory is **refuted** (Rofi is 2.0.0, `wayland: selected`) — but **click-away is
genuinely impossible on Rofi today**, for a different reason. Source diff:

| | `click_to_exit` refs in `source/wayland/display.c` |
|---|---|
| **rofi 2.0.0 (ours)** | **0** |
| `next` branch | 10 |

Rofi 2.0.0's Wayland backend **never reads `click-to-exit`** — our setting is silently dead
config. The fix (PR #2272, *"wayland: implement click-to-exit using fullscreen capture
surface"*) merged **2026-03-20** into `next` and is **unreleased**; 2.0.0 remains the latest
release. So: no, not achievable without tracking unreleased git.

**Why QuickShell wins rather than fuzzel/anyrun:** `hyprland_focus_grab_v1` is *purpose-built*
for this and **already works in 7 of our panels**. Every layer-shell launcher hits the same
wall Rofi hit and works around it with capture surfaces or focus-loss heuristics. Fuzzel's
click-outside is focus-loss only (wallpaper-click **unverified**); anyrun is GTK4 CSS with no
Matugen path.

**"Don't build UI from scratch" does not bite here** — there is nothing to lift: caelestia's
launcher needs a C++ SQLite plugin and is GPL-3; DankMaterialShell's is 10k lines with 587
`Theme` refs; end-4's binds to a 418-line singleton; noctalia **abandoned QuickShell** for
C++/OpenGL. Meanwhile QuickShell 0.3.0 already ships everything needed — verified present in
our installed `.qmltypes`: `DesktopEntries.applications`, `DesktopEntry.icon/execString/execute()`,
`Quickshell.iconPath()`.

**Scope ≈ 200–350 LOC** — comparable to our existing `BluetoothPanel` (159) or `NetworkPanel`
(186): add `"launcher"` to `PanelCoordinator.knownPanels`; a ~30-line apps service; vendor
`fuzzysort.js` (MIT, from upstream — *not* laundered out of the GPL shells); ~150-line
`LauncherPanel.qml`; generalise `PanelHost` for centred placement; point `rofi-toggle` at an
IPC toggle, keeping both the Waybar Apps button and bare Super.
**Bonus on a dual-core i3:** QuickShell is already resident, so it opens instantly instead of
forking Rofi on every press — strictly cheaper than today.

**Stopgap available today (one line):** `@theme "/dev/null"` + alpha → ~0.6 fixes legibility,
the dashed border and the glass immediately, while leaving click-away broken until upstream
ships 2.1. Reasonable as a bridge while the QuickShell launcher lands.

**Side-fix:** `icon-theme: "Adwaita"` → **Papirus**.

### 5.6 Chrome — **SOLVED**

Not GTK, not flags, not an extension. **`BrowserThemeColor` enterprise policy.** Verified by
grepping the actual Chrome 149 binary on this machine: `BrowserThemeColor` and
`refresh-platform-policy` are **present**; `BrowserColorScheme` (what Omarchy writes) and
`WebUIDarkMode` are **absent — they are no-ops here.**

```nix
# NixOS module, NOT Home Manager: Chrome hardcodes /etc/opt/chrome/policies
# with no $HOME fallback (verified absent from the binary).
programs.chromium = {          # misleadingly named — nixpkgs writes /etc/opt/chrome too
  enable = true;
  extraOpts.BrowserThemeColor = "#151b2a";
};
```

Chain verified in chromium source: policy → pref `autogenerated.theme.policy.color` →
`theme_service.cc`: `if (UsingPolicyTheme()) { BuildAutogeneratedPolicyTheme(); return; }`.
That early return is **why it beats GTK, the user theme and Customize-Chrome**.
`BuildFromColor` sets `COLOR_FRAME_ACTIVE` + `COLOR_TOOLBAR` with auto-contrast text — a dark
seed kills the white titlebar **and** the white bookmark bar.

**Correction to the brief's framing:** in CSD mode on Wayland the "title bar" *is* the
tab-strip area = `COLOR_FRAME_ACTIVE`. So theming `frame` fixes it **without** touching
decoration mode. Leave "Use system title bar" **off**.

Live refresh: `google-chrome-stable --refresh-platform-policy --no-startup-window`.

**Honest limits:** one seed colour only (frame ≠ toolbar would need a theme extension);
"Managed by your organization" will appear in the menu; `programs.chromium.commandLineArgs`
**does not exist**; `~/.config/chrome-flags.conf` is an Arch launcher convention that does
nothing on NixOS. **Unverified:** the Matugen-driven variant (a tmpfiles `L+` symlink from
`/etc/opt/chrome/policies/managed/` into our cache) — confirm at `chrome://policy`.

Audit the result against mubin's one salvageable artefact: its checklist of the **nine
browser surfaces** (toolbar, background, search bar, tab highlight, popup bg/text,
icons/text, background-tab text, search text).

### 5.7 GTK / icons / cursor — **DECIDED**

#### Root cause: **libadwaita never enters dark mode.** One line fixes it.

Proven from the evaluated config:

```
gtk-4.0/settings.ini → gtk-application-prefer-dark-theme=1   ← libadwaita IGNORES this + warns
gtk.colorScheme = null
dconf org/gnome/desktop/interface = {cursor-size, cursor-theme, font-name, gtk-theme, icon-theme}
                                     ← NO color-scheme key
```

libadwaita's dark values live behind `@media (prefers-color-scheme: dark)`, driven by
`color-scheme` via the portal/gsettings — **which we never set**. So it runs the **light**
stylesheet, our ~9 overrides punch dark holes into it, and ~30 unoverridden colours stay light
(`dialog_bg_color #fafafb`, `thumbnail_bg_color #ffffff`, `scrollbar_outline_color white`).
**Pale-lavender accent over light surfaces is exactly the "mauve wash".**

**Fix:** `gtk.colorScheme = "dark"` (writes `color-scheme = "prefer-dark"` +
`gtk-interface-color-scheme = 2`; enum verified DARK=2), plus override the **full** name set
rather than nine of them. Suppress libadwaita's warning with
`gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = false`.

#### The mechanism does work — one palette can theme both toolkits

Traced end-to-end in source (libadwaita 1.9.0, GTK 4.22.4, GTK 3.24.52):
- `~/.config/gtk-{3,4}.0/gtk.css` loads at `GTK_STYLE_PROVIDER_PRIORITY_USER` (800); both
  cascades resolve highest-priority-first, first match wins → **USER beats libadwaita's THEME
  (200)**.
- libadwaita 1.9 widgets use **only** `var(--window-bg-color)`, bridged by
  `:root { --window-bg-color: @window_bg_color; }` → **our `@define-color` wins**.
- **adw-gtk3 deliberately mirrors libadwaita's exact named-colour API** — same names, both
  toolkits.
- `@define-color` is deprecated in GTK 4.22 but the warning is gated behind `DEBUG_CHECK_CSS` —
  silent in normal use. **Future risk, not current.**
- libadwaita's accent API is a **9-value enum**; even the portal's arbitrary RGB gets snapped
  via `adw_accent_color_nearest_from_rgba()`. So **GNOME 47+ accent support makes things worse,
  not better** — `@define-color accent_bg_color` is the *only* way to carry a wallpaper hex.

#### Runtime recolour: **restart required — honest answer**

`settings_init_style()` holds a **static `GtkCssProvider`**, `load_from_path` once, **no
GFileMonitor** — in *both* GTK3 and GTK4. User CSS is never re-read. The gsettings theme-toggle
hack (which one reference build uses) **cannot help us**: it reloads only the *theme* provider,
and our colours live in the **USER** provider.

Our `@import` indirection (HM read-only symlink → writable cache) is architecturally **sound**;
new processes pick up new colours. **Keep it.** GTK apps recolour on restart — state that
plainly rather than implying live recolour.

#### Keep adw-gtk3-dark — measured, not aesthetic

Override surface is the decisive criterion for a wallpaper-adaptive system:

| Theme | literal colours | named refs |
|---|---|---|
| **adw-gtk3-dark** | 317 | **1313** |
| Tokyo Night | 1043 | 93 |
| Colloid | 1034 | 92 |
| Orchis | 934 | 84 |

adw-gtk3 is **~14× more override-friendly**. Colloid/Orchis/Tokyo Night **bake their palette
into ~1000 literals** `@define-color` cannot touch — they would need per-wallpaper SCSS
regeneration (imperative, slow, against our constraints).

**Thunar's "dated" look is a separate, fixable thing:** adw-gtk3-dark hardcodes **GNOME neutral
greys with zero blue undertone** (`dialog_bg_color #36363a`, `sidebar_backdrop_color #28282c`,
`thumbnail_bg_color #39393d`) and we do not override them. Add them to the override set.

#### Icons — fixed pack, recoloured declaratively at build time

`papirus-icon-theme.override { color = "teal"; }` — nixpkgs runs `papirus-folders` **inside the
derivation**, so it is fully declarative. Papirus ships `folder-teal/cyan/darkcyan/violet`.
**Per-wallpaper recolour is impractical** (build-time = a Nix rebuild per wallpaper, and
papirus-folders accepts ~30 preset names, not hex); runtime recolour is a non-starter — it
mutates a read-only store path. Fix Rofi's `icon-theme: "Adwaita"` → `"Papirus-Dark"`.

#### Cursor — **keep Adwaita@24**; the brief's assumption is backwards

Parsed from the xcursor binary TOCs:

- **`Adwaita`: [24, 30, 36, 48, 72, 96]** — ships **36 = 24 × 1.5**
- `Bibata-Modern-Ice`: [16,20,22,24,28,**32**,40,**48**,56,64…] — **no 36**

Adwaita ships 30/36 *specifically for* 1.25/1.5 fractional scaling. **Our current Adwaita@24 is
already correct**; switching to Bibata@24 would be a **regression**. If Bibata is wanted for
looks, it must run at **size 32 → 48 physical**. (Bibata-Modern-Ice is solid white with a black
outline — reads well on dark glass; "Ice" is a colour name, it is *not* translucent as the
brief assumed.) `hyprcursor` does not rescue this — `bibata-hyprcursor` **is not in nixpkgs**.

⚠️ **Blocker if we do switch:** `desktop-apps.nix` sets `gtk.cursorTheme` **explicitly**, while
HM's `home.pointerCursor` sets it via `mkDefault` — **explicit wins, so Adwaita would silently
override Bibata**. That line must be removed first.

#### GTK app glass — possible, but **advise against**

The "libadwaita forbids transparency" claim is **false** (GTK3's `update_opaque_region()` keys
off CSS background alpha; GTK4 infers from the rendernode; `adw-window.c` has zero
`opaque`/`transparent`). But Hyprland's `opacity` window rule multiplies the **whole texture
including text** (`surface.frag`: `pixColor.a * alpha`) — that is translucency, **not glass**.
Real glass needs alpha on *every* layer (window/view/headerbar/sidebar/popover/card); miss one
and you get an opaque slab — and `view_bg` is most of Thunar. Plus fullscreen kawase every
frame on a dual-core i3 + Iris Plus on battery.

**Recommendation: keep glass on layer-shell surfaces (Waybar / launcher / panels / notifications)
— which our config already does.** The brief's *"the file explorer must match the desktop's
glass aesthetic"* is **not fully achievable**; deliver a properly dark, blue-undertoned,
accent-matched Thunar instead, and say so rather than half-delivering glass.

> **Correction to my own earlier reasoning.** I recorded that EasyEffects is a GTK4/libadwaita
> app and inferred from its mauve window that "some GTK4 theming is landing". **That is wrong.**
> EasyEffects 8.2.4 is **Qt6/Kirigami** (`qtbase-6.11.0`, `kirigami-6.27.0`; no libadwaita, no
> gtk4). Its mauve is our *Qt* stack — `qt.platformTheme.name = "gtk3"` + `qt.style.name =
> "adwaita-dark"` bridging GTK3's colours into QPalette. The real libadwaita apps here are
> `mission-center` and `pwvucontrol`; **Thunar links `libgtk-3`** (verified by `ldd`). The one
> piece of evidence I used to reason about libadwaita said nothing about it.

### 5.10 Hyprlock — **DECIDED**

#### The transition: **No. Hyprlock cannot do it.** Verified against installed v0.9.5 source.

`ConfigManager.cpp:360-374` creates **exactly 8 animation nodes**: `global → fade → {fadeIn,
fadeOut}` and `inputField → {inputFieldColors, inputFieldFade, inputFieldWidth,
inputFieldDots}`. **No `label` node. No `image` node.** Labels expose no opacity, no
visibility, no conditional — **the avatar and username cannot fade, move or scale.** The only
interaction-driven visibility is `fade_on_empty`, and `updateFade()` keys on `passwordLength >
0` — it reveals only after the **first keystroke**, not on mouse movement.

**Why the reference has it:** ilyamiro's lock is a **QuickShell QML lock** (`Lock.qml:322`
`inputActive = true`; `:339` `opacity: inputActive ? 0.0 : 1.0`). That is a QML-only
capability. Its "circular vignette" is also not a vignette — it is **two slowly-orbiting
translucent circles** at 3–8% opacity over a `MultiEffect` blur.

**A custom PAM lock stays out of scope.** `BUILD_PLAN.md` deferred it as crash-risky and that
holds: a broken lock is a locked-out laptop.

**Best achievable, honestly:** one always-composed layout (clock, date, avatar, username, pill
all permanently visible) plus the motions that are real — `fadeIn`/`fadeOut` (the main
cinematic beat), and **`placeholder_text` "ENTER PIN" → dots**, which is a genuine state change
(`PasswordInputField.cpp:332` unloads the placeholder the instant `passwordLength != 0`) and is
the honest substitute for the target. **Do not set `fade_on_empty = 1`** — labels cannot fade,
so a pill blinking in beside a frozen avatar reads as broken. `inputFieldWidth` is unreliable:
`updateWidth()` uses `max(placeholder_width + height, configSize.x)`, so with a 300px pill it
**never fires**.

#### Four dead config options — a real live bug

**`grace`, `no_fade_in`, `no_fade_out`, `disable_loading_bar` do not exist in v0.9.5.** `grace`
survives **only as a CLI flag** (`main.cpp:29`). The generated store config emits all four, and
hyprlock logs *"Config has errors … Proceeding ignoring faulty entries"*. **So `grace = 1` is
doing nothing — there is no grace period today.** Delete all four; if grace is wanted it moves
to hypridle as `hyprlock --grace 1`.

#### Hyprlock has **no vignette option** — bake it

Not in v0.9.5, not in `main`. Background supports only `blur_size, blur_passes, noise, contrast,
brightness, vibrancy, vibrancy_darkness, zindex, reload_time, reload_cmd, crossfade_time`.
**Our current "vignette" is a 660×660 hard-edged opaque disc** (`rounding = -1` → `min(w,h)/2`)
at alpha `0xe8` = **91% opaque** — it fails the see-through test outright.

Bake it with ImageMagick instead (IM 7.1.2 is already a transitive dep; this makes it a
declared one). Build-time gradient composite (~6.0s, wallpaper-independent) + a runtime
composite in `apply-wallpaper` (~3.3s), staged through the existing atomic path as
`$auroraLockBg` alongside `$auroraWallpaper`. Rendered and viewed: a genuine soft circular
vignette with visible soft seafoam + violet orbs — **strictly better than hyprlock `shape`
circles, which render hard edges that band visibly at low alpha over a smooth blur.**

#### Perf: the premise is backwards — blur is **one-time, not per-frame**

`Background.cpp:120`: blur renders into a **cached framebuffer once at lock**
(`!blurredFB->isAllocated() || firstRender`); line 152 returns the cached texture thereafter.
The ticking clock just samples it. **So `blur_passes = 4` is affordable on Iris Plus** — the
cost is a one-off hitch at lock, invisible behind `fadeIn`.

**Do NOT pre-blur the image.** `blurFB` is only called `if (blurPasses > 0)`, and
`noise`/`contrast`/`brightness`/`vibrancy` are passed **only inside that call** — so
`blur_passes = 0` **silently discards all four**. Live GPU blur wins on every axis. Bake only
the vignette; let the GPU blur.

#### Values

`blur_passes = 4`, `blur_size = 5` (smaller offset + more passes = smoother, less ringing),
`noise = 0.015` (anti-banding — functional, not decoration), `contrast = 0.92`,
**`brightness = 0.65`**, `vibrancy = 0.25`, `vibrancy_darkness = 0.30`, `path = $auroraLockBg`.

> Empirically self-corrected: the first instinct was `brightness = 0.40`. Rendered, it was
> **near-black and destroyed the aurora** — the baked vignette and `brightness` *multiply*. A
> rendered 0.60/0.78/0.92 comparison strip puts the sweet spot at **0.60–0.70**.

Pill: `size = 300, 58`, **`rounding = -1`** (a true pill = 29; ours is 12, i.e. **not a pill**),
`outline_thickness = 1` (ours is 2), `outer_color = rgba(ffffff1f)` (12% white hairline, not a
saturated ring), **`inner_color = rgba(0a0e1a8c)` (55% — wallpaper visible, passes the test)**.
Drop the 660px disc entirely and let the composition float on the baked vignette.

Type, all verified present via `fc-match` — Inter 4.1 ships **Inter Display**: clock
`Inter Display Light` **116** (was 80); date **22**; avatar **132**; username
`Inter Display Medium` **23**; status `FiraCode Nerd Font` **15**. Units are **logical px**
(1707×1067). Everything up ~30% to answer "too small".

⚠️ **A real Home Manager gotcha:** `handleAnimation` resolves the bezier **at parse time** and
silently falls back to `"default"` if it is not yet defined — and HM's `toHyprconf` renders
lists **alphabetically**, so `animation=` emits **before** `bezier=` and the curve is silently
dropped. Only `linear` is built in. Fix with the module's own option:
`programs.hyprlock.importantPrefixes = [ "$" "bezier" ];`

### 5.12 File explorer + system monitor — **DECIDED**

#### File manager: **stay on Thunar**

**The reference premise is false again.** `saatvik333/hyprland-dotfiles` → `variables.conf`:
**`$fileManager = thunar`** — it is the same thing we already run. Its theme is Colloid via git
submodule + `install.sh` (our imperative anti-pattern), its "glass" is one line
(`windowrule = opacity 0.90 0.90, class:^(thunar)$`), and the repo is **abandoned** (author
moved to Niri). The "cleaner file explorer" in its screenshots is almost certainly **Yazi, a
TUI in Alacritty — the glass comes from the terminal, not the file manager.**

**Glass on a GTK window: mechanically possible, aesthetically no.** Hyprland's `opacity` rule
is a compositor alpha multiply applied *after* the app renders — **it hits the glyphs too**.
That is the categorical difference from Kitty, which alphas only its background and keeps text
opaque. Evidence: the one real glassed Nautilus found has **file labels washed to
near-invisible ghosts**; ML4W's own hero shot keeps Nautilus **deliberately opaque** beside a
glass terminal. **Zero screenshots of a glassed Thunar or Nemo exist anywhere — the scarcity is
the finding.** Also `decoration:blur:popups` defaults **false**, so menus would not blur.

**Verdict: spend the glass budget on layer-shell (Waybar/launcher/panels) and Kitty; make the
file manager an opaque blue-undertone surface.** The brief's *"the file explorer must match the
desktop's glass aesthetic"* is not achievable as written — say so rather than half-deliver it.

Ranking: **Thunar** (GTK3 — our `@define-color` layer lands; the **only one with a real NixOS
module**; zero migration) > **Nemo** (GTK3 but no module, drags cinnamon-desktop+xapp) >
**Nautilus** (`nautilus-50.1` pulls **`tinysparql` + `localsearch`** — a filesystem indexer on a
dual-core/8GB/battery; GTK4+libadwaita fighting our pipeline; no module).

**Two live bugs found:**
- **Thunar's plugins are silently dead right now.** `desktop.nix` declares `programs.thunar`
  (which builds `thunar-with-plugins`) *and* lists bare `thunar` in
  `environment.systemPackages`. They collide on `bin/thunar` and **the plain build wins** —
  `/run/current-system/sw/bin/thunar` resolves to the plugin-less store path. **Remove `thunar`
  from the systemPackages line.**
- `gtk.css` sets `window_bg_color #05060b` — **below our own `#0a0e1a..#131729` floor**. That is
  exactly why it reads as generic dark mode. Raise to `#0a0e1a`, view `#0d1220`, headerbar
  `#101529`, card/popover `#131729`, plus `inset 0 -1px rgba(255,255,255,0.08)` hairlines to get
  the glass *border language* without transparency.

#### System monitor: **btop**, aurora-themed, in Kitty on workspace 2

**The "btop is expensive on a dual-core" premise is wrong — measured on this i3-1000NG4:**
btop @2000ms = **0.40%** of one core; @4000ms = **0.17%**; bottom = 1.33%; htop = **3.83%**.
**btop is the cheapest by 3–10×.** (saatvik333 has no process monitor at all — its only
terminal display is fastfetch.)

**The glass chain is the whole aesthetic:** `theme[main_bg]=""` + `theme_background = false` →
btop uses the terminal default → Kitty `background_opacity 0.88` → Hyprland blur → **the
wallpaper bleeds through btop.** Northern lights through a frosted window, literally — and it
works *because* Kitty self-alphas rather than relying on a compositor multiply.

```lua
hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true, default_name = "system",
    on_created_empty = "kitty --class aurora-sysmon -o font_size=14 -o window_padding_width=18 "
        .. "-e /run/wrappers/bin/btop --themes-dir /home/alex/.cache/aurora-theme" })
```

⚠️ **Intel iGPU needs a system-level wrapper — the one thing HM cannot do.** nixpkgs btop is
built `BTOP_GPU=ON` and `/sys/devices/i915` PMU exists, but `perf_event_paranoid = 2` blocks it
— caught failing live (*"WARNING: Intel GPU: Failed to initialize PMU"*). Needs
`security.wrappers.btop` with `cap_perfmon,cap_dac_read_search=ep`.

**Matugen theme — verified end-to-end.** The key list is **exactly 48 keys** from
`btop_theme.cpp`'s `Default_theme` map — *not* the README, and *not* the shipped
`catppuccin_mocha.theme` (those are 42-key bashtop-era files missing `proc_pause_bg`,
`followed_fg`, etc). The template was **rendered with real matugen 4.0.0 against the current
wallpaper and loaded by btop with zero "Missing color value" warnings**. It deliberately uses
**literal aurora hexes for surfaces and load ramps, matugen roles only for reactive accents** —
which makes it **immune to the pale-pastel bug**. Wire `[templates.btop]` into `aurora.toml`,
add it to `outputs=()` in `apply-wallpaper` (inheriting the existing validation + atomic
`mv -f`), and add `pkill -SIGUSR2 btop` beside the waybar reload (verified: SIGUSR2 →
`Theme::updateThemes(); Theme::setTheme();`). **Do not** use `programs.btop.themes` — it writes
an immutable store symlink, and matugen owns the theme.

#### B5 — the CPU/Memory split

`missioncenter` *is* the right binary; the bug is **two blind, non-idempotent spawns** racing
the magpie socket. **The shared primary is the fix** — one idempotent destination replaces two
duplicate spawns — and the *split* lives in the right-clicks, each playing to a real strength:

```json
"cpu":    { "interval": 5, "on-click": "hyprctl dispatch 'hl.dsp.focus({ workspace = 2 })'",
            "on-click-right": "kitty --class aurora-gputop -e nvtop" },
"memory": { "interval": 5, "on-click": "hyprctl dispatch 'hl.dsp.focus({ workspace = 2 })'",
            "on-click-right": "missioncenter" }
```

CPU→`nvtop` covers exactly Mission Center's Intel-iGPU blind spot; memory→Mission Center keeps
its least-broken feature. `interval` 3→5 for battery. Add `nvtopPackages.intel` to waybar's
`runtimePath` (that unit's PATH excludes `/run/wrappers/bin`).

### 5.12 File explorer + system monitor — **RESEARCH IN FLIGHT AT TIME OF WRITING**

Known and settled already:
- **B5 is a real, trivial bug**: `cpu` and `memory` have literally identical
  `"on-click": "missioncenter"`.
- Mission Center is a weak destination regardless — the handoff record notes it **cannot report
  Intel GPU utilisation on this hardware** and sometimes refuses its auxiliary socket.
- The request is explicit: system monitoring as **workspace-2 / terminal-style content**, *not*
  a widget popup and *not* a basic system-monitor app window.
- Thunar is GTK3; Nautilus is GTK4/libadwaita — so the file-manager choice is **downstream of
  the 5.7 libadwaita answer**. Switching also means re-wiring udisks/GVFS/tumbler thumbnails
  and the `inode/directory` default handler; that migration cost is real and must be weighed
  against "Thunar looks dated".
### 5.8 QuickShell panel layouts — **DECIDED**

**Honest headline: no community shell matches the aesthetic.** Every serious one (caelestia,
DankMaterialShell, end-4) is Material 3 dark — precisely the "corporate / flat / Android-ish"
the brief rejects. Not one does dark-glass-with-wallpaper-bleed. So the legitimate finding is:
**adopt structure and motion; build the skin ourselves.** That is not the same as building
from scratch — the structures below are lifted, only the surface treatment is ours.

**Common shell:** width 460 (calendar 480, music 900, wifi 440, power 420) · padding 20 ·
card spacing 12 · radius 14 outer / 10 inner · bg `#990a0e1a` · border 1px rgba(255,255,255,0.08)
· inner cards rgba(255,255,255,0.04) fill, no border · **min hit target 40×40, 44 for primary**.
Caelestia's fonts are too small for us (normal 13) → normal 14–15, and go large on hero numerals.

**Calendar/weather (480).** Hero clock **64px** weight 300 with `font.features: {"tnum": 1}`;
**seconds as a separate Text bound to the 1s tick** so we do not repaint 64px glyphs 60×/min.
Full 7×6 month grid, cells **40×40**, today = filled circle `#00d4aa`, event days get a 4px
`#7c3aed` dot. Grid ≈304 wide, fits 480 comfortably. **The curved hourly timeline exists
nowhere — we build it**: `Shape` + `ShapePath` + `PathCubic`, 2px `#38bdf8` stroke with a
`fillGradient` beneath; use **`Shape.GeometryRenderer`** (it is static, tessellated once).

**Music/EQ (900×340).** Adapt caelestia's `CoverVisualiser.qml` — the radial cava ring around
circular album art is essentially our music spec, already built. Our changes: feed it **our
own cava** (theirs comes from a C++ provider we do not need); our cover is a **circle**, so
`shapeEdgeDist` becomes a constant instead of a per-bar `distanceAtAngle()` call each frame;
**drop 60 bars → 32**; use `GeometryRenderer` **not** CurveRenderer (these are straight
`PathLine`s — the curve renderer costs more for nothing); **cap updates at ~30fps**. Vinyl
spin via **`RotationAnimator`** (render thread, survives main-thread jank), and **pause** rather
than stop so it resumes in place. **play 56×56** (this is the direct fix for "unusably small"),
prev/next 44×44; progress track 6px but **`MouseArea` height 20** for a real seek target.
⚠️ **Nix constraint:** EQ presets cannot be written into the shell's own config dir (read-only
store symlink) — write to `$XDG_STATE_HOME/aurora-shell/eq.json`.

**WiFi (440).** Radial gauge 140⌀ — but **the centre number is download Mbps, not signal %**;
signal becomes the arc fill only. Detail grid 2×2 for IP/Security/Band/Channel.

**Power (420).** Battery gauge 120⌀ with % at 32px tabular; brightness/volume sliders with
**24×24 handles and 44px rows** (these are what actually gets touched). Session buttons 64×64,
neutral at rest, colour only on hover. **Shutdown/reboot must require confirm-or-hold** — a
64px shutdown one click deep in a panel is a footgun.

**Structure sources:** DankMaterialShell for the calendar month-grid + control-centre
composition (structurally closest, aesthetically the thing we reject); caelestia for music +
tokens; end-4's `Appearance.qml` for the canonical **pure-QML** M3 curve set.

### 5.8a Motion — the bezier facts that will otherwise bite

- **Qt requires `bezierCurve` length to be a multiple of 6**, ending at `1,1`. A wrong-length
  array is **silently discarded** — no warning, empty curve (`QQmlEasingValueType::setBezierCurve`:
  `if ((size % 6) != 0) return;`). A CSS `cubic-bezier(x1,y1,x2,y2)` = **6** numbers:
  `[x1,y1,x2,y2,1,1]`.
- **Use `Easing.BezierSpline`.** `Easing.Bezier` is an alias Qt's own header marks
  `// Evil! Don't use this!`
- ⚠️ **Do not copy end-4's `emphasizedFirstHalf`** — it is 8 elements, silently discarded, and
  therefore **live-broken** in their own `settings.qml:264`. A good example of why we verify.
- Pure QML **cannot** assign a whole `QEasingCurve` the way caelestia does from C++; set
  `easing.type` + `easing.bezierCurve` separately.

The M3 set (identical in caelestia's `tokens.hpp` and end-4's `Appearance.qml`):

```qml
readonly property list<real> standard:                 [0.2, 0, 0, 1, 1, 1]
readonly property list<real> emphasizedDecel:          [0.05, 0.7, 0.1, 1, 1, 1]
readonly property list<real> emphasizedAccel:          [0.3, 0, 0.8, 0.15, 1, 1]
readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1]  // y>1 = overshoot
readonly property list<real> expressiveDefaultEffects: [0.34, 0.80, 0.34, 1, 1, 1]
```

The `y > 1` control point is deliberate **overshoot** — that is the "nothing snaps" quality.

**The key insight on "coordinated staging":** across all three reference shells, coordination
is expressed as **duration classes, not `PauseAnimation`**. Spatial properties get 350/500/650ms
spatial curves; effects properties get 150/200/300ms effects curves. Opacity resolving early
while geometry settles late *is* the coordinated feel.

For compact→expanded, use the **single-driver morph**: one eased 0→1 drives everything through
*bindings*, so properties cannot desync:

```qml
property real expandProgress: 0
Behavior on expandProgress {
    NumberAnimation { duration: 500; easing.type: Easing.BezierSpline
        easing.bezierCurve: root.expanded ? Curves.expressiveDefaultSpatial   // overshoot on open
                                          : Curves.emphasizedAccel }          // clean pull-back
}
height:             compactH + (expandedH - compactH) * expandProgress
detailPane.opacity: Math.max(0, (expandProgress - 0.4) / 0.6)   // stagger, free and exact
```

**Panel open couples to 5.2(b):** opacity animating 0→1 crosses `ignore_alpha`. At 0.10 it is
continuous; at 0.50 you get the blur pop.

### 5.8b WiFi speed — measured, with a correction

**Use `/proc/net/dev` deltas.** Measured on this machine: `/proc/net/dev` = **32 µs** for all
interfaces both directions in one read; sysfs = 22 µs *per counter*; `nmcli dev wifi` = **22 ms**
(~700× worse). Waybar reads `/proc/net/dev` too.

`Mbps = (rx_now - rx_prev) * 8 / dt_seconds / 1e6` — **SI 1e6, not 1024²** (link rates are quoted
in SI; getting it wrong reads 4.9% slow). Counters are **64-bit and do not wrap** (~46 years at
100 Gbit/s), so a negative delta **always** means an interface reset → **clamp to 0**.

⚠️ **Do not copy caelestia's `NetworkUsage.qml`** — it has two real bugs, found by live test:
`reload()` then `text()` on the next line is **exactly one poll interval stale** (QuickShell docs:
"calling reload() will return the old data until the load completes"); and
`if (rxDelta < 0) rxDelta += Math.pow(2, 64)` yields a **1.8e19 B/s** spike on reset that poisons
the sparkline. Use noctalia v4.7.7's `SystemStatService.qml` pattern instead — read in **`onLoaded`**,
clamp resets to 0. Use **measured `dt`** (`Date.now()` delta), never the nominal interval.

**Never poll via `Process`** — noctalia #2274 is an FD-leak crash after ~26h uptime, root-caused
to QuickShell's `Process` leaking pipe FDs per invocation.

**Gate it:** `running: refCount > 0`, incremented by consumers — the timer must not run while the
panel is closed. Same discipline as `CavaService`.

**SSID/signal/security** come from QuickShell 0.3's built-in **`Quickshell.Networking`**
(NetworkManager D-Bus, event-driven, zero polling) — tested live on this machine:
`SSID=Soltech iface=wlp115s0f0 sec_str=WPA2 sig=71%`. Use `NetworkDevice.name` to pick the
`/proc/net/dev` row. ⚠️ **Do not hardcode the security enum — the docs list it in a different
order than the real values**; use `WifiSecurityType.toString()`. The singleton populates
**asynchronously (~1–2s)**, so a one-shot read at `Component.onCompleted` returns nothing —
bind reactively.

**Band, channel and IP are NOT exposed** by `Quickshell.Networking` 0.3 (confirmed from source).
Get them from nmcli **once on connect**, never polled — and **`--rescan no` matters**, since
omitting it triggers a scan that disrupts the connection. **Derive band from FREQ, not CHAN**
(6GHz channel numbers collide with 5GHz).

Smoothing: honest finding — **none** of Waybar, noctalia or caelestia use EMA, so no sourced
value exists. Recommend α = 0.4 at 1s; keep raw for the sparkline, show EMA as the number.
### 5.9 Kitty startup experience — **DECIDED**

**The brief's reference is wrong (again).** `saatvik333/hyprland-dotfiles` — cited for "ASCII
art on startup" — **has no ASCII art**: a bare `saatvik333 ~ $` prompt, warm sepia via Wallust,
no fetch, no blur. Aesthetically the opposite of aurora dark glass. `snes19xx/surface-dots`
sets **`background_opacity 1`** — fully opaque, not a glass model either. Worth stealing from
surface-dots' *config* (more authoritative than its screenshots): nerd-font glyph keys instead
of text labels, `" ▐ "` separators, named ANSI colours.

**fastfetch — measured on this actual i3-1000NG4:**

| config | time |
|---|---|
| default (all modules) | **138 ms** |
| minus `packages` | 75 ms |
| tight, no `packages`/`wm` | **8 ms** |
| process-spawn floor | 4 ms |

The perf suspicion was right and is now quantified. **`packages` = 70 ms warm / 338 ms cold**,
and **nix is 100% of it**. **`wm` = 61 ms**; a static `custom` line is **0.02 ms**. Everything
else is ≤0.5 ms.

**Decision:** drop `packages`; replace `wm` with a Nix-injected `${pkgs.hyprland.version}`
static string. Lands **~10–25 ms** — so **caching is unnecessary**, which is fortunate:
fastfetch **strips all colour when piped**, so a naive `> cache.txt` silently yields monochrome
art.

**Wiring — `startup_session` is wrong** (it only covers the first OS window, so it would not
fire for Ctrl+T, contradicting "tabs are first-class"). Use fish `interactiveShellInit` with an
**exported guard**, not `SHLVL` (fish only increments SHLVL for *interactive* shells and it is
relative to ambient level — measured L1=3, nested=4, so `-eq 1` is fragile):

```fish
if status is-interactive; and not set -q AURORA_FETCH_SHOWN
    set -gx AURORA_FETCH_SHOWN 1
    fastfetch
end
```

This is correct precisely because kitty only copies shell env behind `--copy-env` (default
`False`) — so **every new tab prints, nested `fish` does not**.

**The Matugen conflict dissolves:** HM's `programs.fastfetch` writes `config.jsonc` as a
read-only store symlink, so it cannot be per-wallpaper. Fix: **use ANSI palette indices
(`"keyColor": "36"`), not hex** — fastfetch then inherits kitty's Matugen-recoloured palette for
free, and `set-colors` updates it live. No extra wiring.

**ASCII art:** the built-in NixOS logo is **26 lines × 114 cols** — it would eat two-thirds of a
29-row terminal on *every tab*. Rejected on measurement. Use a 3-line half-block wordmark
(clean/stylized, not figlet), in `home.file` (art does not change per wallpaper).

**Tab bar / opacity:** keep `powerline`/`slanted` — the only style that reads as layered glass;
`fade` muddies against a translucent background. `tab_bar_min_tabs` defaults to 2, so a
single-tab window shows no bar — correct for Ctrl+T-first-class. **Keep `background_opacity
0.88`** — top of the 0.82–0.88 band, and the band exists so code stays readable. **Do not chase
the panels' 0.55.**

⚠️ **Kitty's `background_blur` is a guaranteed no-op on Hyprland.** Verified by binary
inspection: kitty's `glfw-wayland.so` implements blur *only* via `org_kde_kwin_blur_manager`;
Hyprland 0.55.4's ELF has **no** `org_kde_kwin_blur` (sanity-checked — the same grep does find
its `zwlr_*` protocols). Compositor blur is the only mechanism. Leave it unset.

### 5.9a Live terminal recolour — safe, and the SIGUSR1 constraint is a misdiagnosis

**`EXECUTION_LOG.md` states "Never send Kitty `SIGUSR1`: it terminates this Kitty 0.47.4
build." The source says otherwise.** In v0.47.4 `child-monitor.c`:

```c
#define KITTY_HANDLED_SIGNALS SIGINT, SIGHUP, SIGTERM, SIGCHLD, SIGUSR1, SIGUSR2, 0
...
case SIGUSR1:  ss->reload_config = true;  break;
```

SIGUSR1 is **reload-config**. The probable real cause of the observed death: SIGUSR1's *default
disposition is Term*, and **only the kitty GUI process installs the handler** — so a broad
`pkill -USR1 kitty`-style send also hits the `kitten __watch_conf__` and `kitten __atexit__`
helpers and kitty's own children, none of which handle it. They die; the window vanishes; it
looks like "kitty terminated". (Both helpers are visible in our own process tree.)

**Keep the constraint anyway** — it was not re-tested on Alex's live terminal, and it is moot,
because there is a better mechanism:

**Command-scoped remote control.** The obvious hardening (`socket-only` + abstract socket) is
wrong on both halves:
- **`socket-only` allows *everything*** — including `send-text`, i.e. keystroke injection, i.e.
  RCE as alex.
- **`unix:@abstract` is not safer**: abstract sockets have no inode or mode bits. Kitty
  compensates either way (`verify_peer_uid` + `getpeerid()` denies `peer_uid != geteuid()`), but
  a filesystem socket in `$XDG_RUNTIME_DIR` (verified `drwx------ alex`) wins on defence in
  depth.

The correct answer is **scoping by command**, proven on a throwaway instance:

```
allow_remote_control password
remote_control_password "" set-colors
listen_on unix:${XDG_RUNTIME_DIR}/kitty.sock
```

An empty password whitelists **only** the named commands. Measured: `set-colors` → **exit 0,
palette applied live**; `launch`, `ls`, `send-text` → **denied** (`send-text` verified properly —
it returns 0 because it is fire-and-forget, so a child capturing stdin was used to confirm it
received nothing). A compromised same-uid process can only recolour the terminal.

Wire into `apply-wallpaper` — all 17 keys our template writes are in kitty's 288-entry
`all_colors` set, so the whole file applies:

```sh
kitten @ --to unix:$SOCK set-colors --all --configured ~/.cache/aurora-theme/kitty.conf
```

Two gotchas: `listen_on` **from the config file** appends `-{kitty_pid}` → **glob
`kitty.sock-*`** (one per process); and the socket path has a **~108-char limit** (a longer path
fails with a misleading "Invalid listen_on").

**Recommendation: adopt it.** Cosmetic-only exposure for a real payoff — existing terminals
recolour with the wallpaper instead of staying stale. "New terminals only" remains a defensible
fallback if Alex prefers zero new surface.

### 5.11 Wallpaper picker + animated wallpapers — **DECIDED**

#### skwd-wall: viable, but **do not adopt**

The brief's premises are wrong — mostly *in its favour*, which makes the negative verdict
stronger. It is **not Rust: it is QML on QuickShell**, the toolkit we already run (84 QML
files, 20.6k LOC, API surface entirely within our 0.3.0). It **already has native awww
support** (`Config.wallpaperEngine = "awww" | "skwd-paper"`), **already ships a Nix flake**
with `nixosModules.default`, and **already supports our pipeline** via `pickOnlyMode` +
`postProcessing` + `features.matugen: false` — so "adapt it for Matugen" needs *config, not a
fork*. There is also nothing to pin: no tags, no `flake.lock`, only `main`.

**Rejected on three grounds:**

1. **Upstream abandons it in ~7 days.** Its README: *"currently undergoing a complete rewrite
   to Rust… I have fully abandoned Quickshell… V2 released ~23/07/2026."* Today is
   **2026-07-16**. Adopting V1 means owning 20.6k LOC of dead QML on day one — and V2 destroys
   the single reason to choose it (QuickShell-native).
2. **Its daemon would fight ours.** `apply/awww.rs:36` runs `awww kill; pkill -x awww-daemon`.
   Our awww is `aurora-wallpaper.service`; `awww kill` **exits 0**, so `Restart=on-failure`
   will *not* restart it — the wallpaper daemon silently disappears.
3. **Cost/benefit is inverted.** No `flake.lock` → a second nixpkgs (unstable vs our pinned
   commit), a source-built quickshell, and a **619-crate Rust daemon** (rusqlite bundled,
   ffmpeg bindgen), all uncached, on a dual-core i3. Its headline features — 13-colour
   sorting, Wallhaven, Steam, Ollama auto-tagging — exist for people with **thousands** of
   wallpapers. **We have twelve.**

**Fatal aesthetic mismatch:** its UI is itself Matugen-themed, so its accent follows the
wallpaper (green in one shot, red in another). It **structurally cannot hold a fixed
teal/cyan/purple identity** — the exact thing we are fixing.

**Steal the design, not the codebase.** The parallelogram is `QtQuick.Shapes` + ~10 lines of
skew geometry (`SliceDelegate.qml:71-75`). That is the valuable part and it is cheap.

#### The picker: premise correction — **there is no custom picker**

`PowerPanel.qml:223-227` is a button calling `PowerService.openWallpaperPicker()` →
`Quickshell.execDetached(["waypaper"])`. **The "custom-built jank" is simply Waypaper's GTK3
window** (viewed: an opaque GTK box that fails the see-through test outright). Moving it out of
the power panel is a **5-line delete**; building a real picker is the actual work.

**Decision: a new `wallpaper` QuickShell panel**, bound to SUPER+W — add to
`PanelCoordinator.knownPanels`, new `panels/wallpaper/WallpaperPanel.qml`, borrowing skwd-wall's
parallelogram geometry. It inherits Overlay layer, `HyprlandFocusGrab`, Escape and **blur (via
the existing `aurora-.*` rule) for free — no `rules.lua` change needed.**

**A desktop right-click menu is the wrong answer on Hyprland:** there is no desktop surface —
awww's background layer takes no input — and on a tiling WM the desktop is almost never
visible, so the affordance is unreachable exactly when you want it.

#### mpvpaper vs awww: they **do** collide — verified live

```
Layer level 0 (background): namespace: awww-daemon, pid: 1826
Layer level 2 (top):        aurora-taskbar
```

Both default to wlr-layer-shell **`background`** (awww `cli.rs:20`; mpvpaper `-l` defaults to
background). Two surfaces on one layer do not error — they stack by creation order, and
Hyprland has no layer-priority rule (issue #7476 open). **Do not rely on stacking.**

**Design: mutual exclusion via systemd `Conflicts=`**, not layering. Add
`aurora-video-wallpaper@.service` with `Conflicts=aurora-wallpaper.service` both ways; systemd
guarantees one owner atomically. `apply-wallpaper:116` already restarts awww on a still-apply,
so still→video→still falls out for free. Both are in the pinned nixpkgs (awww 0.12.1,
mpvpaper 1.8).

#### Matugen from video: montage, not first frame

skwd-daemon's own answer (`-vframes 1`) is naive — **the first frame is routinely a black
fade-in**. Averaging (`tmix`) is the other trap: it desaturates toward grey, and Matugen picks
a *source colour*, so you would get a muddy theme. Use a **montage** (preserves chroma; Matugen
only quantises, so seams do not matter), and derive **two** images:

```sh
# palette source: 16 frames across the loop
ffmpeg -y -i "$v" -vf "fps=1/2,scale=640:-1,tile=4x4" -frames:v 1 -update 1 montage.png
# hyprlock still: most representative single frame
ffmpeg -y -i "$v" -vf "thumbnail=300" -frames:v 1 -update 1 still.png
```

Two images are **required** because `apply-wallpaper:93` feeds the wallpaper to **hyprlock** —
otherwise your lock screen is a 4×4 montage.

**Two real bugs found in `apply-wallpaper` while establishing this:**
- **`:21-24`** — the extension whitelist rejects `.mp4` outright.
- **`:100-108`** — writes `wallpaper.json` **before** the `--theme-only` return at `:110`, so it
  would record the *extracted frame* as the wallpaper and `select_wallpaper` would restore a
  still on boot instead of the video. **Guaranteed hit, not hypothetical.**

#### Power: measured, and the verdict is no

**The headline: VA-API is not broken — the driver was never installed.** Independently
confirmed here:

```
$ ls /run/opengl-driver/lib/dri/ | grep drv_video
d3d12  nouveau  r600  radeonsi  virtio_gpu        # <- no iHD, no i965
$ grep -rE "intel-media-driver|hardware.graphics|LIBVA" **/*.nix
(nothing — 19 .nix files, zero VA-API config)
```

On an **Iris Plus G4 (Ice Lake Gen11, PCI 8086:8A5C)**. The fix was proven without a rebuild by
loading `intel-media-driver` from the store: `va_openDriver() returns 0`, *Intel iHD driver
26.1.6*, with H.264 / HEVC Main10 / VP9 VLD entrypoints (**no AV1** — Gen11 predates it).
Fix ≈ 4 lines: `hardware.graphics.extraPackages = [ pkgs.intel-media-driver ]` +
`LIBVA_DRIVER_NAME=iHD`.

**This is worth doing regardless of wallpapers.** It is the direct cause of the
`vaInitialize failed` error in our journal, which means **Chrome has been software-decoding all
video since day one** — a continuous battery cost on a dual-core i3, fixable for four lines.
Filed as a new item (B15).

**Measured decode on this CPU** (`ffmpeg -benchmark`, CPU-seconds per 20s of video; the machine
has 2 cores):

| Workload | Software (today) | VA-API (after fix) |
|---|---|---|
| 1080p30 H.264 | **53%** of a core | 18% |
| **2560×1600@30 H.264** | **103% of a core — ~51% of the whole CPU** | 39% |
| awww, static | **0.0%** (0 CPU-seconds in 50 min, 2.1 MB RSS) | — |

Native-res software decode burns **half the machine, continuously, forever** — on synthetic
content *easier* than real video, and excluding scale-to-2560×1600 and 60Hz compositing.

**`--auto-pause` will not save it.** Its own man page: *"'hidden' is if there is a **fullscreen**
window in the way… mpvpaper will still draw/render even if a normal window is blocking the
wallpaper view entirely"* and *"at best a hack."* In normal tiled use you decode 24/7 while you
work.

**Honest verdict: not on battery, ever.** Conditionally acceptable **plugged in**, *and only
after* the driver fix, *and only* at **≤1080p** (never native, never AV1):

```sh
mpvpaper -f -s -o "no-audio loop-file=inf hwdec=vaapi vo=gpu \
  input-ipc-server=/run/user/1000/mpvpaper.sock" eDP-1 loop.mp4
```

Drive pause from an **AC-state udev hook** over that IPC socket, **not** from `--auto-pause`.
Default **off on battery**, opt-in on AC. (Watts could not be measured: the T2 battery exposes
no `power_now`/`energy_now`.)

**Recommendation to Alex:** take the VA-API fix now (it pays for itself in Chrome), and treat
animated wallpaper as an **opt-in, AC-only, ≤1080p** feature — or drop it. It is the one
requested feature whose cost genuinely exceeds its value on this hardware.


---

## 6. Dependency graph

```
        ┌──────────────────────────────────────────────┐
        │ B1  Waybar app-launch isolation              │  SAFETY GATE
        │     (blocks safe service restarts)           │  must land first
        └───────────────────┬──────────────────────────┘
                            │
        ┌───────────────────▼──────────────────────────┐
        │ 5.1  PALETTE ARCHITECTURE                    │  ROOT DEPENDENCY
        │      + 5.2 glass alpha                       │  everything visual
        └─┬─────────┬─────────┬─────────┬──────────┬───┘  consumes this
          │         │         │         │          │
      ┌───▼──┐ ┌───▼───┐ ┌───▼────┐ ┌──▼───┐ ┌───▼────┐
      │Waybar│ │ Rofi  │ │QuickShl│ │ GTK  │ │Hyprlock│
      │ 5.4  │ │ 5.5   │ │  5.8   │ │ 5.7  │ │  5.10  │
      └───┬──┘ └───────┘ └───┬────┘ └──┬───┘ └────────┘
          │                  │         │
          │ B2 workspaces    │         └─► Chrome (5.6)
          │ (needs custom/   │
          │  module design)  └─► 5.3 dock (reuses aurora-.* blur)
          │                       5.11 picker (moves out of power panel)
          ▼
      B5 cpu/mem split ──► 5.12 system monitor decision
```

**Reading:** B1 first (safety). Then the palette + glass — restyling before it means doing
the work twice. Independent of both: B3, B4, B6, B7, B9, B11, B12, B14.

---

## 7. Staged execution with test gates

**Stage B0 — diagnostics only, zero changes.** Cheap, high-information, and it de-risks
everything after it:
- Answer **B10** with one question to Alex (does tap-to-click work?) + one reversible live eval.
- Try to reproduce **B13** *before* B1 lands, so the fix can be proven rather than asserted.
- **Live-verify the glass fix with `hyprctl eval` before writing any config** (5.2): toggle
  `blur=false` / `blur=true, ignore_alpha=0.10, xray=true` on the named rule and screenshot
  both. Also sweep `ignore_alpha` live. **Nothing here touches a file.**
- Confirm `xray + passes=2` is affordable on the Iris Plus. **This is the single biggest open
  risk in the plan and it is measurable in minutes.**

**Stage B1 — functional bug fixes.** B1 (first — it is the safety gate), then B2, B3, B4, B5,
B6, B7, B9, B11, B12, B14.
*Gate: Alex verifies bugs are fixed — above all that **restarting Waybar no longer kills
Chrome/Kitty**, tested deliberately.*

**Stage B2 — palette + glass foundation.** The matugen 4.1.0 upgrade, 5.1 templates, 5.2 glass,
plus the mechanical palette check in `checks/`.
*Gate: switch through red / green / cyan / violet / neutral wallpapers; every surface recolors;
**nothing goes pink**; the wallpaper is visible through every panel; window borders are no
longer pink.*

**Stage B3 — Waybar + launcher + GTK/Chrome.** *Gate: base look is right; **Chrome's titlebar
is no longer white**; the launcher is legible and dismisses on click-away.*

**Stage B4 — QuickShell panel styling.** *Gate: panels look and function correctly; music
transport is genuinely clickable; WiFi shows real Mbps.*

**Stage B5 — new components.** Dock, picker relocation, terminal startup, system monitor,
animated wallpaper (**only if** the power verdict allows). *Gate: Alex verifies new components.*

**Stage B6 — polish.** Animation tuning, colour cohesion across all wallpapers, hover,
transitions, final sizing. *Final: full walkthrough.*

### Sequencing notes that matter

- **B1 before anything that restarts a service.** Until it lands, a Waybar restart destroys
  Alex's session.
- **B2 before B3/B4.** Every surface consumes the palette. Restyling first means doing it twice
  — the most likely explanation for how the current build ended up half-applied.
- **Stage B0's `hyprctl eval` blur test is worth doing on day one**, independent of everything
  else. If `xray` turns out unaffordable on the Iris Plus, the glass target changes and that
  should be known *before* the templates are rewritten around it.

---

## 8. Standing constraints for Phase B

1. **Do not restart `waybar.service`** while Alex has work open, until B1 lands. Use
   `Super+Enter` for a maintenance terminal (it parents to Hyprland).
2. **Hyprland native Lua only.** `hyprctl keyword` and legacy dispatcher strings are
   forbidden — and demonstrably broken (B2). Every new runtime action must be exercised over
   real compositor IPC before being called verified; static JSON/Nix validation does **not**
   catch this class of bug (that is how B2 shipped).

2a. **Verify against the running machine, not against a README.** This is the single lesson of
   Phase A and it is not a platitude — it is the difference between the two audits. Nine
   reference repos did not contain what the brief said; `EXECUTION_LOG`'s SIGUSR1 warning is
   probably a misdiagnosis; a matugen key has been silently discarded for the whole project's
   life. **Every one was caught by running one command.** Concretely, for each change:
   - render it, screenshot it, and *look* — the eye is what failed last time, but only because
     it was never pointed at the output;
   - prefer a reversible live probe (`hyprctl eval`, `rofi -dump-theme`, `matugen --dry-run`,
     `hyprctl layers -j`) **before** editing a file;
   - when a source claims a mechanism, check it against *our* binary — Chrome's
     `BrowserThemeColor` is present and `BrowserColorScheme` is absent **on this build**; that
     is not knowable from a blog post;
   - record refuted hypotheses rather than deleting them. Four of this audit's most useful
     entries are corrections of its own earlier conclusions.
3. **Never send Kitty `SIGUSR1`** — it terminates this build.
4. Preserve every T2 / firmware / boot / dual-boot invariant. Keep
   `debug.disable_scale_checks = true`.
5. All changes go through the flake + `nixos-rebuild`. No imperative installers, no manual
   file drops. Several attractive community themes ship `install.sh` — that disqualifies the
   installer, not necessarily the theme.
6. Setting the system profile is required to create a numbered boot generation.
7. **Budget the iGPU.** Intel Iris Plus, dual-core i3, 8GB, on battery. Reject always-on
   animation, permanently-resident fullscreen overlays, and per-frame JS loops.
8. Do not push, merge, rebase, update flake inputs, remove generations, delete backups, or
   touch the macOS partition without explicit approval.
