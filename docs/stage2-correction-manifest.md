# STAGE 2 CORRECTION CLOSURE — FROZEN MANIFEST

**Published before the expensive build, per `PM_OPERATING_RULES.md` §2 and
operator decision 20.** One build → one boot-only deployment → one reboot → one
gate. Nothing in this manifest is claimed as tested; every row states exactly
which of the seven states it has reached.

**Base:** generation 31 (`wirdp0v9…`), active and default. **Fallback:**
generation 26 (`92bdqiip…`). **Branch:** `codex/macbook-desktop`.

---

## 1. Why this build is expensive, and why it is unavoidable

Generation 31 carries `wrz9r718…-hyprland-0.55.4`, built from **two** patches.
`flake.nix` now declares **three** — `hyprland-dwindle-resize-workarea.patch`
landed at 07:16 (`fc78ebe`), after generation 31 was built at 06:06.

The patch list genuinely changed, so the rule "reuse the compositor output when
the source patch set is unchanged" does not apply. Hyprland rebuilds, and
**hyprbars rebuilds against it in the same closure** — the plugin helper consumes
top-level `hyprland`, so they cannot be deployed separately without ABI drift.

**No compositor recompile is being triggered by unrelated shell or configuration
changes.** The trigger is the patch list itself, checked in `flake.nix`, not the
calendar.

---

## 2. Compositor patch set — final, verified before compiling

| Patch | Target | Status |
|---|---|---|
| `hyprland-drag-anchor.patch` | `src/layout/supplementary/DragController.cpp` | carried, unchanged |
| `hyprland-deco-border-grab.patch` | `src/managers/input/InputManager.cpp` | carried, unchanged |
| `hyprland-dwindle-resize-workarea.patch` | `src/layout/algorithm/tiled/dwindle/DwindleAlgorithm.cpp` | **new this closure** |

**Pre-compile verification performed this session, not inherited:**

- All three apply against the pinned source `cr4vq0w7…-source` with **zero fuzz
  and zero offset** (`patch -p1 --dry-run`).
- The dwindle patch deletes the `PMONITOR` binding. Verified by reading the
  actual source that `PMONITOR` is used **only** on the line the patch replaces
  within `resizeTarget` — no dangling reference, no unused-variable break. The
  other `PMONITOR` occurrences in that file belong to different functions.

**Root cause it fixes:** dwindle measured its edge-stick flags against
`PMONITOR->logicalBoxMinusReserved()`, the *un-inset* monitor box, while the node
tree actually tiles `space()->workArea()` — which is that box inset by
`general:gaps_out`. Every `STICKS()` comparison therefore missed by exactly
`gaps_out`, so with any `gaps_out >= 2` all four `DISPLAY*` flags were permanently
false. That silently disabled the "this edge is a work-area edge, use the opposite
border" fallbacks, and a corner grab whose side lay on the work-area boundary
contributed **no axis at all** — the one-directional tiled corner resize Alex
reported.

---

## 3. Items in this closure

| # | Item | Written | PM reviewed | Included |
|---|---|---|---|---|
| 1 | Tiled corner resize — dwindle work-area patch | Y | Y — patch read, applies clean, compile-safe | Y |
| 2 | Deterministic snap — reserved probe + pre-placement reconciliation | Y | see §4 | Y |
| 3 | Rail previews / grouped apps — wrapper aliases, single-window gate removed | Y | **Y — verified correct** | Y |
| 4 | Rail scroll scoping — brightness-to-zero fix | Y | **Y — verified correct** | Y |
| 5 | Floating hover focus — `float_switch_override_focus = 0` | Y | see §4 | Y |
| 6 | Screenshot toolbar, lifecycle and focus restoration | Y | see §4 | Y |
| 7 | Boot readiness / time synchronisation | Y | see §4 | Y |
| 8 | **Agent PATH invariant** (decision 24) | Y | Y — HM eval passes | Y |
| 9 | `libva-utils` for the untestable VA-API gate row | Y | Y | Y |

