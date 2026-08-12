# PM HANDOFF — GENERATION 32 PHYSICAL HARD FAIL

**Written 2026-07-29 22:10 CDT, at operator-directed termination of the PM session.**
This session is no longer trusted to continue diagnosis or coordination. Nothing in this
document is an accepted root cause. Verify live ground truth; do not inherit this blindly.

> **UPDATE 2026-08-09 — this is a dated 2026-07-29 record; read the current authority docs.**
> Since this handoff: the blind diagnostic review was **completed** (two independent blind
> Pass-1 reviews converged; accepted findings — defect record **D1–D9** (D1–D7/D9 diagnosed,
> **D8 unresolved**) — in `docs/reports/gen32-recovery-diagnosis.md`;
> an adversarial Pass-2 artifact exists but is not asserted as an accepted gate sign-off;
> so the "no accepted Codex review exists" statements below are **historical**, not current).
> The repository was normalized to branch **`main`** (the `codex/macbook-desktop` line was
> retired). Current machine/repository state: `docs/reports/CURRENT_STATE_AUDIT_2026-08-09.md`.
> The machine is still on generation 32; Stage 2 and all defects remain **OPEN**.

---

## 1. Ground truth

| Item | Value |
|---|---|
| Booted / current / profile generation | **32** — all three agree |
| System store path | `/nix/store/62aim1mw2c26siwlymv9r5xa0qqa5ryw-nixos-system-macbook-26.11.20260616.567a49d` |
| Gen 31 (comparison only) | `/nix/store/wirdp0v9rgaylk2vywhiqpd2bgxl49gx-nixos-system-macbook-26.11.20260616.567a49d` |
| Home Manager generation | `/nix/store/kbmsidhzdwhlrrqyq1dz14hb1mq8r66l-home-manager-generation` |
| Branch | `codex/macbook-desktop` |
| HEAD at session start of this handoff | `7d0d66034f17e357ed5643c573c9e348ebecc367` |
| Tree state | **clean** — `git status --short` empty; **no uncommitted implementation changes** |
| Free disk | 35 G available of 120 G (70 % used) on `/` and `/nix` |
| Compositor | Hyprland 0.55.4, branch `v0.55.4-b`, commit `a0136d8c…`, clean |
| Compositor store path (gen 32) | `/nix/store/wf1971v55jf4im6zb6b5f8gn6is9ms0j-hyprland-0.55.4` |
| Compositor store path (gen 31) | `/nix/store/wrz9r718svay8k5dhghzl4sf4w5ddfjb-hyprland-0.55.4` |
| Plugins loaded | `aurora-minimize` 0.1 (handle `596dd01fc760`), `hyprbars` 1.0 (handle `596dcf7b1960`) |
| Shell | `quickshell-wrapped-0.3.0` → `caelestia-shell-1.0.0`, PID 1857 |
| Diagnostic processes after cleanup | **none** — 0 Codex processes, 0 btmon processes |
| `bluetoothd` debug mode | **STILL ENABLED** — see §5 |
| Root channel | a kitty window titled `AURORA ROOT CHANNEL` may still be open; closing it revokes root |

### Compositor patch delta, gen 31 → gen 32 (proven via `nix derivation show`)

Both derivations share `src` `cr4vq0w7dn9i5m19847mrl99rm24vsba-source`, the same `stdenv`,
the same `buildInputs`/`nativeBuildInputs`, the same `cmakeFlags`, `postPatch`, `postInstall`.

```
gen 31 patches (ordered):
  qsgh1yww4490fayphsv32hi3jm12bdq7-hyprland-drag-anchor.patch
  6awy9ljdadnyj39bisniid9d2v6viznm-hyprland-deco-border-grab.patch

gen 32 patches (ordered):
  qsgh1yww4490fayphsv32hi3jm12bdq7-hyprland-drag-anchor.patch        <- byte-identical store path
  6awy9ljdadnyj39bisniid9d2v6viznm-hyprland-deco-border-grab.patch   <- byte-identical store path
  163p7lgk8ym72afakkbi9gml851gfcvv-hyprland-dwindle-resize-workarea.patch   <- NEW, appended last
```

The **only** compositor source delta is `hyprland-dwindle-resize-workarea.patch`. `hyprbars`
and `aurora-minimize` were rebuilt solely because the compositor derivation they link against
changed. **The next PM must not treat "the new patch is small" as evidence it is isolated.**

