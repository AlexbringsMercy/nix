# Issue log — Aurora desktop overhaul (Phase A audit)

Author: Claude Code orchestration run, 2026-07-16
Scope: every defect from the visual design reference's bug list, plus everything found
during an independent live audit of the running system.

**Status of each item is one of:**

| Status | Meaning |
|---|---|
| **PROVEN** | Root cause established by direct evidence recorded in this file. |
| **STRONG** | High-confidence mechanism identified; one specific test would confirm it. |
| **OPEN** | Reported but not yet root-caused. Needs investigation in Phase B. |
| **NOT POSSIBLE** | The request cannot be satisfied as literally stated. Honest alternative given. |

Nothing in this file was fixed. Phase A is audit and planning only.

---

## 0. State delta — the handoff report is out of date

`EXECUTION_LOG.md` says Generation 10 was installed but the machine "has not rebooted
since it was installed", so `/run/current-system` still pointed at Generation 9.

**That is no longer true.** The machine rebooted at **2026-07-16 05:29**:

```
/run/current-system          -> /nix/store/9lwy876…-nixos-system-macbook-26.11.20260616.567a49d
/nix/var/nix/profiles/system -> /nix/store/9lwy876…-nixos-system-macbook-26.11.20260616.567a49d
```

Both now point at the **Generation 10** store path. So Generation 10 booted successfully and
is live. Kernel `linux-t2 6.18.35`, Hyprland 0.55.4, no failed system or user units,
`hyprctl configerrors` empty, monitor `2560x1600@60 scale 1.50` with `reserved: 0 46 0 0`.
The Retina fix is live and correct — no dead bands.

Git tree is clean on `codex/macbook-desktop`, one commit ahead of the handoff report
(`5f45837 docs: record full Aurora deployment handoff`).

**Implication:** the two P0/P1 lifecycle defects from the handoff report are still unfixed,
and P0 is now confirmed live (see §1).

---

## 1. 🔴 SAFETY — Waybar owns the cgroup of every app launched from it (P0)

**Status: PROVEN. This is the highest-severity issue and it constrains how Phase B may be
executed.**

`waybar.service` has `KillMode=control-group`. Apps launched from the bar's `on-click`
commands are spawned as children of Waybar and land in its cgroup. Ground truth read
directly from `cgroup.procs` at audit time — 21 processes in `waybar.service`:

```
2008  .waybar-wrapped
2292  .kitty-wrapped        <-- the terminal running this session
2298  kitten     2301 kitten     2534 cat     2535 cat
2541  chrome_crashpad       2545 chrome_crashpad
2555  chrome  2556 chrome  2560 chrome  2593 chrome  (zygotes, GPU process)
2598  chrome  2610 chrome  (network + storage services)
2636  chrome  2849 chrome  2888 chrome  2945 chrome  3835 chrome  4345 chrome  4709 chrome  (renderers)
```

The escape is only **partial**, which the handoff report did not capture:

