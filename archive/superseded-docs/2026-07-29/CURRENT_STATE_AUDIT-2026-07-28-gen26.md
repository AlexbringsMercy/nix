# Aurora Current-State Audit

**Timestamp:** 2026-07-28 (session date). Machine RTC is skewed — see §22.
**Machine:** `macbook` — 2020 MacBook Air, Apple T2, Intel i3 dual-core, 8 GB, 2560×1600 @ 1.5 (1707×1067 logical). Kernel `6.18.35` (`linux-t2`).
**Repository:** `/home/alex/nix` → `github.com/AlexbringsMercy/nix`
**Branch / HEAD:** `codex/macbook-desktop` @ `6486742` — clean tree, 0 ahead / 0 behind `origin/codex/macbook-desktop`
**Running generation:** **26** (`/nix/store/92bdqiipmfazicpi1b1vy4hbn77wf33r-nixos-system-macbook-…`)
**Default boot generation:** **26** — same store path; booted == current == profile default
**Overall stage verdict:** Stage 0 **accepted**. Stage 1 **accepted (with deferrals)**. Stage 2 **conditional pass, not closed** — three non-negotiable items unresolved. Stage 3 **not started**.

---

## 1. Executive Summary

The machine is running the Aurora architecture: `aurora-shell.service` supervises the vendored caelestia chassis under QuickShell, Hyprland 0.55.4 native-Lua, hyprbars titlebars with the hover patch. Waybar, Rofi, SwayOSD and the old custom QuickShell trees are gone as *modules* and none of them is running. The July 16 Waybar-era section of `EXECUTION_LOG.md` describes a dead architecture and must not be read as current.

Five findings materially change the picture the previous handoff left:

1. **The machine has rebooted into gen 26.** `PM_HANDOFF.md` says "gen 25 booted, gen 26 staged boot-only and NEVER TESTED." Ground truth contradicts it: `/run/current-system`, `/run/booted-system` and `/nix/var/nix/profiles/system` all resolve to the gen 26 store path. The Stage 2D half-snap rework is therefore **activated**, not staged — but there is no record of Alex live-testing it, so it sits in "activated, not live-tested."

2. **The drag-anchor patch is written and committed but was never built.** Proven by derivation hash, not inference: the patched derivation `bkjrfi08…` references `hyprland-drag-anchor.patch` and would output `azvhdgfz…-hyprland-0.55.4`; that path **is not valid in the store**. The running compositor `rv2dda5…` comes from derivation `kpzvdhci…`, which contains **no** patch reference. Both gen 25 and gen 26 reference the unpatched output. Stale `.lock` files and a `.drv.chroot` timestamped 2026-07-22 11:47 mark exactly where the build died.

3. **The DWT root cause is confirmed on the live machine and the fix does not exist anywhere in the repo.** `udevadm info /dev/input/event7` reports `ID_INPUT_TOUCHPAD_INTEGRATION=external`; libinput reports `Disable-w-typing: n/a`. There is no `services.udev.extraHwdb` and no `TOUCHPAD_INTEGRATION` string in any `.nix` file in the tree. `input.lua:15` sets `disable_while_typing = true` — an inert no-op.

4. **Corner resize has no implementation and no research artifact.** The tree contains exactly two patches: `hyprland-drag-anchor.patch` and `hyprbars-hover.patch`. Decision #11 reopened corner resize as non-negotiable on 2026-07-22; nothing has been written since.

5. **Stage 3 has not begun.** No `topbar`/`taskbar` module exists anywhere under `modules/`. The interrupted mapping session produced no output artifact — its event stream is 92 lines ending mid-file-read, and there is no `stage3prep-final.md`.

The single next coherent execution batch is therefore unchanged from what the previous PM queued, with one item now cheaper than believed (gen 26 is already live): **build the drag patch, implement the DWT hwdb entry, patch hyprbars for corner resize — one build, one staged boot, one reboot, then Alex re-tests the whole Stage 2 surface including the already-live half-snap rework.** Stage 3 stays blocked until that gate closes.

---

## 2. Authority and Evidence Used

Applied in the order the audit brief specifies. Where sources conflicted, the winner is named inline in §17.

| Rank | Source | How it was used |
|---|---|---|
| 1 | Direct machine evidence | `readlink -f` on system/booted/profile links; `nix path-info` validity checks; `nix derivation` / raw `.drv` text greps; `systemctl --user show`; `hyprctl version/plugin list/configerrors`; `udevadm info`; `libinput list-devices`; `pgrep`; `/proc/<pid>/cgroup`; `diff` of live HM symlink targets against repo files |
| 2 | Git repository | `git log/branch -vv/status --porcelain -uall/worktree list/stash list/merge-base/rev-list`; commit timestamps correlated against generation mtimes |
| 3 | Latest `EXECUTION_LOG.md` entries | Stage 0 (l.776) → close-out (l.1320) read in full |
| 4 | `GRAND_PLAN.md` | Read in full (706 lines) — §0, §2, §3, §5, §6, §8, §9, §10, §12 |
| 5 | `MASTER_REQUIREMENTS.md` | Read in full (292 lines) |
| 6 | Older `EXECUTION_LOG.md` | July 16 handoff section read at l.131–200 and l.742–775 to characterise the superseded era |
| 7 | Planning/provenance files | `SESSION_PREAMBLE.md`, `PM_HANDOFF.md`, `SOURCES.md` (head) |

**Discipline note (`SESSION_PREAMBLE.md` §4):** every hypothesis in the audit brief's §5 was re-derived from primary evidence. Nothing was inherited. Where a claim could not be proven, it is recorded as unproven rather than assumed — see §22.

---

## 3. Repository State

| Fact | Value |
|---|---|
| Working directory | `/home/alex/nix` |
| Branch | `codex/macbook-desktop` |
| HEAD | `6486742ead4f1fbed930db9cc0b41fcbf413355d` |
| Upstream | `origin/codex/macbook-desktop` |
| Remote | `https://github.com/AlexbringsMercy/nix` (fetch + push) |
| Ahead / behind | `0 0` (`git rev-list --left-right --count`) |
| `git status --short` | *empty* |
| Untracked (`-uall`) | *none* |
| Stash | *empty* |
| Worktrees | one — `/home/alex/nix` only |
| Branches | `codex/macbook-desktop` (checked out), `main` @ `4974921`, plus the two remote-tracking refs |
| Interrupted operations | none — no `MERGE_HEAD`, no `rebase-merge`/`rebase-apply`, no `CHERRY_PICK_HEAD`, no `index.lock` |

**The tree is pristine.** No uncommitted execution work exists, no work is hiding on another branch or worktree, and the four governing documents (`GRAND_PLAN.md`, `MASTER_REQUIREMENTS.md`, `SESSION_PREAMBLE.md`, `EXECUTION_LOG.md`) are the checked-out branch's versions.

### Commit graph, Stage 0 → HEAD

```
6486742  2026-07-22 12:36  pm: handoff brief for next session
df37152  2026-07-22 11:45  stage2: carry tiled-drag grab-anchor patch for Hyprland 0.55.4
58692ba  2026-07-21 22:59  fix(stage2d): drag animation off permanent; half-snap decoration-aware + release path
c709a8f  2026-07-21 21:52  feat(stage2c): half-snap on bare Super+arrows + T2 DWT quirk; decisions register
262472b  2026-07-21 19:52  fix(stage2b): scroll 0.6, brightness on caelestia OSD, drop broken volume gesture
29fedce  2026-07-21 19:23  feat(stage2b): Cmd+Space launcher, retire SwayOSD, input tuning, shell.json writable
498e018  docs(stage2a): window-model close-out + hover-crash lesson
345f47b  feat(stage2a): hyprbars button hover state (patched plugin) + size 24
8fea3d4  fix(stage2a): convert hyprbars/minimize/snap actions to 0.55 native-lua dispatch
d47ae38  fix(stage2a): snap on bare Super+arrows (Windows-style) per operator
f8ca332  feat(stage2a): window model — hyprbars, real omarchy minimize, focus/snap/ws1-5
7a0d927  fix(stage1): relax the aggressive idle-lock to 20 min; no auto-suspend
ceca7a4  fix(stage1): retire duplicate tray applets; log the Stage 1 gate outcome
d87090e  fix(stage1): drop unused Plex; resume agent skips permission prompts
c72b564  docs(stage1): 1C cutover close-out + session prompt
18b5182  feat(stage1c): cutover — enable aurora-shell, retire old trees, seed scheme
89ee6d8  docs(pm): handoff brief + kickoff prompt for incoming PM session
3044e5e  docs(stage1): 1B close-out
9f64c36  feat(stage1b): aurora scheme defaults — pinned ladder, dark identity, accent families
9fb8a88  docs(stage1): 1A close-out + 1B scheme session prompt
4b768fe  fix(stage1a): merge packages attrset — dynamic attrs cannot be defined twice
f0dbbf5  chore(stage1a): lock aurora-shell subflake inputs
ccdecef  feat(stage1a): wire aurora-shell into the parent flake as a path input
b56b87d  docs(stage1a): attribution headers across the vendored chassis
966de79  feat(stage1a): vendor caelestia shell as the aurora-shell chassis (verbatim snapshot)
e72d55f  docs(stage1): codex session prompt — 1A vendor chassis
47269fb  docs(stage0): close-out — gate passed
eb09b64  fix(stage0): resume loop — start in the trusted home project, hold the window
c76d6b3  feat(stage0): build harness — scoped NOPASSWD deploy verbs + armed resume loop
fc40c9f  fix(stage0): restore xdg-utils parity; make build-plan symlink relative
```

### `df37152` — verified, not taken on trust

`git merge-base --is-ancestor df37152 HEAD` → **true**. Its actual content was inspected rather than its message:

- `modules/nixos/patches/hyprland-drag-anchor.patch` (1192 bytes) — a single hunk in `src/layout/supplementary/DragController.cpp`, replacing the centre-under-cursor placement with a normalized grab anchor captured before `changeFloatingMode` and re-applied against the post-float size. Isolation matches the log's claim: nothing outside `if (m_dragThresholdReached)` is touched.
- `flake.nix` — `hyprlandOverlay` applied to **both** eval paths: `homePkgs` (for `homeConfigurations.alex`) and the `nixpkgs.overlays` module inside `mkMacbook` (for `nixosConfigurations.macbook`). Verified by reading the file, not by grep.

**Commits after `df37152`:** exactly one — `6486742`, which adds `PM_HANDOFF.md` and `PM_KICKOFF_PROMPT.md` and touches no configuration.

---

## 4. Running System State

