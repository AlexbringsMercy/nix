# STAGE 2 CORRECTION CLOSURE — FROZEN MANIFEST

> ## ⚠ OUTCOME: this manifest produced generation 32, which PHYSICALLY FAILED (2026-07-29)
>
> The build, the boot-only deployment and the reboot all completed, and the automated
> structural pass returned 41 PASS / 0 FAIL / 0 UNVERIFIED. The **physical** gate then failed
> on ten defects, including regressions against generation 31 in titlebar drag and tiled
> resize. No row in this manifest may be advanced past `activated`.
>
> A **new** frozen correction manifest must be produced by the next PM, after the mandated
> Codex reviews. See `docs/briefs/PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md` and
> `docs/briefs/PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md`.

**Published before the expensive build, per `docs/instructions/PM_OPERATING_RULES.md` §2 and
operator decision 20.** One build → one boot-only deployment → one reboot → one
gate. Nothing in this manifest is claimed as tested; every row states exactly
which of the seven states it has reached.

**Base:** generation 31 (`wirdp0v9…`), active and default. **Fallback:**
generation 26 (`92bdqiip…`). **Branch:** `main` (canonical; formerly
`codex/macbook-desktop`, normalized 2026-08-09).

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

Filled in from the source reviews before the build is staged. No item ships as
"reviewed" on the strength of the previous session's assertion.

### Item 2 — deterministic snap: **two defects found and fixed**

Core mechanism verified correct, and verified against the **live** compositor
rather than against the code's own comments: `hyprctl` reports
`reserved [60,10,10,10]`, `gaps_in 5`, `gaps_out 8`. Hand-computing
`snap_geometry` with those real numbers gives left `{x=68,y=48,w=808,h=1001}` and
right `{x=881,y=48,w=808,h=1001}` — widths exactly equal, right edge landing
exactly on the gapped usable boundary (`881+808 = 1689 = 1697-8`). No off-by-gap
or off-by-reserved error.

Ordering confirmed at the source: `hl.dispatch` is a synchronous `guardedPCall`
and the minimize resolves to `aurora-minimize`'s `doMinimize`, a direct
synchronous `setHidden` + `removeTarget` with no deferral. Every surplus minimize
therefore completes before placement, and placement is absolute rather than a
delta, so a transient reflow cannot survive it.

- **Defect 1, behavioural — fixed.** `reconcile_pair` treated *a surplus window
  closing while minimized* identically to *a surplus window being restored*,
  forcing pair dissolution. Closing an unrelated minimized window is not one of
  the dissolution triggers in `docs/plans/GRAND_PLAN.md` §6.2. Now prunes stale bookkeeping
  only.
- **Defect 2, dead code — fixed.** A positional `"exact"` marker copied from a
  donor was silently ignored by this engine's parser; replaced with an explicit
  `relative = false`.

### Item 5 — floating hover focus: **verified correct, unchanged**

`float_switch_override_focus = 0`, `follow_mouse = 2`, `focus_on_close = 2` all
intact. Mechanism confirmed against `InputManager.cpp`: the hover-triggered
`rawWindowFocus` is gated on `(floating && PFLOATBEHAVIOR == 2)` or
`(focus-state differs && PFLOATBEHAVIOR != 0)`; at `0` both terms are false, so
hover sets pointer focus only. Nothing elsewhere re-enables it.

### Item 6 — screenshot: **lifecycle correct; one hazard NOT structurally solved**

Correct and verified: focus restoration through a single choke point on both
cancel and completion; hover/selection never dispatches focus; the full-screen
path is a visible button with no Print key involved; window mode excludes
hidden/minimized clients and adds a `focusHistoryID` z-order tiebreak for
overlapping floating windows. The toolbar is **not** an independent layer-shell
surface — it is a plain `Item` inside the single `caelestia-area-picker`
`PanelWindow`, so focus-strand hazard (b) is structurally impossible.