| Process | Cgroup | Survives a Waybar restart? |
|---|---|---|
| Chrome **main** (2524) | `app-com.google.Chrome-2524.scope` | yes |
| Chrome zygotes/GPU/network/**renderers** | `waybar.service` | **no — every tab dies** |
| Kitty **master** (2292) | `waybar.service` | **no — the window dies** |
| Kitty's shell children (fish, claude) | `kitty-2292-0.scope` | orphaned when the master dies |

So "the app made its own scope" is false comfort: Chrome keeps only its browser process and
loses every renderer; Kitty keeps only its shell children and loses the terminal itself.

Corroborating evidence — Chrome's stderr is journalled **under the Waybar unit**:

```
Jul 16 05:33:03 macbook waybar[2535]: [ERROR:vaapi_wrapper.cc] vaInitialize failed
Jul 16 05:33:04 macbook waybar[2535]: [chrome/browser/ui/webui/ntp/new_tab_ui.cc] …
```

### Operational constraint for Phase B

**Do not `systemctl --user restart waybar` while Alex's apps are open.** At audit time the
terminal running this very session was PID 2292, a direct child of Waybar (PID 2008).
Restarting Waybar would have killed this session and every Chrome tab.

A SIGUSR2 CSS reload is safe; a unit restart is not. Use `Super+Enter` for a maintenance
terminal, which parents to Hyprland instead.

### Root cause

`modules/home/waybar/config.json` launches apps directly:

```json
"custom/chrome":   { "on-click": "google-chrome-stable --ozone-platform-hint=auto" }
"custom/terminal": { "on-click": "kitty" }
"custom/files":    { "on-click": "thunar" }
"cpu"/"memory":    { "on-click": "missioncenter" }
```

### Fix

Route every Waybar launch through a compositor-native exec so Hyprland is the parent, not
Waybar. Hyprland's own keybinds already use the native form (`hl.dsp.exec_cmd`), so the
mechanism is proven on this machine:

```
on-click = hyprctl dispatch 'hl.dsp.exec_cmd("kitty")'
```

`systemd-run --user --scope` is the alternative. Either detaches the app from Waybar's
cgroup. This same `hyprctl dispatch` mechanism also fixes §2, so one change resolves both.

### Verification

Launch Chrome, Kitty, Thunar from the bar; confirm each is **outside** `waybar.service`'s
`cgroup.procs`; then deliberately `systemctl --user restart waybar` and confirm all three
survive with their tabs/windows intact.

---

## 2. 🔴 Workspace 2 button does nothing — and it is not a Waybar config error

**Status: PROVEN.** Bug list item #9.

Waybar's **built-in** `hyprland/workspaces` module dispatches to Hyprland using the *legacy
dispatcher string* form, which is compiled into Waybar's C++ — it is not something the JSON
config can change. Hyprland 0.55's Lua parser **rejects** that form. Tested live over the
real compositor IPC:

```
$ hyprctl dispatch workspace 1
error: [string "return hl.dispatch(workspace 1)"]:1: ')' expected near '1'
 → Note: dispatch in lua is a shorthand for hl.dispatch(...), your syntax might need to be updated.

$ hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'
ok
```

**So every workspace button is dead, not just #2.** Alex only notices #2 because clicking
"1" while already on workspace 1 looks like it worked.

This is precisely the Hyprland 0.55 incompatibility the previous session found and fixed —
but it fixed only the `custom/` modules it controlled. Confirmed in `config.json`: every
custom module already uses the correct native form (`custom/window-close` →
`hyprctl dispatch 'hl.dsp.window.close()'`). The built-in workspaces module was missed
because it cannot be fixed from config.

`wlr/taskbar` is unaffected — it uses the `wlr-foreign-toplevel` Wayland protocol, not
`hyprctl`. That is why task buttons work.

### Fix

Replace the built-in `hyprland/workspaces` module with `custom/` modules that call
`hyprctl dispatch 'hl.dsp.focus({ workspace = N })'`. The cost is losing the module's
automatic active/urgent state styling, which must then be driven by a `custom` module with
`exec` + `return-type: json`, or by drawing the workspace indicator in QuickShell instead.
This is a real design decision for the plan, not a one-line fix.

### Verification

Click workspace 2 and confirm the switch; confirm the active-state pill still tracks the
real workspace when it is changed by `Super+2` and by a three-finger swipe.

---

## 3. 🔴 The muddy pink/mauve palette — structural, not a bad wallpaper

**Status: PROVEN.** This is the single largest visual defect and the root dependency for
almost every other visual fix.

The design brief demands teal/cyan primary (`#00d4aa`, `#0ea5e9`, `#38bdf8`), deep purple
and seafoam secondaries, on near-black **blue** surfaces. What is actually generated for the
current wallpaper (`violet-nokstella-stars.jpeg`), read from `~/.cache/aurora-theme/`:

```
source_color  #3c3c6a   (desaturated dark violet-blue)
primary       #c3c1f8   pale lavender
secondary     #c6c4dc   pale grey-lavender  (essentially grey)
tertiary      #f1b5db   PALE PINK           <-- the "muddy pink"
error         #ffb4ab   pale salmon
```

### Why — three compounding causes

**(a) Material 3 dark-mode accent roles are light tone-80 pastels by design.** In M3, dark
`primary` is a *light* tone because it is intended as a foreground colour on dark surfaces.
Matugen is doing exactly what M3 says; the templates are using those roles as if they were
saturated brand accents.

**(b) M3 `tertiary` is a ~+60° hue rotation of primary.** For any blue/violet source that
lands squarely in pink/magenta. The pink is *mathematically guaranteed*, not bad luck.

**(c) The semantic names in our templates are lies.** `templates/aurora/waybar.css`:

```css
@define-color purple @aurora_tertiary;   /* -> #f1b5db  PINK   */
@define-color cyan   @aurora_primary;    /* -> #c3c1f8  LAVENDER */
@define-color teal   @aurora_secondary;  /* -> #c6c4dc  GREY   */
```

Waybar's hand-tuned stylesheet asks for `cyan`/`teal`/`purple` and silently receives
lavender/grey/pink. Rofi does the same (`config.rasi` lines 34-36), which is why its
scrollbar and prompt are pink and grey.

### Verified across the whole wallpaper collection — every one fails

Rendered read-only for all twelve wallpapers. Not one produces a saturated accent; every
primary/secondary/tertiary is a tone-80 pastel, and blue/violet/purple/**seafoam** sources
all yield pink or lavender tertiary:

```
WALLPAPER                        source    primary   secondary tertiary
blue-aurora-light.jpg            #0c8ae5   #9fcaff   #aac9f1   #ebb2ff   <- blue -> PINK
cyan-raya-lucaria.jpeg           #3b7283   #98cfe2   #b5cad2   #dabbec
green-aurora-lake.jpg            #6cf137   #cfffb5   #8fd96e   #c4ffda
neutral-somerville-horizon.jpg   #0a0f12   #c2c7cb   #c6c6c8   #ccc4cc   <- near-black -> GREY
purple-misty-highlands.jpeg      #2a1e34   #d3c0dd   #cdc3d0   #e7bbc5   <- purple -> PINK
seafoam-moonlit-mountain.webp    #3b8f71   #84d7b5   #adcebe   #c3c0ff   <- seafoam -> LAVENDER
violet-nokstella-stars.jpeg      #3c3c6a   #c3c1f8   #c6c4dc   #f1b5db   <- CURRENT
```

Switching wallpaper cannot fix this. The template architecture must change.

### Deeper cause: `aurora.toml` is written for matugen **4.1.0**, but **4.0.0** is installed

**Status: PROVEN — and this is the most consequential single finding in the audit.**

`aurora.toml` lines 4-7 set:

```toml
fallback_color = "#04d1f9"          # teal
prefer = "closest-to-fallback"      # <- intended: bias source selection TOWARD teal
contrast = 0.08
source_color_index = 0
```

`prefer`, `contrast` and `source_color_index` **do not exist as config keys in matugen
4.0.0** — they were added in 4.1.0. Matugen's config struct has no `deny_unknown_fields`, so
serde **silently discards them**. No warning, no error.

Verified independently, by mutating one key in the real config and re-rendering:

```
$ sed 's/prefer = "closest-to-fallback"/prefer = "TOTAL-GARBAGE-NOT-REAL"/' aurora.toml > t.toml
$ matugen image <wallpaper> --config t.toml --prefix … --mode dark --type scheme-content --source-color-index 0 --quiet
$ echo $?
0
```

Exit **0** on a garbage value. Were `prefer` a real 4.0.0 key with an enum type, serde would
reject the invalid variant outright. It does not, because the key does not exist.

**What this cost us.** In 4.1.0, `prefer = "closest-to-fallback"` selects the wallpaper
candidate colour with the **minimum CIE Lab distance to `fallback_color`** — i.e. it picks
the most *teal-ish* colour the wallpaper offers. **That is exactly the teal bias the design
brief asks for, it was configured, and it has never once executed.** The author wrote a
correct intent against a version we do not ship.

**Do not assume upgrading alone fixes it.** Two traps:

1. `apply-wallpaper` passes `--source-color-index 0` **explicitly on the CLI**, which pins
   the dominant colour and would very likely override `prefer` even on 4.1.0. The script must
   stop forcing an index for `prefer` to have anything to decide.
2. On 4.1.0, `matugen image` with `prefer` unset **and** stdin not a terminal is reported to
   hard-error ("Multiple source colors found"). `apply-wallpaper` is non-interactive, so
   `prefer` becomes *mandatory* after the upgrade. (Our config already sets it — but the
   interaction must be tested, not assumed.)

Note `contrast = 0.08` and `source_color_index = 0` are *also* dead as config keys, but
`apply-wallpaper` passes both on the CLI where they **do** work — so those two are harmless
duplication rather than live bugs. Only `prefer` was load-bearing and lost.

### The other fix that exists in the config and was never wired up

`modules/home/theming/matugen/aurora.toml` defines the correct anchors:

```toml
[config.custom_colors]
aurora_purple  = { color = "#a48cf2", blend = true }
aurora_teal    = { color = "#04d1f9", blend = true }
aurora_seafoam = { color = "#37f499", blend = true }
```

**No template references any of them.** It is dead config. Verified by rendering with the
real project config — the roles *are* produced, and the `_source`/`_value` variants preserve
the true anchor exactly:

```
aurora_teal            #b4e1ff   <- blend=true still washes it to tone-80. Not usable as-is.
aurora_teal_source     #04d1f9   <- EXACT anchor preserved
aurora_teal_value      #04d1f9   <- EXACT anchor preserved
aurora_teal_container  #66caff   <- usable mid-tone
aurora_purple_source   #a48cf2
aurora_seafoam_source  #37f499
```

So `blend = true` alone is **not** the fix — it inherits the same tone-80 washing. The
design brief's requirement ("Matugen should REINFORCE this palette… if a wallpaper produces
muddy pinks, the template should CONSTRAIN output to stay within the dark/cool spectrum")
maps onto choosing deliberately between `_source` (fixed brand anchors, wallpaper-independent),
`_container` (mid-tone, partially adaptive), and blended roles with tone/hue clamping.
The concrete template design is a research deliverable and a Phase B decision.

### Verification

Re-render all twelve wallpapers and assert every generated primary/secondary/tertiary sits
within the intended cool/dark spectrum and above a minimum saturation — mechanically, not
by eye. That check should live in `checks/`.

---

## 4. 🔴 Glassmorphism is opaque — the panels are literally alpha 1.0

**Status: PROVEN.** Bug list: "glassmorphism too dark — panels look like opaque black
rectangles, not frosted glass."

Spec: `background: rgba(10,14,26, 0.55–0.65)`. Actual, per surface:

| Surface | Source | Actual alpha | Spec |
|---|---|---|---|
| **QuickShell panels** | generated `quickshell.json` → `"panel": "#0b0e16"` | **1.00 (fully opaque)** | 0.55–0.65 |
| Rofi | generated `rofi.rasi` → `#05060bf2` | 0.949 | 0.55–0.65 |
| Waybar | generated `waybar.css` → `rgba(5,6,11,0.82)` | 0.82 | 0.55–0.65 |