| Fact | Value |
|---|---|
| `/run/current-system` | `/nix/store/92bdqiipmfazicpi1b1vy4hbn77wf33r-nixos-system-macbook-26.11.20260616.567a49d` |
| `/run/booted-system` | **same path** |
| `/nix/var/nix/profiles/system` | `system-26-link` → **same path** |
| Running generation | **26** (created 2026-07-21 23:03:06) |
| Next-boot generation | **26** — booted, current and default all agree; no divergence |
| Generations present | 8–26 (1–7 deleted in Stage 0; 15 retained as the channel-lineage rollback anchor) |
| Kernel | `6.18.35 #1-NixOS SMP PREEMPT_DYNAMIC` |
| Hyprland | 0.55.4, commit `a0136d8c04687bb36eb8a28eb9d1ff92aea99704`, ABI `…_aq_0.12_hu_0.13_hg_0.5_hc_0.1_hlg_0.6` |
| QuickShell | `quickshell-wrapped-0.3.0` |
| Hyprland config errors | **0** |
| Loaded plugins | **hyprbars only** (by Vaxry, v1.0) |
| Failed system units | **0** |
| Failed user units | **0** |
| Home Manager | **integrated via NixOS** — `nixos-activation.service` (user) active; live HM file store is `xvkd65lwpqibq5hmml7c8cr98hbayaf1-home-manager-files` |

**Standalone HM profile is stale and irrelevant.** `~/.local/state/nix/profiles/home-manager` still points at `home-manager-3-link` from 2026-07-16. That is the pre-Stage-0 standalone lineage; it is not what activates today. Anyone diffing against it will be reading the Waybar era.

### `aurora-shell.service`

```
FragmentPath   /home/alex/.config/systemd/user/aurora-shell.service
ActiveState    active   SubState  running
MainPID        1741
ExecStart      /nix/store/nx8375sxz5zw7ylp68q649jicfqjyyv4-caelestia-shell-1.0.0/bin/caelestia-shell
KillMode       process
```

Unit file confirms the full §2.2 hardening: `KillMode=process`, `SuccessExitStatus=143`, `LimitCORE=0`, `Restart=on-failure`, `RestartSec=5s`, `StartLimitBurst=3` / `StartLimitIntervalSec=30`, `OnFailure=aurora-notification-fallback.service`, `PartOf=graphical-session.target`.

PID 1741's cgroup is `…/session.slice/aurora-shell.service` and its command line is `quickshell -p /nix/store/nx8375sxz5zw7ylp68q649jicfqjyyv4-caelestia-shell-1.0.0/share/caelestia-shell`. Memory 2.8 G (peak 3.9 G) — worth watching on an 8 GB machine, but note the cgroup also contains a Chrome tree, because `KillMode=process` deliberately leaves detached children parented here. That is the designed behaviour, not a leak.

**Naming note for future sessions:** the *unit* and the *module option* are `aurora-shell`; the *package and binary* are still `caelestia-shell`. Log entry 1C states this explicitly ("only namespace + unit name flipped"). Seeing `caelestia-shell` in a process list is **not** evidence that the fork was reverted.

### Retired-architecture check

| Component | Unit present? | Process running? |
|---|---|---|
| Waybar | no | **no** |
| Old custom QuickShell shell unit | no | **no** |
| Rofi service glue | no | **no** |
| SwayOSD | no | **no** |
| awww | no | **no** |
| Waypaper | no | **no** |
| Dunst (`aurora-notification-fallback`) | yes — `linked`, **inactive** | no — correct (failure fallback only) |

Only expected processes are live: `start-hyprland` / `Hyprland` (PID 1693/1696), the shell (1741), `xdg-desktop-portal-hyprland`, `power-profiles-daemon`. `hypridle.service` is active.

**Caveat — the retired packages are still installed.** `modules/home/packages.nix` still lists `awww`, `dunst`, `rofi`, `waybar`, `waypaper`, and `modules/home/hyprland/default.nix` still builds a `rofi-toggle` wrapper. `modules/home/theming/` still ships matugen templates for `waybar.css`, `rofi.rasi` and `dunstrc`. None of it runs or is wired to anything. Log entry 1C flagged this as transitional and assigned the sweep to Stage 2; **the sweep did not happen.** It is cosmetic dead weight, not a functional regression — but it is unfinished Stage 2 scope, tracked in §11.

---

## 5. Stage Completion Matrix

Legend: **Y** = yes · **P** = partial · **N** = no · **—** = not applicable at this stage.

| Stage | Planned | Written | Built | Installed | Activated | Live-tested | Accepted | Evidence |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| **0** — Reconcile & baseline | Y | Y | Y | Y | Y | **P** | **Y** | Gens 16→17 deployed; gens 1–7 deleted (earliest link is `system-8-link`); gen 15 anchor present; pushed. Log l.855–881 records GATE PASSED. TV + Xbox physical checks were *deferred, not run* — §6. |
| **1** — Chassis up | Y | Y | Y | Y | Y | Y | **Y (with deferrals)** | `modules/home/aurora-shell/` = 451 files; `programs.aurora-shell.enable = true`; unit hardened and running; gens 18→19; log l.981–1007 records the gate ran with Alex live. Glass A/B and palette completeness explicitly deferred to Stage 4. |
| **2** — Window model | Y | **P** | **P** | **P** | **P** | **P** | **N** | Conditional pass (log l.1203). 2A/2B/2C/2D landed and are live in gen 26; drag patch written-not-built; DWT fix not written; corner resize not started. Full breakdown in §8. |
| **3** — Top taskbar + expanded panels | Y | **N** | N | N | N | N | N | No `topbar`/`taskbar` module anywhere under `modules/`. Only the mapping *prompt* exists (`codex-prompts/stage3-taskbar-mapping.md`); the mapping session died with no output. §9. |
| **4** — Wallpaper & theme pipeline | Y | N | N | N | N | N | N | No skwd-wall flake input in `flake.nix`; no `SkwdBridge`; matugen tree still the Stage-1 leftover. Caelestia's own `background` module still renders the wallpaper, as 1C planned. |
| **5** — Rail dock + desktop layer + clipboard + polkit + switcher | Y | N | N | N | N | N | N | No dock entry, no clipboard panel, no polkit module graft in the tree. |
| **6** — Files & apps | Y | N | N | N | N | N | N | No `apps.nix`; no Dolphin module; `keybinds.lua:3` still launches `thunar`. |
| **7** — Boot & lock | Y | N | N | N | N | N | N | No Plymouth, no regreet, no composite lock. `modules/home/lock` is the pre-Grand-Plan Hyprlock tree; `Super+L` still execs `hyprlock`. |
| **8** — Dev workspace & agents | Y | N | N | N | N | N | N | No `agent.slice`, no `special:dev` toggle, no zellij wiring in the tree. |
| **9** — Guardrails & Nexus completion | Y | N | N | N | N | N | N | No `services.restic` anywhere in the repo; no health template unit; no Nexus new pages. |
| **10** — Hardware truth & polish | Y | N | N | N | N | N | N | Not started. |

Stage 2's row is **P** in four columns because the stage is genuinely mixed: most of it is activated on the running machine, and three named items are not. Collapsing it to a single verdict would be the exact error this audit exists to prevent.

---

## 6. Stage 0 Audit

Gate definition: `GRAND_PLAN.md` §10 Stage 0 — commit the uncommitted work, set upstream and push, port the channel config, reboot clean, resolve or root-cause the `start-hyprland` warning, TV reachable, controller paired, delete gens 1–7.

| Item | State | Evidence |
|---|---|---|
| Flake as sole authority | **Accepted** | Parity sweep recorded at log l.797–809; `/etc/nixos` retained read-only per MASTER §10. Deploys route through `~/.config/nixos-local` (machine-local, not in Git). |
| TV firewall rule in flake | **Activated** | `modules/nixos/media-center.nix` carries the MAC-accept rule for `40:2f:86:81:26:3e` in `firewall.extraCommands` / `extraStopCommands`, imported by `hosts/macbook`. Rule text read directly. |
| Media Center / Plex correction | **Activated** | Same file documents Plex removal (2026-07-21, commit `d87090e`) with the reason. Moonfin user-dir stack untouched — `~/.local/share/mediacenter` and `~/.local/bin/mediacenter` both present. |
| Controller tuning preserved | **Activated** | `modules/nixos/desktop.nix:56` — `hardware.bluetooth.settings.LE` = MinConnectionInterval 7 / Max 9 / ConnectionLatency 0, with the Xbox rationale in-comment. |
| Firmware wrapper preserved | **Activated** | `/etc/nixos/firmware/brcm` present, **163 files** — matches MASTER §10 exactly. Supplied via the non-Git wrapper flake. |
| t2fanrd preserved | **Activated** | Input in `flake.nix:9`, module at `modules/nixos/laptop-power.nix:21`. `systemctl is-active t2fanrd` → **active**. `/etc/t2fand.conf` shows `low_temp = 50`, `high_temp = 75`, `speed_curve = "linear"` — Alex's tuned 50/75 curve, verbatim. |
| VA-API configuration | **Activated** | `modules/nixos/desktop.nix:51` — `hardware.graphics.enable` + `extraPackages = [ intel-media-driver ]`. |
| Git upstream / push | **Accepted** | Upstream set, 0/0 with origin. |
| Generations 1–7 deleted | **Accepted** | Earliest profile link is `system-8-link`. |
| Recovery anchor generation | **Accepted** | `system-15-link` present (2026-07-21 07:28) — the last channel-lineage build, held until the Stage 10 wipe. `docs/recovery.md` present. |
| `start-hyprland` warning | **Root-caused, not fixed — by design** | Root cause at log l.811–817: greetd launches the `start-hyprland` wrapper (`desktop.nix:20`) where the channel launched bare `Hyprland`. Fix is assigned to Stage 7's session-chain rebuild. Log l.865 records the warning was *not observed* on the gen 16 boot. |

### The two Stage 0 items that were never physically tested

`EXECUTION_LOG.md` l.866–871 is explicit, and it is the honest record: **TV-from-couch reachability and Xbox controller pairing were deferred to the Stage 1 gate as formalities, with risk accepted** because the MAC rule was verified inside the live firewall-start script and the BlueZ LE settings plus `/var/lib/bluetooth` were untouched.

Reading forward, the Stage 1 gate entry (l.981–1007) records what *was* tested and **does not mention TV or controller**. So these two acceptance items were deferred once and then silently dropped.

**Verdict: Stage 0's gate is accepted, but two physical acceptances remain owed.** They are inference-backed, not test-backed. They belong in §19 as operator tests, not in the audit as passes. This audit did not retest them (out of scope per the brief).

---

## 7. Stage 1 Audit

