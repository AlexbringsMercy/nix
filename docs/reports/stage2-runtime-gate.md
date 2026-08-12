# STAGE 2 CORRECTION — RUNTIME GATE

> ## ⚠ THIS GATE WAS STOPPED ON 2026-07-29 — GENERATION 32 HARD FAIL
>
> Generation 32 returned **41 PASS / 0 FAIL / 0 UNVERIFIED** on the automated pass and then
> **failed the physical gate**. The operator declared a hard fail during group A/B and
> **stopped the remaining A–H tests**. Do not resume them until the correction closure lands.
>
> Ten defects were observed, including a ~5 s full-display freeze on snap, snap geometry
> landing under the left rail, wrong-window minimize, keyboard-focus corruption, a returned
> titlebar drag-anchor regression, completely dead tiled resize, a false "active" Media Center
> rail entry, and an unequal scroll rate over hovered-but-unfocused windows.
>
> **Group C (rail previews and exact grouped selection) PASSED and must be preserved.**
>
> The automated pass **did not detect any of the ten failures**. Treat a structural pass as
> necessary, never sufficient.
>
> See `PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md`. Stage 2 remains **OPEN**.

Two parts. **The machine goes first**, so the operator's sitting stays small.

1. **Automated objective pass** — `~/.local/state/aurora-build/pm/aurora-stage2-gate-auto.sh`.
   Run immediately after the reboot. It decides every check a machine can decide:
   generation integrity, failed units, compositor/plugin ABI identity, window-model
   options, agent CLI resolution and versions in three PATH contexts, agent state
   preservation, DWT, capture stack, VA-API/iHD, time sync, protected state. It
   prints `PASS` / `FAIL` / `UNVERIFIED` per row. **`UNVERIFIED` is never a pass.**
2. **Grouped physical tests, below** — only what a human must judge.

**Baseline before reboot (generation 31):** 28 PASS · 7 FAIL · 4 UNVERIFIED. The
seven failures are precisely the deltas this closure supplies; they must all flip
to PASS.

---

## A. Tiled resizing and titlebar behaviour

**This is the Stage 2 blocker from the last gate.** Floating resize already worked
and is explicitly *not* the target.

**Do:** open **three** ordinary tiled windows. Grab each corner of the middle one
with the mouse and drag outward, then inward. Repeat with **four** windows. Then
drag a window by its titlebar.

**Pass:**
- every corner moves **both** axes wherever neighbouring layout space allows;
- **grow and shrink** both work;
- **no floating the window first**, no hotkey — plain mouse on a normal tiled window;
- titlebar drag keeps the window under the cursor at the grab point;
- `Super+RMB` still resizes (redundant path, must not have regressed).

---

## B. Snap reservation/reflow and surplus minimize

> **Snap-model clarification (2026-08-09):** the snap model is **reservation/reflow**,
> not a pair model. See `docs/plans/GRAND_PLAN.md` §6.2 and
> `docs/reports/gen32-recovery-diagnosis.md`.

**Do:** with one window, `Super+Left`, then `Super+Left` again. Add a second window;
verify both stay visible (one reserved, one reflowed). Then snap the second right.
Add a third. Then, in turn: restore a minimized window · drag/unsnap an owner ·
maximize one · close one · open a new window while a half is reserved.

**Pass:**
- halves are **exact** — fully in frame, no upper-left drift, clear of the rail;
- second press returns the window to ordinary tiling;
- one side reserved: ordinary windows **stay visible** and reflow in the opposite half;
- both sides reserved by explicit owners, no ordinary region left: surplus minimizes;
- snap onto an already-reserved side **demotes** the previous owner to ordinary;
- releasing a reservation (drag/unsnap/maximize/close) returns the region to
  ordinary tiling;
- a new window tiles in the available region.

---

## C. Rail: direct restore, previews, exact grouped selection

**Note:** hover previews failed **globally** last time — single-window Thunar only
ever proved *restore*, never *preview*. Test both.