The QuickShell case is the worst and the most subtle. `core/Tokens.qml` has a *correct*
translucent fallback:

```qml
readonly property color panel: palette.panel || Qt.rgba(0.043, 0.055, 0.086, 0.94)
```

…but `palette.panel` loads successfully from the generated JSON as the **6-digit hex
`#0b0e16`, which carries no alpha channel and is therefore fully opaque**. The working
fallback is only used if the palette fails to load. The template silently destroys every
panel's translucency.

Compounding it, `decoration:blur:brightness = 0.84` (confirmed live via `hyprctl getoption`)
*darkens* whatever blur does get through, and `layer_rule ignore_alpha = 0.50` in
`rules.lua` means surfaces must stay above 0.50 alpha to be blurred at all — directly
relevant when tuning down to the 0.55–0.65 target, which leaves very little margin.

### Fix

Emit alpha in the generated colours (8-digit hex / explicit `rgba`) for all three consumers,
retune to the 0.55–0.65 band, raise `blur:brightness` toward 1.0, and re-check
`ignore_alpha` against the new alphas. The "can you see the wallpaper through it" test is
the acceptance criterion.

---

## 4a. The blur plumbing is already CORRECT — opacity is the whole bug

**Status: PROVEN.** This is good news and it narrows §4 considerably.

I checked whether our blur `layer_rule`s actually reach the surfaces, rather than assuming.
Live namespaces:

```
$ hyprctl layers
Monitor eDP-1:
  Layer level 0 (background): namespace: awww-daemon      xywh: 0 0 1707 1067
  Layer level 2 (top):        namespace: aurora-taskbar    xywh: 8 6 1691 40
```

And `core/PanelHost.qml:16` names every panel surface:

```qml
property string layerNamespace: "aurora-panel-" + panelName
WlrLayershell.namespace: host.layerNamespace
```

Against `rules.lua`, which blurs these namespaces — `waybar`, `rofi`, `launcher`, `swayosd`,
`osd`, `notifications`, `quickshell:.*`, `aurora-.*`:

| Rule | Matches what, in reality |
|---|---|
| **`aurora-.*`** | **`aurora-taskbar` (Waybar) and `aurora-panel-*` (every panel) — this one does all the work** |
| `quickshell:.*` | **nothing** — we set custom namespaces, so QuickShell never uses its `quickshell:*` default |
| `waybar` | **nothing** — the real namespace is `aurora-taskbar`, which does not contain "waybar" |
| `rofi`, `launcher`, `swayosd`, `osd`, `notifications` | unverified; likely dead for the same reason |

So **blur is being applied correctly to Waybar and to every panel, via `aurora-.*`.** Five of
the eight rules are dead weight, but harmlessly so.

**This is the decisive point:** the compositor is dutifully blurring the wallpaper behind
panels that are **fully opaque** (§4), so not one blurred pixel can be seen. We have been
paying the iGPU cost of blur the entire time and receiving zero visual benefit from it.

The glass fix is therefore **primarily a template alpha fix, not a blur-mechanism fix** —
much cheaper and lower-risk than it first appeared. Two caveats when the alpha drops:

- `ignore_alpha = 0.50` means pixels *below* 0.50 alpha are not blurred. Our 0.55–0.65 target
  clears it, but only just. The caelestia audit found a better idiom: set `ignore_alpha` just
  under the panel alpha (they use `base - 0.03`), so the panel body blurs while transparent
  padding and rounded corners do not develop blurred halos.
- `decoration:blur:brightness = 0.84` darkens the blur and should move toward 1.0.

Dead rules should be cleaned up so the config stops implying coverage it does not have.

---

## 5. 🔴 Rofi is broken because the theme is incomplete

**Status: PROVEN.** Bug list: "alternating pink/beige rows on purple background with a
dashed border… looks broken, not styled."

**Corrected and made precise by dumping the live theme.** My first draft said "the theme only
overrides some properties and inherits Rofi's light defaults for the rest", and blamed the
pink on §3. The *effect* was right; the *mechanism* and the *colour* were both wrong.
Recording the correction so it is not inherited.

`rofi -dump-theme` run against the live config shows exactly what survives:

```rasi
element alternate.normal {
    background-color: var(alternate-normal-background);   /* survived from Rofi's DEFAULT theme */
    text-color:       var(foreground);                    /* our override */
}
alternate-normal-background: var(lightbg);
lightbg: rgba ( 238, 232, 213, 100 % );   /* #eee8d5 — opaque SOLARIZED BEIGE */
listview { border: 2px dash 0px 0px; }    /* the dashed border, survived */
```

So:

- **The rows are not pink, and Matugen is not involved.** They are `#eee8d5`, opaque
  Solarized beige, straight out of **Rofi's built-in default theme**. The palette bug (§3) is
  real but was *never* the cause of this symptom.
- **It is a theme-*loading* bug, not a theme-*completeness* bug.** Per `rofi-theme(5)`,
  `@import` = "import and parse a second file" (**merges** into the default theme), whereas
  `@theme` = "**discard theme**, and load file as a fresh theme". `config.rasi:24` uses only
  `@import`, so **Rofi's default theme is never discarded** and every property we do not
  explicitly set survives from it. Our `*` block does override `background`, which is why
  `normal` rows look correct and only `alternate` rows break.
- **Verified one-line fix:** adding `@theme "/dev/null"` before the import →
  `lightbg` references 0, `alternate.normal` background gone, dashed border gone.

### This also refutes the brief's account of the Rofi failure

The brief says we "were supposed to use newmanls/windows11-list-dark but clearly wasn't
applied properly", implying a complete theme was swapped for a partial one. Fetching the real
`windows11-list-dark.rasi` shows it sets **no** `element normal.normal` background, **no**
`element alternate.normal` background, **no** `normal-background`, **no**
`alternate-normal-background` and **no** `listview border` either.

**Both themes are partial.** windows11-list-dark works only because it is loaded via
`-theme` / `@theme`, which discards the default. `@import`-ing it would have reproduced our
exact bug. The regression was the **loading verb**, not the theme's completeness.

(Its window alpha is **0.75** against our **0.949** — which independently accounts for the
opacity miss.)

### Click-away dismiss — the obvious explanation is REFUTED

**Status: OPEN.** `click-to-exit: true` **is** already set (line 14), so the option is not
the issue.

**An earlier draft of this log blamed XWayland. That was wrong — recording the correction so
it is not inherited.** The reasoning came from `BUILD_PLAN.md`, which says we use `pkgs.rofi`
because `rofi-wayland` "was removed" from nixpkgs; from that I inferred we run the X11 Rofi
under XWayland, unable to see clicks landing on native Wayland surfaces.

Checked instead of assumed:

```
$ rofi -version
Version: 2.0.0
$ rofi -help
	• xcb     enabled
	• wayland enabled (1.25.0)
	• wayland: selected          <-- the Wayland backend is ACTIVE
```

`rofi-wayland` was not removed so much as **absorbed**: upstream Rofi 2.0 merged Wayland
support, and our build has it compiled in *and selected at runtime*. Rofi is a **native
Wayland client**, so the XWayland theory cannot explain the symptom.

That reopens the question rather than answering it. Causes now worth testing: whether Rofi
2.0's `click-to-exit` is honoured on the Wayland backend at all (it may be an xcb-only code
path), and whether the `rofi-toggle` `pgrep`/`pkill` wrapper interferes. Delegated to
research. **Do not act on the XWayland story.**

Consequence for the plan: because Rofi is native Wayland it *is* a layer-shell client, so
layer rules can in principle reach it (see §4a). Replacing the launcher (fuzzel / anyrun /
walker / a QuickShell-native launcher reusing our existing focus-grab dismissal) is therefore
no longer forced by an architectural dead end — it is a free choice to be made on merit.

---

## 6. 🟠 disable_while_typing — configured correctly, still reported broken