**Hazard (a) — RESOLVED in commit `6805009`; the paragraph below records what was
found.** Region and window capture now compute geometry, tear down the layer-shell
window, and crop with `grim -g` from a separate process, matching
`docs/plans/GRAND_PLAN.md` §5.12. Proving it exposed a **live defect that was not
theoretical**: Hyprland keeps *rendering* an unmapped layer surface for the whole
`layersOut`/`fadeLayersOut` animation (~300 ms / ~280 ms). Measured on generation
31 with a throwaway opaque Overlay surface torn down the same way — grim at 5 ms
still captured ~100 % of it, at 153 ms ~76 %, clean only at ~307 ms. **The
existing 50 ms `toolbarFullSettle` timer was therefore already broken in
practice: the toolbar's own Full screen button was almost certainly baking the
toolbar into captures at high opacity.** A plain unmap-then-grim would have
inherited the bug. The replacement waits on `hyprctl layers` confirming the
namespace is gone — a compositor-confirmed predicate, not a delay — inside the
same `sh -c` as grim so nothing can reorder them, bounded at 40 polls (~2.3 s) so
a namespace rename degrades rather than hangs. `hiddenForCapture` was removed
because its replacement is live in the same change (decision 21).

The original finding, for the record:


region/window mode the code hides overlay, border and toolbar and activates
`screencopy` in the same tick with no settle. The Qt-scenegraph argument in the
existing comment is real but addresses the wrong layer: `screencopy`'s *content*
is a compositor-level capture of the whole output, and the picker sits on
`WlrLayer.Overlay`. Whether the toolbar is in that frame is a race — the exact
hide-then-capture pattern operator decision 27 rules unacceptable, and a
divergence from `docs/plans/GRAND_PLAN.md` §5.12, which specifies capture **via grim after
geometry** precisely so contamination is structurally impossible. Being reworked
to geometry → unmap → grim before this closure ships.

### Item 7 — boot readiness: **verified correct, and an open uncertainty resolved**

The previous session left unverified whether `wantedBy = [ "sysinit.target" ]`
on `systemd-time-wait-sync.service` would delay boot. The shipped unit file was
read directly from the store: it declares `Before=time-sync.target
shutdown.target` and `DefaultDependencies=no` — **not** `Before=sysinit.target`.
So it bounds `time-sync.target` only and does **not** delay `sysinit.target`,
`basic.target`, Hyprland start, or local restore. The separation the operator
required is real at the systemd level, not merely in the resume script.

`aurora-resume-agent` confirmed: kitty windows open immediately and
unconditionally; only the inner `claude --continue` and Chrome launches are gated;
the wait is bounded (60s default) with a visible waiting message, a visible
timeout message, and `exit 0` regardless; both time **and** network are required;
no application is special-cased — "ChatGPT" appears only in prose.

### Item 3/4 — rail: **verified correct, unchanged**

Recorded because it corrects the previous session's framing: the preview failure
was **global**, not grouped-only. `popouts.currentToplevels` was assigned to an
undeclared property, throwing on every call before `hasCurrent = true` — which is
why single-window Thunar previews failed while its restore worked. The chain is
now declared end to end, and the hover path has no `windowCount > 1` branch, so
one fix repairs both paths.

### Rail-owner handoff — ephemeral surface identifiers

Required by the cross-session handoff the PM owns:

- Layer-shell namespace **`caelestia-area-picker`** — covers picker, overlay,
  border and toolbar; they are one surface.
- QML `objectName` **`areaPickerToolbar`** — introspection only, no independent
  window identity.
- `services/Screenshotter.qml` — headless singleton, no surface at all.