**Do:** with **one** Thunar window, hover its rail entry, then click it. Open **two
Kitty** windows; hover the grouped entry; minimize one; click a specific thumbnail.

**Pass:**
- single-window hover shows a **live preview**;
- grouped hover shows **one thumbnail per window**, not one app icon;
- minimized members are visibly **dimmed** but still clickable;
- clicking a thumbnail focuses/restores **that exact window**;
- only **current-workspace** windows appear;
- **no** workspace/tray/calendar/network/Bluetooth/audio/battery stack on the rail.

---

## D. Pointer scrolling, keyboard focus, DWT release

**Do:** click window A. Hover window B (tiled) and scroll. Repeat with B floating.
Then hover/scroll over rail entries. Then type continuously and stop, moving the
pointer immediately.

**Pass:**
- scrolling affects the **hovered** window;
- keyboard focus **stays on A** until you click;
- **rail hover/scroll never changes brightness** (last gate: brightness fell to zero);
- volume/brightness controls elsewhere still respond to their own scroll;
- pointer control returns promptly after typing stops. **A normal libinput DWT delay
  is not a defect** — report the approximate delay rather than a verdict.

---

## E. Screenshot: Region / Window / Full screen

**Do:** open screenshot mode. Confirm the toolbar. Take one of each mode — including
**Window** on two *overlapping floating* windows. Cancel one with Escape. Then open
a PNG and look hard at where the toolbar was.

**Pass:**
- toolbar appears **top-centred** with **Region · Window · Full screen**, active mode obvious;
- **Full screen works in one click** — no Print key anywhere;
- Window captures the **exact** bounds of the **topmost** window;
- Region stays adjustable; output lands in the clipboard **and** `~/Pictures/Screenshots`;
- **the toolbar is not in any capture** — this is the measured defect this cycle fixed;
- after **both** cancel and completion, typing goes straight back to the window you
  were in, **without** clicking;
- **no screenshot/image icon appears in the app rail.**

If a capture is ever refused, you should see **"Screenshot cancelled — the capture
overlay was still on screen."** That is the guard working correctly, not a crash.
Retry; report it if it recurs.

---

## F. Boot readiness, browser and harness

**Do:** simply observe the first minutes after this reboot.

**Pass:**
- Chrome restores tabs with **no clock or certificate error**, no invalidated login;
- the resumed terminal's **first** agent request succeeds — no immediate API error;
- your terminals come back **promptly**; they must not wait on time sync.

---

## G. Claude / Codex persistence

The automated pass covers current shell, fresh login shell and the systemd user
environment. **You supply the two contexts a script cannot fake.**

**Do:** open a **brand-new terminal window** and run `claude --version`, `codex --version`.
Then **log out and back in graphically** and run the same two.

**Pass:** both resolve to `~/.local/bin/…` and report **≥ 2.1.220** and **≥ 0.145.0**.
Your conversations, credentials and settings are intact. No older copy wins.

---

## H. Visual sanity and subjective items

**Pass:** clock, tray, network, Bluetooth, audio, battery, launcher (`Super+Space`
and the Apps button) and power all behave. Single OSD for brightness and volume —
no double. Pinch zoom still works. Dashboard stays dead (`Super+K` and top-edge
swipe do nothing). Nothing looks obviously broken.

---

## Not gated here — recorded, deliberately

- **Wallpaper picker mouse discoverability** — deferred by operator approval
  (decision 28); skwd replaces it at Stage 4. **Not** marked fixed.
- **Persistent NixOS default boot** (decision 23) — performed at *this* reboot by
  holding **Control** when selecting NixOS in Apple Startup Manager, but **verified
  only on the NEXT cold boot**. Recording it as passed now would be a false pass.
- **Kitty `Ctrl+T` / reopen-last-tab** — Stage 8, never a Stage 2 blocker.

---

## Close-out condition

Stage 2 closes only when the automated pass is **0 FAIL / 0 UNVERIFIED**, every
group above passes, **and Alex accepts the gate in his own words.** Until then,
report `STAGE 2 — OPEN`.