**Status: OPEN — the obvious explanation is disproven; needs one specific test.**

Bug list item #1, "critical". The setting is genuinely applied:

```
$ hyprctl getoption input:touchpad:disable_while_typing
bool: true set: true
```

…and `input.lua` sets it in the `touchpad` block along with `natural_scroll`,
`tap_to_click`, `clickfinger_behavior`, `scroll_factor = 0.78`.

The kernel exposes the trackpad correctly as a real touchpad — `event7`, `PROP=5`
(`INPUT_PROP_POINTER|INPUT_PROP_BUTTONPAD`), `EV=1b` (has `EV_ABS`, no `EV_REL`):

```
N: Name="Apple Inc. Apple Internal Keyboard / Trackpad"
P: Phys=usb-bce-vhci-5/input2    H: Handlers=event7 mouse0    B: PROP=5   B: EV=1b
```

Hyprland lists it under `mice:` with `scroll factor: -1.00`:

```
mice:
	Mouse at 56364bbee300:
		apple-inc.-apple-internal-keyboard-/-trackpad-1
			default speed: 0.00000
			scroll factor: -1.00
```

**An earlier draft of this log read `-1.00` as "the touchpad block is inert". That is
probably wrong, and the correction matters — recording it so the mistake is not inherited.**
In `hyprctl devices -j` this field is the *per-device override* (`device:<name>:scroll_factor`),
which is legitimately unset because we only set the **global** `input:touchpad:scroll_factor`.
`-1.00` therefore means "no per-device override", not "touchpad settings not applied".

The decisive counter-evidence is behavioural: `tap_to_click`, `natural_scroll` and
`clickfinger_behavior` all live in the *same* `touchpad{}` block, and Alex has never reported
them broken. If the block were inert, tap-to-click would not work — and that is impossible to
miss. So the block is almost certainly being applied, and the two bugs are separate:

- **DWT (§6):** applied but **not effective**. libinput implements DWT by *pairing* a touchpad
  with an internal keyboard. Here both nodes sit on `apple_bce`'s **virtual USB host**
  (`usb-bce-vhci`) sharing vid/pid `05AC:0280`. A pairing heuristic that expects an internal
  bus may decline to pair them, so DWT is enabled but never engages.
- **Scroll (§7):** applied, but `0.78` is simply too mild — a 22% reduction is nowhere near
  enough for this trackpad.

**Confirm before fixing — one question to Alex settles it:** *do tap-to-click and two-finger
scrolling work today?* If yes, the block applies and the above holds. If tap-to-click is also
broken, the original inert-block hypothesis returns and the fix is a per-device section.

Cheap live test for Phase B (a runtime eval, no file change, fully reversible):

```sh
hyprctl eval 'hl.config({ device = { ["apple-inc.-apple-internal-keyboard-/-trackpad-1"] = { disable_while_typing = true, scroll_factor = 0.4 } } })'
# then type continuously with a palm on the pad, and compare scroll speed before/after
```

Do not ship a fix for either item without an empirical before/after.

---

## 7. 🟠 Scrolling too sensitive outside the terminal

**Status: STRONG — most likely just an under-tuned value, not a broken mechanism.**

`scroll_factor = 0.78` is applied globally (see the correction in §6 — it *is* reaching the
device). 0.78 is only a 22% reduction from default, which is nowhere near enough for an Apple
trackpad whose raw deltas are large.

"Fine in terminal, jumps everywhere else" fits this cleanly and is a useful clue: Kitty
consumes scroll as **discrete line steps**, so an oversized delta still moves ~1 line and
feels normal. GTK/Chrome consume **continuous per-axis deltas**, so the same oversized value
scrolls a whole screen — "jumps everywhere".

Fix: lower `scroll_factor` to roughly **0.3–0.5** and tune by feel with Alex. If that alone
does not bite, fall back to the per-device test in §6.

---

## 8. 🟠 Screenshot "purple overlay covering the capture"

**Status: PROVEN.** Bug list item #8.

`scripts/screenshot-area` line 18:

```sh
selection="$(slurp -d -b '#030308cc' -c "${primary}ff" -s "${tertiary}55" -w 2)"
```

`-s` is slurp's **selection fill**. It is set to `tertiary` at `55` (33%) alpha — and
`tertiary` is currently `#f1b5db`, **pink** (§3). So the region being selected is washed with
33% pink, which is exactly the reported symptom.

The saved PNG is not actually tinted — slurp only draws the overlay and `grim` captures
after it exits — so this is a "cannot see what I am selecting" bug rather than corrupted
output. Worth stating plainly to Alex, since the bug list describes it as "covering the
capture".

### Fix

Selection fill should be fully transparent so the true content shows through:
`-s '#00000000'`, keeping `-b` for the dim outside and `-c` for the accent border. §3 fixes
the pink independently, but the selection fill should be transparent regardless.

---

## 9. 🟠 Weather is set to Chicago, not Austin

**Status: PROVEN.** Bug list item #12.

```
scripts/weather-fetch:10:latitude="41.8781"
scripts/weather-fetch:11:longitude="-87.6298"
scripts/weather-fetch:13:location="Chicago"
modules/home/quickshell/config/services/WeatherService.qml:12: location: "Chicago",
modules/home/quickshell/config/services/WeatherService.qml:25: readonly property string location: data.location || "Chicago"
```

Required: Austin, TX — **lat 30.2672, lon -97.7431**. Note the timezone
`America/Chicago` is *correct* for Austin and should stay. The value is duplicated across
two files and appears twice more as a QML default — all four sites must change, which is
itself a smell worth fixing (single source of truth).

---

## 10. 🟠 CPU and Memory buttons open the same window

**Status: PROVEN.** Bug list item #10. Literally identical handlers in `config.json`:

```json
"cpu":    { "on-click": "missioncenter" }
"memory": { "on-click": "missioncenter" }
```

