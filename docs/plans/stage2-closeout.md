# Stage 2 Close-Out — Operator Gate

**Status: `STAGE 2 — OPEN`.**

**Generation running:** 26 — and it is also the **default boot target**.
**Generation 27:** built on 2026-07-28 and briefly staged, then **deliberately
un-staged on 2026-07-29**. It is a valid compile/staging milestone, **not** the
Stage 2 candidate: it predates the approved snap, minimize, rail and pointer-focus
decisions. Its store outputs remain valid and are **reused**, so the patched
compositor and ABI-matched hyprbars are not recompiled.
**Fallback:** generation 26 is what is running; nothing to roll back to yet.
**Branch:** `main` (canonical; the former `codex/macbook-desktop` line was
normalized onto `main` and retired 2026-08-09). Historical HEAD when this gate
was authored: `04cab49` plus the 2026-07-29 documentation correction.

**This gate is not yet reachable.** Four Stage 2 deliverables — `follow_mouse = 2`,
the same-workspace minimize backend, the deterministic two-pane snap, and the
minimum left-rail application slice — were added by the 2026-07-29 architecture
correction and are not yet written. The batch is **not frozen** and no build has
been started for it.

`Tested` is `PASS` / `FAIL` / `UNVERIFIED`. **No row may be blank, and a check
that was not run is `UNVERIFIED`, never an implied `PASS`.** Rows are filled from
Alex's own words at the gate sitting, not from PM inference.

---

## Drag anchor

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| Tiled drag from grab position 1 (near top-left of titlebar) | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Tiled drag from grab position 2 (near top-right) | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Tiled drag from grab position 3 (near bottom-left) | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Tiled drag from grab position 4 (near bottom-right) | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Short window | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Tall window | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| `Super+LMB` drag | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Titlebar drag | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| No centre jump on pickup | Y | Y | Y | N | UNVERIFIED | N | Patched output `wrz9r718…` valid; running compositor is still unpatched until reboot |
| Floating drag unchanged (no regression) | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Drop-to-retile works | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |

## Half-snap

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| `Super+Left` | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Live since gen 26; never exercised by the operator |
| `Super+Right` | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Live since gen 26; never exercised by the operator |
| No top-left drift | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Awaiting operator |
| All edges in frame | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Awaiting operator |
| Second arrow press returns to tiling | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Awaiting operator |
| New windows do not tile under a permanent floating snap | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Awaiting operator |
| Dragged snapped window behaves normally | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Awaiting operator |
| Next arrow re-snaps | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Awaiting operator |

## Disable while typing

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| libinput reports DWT available/enabled for `/dev/input/event7` | Y | **Y** | Y | N | UNVERIFIED | N | Pre-verified in the built closure: `systemd-hwdb query` against the device's real composed key returns `ID_INPUT_TOUCHPAD_INTEGRATION=internal`, negative control empty. Runtime `libinput list-devices` check owed after reboot — currently `n/a`. |
| Typing with natural palm placement does not move the cursor | Y | Y | Y | N | UNVERIFIED | N | Needs Alex's hands after reboot |
| No destructive typing/trackpad regression | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Palm/thumb thresholds measured (`libinput measure touch-size`) | N | N | N | N | UNVERIFIED | N | **Separate second pass — deliberately does not block this batch.** Needs Alex's hands. |

## Corner resize

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| Floating window — top-left corner | Y | Y | Y | N | UNVERIFIED | N | The specific corner proven dead pre-patch |
| Floating window — top-right corner | Y | Y | Y | N | UNVERIFIED | N | The specific corner proven dead pre-patch |
| Floating window — bottom-left corner | Y | Y | Y | N | UNVERIFIED | N | Worked pre-patch; must not regress |
| Floating window — bottom-right corner | Y | Y | Y | N | UNVERIFIED | N | Worked pre-patch; must not regress |
| Expand | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Shrink | Y | Y | Y | N | UNVERIFIED | N | **Re-check the "one direction only" claim here.** `DragController.cpp:305-345` is symmetric; if one-directionality survives, the mechanism explanation is wrong and this reopens. |
| Titlebar and buttons unaffected | Y | Y | Y | N | UNVERIFIED | N | Zero hyprbars lines changed; hover patch byte-identical |
| Ordinary border resize unaffected | Y | Y | Y | N | UNVERIFIED | N | Left/right/bottom bands provably pixel-identical |
| `Super+RMB` still works | Y | Y | Y | N | UNVERIFIED | N | Redundant path, not the solution |

