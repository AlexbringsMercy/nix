# Generation-32 Recovery Diagnosis — D1–D9

_Recorded 2026-08-09. Source: two independent blind GPT-5.6 Sol `xhigh` reviews
(Review A — compositor/input; Review B — snap/minimize/restore/rail state machine)
that converged with Claude's independent diagnosis after the 2026-07-29 generation-32
physical hard fail. Provenance and artifacts: `docs/reports/codex-consultation-record.md`
and `~/.local/state/aurora-build/pm/gen32-recovery/` (runtime state, not tracked)._

## Status of this document

These are **accepted recovery diagnoses**, established strongly enough to drive the next
implementation batch. They are **NOT** implemented, built, or physically accepted.

- **Stage 2 is OPEN.** Every defect below is **OPEN**.
- Generation 32 booted, passed the automated structural gate 41/41, and then **physically
  failed** the operator gate on ten defects. It is still the running generation.
- No Stage 3 deployment is permitted until Stage 2 physically passes.
- **Rail previews and exact-window rail selection work and are a preservation requirement**
  for any fix.
- This session performed **no implementation, build, activation, or reboot**.

Distinguish throughout: **diagnosed** (root cause identified) vs **proven** (verified) vs
**fixed** (implemented + reviewed build + physical acceptance — none are fixed).

---

## D1 — ~5-second snap freeze

**Root cause identified.** `screen.reserved` is absent from the Hyprland 0.55.4 Lua monitor
object. The Lua snap code falls back to `io.popen("hyprctl monitors -j")`. That runs a
**synchronous self-IPC inside a compositor Lua callback**, which deadlocks until the ~5 s
receive timeout — matching the observed ~5-second display freeze. **OPEN.**

## D2a — under-rail / bad fallback geometry

When the synchronous monitor query times out, reserved-space fallback becomes **zero**. The
resulting arithmetic matched the observed residual Chrome geometry approximately
`x=8, y=38, width=843, height=1021` (window landing under the left rail). **OPEN.**

## D2b — independent geometry error

Separate from the timeout: the Lua subtracts only the ~30 px titlebar; it does **not**
correctly account for the 2 px borders, and it treats `gaps_in` as **one** center gap even
though Hyprland applies gaps **per edge**. **OPEN.**

## D3 — unrelated partner/terminal minimizes on first snap

The gen-32 snap logic computes surplus windows as all visible windows except the active
target and a previously recorded partner. On a **fresh workspace no partner exists**, so a
normal tiled window can be classified as surplus and minimized before placement. A
gen-32-specific state-machine regression. **OPEN.** (See the corrected reservation/reflow
semantics in §"Approved snap semantics" below — the pair/partner model is rejected.)

## D4 — focus / partial-transaction failure

The snap operation performs ~13 mutations while discarding meaningful result channels.
Bookkeeping is updated **after** destructive steps without complete verification, rollback,
or reliable focus finalization — so a failure can leave partial geometry/minimize/focus
state. **OPEN.**

## D5 — rail restore cannot restore prior placement

The current minimize backend stores essentially a **weak client reference + fullscreen
mode**. Restore reinserts the client as a **new** layout window, so loss of previous
placement/layout is expected from the current architecture. **OPEN** (architectural).

## D6 — titlebar move-drag jump

The drag anchor is normalized against a **tiled-node box** and later reapplied against the
**floating client box**. Those coordinate spaces / decoration extents differ, producing the
observed jump on pickup. **OPEN.**

## D7 — resize defects (evidence-refined)

Later physical evidence **supersedes** the original broad "pointer capture never arms"
hypothesis, which is **obsolete**. Current observed behavior:

- **D7a** — the correct horizontal/vertical resize cursor appears on hover, but **mouse-down
  changes it into a diagonal corner-resize cursor**.
- **D7b** — outer horizontal edges anchor incorrectly. The shared **inner split works**
  (left window's inner/right edge; right window's inner/left edge). The **screen-outer**
  edges behave as the opposite/inner edge: the left window's outer/left behaves as if
  resizing from the right, and the right window's outer/right behaves as if resizing from
  the left.
