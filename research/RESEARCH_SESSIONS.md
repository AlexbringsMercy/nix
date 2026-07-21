# RESEARCH SESSIONS — the remaining research, scoped and ready to run

**What this is:** the single file the user runs all post-gap-review research from. Every still-open item from `GAP_REVIEW.md` (Categories A–F + its addendum) and every un-closed need in `SYNTHESIS.md` is assigned to exactly one session below, or to the **No-session list** at the end with its verdict. Nothing is unaccounted for.

**How to use:** run the sessions in the recommended order (§ Run order). For each, open a fresh Codex session and paste its **ready-to-paste prompt** verbatim — the prompt is self-contained (role, read list, task, rules, output format). Sessions write to their own `~/nix/research/<name>.md`. They report findings incrementally so you can re-steer.

**What these sessions are NOT:** they do not plan, execute, write config, run diagnostics, or touch the live machine. They read community repos/wikis, view previews, compare candidates, and write findings mapped to requirement/gap IDs. The L3 plan session consumes all of these plus `SYNTHESIS.md`.

---

## Overview table

| # | Session | One-line scope | Output file | Size |
|---|---|---|---|---|
| 1 | **Shell Surfaces — Dock, Sidebar & Launcher** | Settle the caelestia sidebar contested claim; three-way dock comparison (DMS + ekremx25 + iNiR); specify the sidebar's *visual*; measure the caelestia launcher slice | `research/shell-surfaces.md` | Large |
| 2 | **Lock Screen** | Open comparison of ALL lock candidates (Hyprlock + QML/QuickShell), each one's real choreography ceiling and shipped safeguards | `research/lock-screen.md` | Medium |
| 3 | **Window Management, Input & Gestures** | Per-window controls (hyprbars vs alternatives), window move/snap/drag-to-workspace, 4-finger/pinch gestures, and sourced fixes for the open input/window bugs | `research/window-input.md` | Medium-large |
| 4 | **Hardware, Drivers & Boot** | T2 + Iris Plus physical-machine truth: webcam, speaker profile, fan, keyboard backlight, recorder backend, gaming latency, T2 boot-default | `research/hardware-drivers.md` | Large |
| 5 | **Dev Experience & Workspace** | The §7 two-agent workspace sourcing + Alt+Tab, Starship, Neovim eval, Fish accept-key, find-file, agent completion hooks, persistent agent sessions | `research/dev-experience.md` | Large |
| 6 | **Daily Guardrails** | Config-class policy research: battery lifecycle, night light, audio device auto-switch, disk/GC policy, captive-portal handling | `research/daily-guardrails.md` | Medium |
| 7 | **App Lifecycle — Install & Update** | tuxmate NixOS reality-check + install-GUI comparison; durable npm-global; the update-diff/rollback (nvd) experience | `research/app-lifecycle.md` | Small-medium |
| 8 | **Settings Center & System Dialogs** | caelestia Nexus slice eval + settings page inventory; polkit/keyring/greeter/logout theming; emoji surface; health & backup sourcing | `research/settings-dialogs.md` | Medium |
| 9 | **File Management & Dialogs** | Thunar vs Nemo vs Nautilus (full daily-use criteria); archive opener; file-picker portal backend; desktop + file-manager right-click menus | `research/file-management.md` | Medium |
| 10 | **Wallpaper Pipeline** | Verify skwd-wall handles transitions natively (awww redundancy); SliceDelegate compat; gowall/hellwal generator capabilities; auto-cycling | `research/wallpaper-pipeline.md` | Small-medium |

**Recommended run order:** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10. Sessions 1–3 block the most downstream planning (two major surfaces, the lock surface, and the core window/input interaction model). Sessions 4, 9, 10 are independent of the others and may be run in parallel or at any time. See § Run order for rationale.

---

## Universal rules block (embedded in every prompt)

Each prompt below contains this rules block verbatim so it can be pasted into a fresh session with no editing. It is reproduced once here for reference:

> **RULES —**
> 1. **Licensing is not a constraint and is never mentioned.** Any reference to it is a violation. Treat every repo as fully usable.
> 2. **Never build from scratch.** Find and adapt an existing community implementation; the only acceptable bespoke work is small glue (a dispatch script, a min-width override) no community implementation could contain. If you can't find it here, the answer is "search elsewhere," not "write our own."
> 3. **Full-repo / full-source reads.** When a repo is involved, read the whole thing — structure, services, theming, how pieces interconnect — not one keyword-matched file. For wiki/web sources, read the whole relevant page set.
> 4. **Visual verification is mandatory.** VIEW previews, screenshots, and videos before ranking or adopting anything. State findings from what you SAW, not from reading CSS/QML values. A component ranked on source alone is not ranked.
> 5. **No system diagnostics, no security work, no execution, no code-writing.** You do not touch the live machine. Sourcing the community's known-good hardware/config approach is research and is in scope; running or verifying it on the machine is execution-time and out of scope — flag those as "live-test at execution" steps.
> 6. **Write findings to your output file; report important discoveries incrementally** so the user can re-steer. No everlong chat-only sessions.
> 7. **Cross-reference `~/nix/MASTER_REQUIREMENTS.md`; map every finding to a requirement/gap ID** (§4.x, §6, A2, B5, C4, E-row, F-row, etc.).
> 8. **Surface bonus finds** that fit the design philosophy (§0, §2, §3) even if nobody asked, flagged as such.
> 9. **Honesty:** end your output with a "What I actually read/viewed vs what I didn't" section. Rank candidates with explicit reasoning. Compare multiple candidates — no first-match acceptance. Flag any claim you're carrying from a single prior session as unsettled until you've checked it against the actual source. Contested claims (previously flip-flopped) must be settled with file paths + viewed previews as evidence.

---

# Session 1 — Shell Surfaces: Dock, Sidebar & Launcher

**Purpose.** Close the two-side-surface question and the launcher packaging question — the single biggest still-open cluster. Covers **A2** (dock/sidebar three-way + the sidebar-is-a-mirage problem), **A3** (launcher slice measurement), **A5** (display-panel rider), and the canonical **contested claim** ("caelestia sidebar is just a notification drawer" — UNSETTLED per §15). Bar ownership (A1) is already decided (QuickShell) so this session does **not** touch the top bar.

**In scope:**
- Settle definitively what caelestia's "sidebar" actually is (open the real main repo; file paths + viewed previews).
- Three-way dock code comparison to equal depth: **DankMaterialShell** Modules/Dock, **ekremx25/quickshell** dock, **snowarch/iNiR** dock (already researched — use `iNiR.md` as the depth baseline the others must be brought up to).
- Specify the sidebar's *visual design* (glass tile treatment, Kurve visualizer strip placement/sizing, pinned/running grouping) — because no repo's stock look matches the intent (agridyne's "sidebar" is a Kurve strip + desktop widgets + Zen tiles, not a liftable sidebar).
- Measure the **minimal caelestia launcher closure**: what QML/plugin/AppDb/Qalculator pieces come with it, and whether it drags in the C++ plugin build. Output a concrete slice size + dependency list so the plan can choose "carry the slice" vs "configured shell with modules disabled."
- **Rider (A5):** while DMS is open, assess its display module; glance at noctalia's display module — so the ilyamiro `MonitorPopup` display panel becomes a *choice*, not a default.

**Out of scope:** top bar (decided QuickShell); notification/panel service backends (sourced in SYNTHESIS); lock screen; anything not a dock/sidebar/launcher/display surface.

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md`; `~/nix/research/SYNTHESIS.md` (sidebar/dock/launcher/display sections); `~/nix/research/caelestia.md`, `~/nix/research/agridyne.md`, `~/nix/research/iNiR.md`.

**Output:** `~/nix/research/shell-surfaces.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland 0.55 + QuickShell OS build on a 2020 T2 MacBook Air (Intel i3 dual-core, Iris Plus, 8GB RAM, 1.5x fractional scale, single display). You research external community repos and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST (in order):
- ~/nix/MASTER_REQUIREMENTS.md — the authoritative requirements. Note §6 (Sidebar/dock, Launcher, Dropdown panels), §2 interaction philosophy, §3 visual direction, §8 reference-build map, §15 decisions.
- ~/nix/research/SYNTHESIS.md — sections: "Sidebar / vertical dock", "Launcher", "Display panel". This is prior cross-repo synthesis; treat its single-session-sourced claims as provisional.
- ~/nix/research/caelestia.md, ~/nix/research/agridyne.md, ~/nix/research/iNiR.md — prior full-repo reads of three of the candidates.

YOUR TASK — settle the two side surfaces + the launcher packaging:

1. CONTESTED CLAIM (must settle definitively). The claim "caelestia's sidebar is just a notification drawer" has flip-flopped across prior sessions ("no dock" → "3-module composite" → "notification drawer"). Open the ACTUAL caelestia-dots/caelestia MAIN repo (not just /shell) and settle what the sidebar is: its modules, layout, whether it contains any pinned/running app dock, its interaction model. Give file paths and VIEW its previews. State the verdict plainly.

2. DOCK — three-way code comparison to equal depth. iNiR's dock (modules/dock/Dock.qml, DockApps.qml, DockAppButton.qml, DockPreview.qml, DockContextMenu.qml) is already researched in iNiR.md — use it as the depth baseline. Bring these two up to that same depth of read + preview viewing:
   - DankMaterialShell (the Modules/Dock, ~4 files: left-vertical dock, pinned + running grouped icons).
   - ekremx25/quickshell (its dock implementation).
   Compare all three against §6 Sidebar/dock requirements: left-vertical, pinned + running grouped, mouse task actions (hover preview, click activate, right-click close/close-all, pin/unpin, launch-new), glass icon-tile treatment, auto-hide, stable ordering. Rank with reasoning. VIEW previews of each — do not rank on code alone.

3. SIDEBAR VISUAL SPEC. No repo's stock sidebar matches the intent, so specify it: the glass app-tile treatment (agridyne's YouTube-style themed tiles are the visual motif — describe from viewed previews), where the Kurve Cava visualizer strip sits and at what size (luisbocanegra/kurve is the visualizer source; agridyne showcases exact sizing — Left orientation, Blocks, rounded, bar width 4/gap 5, block height 5/gap 4, transparent bg), and how pinned vs running groups are arranged. Produce a half-page concrete visual spec the plan can build to.