| Item | State | Evidence |
|---|---|---|
| `modules/home/aurora-shell/` vendored chassis | **Activated** | 451 files. Top level: `plugin/`, `services/`, `components/`, `modules/`, `utils/`, `nix/`, `assets/`, `shell.qml`, `flake.nix`. `modules/` contains `bar`, `dashboard`, `drawers`, `launcher`, `lock`, `nexus`, `notifications`, `osd`, `session`, `sidebar`, `utilities`, `windowinfo`, `areapicker`, `background` — the full §2.1 fork manifest. |
| `programs.aurora-shell` wiring | **Activated** | `modules/nixos/base.nix:47` — `home-manager.sharedModules = [ inputs.aurora-shell.homeManagerModules.default ]`. `home/alex/default.nix:25–27` — `.enable`, `.cli.enable`, `.settings = { }` (the last deliberately keeps `shell.json` mutable rather than a read-only store symlink). `flake.nix` also wires the module into the standalone `homeConfigurations.alex` path. Both eval paths covered. |
| `aurora-shell.service` hardening incl. `KillMode=process` | **Live-tested** | Unit file read in full — see §4. Log l.986 records `KillMode=process` **proven live**: the shell restarted mid-session and the agent terminal survived. This is the P0 Waybar-cgroup class confirmed dead. |
| Waybar / Rofi / custom-QuickShell module retirement | **Activated (modules)** / **Not done (packages)** | `modules/home/{waybar,rofi,quickshell,wallpaper}` all **absent** — 42 files / 6273 lines deleted in `18b5182`. But `packages.nix` still installs waybar, rofi, awww, waypaper, dunst, and `hyprland/default.nix` still builds `rofi-toggle`. Nothing runs. See §11. |
| Fallback Dunst | **Activated** | `aurora-notification-fallback.service` — `UnitFileState=linked`, `ActiveState=inactive`. Correct: it exists as `OnFailure=` target only. Static `assets/fallback-dunstrc` carried per 1C so it survives the matugen tree's eventual retirement. |
| Aurora fallback palette + mutable `scheme.json` seed | **Activated** | 1B pinned the §3.1 ladder in `Colours.qml` (46 Aurora-marked lines, PM hex-count verified 24/24 unique hexes, 44/44 roles). 1C seeds `~/.local/state/caelestia/scheme.json` write-if-absent via an HM activation, deliberately mutable so Stage 4 can overwrite. |
| Live Aurora shell process | **Activated** | PID 1741, supervised, 0 failed units, 0 configerrors. |
| Gate physically tested | **Yes** | Log l.981: "Stage 1 gate — RAN 2026-07-21 (Alex live)". Gens 18 (boot-only + armed-resume reboot) then 19 (Plex removal via detached switch). |
| Old-architecture process still active | **None** | Verified by `pgrep` and by full user-unit enumeration. |

### Stage 1 issues deliberately deferred (not defects)

Log l.995–1004 assigns each finding forward, and the assignments are consistent with `GRAND_PLAN.md` §10:

- **Palette completeness / quality** → Stage 4. 13 of 54 M3 roles were unpinned, producing a warm-Material clash (ISSUE_LOG §20). Binding direction: accents are wallpaper-derived, "aurora" is one mode, Raycast-deep not generic-hex.
- **Double brightness OSD, launcher keybind, brightness ownership** → Stage 2 (landed in 2B — see §8.2).
- **Top bar + WiFi/BT placement** → Stage 3.
- **Wallpaper + real glass** → Stage 4. Note the live `general.lua` blur is `size 8 / passes 2 / vibrancy_darkness 0.38`, whereas `GRAND_PLAN.md` §3.2's starting point is `size 12 / passes 1 / vibrancy_darkness 0` (with 0 = maximum effect per accepted finding §9). The §3.2 glass A/B gate has **not** been run. This is a known open gate, not drift.
- **Lock polish** → Stage 7.
- **T2 RTC boot-clock skew** (ISSUE_LOG §28) → Stage 7 boot chain. Still live: `systemctl` reports unit start times in 1970 and `uptime` reports "up 20659 days". Cosmetic here, but it means **timestamps from `systemctl`/`uptime` are unreliable evidence on this machine** — this audit used file mtimes and git dates instead.

**Verdict: Stage 1 accepted, with the deferrals above carried forward as scheduled work, not as debt.**

---

## 8. Stage 2 Audit

### 8.1 Window Controls and Focus

| Item | Planned | Written | Built | Installed | Activated | Live-tested | Evidence |
|---|---|---|---|---|---|---|---|
| hyprbars installed and active | Y | Y | Y | Y | **Y** | Y | `hyprctl plugin list` → hyprbars v1.0 loaded, and it is the **only** plugin. Live config symlinks to `…-hyprbars-0.55.0/lib/libhyprbars.so`. |
| Close / maximize / minimize buttons | Y | Y | Y | Y | Y | Y | `hyprbars.lua.in` — three `add_button` calls, right-to-left so screen order is minimize │ maximize │ close. |
| Monochrome operator override | Y | Y | Y | Y | Y | Y | All three buttons `bg_color = rgba(00000000)`, glyph-only, `size = 24`. In-file comment records the override of the plan's "red/yellow/green" wording. Decision #2. |
| Hover patch | Y | Y | Y | Y | **Y** | Y | Running plugin `5n10sci62…` derives from drv `583a4gzi…`, which **contains** `hyprbars-hover.patch`. Log l.1037: operator confirmed hover works and "looks clean." |
| ABI match | Y | Y | Y | Y | **Y** | — | Drv `583a4gzi…` references hyprland drv `kpzvdhci…` and `kccz53zm…-hyprland-0.55.4-dev` — i.e. the *same* unpatched compositor that is running. **ABI is currently consistent.** See §8.4 for why this changes the moment the drag patch builds. |
| Click-to-focus | Y | Y | Y | Y | Y | Y | `input.lua:6` — `follow_mouse = 0`. Kills the hover-mistarget bug by construction (MASTER §5). |
| Focus-on-close | Y | Y | Y | Y | Y | Y | `input.lua:7` — `focus_on_close = 2` (most-recent, macOS-like). |
| Minimize implementation | Y | Y | Y | Y | Y | Y | omarchy `window-minimize` vendored verbatim (`scripts/window-minimize`, attribution in `SOURCES.md`); per-window `special:min-<addr>`, LIFO. `general.lua` sets `misc.close_special_on_empty = true`. Button action + `Super+Down`. |
| Restore path | Y | Y | Y | Y | Y | Y | `keybinds.lua:32` — `Super+Alt+M` → `window-minimize restore`. Plus the shell's workspace switcher (currently the only *visible* path). |
| Special minimized-workspace visibility + Stage 3 filter deferral | Y | **Prompt only** | N | N | N | — | The 1-line filter is drafted in `codex-prompts/stage2a-hide-min-workspaces.md` and **deliberately not deployed**: log l.1038–1042 records that hiding `special:min-*` before the taskbar exists would make minimize a one-way trip. Operator caught this. Ships **with** the Stage 3 taskbar. This is a correct deferral, not a gap. |

Also live from 2A: workspaces 1–5 (`keybinds.lua:137`), `Super+Q` / `Alt+F4` close, `Super+F` maximize, `Super+Shift+F` fullscreen, `Super+drag` move / `Super+RMB` resize (`keybinds.lua:26–27`), titlebar drag via hyprbars `MBIND_MOVE`.

**Third-window-closes bug:** log l.1194 records the repro attempt **failed** at the Stage 2 gate — the bug is dead, the Waybar-cgroup fix held. Live-tested, closed.

### 8.2 Keymap and OSD

| Item | State | Evidence |
|---|---|---|
| `Cmd+Space` launcher binding | **Activated** | `keybinds.lua:14` — `SUPER + Space` → `caelestia:launcher`. `Super+T` was moved to float-toggle (`:33`) to free the chord. Also bound: bare `Super` release, `Super+D`. |
| Brightness keys | **Activated** | `:162–163` — `XF86MonBrightnessUp/Down` → `caelestia:brightnessUp/Down` globals, `locked`, `repeating`. In-comment reason: `brightnessctl` fired no OSD. |
| Volume keys | **Activated** | `:158–161` — `wpctl` direct commands, `locked`. Caelestia's audio service observes the sink change and renders its own OSD. |
| Caelestia/Aurora OSD ownership | **Activated** | Single OSD owner by construction — direct device commands are *observed*, not double-reported. |
| SwayOSD retirement | **Activated** | No SwayOSD unit, no process, and no `swayosd` string in any `.nix` file. The double-brightness-OSD defect from the Stage 1 gate is structurally gone. |
| Screenshot bindings | **Written / activated, not verified** | `:146–153` — `Super+Shift+S` → `screenshot-area`, `Print` → `screenshot-full`, both `locked`. **The purple-film defect (MASTER §5) has no recorded retest.** `GRAND_PLAN.md` §5.12 expects the capture chain to be rebuilt onto `modules/areapicker/` at Stage 4; these bindings are the interim path. |
| Detached app-launch handling | **Activated** | 2B sweep (`29fedce`). Structurally reinforced by `KillMode=process`. |
| Workspace count + gesture bindings | **Activated** | Workspaces 1–5 focus + `Super+Shift+N` move (`:137–144`). `input.lua:33` — 3-finger horizontal workspace swipe (do-not-regress, preserved). `input.lua:42` — 2-finger pinch → native `cursor_zoom`, `mode = "live"`. |
| `scroll_factor = 0.6` | **Live-tested, FINAL** | `input.lua:18`. Decision #7 — full A/B loop 1.0/0.8/0.7/0.6 run live at the gate; 0.6 won on feel. |
| `animate_mouse_windowdragging = false` | **Live-tested, permanent** | `general.lua` misc block. Decision #8 — live-confirmed irrelevant to the drag jump; operator kept the rigid feel. |

**Volume gesture — owed, not cut.** `input.lua:39–41` documents the removal in-file. Decision #4 (operator: parked-is-not-fixed) then decision #9 (operator: **deferred** to the compositor bump whose newer gesture API does continuous natively). 2C escalated correctly rather than shipping a workaround: pinned 0.55.4's gesture API accepts only `string|function` actions, verified against installed `hl.meta.lua:444-454`. **This is a live commitment with a paper trail — do not let it evaporate at the bump.**

### 8.3 Half-Snap