**No rail-side filter rule is actually required.** `AppRail`'s data source is
`Hypr.toplevels` (`hyprctl clients`), and layer-shell surfaces structurally never
appear there. The gen-31 "dead screenshot icon in the rail" had a different root
cause — a pinned-spec icon-resolution issue, already fixed in `AppRail.qml`. The
identifiers above are for debugging, not filtering.

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
`docs/plans/GRAND_PLAN.md` §5.12 names it for the recorder backend, but the outstanding gate
row asks to *verify* VA-API/iHD, and Intel Gen9+ auto-selects iHD already.
Forcing a driver env var immediately before a physical gate risks introducing a
regression the gate would then have to untangle. `vainfo` now ships (item 9); if
it reports anything other than iHD encode, the env var is set as a follow-up with
evidence rather than pre-emptively.

---

## 6. Removals and live replacements

**No surface is removed in this closure.** Per decision 21 and
`docs/instructions/PM_OPERATING_RULES.md` §2, nothing is deleted before its replacement is live in
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

---

## 8. Build result — both evaluation paths built clean

**Attempt 1 failed on disk, not on code.** `/` was at 98%; Hyprland died at 5% on
`ar: unable to copy file 'libhyprland_lib.a'; reason: No space left on device`.
Cause: three 11 GB worktree copies (33 GB) created by
`--override-input macbook-config path:/home/alex/nix`, because the `path:` fetcher
ignores `.gitignore` and copies `repos/` on every eval. All three verified
unreferenced (0 referrers, 0 GC roots, absent from the gen 26 and gen 31 closures)
and deleted: **111 GB → 79 GB used, 35 GB free**. No generation was collected —
`nix-collect-garbage -d` would have destroyed the gen-26 fallback.

**Attempt 2 built clean** via the wrapper's committed `git+file:` input, repinned
to `6805009`:

| Path | Result | Output |
|---|---|---|
| `homeConfigurations.alex.activationPackage` | `HM_EXIT=0` | `1zvqmc65…-home-manager-generation` |
| `nixosConfigurations.macbook…toplevel` (firmware-backed) | `SYS_EXIT=0` | **`i55p3311…-nixos-system-macbook`** |

### Compositor and plugin identity — ABI consistent

| Component | Generation 31 | This closure |
|---|---|---|
| Hyprland (patched) | `wrz9r718…` — 2 patches | **`wf1971v5…` — 3 patches** |
| hyprbars | `8s56v8nb…` | **`lm09v2cm…`** |
| aurora-minimize | `yj206xdb…` | **`jnhwa9xd…`** |

Both plugins rebuilt **against the new compositor in the same closure**, so there
is no ABI drift. `rv2dda5j…` (unpatched nixpkgs Hyprland, a transitive dependency)
is present in both and unchanged.

### Protected-state closure proof — verified in the built output

| Item | Method | Result |
|---|---|---|
| T2 Broadcom firmware | `nix-store -qR` | present |
| TV firewall rule | read the actual script: `--mac-source 40:2f:86:81:26:3e` | present; `firewall-start` path is **byte-identical to generation 31** |
| Xbox BT tuning | `etc/bluetooth/main.conf` | `MinConnectionInterval=7`, `MaxConnectionInterval=9` |
| VA-API / iHD | `nix-store -qR` | `intel-media-driver` present |
| `vainfo` | `nix-store -qR` | `libva-utils` now present — gate row 36 becomes testable |
| DWT hwdb entry | binary search of `hwdb.bin` | `v05acp0280` present |
| grim | `nix-store -qR` | present — all three capture paths depend on it |

Two of these initially appeared missing and were **not** reported as such:
`firewall-start` is a package directory rather than a file, and `hwdb.bin` is a
binary that `strings` does not usefully index. Both were re-checked with a correct
method before any claim was made.

### Claim classification for this closure

- **closure-verified:** every row in the two tables above; both build exits; the
  compositor/plugin identities; HM evaluation of the PATH change.
- **source-reviewed:** all nine correction items, at the depth recorded in §3–§4.
- **physically verified:** *nothing yet.* That is what the gate is for.

### Note on the pin

The closure is built from commit `6805009`. Documentation commits after it
(`21b22c1` and later) do not enter the system closure and deliberately did **not**
trigger a rebuild — reusing a good closure rather than rebuilding for bookkeeping.