Ties into the request for system monitoring as a workspace-2 terminal-style view rather than
a widget popup. Note the handoff report also records that Mission Center cannot report Intel
GPU utilisation on this hardware and sometimes refuses its auxiliary socket — so it is a weak
destination for either button. Delegated to research.

---

## 11. 🟠 EasyEffects is a visible application

**Status: PROVEN.** Bug list item #15. Two separate causes:

1. **It is treated as a real app window.** `rules.lua` lines 20-33 give
   `com.github.wwmm.easyeffects` a float+center rule at 72% of the monitor — i.e. the config
   explicitly styles it as a visible window.
2. **It appears in the launcher.** Visible in the Rofi screenshot as "Easy Effects". Its
   `.desktop` entry needs `NoDisplay=true`.

It should be invisible background infrastructure: keep the service, remove the float rule,
mask the desktop entry, and ensure it never takes focus.

---

## 12. 🟠 Cmd+Space opens the wrong thing

**Status: PROVEN.** Bug list item #5. `keybinds.lua` line 27:

```lua
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }))
```

Super+Space is bound to **float/tile toggle**, not the launcher. (Alex reported it as
"window focus"; the actual binding is float toggle — same conclusion.) This is currently
*intentional* and documented in `docs/controls.md`, so it is a design change, not a
regression: Alex wants macOS Spotlight muscle memory. Fix requires rehoming float-toggle to
a free chord.

Related, item #13: **Cmd+arrow does not move windows.** Lines 34-42 bind `SUPER+arrow` to
**focus** and `SUPER+SHIFT+arrow` to **move**. Alex wants Cmd+arrow to move/snap. These two
requests plus bare-Super-opens-launcher interact, so the keymap needs designing as a whole
rather than patching one bind at a time.

---

## 13. 🟡 Delete/backspace speed

**Status: NOT POSSIBLE as literally requested.** Bug list item #11 asks for "progressive
(slow start, accelerate)".

`input.lua` sets `repeat_delay = 300, repeat_rate = 35`. 35 chars/sec is fast (default 25),
which explains "too fast".

But the Wayland/libinput keyboard repeat model is a **fixed delay + fixed rate**. There is no
acceleration curve; `wl_keyboard.repeat_info` carries exactly two integers. Progressive
acceleration cannot be expressed. Options, honestly:

- tune to something calmer (e.g. `repeat_delay 400`, `repeat_rate 20-25`) — recommended;
- true acceleration would require an input-remapping layer (keyd, xremap) intercepting
  evdev and synthesising repeats, which is a real daemon in the input path on the *only*
  keyboard of a laptop — a meaningful reliability risk for a cosmetic gain.

Recommend tuning. Do not promise acceleration.

---

## 14. 🟡 Kitty Ctrl+T / Ctrl+Shift+T

**Status: PARTIALLY POSSIBLE.** Bug list item #14.

`kitty.conf` binds only `map ctrl+c copy_or_interrupt`. Kitty's default new-tab is
`ctrl+shift+t`, so **Ctrl+T does nothing** today. Remapping Ctrl+T → `new_tab` is trivial.

**"Reopen last closed tab" has no native Kitty implementation.** There is no built-in
undo-close-tab. It would need a custom kitten tracking closed tabs' cwd/command, and would at
best restore the working directory, not the process. Flagging rather than silently shipping
a half-feature.

### The SIGUSR1 constraint is very likely a misdiagnosis

`EXECUTION_LOG.md` records: *"Never send Kitty `SIGUSR1`: it terminates this Kitty 0.47.4
build."* **The source says the opposite.** In v0.47.4 `child-monitor.c`:

```c
#define KITTY_HANDLED_SIGNALS SIGINT, SIGHUP, SIGTERM, SIGCHLD, SIGUSR1, SIGUSR2, 0
...
case SIGUSR1:  ss->reload_config = true;  break;
```

SIGUSR1 is **reload-config**, handled via signalfd in the event loop.

The probable real cause: SIGUSR1's *default disposition is Term*, and **only the kitty GUI
process installs the handler**. A broad `pkill -USR1 kitty`-style send also reaches the
`kitten __watch_conf__` and `kitten __atexit__` helpers and kitty's own children — none of
which handle it. They die, the window vanishes, and it presents as "kitty terminated". Both
helpers are visible in our own live process tree (`kitten __watch_conf__ 2292 …`), which makes
this mechanism concrete rather than hypothetical.

**Keep the constraint regardless.** It was not re-tested against Alex's live terminal (rightly
— the downside is losing his session), and it is moot: command-scoped remote control
(`remote_control_password "" set-colors`) is a strictly better live-recolour mechanism and
avoids signals entirely. See plan §5.9a. Recorded because an incorrect "never do X" hardens
into folklore and quietly forecloses good options.

---

## 15. 🟠 "Opening 3+ windows causes existing ones to close after resize"

**Status: STRONG — and the design reference's own guess ("tiling bug") is probably wrong.**

The bug list files this under tiling. The evidence points at §1 instead. `waybar.service`:

```
KillMode=control-group
Restart=on-failure
OOMPolicy=stop
```

With Chrome's renderers **inside Waybar's cgroup** (§1) and only 7.6 GiB RAM, a precise
mechanism exists:

> Open several windows → memory pressure → the OOM killer takes a Chrome renderer (high
> `oom_score`, and it lives in `waybar.service`) → `OOMPolicy=stop` stops the **whole unit**
> → `KillMode=control-group` then kills **every** process in the cgroup → Kitty and all of
> Chrome die at once.

That reads to a user exactly as "opening more windows made my existing windows close".
`Restart=on-failure` gives the same outcome from any Waybar crash.