| Question | Answer |
|---|---|
| Current source implementation | `keybinds.lua:61–135`. `snap_gaps_in = 5`, `snap_gaps_out = 8`, `snap_titlebar_height = 30`. Bound to bare `Super+Left` / `Super+Right` (decision #1, Windows-style, no Ctrl). |
| Decoration-aware geometry | **Yes.** `y = screen.y + 8 + 30 = 38`; `height = 1067 − 16 − 30 = 1021`; `usable_width = 1707 − 16 − 5 = 1686` → halves of **843**. Matches the log's 2D description exactly (l.1211–1214). Exact coordinates address the *client* box, so `y` includes the reserved bar and `height` excludes it. |
| Return-to-tiling / release behaviour | **Yes.** `is_half_snapped()` compares the live window box against both computed halves within ±1 px; a second arrow press on a matching window fires `window.float({action="toggle"})` to retile. After a native `Super+LMB` drag changes the geometry the window is an ordinary float again, and the next arrow press re-snaps rather than tiles. |
| Which generation contains it | **Gen 26.** Commit `58692ba` is timestamped 2026-07-21 22:59:08; `system-26-link` was created 2026-07-21 23:03:06 — four minutes later. |
| Was it activated | **YES — and this reverses the handoff.** `~/.config/hypr/hyprland/keybinds.lua` resolves to `…-home-manager-files/…/keybinds.lua`, and `diff` against `modules/home/hyprland/hyprland/keybinds.lua` reports **identical**. The 2D constants (`snap_titlebar_height = 30`, `is_half_snapped`) are present in the live file. |
| Did Alex physically retest the revised version | **No record.** |

**This is the largest correction to the inherited picture.** `PM_HANDOFF.md` l.164–166 states gen 26 is "staged boot-only and NEVER TESTED — do not report 2D fixes as live; the running system is gen 25." That was true when written. It is false now: the machine has since booted into gen 26. The 2D half-snap rework is **activated but not live-tested** — it moves out of "installed but not activated" (§14) and into §15.

The two gate defects 2D was written to fix (log l.1178–1183 — placement drifting out of frame top-left, and the snapped window staying floating forever so new windows tiled underneath it) are addressed *in the code that is now running*. Whether they are fixed *in practice* is an open question that only Alex's hands can answer.

### 8.4 Drag-Anchor Patch — which Hyprland is actually active

This was audited as nine separate questions, deliberately not collapsed. Derivation hashes and store-path validity were used in place of names.

| # | Question | Answer | Evidence |
|---|---|---|---|
| 1 | Does `modules/nixos/patches/hyprland-drag-anchor.patch` exist? | **Yes** | 1192 bytes, single hunk in `src/layout/supplementary/DragController.cpp`. Read in full. |
| 2 | Does the overlay applying it exist? | **Yes** | `flake.nix` — `hyprlandOverlay` does `prev.hyprland.overrideAttrs` appending the patch to `old.patches`. |
| 3 | Does the overlay apply to both eval paths? | **Yes** | `homePkgs = import nixpkgs { overlays = [ hyprlandOverlay ]; }` feeds `homeConfigurations.alex`; and `mkMacbook` injects `{ nixpkgs.overlays = [ hyprlandOverlay ]; }` as a module into `nixosConfigurations.macbook`. |
| 4 | Is the intended patch commit in Git? | **Yes** | `df37152`, ancestor of HEAD, content inspected (§3). |
| 5 | Does the configured derivation carry the patch? | **Yes** | Drv `bkjrfi08q5gf87jny3sj37iw4sq31r87-hyprland-0.55.4.drv` contains `hyprland-drag-anchor.patch` and declares output `azvhdgfzwhvyng9942pj6qga4ii60mm3-hyprland-0.55.4`. |
| 6 | **Does a completed patched Hyprland output exist in the store?** | **NO** | `nix path-info /nix/store/azvhdgfz…-hyprland-0.55.4` → `error: path … is not valid`. The output was never realised. |
| 7 | Was ABI-matched hyprbars built against the patched compositor? | **NO** | Drv `2a39krh29nndqh1f5f69zkd5pbw8m76f-hyprbars-0.55.0.drv` is the patched-compositor variant (references `bkjrfi08…`, and carries the hover patch). Its output `gfbbpbaljd5r6lvhwa1yfmzri39vrhhm-hyprbars-0.55.0` → `is not valid`. |
| 8 | Does any installed generation reference the patched outputs? | **NO** | Gen 25 and gen 26 both resolve `sw/bin/Hyprland` to `rv2dda5jgqr8vxd4ljp7vxmklmficxcm-hyprland-0.55.4`. No generation references `azvhdgfz…`. |
| 9 | **Is the running Hyprland the patched output?** | **NO** | Running binary is `/nix/store/rv2dda5jgqr8vxd4ljp7vxmklmficxcm-hyprland-0.55.4/bin/Hyprland` (PID 1696, from `pgrep -a`). That path is the declared output of drv `kpzvdhci2x8f4civx2s9qim9x1adk31d-hyprland-0.55.4.drv`, which contains **zero** occurrences of `hyprland-drag-anchor.patch`. |

**Two distinct derivations exist for "hyprland-0.55.4," and they are not interchangeable:**

```
kpzvdhci2x8f4civx2s9qim9x1adk31d.drv  → rv2dda5jgqr8vxd4ljp7vxmklmficxcm  UNPATCHED — RUNNING, in gens 25 & 26
bkjrfi08q5gf87jny3sj37iw4sq31r87.drv  → azvhdgfzwhvyng9942pj6qga4ii60mm3  PATCHED   — NOT VALID, never built
```

**Forensics of the interrupted build.** Three zero-byte root-owned lock files remain in the store, all stamped **2026-07-22 11:47**:

```
azvhdgfzwhvyng9942pj6qga4ii60mm3-hyprland-0.55.4.lock
p0ibd1kan125halyrywc18741w6z01aj-hyprland-0.55.4-dev.lock
3di2887csdzqq7bk7yflqs0xfmk04k8g-hyprland-0.55.4-man.lock
```

plus a `bkjrfi08…-hyprland-0.55.4.drv.chroot` directory (root-owned, unreadable to `alex` — recorded in §22). The commit `df37152` is timestamped 11:45:57. So the build started roughly 90 seconds after the commit and died during compilation, leaving the sandbox and locks behind. This is precisely what log l.1278–1280 describes.

**Classification:**

| State | Verdict |
|---|---|
| Planned | Yes — decision #10, 2026-07-22 |
| Written | **Yes** — patch + overlay, PM-verified (applies with zero fuzz to the pinned blob `ad68274 @ a0136d8c`; overlay live in real eval) |
| Built | **No** |
| Installed | **No** |
| Activated | **No** |
| Live-tested | **No** |

**Required test matrix still owed** (log l.1271–1273): 4 grab points × short/tall windows × `Super+LMB` / titlebar drag; floating drag unchanged; drop-to-retile intact.

**ABI consequence — this is the load-bearing operational fact.** Today the compositor and hyprbars are consistent (both descend from `kpzvdhci…`). The instant the drag patch builds, `pkgs.hyprland` changes, and because the plugin helper consumes top-level `hyprland`, **hyprbars must rebuild in the same closure**. They cannot be deployed separately. Combined with the 2A hover-crash lesson (log l.1046–1066: never hot-swap a compositor plugin — `hyprctl reload` re-runs `hl.plugin.load`, double-loads the singleton, null-derefs `barHeight`, SIGSEGV into safe mode), this batch is **boot-only + clean reboot, mandatory**.

### 8.5 Disable While Typing

Every element re-measured on the live machine this session.

| Evidence | Result |
|---|---|
| udev classification of the internal T2 trackpad | `udevadm info /dev/input/event7` → `ID_INPUT=1`, `ID_INPUT_TOUCHPAD=1`, `ID_INPUT_WIDTH_MM=122`, `ID_INPUT_HEIGHT_MM=82` |
| `ID_INPUT_TOUCHPAD_INTEGRATION` | **`external`** — and `ID_INTEGRATION=external` alongside it |
| libinput's current DWT capability | **`Disable-w-typing: n/a`** (also `Disable-w-trackpointing: n/a`). Device: `Apple Inc. Apple Internal Keyboard / Trackpad`, `usb:05ac:0280`, `/dev/input/event7`, Group 8, 122×82 mm |
| Existing `services.udev.extraHwdb` entries | **NONE.** `grep -rn "extraHwdb\|hwdb\|TOUCHPAD_INTEGRATION\|touchpad:usb" --include=*.nix .` returns **zero matches** across the entire repository |
| Existing libinput local quirks | **Present, but for the keyboard only** — `modules/nixos/desktop.nix:41` writes `/etc/libinput/local-overrides.quirks` with `[Apple T2 Internal Keyboard]`, `MatchUdevType=keyboard`, `MatchBus=usb`, `MatchVendor=0x05AC`, `MatchProduct=0x0280`, `AttrKeyboardIntegration=internal`. `MatchUdevType=keyboard` deliberately excludes the same-named trackpad interface. Live at `/etc/libinput/local-overrides.quirks` → `/etc/static/…` |
| The proposed internal-**touchpad** hwdb correction | **Does not exist** — not written, not committed, not built, not installed |
| Palm/thumb thresholds measured and written anywhere | **No** |

**Diagnosis, confirmed independently of the log.** The 2C quirk fixed the *keyboard* half (`AttrKeyboardIntegration=internal`). The *touchpad* half is untouched: udev's default for USB touchpads classifies them `external`, and libinput will not offer DWT on a touchpad it believes is external. Hence `Disable-w-typing: n/a` — **the feature is not disabled, it is absent**. `input.lua:15`'s `disable_while_typing = true` has therefore been a silent no-op for the entire build.

This supersedes both earlier framings in the log — 2C's "may already apply, don't pre-declare fixed" (l.1144–1148) and the Stage 2 gate's "only partially better" (l.1195–1197). Neither was wrong to hedge; the 2026-07-22 measurement resolved it, and this session re-confirmed it from the device.

**The fix, as specified at log l.1290–1293:** `services.udev.extraHwdb` in `desktop.nix` with match `touchpad:usb:v05acp0280:*` → `ID_INPUT_TOUCHPAD_INTEGRATION=internal`. **Lowercase vid/pid is required** for hwdb matching. systemd's stock `70-touchpad.hwdb` documents the key.

**The operator interaction still needed — exactly one thing.** Run `libinput measure touch-size /dev/input/event7` **with Alex's hands on the trackpad**, then fill the 2D report's candidate quirk stanza with measured `AttrPalmSizeThreshold` / `AttrThumbSizeThreshold`. Tooling is verified present at `/nix/store/md7kljxi6ys3vbghgbliqcrp1x40mj1x-libinput-1.31.3-bin/bin/libinput`; `alex` is in the `input` group so **no sudo is required**; keyboard is `event2`, trackpad is `event7`. This audit did **not** run it (correctly — it is interactive and requires Alex).

Supporting evidence retained: `~/.local/state/aurora-build/pm/dwt-capture.log` (390 KB) — the live capture showing 22 palm-taps during typing, most within ±0.15 s of keypresses.

**Sequencing note the next PM should not miss:** the hwdb entry and the threshold measurement are *separable*. The hwdb entry alone turns `Disable-w-typing` from `n/a` to `enabled` and can ship in the batch immediately. The measured thresholds are a second, finer pass that needs Alex and can follow. Do not block the batch waiting for the measurement.

### 8.6 Corner Resize

| Question | Answer |
|---|---|
| Current hyprbars version / source | **v0.55.0**, built from `hyprland-plugins` via `overrideAttrs` in `modules/home/hyprland/default.nix`. Running output `5n10sci62…`. |
| Existing hyprbars patches | **Exactly one** — `modules/home/hyprland/patches/hyprbars-hover.patch` (5886 bytes). |
| Corner-resize patch or research report | **Neither exists.** `find . -name '*.patch' -not -path './repos/*'` returns exactly two files: `hyprland-drag-anchor.patch` and `hyprbars-hover.patch`. No corner-resize prompt in `codex-prompts/`, no report in `~/.local/state/aurora-build/pm/`. |
| Did source investigation begin | **No.** Log l.1307 states plainly: "Not started." |
| Any implementation intended to fix the interaction | **No.** The compositor side is configured as the plan expects — `general.lua` has `resize_on_border = true`, `extend_border_grab_area = 12`, `hover_icon_on_border = true` — but 2D's verdict (l.1229–1232) is that `extend_border_grab_area` **cannot reach through hyprbars' event handling**, so no config-level repair exists. |
| Is only `Super+RMB` left as fallback | **Yes** — `keybinds.lua:27`, `SUPER + mouse:273` → `window.resize()`. |

**Mechanism, as understood from the log and consistent with the config read:** the carried hyprbars v0.55.0 reserves a 30 px top bar (`bar_height = 30`, `bar_part_of_window = true`, `bar_precedence_over_border = true`) and consumes pointer events over it, shadowing the compositor's corner border-grab zones. This is the upstream-known hyprbars × `resize_on_border` interaction (#355) that `GRAND_PLAN.md` §6.2 predicted and gated.

**Status: reopened and non-negotiable.** Operator decision #11, 2026-07-22, in Alex's own words: *"I want corner resize... just like the drag its a non negotiable we dont just skip over."* The log records that the PM had wrongly labelled the 2D fallback verdict "closed" when Alex had never accepted it.

**Stage 2 cannot be marked complete while this is unresolved.** The intended fix path (log l.1302–1307) is to research the interaction in the carried v0.55.0 hyprbars source and **extend our already-carried patch** — the hover patch is the precedent that this is tractable and in-house. Sourced fixes preferred; Codex xhigh; isolation constraints like the drag prompt.

### 8.7 Stage 2 Gate Verdict

**Verdict: NOT READY FOR GATE — but ready for one combined build, with a caveat.**

Against the brief's five options:

- ✗ *Accepted* — no. Three items are unresolved and one non-negotiable (corner resize) has no implementation.
- ✗ *Activated but awaiting live test* — partially true (§8.3 half-snap), but not the stage verdict.
- ✗ *Built but awaiting reboot* — no. Nothing new is built; the drag patch's output is not valid.
- **~ *Ready for one combined build*** — true for **two of three** items. The drag patch is written and PM-verified, so its build is purely mechanical and can start immediately. The DWT hwdb entry is a small, fully-specified `.nix` edit that can be written today.
- **✓ *Not ready for gate*** — because **corner resize has not been started**, and it gates the stage by operator decision.

The honest formulation: **Stage 2 is one research task away from being ready for its final build.** The drag build and the DWT hwdb entry can proceed in parallel with the corner-resize investigation, but all three must land in one closure before the reboot — per Alex's standing batch directive and because the compositor/plugin ABI forces it.

Stage 2 closes only when all three land, they deploy in one boot-only generation, and Alex's re-test confirms all four surfaces (drag, half-snap, DWT, corner resize) in a single reboot.

---

## 9. Stage 3 Preparation State

| Question | Answer | Evidence |
|---|---|---|
| Does `codex-prompts/stage3-taskbar-mapping.md` exist? | **Yes** | 3966 bytes, dated 2026-07-22 12:19. |
| Is thread `019f8ad6-f360-7340-8c92-c17189e395b0` resumable locally? | **Yes** | Rollout record present: `~/.codex/sessions/2026/07/22/rollout-2026-07-22T12-19-30-019f8ad6-f360-7340-8c92-c17189e395b0.jsonl`. |
| Does `pm/stage3prep-events.jsonl` exist and is it complete enough to use? | **Exists; NOT complete enough** | 1,092,937 bytes but only **92 lines**. Line 1 confirms `thread.started` with the matching ID. The stream **ends mid-tool-output**, in the middle of a QML file read (a window-preview component, around line 229 of the file being read). There is no `turn.completed`, no final agent message, no structured mapping output. |
| What outputs did the interrupted session write? | **None** | `~/.local/state/aurora-build/pm/` contains `build-drag.log`, `dragpatch-final.md`, `dragresearch-final.md`, `dwt-capture.log`, `stage2c-final.md`, `stage2d-final.md`, `stage3prep-events.jsonl`. There is **no `stage3prep-final.md`** — the `--output-last-message` file was never written, which is exactly what a mid-run death produces. |
| Were any Stage 3 implementation files or commits created? | **No** | No `topbar`/`taskbar` directory anywhere under `modules/` (`find modules -iname '*topbar*' -o -iname '*taskbar*'` → empty). No commits after `df37152` except the docs-only `6486742`. |
| Did the interrupted session make unsupported changes? | **No** | Working tree is clean with zero untracked files (`git status --porcelain -uall` → empty). The session ran read-only in practice — its visible activity was reading the preamble, the plan sections, the aurora-shell/Nix wiring, and donor QML. Nothing it did survives except the partial log. |

**Recommendation: start a fresh mapping session; do not resume the thread.**

Reasoning, stated so the next PM can overrule it with cause rather than by default:

1. The partial stream contains no conclusions — only reads. There is nothing to salvage but reading order, which the prompt already encodes.
2. Resuming replays ~1 MB of stale tool output into the new context for zero analytical yield, on a machine where context and compute are both scarce.
3. The prompt file survives intact and is the actual reusable artifact.
4. The audit brief forbids resuming it in this session regardless, and nothing found here argues for changing that later.

The one thing worth carrying forward is the prompt's third objective — **dev-loop feasibility: a second QuickShell instance running from the worktree for hot QML iteration.** That is load-bearing for Stage 3 cycle time on this hardware, and it is the question most likely to change how Stage 3 is batched. It should survive into whatever replaces this session.

**Stage 3 has not genuinely begun.** Its gate (`GRAND_PLAN.md` §5.1) is untouched.

---

## 10. Protected-State Verification

Read-only. Presence, path and configuration status only — no contents of sensitive files are reproduced here.

| Item | Status | Evidence |
|---|---|---|
| `/etc/nixos/firmware/brcm` | **Intact** | Directory present, **163 files** — matches MASTER §10 exactly. |
| Machine-local firmware wrapper | **Intact (by reference)** | `~/.config/nixos-local`, deliberately not in Git; `flake.nix` takes `firmwareSource ? null` so the repo evaluates portably. Wrapper itself not inspected — see §22. |
| T2 hardware module imports | **Intact** | `flake.nix:62` — `nixos-hardware.nixosModules.apple-t2`. |
| systemd-boot / dual-boot invariants | **Intact** | 12 entries in `/boot/loader/entries/`, all `nixos-*.conf`. Not modified. `canTouchEfiVariables = false` per the T2 constraint. |
| Bluetooth state path / pairings | **Not inspected — see §22** | `/var/lib/bluetooth` requires root; `sudo -n` correctly refused (build-harness NOPASSWD is scoped to deploy verbs only). No evidence of change; nothing this session touched it. |
| Xbox BLE tuning | **Intact** | `desktop.nix:56` — `settings.LE` Min 7 / Max 9 / Latency 0, with the rationale comment preserved. |
| t2fanrd configuration | **Intact and running** | Flake input + `laptop-power.nix:21`; service **active**; `/etc/t2fand.conf` = 50/75 linear. |
| VA-API / iHD | **Configured** | `desktop.nix:51` — `hardware.graphics.enable` + `intel-media-driver`. **Note:** `vainfo` is not on `PATH` in the current system closure, so the `GRAND_PLAN.md` §5.12 "`vainfo` shows iHD encode" check **cannot be run as-is** and has no recorded pass. See §19. |
| TV firewall rule | **Present in flake** | `modules/nixos/media-center.nix` — MAC-accept for `40:2f:86:81:26:3e`, insert + stop-remove. Live `iptables` state not readable (§22). |
| Moonfin / Media Center config | **Intact** | `~/.local/share/mediacenter` and `~/.local/bin/mediacenter` both present. User-dir by design — survives rebuilds. Never auto-started; no unit for it. |
| `nix-ld` | **Intact** | `modules/nixos/base.nix:28` — `programs.nix-ld.enable = true`. |
| npm-global path | **Intact** | `home/alex/default.nix:19` — `sessionPath = [ "$HOME/.npm-global/bin" ]`. The agent lane (`/home/alex/.npm-global/bin/codex`) depends on this. |
| Chrome native Wayland | **Intact** | `keybinds.lua:2` — `google-chrome-stable --ozone-platform-hint=auto`. Live Chrome processes show `--ozone-platform=wayland` and `--enable-features=WaylandWindowDecorations`, confirming native Wayland end-to-end. |
| Font rendering / cursor / input settings | **Intact** | Fonts incl. Inter declared in the flake (Stage 0 parity sweep). Input: `tap_to_click = true`, `natural_scroll = true` (`input.lua:11–12`) — both do-not-regress items preserved. Cursor: `hover_icon_on_border = true`. |
| Recovery documentation / backup path | **Present** | `docs/recovery.md`, `docs/controls.md`, `docs/updating.md`, `docs/wallpapers.md`. Gen 15 held as the channel-lineage rollback anchor. **Note:** `services.restic` does not exist anywhere in the repo — backup is Stage 9 scope and is correctly not yet built. |

**No protected state was found clobbered.** Two items are unverified rather than verified — Bluetooth pairings and the live firewall rule — both solely because read access required a password this session was instructed not to request.

---

## 11. Planned but Unstarted Work

Described in `GRAND_PLAN.md`, no implementation evidence found on disk.

**Within Stage 2 (blocking the gate):**

- **Corner-resize hyprbars patch** — decision #11, non-negotiable. No patch, no research report, no prompt. §8.6.
- **DWT udev hwdb entry** — fully specified in the log, zero lines written. §8.5.
- **Palm/thumb threshold measurement** — needs Alex's hands. §8.5.

**Within Stage 2 (non-blocking cleanup that was assigned to Stage 2 and never done):**

- Retire `waybar`, `rofi`, `awww`, `waypaper` from `modules/home/packages.nix`.
- Retire the `rofi-toggle` wrapper from `modules/home/hyprland/default.nix`.
- The matugen templates for `waybar.css` / `rofi.rasi` / `dunstrc` in `modules/home/theming/` are entangled with Stage 4's theming rework — **leave them**; retiring them piecemeal risks breaking the dunst fallback before Stage 4 replaces the pipeline.

**Deferred with a paper trail (do not silently drop):**

- **3-finger vertical live-volume gesture** — decision #4 then #9. Owed at the compositor bump (0.56+ adds Lua touchpad gestures).
- **Hiding `special:min-*` workspaces** — filter drafted in `codex-prompts/stage2a-hide-min-workspaces.md`, ships **with** the Stage 3 taskbar.
- **§3.2 glass A/B gate** — a Stage 1 gate item deferred to Stage 4. Live blur (`size 8 / passes 2 / vibrancy_darkness 0.38`) still differs from the plan's starting point (`12 / 1 / 0`).
- **Palette completeness** — 13 of 54 M3 roles unpinned (ISSUE_LOG §20) → Stage 4.
- **Launcher/dashboard animation lag** → Stage 3 motion pass.
- **Corner-resize documentation in Nexus Input help** → Stage 9, *after* the real fix lands.
- **`start-hyprland` warning** → Stage 7 session-chain rebuild.
- **T2 RTC boot-clock skew** (ISSUE_LOG §28) → Stage 7.

**Stages 3–10 in their entirety.** Nothing from Stage 3 onward has any implementation artifact. See §5.

---

## 12. Written but Not Built

| Item | Location | Note |
|---|---|---|
| **Hyprland drag-anchor patch** | `modules/nixos/patches/hyprland-drag-anchor.patch` + `flake.nix` overlay, commit `df37152` | The single most important entry in this audit. PM-verified as correct (zero-fuzz dry-run against the pinned blob; overlay live in real eval) — it simply never compiled. §8.4. |
| **ABI-matched hyprbars for the patched compositor** | Implied by the overlay | Drv `2a39krh2…` exists; output `gfbbpbalj…` is not valid. Rebuilds automatically as a consequence of building the compositor — no separate action needed. |

Nothing else in the tree is written-but-unbuilt: every other configuration file is realised in the running generation.

---

## 13. Built but Not Installed

**Nothing.**

Every valid store output relevant to the current configuration is referenced by gen 26. The two patched outputs that *would* occupy this category (`azvhdgfz…-hyprland`, `gfbbpbalj…-hyprbars`) are not valid store paths, so they belong in §12, not here. Older generations 8–25 retain their own closures, but those are historical, not staged work.

---

## 14. Installed but Not Activated

**Nothing.**

This category was expected to hold the gen-26 half-snap rework, per `PM_HANDOFF.md`. It does not: booted, current and profile-default all resolve to the same gen 26 store path, so there is no staged-but-unbooted generation. **The handoff's central operational claim is stale.** The item moved to §15.

---

## 15. Activated but Not Live-Tested

Running on the machine right now, with no record of Alex exercising it.

| Item | Since | Why it matters |
|---|---|---|
| **Stage 2D half-snap rework** — decoration-aware geometry (y=38, 843 px halves, 5 px centre gap, all edges in frame) + the arrow-press release path back into the dwindle tree | gen 26 | Written specifically to fix the two defects Alex found at the Stage 2 gate: out-of-frame drift, and snapped windows staying floating forever so new windows tiled underneath. **Whether it actually fixes them is unknown.** §8.3. |
| **`animate_mouse_windowdragging = false` as a permanent setting** | gen 26 | Decision #8. A/B'd live at the gate, but the permanent form shipped in `58692ba` and has not been re-confirmed in daily use. Low risk. |
| **Screenshot bindings** — `Super+Shift+S` → `screenshot-area`, `Print` → `screenshot-full` | since 2B | The MASTER §5 purple-film defect has **no recorded retest** on the current chain. §8.2. |
| **2-finger pinch → native `cursor_zoom`** (`mode = "live"`) | since 2C/2D era | Sourced, correct-by-construction, never exercised on the gate checklist. |
| **`repeat_delay = 350` / `repeat_rate = 22`** | since 2B | MASTER §5 lists "backspace/delete repeat far too fast, not progressive" as a defect. The values landed; the empirical before/after MASTER demands was never run. |

Everything in this table can be tested in the **same** reboot as the pending batch. None of it justifies a reboot of its own.

---

## 16. Accepted Operator Decisions

The decisions register from `EXECUTION_LOG.md` l.1094–1129, l.1185–1192 and l.1251–1307, reproduced as a single authoritative list. **These are settled and are not to be relitigated.**

| # | Decision | Date | Status |
|---|---|---|---|
| 1 | Snap/window keys on **bare Super+arrows — no Ctrl** (Windows-style) | 2026-07-21 | Live (`keybinds.lua:134–135`) |
| 2 | Titlebar buttons: **clean modern monochrome** — not the plan's traffic-light red/yellow/green wording, not a Windows/macOS copy | 2026-07-21 | Live (`hyprbars.lua.in`) |
| 3 | **`scroll_factor 0.6`**, not the plan's 0.3 | 2026-07-21 | Superseded by #7 (same value, now final) |
| 4 | The 3-finger vertical live-volume gesture is **NOT cut** — parked-is-not-fixed. Cutting planned features to silence a bug is never a fix on this project | 2026-07-21 | Owed; see #9 |
| 5 | Super+drag spring: root cause **CONTESTED — settle it live, not on paper** | 2026-07-21 | **Settled** at the gate: tiled-window pickup placement. Animation theory dead (identical with flag off); scaling theory dead (floating windows drag perfectly at the same scale) |
| 6 | **PM conduct (binding):** full grounding reads + stated read list before any work; decisions logged same-day; fixes come from community sources, never from cutting scope or hand-patching upstream first; plain high-level communication | 2026-07-21 | Standing |
| 7 | **`scroll_factor 0.6` FINAL** — full live A/B loop 1.0/0.8/0.7/0.6 | 2026-07-21 | Live, final |
| 8 | **`animate_mouse_windowdragging = false` permanent** | 2026-07-21 | Live, permanent |
| 9 | **Volume gesture DEFERRED** until the Hyprland bump whose newer gesture API does continuous natively. **Not cut — owed** | 2026-07-21 | Owed at the bump |
| 10 | **Carry the compositor patch** for the drag anchor, on two verified conditions: (a) proven from read source that older Hyprland preserved the grab point; (b) strictly isolated, no scope opening | 2026-07-22 | Written, **not built** |
| 11 | **Corner resize REOPENED — non-negotiable.** *"I want corner resize... just like the drag its a non negotiable we dont just skip over."* | 2026-07-22 | **Not started** |
| — | **Standing directive: batch fixes.** Group file-work into batches; **one build + one reboot per batch** | 2026-07-22 | Governs the §18 batch |

Two further standing constraints, carried from `PM_HANDOFF.md` and `MASTER_REQUIREMENTS.md` §1.1, restated because they are absolute:

- **Attribution for vendored code = upstream repo + path only.** Licensing is never mentioned, anywhere, for any reason — not in code, commits, logs, prompts, or reports.
- **Never narrow what's intended.** Any answer that means cutting or downgrading a planned feature to silence a bug is wrong. A single-lane "the ecosystem lives with it" search is a void conclusion. The drag-bug research proved Alex right on exactly this point: the fix was Hyprland's own former behaviour, forward-ported.

---

## 17. Execution Log Contradictions and Stale Claims

Each entry names the winning evidence and why.

### 17.1 The July 16 "current handoff" section is a dead architecture

`EXECUTION_LOG.md` l.131–137 declares itself "the durable current-state report" and "when an older section conflicts with this one, this section wins." **That sentence is now actively misleading.** The section describes:

- Waybar as the permanent glass taskbar and primary click surface (l.172)
- Independent custom QuickShell `PanelWindow` dropdowns as the panel architecture (l.173–174)
- Matugen/awww/Waypaper as the theming and wallpaper pipeline
- "The MacBook exposes only workspaces 1 and 2" (l.190)
- Generation 9 running, generation 10 as next boot (l.148–149)

**Winner: the machine and the later log.** Waybar is not installed as a module and is not running. Workspaces are 1–5. The generation is 26. The architecture is caelestia-forked `aurora-shell` per `GRAND_PLAN.md` §2.1, with Waybar explicitly retired in §2.2's unit table. The Grand Plan (2026-07-21) supersedes this section wholesale; l.4 of the plan says so directly, and `MASTER_REQUIREMENTS.md` §15 records "Bar: QuickShell. Waybar is retired" as a firm decision dated 2026-07-17 — *before* the plan, and after the July 16 report.

The July 16 section's "Instructions for the next chat" (l.742–765) are correspondingly obsolete: they direct the reader to `BUILD_PLAN.md` (superseded), to fix Waybar launch isolation first (fixed by deletion), and not to push or delete generations (both since done, with authorisation, in Stage 0).

### 17.2 "Drag patch (built)" contradicts "the build was interrupted" — in the same entry

Log l.1279–1280: *"The build of both eval paths was interrupted before the patched compositor compiled — only stock hyprland-0.55.4 is in the store. **Builds owed**."*

Log l.1310–1311, twenty-nine lines later: *"Current batch: drag patch **(built)** + DWT hwdb/quirk fix + corner-resize hyprbars patch."*

**Winner: "interrupted," decisively, and the machine over both.** `nix path-info` reports the patched output invalid; the running compositor derives from a patch-free derivation; lock files and a `.drv.chroot` mark the interruption at 2026-07-22 11:47. The "(built)" parenthetical is a drafting error in the batch summary. It is the single most dangerous line in the log, because a PM reading only the batch list would skip the build and deploy an unchanged compositor while telling Alex the drag bug is fixed.

### 17.3 `PM_HANDOFF.md`: "gen 25 booted, gen 26 staged and NEVER TESTED"

`PM_HANDOFF.md` l.164–166 instructs: *"Do not report 2D fixes as live; the running system is gen 25."*

**Winner: the machine.** `/run/current-system`, `/run/booted-system` and `/nix/var/nix/profiles/system` all resolve to gen 26's store path. The machine rebooted after the handoff was written. The 2D fixes **are** live — but still untested, so the handoff's *underlying caution* remains correct even though its *stated fact* is wrong. The correct present statement is "activated, not live-tested," not "staged."

This is also the failure mode `PM_HANDOFF.md` itself warns about at l.238: *"Staged ≠ live: check `readlink /run/current-system` before telling Alex to test."* The rule was right; the recorded value went stale.

### 17.4 DWT: three successive framings, only the last one true

| Entry | Claim |
|---|---|
| 2C (l.1141–1148) | Quirk shipped; honest caveat that libinput may already apply the attribute and DWT's ineffectiveness may have another cause — *"do not pre-declare this fixed"* |
| Stage 2 gate (l.1195–1197) | *"DWT typing-protection only partially better"* |
| 2D (l.1224–1228) | *"stock libinput already applies keyboard-integration AND the corrected T2 palm-size threshold — the 2C override was redundant-but-harmless"* |
| 2026-07-22 (l.1282–1299) | **Root cause found: `ID_INPUT_TOUCHPAD_INTEGRATION=external`, `Disable-w-typing: n/a` — DWT has never existed on this device** |

**Winner: the 2026-07-22 measurement, re-confirmed live by this audit.** "Partially better" was an artefact of subjective assessment against a feature that was never active. The 2C quirk addressed the *keyboard* integration attribute, which was never the blocker — the *touchpad* integration attribute is. Credit where due: 2C's honest caveat and 2D's escalation-not-shipping were both correct behaviour under uncertainty; the register only became wrong when "partially better" was allowed to stand as a finding.

### 17.5 Corner resize: marked closed, then reopened

2D (l.1229–1232) recorded: *"Plan's pre-authorized fallback stands: Super+RMB corner resize + document in Nexus Input help."* The PM described this as closed.

**Winner: the operator.** Log l.1301–1307 records decision #11 — Alex never accepted the fallback and reopened it as non-negotiable, and the log explicitly names the PM's error: *"The PM wrongly described the 2D fallback verdict as 'closed'; the operator never accepted it."*

**The governing rule, from `PM_HANDOFF.md` l.27–29:** *"Nothing is 'closed' or 'deferred' unless Alex said so, in his words. Plan features are commitments. Fallbacks are proposals until he signs off."*

### 17.6 A gate called "passed" with a non-negotiable outstanding

The Stage 2 gate (l.1203) is recorded as **CONDITIONAL PASS**, with closure explicitly contingent on the 2D batch landing plus an operator re-check. That framing is correct and honest.

The risk is drift, not error: `PM_HANDOFF.md` l.167 restates it correctly, but a reader skimming for "Stage 2" could take "pass" and move on. **Stage 2 is not passed.** Corner resize alone blocks it.

### 17.7 Stage 0 acceptances recorded as deferred, then never run

Log l.866–871 defers TV-from-couch reachability and Xbox controller pairing to the Stage 1 gate, with risk explicitly accepted. The Stage 1 gate entry (l.981–1007) does not mention either.

**Winner: nothing — this is a genuine gap, not a conflict.** Both remain inference-backed (firewall rule verified in the live start script; BlueZ settings and `/var/lib/bluetooth` untouched) rather than test-backed. They belong in §19.

### 17.8 Generation numbers and live paths that have gone stale

- July 16 section: "Generation 9 running / Generation 10 next boot" → now 26/26.
- July 16 section: live HM `kyl34kvnyja…` → the standalone HM profile is now vestigial (last touched 2026-07-16); HM activates through the NixOS module, live file store `xvkd65lwpqibq5hmml7c8cr98hbayaf1-home-manager-files`.
- 1A/1B/1C build outputs (`2sc3i9j9s0q…`, `46jqdy8svnx…`, `fi5py6wflyg…`, `j4y0rw9mai2…`) are historical build receipts, not current paths. The live shell is `nx8375sxz5zw7ylp68q649jicfqjyyv4-caelestia-shell-1.0.0`.
- `PM_HANDOFF.md` l.162: "HEAD at handoff includes the drag patch commit and the handoff commit; pushed" — still accurate.

### 17.9 Planned work described as deployed

Beyond §17.2, one lower-stakes case: log entry 1C (l.960–967) flags the retired packages as "transitional state ... retires on schedule" in the Stage 2 window-model sweep. 2B (l.1086–1090) reports "rules cleanup" as landed. **`waybar`, `rofi`, `awww` and `waypaper` are still in `packages.nix`.** The sweep was partial. Harmless — nothing runs — but it is unfinished Stage 2 scope, not completed scope.

### 17.10 Deployed work lacking a physical acceptance record

See §15 in full. The headline case is the 2D half-snap rework: shipped, activated, and never touched by Alex.

---

## 18. Exact Next Execution Batch

**This audit does not execute it.** It is specified so the next PM can start without re-deriving anything.

### Scope

**Batch name: Stage 2 close-out.** Three items, one closure, one boot-only deploy, one reboot.

1. **Build the drag-anchor patch.** No new code. Re-run both builds; nix resumes from store. The patch and overlay are already committed and PM-verified.
2. **Implement the DWT udev hwdb entry.** New code, small and fully specified: `services.udev.extraHwdb` in `modules/nixos/desktop.nix`, match `touchpad:usb:v05acp0280:*` → `ID_INPUT_TOUCHPAD_INTEGRATION=internal`. **Lowercase vid/pid.** Reference: systemd's stock `70-touchpad.hwdb`.
3. **Research and patch hyprbars for corner resize.** The only genuinely open engineering task. Investigate the v0.55.0 hyprbars top-decoration × `resize_on_border` interaction in the carried source, and **extend the existing carried patch** so corner grabs work. Sourced fixes preferred. Codex xhigh, house research style, isolation constraints modelled on the drag prompt.

### Why these three belong in one batch

- **ABI forces it.** Building the drag patch changes `pkgs.hyprland`; because the plugin helper consumes top-level `hyprland`, hyprbars rebuilds in the same closure automatically. A corner-resize patch is *also* a hyprbars change. Shipping them separately means two compositor-closure rebuilds and two reboots on a machine where the compositor is one long-running derivation.
- **Alex's standing directive** (2026-07-22): one build + one reboot per batch. Rebuild-per-fix already wasted his time once.
- **The re-test is a single sitting.** All four surfaces under test — drag, half-snap, DWT, corner resize — are window-manipulation behaviours exercised with the same windows in the same few minutes.
- **The compositor cannot be hot-swapped** (2A SIGSEGV lesson). Every item here requires a clean boot anyway.

### Files that would change

| File | Change |
|---|---|
| `modules/nixos/desktop.nix` | **Add** `services.udev.extraHwdb` block (item 2) |
| `modules/home/hyprland/patches/hyprbars-corner-resize.patch` *(new)* or an extension of `hyprbars-hover.patch` | Item 3 |
| `modules/home/hyprland/default.nix` | Register the new/extended patch in the `patchedHyprbars` `overrideAttrs` list (item 3) |
| `EXECUTION_LOG.md` | Batch entry + any decisions, same-day |
| *(no change)* `flake.nix`, `modules/nixos/patches/hyprland-drag-anchor.patch` | Already correct — item 1 is a build, not an edit |

### What must build together for ABI consistency

One closure containing, in dependency order:

```
hyprland-0.55.4  (patched: drag-anchor)          → azvhdgfzwhvyng9942pj6qga4ii60mm3
  └─ hyprbars-0.55.0 (patched: hover + corner)   → new hash, replaces gfbbpbalj…
       └─ home-manager-files (hyprbars.lua plugin path)
            └─ nixos-system-macbook toplevel     → gen 27
```

Build **both** eval paths per the verification both-paths rule: `path:/home/alex/nix#homeConfigurations.alex.activationPackage` and `…#nixosConfigurations.macbook.config.system.build.toplevel`. Deploy through the machine-local wrapper (`nix flake update --flake ~/.config/nixos-local` first — it repins the git rev, required after every commit). `--max-jobs 2 --cores 2`. **Run the compositor build in a detached `systemd-run --user` unit** — a tool-managed background task's timeout can kill a nix build mid-derivation and lose the whole compile.

### Deployment mode

**Boot-only. Mandatory. Not negotiable, and not a preference.**

`sudo nix-env --profile /nix/var/nix/profiles/system --set "$TOP"` → `sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot` → armed resume → reboot.

Three independent reasons: (a) the compositor binary changes, and a live switch cannot replace a running Hyprland; (b) hot-swapping a compositor plugin double-loads hyprbars' process-wide singletons and SIGSEGVs into safe mode — paid for once already; (c) a live `switch` attached to the agent terminal has OOM-killed this machine before. Gen 26 remains selectable as the fallback.

### Physical test matrix for Alex, after the reboot

**Drag anchor** (the owed matrix from log l.1271–1273):
- 4 grab points (near each corner of the titlebar) × short and tall windows × `Super+LMB` and titlebar drag — the window must stay under the cursor at the grab point, not jump to centre.
- A **floating** window drags exactly as before (no regression).
- Drop-to-retile still works — dropping a dragged tiled window back into the layout re-tiles it.

**Half-snap** (activated in gen 26, never tested):
- `Super+Left` / `Super+Right` — window lands fully in frame, no top-left drift.
- Second arrow press on a snapped window returns it to the tiling layout.
- After snapping, open a new window — it must **not** tile underneath a permanent floater.
- Drag a snapped window: it behaves as an ordinary float; the next arrow press re-snaps.

**DWT:**
- `libinput list-devices` for `/dev/input/event7` now reads **`Disable-w-typing: enabled`** (currently `n/a`) — this is the objective pass/fail.
- Type a paragraph in a text field with palms resting naturally; the cursor must not jump.

**Corner resize:**
- Grab each of the four corners of a floating window and both **expand and shrink**. MASTER §5's defect is specifically that resize "only works in one direction."
- Repeat on a tiled window (dwindle tree math means one-directionality there is expected, per `GRAND_PLAN.md` §6.2 — do not report that as a failure).
- `Super+RMB` still works as the redundant path.

**Free riders in the same sitting** (§15 — no extra reboot):
- Screenshot: `Super+Shift+S` region → check the PNG for the purple overlay film; `Print` full screen.
- Key repeat: hold backspace — is it controlled rather than runaway?
- 2-finger pinch → cursor zoom.

### Explicit exclusions — what must not creep into this batch

- **No Stage 3 work.** No taskbar, no topbar module, no `special:min-*` filter (it ships *with* the taskbar, by operator instruction).
- **No Stage 4 work.** No skwd-wall, no palette rework, no glass A/B, no matugen retirement.
- **No compositor version bump.** The volume gesture is deferred *to* the bump; the bump is not this batch. Bumping now would invalidate both patches and the hyprbars ABI in one move.
- **No retirement of `waybar`/`rofi`/`awww`/`waypaper` from `packages.nix`** unless it is genuinely free. It is cosmetic, it touches the HM closure, and a rebuild failure there would block three real fixes. Do it in a later low-risk batch.
- **No lock/boot/greeter changes** (Stage 7), **no Dolphin/MIME work** (Stage 6).
- **No "quick fixes"** discovered en route. Log them; do not absorb them.
- **No live `switch`.** Boot-only, always.

### Can Stage 3 begin before this batch passes?

**No.**

- Stage 2's gate is a hard `[GATE]` marker in `GRAND_PLAN.md` §10, and §0.4 states work stops at a gate until the listed checks pass on the physical machine.
- Corner resize is non-negotiable by operator decision #11. Starting Stage 3 with it open would repeat exactly the error that got it reopened.
- Stage 3's own deliverable *depends* on Stage 2 closing: the `special:min-*` workspace filter is held back specifically to ship with the taskbar, because minimize would otherwise become a one-way trip.

**What may proceed in parallel:** Stage 3 *mapping* — a fresh read-only component-map session against `GRAND_PLAN.md` §5.1, plus the dev-loop feasibility question (a second QuickShell instance from the worktree for hot QML iteration). That is research, it touches nothing, and it is the right use of the wait. **Stage 3 implementation stays blocked.**

---

## 19. Required Operator Tests

Everything that needs Alex's hands, grouped so his time is spent once.

### A. Needs Alex during the batch (before the reboot)

1. **`libinput measure touch-size /dev/input/event7`** — with his hands on the trackpad, resting palms and thumbs as he naturally would. Produces measured `AttrPalmSizeThreshold` / `AttrThumbSizeThreshold` for the 2D report's candidate quirk stanza. Tool: `/nix/store/md7kljxi6ys3vbghgbliqcrp1x40mj1x-libinput-1.31.3-bin/bin/libinput`. **No sudo** — `alex` is in the `input` group. Keyboard `event2`, trackpad `event7`.
   *This does not block the batch* — the hwdb entry alone flips DWT from `n/a` to `enabled`. The thresholds are a finer second pass.

### B. Needs Alex after the reboot — the Stage 2 gate re-test

The full matrix in §18. One sitting: drag anchor, half-snap, DWT, corner resize, plus the §15 free riders.

### C. Owed from Stage 0, never run

2. **TV-from-couch reachability** — Moonfin/Jellyfin reachable from the living-room LG TV. Deferred at the Stage 0 gate (operator away from the TV), never picked up at Stage 1. Currently inference-backed only.
3. **Xbox controller pairing** — same deferral, same status. BlueZ LE tuning is in the flake and `/var/lib/bluetooth` is untouched, but nobody has held the controller.

### D. Owed from Stage 1, deferred by plan

4. **§3.2 glass A/B** — an evening with Alex: size 12/1-pass vs 8/2-pass; `xray true` vs `false`; `decoration:glow` rim accent. Formally a Stage 1 gate item, deferred to Stage 4 where the real glass work lives. Live config currently differs from the plan's starting values.
5. **VA-API confirmation** — `GRAND_PLAN.md` §5.12 expects `vainfo` to show iHD encode. **`vainfo` is not in the current system closure**, so this check has never been runnable as written. Either add `libva-utils` or verify by another route. Low urgency; the driver is configured and Chrome renders on native Wayland.

### E. Do not test yet

- Anything Stage 3+. The surfaces do not exist.
- Suspend/lid cycles (Stage 7's acceptance gate) — the T2 suspend story is deliberately untouched.

---

## 20. Proposed Handoff Header for `EXECUTION_LOG.md`

**Not applied.** This audit did not modify `EXECUTION_LOG.md`. The block below is offered for a later PM to prepend **only after Alex approves it**.

```markdown
> ## ⚠ READ THIS BEFORE READING ANYTHING BELOW
>
> This log contains two incompatible architectures. Read chronologically and
> trust later entries over earlier ones.
>
> **The 2026-07-16 "full implementation and handoff report" section describes a
> RETIRED architecture.** It calls itself "the durable current-state report" and
> claims later sections lose to it. That claim expired on 2026-07-21. It
> describes Waybar as the permanent taskbar, independent custom QuickShell
> dropdown panels, matugen/awww/Waypaper theming, and workspaces 1–2. **None of
> that is the build.** Do not resume from it, cite it, or treat its
> "Instructions for the next chat" as live.
>
> **The current architecture is `GRAND_PLAN.md`:** caelestia forked as
> `aurora-shell` (one QuickShell instance, systemd-supervised), a new QuickShell
> top taskbar, caelestia's vertical rail retained, Waybar retired, skwd-wall as
> the wallpaper authority, staged gates controlling execution.
>
> **Start here:** `## Stage 0 — Reconcile & baseline (2026-07-21)`, then read
> forward to the end. Then read `CURRENT_STATE_AUDIT.md` for verified machine
> state — this log records what was *attempted*, not what is *running*.
>
> **Two corrections to entries below, proven against the machine:**
> 1. The 2026-07-22 close-out's batch line says "drag patch **(built)**". It was
>    **not built.** The same entry says so 30 lines earlier ("the build was
>    interrupted... builds owed"). The patched output is not a valid store path;
>    stock unpatched Hyprland is running.
> 2. The handoff's "gen 25 booted, gen 26 staged and NEVER TESTED" is stale. The
>    machine has since **booted into gen 26**. The 2D half-snap rework is
>    activated — but still not live-tested.
>
> **Stage 2 is NOT closed.** Conditional pass only. Corner resize is reopened and
> non-negotiable (decision #11).
```

---

## 21. Commands and Files Inspected

### Files read in full

- `GRAND_PLAN.md` (706 lines) · `MASTER_REQUIREMENTS.md` (292) · `SESSION_PREAMBLE.md` (102) · `PM_HANDOFF.md` (261)
- `EXECUTION_LOG.md` — l.776–1320 in full (Stage 0 → close-out); l.131–200 and l.742–775 (July 16 era characterisation); full header map via `grep -n '^#'`
- `flake.nix` · `modules/nixos/patches/hyprland-drag-anchor.patch` · `modules/nixos/media-center.nix` · `modules/home/hyprland/hyprland/input.lua` · `general.lua` · `keybinds.lua` · `hyprbars.lua.in` · `~/.config/systemd/user/aurora-shell.service` · `/etc/t2fand.conf`
- `modules/nixos/desktop.nix` l.30–75 · `SOURCES.md` (head)

### Directories listed

`~/nix` · `modules/` (full tree to depth 3) · `modules/home/aurora-shell/` (top level + `modules/`) · `modules/home/hyprland/` (all files) · `modules/nixos/patches/` · `modules/home/hyprland/patches/` · `codex-prompts/` · `docs/` · `home/alex/` · `~/.local/state/aurora-build/pm/` · `~/.codex/sessions/2026/07/22/` · `/nix/var/nix/profiles/` · `~/.local/state/nix/profiles/` · `/boot/loader/entries/` · `/etc/libinput/`

### Commands run (all read-only)

**Git:** `git branch -vv` · `branch -a` · `rev-parse HEAD` · `status --short` · `status --porcelain -uall` · `remote -v` · `log --oneline -30` · `log --format='%h %ad %s' --date=iso` · `merge-base --is-ancestor df37152 HEAD` · `rev-list --left-right --count` · `worktree list` · `stash list`

**Nix / store:** `nix path-info` (validity checks on `azvhdgfz…-hyprland`, `gfbbpbalj…-hyprbars`) · `nix path-info --derivation` · `grep` over raw `.drv` ATerm text for `hyprland-drag-anchor.patch`, `hyprbars-hover.patch`, `"out","/nix/store/…"`, and cross-derivation hyprland references · `ls -d /nix/store/*hyprland-0.55*` and `*hyprbars*` · `readlink -f` on `/run/current-system`, `/run/booted-system`, `/nix/var/nix/profiles/system`, HM profiles · `grep -o` for store paths inside `system-25-link` / `system-26-link`

**systemd:** `systemctl --user status aurora-shell.service` · `systemctl --user show` (ExecStart, MainPID, KillMode, ActiveState, SubState, FragmentPath) · `systemctl --user list-units --type=service --all` · `systemctl --failed` (system + user) · `systemctl is-active t2fanrd`

**Hyprland:** `hyprctl version` · `hyprctl plugin list` · `hyprctl configerrors`

**Input:** `libinput list-devices` (via the pinned store path) · `udevadm info /dev/input/event7`

**Process:** `pgrep -a -f` for the shell/compositor/retired-component set · `cat /proc/1741/cgroup` · `readlink -f /proc/1741/exe`

**Filesystem:** `ls -la --time-style=long-iso|full-iso` on profiles and store locks · `diff` of `~/.config/hypr/hyprland/keybinds.lua` against the repo file · `find` for `*.patch` and for `*topbar*`/`*taskbar*` · targeted `grep -rn` over `--include=*.nix` for `extraHwdb`/`TOUCHPAD_INTEGRATION`/`dwt`/`restic`/`waybar`/`rofi`/`t2fanrd`/`bluetooth`/`nix-ld`/`npm-global`/`ozone` · `head`/`wc -l` on the Stage 3 event stream

### Deliberately NOT run

No `nix build`, `nixos-rebuild`, `home-manager switch`, `nix-env --set`, `switch-to-configuration`, `nix flake update`, `nix-collect-garbage`. No service start/stop/restart/reload. No `hyprctl reload`, `hyprctl keyword`, `hyprctl eval`, plugin load/unload. No `udevadm trigger`. No git write of any kind — no commit, add, stash, checkout, fetch, push. No reboot or suspend. No file in the repository was modified except the creation of this audit. No sudo password was requested.

---

## 22. Evidence Not Available / Not Inspected

Recorded honestly per `SESSION_PREAMBLE.md` §5 — absence of evidence is reported as such, never as evidence of absence.

### Blocked by permissions (no password requested, per the brief)

| Evidence | Why blocked | Impact |
|---|---|---|
| `/var/lib/bluetooth` contents | Root-only; `sudo -n` refused (build-harness NOPASSWD is scoped to deploy verbs) | Xbox pairing **persistence** unverified. The *configuration* (BlueZ LE tuning) is verified in the flake. |
| Live `iptables -S nixos-fw` | Root-only | The TV MAC-accept rule is verified **in the flake**, not in the running firewall. Log l.869–870 records it was verified inside the live firewall-start script at the Stage 0 gate. |
| `/nix/store/bkjrfi08…-hyprland-0.55.4.drv.chroot` | Root-owned, unreadable | Cannot recover the exact compiler stage where the build died. Immaterial — the build simply re-runs. |
| `/proc/1696/exe` and `/proc/1696/maps` (Hyprland) | `Permission denied` despite same-user ownership | Could not confirm the loaded `.so` from the process map. **Compensated:** the compositor path came from `pgrep -a -f` (full argv), and the plugin path from the live `hyprbars.lua` symlink target — both independent of `/proc` and sufficient. |

### Not inspected — out of scope or unnecessary

- `~/.config/nixos-local/` (the machine-local wrapper flake) — not in Git, not required to establish repository or generation truth.
- `ISSUE_LOG.md` (52 KB) — referenced indirectly via the execution log's §19/§20/§28 citations. Not read in full; a targeted read is advisable if a specific issue number becomes load-bearing.
- `OVERHAUL_PLAN.md`, `BUILD_PLAN.md`, `VISUAL_RESEARCH.md`, `RESEARCH_GUIDE.md`, `visual-design-reference.md`, `FABLE_PLAN_PROMPT.md`, `AURORA_OPERATOR_GUIDE.md`, `macbook-setup-handoff.md`, `nixos-hyprland-build-spec.md`, `macbook-build-spec.md`, `research/`, `repos/` — superseded by `GRAND_PLAN.md` (its l.4 says so) or research corpus outside this audit's scope. `macbook-build-spec.md` is on the PM Tier-1 list and should be read by the next PM even though it was not required to establish current state.
- The 451 files of `modules/home/aurora-shell/` — directory structure and top-level module inventory confirmed; individual QML not read. Not needed for state classification, and Stage 3 mapping is the session that should read it properly.
- `EXECUTION_LOG.md` l.200–742 — the July 16 era's implementation detail. Its architecture is retired; only its framing was needed.
- `~/.local/state/aurora-build/pm/*.md` reports (`dragresearch-final.md`, `dragpatch-final.md`, `stage2c-final.md`, `stage2d-final.md`) — presence and sizes confirmed; contents not read, because the execution log's summaries of them were verifiable directly against the machine, which is the stronger evidence.

### Deliberately not tested (brief prohibits)

TV reachability · Xbox controller pairing · `libinput measure touch-size` (interactive, needs Alex) · any drag/snap/resize/DWT behaviour requiring a live reboot or physical interaction · anything requiring a service restart to observe.

### Known measurement hazard on this machine

**The system clock is unreliable.** T2 RTC skew (ISSUE_LOG §28) makes `systemctl` report unit start times as 1970 and `uptime` report "up 20659 days." **Do not use `systemctl` timestamps or `uptime` as evidence on this machine.** This audit used file mtimes, store-path validity, and git commit dates instead — all of which are consistent with each other and with the recorded history.

---

*Audit complete. Read-only throughout. No configuration, generation, service, git object, or project file was modified — this document is the session's only write.*