---

## 9. Defect classification — corrected, and a correction to my own earlier wording

**Toolbar / layer capture contamination — PROVEN.** Measured directly on
generation 31: a throwaway opaque `WlrLayer.Overlay` surface, torn down exactly as
the picker is, was still ~100% present in a grim frame 5 ms after destruction,
~76% at 153 ms, and clean only at ~307 ms. That is a measurement, not an
inference.

**It is NOT established as the same root cause as the older tinted-overlay /
slurp "pink film" defect.** Earlier wording in this session called it "the
pink-film defect class"; that conflation is withdrawn. What the two share is only
the *symptom shape* — an unintended surface reaching the output. The old defect
was proven arithmetically as **alpha blending of a tinted selection overlay**
(alpha `0x55` = ⅓ → predicted floor (80.33, 60.33, 73.00) vs measured (80, 60,
73)). The new one is a **compositor fade-out timing window on an unmapped
layer-shell surface**. No evidence collected here shows a shared mechanism, and
none should be claimed until a capture is pixel-inspected at the gate.

**The older failed build's disk-space cause — STRONG INFERENCE, not confirmed
history.** *This* session's build failure on ENOSPC is confirmed (the log records
`ar: ... No space left on device` with `/` at 98%). The 2026-07-29 **morning**
session's build leaving no generation, boot entry or store output is *consistent*
with the same silent ENOSPC, and two of the three stale 11 GB copies provably
predate the 2026-07-28 archive commit — but **that session's build log was not
preserved**, so the causal link is inference. It is recorded as such in
`docs/reports/EXECUTION_LOG.md` and must not be restated as established fact.

---

## 10. Final closure — attempt 3, after the fail-closed guard correction

The pre-stage clarification found the capture guard fell through on timeout and
would hand back a contaminated screenshot with no visible error. That was
corrected and rebuilt once, per the operator's instruction. Compositor and plugin
outputs were **reused from cache** — only QML changed, so no recompile.

| Path | Result | Output |
|---|---|---|
| HM activation | `HM_EXIT=0` | `r9w8525d…-home-manager-generation` |
| System toplevel | `SYS_EXIT=0` | **`62aim1mw…-nixos-system-macbook`** — `nix path-info` VALID |

**Pinned commit:** `5d37e1c` (contains the guard fix). The only later commit,
`521e76d`, touches `docs/` and an unreferenced script — it does not enter the
closure, and no rebuild was triggered for bookkeeping.

**Guard verified in the built artifact**, not merely in source
(`qyfv7y9i…-caelestia-shell-1.0.0`):

```
{ n=0; while [ "$n" -lt 40 ] && hyprctl layers | grep -q "namespace: caelestia-area-picker";
  do n=$((n+1)); sleep 0.02; done;
  if hyprctl layers | grep -q "namespace: caelestia-area-picker"; then exit 92; fi; } && grim …
```

Three branches tested before building: namespace never disappears → exit 92, grim
never runs; already absent → exit 0, grim runs; disappears after 5 polls → exit 0,
grim runs. The first attempt at this fix used `grep -q … && exit 92`, which left
the block's status at 1 on the common path and would have broken **every** capture
— caught by testing rather than by reasoning.

**Identity and protected state, re-verified on the final closure:**

| Check | Result |
|---|---|
| Hyprland / hyprbars / aurora-minimize | `wf1971v5…` / `lm09v2cm…` / `jnhwa9xd…` — unchanged from attempt 2, ABI consistent |
| T2 firmware · iHD · libva-utils · grim | all present |
| TV firewall `firewall-start` | **byte-identical to generation 31** |
| `systemd-time-wait-sync` wiring | present in closure |
| Closure size / free disk | 7.9 GB / **35 GB free** |

**Verdict: READY TO STAGE.** Nothing in this closure is physically verified — that
is what the runtime gate is for (`docs/reports/stage2-runtime-gate.md`).