**Item 3 and 4 review finding, recorded because it corrects the previous
session's framing:** the rail failure was **global**, not grouped-only. The
property assignment `popouts.currentToplevels = item.windows` threw on a
non-existent property on *every* call, aborting before `hasCurrent = true`. That
is why single-window Thunar hover previews also failed while Thunar's *restore*
worked. The fix removes the exception unconditionally, and the hover path has no
`windowCount > 1` branch — so single and grouped previews are repaired by the same
change. Verified by tracing the full chain (`AppRail` → `Bar` → `Wrapper` →
`PopoutState` → `Content` → `RailGroupPreview`), not by trusting the claim.

---

## 4. Review status of the remaining items

Filled in from the concurrent source reviews before the build is staged. No item
ships as "reviewed" on the strength of the previous session's assertion.

*(Pending: window-model review — items 2 and 5; screenshot/boot review — items 6
and 7.)*

---

## 5. Protected state — closure proof

Verified present in the source that produces this closure:

| Protected item | Where | Status |
|---|---|---|
| T2 Broadcom firmware | `modules/nixos/t2-firmware.nix` via the machine-local wrapper's `firmwareSource` | present, unchanged |
| TV firewall rule (LG TV MAC-accept) | `modules/nixos/media-center.nix` — `firewall.extraCommands` / `extraStopCommands` | present, unchanged |
| Xbox controller BT tuning | `modules/nixos/desktop.nix` — `MinConnectionInterval = 7`, `MaxConnectionInterval = 9`, `ConnectionLatency = 0` | present, unchanged |
| VA-API / iHD | `modules/nixos/desktop.nix` — `hardware.graphics.extraPackages = [ intel-media-driver ]` | present, unchanged |
| Bluetooth pairings, keyring, Jellyfin ServerId | `/var/lib/bluetooth`, `~/.local/share/keyrings`, mediacenter data | state, not config — untouched by rebuild |
| Claude Code / Codex binaries, config, sessions | `~/.local/bin`, `~/.local/share/claude/versions/`, `~/.codex/`, `~/.claude*` | **not owned by Nix**; only PATH *order* is declared |

**`LIBVA_DRIVER_NAME=iHD` is deliberately NOT being set in this closure.**
`GRAND_PLAN.md` §5.12 names it for the recorder backend, but the outstanding gate
row asks to *verify* VA-API/iHD, and Intel Gen9+ auto-selects iHD already.
Forcing a driver env var immediately before a physical gate risks introducing a
regression the gate would then have to untangle. `vainfo` now ships (item 9); if
it reports anything other than iHD encode, the env var is set as a follow-up with
evidence rather than pre-emptively.

---

## 6. Removals and live replacements

**No surface is removed in this closure.** Per decision 21 and
`PM_OPERATING_RULES.md` §2, nothing is deleted before its replacement is live in
the same closure.

Specifically **not** removed, and why:

- The `~/.npm-global` `@anthropic-ai` and `@openai` package trees stay on disk.
  Decision 24 permits neutralizing duplicates only *after* the canonical path is
  proven in current shell, fresh terminal and fresh graphical login. The stale
  `claude` shim in `~/.npm-global/bin/` is already gone; the trees are inert but
  are not being deleted on the same reboot that proves the fix.
- `~/.profile`'s Codex-installer PATH line and `fish_user_paths` are left in place.
  They become redundant once `sessionPath` declares the order, but removing them in
  the same step would make a failed activation harder to diagnose.
- The Stage 2 cleanup sweep (dead `waybar`/`rofi`/`awww`/`waypaper` entries,
  `rofi-toggle`) is **not** in this batch. Work order §3 makes it explicitly
  subordinate to the real fixes.

---

## 7. Claim classification

Every claim in the reboot request is labelled as exactly one of:

- **source-reviewed** — read in the tree this session; says nothing about runtime.
- **closure-verified** — proven by evaluation or by the built store output.
- **physically verified** — Alex observed it on the machine.

Nothing in this closure is physically verified yet. That is the point of the gate.