4. LAUNCHER SLICE MEASUREMENT (A3). Appearance/behavior is already decided: caelestia's launcher. The open question is dependency ownership. Open caelestia and determine the MINIMAL closure needed to run just the launcher: which QML modules, whether it needs the C++/native plugin (Caelestia appdb, qalculator), Config, controls, Actions.qml, the shared drawer wrapper (which must be replaced with an independent glass window). Count what comes with it. State concretely: is carrying the slice cheaper than running the configured shell with other modules disabled? Give a dependency list and a size estimate.

5. RIDER (A5, display panel). While DMS is open, assess its display/monitor module. Glance at noctalia (noctalia-shell) for a display module too. Goal: make ilyamiro's MonitorPopup (the current default-by-elimination for the Display panel) a real choice — note if DMS/noctalia have a better resolution/refresh/arrangement panel worth adopting instead. Single display today, but keep future multi-monitor code in mind.

CONTESTED CLAIMS to settle in your area, with evidence: the caelestia sidebar identity (task 1); "iNiR dock is visually conventional / no bespoke glass tiles" (verify from previews); "DMS dock is the leading source" (MASTER §6) vs "iNiR provisionally wins" (SYNTHESIS) — resolve by actual comparison.

RULES —
1. Licensing is not a constraint and is never mentioned. Any reference to it is a violation. Treat every repo as fully usable.
2. Never build from scratch. Find and adapt an existing community implementation; the only acceptable bespoke work is small glue no community implementation could contain. If you can't find it, say "search elsewhere," not "write our own."
3. Full-repo reads. Read the whole repo — structure, services, theming, interconnections — not one keyword file.
4. Visual verification is mandatory. VIEW previews/screenshots/videos before ranking. State findings from what you SAW. A component ranked on source alone is not ranked.
5. No system diagnostics, no security work, no execution, no code-writing. Don't touch the live machine.
6. Write findings to your output file and report important discoveries incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map every finding to a requirement/gap ID.
8. Surface bonus finds that fit the design philosophy (§0/§2/§3), flagged as such.
9. Honesty: end with a "What I actually read/viewed vs what I didn't" section. Rank with reasoning; compare multiple candidates; settle contested claims with file paths + viewed previews.