---

## 2. Generation 32 is physically FAILED

Automated structural gate: 41 PASS / 0 FAIL / 0 UNVERIFIED, stable over three runs.
**That gate did not detect any of the failures below.** Structural pass ≠ physical pass.

Alex's observed failures, recorded without reinterpretation:

1. `Super+Left` / `Super+Right` **freezes the entire display for roughly five seconds**.
2. Snap then produces **incorrect floating geometry under the left vertical rail**.
3. With exactly Chrome and one terminal, snapping Chrome caused the **terminal to glitch and
   minimize incorrectly**. With exactly two visible windows the other must become/remain the
   opposite half; only surplus windows beyond the completed pair may minimize.
4. Snap **corrupted keyboard input/focus** badly enough that Chrome had to be closed and reopened.
5. **Rail previews and exact-window selection now work and must be preserved.**
6. **Restore does not return windows to their prior state/position** — cannot be isolated
   cleanly while snap is corrupt.
7. **Legacy Media Center remains falsely active on the rail** when no Media Center window is open.
8. **Titlebar drag-anchor jump regressed** — the window jumps upward and the pointer no longer
   remains at the original titlebar grab point.
9. **Ordinary tiled resize is completely nonfunctional** — horizontally, vertically and diagonally.
10. **Scroll speed over a hovered but keyboard-unfocused window is dramatically slower** than
    over the focused window. Focused-window scroll speed is already correct and
    **must not be globally increased**.

### Status statements

- **Stage 2 remains OPEN.**
- The remaining operator gate (groups A–H) was **stopped** and must not be resumed until the
  correction closure lands.
- **No Stage 3 deployment is permitted.**
- **Gen 31 is comparison evidence only, not an accepted complete fallback.** Its tiled resize
  was incomplete (horizontal only) and its own gate was 28 PASS / 7 FAIL / 4 UNVERIFIED.
- **Alex should avoid using snap on gen 32 until corrected.**
- **No root cause from this PM session is accepted.**
- The **synchronous compositor self-IPC / deadlock explanation is a high-priority hypothesis,
  not a proven fact.** The next PM must independently inspect it through the mandated Codex
  adversarial process before any implementation.

---

## 3. Failure matrix

Everything in the "Unproven" column is this session's inference and carries **no authority**.

### F1 — Snap freezes the display ~5 s

- **Physical evidence:** operator, reproducible; ~5 s full-display freeze on `Super+Left/Right`.
- **Known-good comparison:** none — snap has never been observed working correctly.
- **Proven facts:** `modules/home/hyprland/hyprland/keybinds.lua` contains
  `monitor_reserved_via_hyprctl()` which calls `io.popen("hyprctl monitors -j 2>/dev/null")`
  and blocks on `handle:read("*a")`. `luaL_openlibs()` is called at
  `src/config/lua/ConfigManager.cpp:313`, so `io.popen` **is** available in the embedded VM.
  `CLuaMonitor`'s `__index` (`src/config/lua/objects/LuaMonitor.cpp`) resolves only
  `width/height/refresh_rate/x/y/active_workspace/active_special_workspace/position/size/
  scale/transform/dpms_status/vrr_active/is_mirror/mirrors/focused` — **there is no `reserved`
  key**, so `monitor_reserved()`'s fast path can never hit and the shell-out runs on **every**
  keypress. `hyprctl/src/main.cpp:187` sets `SO_RCVTIMEO` to **exactly 5 s**.
- **Unproven hypothesis:** that the Lua callback runs on the compositor's own event-loop
  thread, so the `hyprctl` child cannot be serviced and blocks for the full 5 s. **Not
  verified by instrumentation.** No timestamped proof of the freeze was captured.
- **Source areas:** `modules/home/hyprland/hyprland/keybinds.lua` lines ~205-245 and `half_snap`
  ~583-620; Hyprland Lua dispatch/threading model.
- **Preserve:** nothing in this path is known-good.
- **Runtime test owed:** timestamped proof of the freeze correlated with an HCI-free
  compositor stall; then proof the corrected path never blocks.

### F2 — Snap geometry lands under the left rail

- **Physical evidence:** operator; also a **residual window still on screen** at the time of
  diagnosis: `class=kitty ws=2 floating at=[856,38] size=[843,1021]`.