*Tiled windows are excluded: dwindle one-directionality there is expected
(`docs/plans/GRAND_PLAN.md` §6.2) and must not be reported as a failure.*

## Screenshots

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| Physical-display comparison recorded | — | — | — | — | **PASS** | **Y** | Resolved by measurement, not by eye: a clean `grim -o eDP-1` capture reaches true 0,0,0 and true 255,255,255 with 0 error across 36 channel values of a 12-swatch chart. **The display is not tinted.** Alex's eyes were not required. |
| Known-colour test passed | — | — | — | — | **PASS** | **Y** | 12-swatch chart, 0/36 channel error through the full-screen path |
| Root cause identified | — | — | — | — | **PASS** | **Y** | slurp's overlay composited into the frame: alpha `0x55` = ⅓ predicts a floor of (80.33, 60.33, 73.00); files measure (80,60,73). Border (194,192,247) vs slurp's (195,193,248). |
| Region screenshot colours correct | Y | Y | Y | N | UNVERIFIED | N | slurp removed entirely; overlay is a sibling node excluded from the grab by construction. Awaiting reboot. |
| Full screenshot colours correct | Y | Y | Y | N | UNVERIFIED | N | Path was **never defective**; now via grim from the Screenshotter service. Awaiting reboot. |
| No mauve/pink cast | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| No overlay contamination baked into output | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Clipboard output | Y | Y | Y | N | UNVERIFIED | N | Both paths write clipboard **and** file |
| Timestamped PNG output | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Correct destination directory (`~/Pictures/Screenshots`) | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Keyboard bindings (`Super+Shift+S`, `Print`) | Y | Y | Y | N | UNVERIFIED | N | Rebound to `hl.dsp.global`; verified in built closure |
| Clickable path (Utilities Screenshot card) | Y | Y | Y | N | UNVERIFIED | N | `Screenshot.qml` present in the deploy closure |
| Visible error on failure | Y | Y | Y | N | UNVERIFIED | N | Test by inducing failure, e.g. `chmod 500` the destination |
| Region capture sharpness (fractional-scale resample) | — | — | — | — | UNVERIFIED | N | **Must be tested with a one-pixel checkerboard or text, NOT colour swatches** — averaging two identical pixels returns that pixel, so swatches give a false pass. Pre-existing, not a regression. Operator instruction: test first, decide after. |

## Pointer scroll and keyboard focus (`follow_mouse = 2`)

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| Scroll mouse wheel over an unfocused window — that window scrolls | N | N | N | N | UNVERIFIED | N | Added 2026-07-29; currently `follow_mouse = 0` |
| Scroll touchpad over an unfocused window — that window scrolls | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| The hovered window is the one that scrolls, not the focused one | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| Typing still goes to the last **clicked** window while hovering elsewhere | N | N | N | N | UNVERIFIED | N | The whole point of mode 2 — keyboard focus stays click-controlled |
| Clicking transfers keyboard focus normally | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |

## Minimize and left rail

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| Minimize from the titlebar button | N | N | N | N | UNVERIFIED | N | Backend being replaced; `special:min-*` rejected |
| The window leaves layout, render and input | N | N | N | N | UNVERIFIED | N | Mechanism: `setHidden` + `removeTarget` (finding 20a) |
| The window retains its **original** workspace | N | N | N | N | UNVERIFIED | N | `m_workspace` is read, never written |
| A dimmed rail entry remains visible for it | N | N | N | N | UNVERIFIED | N | Rail slice not yet written |
| One click in the rail restores and focuses it | N | N | N | N | UNVERIFIED | N | Mandatory path; hotkey is optional redundancy |
| Restore never requires visiting another workspace | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| Multiple windows of one app — preview selects the **exact** window | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| A shell restart does not strand minimized windows | N | N | N | N | UNVERIFIED | N | Must survive reload without losing windows |
| **No** minimize workspace ever appears in any switcher | N | N | N | N | UNVERIFIED | N | The specific failure of the rejected backend |
| Pinned apps are always visible in the rail | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| Rail shows running/minimized from the **current workspace only** | N | N | N | N | UNVERIFIED | N | No other-workspace clutter |
| Rail carries **no** duplicate system-status stack | N | N | N | N | UNVERIFIED | N | No workspace/calendar/tray/network/BT/audio/battery duplication |

## Deterministic two-pane snap

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| `Super+Left` = exact left half, with one window open | N | N | N | N | UNVERIFIED | N | Meaning must not depend on window count |
| `Super+Right` = exact right half, with one window open | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| Same exact geometry with two windows open | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| Same exact geometry with three or more windows open | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| One side reserved: ordinary windows **stay visible** and reflow in the opposite half | N | N | N | N | UNVERIFIED | N | Reservation/reflow model (2026-08-09 clarification) |
| Both sides reserved by explicit owners: remaining ordinary windows minimize | N | N | N | N | UNVERIFIED | N | Reservation/reflow model |
| Minimized surplus remains represented in the rail | N | N | N | N | UNVERIFIED | N | Must stay recoverable |
| Snap onto an already-reserved side **demotes** the previous owner to ordinary | N | N | N | N | UNVERIFIED | N | Previous owner joins reflow pool, not minimized |
| Restoring a minimized window when a half frees up re-tiles normally | N | N | N | N | UNVERIFIED | N | Returns to ordinary tiling |
| Dragging/unsnapping an owner releases that reservation | N | N | N | N | UNVERIFIED | N | Reservation/reflow model |
| Maximizing an owner releases that reservation | N | N | N | N | UNVERIFIED | N | Reservation/reflow model |
| Closing an owner releases that reservation | N | N | N | N | UNVERIFIED | N | Reservation/reflow model |
| Prior state/placement restored where possible | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |
| **No window is ever silently closed or lost** | N | N | N | N | UNVERIFIED | N | Hard requirement across every snap path |
| App groups behave correctly through snap/minimize/restore | N | N | N | N | UNVERIFIED | N | Added 2026-07-29 |

## Existing Stage 2 regression checks

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| Close button | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Maximize button | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Minimize button | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Visible restore path | Y | Y | Y | N | UNVERIFIED | N | `Super+Alt+M` + workspace switcher |
| Titlebar drag | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Hover highlight | Y | Y | Y | N | UNVERIFIED | N | Carried hover patch, byte-identical |
| Double-click behaviour | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Click-to-focus | Y | Y | Y | N | UNVERIFIED | N | `follow_mouse = 0` |
| Focus-on-close | Y | Y | Y | N | UNVERIFIED | N | `focus_on_close = 2` |
| Launcher (`Super+Space` and Apps button) | Y | Y | Y | N | UNVERIFIED | N | **rofi was removed this batch — confirm the launcher still opens** |
| Brightness keys + single OSD | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Volume keys + single OSD | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Screenshot keys | Y | Y | Y | N | UNVERIFIED | N | Awaiting reboot |
| Controlled held-backspace repeat | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | `repeat_delay 350` / `repeat_rate 22`; empirical check never run |
| Pinch zoom | Y | Y | Y | **Y (gen 26)** | **PASS** | **Y** | Alex, physical confirmation prior to 2026-07-29 (decision 20 item 26). **Not retested unless touched.** |
| Workspace gestures (3-finger swipe) | Y | Y | Y | **Y (gen 26)** | UNVERIFIED | N | Do-not-regress item |
| Zero Hyprland config errors | Y | Y | Y | N | UNVERIFIED | N | `hyprctl configerrors` after reboot |
| Zero failed units | Y | Y | Y | N | UNVERIFIED | N | `systemctl --failed` + `--user --failed` after reboot |
| Dunst fallback unaffected by the package sweep | Y | Y | Y | N | UNVERIFIED | N | Static `assets/fallback-dunstrc` retained |