OUTPUT to ~/nix/research/shell-surfaces.md, structured: Sidebar verdict (contested claim settled) · Dock three-way comparison + ranking · Sidebar visual spec · Launcher slice measurement + recommendation · Display-panel rider · Bonus finds · What I read/viewed vs didn't.
```

---

# Session 2 — Lock Screen

**Purpose.** Turn the lock screen from "Hyprlock by default" into a real, evidence-graded **open comparison**, per §15 (Hyprlock is NOT locked in; QML/QuickShell locks are back in scope; the "lockout risk" is overstated). Reframes Fable's **D6** (Hyprlock's 8-node ceiling is now one input, not the settled boundary) and answers the §15 research target: what safeguards the top QML locks actually ship and what each option's real choreography ceiling is.

**In scope:**
- Enumerate the real candidates: **Hyprlock** (current-version animation node ceiling from its actual source), **QuickShell/QML `WlSessionLock` locks** (ilyamiro, caelestia, iNiR implementations + any strong r/unixporn NixOS QML lock), and any other Hyprland-compatible lock.
- For each: the **actual choreography ceiling** (what can fade/move/scale/sequence) and the **shipped safeguards** (PAM fallback, TTY escape, watchdog/systemd restart, unlock-not-dependent-on-a-shell-process).
- Map each against the visual target: blurred wallpaper + circular vignette, large clock/date, avatar, PIN field, battery/WiFi status, cinematic depth-of-field, and an *unlock* animation (Hyprlock has none today).
- Recommend the highest choreography ceiling that can be made safe, with the `security.pam.services.<lock>` requirement stated.

**Out of scope:** implementing anything; the greeter/logout screen (that's Session 8, regreet); the boot splash (Session 4, Plymouth).

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§6 Lock, §3 Motion, §15); `~/nix/research/SYNTHESIS.md` (Lock screen section + the Motion "Lock choreography" row); `~/nix/research/ilyamiro.md`, `~/nix/research/caelestia.md`, `~/nix/research/iNiR.md`.

**Output:** `~/nix/research/lock-screen.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland 0.55 + QuickShell OS build on a 2020 T2 MacBook Air (dual-core i3, Iris Plus, 8GB RAM, single display). You research external community sources and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — especially §6 "Lock screen — NOT locked to Hyprlock", §3 Motion, §15 DECISIONS LOG (lock screen is an OPEN comparison; the QML "lockout risk" is overstated — boot recovery + root password always exists; the target is the highest choreography ceiling that can be made safe).
- ~/nix/research/SYNTHESIS.md — the "Lock screen" section and the Motion table's "Lock choreography" row. NOTE: the synthesis pre-decided "Hyprlock, restyled." That decision is REOPENED by §15. Treat the synthesis lock recommendation as one input, not the answer.
- ~/nix/research/ilyamiro.md, ~/nix/research/caelestia.md, ~/nix/research/iNiR.md — for their lock implementations (ilyamiro Lock.qml choreography; caelestia shell/modules/lock/* with PAM/fingerprint/face; iNiR modules/lock/* with media/Cava).

YOUR TASK — an evidence-graded open comparison of lock-screen options:

1. ENUMERATE candidates. At minimum: (a) Hyprlock (hyprwm/hyprlock); (b) the QML/QuickShell WlSessionLock locks in ilyamiro, caelestia, iNiR; (c) any other strong Hyprland-compatible lock, including standout QML locks from top r/unixporn NixOS/Hyprland builds — search for them and VIEW their showcases.

2. For HYPRLOCK: read its ACTUAL current source to establish the real choreography ceiling — how many animation nodes exist, whether labels/images can fade/move/scale, which config options are dead. A prior review found (older version) only ~8 animation nodes and no label fade/move/scale. Verify against the current version and state what Hyprlock can and cannot choreograph today, including whether it has any unlock (not just lock) animation.

3. For each QML/QuickShell LOCK: establish (a) its choreography ceiling — what it actually animates, from VIEWED previews/videos, and (b) its SAFEGUARDS. This is the core §15 question: the top builds shipping QML locks will have safety mechanisms — find them. Specifically look for: PAM fallback configuration, TTY escape (VT switch), a watchdog/systemd restart if the lock process dies, and whether a successful unlock depends on a shell process staying alive. Document each candidate's safeguard set with file paths.

4. MAP each candidate to the visual target (§6): blurred wallpaper, circular vignette, large clock/date, avatar, PIN field, battery + WiFi status pills, cinematic depth-of-field, and an unlock animation. VIEW previews — rank visual/choreography quality from what you SAW.

5. RECOMMEND: the highest choreography ceiling that can be made safe on this laptop, with reasoning. State the required PAM line (security.pam.services.<chosen> = {};) and the exact safeguards the chosen option needs configured. If the honest answer is "QML lock X with safeguards A/B/C beats Hyprlock's ceiling and is safe," say so; if Hyprlock's safety wins despite the lower ceiling, say that. Do not inherit either prior position.

CONTESTED CLAIM to resolve: SYNTHESIS says "Hyprlock, translate ilyamiro's choreography through supported facilities"; the overhaul said most of that choreography is NOT translatable (8-node ceiling). Settle which is true against current Hyprlock source, then judge it against the QML options now that they're back in scope.

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community implementations, small glue only.
3. Full-source reads (repo + the lock's actual source/config).
4. Visual verification mandatory — VIEW lock previews/videos before ranking.
5. No diagnostics, no security hardening work, no execution, no code-writing. (Reading how a lock configures PAM/TTY-escape/watchdog is research; configuring them on the machine is execution-time — flag as live-test.)
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §6/§3/§15 and D6.
8. Surface bonus finds, flagged.
9. Honesty: end with "What I actually read/viewed vs what I didn't." Rank with reasoning; compare all candidates; settle the contested ceiling claim with source evidence.

OUTPUT to ~/nix/research/lock-screen.md: Candidate inventory · Hyprlock real ceiling · Per-candidate choreography ceiling + safeguards table · Visual mapping to target (from viewed previews) · Recommendation with PAM + safeguard requirements · What I read/viewed vs didn't.
```

---

# Session 3 — Window Management, Input & Gestures

**Purpose.** Source the window/input interaction model — a core §2 interaction-philosophy area with no owner yet. Covers **§4.15** (per-window min/max/close — hyprbars vs alternatives), **§4.16** (window move/snap/drag-to-workspace), **§4.8** (4-finger + pinch gestures), and the still-open **Category F** input/window bugs (`disable_while_typing`, backspace repeat, scroll-speed normalization, corner-resize one-directional, 3rd-window-close, hover-focus policy). Gives the "it's just config" items sourced values/repro instead of assumptions.

**In scope:**
- Per-window controls: current **hyprbars** state (re-evaluate against upstream bugs it was deferred over) vs alternatives; minimize→special-workspace semantics; a focus policy that coexists with per-window buttons and avoids hover-targeting errors.
- Window movement: Cmd+arrows (config), edge-snapping (plugin/config check), modifier-free titlebar dragging, and **drag-window-onto-workspace-button** (DropArea + payload — iNiR's `BarModuleOrderEditor` DropArea is a *pattern*, not an implementation; source the real dragged-window→workspace approach).
- Gestures: 4-finger map (caelestia `gestures.lua` is sourced) and **pinch** (research — unsourced everywhere), preserving the working 3-finger workspace swipe.
- Open input/window bugs: `disable_while_typing` empirical fix (without regressing tap-to-click/two-finger scroll), progressive backspace/delete repeat, cross-app scroll-speed normalization (esp. Chrome), corner-resize one-directional cause (dwindle edge behavior), and the 3rd-window-resizes/closes-another cause. Provide sourced values/known-good settings and repro direction.

**Out of scope:** the bar itself (decided); root-caused bugs already fixed by decisions (workspace-2 button, apps-die-on-restart — QuickShell bar + detached launches); security/diagnostics.

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§4.8, §4.15, §4.16, §5 Input & Window sections, §2); `~/nix/research/GAP_REVIEW.md` (Category F + E-table window rows); `~/nix/research/caelestia.md` (gestures.lua, keybinds.lua); `~/nix/research/iNiR.md` (DropArea pattern, dock context menus).

**Output:** `~/nix/research/window-input.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland 0.55 (native Lua config) + QuickShell build on a 2020 T2 MacBook Air (Apple keyboard, Cmd=Super; libinput touchpad with working tap-to-click + two-finger scroll that must NOT regress; single display). You research community solutions and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §4.8 gestures, §4.15 per-window controls, §4.16 window movement/snapping, §5 bug log (Input & typing, Window management), §2 interaction philosophy (mouse-first, redundancy, no hotkey memorization).
- ~/nix/research/GAP_REVIEW.md — Category F (bug cross-reference) and the Category E table rows for per-window controls, window move/snap/drag, gestures.
- ~/nix/research/caelestia.md — its gestures.lua (4-finger workspace, 3-finger special-workspace, 4-finger sleep) and keybinds.lua dispatch patterns.
- ~/nix/research/iNiR.md — its DropArea drag mechanics (BarModuleOrderEditor) as a PATTERN only.

YOUR TASK — source the window/input interaction model:

1. PER-WINDOW CONTROLS (§4.15). Min/Max/Close buttons on EVERY window (hover-reveal at window top is acceptable), because traveling to the bar for every close is tedious and hover-follows-focus makes it error-prone. Re-evaluate hyprbars' CURRENT state (it was deferred over upstream bugs — is it usable now?) against alternatives (other Hyprland titlebar/decoration plugins, or a QuickShell-drawn per-window control overlay). Cover minimize semantics (likely map to a special workspace). VIEW previews of each. Rank.

2. FOCUS POLICY. Source a focus policy that coexists with per-window buttons and fixes the "hover-based focus makes the bar close button error-prone / must avoid hovering other windows en route" bug. State the concrete Hyprland focus settings.

3. WINDOW MOVEMENT & SNAPPING (§4.16). Cover: Cmd+arrows to move windows (config), drag-to-edge half/full snapping (built-in vs plugin), modifier-free titlebar dragging (grab via titlebar like Windows, not holding Cmd), and DRAG-WINDOW-ONTO-WORKSPACE-BUTTON (the bar workspace delegate must accept a dragged window/task payload and dispatch that window to the workspace). The iNiR DropArea is only a pattern — find the real dragged-window→workspace implementation if one exists in the community, else specify the minimal glue.

4. GESTURES (§4.8). Preserve the working 3-finger workspace swipe. Source the 4-finger map (caelestia gestures.lua is the syntax/action source — resolve its workspace-vs-sleep conflict) and PINCH-to-zoom behavior (unsourced everywhere — research what's achievable natively in Hyprland 0.55 and via community configs). Every gesture action must also have a mouse-accessible equivalent.

5. OPEN INPUT/WINDOW BUGS — give sourced values or repro direction (not "just config" hand-waving):
   - disable_while_typing ineffective (cursor clicks into text while typing) — empirical fix without regressing tap-to-click/two-finger scroll; note libinput DWT pairing.
   - Backspace/Delete key repeat too fast / not progressive — target repeat_delay/rate values (acceleration is proven impossible; state the honest tunable range).
   - Scroll speed inconsistent (fine in terminal, too fast/jumpy in Chrome and elsewhere) — scroll_factor range + how to fix Chrome separately.
   - Corner/border resize only works one direction (can expand, can't shrink from a corner) — likely dwindle edge behavior; give repro direction and any known Hyprland fix.
   - Opening a 3rd+ window sometimes resizes and CLOSES an existing window — note the prior root-cause theory (Waybar cgroup, now removed) and what to re-verify.

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community solutions, small glue only.
3. Full reads of any plugin/repo/wiki involved.
4. Visual verification mandatory — VIEW previews of per-window control solutions before ranking.
5. No diagnostics, no execution, no code-writing. You can source known-good libinput/Hyprland values from the community; the actual empirical before/after test is execution-time — flag it.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §4.8/§4.15/§4.16 and the F bug IDs.
8. Bonus finds flagged.
9. Honesty: end with "What I actually read/viewed vs what I didn't." Rank per-window-control candidates with reasoning; be explicit where the community has no source and only glue is possible.

OUTPUT to ~/nix/research/window-input.md: Per-window controls comparison + ranking · Focus policy · Window move/snap/drag (incl. drag-to-workspace) · Gesture map (4-finger + pinch) · Open input/window bugs with sourced values/repro · Bonus finds · What I read/viewed vs didn't.
```

---

# Session 4 — Hardware, Drivers & Boot

**Purpose.** Establish physical-machine truth for the T2 MacBook + Iris Plus so no daily trust-breaking surprise survives to execution. Covers **B5** (webcam), **A7** (recorder backend on Iris Plus), **C4** (T2 speaker profile), **C14** (t2fanrd), **B17/C13** (keyboard-backlight persistence + idle intelligence), the **§4.6** gaming latency stack, the **§4.4** T2 boot-default (`bless`/NVRAM) research, and the mic/camera in-use indicators from **B4/B5**. Almost entirely a t2linux-wiki + targeted-repo web-research session (no live-machine testing — that's execution-time).

**In scope:**
- **Webcam:** does the internal T2 camera work under the current kernel, what driver/firmware path (t2linux), Chrome/Wayland (Meet/Zoom web) usability, and a test-surface pattern (`mpv /dev/video0` behind a System-group action). Note historical T2 camera quality caveats honestly.
- **Recorder backend:** `gpu-screen-recorder` vs `wf-recorder` vs OBS-class on Iris Plus / i915 — VA-API hardware encoding reality, community reports. The capture *UI* is already sourced (ilyamiro overlay + caelestia record lifecycle); this decides only the backend.
- **T2 speaker profile (C4):** the t2linux-maintained EasyEffects profile for MacBookAir9,1 that restores macOS-like voicing. Source it as the default output preset (EasyEffects is already the invisible EQ backend).
- **t2fanrd (C14):** the T2 fan-control daemon; a sane curve + a temperature readout source for the system workspace.
- **Keyboard backlight (B17/C13):** `apple::kbd_backlight` via `applesmc` — persistence across boots, a slider path, idle-dim/restore-on-keypress.
- **Gaming latency stack (§4.6):** xpadneo vs xone controller driver, Hyprland frame-timing/tearing options, PipeWire quantum/audio-latency tuning, and the XWayland-scaling-blurriness check at 1.5x. The Xbox controller had button+video+audio latency that worked on macOS — pure NixOS config debt.
- **T2 boot-default (§4.4):** the careful `bless`/NVRAM-from-macOS research to remove the per-boot Option hold, with T2 startup-security caveats stated. (Plymouth theming + systemd-boot menu-hiding are config — flagged, not the research core.)
- **Mic/camera in-use indicators (B4/B5):** the macOS orange/green dot — PipeWire node-state watchers (caelestia/iNiR audio services already track streams) + a bar-level mic-mute toggle.

**Out of scope:** anything requiring running commands on the live machine (flag those as execution-time live-tests); security hardening; the capture UI (sourced); audio *device auto-switch* policy (that's Session 6's WirePlumber block — this session only covers the in-use indicators and the speaker profile).

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§4.4, §4.6, §4.7, §4.9, §10 hardware constraints/invariants, §13); `~/nix/research/GAP_REVIEW.md` (A7, B5, C4, C13, C14, B17, boot rows in E); primary web source: the **t2linux wiki** (covers camera, speaker, fan, keyboard backlight, boot on T2).

**Output:** `~/nix/research/hardware-drivers.md`.

**Ready-to-paste prompt:**

```
You are a targeted hardware-research session for a NixOS 26.11 build on a 2020 MacBook Air (MacBookAir9,1 — Intel i3 Ice Lake dual-core, Intel Iris Plus / i915, 8GB RAM, Apple T2 chip, Broadcom WiFi/BT, Apple internal keyboard/camera/speakers). You research the community's known-good hardware/driver approaches and write findings to a file. You do NOT run commands on the machine, diagnose it, or execute anything — where a step requires the live machine, flag it as an execution-time live-test.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §4.4 boot experience, §4.6 gaming input stack, §4.7 network truth, §4.9 system sounds, §10 hardware constraints & invariants (T2 kernel/modules, firmware/brcm, Iris Plus, 8GB budget — these are preserved unconditionally), §13 apps.
- ~/nix/research/GAP_REVIEW.md — A7 (recorder backend), B5 (webcam), C4 (T2 speaker profile), C13 (keyboard-backlight intelligence), C14 (t2fanrd), B17 (keyboard backlight persistence, boot), and the E-table boot/gaming rows.
- Primary external source: the t2linux wiki (wiki.t2linux.org) and the t2linux GitHub org — they cover camera, speakers, fan, keyboard backlight, and boot for exactly this hardware. Read the relevant pages fully.

YOUR TASK — source physical-machine truth. For each, state the community's known-good approach, the NixOS config shape, honest caveats, and the exact live-test step to run at execution:

1. WEBCAM (B5). Does the internal T2 camera work under the current kernel? Driver/firmware path (t2linux). Can Chrome on Wayland use it for Meet/Zoom web? Historical quality/functionality caveats. A "Test camera" surface pattern (e.g. mpv /dev/video0) behind a System-group action. Discovering this broken in the first meeting is a trust-destroying event — be thorough and honest about risk.

2. RECORDER BACKEND (A7). gpu-screen-recorder vs wf-recorder vs OBS-class on Iris Plus / i915: VA-API hardware-encode reality, community reports of Intel-path success/failure, CPU/GPU cost. The capture UI is already chosen (ilyamiro overlay + caelestia record lifecycle) — you are choosing ONLY the backend. State the pick + the live-test.

3. T2 SPEAKER PROFILE (C4). The t2linux-maintained EasyEffects profile for MacBookAir9,1 that restores macOS-like speaker voicing (Linux defaults sound flat/tinny). EasyEffects is already the invisible EQ backend — source the profile to ship as the default output preset. Give the source location.

4. t2fanrd (C14). The T2 fan-control daemon: how it's configured on NixOS, a sane curve for sustained dual-core agent workloads, and where a temperature readout comes from for the system workspace.

5. KEYBOARD BACKLIGHT (B17/C13). apple::kbd_backlight via applesmc: persistence across boots (systemd-backlight-style unit), a slider control path, and idle-dim / restore-on-keypress (the macOS behavior on this exact chassis).

6. GAMING LATENCY STACK (§4.6). The Xbox controller had button + video/frame + audio latency on NixOS that did not exist on macOS — pure config debt. Source the full low-latency pipeline: xpadneo vs xone controller driver (evaluate both), Hyprland frame-timing/tearing/latency options, PipeWire quantum/buffer tuning for audio latency, and check XWayland scaling blurriness for Steam at 1.5x fractional scale. End-to-end, per §4.6. State the live-test to verify each leg.

7. T2 BOOT-DEFAULT (§4.4). The careful part: removing the per-boot "hold Option" via bless/NVRAM from the macOS side on a T2 Mac, with startup-security caveats. This touches an invariant (systemd-boot dual-boot with recovery) — research it deliberately and flag every risk. (Plymouth theming + systemd-boot menu timeout 0 with a hold-to-reveal key are config work — mention them but they are not the research core.)

8. MIC/CAMERA IN-USE INDICATORS (B4/B5). The macOS orange/green dot: PipeWire node-state watchers to detect mic/camera in use (caelestia/iNiR audio services already track streams — cite the pattern) and a bar-level mic-mute toggle.

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community configs/daemons, small glue only.
3. Full reads of the t2linux wiki pages and any driver/daemon repo involved.
4. Visual verification where relevant (e.g. VIEW recorder output samples / controller-test evidence if shown).
5. No diagnostics, no execution, no code-writing on the machine. Sourcing known-good configs is research; running/verifying them is execution-time — flag each live-test explicitly.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §4.4/§4.6/§4.9 and A7/B5/C4/C13/C14.
8. Bonus finds (other T2/Iris Plus quality wins) flagged.
9. Honesty: end with "What I actually read vs what I didn't," and be blunt about which items are genuine risks (camera, boot-default) vs low-risk.

OUTPUT to ~/nix/research/hardware-drivers.md: one block per item (webcam, recorder, speaker, fan, kbd backlight, gaming, boot-default, in-use indicators), each with community approach + NixOS shape + caveats + execution-time live-test · Bonus finds · What I read vs didn't.
```

---

# Session 5 — Dev Experience & Workspace

**Purpose.** Source the daily two-agent developer experience — the §7 major requirement plus the input/terminal polish that defines it. Per §15 this is **one session**: Alt+Tab (**B1**) + Starship (**B17**) + Neovim evaluation + Fish autosuggestion accept-key (**§4.5**) + related input polish + the **§7** dev-workspace sourcing (named/icon terminals, one-click agent launchers, find-file, git status, agent-session status) + **C1** (agent completion hooks) + **C2** (persistent agent sessions).

**In scope:**
- **Alt+Tab (B1):** QuickShell window-switcher implementations, `hyprswitch`, DMS switcher modules — a styled switcher with window previews. VIEW previews.
- **§7 dev workspace:** community sourcing for named + icon Kitty terminals, one-click launchers (Claude Code `--dangerously-skip-permissions` in its own terminal; Codex yolo in its own), preset working directories, a file viewer/search pane, click-any-path-in-output-opens-editor (kitten hints — sourced), a git-status summary, and agent-session status at a glance. Easy button+hotkey access and window movement into/out of it (special-workspace patterns).
- **C1 agent completion hooks:** Claude Code Stop/attention hooks → `notify-send` ("Claude finished in ~/nix — 3 files changed"); Codex equivalent via wrapper. This turns notifications into an agent-supervision surface.
- **C2 persistent agent sessions:** tmux/zellij under the agent Kitty windows so a terminal death never kills the agent — reattach and continue.
- **Terminal/find-file:** `fzf`/`television` + `bat` in a Kitty overlay for project find-file/open; the saatvik333 reference (its terminal features live in an nvim dashboard config).
- **Starship:** a community aurora-adjacent preset wired to palette tokens.
- **Neovim evaluation:** LazyVim vs AstroNvim — because the editor decision *is* the dev-workspace editor-pane decision (§15 promotes it to active eval; decide after the workspace lands).
- **Fish autosuggestion accept-key (§4.5):** the working accept key (right-arrow / Ctrl+F) documented on the Apple keyboard.

**Out of scope:** the top bar and notification service (sourced); the process/monitor workspace (mostly decided — btop on a named workspace); building anything.

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§7, §4.5, §6 Terminal, §14 Neovim note, §15); `~/nix/research/SYNTHESIS.md` (Terminal/Kitty section, "Daily two-agent development workspace" section); optionally `~/nix/research/caelestia.md` (named special-workspace Lua patterns, Fish/Starship/Fastfetch). For Claude Code hooks, consult the Claude Code documentation.

**Output:** `~/nix/research/dev-experience.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland 0.55 + QuickShell + Kitty + Fish build on a 2020 T2 MacBook Air (dual-core i3, 8GB RAM, Apple keyboard Cmd=Super). The user's daily workflow is TWO AI coding agents (Claude Code and Codex) running long tasks in terminals. You research community solutions and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §7 DEV WORKSPACE (the major requirement), §4.5 text input (Fish accept key), §6 Terminal (Kitty), §14 Neovim (promoted to active evaluation), §15 (dev-experience is one session; Neovim decided after the workspace lands; Kitty Ctrl+Shift+T reopen was really about reopening FILES → dev-workspace scope).
- ~/nix/research/SYNTHESIS.md — the "Terminal / Kitty" section and the "Daily two-agent development workspace (§7)" section (both note these are largely GAPS needing a dedicated community source — that's your job).
- ~/nix/research/caelestia.md — its named special-workspace Hyprland-Lua patterns and Fish/Starship/Fastfetch userland (organization reference).
- For Claude Code hooks specifically: consult the Claude Code documentation (hooks / Stop hook).

YOUR TASK — source the daily two-agent developer experience:

1. ALT+TAB SWITCHER (B1). Today Alt+Tab does nothing — a huge Windows-muscle-memory hole; the keyboard half of the mouse+keyboard redundancy philosophy. Source a styled window switcher with window previews: QuickShell window-switcher implementations, hyprswitch, DMS switcher modules. VIEW previews and rank; estimate the glass-token adaptation.

2. §7 DEV WORKSPACE. No repo closes this — source the pieces and specify the composition:
   - Named + ICON Kitty terminal windows (per-terminal name and icon).
   - One-click launchers: Claude Code with --dangerously-skip-permissions in its own terminal; Codex in yolo mode in its own terminal (detached from the launching process).
   - Quick terminal spawn with preset working directories.
   - A file viewer/search pane; click any path in terminal output to open that file in the editor (kitten hints is the sourced path-click mechanism).
   - A git-status summary for active repos, and active agent-session status at a glance.
   - Easy button + hotkey access; easy window movement into/out of the workspace (Hyprland special-workspace patterns — caelestia is the Lua reference).

3. AGENT COMPLETION HOOKS (C1). Claude Code supports hooks — a Stop/attention hook firing notify-send ("Claude finished in ~/nix — 3 files changed") turns notifications into an agent-supervision surface. Source the exact hook mechanism and the Codex equivalent (wrapper). This is the single highest-value notification source for this user.

4. PERSISTENT AGENT SESSIONS (C2). Run the agent launchers inside tmux or zellij so a terminal death (crash, accidental close) never kills the running agent — reattach and continue. Compare tmux vs zellij for this exact use; recommend one.

5. TERMINAL FIND-FILE / OPENER. fzf vs television (+ bat preview) in a Kitty overlay window for project find-file/open. The saatvik333 reference's terminal features live in its nvim dashboard config — note what's actually there. Include kitten hints for path-click (already sourced — just confirm the binding shape).

6. STARSHIP. Pick a community aurora-adjacent preset and describe wiring it to the palette tokens (deep dark blue/purple/teal). Keep it themeable via the central palette, not hard-coded.

7. NEOVIM EVALUATION. LazyVim vs AstroNvim (and note if a lighter config fits an 8GB dual-core better). This decides what the dev-workspace editor pane should be. VIEW previews of each. Recommend, but frame the final call as "after the workspace lands."

8. FISH ACCEPT KEY (§4.5). Document the working autosuggestion accept key (right-arrow / Ctrl+F) on the Apple keyboard — the exact binding and a 2-minute live-test to confirm.

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community solutions, small glue only.
3. Full reads of any repo/config involved.
4. Visual verification mandatory — VIEW switcher/Neovim/Starship previews before ranking.
5. No diagnostics, no execution, no code-writing on the machine. Flag the Fish-key and hook tests as execution-time.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §7/§4.5/§6/§14 and B1/C1/C2.
8. Bonus finds (dev-quality wins) flagged.
9. Honesty: end with "What I actually read/viewed vs what I didn't." Rank with reasoning; be explicit where §7 has no single community source and only composition/glue is possible.

OUTPUT to ~/nix/research/dev-experience.md: Alt+Tab candidates + ranking · §7 workspace composition (each piece sourced or flagged glue) · Agent completion hooks (C1) · Persistent sessions tmux vs zellij (C2) · Find-file/opener · Starship · Neovim eval · Fish accept key · Bonus finds · What I read/viewed vs didn't.
```

---

# Session 6 — Daily Guardrails

**Purpose.** Batch the config-class daily-safety policies that are absent from every document. Covers **B3** (battery lifecycle), **B2** (night light), **B4/C5** (audio device auto-switch, codec quality, per-device EQ/AutoEq), **B6** (disk-space stewardship + GC policy, framed around the §15 generation lifecycle), and **B11** (captive portals). All config-class — the research is identifying the right mechanism/tool and the policy shape, not building UI.

**In scope:**
- **B3 battery:** low-battery warnings (20%/10% with urgency escalation), critical auto-suspend at ~5% (zram-only → hibernate is off the table, suspend is the honest option), time-remaining estimate, automatic power-profile switching (powersave on battery / balanced-performance on AC — power-profiles-daemon is installed but has no policy). UPower policies, `poweralertd`, and the warning UX from iNiR/caelestia battery services.
- **B2 night light:** `hyprsunset` (first-party) vs `wlsunset`, a schedule, and a System-group toggle with a warmth slider; a quick visual check that a warm shift over aurora glass looks right.
- **B4 audio lifecycle:** WirePlumber auto-switch policy (AirPods connect → audio moves there; disconnect → moves back; 3.5mm plug → same), per-device, verified; BT codec quality (SBC vs AAC, BlueZ config). **C5:** bind EQ presets to output devices (speakers → the T2 profile from Session 4; headphones → their AutoEq profile) and switch with the device-switch events; source AutoEq DB usage.
- **B6 disk/GC:** visible disk usage, `nix.gc.automatic` with a retention window that respects the rollback story, generation pruning with a "keep last N + known-good" affordance, low-space warning. **Frame around §15:** generations 1–7 deletable now; after the first accepted complete build, current-era generations get wiped — the policy must tolerate that lifecycle.
- **B11 captive portals:** NetworkManager connectivity-check config + a dispatcher hook that notifies "This network needs a sign-in" with a click-through to the portal page.

**Out of scope:** UI construction; the audio *panel* (sourced in SYNTHESIS); the T2 speaker profile itself (Session 4); mic/camera in-use dots (Session 4); security/diagnostics.

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§4.7, §10 budget, §15 generations); `~/nix/research/GAP_REVIEW.md` (B2, B3, B4, B6, B11, C5). Optionally SYNTHESIS audio/network sections for the service backends that would surface these.

**Output:** `~/nix/research/daily-guardrails.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland + QuickShell build on a 2020 T2 MacBook Air (dual-core i3, 8GB RAM, 121GB NixOS partition, zram swap only — NO swap partition, so hibernate is unavailable; power-profiles-daemon installed but with no policy; Broadcom BT for AirPods-class devices). You research config-class policy solutions and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §4.7 network truth, §10 hardware budget (zram stays; no swap partition), §15 (Nix generations: 1–7 deletable now; post-acceptance the current-era generations get wiped too — GC policy must design around THAT lifecycle).
- ~/nix/research/GAP_REVIEW.md — B2 (night light), B3 (battery lifecycle), B4 (audio device lifecycle), B6 (disk/GC), B11 (captive portals), C5 (per-device EQ + AutoEq).

YOUR TASK — source the daily-safety policies (config-class; identify mechanism + policy shape, not UI):

1. BATTERY LIFECYCLE (B3). Low-battery warnings (20% / 10% with urgency escalation); CRITICAL auto-suspend at ~5% (hibernate is off the table — zram only; suspend is the honest action — without this, one absorbed coding session ends in hard power loss); time-remaining estimate for the power panel; automatic power-profile switching (powersave on battery, balanced/performance on AC). Source: UPower percentage policies, poweralertd, and the warning UX in iNiR/caelestia battery services. Give the concrete policy + which tool owns it.

2. NIGHT LIGHT (B2). hyprsunset (first-party, Hyprland 0.55-era) vs wlsunset: pick one, define a schedule + a System-group toggle with a warmth slider. Note the quick visual check that a warm shift over the aurora-glass palette looks right (participates in the theme story).

3. AUDIO DEVICE LIFECYCLE (B4 + C5). WirePlumber auto-switch policy: AirPods connect → audio moves there; disconnect → moves back; 3.5mm plug → same — per-device and verified. BT codec quality (SBC vs AAC — audible on AirPods-class devices; BlueZ config). C5: bind EQ presets to output devices (speakers → the T2 speaker profile [sourced separately in the hardware session]; headphones → their AutoEq profile from the public AutoEq database) and switch automatically on the device-switch events. Source AutoEq DB usage and the WirePlumber policy examples.

4. DISK / GC POLICY (B6). Visible disk usage (bar/system workspace); nix.gc.automatic with a retention window that respects rollback; generation pruning with a "keep last N + the known-good" affordance; a low-space warning. On NixOS a full disk can block the very rebuild that would fix it — the policy makes it never happen. FRAME AROUND §15: generations 1–7 are deletable now; after the first fully-working accepted build, current-era generations get wiped too — the retention policy must tolerate that lifecycle without stranding the rollback story.

5. CAPTIVE PORTALS (B11). Laptop + travel = hotel/coffee-shop portals. NetworkManager detects connectivity state but nothing acts on it. Source the NM connectivity-check config + a small dispatcher hook that notifies "This network needs a sign-in" with a click-through that opens the portal page. Note how caelestia/iNiR surface Nmcli connectivity states, if useful.

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community configs, small glue only.
3. Full reads of any tool docs/repos involved.
4. Visual verification where a UI toggle/slider preview exists.
5. No diagnostics, no execution, no code-writing. Flag any before/after check as execution-time.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §4.7/§10/§15 and B2/B3/B4/B6/B11/C5.
8. Bonus finds flagged.
9. Honesty: end with "What I actually read vs what I didn't"; be explicit about which tool you'd own each policy with and why.

OUTPUT to ~/nix/research/daily-guardrails.md: one block per policy (battery, night light, audio lifecycle, disk/GC, captive portal), each with mechanism + concrete policy + which tool owns it · Bonus finds · What I read vs didn't.
```

---

# Session 7 — App Lifecycle: Install & Update

**Purpose.** Answer §4.2 (mouse-friendly app install/update on NixOS) with a real community implementation, plus the update-diff superpower. Covers **§4.2** (installer GUI + durable npm-global path for agent CLIs) and **C3** (the "what changed?" update flow with an `nvd` generation diff + one-click rollback). The tuxmate-NixOS-reality-check comes first — if it's Arch-only, the anchor moves.

**In scope:**
- **§4.2 installer:** verify **tuxmate** (abusoww/tuxmate) actually supports NixOS (risk: Arch-focused) before anchoring on it; compare **nix-software-center** (vlinkz), `nix profile` imperative flows, and any other NixOS-native GUI. The criterion is tuxmate's UX bar (seamless, quick, pretty). Installing VS Code/Spotify must be as easy as on Windows/macOS.
- **npm-global for agent CLIs:** make the permanent npm-global path durable (Home Manager sessionPath) and document the update flow so `npm install -g` for Claude Code/Codex works like elsewhere.
- **C3 update experience:** a check → build → show `nvd` generation diff (packages added/removed/version bumps) → activate → "rollback" button that boot-selects the previous generation. This is the strongest "better than Windows/macOS" statement the build can make (NixOS can show exactly what an update did and undo it atomically). Source the `nvd` diff + the `nixos-rebuild`/rollback wrapper shape (lives in Settings › System — Session 8).

**Out of scope:** the Settings-center shell itself (Session 8); building the UI; the §13 app *theming* (palette architecture, sourced).

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§4.2, §13, §14 first bullet on install ease); `~/nix/research/GAP_REVIEW.md` (installer row in E, C3, B17 installer note); `~/nix/research/SYNTHESIS.md` (the "Application install/update" section — establishes no reviewed repo solves this).

**Output:** `~/nix/research/app-lifecycle.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS 26.11 build (flake-or-channel based; nix-ld enabled; agent CLIs Claude Code and Codex already working via npm-global and must keep working). You research NixOS app-install/update solutions and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §4.2 (App install & update: installing VS Code/Spotify must be as easy as Windows/macOS; updating Claude Code/Codex as easy as npm install -g; tuxmate [github.com/abusoww/tuxmate] is the UX reference), §13 apps list, §14 (install ease).
- ~/nix/research/GAP_REVIEW.md — the "NixOS GUI installer" row in the Category E table (verify tuxmate isn't Arch-only FIRST), C3 (update experience with a diff), and B17's installer note.
- ~/nix/research/SYNTHESIS.md — "Application install/update and permanent CLI-global path" section (confirms none of the five researched repos solves this; you are finding the actual community implementation).

YOUR TASK:

1. INSTALLER (§4.2). FIRST verify whether tuxmate actually supports NixOS or is Arch-focused — this determines whether it can be the anchor. Then compare NixOS-native GUI install options against tuxmate's UX bar (seamless, quick, pretty, mouse-first): nix-software-center (vlinkz/nix-software-center), nix profile imperative flows, and any other NixOS GUI app manager. VIEW previews of each. Recommend the best NixOS-compatible solution that matches tuxmate's ease for installing GUI apps like VS Code/Spotify. Rank with reasoning.

2. NPM-GLOBAL FOR AGENT CLIs. Claude Code/Codex already run via a global npm path — make it DURABLE under the Nix store model (Home Manager sessionPath or equivalent) and document the update flow so `npm install -g <agent>` keeps working like on any other OS. State the concrete config shape and the update command.

3. UPDATE EXPERIENCE (C3). Design the sourcing for a Settings › System update flow: check → build → SHOW the nvd generation diff (packages added/removed, version bumps) → activate → a "rollback" button that boot-selects the previous generation. NixOS is the only OS that can show exactly what an update did and undo it atomically — this is the headline "better than Windows/macOS" feature. Source: nvd (or nix-diff / nvd generation diff usage), the nixos-rebuild wrapper, and the boot-generation-select mechanism for rollback. The UI lives in the Settings center (a separate session) — you supply the mechanism + command shapes, not the UI.

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community tools, small glue only.
3. Full reads of the installer repos/tools' docs.
4. Visual verification mandatory — VIEW installer-GUI previews before ranking.
5. No diagnostics, no execution, no code-writing on the machine. Flag command-verification as execution-time.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §4.2/§13 and C3.
8. Bonus finds (e.g. declarative-vs-imperative UX tricks) flagged.
9. Honesty: end with "What I actually read/viewed vs what I didn't." State the tuxmate-on-NixOS verdict plainly up front.

OUTPUT to ~/nix/research/app-lifecycle.md: tuxmate NixOS verdict · Installer-GUI comparison + ranking · Durable npm-global + update flow · Update-diff/rollback mechanism (nvd + rollback) · Bonus finds · What I read/viewed vs didn't.
```

---

# Session 8 — Settings Center & System Dialogs

**Purpose.** Source the unification the governing standard keeps asking for — a place that *is* Settings — plus the un-themed system dialogs that break cohesion. Covers **B7** (Settings app: caelestia Nexus slice eval + page inventory), **B8** (polkit + keyring theming), **B12** (greeter/logout screen), **B13** (system-health surfacing), **B14** (backup story), and **B15** (emoji/special-char surface + color-emoji font verification).

**In scope:**
- **B7 Settings:** evaluate the caelestia **Nexus** slice (`shell/modules/nexus/*`) — can it be extracted without dragging in the whole service graph, how heavy is it — and propose a page inventory (Appearance, Display, Input [scroll speed / key repeat / gestures as *user-tunable* instead of one-shot fixes], Audio, Network, Notifications, Default apps, Startup apps, System [generation info/update/rollback from Session 7]). Ship page-by-page; each page a thin front over an existing service.
- **B8 polkit + keyring:** theme the polkit agent dialog (`hyprpolkitagent`, or a QuickShell polkit agent — check DMS/noctalia) and the GNOME keyring unlock prompt; note that keyring auto-unlock should ride the greetd PAM login (configured, untested → flag as live-test).
- **B12 greeter/logout:** the surface after logout (greetd fallback is raw today). `regreet` (GTK, themeable to the palette) vs tuigreet-styled minimalism. It's the OS's face at its worst moment (session death).
- **B13 system health:** a tiny watcher that notifies "a background service failed (watchdog restarted it)" with the journal excerpt one click away — systemd `OnFailure=` hooks or a QuickShell DBus watcher. Pairs with notification history.
- **B14 backup:** one decision — restic vs borgmatic to an external disk/cloud target, scheduled, with a status line in Settings › System. Compare the two for this use.
- **B15 emoji:** a mouse-reachable emoji/special-char surface (iNiR launcher has an emoji prefix — sourced; also a System-group or launcher-mode button + a hotkey) and verify a color emoji font (Noto Color Emoji) is installed system-wide (tofu in terminals/GTK apps is a classic NixOS miss).

**Out of scope:** building the pages; the update/rollback *mechanism* (Session 7 supplies it); the glass tuner (sourced — iNiR AuroraStyleEditor); the file-picker portal (Session 9).

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§0 governing standard, §2, §6 Dropdown panels, §4.17); `~/nix/research/GAP_REVIEW.md` (B7, B8, B12, B13, B14, B15, and Bonus Find #5 Nexus); `~/nix/research/caelestia.md` (Nexus module).

**Output:** `~/nix/research/settings-dialogs.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland + QuickShell build on a 2020 T2 MacBook Air. A polkit agent and gnome-keyring are installed; login is greetd auto-login; the shell aims for total visual cohesion (an unthemed default dialog is a jarring break). You research community solutions and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §0 governing standard ("streamlined enough that anyone could use it"), §2 interaction philosophy, §3 (no template-like breaks in cohesion), §6 Dropdown panels, §4.17 app theming.
- ~/nix/research/GAP_REVIEW.md — B7 (Settings app — highest-leverage single addition for "OS not rice"), B8 (polkit + keyring), B12 (greeter after logout), B13 (system health surfacing), B14 (backup story), B15 (emoji/special-char), and Bonus Find #5 (Caelestia Nexus).
- ~/nix/research/caelestia.md — the Nexus module (shell/modules/nexus/*) and its typed settings rows.

YOUR TASK — source the settings center and the un-themed system dialogs:

1. SETTINGS CENTER (B7). Evaluate the caelestia Nexus slice: can it be extracted to serve as a settings-center scaffold WITHOUT dragging in the entire caelestia service graph? How heavy is it? VIEW its previews. Then propose a page inventory, each page a thin front over an already-planned service: Appearance (wallpaper, palette/accent, glass tuner, motion/reduced-motion), Display (resolution/refresh, night light, brightness), Input (scroll speed, key repeat, gestures, tap settings — the bug-log input complaints become USER-TUNABLE here), Audio, Network, Notifications (per-app rules), Default apps (the §4.1 MIME map made visible), Startup apps, System (generation info / update / rollback — mechanism comes from the app-lifecycle session). Recommend a page-by-page ship order.

2. POLKIT + KEYRING (B8). Source a themed polkit agent: hyprpolkitagent, or a QuickShell polkit agent (check DankMaterialShell / noctalia — some shells ship one). Theme it to the palette. Same for the gnome-keyring unlock prompt if it appears outside auto-unlock. Note that keyring auto-unlock should ride the greetd PAM login (configured but untested — flag the live-test). VIEW previews.

3. GREETER / LOGOUT (B12). After logout the session drops to a raw greetd fallback — the OS's face at its worst moment and the recovery path when the session dies. Compare regreet (GTK, themeable to the palette) vs a tuigreet-styled minimal option. VIEW previews. Recommend.

4. SYSTEM HEALTH (B13). A tiny watcher that converts silent systemd failures into legible events: "a background service failed (watchdog restarted it)" with the journal excerpt one click away. Source: systemd OnFailure= hooks or a QuickShell DBus watcher. Pairs with notification history.

5. BACKUP (B14). One decision: restic vs borgmatic to an external disk or cloud target, scheduled, with a status line in Settings › System. Compare the two for a single-laptop personal-data backup (~/Documents, wallpapers, project repos, ~/.local/state). Recommend.

6. EMOJI / SPECIAL CHARS (B15). A mouse-reachable emoji/special-char surface (iNiR's launcher has an emoji prefix — sourced; add a System-group or launcher-mode button + a hotkey, Win+. / Cmd+Ctrl+Space reflex) AND verify a color emoji font (Noto Color Emoji) is installed system-wide so terminals/GTK apps don't show tofu (Chrome bundles its own; the rest of the OS doesn't).

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community solutions, small glue only.
3. Full reads of any shell/agent/greeter repo involved.
4. Visual verification mandatory — VIEW Nexus/polkit/greeter previews before recommending.
5. No diagnostics, no execution, no code-writing on the machine. Flag keyring-auto-unlock and font-tofu checks as execution-time live-tests.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §0/§6/§4.17 and B7/B8/B12/B13/B14/B15.
8. Bonus finds flagged.
9. Honesty: end with "What I actually read/viewed vs what I didn't." State the Nexus-extractability verdict plainly.

OUTPUT to ~/nix/research/settings-dialogs.md: Settings-center Nexus verdict + page inventory + ship order · Polkit/keyring theming · Greeter/logout recommendation · System-health watcher · Backup restic-vs-borgmatic · Emoji surface + font verification · Bonus finds · What I read/viewed vs didn't.
```

---

# Session 9 — File Management & Dialogs

**Purpose.** Settle the file-management experience — the daily surface still carrying two contradictory positions. Covers **A6** (Thunar vs Nemo vs Nautilus, full daily-use criteria), **B10** (archive opener), **B9** (file-picker portal backend), and the **§4.13** desktop + file-manager right-click context menus (added in the GAP_REVIEW sweep-check as a small dev item).

**In scope:**
- **A6 file manager:** a real visual + functional comparison of themed **Thunar** vs **Nemo** vs **Nautilus** against daily-experience criteria no doc has listed: undo of file operations, tabs, bulk rename, in-manager search, archive integration, device-eject affordance, thumbnails — not just looks. The overhaul effectively decided Thunar (Nautilus drags a filesystem indexer onto 2-core/8GB; Nemo drags cinnamon deps); MASTER still asks for the comparison. Run it and pick, or ratify Thunar with evidence. Target look: modern dark-glass-adjacent (agridyne/saatvik333 explorer references; "dark glass, a bit too dark" was the prior favorite).
- **B10 archives:** pick + configure an archive opener — `file-roller` (GTK, integrates with Thunar) vs Thunar archive plugin + `xarchiver`; extract-here contextual action beats an archive-browser for most users. Double-clicking a `.zip` must do something sane.
- **B9 portal:** which xdg-desktop-portal backend serves the file chooser (`-gtk` vs `-hyprland` per interface), whether it's dark/themed, remembers last directory, shows Recents; theme it with the §4.17 GTK work; the Chrome upload/save flows are the daily moment (test = execution-time). Drag-and-drop onto the picker / into the page.
- **§4.13 right-click:** the **file-manager** context menu is native to the chosen manager (config/theming); the **desktop** right-click menu (on the wallpaper root → new-terminal / change-wallpaper / display-settings) is unsourced in all five repos → a small QuickShell desktop-layer context-menu dev item; source the pattern (share the component with the file manager where possible). Taskbar/tray context menus are already sourced (caelestia/iNiR) — do not re-research.

**Out of scope:** the palette/GTK theming architecture (sourced in SYNTHESIS); UDisks automount *testing* (execution-time; identify `udiskie` vs file-manager-native as the mechanism only); building anything.

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§4.1, §4.12, §4.13, §4.17, §6 File manager); `~/nix/research/GAP_REVIEW.md` (A6, B9, B10, and the §4.13 addendum entry); `~/nix/research/SYNTHESIS.md` (File manager + Removable media + Right-click sections); `~/nix/research/caelestia.md`, `~/nix/research/iNiR.md` (Thunar CSS / toolkit writers).

**Output:** `~/nix/research/file-management.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland + QuickShell build on a 2020 T2 MacBook Air (dual-core i3, 8GB RAM — a filesystem indexer is a real cost here). GTK theming (19 GTK3 named colors + 4 libadwaita root vars) is already sourced. You research file-management solutions and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §4.1 file associations, §4.12 removable media & trash, §4.13 right-click everywhere, §4.17 app theming, §6 File manager (Thunar vs Nemo vs Nautilus; modern dark-glass-adjacent; thumbnails, trash, automount).
- ~/nix/research/GAP_REVIEW.md — A6 (file manager — stop carrying two positions; daily-use criteria listed), B9 (file-picker portal), B10 (archives), and the "§4.13 — ADDED" entry in the Post-review addendum (desktop right-click = small dev; file-manager menu = native; tray/task already sourced).
- ~/nix/research/SYNTHESIS.md — "File manager", "Removable media and trash", "Right-click everywhere" sections.
- ~/nix/research/caelestia.md, ~/nix/research/iNiR.md — Thunar CSS/preferences (caelestia) and GTK3/GTK4/libadwaita writers (iNiR).

YOUR TASK:

1. FILE MANAGER (A6) — a real visual + functional comparison of themed Thunar vs Nemo vs Nautilus. Criteria (VIEW previews for looks; check docs/features for function): modern dark-glass-adjacent appearance (agridyne/saatvik333 explorer references; prior favorite was "dark glass, a bit too dark"), working thumbnails, trash semantics, UDisks automount integration, AND the daily-experience items no doc lists: undo of file operations, tabs, bulk rename, in-manager search, archive integration, device-eject affordance. Weigh the 2-core/8GB cost (Nautilus drags a filesystem indexer; Nemo drags cinnamon deps). Either ratify Thunar with evidence or pick a winner — but stop carrying both positions. Rank with reasoning.

2. ARCHIVES (B10). Pick + configure an archive opener so double-clicking a .zip does something sane (extract-here contextual action beats an archive-browser app for most users): file-roller (GTK, integrates with the chosen manager) vs Thunar archive plugin + xarchiver. One decision + the config shape.

3. FILE-PICKER PORTAL (B9). Which xdg-desktop-portal backend serves the file chooser (xdg-desktop-portal-gtk vs -hyprland, per interface), is it dark/themed, does it remember the last directory, does it show Recents. Theme it with the sourced GTK work. The daily moment is Chrome upload + save-as (the actual test is execution-time — flag it). Note drag-and-drop onto the picker / straight into the page.

4. RIGHT-CLICK (§4.13). The file-manager context menu is native to the chosen manager (config/theming — note what it offers). The DESKTOP right-click menu (right-click the wallpaper root → new-terminal / change-wallpaper / display-settings) is unsourced in all five prior repos — source a QuickShell desktop-layer context-menu pattern (share the component with the file manager where sensible) and specify the minimal glue. Do NOT re-research taskbar/tray menus — already sourced (caelestia Tray*.qml / iNiR dock context menus).

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community solutions, small glue only.
3. Full reads of any file-manager/portal/plugin docs involved.
4. Visual verification mandatory — VIEW file-manager previews before ranking.
5. No diagnostics, no execution, no code-writing. Identify the automount mechanism (udiskie vs native) but flag the §4.12 USB test as execution-time.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §4.1/§4.12/§4.13/§4.17/§6 and A6/B9/B10.
8. Bonus finds flagged.
9. Honesty: end with "What I actually read/viewed vs what I didn't." State the file-manager pick plainly with its trade-offs.

OUTPUT to ~/nix/research/file-management.md: File-manager comparison + pick · Archive opener decision · Portal backend + theming · Right-click (desktop dev + file-manager native) · Bonus finds · What I read/viewed vs didn't.
```

---

# Session 10 — Wallpaper Pipeline

**Purpose.** Close the small verify-questions left around the DECIDED wallpaper picker. skwd-wall is final (§15); this session answers only the open sub-questions: does it handle **transitions** natively (awww redundancy), the `SliceDelegate` compat, and the palette-generator capabilities. Covers **A4** (the verify carried forward), the **awww** relationship, generator options (**gowall/hellwal** — accepted fallbacks, capabilities to document), and **C10** (auto-cycling).

**In scope:**
- **A4 verify:** open **liixini/skwd-wall** fully, VIEW its preview videos, and determine whether it performs wallpaper **transitions** itself. If it does, **awww may be redundant for the picker flow** — state clearly what awww is still needed for (auto-cycling / non-picker changes) vs where skwd-wall covers it.
- **SliceDelegate compat:** confirm the "vendor `SliceDelegate.qml`, one-line change frees it from its Rust daemon" claim against the actual repo; state the exact change.
- **awww relationship:** the `awww kill` daemon conflict is a known compat edit — document what awww is and the minimal patch so it and skwd-wall coexist (systemd won't restart it as-is).
- **Generators:** document capabilities of **gowall** (Achno/gowall — recolors wallpapers toward a palette; the inverse approach) and **hellwal** (the accepted palette-generation fallback if Matugen stays problematic). Matugen's `custom_colors` silent-discard is an accepted finding whose *version verification* is execution-time — do not try to verify it live; just note the fallback chain.
- **C10 auto-cycling:** daily/interval shuffle through the curated collection using the atomic apply pipeline (which makes it safe by construction) + the optional evening "prefer darker wallpapers as night light engages" variant. One timer + policy — source the pattern.

**Out of scope:** the atomic apply *transaction* (SYNTHESIS keeps the existing apply-wallpaper stager — extend its consumer list at plan time); the palette *token architecture* (sourced); verifying Matugen on the installed version (execution-time).

**Read list:** this block; `~/nix/MASTER_REQUIREMENTS.md` (§6 Wallpaper system, §5 Visual wallpaper-switcher, §15 wallpaper decision); `~/nix/research/GAP_REVIEW.md` (A4 + the A4 resolution in the addendum); `~/nix/research/SYNTHESIS.md` (Wallpaper picker/transitions/apply-pipeline section); `~/nix/research/iNiR.md` (AwwwBackend.qml, generator flow).

**Output:** `~/nix/research/wallpaper-pipeline.md`.

**Ready-to-paste prompt:**

```
You are a targeted research session for a NixOS + Hyprland + QuickShell build on a 2020 T2 MacBook Air (dual-core i3, Iris Plus, 8GB RAM). The wallpaper PICKER is already decided: liixini/skwd-wall is final (use as-is + compat only — it looks beautiful, no rewriting). You research the remaining pipeline sub-questions and write findings to a file. You do not plan, execute, write config, run diagnostics, or touch the machine.

READ FIRST:
- ~/nix/MASTER_REQUIREMENTS.md — §6 "Wallpaper system" (skwd-wall as-is + compat; SliceDelegate one-line change; awww for transitions; Matugen IF verified else hellwal fallback; gowall as inverse; atomic apply), §5 Visual (wallpaper switcher jank), §15 (skwd-wall FINAL; VERIFY it may handle transitions itself — if so awww may be redundant in the picker flow, still possibly useful for auto-cycling).
- ~/nix/research/GAP_REVIEW.md — A4 and its resolution in the Post-review addendum.
- ~/nix/research/SYNTHESIS.md — the "Wallpaper picker, transitions, and apply pipeline" section.
- ~/nix/research/iNiR.md — its AwwwBackend.qml and validated generated-contract flow.

YOUR TASK — close the small open sub-questions around the decided picker:

1. TRANSITIONS VERIFY (A4). Open liixini/skwd-wall fully and VIEW its preview videos. Does skwd-wall perform wallpaper TRANSITIONS itself (crossfade/animation on wallpaper change)? If yes, awww may be REDUNDANT for the picker flow — state exactly what awww would still be needed for (auto-cycling / non-picker changes) vs what skwd-wall covers. If no, confirm awww remains the transition layer. Answer from what you SAW in the previews, not inference.

2. SLICEDELEGATE COMPAT. Confirm the "vendor SliceDelegate.qml + a one-line change frees the picker from its Rust daemon" claim against the actual repo. State the exact file and the exact change.

3. AWWW RELATIONSHIP. Document what awww is and the known daemon conflict (skwd-wall's daemon `awww kill`s ours in a way systemd won't restart). Give the minimal compat patch so awww and skwd-wall coexist.

4. GENERATORS. Document capabilities (from repos/docs) of: gowall (Achno/gowall — recolors a wallpaper TOWARD a palette, the inverse approach) and hellwal (the accepted palette-generation fallback if Matugen stays problematic). Do NOT try to verify Matugen on the installed version — that's execution-time; just lay out the fallback chain (Matugen-if-verified → hellwal) and where gowall fits as an optional inverse mode.

5. AUTO-CYCLING (C10). Source the pattern for daily/interval wallpaper shuffle through the curated collection using the existing atomic apply pipeline (safe by construction) + the optional evening variant (prefer darker wallpapers as night light engages). One timer + policy.

RULES —
1. Licensing is not a constraint and is never mentioned.
2. Never build from scratch; adapt community implementations, small glue only.
3. Full reads of skwd-wall and the generator repos.
4. Visual verification mandatory — VIEW skwd-wall's transition previews before answering the transitions question. This is the crux.
5. No diagnostics, no execution, no code-writing. Do not verify Matugen live — flag it as execution-time.
6. Write to your output file; report incrementally.
7. Cross-reference MASTER_REQUIREMENTS.md; map to §6/§5 and A4/C10.
8. Bonus finds flagged.
9. Honesty: end with "What I actually read/viewed vs what I didn't." The transitions answer must be from viewed previews — say so.

OUTPUT to ~/nix/research/wallpaper-pipeline.md: Transitions verdict (from viewed previews) + awww redundancy · SliceDelegate exact compat change · awww coexistence patch · Generator capabilities + fallback chain · Auto-cycling pattern · Bonus finds · What I read/viewed vs didn't.
```

---

## No-session list — accounted for, but not research

Everything below is config-work, already-resolved by a decision, plan-time composition, a plan-time design artifact, or deferred. It flows to the **L3 plan session**, not to research. Listed so nothing silently vanishes.

**Resolved by §15 / prior decisions (→ plan-time composition, sourcing already exists):**
- **A1 bar ownership** — DECIDED QuickShell. All §6 Top-bar work is QuickShell composition (SYNTHESIS: iNiR zones + ilyamiro geometry + caelestia tray + agridyne islands). **D3** collapses to its QuickShell branch.
- **D1 panel coordinator** — KEEP the existing PanelCoordinator/PanelHost *only if it wins a comparison* (§15 "not sacred") — a plan-time comparison, not research.
- **D2 music/EQ composition** — deferred to plan (staged upgrades vs new composition is a plan call). The donor pieces are all sourced (ilyamiro EQ + caelestia MPRIS/cava/lyrics + iNiR cava lifecycle + Kurve strip).
- **D4 network donor correction** — use the overhaul's noctalia SystemStatService pattern, not caelestia's buggy NetworkUsage.qml (stale-read + 2^64 wraparound). Plan-time file choice.
- **D5 notification semantic filter** — sourced UI (caelestia) + iNiR ingress caps; the routine-event filter is acknowledged bespoke glue, budgeted at plan.
- **D6 → Session 2** (reframed to an open comparison — no longer a no-session item).
- **D7 glass numbers** — reconcile via one `hyprctl eval` A/B at execution (overhaul's evidence-graded values win: ignore_alpha 0.10, xray tunable, size 8/two passes as the fallback from size 12/one pass). Execution-time A/B, not research.
- **Process/monitor workspace** — mostly decided (overhaul btop-on-workspace-2). Integration/plan, not research.
- **Kitty Ctrl+Shift+T** — impossible as specified; the reopen-FILES intent moves to the dev workspace (Session 5).

**Config-class (→ plan/execution, no sourcing needed):**
- **XDG MIME / default-app map** (§4.1) — write `mimeapps.list` via Home Manager; surfaced in Settings › Default apps (Session 8 page inventory). The app *choices* ride §13.
- **CUPS + HPLIP printing** (§4.14) — `services.printing` + hplip + test page.
- **VA-API for Chrome** (accepted finding, §9; C16c) — four Nix lines; ship in the first stage. Biggest silent battery win.
- **Chrome polish pack** (C16a/b) — two-finger back/forward flag (`TouchpadOverscrollHistoryNavigation` on Ozone); PiP window rules (float/pin-above/no-border/persistent).
- **Weather → Austin** (§5) — coordinates fix; collapse the 4 duplicated definitions.
- **Screenshot purple film** (§5) — one-line slurp `-s` selection-fill fix; capture via grim after geometry.
- **Cmd+Shift+S / Print bindings**, **Kitty Ctrl+T**, **Cmd+Space → launcher** — keymap config (owners sourced).
- **System sounds** (§4.9) — freedesktop sound theme + libcanberra + a small hook in the notification service; toggleable. (Borderline — if the "who plays events under Hyprland" question needs sourcing, fold a paragraph into Session 6; otherwise config.)
- **USB automount/trash** (§4.12) — `udiskie` (or file-manager-native, decided in Session 9) + the §4.12 test at execution.
- **Micro-status language** (C17), **screen-share auto-DND** (C15), **accessibility toggles / cursor zoom** (C19) — policy/config once the underlying services exist.
- **Color picker** (C9) — `hyprpicker` + auto-copy hex + toast; trivial config in the System group.
- **Nix generation cleanup** (§15) — delete gens 1–7 now; post-acceptance wipe — execution action; the *policy* is designed in Session 6 (B6).
- **Glass alpha fix, palette-slot architecture, EasyEffects service-mode + XDG preset path, detached launches, motion vocabulary, diffuse-aurora gradient (ML4W CSS technique)** — all root-caused/sourced (§9 + SYNTHESIS); plan/execution.

**Already sourced C-items (→ plan inclusion, generous per §15):**
- **C6 OCR** (iNiR capture-OCR — tesseract "Copy text" mode), **C8 lyrics** (caelestia lyrics service — toggle in expanded music widget), **C11 desktop widgets** (iNiR edit-mode — restrained, two widgets), **C12 FocusTime** (ilyamiro SQLite analytics — opt-in) — all sourced; the plan places them.
- **C20 calendar ICS read-only** — sourced pattern (build-plan Phase 3 ICS/CalDAV); needs the user's Google Calendar secret ICS URL as a config input.

**Plan-time design artifact (not research):**
- **B18 widget/element placement map** — the one-page "where every control lives / what triggers it / compact vs expanded / which surface owns it" map. Produce at the *start* of L3 (before the twenty small placement debates), using the proposed principle: *bar right = status that changes; System button = actions you take (capped ~6); Settings = anything you configure; launcher = everything by name.*

**Deferred (§15 security & diagnostics — no session touches these):**
- **B16 clipboard-history privacy policy** (sensitive-type exclusion, expiry) — the base cliphist+UI is sourced and NOT deferred; only the privacy policy waits.
- **WiFi-password-argv fix** — use the safe credential API when composing the network panel; the hardening framing is deferred.
- Any standalone system-hardening / health-diagnostic effort.

**Needs a user decision before it can be scoped (flagged — see report):**
- **C7 KDE Connect** — scope depends entirely on whether Alex's phone is Android (full: notifications/files/clipboard/media) or iPhone (files/clipboard only, no notifications). Ask before investing panel work.
- **C18 Tailscale/VPN slot** — worth it only if there's a second machine (home box / remote agent target) that matters. Ask before adding the network-panel slot.

---

## Run order (rationale)

**Tier 1 — run first, blocks the most planning:**
1. **Shell Surfaces** — two of the three major shell surfaces (dock, sidebar) + the launcher packaging decision. The most downstream-blocking single session; also settles the canonical contested claim.
2. **Lock Screen** — a distinctive full-surface decision reopened by §15; independent of the shell surfaces, high visual stakes.
3. **Window Management, Input & Gestures** — the core §2 interaction model (per-window controls, drag-to-workspace, gesture map) plus the daily input bugs; touches the bar/window UX the plan builds on.

**Tier 2 — high value, largely independent:**
4. **Hardware, Drivers & Boot** — trust-critical (webcam, boot) and mostly independent web-research; can run in parallel with Tier 1 if you have the bandwidth.
5. **Dev Experience & Workspace** — the §7 major requirement; self-contained.

**Tier 3 — fill-in, lower coupling:**
6. **Daily Guardrails** · 7. **App Lifecycle** · 8. **Settings Center & Dialogs** (consumes App Lifecycle's update mechanism, so run after 7) · 9. **File Management** · 10. **Wallpaper Pipeline**.

Sessions **4, 9, 10** have no dependency on the others and may be slotted in whenever convenient.