- **Known-good comparison:** correctly tiled windows on the same monitor sit at `at=[70,50]`.
- **Proven facts:** live `hyprctl monitors -j` reports `reserved [60,10,10,10]`, scale 1.50,
  2560×1600 (logical 1707×1067); `gaps_out = 8`, `gaps_in = 5`. The rail has **no layer-shell
  surface of its own** — the reserved area comes from four 1×1 `caelestia-border-exclusion`
  surfaces. With `reserved = {0,0,0,0}` the file's own arithmetic yields left `x=8, w=843,
  y=38, h=1021` and right `x=856, w=843` — the right value **matches the residual window
  exactly**. With the true reserved values it would yield left `x=68, w=808, y=48, h=1001`.
- **Unproven:** that the zeroing is caused by the `hyprctl` fallback rather than another path.
- **Source areas:** `snap_geometry()` ~254-278; `monitor_reserved()` ~240-245.
- **Runtime test owed:** snapped halves land at the exact usable half, clear of the rail.

### F3 — Two-window pairing minimizes the wrong window

- **Physical evidence:** operator; Chrome + one terminal, snapping Chrome minimized the terminal.
- **Proven facts:** in `half_snap`, `keep` is seeded **only** from `s[other_side]` — this file's
  own prior bookkeeping. On the first snap of a workspace that is `nil`, so every other visible
  window is classified surplus and minimized.
- **Unproven:** nothing further; the code path is plain, but no runtime trace was taken.
- **Required behaviour:** with exactly two visible windows, snapping one left keeps/places the
  other right; surplus minimization runs **only after both pair members are established**.
- **Source areas:** `half_snap` ~583-620, `reconcile_pair` ~464-513.
- **Runtime test owed:** the B group of `docs/reports/stage2-runtime-gate.md`.

### F4 — Snap corrupts keyboard focus

- **Physical evidence:** operator; Chrome would not accept typing and had to be closed/reopened.
- **Proven facts:** the snap action list dispatches `float(on) → resize → move` and **never**
  focuses the target; there is no transaction abort/restore path.
- **Unproven:** the precise mechanism (Wayland seat focus vs Hyprland active-window bookkeeping).
- **Required behaviour:** a snap transaction must end with keyboard focus on the snapped target;
  failure or timeout must abort and restore the complete pre-snap state.
- **Runtime test owed:** focus lands on the snapped window; a forced failure restores cleanly.

### F5 — Titlebar drag-anchor regression

- **Physical evidence:** operator; window jumps upward, titlebar mostly off-screen, pointer ends
  near the Chrome tab strip. **Passed on gen 31.**
- **Proven facts:** `hyprland-drag-anchor.patch` is a **byte-identical store path** in gen 31 and
  gen 32 and is applied first in both. It therefore did not itself change.
- **Unproven:** why it regressed. Candidates: interaction with the new work-area patch;
  the `hyprbars` rebuild; or a consequence of already-corrupt floating state from F1–F4.
- **Source areas:** `src/layout/supplementary/DragController.cpp::updateDragWindow`;
  `changeFloatingMode`; decoration reserved extents.
- **Runtime test owed:** titlebar drag keeps the window under the cursor at the grab point.

### F6 — Tiled resize completely nonfunctional

- **Physical evidence:** operator; no horizontal, vertical or diagonal resize.
  **Gen 31 had horizontal resize.**
- **Proven facts (source, not runtime):** the gen-32-only patch replaces
  `PMONITOR->logicalBoxMinusReserved()` with `m_parent->space()->workArea()` in
  `DwindleAlgorithm::resizeTarget`. `CSpace::recheckWorkArea()` (`src/layout/space/Space.cpp:77`)
  sets `m_workArea = logicalBoxMinusReserved()` **inset by `general:gaps_out`**.
  `DwindleAlgorithm.cpp:588` sets `TOPNODE->box = space()->workArea()` and line 53 does
  `pTarget->setPositionGlobal(box)`, so the node box **is** the target's logical box.
  `STICKS(a,b)` is `abs(a-b) < 2`. In `resizeTarget`, the first use of the flags is
  `if (DISPLAYLEFT && DISPLAYRIGHT) allowedMovement.x = 0;` and
  `if (DISPLAYBOTTOM && DISPLAYTOP) allowedMovement.y = 0;`.
- **Unproven hypothesis:** that making the flags fire now **zeroes** movement for any window
  spanning the work area on both sides of an axis, inverting the previous failure. **This was
  never runtime-verified**, and the window layout at Alex's test time is unknown, so it may not
  account for *all* resize being dead.
- **Source areas:** `DwindleAlgorithm.cpp` ~305-340 and the smart-resizing block below it;
  `WindowTarget.cpp::updatePos`; `Space.cpp::recheckWorkArea`.
- **Runtime test owed:** group A of `docs/reports/stage2-runtime-gate.md`, three and four windows.

### F7 — Media Center falsely active on the rail

- **Physical evidence:** operator.
- **Proven facts:** `AppRail.qml` pins `classRegex: /^MediaCenter$/i` and derives a pinned
  entry's windows from `wsToplevels`. At diagnosis time **no toplevel with class `MediaCenter`
  existed**, while a background service `node ~/.local/share/mediacenter/server.js` (pid 5627)
  **was** running. `wsToplevels` does not filter `hidden`.
- **Unproven:** which of pinned-entry rendering, a stale toplevel, a hidden/minimized toplevel,
  or an app-id alias produces the "active" state. Not isolated.
- **Required behaviour:** "Active" must derive from a real current-workspace toplevel, never a
  pinned entry or a background service.
- **Source areas:** `modules/home/aurora-shell/modules/bar/components/AppRail.qml` ~70-165, ~430.

### F8 — Hovered-but-unfocused scroll rate is far slower

- **Physical evidence:** operator, new this session. Focused-window scroll rate is correct.
- **Proven facts:** none — **no investigation was performed.** This defect arrived immediately
  before session termination.
- **Constraint:** do **not** compensate with a global `scroll_factor` increase; that would
  break the already-correct focused path and mask two distinct event paths.
- **Required isolation (operator's own specification):** two tiled Kitty windows first, then two
  Chrome windows, then tiled vs floating; confirm raw libinput deltas are identical for both
  cases; trace what Hyprland delivers to the focused surface vs the pointer-hovered
  keyboard-unfocused surface. Inspect `follow_mouse=2` routing, inactive-window axis handling,
  whether only one path applies `scroll_factor`, discrete-wheel vs continuous-axis conversion,
  fractional-axis accumulation/truncation, seat pointer focus vs keyboard focus, any shell/plugin/
  Lua scroll handler, and floating-window boundary behaviour.
- **This must be included in the compositor/input Codex review.**

---

## 4. Completed work that must NOT be regressed

- Generation 32 **booted** successfully.
- Hyprland and **both plugins loaded ABI-consistently** (verified live via `hyprctl plugin list`).
- **Rail single and grouped previews, and exact-window selection, work** — operator-confirmed.
  This is the one window-model item that improved this cycle. **Preserve it.**
- `claude` resolves to `~/.local/bin/claude`, version **2.1.220**.
- `codex` resolves to its canonical `~/.local/bin` standalone release, version **0.145.0**.
- Correct PATH ordering exists across the verified contexts.
- **DWT enabled.**
- **VA-API / iHD H.264 encoding available.**
- Protected state survived: Xbox LE interval tuning (7/9), TV firewall rule, Bluetooth pairing
  records, and the other protected items.
- Boot time / network readiness did **not** reproduce the gen-31 clock/certificate failure.
- The **screenshot timeout guard was corrected before gen 32** (fail-closed, exit code 92).
- **Persistent NixOS default** was selected by holding Control in Apple Startup Manager, but
  **requires a later no-key cold boot for final verification** — recording it as passed now
  would be a false pass.
- **Wallpaper-picker discoverability** remains an operator-approved non-blocking deferral to
  Stage 4 (decision 28). Not fixed.
- **Kitty reopen-last-closed-tab** means a Kitty **terminal tab** (with working directory), not
  editor files, and belongs to **Stage 8**. Never a Stage 2 blocker.

---

## 5. Bluetooth / Xbox controller

**Do not label this a gen 31 → gen 32 regression.** The controller had not been physically
connection-tested for several generations; the last-known-working generation is **unknown**.

### Classification

| Claim | Status |
|---|---|
| Current physical failure (flashing until power-off timeout) | **proven** |
| A correct immediate connection is achievable | **proven** — live, instrumented |
| Reliable repeatability | **unproven** |
| Absolute incompatibility / hardware limitation | **disproven** |
| gen 31 → 32 regression | **unproven** |
| Root cause | **unknown** |

One successful attempt does **not** close the issue.

### Recorded physical state at termination

- The controller later connected **immediately through the ordinary graphical action**.
- The connection remained stable for **at least 13 minutes** (1148 s at last check).
- BlueZ reported **`ServicesResolved = true`**.
- Battery reported **90 %**.
- **No BlueZ or kernel errors** were observed during that successful interval.
- **LED steadiness and input-device functionality were still awaiting Alex's confirmation**
  when the session was terminated.

### Preserved evidence — `~/.local/state/aurora-build/xbox-known-good/`

Binary captures are deliberately **not** in Git.

| File | Size | SHA-256 |
|---|---|---|
| `known-good-connect.btsnoop` | 283 297 | `14a97bb98d3aa51b4aca0ebb90efb2fff04ddcdd38b8ac3fc1b2db87091e90f2` |
| `session-full.btsnoop` | 7 483 020 | `0262d9bac015bd88f18feeb55cf90358b2d3b5a6953783873e1ab333dea15d49` |
| `known-good-bluetoothd.log` | 31 799 | `eda9173ce8e243ddae43001274784bf3dffb90ca93504456d540d81fd70c6f92` |
| `known-good-kernel.log` | 1 236 | `2ebb682cc84e44de40e2e68ff1d4a3313f16970e5e9c9937b0a0371ba33ff33c` |
| `known-good-215309.txt` | 1 886 | `642c144993767f81415da3f164766aacea4a0e0fca98c68ba12c68ebfc533b14` |
| `DIAGNOSIS.md` | 5 159 | `36454348e65a522ca8eed5cdfe11bf21490faf0c9970b3f158e99f98cf2b3109` |

Also `CHECKSUMS.txt` and `codex-attempts-INCOMPLETE/` in the same directory.
Gen-32 compositor evidence: `~/.local/state/aurora-build/gen32-failure/`
(`hyprland-gen32.log` `d274768b…`, `journal-system-b0.txt` `01c064b7…`,
`journal-user-b0.txt` `38005c47…`, plus `CHECKSUMS.txt`).

### `bluetoothd` debug state — ACTION REQUIRED BY NEXT PM

Debug logging was enabled at runtime with **`kill -USR2 1050`**. It was **not** a config or
override change, so **there is nothing to restore in configuration** — `/etc/bluetooth/main.conf`
is untouched and a normal service start will come up at default verbosity.

**The currently running daemon remains in debug mode** and will stay so until a controlled
restart or the next reboot. It was deliberately left enabled so that a natural failure still
produces daemon-level evidence. To restore normal logging live, without restarting:
`sudo kill -USR1 1050`. To re-arm HCI capture: `sudo btmon -w <path>`.

Bluetooth was **not** restarted. The controller was **not** disconnected, forgotten or re-paired.

### Comparison the next PM must complete

The failed and successful traces have **not** been compared to the operator's required depth.
The one concrete divergence observed: the two late-success attempts bound `hid-generic` first
and rebound to `microsoft` 13–25 ms later, creating two input devices (`input13`, `input14`,
uhid `…0B13.0009`); the known-good bound `microsoft` **directly**, one input device (`input15`,
uhid `…0B13.000A`). **Cause versus consequence is not established.**

**Evidence gap:** there is **no HCI trace and no daemon trace for any failed attempt** — btmon
and SIGUSR2 were armed only at 21:49, after every failure. The HCI status of a failing attempt,
whether it reached `LE Create Connection`, and whether the peripheral was advertising at click
time are all **unknown**.

---

## 6. Codex consultation status

**No accepted Codex review exists.** No Codex diagnosis was obtained, and none may be inferred
from the partial artefacts. **Consultation remains open.**

All current-session Codex processes were terminated (PIDs 14867 → 14864 → 14862, plus earlier
runs); **zero** remain.

### Attempt record

| # | Configuration | Outcome / cause |
|---|---|---|
| 1 | `-c model_reasoning_effort=xhigh`, stdin via `-` | No response body. Later found still running; the `nohup` wrapper had exited while the child continued — PM misread partial output as failure. |
| 2 | `-c model_reasoning_effort=xhigh`, prompt as argument | **Endless web-search loop** — 30+ searches for BlueZ/Quickshell/kernel source, never answered. |
| 3 | `-c tools.web_search=false` | **Wrong config key** (PM error). Search still enabled; looped again. |
| 4 | `--disable web_search` | **Deprecated flag** (PM error). Tool reported the correct form is top-level `web_search`. |
| 5 | `-c web_search="disabled"` | Emitted only its commentary phase, then no final message. |
| 6 | `-c model_reasoning_effort=high`, `web_search="disabled"` | Same — commentary only. Confirms effort level was not the variable. |
| 7 | Clean re-run via script file, `xhigh`, `web_search="disabled"` | **Terminated by this directive before completion.** Explicitly **not accepted**: it was launched with web search disabled, contrary to the intended advisor configuration. |

**The tool itself must not be characterised as incapable based on these invocation failures.**
A trivial control prompt returned correctly, so the CLI and model work; the failures are
attributable to PM misconfiguration and to an unbounded search loop under a large prompt.

### Artefact locations — all clearly INCOMPLETE and NON-AUTHORITATIVE

`~/.local/state/aurora-build/xbox-known-good/codex-attempts-INCOMPLETE/`

- Prompts: `codex-bt-pass1.md`, `codex-bt-pass1b.md`, `codex-bt-pass2.md`
- Partial outputs: `codex-bt-pass1-out.txt`, `codex-bt-1b-out.txt`, `codex-bt-1c-out.txt`,
  `codex-bt-1d-out.txt`, `codex-bt-1e-out.txt`, `codex-bt-2-out.txt`, `codex-bt-3-out.txt`
- Runner: `run-codex-bt.sh`; termination record: `codex-termination-record.txt`
- **`codex-HYPRLAND-pass1-PREPARED-NEVER-RUN.md`** — a complete blind Pass-1 packet for the
  compositor/snap defects that was written but **never executed**. It is a usable starting
  point; it predates defect F8 (hovered scroll), which must be added.
- Codex session rollouts: `~/.codex/sessions/2026/07/29/rollout-*.jsonl`

### Standing consultation workflow (unchanged, mandatory)

Use **GPT-5.6 Sol at `xhigh`**, with **normal web-search capability available**, read-only and
advisory scope, and a **bounded invocation method that captures the real child process and its
completion state** — not a `nohup` wrapper whose exit is mistaken for the child's.

Codex may inspect source, diffs, patches, logs and runtime evidence; independently diagnose;
challenge hypotheses; identify conflicts and regression risks; propose exact source changes,
pseudocode or patch diffs; and design static/unit/runtime tests. Codex may **not** edit the
working tree, run builds, stage or activate generations, commit, push, execute implementation,
or expand scope beyond the assigned defect cluster.

Pass 1 must be **blind** — Codex receives Alex's exact physical observations, gen 31 vs gen 32
behaviour, logs and timestamps, the exact source/diff, the loaded compositor/plugin identities,
and the acceptance behaviour, **without** the PM's preferred diagnosis. Claude then forms its
own diagnosis. A second `xhigh` review adversarially evaluates whether the proposal explains the
entire trace, whether it risks destroying pairings, whether it can regress Xbox reconnect latency
or other Bluetooth devices, whether a restart/live test/rebuild/reboot is actually necessary, and
the exact acceptance tests.

**Any material Claude/Codex disagreement must be surfaced to Alex before implementation. It may
not be silently resolved by PM preference.**

**No implementation before both independent reviews and the adversarial review are complete.**

---

## 7. Constraints carried forward

- Do not build, stage a generation, or reboot per individual fix. Produce **one** root-cause
  report and **one** frozen correction manifest covering all regressions first.
- Batch the correction into **one closure and one later reboot**.
- Use isolated worktrees for unrelated work while diagnosing.
- Never pass `--override-input macbook-config path:/home/alex/nix` — the `path:` fetcher ignores
  `.gitignore` and previously filled the disk (see `README.md`).
- Boot-only deployment: `nix-env --profile --set` + `switch-to-configuration boot`. Never
  `switch` or `test`.
- Seven distinct states: written · built · installed · activated · tested · passed · accepted.
  Gen 32 reached **activated**, then **failed** testing.