**Not yet proven.** It did not reproduce this boot: `NRestarts=0`, no OOM events in the
journal, and 4.6 GiB available with zram unused. The handoff report was equally careful
("the journal does not prove that later cause"). The honest position is that the mechanism is
confirmed to *exist* and is sufficient to cause the symptom; the trigger is unconfirmed.

Fixing §1 removes this mechanism entirely. **Test by reproduction after the §1 fix** —
open many windows and try to provoke it — rather than declaring it fixed.

---

## 16. Remaining reported items — carried forward, not yet root-caused

| # | Item | Status | First note |
|---|---|---|---|
| 3 | Border resize only expands, never shrinks | **OPEN** | `resize_on_border = true`, `extend_border_grab_area = 12`, `dwindle.smart_resizing = true` are all set. In a dwindle tile, dragging an *outer* edge has no neighbour to resize against, which may be exactly what Alex is hitting. Needs a reproduction to distinguish "works only on shared borders" from a real bug. |
| 7 | Drag windows by titlebar without a modifier | **OPEN** | `SUPER+mouse:272` is the documented fallback. Native CSD titlebars should already drag. Needs to be established per-app (Chrome CSD vs Kitty, which has no titlebar) before it can be called a bug. |
| 17 | Window buttons on windows themselves | **OPEN / deferred** | `BUILD_PLAN.md` deliberately rejected `hyprbars` (double decorations, `resize_on_border` conflicts, XWayland pointer issues). Revisit only with evidence it is now stable. |
| 16 | Wallpaper picker buried under the battery panel | **PROVEN, by design** | `PowerPanel.qml` owns it; `docs/controls.md` documents it. Needs a system/settings panel to move to. |
| — | Chrome renders a bright white titlebar/bookmark bar | **PROVEN (visual)** | Clearly visible in the 03:44 screenshot; the single most jarring break in colour cohesion. Mechanism to fix delegated to research. |
| — | Icon theme inconsistency | **PROVEN** | `config.rasi` sets `icon-theme: "Adwaita"` while Papirus is the system icon theme. |
| — | Hardcoded path in a managed file | **PROVEN** | `config.rasi:24` imports `/home/alex/.cache/…` literally. Works, but hostile to the portable-flake goal. |

---

## 15a. 🔴 libadwaita never enters dark mode — found during the GTK audit

**Status: PROVEN.** Not on the brief's bug list; found by auditing the evaluated config.

```
gtk-4.0/settings.ini → gtk-application-prefer-dark-theme=1   <- libadwaita IGNORES this + warns
gtk.colorScheme = null
dconf org/gnome/desktop/interface = {cursor-size, cursor-theme, font-name, gtk-theme, icon-theme}
                                     <- NO color-scheme key
```

libadwaita's dark values live behind `@media (prefers-color-scheme: dark)`, driven by
`color-scheme` via the portal/gsettings — which we never set. **So libadwaita apps
(`mission-center`, `pwvucontrol`) run the LIGHT stylesheet.** Our nine `@define-color`
overrides punch dark holes into a light theme while ~30 unoverridden colours stay light:
`dialog_bg_color #fafafb`, `thumbnail_bg_color #ffffff`, `scrollbar_outline_color white`.

Pale-lavender accent (§3) over light surfaces **is** the mauve wash.

**Fix:** `gtk.colorScheme = "dark"` + override the full name set. See plan §5.7.

Related, and separately fixable: adw-gtk3-dark hardcodes **GNOME neutral greys with zero blue
undertone** (`dialog_bg_color #36363a`, `sidebar_backdrop_color #28282c`) which we do not
override — that, not Thunar itself, is why Thunar "looks dated".

### A correction to my own reasoning, recorded

I earlier treated EasyEffects' mauve window as evidence that "some GTK4/libadwaita theming is
landing". **Wrong.** EasyEffects 8.2.4 is **Qt6/Kirigami** (`qtbase-6.11.0`, `kirigami-6.27.0`;
no libadwaita, no gtk4). Its mauve comes from the *Qt* stack — `qt.platformTheme.name = "gtk3"`
+ `qt.style.name = "adwaita-dark"` bridging GTK3 colours into QPalette. **Thunar links
`libgtk-3`** (verified by `ldd`). The single observation I reasoned from told me nothing about
libadwaita at all.

---

## 16a. On "how Codex failed" — the record, corrected

The brief lists seven charges. Phase A's evidence supports some and refutes others. This
matters because the wrong diagnosis produces the wrong plan.

**Refuted — these were not possible:**

- *"The agridyne sidebar style wasn't referenced at all."* agridyne/dotfiles-dt is a **KDE
  Plasma** rice (Kurve + YoRHa HUD + Panel Colorizer). It cannot be referenced from Hyprland.
- *"The ilyamiro QuickShell code was barely used (only the EQ widget)."* ilyamiro is a
  **single morphing hub** — an architecture `BUILD_PLAN.md` explicitly and correctly rejects.
  It also has **no cava at all**, so the "EQ widget" framing is itself off. Using more of it
  would have meant importing the architecture we ruled out.
- *"Reference mubin-thinks/minimal-wm-config for what REAL universal theming looks like."*
  That repo contains **no matugen, no pywal, no templates, and does not theme Chrome**. There
  was nothing there to learn from. Its companion repo `mubin-thinks/charcoal` **does not
  exist** (404).
- *"end-4/dots-hyprland waybar styling"* — end-4 has **zero waybar files**; it is fully
  QuickShell now.

**Supported — but with a sharper cause than "surface-level research":**

- *"Half-applied color theming."* True, and now precisely explained: surfaces are **hardcoded
  literals** while accents are **derived** — the exact inverse of the intent (plan §5.1).
- *"Glassmorphism is opaque black."* True: 6-digit hex destroys alpha, and the compositor has
  been blurring behind fully opaque panels the whole time (§4, §4a).