## Carried acceptance debt

| Requirement | Written | Built | Installed | Activated | Tested | Passed | Evidence |
|---|---|---|---|---|---|---|---|
| TV reachable from the living-room TV | Y | Y | Y | Y | UNVERIFIED | N | Stage 0 debt; deferred twice, never physically run. Inference-backed only. |
| Xbox controller remains paired and usable | Y | Y | Y | Y | UNVERIFIED | N | Stage 0 debt; BlueZ LE tuning in the flake, `/var/lib/bluetooth` untouched, nobody has held the controller |
| VA-API / iHD encode objectively verified | Y | Y | Y | Y | UNVERIFIED | N | Stage 1 debt. `vainfo` is **not in the closure**, so `docs/plans/GRAND_PLAN.md` §5.12's check has never been runnable as written — needs `libva-utils` or another route. |

---

## Gate result

**Operator acceptance:** *not given.*
**Accepted generation:** *none.*

Stage 2 remains `OPEN` until every row above reads `Tested: PASS` / `Passed: Y`
and Alex accepts the gate in his own words.

---

## Post-reboot runtime verification — generation 31, 2026-07-29

**Booted generation 31**; `booted == current`. These rows were verified by the PM
**without operator hands** and are recorded as `PASS` on machine evidence. Everything
not listed here still requires Alex's physical test.

| Requirement | Result | Evidence |
|---|---|---|
| Patched compositor is what runs | **PASS** | PID 1706 = `wrz9r718…-hyprland-0.55.4/bin/Hyprland` |
| `aurora-minimize` plugin loads | **PASS** | `hyprctl plugin list` → "Plugin aurora-minimize by Aurora" |
| hyprbars still loads (ABI intact) | **PASS** | same listing; no SIGSEGV, no safe mode |
| Zero Hyprland config errors | **PASS** | `hyprctl configerrors` empty |
| Zero failed units (system + user) | **PASS** | `systemctl --failed` both empty |
| **DWT available** | **PASS** | `libinput list-devices` event7 → `Disable-w-typing: enabled` (was `n/a`) |
| udev touchpad reclassification | **PASS** | `ID_INPUT_TOUCHPAD_INTEGRATION=internal`, `ID_INTEGRATION=internal` |
| Minimize: window leaves render/layout | **PASS** | live round trip, `hidden: false → true` |
| Minimize: **original workspace retained** | **PASS** | workspace `id 1` before **and** after minimize |
| Restore: unhides and focuses in one call | **PASS** | `hidden → false`, `activewindow` = the restored address |
| **No minimize workspace ever exposed** | **PASS** | `hyprctl workspaces` shows no `special`/`min` entry during minimize |
| Dashboard global unregistered | **PASS** | `caelestia:dashboard` absent from `hyprctl globalshortcuts` |
| Dashboard dropped from `showall` | **PASS** | global now reads "Toggle launcher, osd and utilities" |
| `Super+K` unbound | **PASS** | absent from `hyprctl binds` |
| Screenshot globals registered | **PASS** | `caelestia:screenshot`, `caelestia:screenshotFull` present |
| Shell runs without QML errors | **PASS** | journal clean but for pre-existing benign portal warnings |
| Working set relaunched after reboot | **PASS** | both terminals + Chrome back; Chrome restored its tab; armed flag consumed |

**Unexpected benefit, measured:** `aurora-shell` resident memory is **0.6 GB**,
against **2.8 GB** recorded in the pre-batch audit. Retiring the dashboard UI removed
a large standing allocation on an 8 GB machine.

**Still `UNVERIFIED` — needs Alex's hands:** drag anchor, corner resize both
directions, snap reservation/reflow behavior, rail click-to-restore and grouped
previews, `follow_mouse = 2` feel, DWT palm suppression while typing, screenshot
colour/clipboard/error paths, wallpaper smoke row, and the Stage 0/1 debts
(TV, controller, VA-API).