- **D7c** — top/bottom edges **visually arm** but dragging does not resize.
- **D7d** — a hidden **center-right brightness/volume popout/layer surface** intercepts
  pointer input around that region; moving from the physical right edge back toward a window
  edge near that hidden widget can make the resize cursor disappear. The left rail does not
  show the same interception.

Later investigation areas: edge-bit selection, grab anchor, boundary selection, coordinate
conversion, and hidden layer-surface input region / mapped state. **OPEN.** Do **not** ask
the operator to repeat the old binary cursor test.

## D8 — focus-dependent Kitty scrolling — UNRESOLVED

Still **unresolved** (no accepted root cause). Observed semantics:

- Two Chrome windows on the same page: focused and hovered-unfocused scrolling are
  effectively **equal**.
- Two Kitty windows: hovered-unfocused Kitty scroll is **dramatically slower/less smooth**
  than focused Kitty.
- Reproduces even when another **Kitty** is keyboard-focused → not merely an
  active-application-**class** distinction.
- Chrome and Kitty intentionally may have different **baseline** scroll tuning.

**Required invariant:** for a given app and its configured baseline, that receiving window's
effective scroll speed must **not** change merely because keyboard focus is elsewhere.

Do **not** "fix" with a global multiplier, a universal unfocused boost, or by removing
Chrome-specific tuning. Later investigation areas: per-app rules; active-client vs
pointer-target rule recipient; pointer vs keyboard focus; Wayland axis
source/value120/discrete/continuous/frame; accumulation/coalescing/timing; raw gesture
path; Hyprland/plugin recipient selection. **OPEN / UNRESOLVED.**

## D9 — Media Center rail entry appears active while closed

Source-level cause: the pinned desktop entry is rendered at **full opacity even when
`windowCount == 0`**. Also: a previous Node-service hypothesis was **disproven**; the rail
listens for `minimize`, Hyprland emits `minimized`, and the current minimize plugin emits
**no matching event**. **OPEN.**

---

## Approved snap semantics (reservation / reflow — NOT a pair model)

The recovery investigation clarified the required product behavior. The authoritative,
binding statement lives in `docs/plans/GRAND_PLAN.md` §6.2; summarized here:

> **half-snap = a reservation with higher layout priority**; ordinary tiled windows are a
> **reflow pool**; **minimize happens only when both halves are reserved by explicit
> half-snap owners and no ordinary tiled region remains.**

- At most **one** explicit half-snap owner per half; an owner occupies the **entire** usable
  half.
- If only one half is reserved, every other eligible ordinary tiled window **stays visible**
  and reflows/tiles in the opposite unreserved half. Ordinary windows are **not** minimized
  merely because one half is occupied by a snap owner.
- Both halves reserved by explicit owners + no ordinary region left → remaining ordinary
  windows minimize.
- Snap onto an already-reserved half: new target becomes owner; previous owner is **demoted
  to ordinary** and joins the opposite half's reflow pool (or overflow/minimized if that half
  is also reserved).
- Moving an owner across sides: release origin, claim destination, demote any prior
  destination owner; ordinary windows reflow into the newly unreserved origin half.
- **Do not** default to MRU pair behavior. A topology snapshot may aid rollback/reflow
  continuity, but exact old geometry is not sacred when the available region changes.

## Approved implementation architecture (for a LATER session — not now)

- Snap + minimize/restore ownership handled in **`aurora-minimize`** as **one backend
  transaction**; Lua becomes **thin dispatch**; **no synchronous compositor self-IPC**.
- Transaction: validate → snapshot relevant state → promote/demote/reflow/minimize → verify
  → focus target → commit bookkeeping; **full rollback on failure**.
- **Preserve rail previews and exact-window rail selection.**

This document does not authorize implementation. Consult
`docs/reports/codex-consultation-record.md` before any change to this code.