- *"Rofi… clearly wasn't applied properly."* True, and the literal mechanism is now known: an
  `@import` that never discards Rofi's default Solarized theme (§5). Note LinuxBeginnings'
  own `layerrule = blur, waybar` is **commented out** upstream — so a faithful copy renders
  unblurred, which may be exactly what happened.
- *"Everything is too small and cramped."* True — though the **bar height (40px) is already in
  spec**; the defect is internal density, not height.

**The real failure mode.** Not laziness, and not "didn't read the references" — several
references contained nothing to read. It is that **nothing was verified against the running
machine**. Every one of these would have been caught by a single check:

| Defect | The check that would have caught it |
|---|---|
| `prefer` silently ignored | `matugen --version` vs the config's key set |
| Pink accents | render one wallpaper, look at the hex |
| Opaque panels | `hyprctl layers` + read the generated alpha |
| Dead workspace buttons | `hyprctl dispatch workspace 2` once |
| Beige Rofi rows | `rofi -dump-theme` once |
| Apps dying with Waybar | `systemctl --user show waybar -p KillMode` once |

`EXECUTION_LOG.md` records extensive static validation — nix parse, nixfmt, JSON, ShellCheck,
qmllint, flake eval, closure checks — and **all of it passed**. That is the lesson: this class
of defect is invisible to static validation. It is only visible by running the thing and
looking at it. The log's own note about the Hyprland 0.55 dispatch bug says exactly this
("Static JSON, Nix, and even config parsing did not catch the original legacy dispatch
strings") — the insight was already there and simply was not generalised.

---

## 17. Infrastructure that is solid — keep, do not touch

The plumbing is genuinely good. The failure was confined to visual surfaces and a few
lifecycle details. Keep:

- pinned flake + module graph; machine-local firmware adapter; `checks/preflight.sh`;
- **every T2 invariant** — `linux-t2` 6.18.35, 163 Broadcom firmware files, `apple_bce`,
  `brcmfmac`, `hci_bcm4377`, `i915`, systemd-boot, `canTouchEfiVariables = false`, macOS
  dual boot, `nix-ld`, `allowUnfree`;
- **`debug.disable_scale_checks = true`** — load-bearing for Retina geometry; removing it
  reintroduces the dead bands. Do not touch;
- Hyprland native-Lua module split; the animation/rules/env organisation;
- QuickShell `PanelCoordinator` / `PanelHost` architecture, lazy panels, native services
  (Networking, BlueZ, PipeWire, UPower, MPRIS, notifications), typed IPC;
- the atomic `apply-wallpaper` pipeline design (lock, staged render, atomic install) — the
  *mechanism* is sound; only the template *content* is wrong;
- notification ownership model with the inactive Dunst fallback;
- Waybar as the bar, dispatching to QuickShell over IPC.

## 18. What must be replaced or overhauled

- every Matugen **template** (§3, §4) — the pipeline stays, the colour content is wrong;
- Waybar CSS/layout: sizing, spacing, padding, glass, and the workspaces module (§2);
- the Rofi theme, wholesale (§5) — and possibly the launcher itself;
- QuickShell panel **styling and layout** (not architecture): calendar structure, music
  sizing, WiFi content (speed, not signal %), power panel reorganisation;
- the custom wallpaper picker → a proper picker, moved out of the power panel;
- GTK/Chrome theming, to actually reach every surface;
- new: sidebar/dock, terminal startup experience, system-monitor view, animated wallpapers.

---

## Dependency note for the plan

§3 (palette) is the **root dependency**. Waybar CSS, Rofi, QuickShell panels, GTK, Chrome,
Hyprlock, notifications, the screenshot overlay and the Hyprland borders all consume Matugen
output. Restyling any of them before the palette architecture is fixed means doing the work
twice — and is very likely what happened the first time.

§1 (Waybar cgroup) is the **safety** dependency: it gates whether Phase B can restart
services at all while Alex has work open.

---

# Stage 0 additions (2026-07-21)

## 19. `start-hyprland` warning at boot — root cause (STRONG; documented, not fixed)

**What emits it:** the `start-hyprland` wrapper script shipped inside the Hyprland
package, which the flake's greetd session commands invoke —
`modules/nixos/desktop.nix:20` (`initial_session`) and `:24` (tuigreet `--cmd`) both run
`${pkgs.hyprland}/bin/start-hyprland`. The wrapper complains when it is launched outside
a fully systemd-managed graphical session (no session manager owning
`graphical-session.target` for it).

**Why it appeared when the flake lineage replaced the channel lineage:** the channel
config's greetd ran the bare compositor binary — `${pkgs.hyprland}/bin/Hyprland` — so no
wrapper ever executed and nothing printed. The flake generation switched the greetd
command to the `start-hyprland` wrapper; the warning entered the boot path with that
switch, not with any regression in the session itself.

**Why it is cosmetic:** the repo already carries the exact lifecycle glue the wrapper
warns is missing. `modules/home/hyprland/default.nix:54-62` defines a compositor-owned
`hyprland-session.target` bridging `graphical-session-pre.target` /
`graphical-session.target`, and `modules/home/hyprland/hyprland/autostart.lua` imports
the session environment into `systemd --user` and starts/stops that target on compositor
start/shutdown ("Raw start-hyprland does not manage graphical-session.target for us").
User services therefore get a clean start/logout lifecycle regardless of the wrapper's
complaint; the warning is boot-console noise, not a functional failure.

**Verbatim text:** not recorded anywhere in this repo (searched `ISSUE_LOG.md` and the
full tree for `start-hyprland`; only references to the phenomenon exist). The Stage 0
gate reboot will capture the exact wording.

**Fix:** lands in Stage 7's session-chain rebuild (greetd + regreet per GRAND_PLAN
§5.11 / Stage 7). Do not touch the greetd command or session wiring before then.
