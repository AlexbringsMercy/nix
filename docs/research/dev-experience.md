# Dev Experience — Daily Two-Agent Developer Workspace

**Scope.** Source the daily two-agent (Claude Code + Codex) developer experience for the NixOS + Hyprland 0.55 +
QuickShell + Kitty + Fish build on the 2020 T2 MacBook Air (dual-core i3 1.1 GHz, 8 GB, Iris Plus, Apple keyboard,
Cmd = Super). Research only — no planning, execution, config-writing, or machine diagnostics. Machine steps
(Fish-key test, hook test, live preview cost) are flagged **[LIVE-TEST AT EXECUTION]**.

**Requirement map.** §7 Dev workspace (major) · §4.5 Fish accept key · §6 Terminal (Kitty) · §14 Neovim (active
eval) · §15 (Kitty Ctrl+Shift+T → reopening FILES → dev-workspace scope) · gaps **B1** (Alt+Tab), **C1** (agent
completion hooks), **C2** (persistent agent sessions).

**Visual-verification note (per the mandatory rules).** Every switcher / Neovim / Starship / find-file candidate
ranked below was **viewed by me directly** (images downloaded to the session scratchpad and opened with the image
viewer — full manifest + which I opened is in §11). Nothing here is ranked on source/README text alone. Web-fact
verification (Claude/Codex docs, Starship/Fish versions, Kitty syntax) was done by focused subagents that each
read `SESSION_PREAMBLE.md` first and returned a verified-vs-inferred audit; I re-state only what they verified and
flag the rest.

---

## 0. TL;DR — ranked picks

| Deliverable | Pick | Runner-up / hedge | Confidence |
|---|---|---|---|
| **B1 Alt+Tab (icon-card switcher)** | **snappy-switcher** — lightest (C/Cairo), true Alt+Tab hold-release, `cyberpunk`(teal)+`liquid-glassB`(dark-glass) themes ≈ target look via one `.ini` | **hyprshell** (nixpkgs + HM module, Hyprland-0.55-native) | High (viewed) |
| **B1 Alt+Tab (LIVE window content)** | **QuickShell cycler** — caelestia `windowinfo` `ScreencopyView` primitive + thin Hyprland cycler, or iNiR `skew` AltSwitcher (Niri→Hyprland port) | — | Med — heavier + more build |
| **§7 Dev workspace** | **Compose it** on caelestia `toggle.py` special-workspace orchestrator + named Kitty terminals + detached launchers | — | High (mechanism sourced) |
| **C1 Claude hook** | **Stop hook → notify-send** (stdin JSON cwd + `git status --porcelain`) | Notification hook for "needs input" | High (docs-verified) |
| **C1 Codex hook** | **`~/.codex/config.toml` `notify` program → notify-send** on `agent-turn-complete` | — | High (docs-verified) |
| **C2 Persistence** | **zellij** (pretty/low-fuss/built-in session serialization) — with `default_mode "locked"` | **tmux** (lighter, non-intrusive to agent TUIs) — the rational pick if RAM/keybind friction bite | Med — a values call |
| **Find-file** | **fzf** (`--style full` + bat) in a Kitty overlay — lightest + first-class fish | **television** (bat preview default + channels) | High (viewed) |
| **Starship** | **tokyo-night structure**, refactored into a central `[palettes.aurora]` block (+ teal token) | **catppuccin-powerline** (ready palette exemplar / if powerline pills preferred) | High (viewed) |
| **Neovim (§14)** | **LazyVim** (most VS-Code-like → serves the "replace VS Code" goal; tokyonight; proven by saatvik333) | **NvChad** / **kickstart** if a live startup/RAM test on the i3 argues lighter | Provisional — **decide after workspace lands** |
| **Fish accept key (§4.5)** | **Right-Arrow** (and **Ctrl-F**) = default `forward-char`, full-accept at EOL | Alt-Right / Alt-F = one word (`forward-word`) | High (default confirmed) |

Kitty path-click (`kitten hints`) and detached-launch (`systemd-run --user --scope` / `setsid -f`) are settled
mechanisms used throughout.

---

## 1. ALT+TAB WINDOW SWITCHER (B1) ✅ viewed & ranked

**Gap.** Today Alt+Tab does nothing — a large Windows-muscle-memory hole and the keyboard half of the
mouse+keyboard redundancy philosophy (§2). Target: a styled switcher with window previews, keyboard **and** mouse
operable, restyleable to dark-glass blue/purple/teal.

### 1.1 The distinction that decides this (confirmed by viewing the images myself)

**"Window previews" splits two ways, and the candidates fall on opposite sides:**
- **Icon-card switchers** (hyprshell, snappy-switcher) show a per-window tile = **app icon + window title** (+
  keybind badge + window-count badge). I viewed this directly: snappy `liquid-glassB`/`cyberpunk` and
  `hyprshell-switch.png` are all icon cards — **no live window content.**
- **Live-content switchers** (QuickShell path) show an actual live capture of each window via
  `ScreencopyView { live: true }`. Verified in code: caelestia `modules/windowinfo/Preview.qml`, iNiR `skew`
  AltSwitcher (`WindowPreviewService`), end-4 `overview/OverviewWindow.qml`.

Given the user's repeatedly-stated attraction to caelestia's **"live window preview popouts"**, "previews" most
likely means live content. So this deliverable has **two honest tiers**, and the right move is to bind an
icon-card switcher now (immediate relief, light) while evaluating a live-content QuickShell cycler as the
matches-the-shell target — the user decides after seeing both live.

### 1.2 Candidate comparison (all viewed unless noted)

| Candidate | Preview type | Hyprland 0.55 fit | Themeable → dark glass | Weight (i3) | Packaging | Notes |
|---|---|---|---|---|---|---|
| **snappy-switcher** (OpalAayan) | Icon+title cards | Native (0.55 Lua + legacy) | **`.ini`**: colors, radius, blur, card size — 15 themes incl. `liquid-glassB` (dark glass), `cyberpunk` (teal) | **Lightest** — C/Cairo | Nix **flake** (`nix profile install github:OpalAayan/snappy-switcher`); not yet in nixpkgs | True Alt+Tab hold-release + toggle mode. Viewed: compact centered glass overlay, genuinely polished; cyberpunk = teal-on-glass already. |
| **hyprshell** (H3rmt; **renamed from hyprswitch**) | Icon+title cards | **Requires ≥0.55.0** (stated) | GTK4 CSS (`--custom-css`) + built-in themes | Medium — GTK4 | **nixpkgs + home-manager module** (best Nix fit) | Daemon + `gui`. Viewed: cleaner but **flatter** tiles than snappy; **also a launcher + calculator** → overlaps the decided caelestia launcher (cohesion cost). |
| **caelestia `windowinfo` (ScreencopyView)** | **LIVE content** | **Native** (`HyprlandToplevel`, `Quickshell.Hyprland`) | Your QML/glass tokens | Heavier (per-window GPU capture) | Part of a shell | Single-window hover popout, **not** a multi-window cycler — but the best Hyprland-native **live-preview primitive** to build one on. `Buttons.qml` = ready window-action dispatch (see §2.6). |
| **iNiR `skew` AltSwitcher** | **LIVE content** (Cover-Flow deck) | **Niri-coupled** — `NiriService.*`; not wired to iNiR's own dual-compositor `CompositorService` | **Excellent** token branches (`auroraEverywhere` → layer/primary/border; `backgroundOpacity`/`blurAmount`/`scrimDim`) + **perf guards** (`isHighLoad`>15 → blur/anim off; icon LRU cache) | Heaviest | Part of a shell | Richest UX (MRU, presets, kbd+mouse, quick-switch). **Hyprland port is real work**: swap window model + MRU + focus + a `ScreencopyView` preview source. |
| **DankMaterialShell** | overview thumbnails | **Hyprland-first** (`HyprlandService`, `CompositorService.sortedToplevels`, `Hyprland.toplevels`) | DMS Material tokens | Medium–heavy | Flake/HM | **No dedicated Alt+Tab module** (`WorkspaceSwitcher.qml` = *workspace* switcher). Provides toplevel plumbing + dock + `WorkspaceOverlays` overview — a base, not a drop-in. |
| **hyprexpo** (Hyprland plugin) | LIVE **workspace** thumbnails | v0.55.4 ABI-pinned | plugin config | Medium | Plugin | Expo grid, **not** Alt+Tab. A cheap spatial complement (mouse-driven "show all"). |
| **Hyprland built-in** `cyclenext` + `bringactivetotop` | none (no UI) | Native | n/a | Zero | Built-in | The fallback. **Bind it now** so Alt+Tab is never dead while the styled one is chosen. |

*(Not window switchers: `sherlock` = app launcher; `hypr-alttab`/kanak-buet19 = "vibe-coded," unmaintained,
unpackaged, no viewable still — excluded on low confidence, not declared nonexistent.)*

### 1.3 Ranking + glass-token adaptation estimate

**Tier A — ship an icon-card switcher now (immediate muscle-memory relief, light):**
1. **snappy-switcher** — best fit. True Alt+Tab hold/release, lightest option (ideal for the i3), and its themes
   already carry the target look: `cyberpunk` (teal) + `liquid-glassB` (dark glass). **Adaptation: LOW** — one
   `.ini` (merge dark-glass base + teal/purple accent, set radius/blur/card size). Caveat: icon cards, not live
   content; Nix flake (not nixpkgs).
2. **hyprshell** — best **Nix-native + maintained** (nixpkgs + HM, 0.55-required). **Adaptation: LOW–MEDIUM**
   (GTK4 CSS, reuses the GTK theming pipeline). Downsides: flatter look; it's also a launcher (overlaps caelestia
   launcher — either disable its launcher/calc or accept redundancy).

**Tier B — the live-content, matches-the-shell target (heavier, more build):**
3. **caelestia `windowinfo` ScreencopyView primitive + a thin Hyprland cycler** — Hyprland-native live previews
   with our own glass container + focus-grab coordinator. **Adaptation: MEDIUM** (the preview is free; the cycler
   UI is the build, kept small by reuse). The cleanest path to true live previews that match the QuickShell shell.
4. **iNiR `skew` AltSwitcher, ported** — the richest UX and already token-themeable to "aurora" (glass styling is
   LOW effort — drop target values into its `auroraEverywhere` slots), **but** the Niri→Hyprland compositor swap
   is MEDIUM–LARGE. Choose only if we want a QuickShell-native switcher and are willing to port.

**Safety net:** bind Hyprland `cyclenext + bringactivetotop` immediately regardless; add `hyprexpo` for a
mouse-driven expo overview (redundancy philosophy).

> **Recommendation:** prototype **snappy-switcher** now (bind Alt+Tab, teal/glass `.ini`) for instant relief at
> near-zero cost, and in parallel stand up the **caelestia-ScreencopyView live-content cycler** as the
> matches-the-shell option; let the user compare live and decide whether icon cards suffice or they want live
> previews. Do not commit to one on my say-so — this is a look/behavior call only the user can close after seeing
> both running.

---

## 2. §7 DEV WORKSPACE — composition ✅ orchestrator sourced

No single community repo closes §7 (SYNTHESIS.md confirms). This session sources the **orchestration mechanism**
so each piece maps to real code and the bespoke glue is minimal.

### 2.1 The spine — caelestia `toggle.py` special-workspace orchestrator

`~/nix/repos/caelestia/cli-main/cli-main/src/caelestia/subcommands/toggle.py` (read in full) is directly
adaptable. Its model:
- Map **workspace-name → {client: {`match`, `command`, `move`, `enable`}}**.
- `run(name)`: for each enabled client → `spawn_client` (if the binary exists **and** no matching client is open:
  `hyprctl dispatch exec "[workspace special:NAME] <cmd>"` — spawns **directly into** the special workspace) and/or
  `move_client` (`movetoworkspacesilent special:NAME,address:<addr>`). If nothing spawned → `togglespecialworkspace NAME`.
- Its **sysmon** client is the "named terminal in a special workspace" template:
  `["foot","-a","btop","-T","btop","fish","-C","exec btop"]` (`-a` class, `-T` title).
- `rules.lua` (l.108–118) pins apps to workspaces: `hl.window_rule({ match = { class = "btop" }, workspace =
  "special:sysmon" })`; `keybinds.lua` (l.128–132) binds toggles: `hl.dsp.exec_cmd("caelestia toggle sysmon")`.

**Adaptation (small, attributable glue):** add a `dev` toggle whose clients are the two agent terminals (+ btop /
git pane), each spawned **named** into `special:dev`, bound to a key **and** a bar/dock button, plus a `rules.lua`
entry pinning `class = dev-*` → `special:dev`. A fork of a proven orchestrator, not from-scratch. (If we skip the
caelestia CLI, the same logic is ~40 lines of Fish/Python around `hyprctl dispatch exec "[workspace special:dev]
…"` — but `toggle.py` is the file to vendor.)

### 2.2 Named + ICON Kitty terminals

No repo has a rich Kitty named/icon example (saatvik333 `kitty.conf` is minimal: opacity 0.9, 5k scrollback;
caelestia uses Foot). Sourced from Kitty's own options — **[LIVE-TEST AT EXECUTION]** confirm exact override keys:
- **Name / identity (for Hyprland rules + taskbar icon):** `kitty --class dev-claude` sets the Wayland app-id /
  `WM_CLASS`; Hyprland matches `class = dev-claude` to route into `special:dev` and to select the Papirus icon via
  a matching desktop entry. **This is the primary "icon" lever.**
- **Title:** `kitty --title "Claude Code"`; a stable tab title via `tab_title_template` (a running program can
  still rewrite the OS-window title, so lean on `--class` for identity).
- **In-window brand mark:** Kitty `window_logo_path` (a PNG watermark), per-window via `--override
  window_logo_path=…` — e.g. distinct Claude vs Codex glyphs.

### 2.3 One-click launchers (each in its own terminal, detached)

- **Claude:** `kitty --class dev-claude --title "Claude Code" --directory <repo> fish -C "claude --dangerously-skip-permissions"`
- **Codex:** `kitty --class dev-codex --title "Codex" --directory <repo> fish -C "codex --yolo"` (see §3.2 for the
  verified yolo flag).
- **Detachment is mandatory** (§5 bug + accepted finding "bar restart kills child-launched apps until detached").
  Sourced pattern = iNiR `ShellExec` → **`systemd-run --user --scope --collect …`** (survives shell reload);
  shell-simple equivalent `setsid -f …`. Every button/keybind launch uses one so a QuickShell reload never takes
  an agent down. Spawn **into `special:dev`** via `exec [workspace special:dev] …`, so one click launches + files
  the agent. Pair with §4 (tmux/zellij) so the agent also survives the *terminal* dying.

### 2.4 Quick terminal spawn, preset working dirs

Kitty `--directory <path>` opens already-`cd`'d. A small menu of preset repos (`~/nix`, current project) →
buttons/keybinds each doing `kitty --class dev-term --directory <preset>` into `special:dev`. In-Kitty complement:
`map … launch --cwd=current --type=os-window` (new terminal inheriting the current dir).

### 2.5 File viewer/search pane + click-any-path-to-open

- **Path-click → editor:** `kitten hints` (settled). Exact `map` lines confirmed — see §5.3.
- **Find-file overlay:** fzf/television Kitty overlay (§5) for fast project open.
- **In-editor file browser:** if Neovim becomes the pane, its picker (LazyVim fzf-lua/snacks). Note saatvik333's
  "find-file" is *this* (its LazyVim dashboard), not a shell tool — §5.1.

### 2.6 Easy window movement in/out (button + hotkey) ✅ exact dispatch sourced

caelestia `modules/windowinfo/Buttons.qml` (read in full) is the reusable pattern — for the focused window it
renders a **10-workspace move grid** (5-col), each button dispatching
`hl.dsp.window.move({ window = "address:0x<addr>", workspace = "<N>", follow = true })` (Lua) /
`movetoworkspace <N>,address:0x<addr>` (legacy), plus **Float/Tile**, **Pin/Unpin**, **Kill** via
`hl.dsp.window.{float,pin,kill}`. This is the **mouse** path to move an agent terminal in/out of `special:dev`
(and doubles as a §4.15 per-window-controls reference); the **hotkey** path is caelestia's
`hl.dsp.window.move({ workspace = "special:dev" })` bind. Redundancy (button + hotkey), both from one repo.

### 2.7 System info + git status + agent-session status "at a glance"

- **System info / startup art:** btop in `special:dev` via the caelestia sysmon pattern (restyle Foot→Kitty).
  caelestia `fastfetch/config.jsonc` is a **boxed dark-blue-gradient** panel (`╭──╮` borders; ANSI `37/16/17/18`
  = white + three deep blues) — a strong §6 startup-art reference (distinct from saatvik333's nvim-dashboard ASCII).
- **Git status:** (a) Starship git modules already render branch/status/state in every agent prompt (saatvik333's
  `starship.toml` enables `$git_branch $git_commit $git_state $git_status`); (b) a persistent `lazygit` pane in
  `special:dev` (caelestia Fish already has `abbr lg lazygit`, `abbr gs 'git status'`). A "summary for active
  repos" tile = a small script looping `git -C <repo> status --porcelain | wc -l` per pinned repo — small glue.
- **Agent-session status:** the **completion hooks** (C1, §3) turn "finished / needs attention" into a desktop
  notification; the multiplexer list (C2, §4: `tmux ls` / `zellij ls`) shows which agents are alive. A QuickShell
  tile can render both (bell state + a line per live session) = the "which agent needs me" glance.

> **§7 honesty:** the composition is fully sourced; genuinely bespoke glue (unavoidable) = the `dev` toggle entry,
> the per-repo git-count script, the agent-status tile wiring. No UI built from scratch — all sits on caelestia's
> orchestrator, Kitty flags, Starship/git, and the C1/C2 mechanisms.

---

## 3. AGENT COMPLETION HOOKS (C1) — highest-value notification source

### 3.1 Claude Code — Stop hook → notify-send ✅ docs-verified

- **Which hook:** **Stop** fires when Claude finishes responding (→ "Claude finished in ~/nix"). **Notification**
  fires when Claude needs input/permission (matchers incl. `idle_prompt`, `permission_prompt` → "needs you").
  Wire **both**.
- **Config** (`~/.claude/settings.json`; event → matcher group → handlers array):
  ```json
  { "hooks": { "Stop": [ { "matcher": "",
      "hooks": [ { "type": "command",
                   "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/agent-notify.sh",
                   "timeout": 5 } ] } ] } }
  ```
- **Data on stdin (JSON, verified fields):** `session_id`, `cwd`, `transcript_path`, `hook_event_name`,
  `stop_hook_active`, `prompt_id`, `permission_mode`. Env: `$CLAUDE_PROJECT_DIR`.
- **"finished in ~/nix — 3 files changed":** read `cwd`; count changes via `git -C "$cwd" status --porcelain | wc -l`:
  ```bash
  #!/usr/bin/env bash
  input=$(cat)
  [ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ] && exit 0   # re-fire guard
  cwd=$(jq -r '.cwd' <<<"$input"); disp="${cwd/#$HOME/~}"
  changed=$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l)
  setsid -f notify-send "Claude finished" "$disp — ${changed} files changed" -a "Claude Code" >/dev/null 2>&1
  exit 0
  ```
- **Gotchas (verified):** `stop_hook_active` guards the Stop re-fire loop (docs cap consecutive Stop-blocks at 8) —
  exit 0 when true. Exit codes: **0** proceed, **2** block (stderr → Claude), other = non-blocking error.
  **Non-blocking is guaranteed by `setsid -f`** on the notify — do NOT rely on the schema `async` field: it
  exists but its exact behavior is **undocumented** → **[LIVE-TEST AT EXECUTION]**. `notify-send` needs the user
  session bus (inherited when fired from the graphical session) — **[LIVE-TEST]** confirm a toast appears.

### 3.2 Codex — the `notify` wrapper equivalent ✅ docs-verified

- **Mechanism:** Codex spawns an external program named in `~/.codex/config.toml` `notify` (a top-level array,
  **before** any `[table]`), passing a **single argv arg = JSON**. Fields: `type`, `thread-id`, `turn-id`, `cwd`,
  `input-messages`, `last-assistant-message`. **Only event type currently = `agent-turn-complete`** (fires on turn
  completion, not on approval prompts — irrelevant under yolo).
  ```toml
  # ~/.codex/config.toml  (top of file)
  notify = ["python3", "/home/alex/.codex/notify-send.py"]
  ```
  ```python
  #!/usr/bin/env python3
  import json, os, subprocess, sys
  if len(sys.argv) < 2: sys.exit(0)
  try: n = json.loads(sys.argv[1])
  except ValueError: sys.exit(0)
  if n.get("type") != "agent-turn-complete": sys.exit(0)
  repo = os.path.basename((n.get("cwd") or "").rstrip("/"))
  subprocess.run(["notify-send", "-a", "Codex",
                  f"Codex done — {repo}" if repo else "Codex done",
                  n.get("last-assistant-message") or "Turn complete"])
  ```
- **Yolo launcher (verified):** `codex --yolo` (alias for `--dangerously-bypass-approvals-and-sandbox`) — no
  approvals, no sandbox, **not** deprecated. Granular equivalent: `codex -a never -s danger-full-access`. Config
  equivalent: `approval_policy = "never"` + `sandbox_mode = "danger-full-access"`. **`--full-auto` is DEPRECATED**
  (prints a warning) — do not use it.
- **[LIVE-TEST]** `python3 ~/.codex/notify-send.py '{"type":"agent-turn-complete","cwd":"/home/alex/nix","last-assistant-message":"hi"}'`
  → a toast should appear; if not, the notification daemon isn't running (that's the fault point, not the script).

---

## 4. PERSISTENT AGENT SESSIONS (C2) — tmux vs zellij ⏳ a values call

**Use case:** run `claude`/`codex` **inside** a multiplexer so a Kitty crash/accidental-close doesn't kill the
agent — reattach and continue. Directly counters the §5 bug "CLI agents … silently breaking sessions that then
need resuming" from the other side: the session outlives the window.

**Verified reality:** **neither** tmux nor zellij resumes a live *process* across a **reboot** (tmux-resurrect
"does not restart actual processes"; zellij re-runs the pane's command behind a "Press ENTER to run" banner). For
the actual use case — machine stays up, window dies — **both work perfectly**: the multiplexer server keeps the
agent running; reattach gives the exact live process mid-run.

| Axis | tmux | zellij |
|---|---|---|
| Reattach | `tmux attach -t NAME`; detach `Ctrl-b d` | `zellij attach NAME`; detach `Ctrl-o d`; on-screen hints |
| Discovery | `tmux ls` | `zellij ls` + built-in **session manager** (`Ctrl-o w`, lists live + exited) — prettier |
| Reboot persistence | **Not built-in** — tmux-resurrect + continuum (`@continuum-restore 'on'`, 15-min autosave); layout+cwd only unless procs whitelisted | **Built-in, default on** — `session_serialization` (layout+commands), `pane_viewport_serialization` (scrollback) |
| Footprint (i3/8 GB) | **Very light** (C, single-digit MB) | Heavier (Rust, tens of MB) — the machine already runs two agents + browser |
| Learning curve | Invisible **prefix** (`Ctrl-b`) — the classic ex-Windows/macOS friction | Mode-based + on-screen hints; no invisible prefix — friendlier, prettier |
| Auto-attach one named session | `tmux new-session -A -s NAME -c DIR '<cmd>'` — clean one-liner | `zellij attach --create` **cannot auto-run a command** (issue #4463) → needs a small layout |
| Interference with agent TUI | **Minimal** — only `Ctrl-b` intercepted; everything else reaches Claude/Codex | **Real gotcha** — default binds shadow `Ctrl-o/p/n/t/s/g/…` used by the agent TUIs → fix with `default_mode "locked"` (ignore keys until `Ctrl-g`) |

**Launchers.** tmux: `tmux new-session -A -s claude-nix -c ~/nix 'claude --dangerously-skip-permissions'`.
zellij: needs a layout (`~/.config/zellij/layouts/claude.kdl` with `pane command="claude" { args
"--dangerously-skip-permissions" }`) then `zellij attach claude-nix || zellij -s claude-nix --new-session-with-layout claude`.

**Recommendation.** **zellij** for the user's stated values (pretty, low-fuss, muscle-memory, zero-config
survive-accidental-close, built-in serialization) — add the one line `default_mode "locked"` to stop keybinding
collisions with the agent TUIs. **But surface honestly:** for *this exact* use (a weak dual-core i3/8 GB already
running two agents, with the agents themselves being full-screen TUIs), **tmux's lightness + near-zero
interference are strong enough that it's a legitimate coin-flip** — it's the rational pick if RAM pressure or the
TUI-keybinding friction bite in practice (cost: the prefix learning curve + wiring resurrect/continuum for reboot
persistence). Both survive accidental close equally; this is UX-vs-frugality, not a capability gap.

*(Orthogonal to Neovim's persistence.nvim session restore in §5.1 — that restores an editor session; tmux/zellij
keep the agent process alive.)*

---

## 5. TERMINAL FIND-FILE / OPENER ✅ viewed & ranked

### 5.1 What saatvik333 actually provides (task-requested clarification)

Full read of `~/nix/repos/saatvik333-hyprland-dotfiles`:
- **"terminal art"** = `nvim/lua/plugins/dashboard.lua` — a **LazyVim `dashboard-nvim` (doom theme)** ASCII "I use
  NVIM" cat. Not a shell fastfetch.
- **"find-file"** = the dashboard's `Find File` → `LazyVim.pick()` and `Find Text` → `live_grep`. **Editor**
  actions, not a shell tool.
- **"session restore"** = dashboard `Restore Session` → `require("persistence").load()` (**persistence.nvim**) —
  an *editor* session (distinct from C2 agent persistence).
- Kitty minimal (opacity 0.9, 5k scrollback); Fish uses `fish_default_key_bindings`.

**Consequence:** the standalone terminal find-file/opener is a **fresh source** (saatvik333 doesn't provide it at
the shell level); Neovim's picker/session-restore apply only if Neovim becomes the editor pane.

### 5.2 fzf vs television (+ bat) in a Kitty overlay ✅ both viewed

Viewed `fzf-style-full.png` (two-pane, rounded borders, bat-highlighted preview, `1/370` scroll) and
`television-tv-transparent.png` (two-pane, channel status bar, bat preview on transparent bg) — **both are
genuinely pretty**; the old "fzf is ugly" is obsolete with `--style full`.

| Axis | fzf | television (`tv`) |
|---|---|---|
| Footprint (i3) | **Instant, tiny** (Go, mature) | Heavier Rust TUI (async preview threads) |
| bat preview | one line `--preview 'bat --color=always {}'` | **built-in default** |
| Fish integration | **first-class official** keybindings | weaker (`tv init` documents bash/zsh; fish glue DIY) |
| Extensibility | env + shell scripting | **channels** (files/text/git-repos + custom TOML) |
| In nixpkgs | Yes | Yes |

**Recommendation: fzf primary** (lightest, first-class fish, `--style full` + one-line bat = the pretty two-pane
look), **television secondary** (preview-on-by-default + channels; pick it if you want batteries-included and don't
mind hand-rolling fish glue). Both in nixpkgs → trying both is free.

**Kitty overlay launch (open selection in editor):**
```conf
# fzf find-file overlay
map super+p launch --type=overlay --cwd=current sh -c "fd --type f | fzf --style full --preview 'bat --color=always --line-range :200 {}' | xargs -r -o $EDITOR"
# television variant (preview built-in)
map super+p launch --type=overlay --cwd=current sh -c "tv files | xargs -r -o $EDITOR"
```
`xargs -o` reopens the tty so terminal editors get a controlling terminal (drop for GUI `code`). Cmd = Super, so
`super+p` is a Cmd bind — watch for conflicts with Hyprland's own Super binds (those fire at the compositor;
these only inside Kitty).

### 5.3 kitten hints path-click (settled mechanism; current syntax confirmed)

```conf
# (a) open path under cursor in the editor
map super+shift+f kitten hints --type path --program "nvim"
#     …or the OS default opener (your §4.1 xdg map routes code/.md → VS Code):
# map super+shift+f kitten hints --type path --program default
# (b) open path:line AT the line
map super+shift+g kitten hints --type linenum --linenum-action self nvim +{line} {path}
#     VS Code: kitten hints --type linenum --linenum-action background code --goto {path}:{line}
```
`--program` accepts `-`(paste) `@`(clipboard) `default`(OS opener) `launch` or a custom program;
`--linenum-action` ∈ `self|window|tab|os_window|background`.

---

## 6. STARSHIP ✅ viewed; palette-wiring confirmed

**Viewed** `catppuccin-powerline.png` (palette-driven but a **busy multi-hue powerline**) and `tokyo-night.png`
(**cleaner/minimal** dark pills, blue/purple accents, on a glass terminal — the better fit for "dark clean glass
with aurora"). saatvik333 `starship.toml` is a solid **structural** base (format order + Nerd-Font symbol set) but
not aurora and not centrally themed; caelestia's Starship is CLI-generated (no static TOML to vendor).

**Palette-token themeability (the hard requirement) — confirmed.** Starship named palettes exist since **v1.11.0**
(Oct 2022; current **v1.26.0** — the earlier "~v1.16" guess was wrong): a top-level `palette = "aurora"` + a
`[palettes.aurora]` block of named colors, referenced everywhere as `style = "bold blue"`. Swap = one block.
Caveat: palette entries are literal hex — they **cannot reference each other**.

**Recommendation (my visually-grounded call, which refines the subagent's):** the palette *mechanism* is
independent of the preset's busyness, so pick the cleaner **tokyo-night structure** (best match for the clean
glass aesthetic) and **refactor its hardcoded hex into a central `[palettes.aurora]` block, adding a teal token** —
a small edit. Use **catppuccin-powerline** as the ready-made palette-mechanism exemplar (it already ships exactly
this pattern), or as the base itself if the user prefers powerline pills. Bootstrap either with
`starship preset tokyo-night -o ~/.config/starship.toml` (or `catppuccin-powerline`) then swap in:
```toml
palette = "aurora"
[palettes.aurora]
base    = "#0b0f1a"   # deep dark blue-black
surface = "#161c2c"
overlay = "#2a3346"
text    = "#c0caf5"
blue    = "#7aa2f7"   # → directory
purple  = "#bb9af7"   # → git
teal    = "#2ac3de"   # → languages / duration
# modules reference token NAMES only, e.g.:
[directory]  { style = "bold blue" }
[git_branch] { style = "bold purple" }
[python]     { style = "teal" }
[cmd_duration] { style = "teal" }
```
The wallpaper-adaptive pipeline (caelestia/Matugen fan-out) writes `[palettes.aurora]` from the **pinned** deep
surfaces + adaptive accents, so Starship recolors with the rest of the system (§3 cohesion).

---

## 7. NEOVIM EVALUATION (§14) ✅ all three viewed — decide AFTER the workspace lands (§15)

**Current facts (verified):** Neovim stable **v0.12.4**, which shipped **`vim.pack`** (built-in git plugin manager,
eager — no lazy-loading). **kickstart.nvim** migrated to `vim.pack` (single `init.lua`, `tokyonight-night`).
LazyVim / NvChad / AstroNvim still use lazy.nvim's aggressive lazy-loading. Weight order (relative, solid):
**mini < kickstart < NvChad < LazyVim < AstroNvim** (absolute RAM MBs are estimates — flag as live-measure).

**What I saw (opened each myself):**
- **LazyVim** (`lazyvim-03-ide-screenshot.png`): full IDE — Neo-tree + buffer tabs + live LSP completion &
  signature/doc popup, tokyonight deep blue/purple. The most complete, most VS-Code-like — and already in the
  target palette lane.
- **NvChad** (`nvchad-banner.webp`): clean 3-pane, custom tab/statusline (LSP, pomodoro), an embedded `astro dev`
  terminal. Visibly **lighter/less dense** — "lightest that's still pleasant."
- **AstroNvim** (`astronvim-dark.webp`): the **densest** — adds a right-side symbols-outline (aerial) panel +
  winbar breadcrumbs. Heaviest/most-abstracted.

**Real-world anchor (local):** saatvik333 — a polished dark-glass Hyprland rice — runs **LazyVim** successfully
(its dashboard/picker/persistence), i.e. LazyVim is proven in exactly this aesthetic lane.

**Recommendation (provisional; final call post-workspace per §15):** **LazyVim**, because §7's stated goal is
"potentially reducing/replacing VS Code reliance" — for that, VS-Code-familiarity/completeness *is* the point,
tokyonight matches the palette, and saatvik333 proves it runs in this exact setup. **Hedge:** on a dual-core
i3/8 GB already running two agents + a browser, footprint is real — so gate the decision on a
**[LIVE-TEST AT EXECUTION]** startup/RAM measurement; if LazyVim feels heavy, drop to **NvChad** (lightest-pleasant)
or **kickstart** (single-file, you-own-it). **Skip AstroNvim** here (heaviest, most abstraction, no payoff on this
hardware). NixOS: lazy.nvim distros work by cloning (plugins live in user dirs; need `git` + a C compiler for
Treesitter); for full reproducibility use **nixCats** (wraps LazyVim/kickstart with store-sourced plugins) or
**kickstart-nix.nvim**.

---

## 8. FISH AUTOSUGGESTION ACCEPT KEY (§4.5) ✅ default confirmed

**Answer (verified vs fish 4.x docs + both reference repos):**
- **Accept the WHOLE suggestion:** **Right-Arrow** or **Ctrl-F** (both `forward-char`; accept only when the cursor
  is at **end of line** — mid-line they just move the cursor).
- **Accept ONE word:** **Alt-Right** or **Alt-F** (both `forward-word`).
- These are **fish defaults — no rebinding needed.** Evidence: saatvik333 `fish/fish_variables` →
  `fish_key_bindings:fish_default_key_bindings`; caelestia `fish/config.fish` adds abbreviations but no accept
  rebind. If ever wanted (fish 4.x named-key syntax): `bind right forward-char` / `bind ctrl-f forward-char` /
  `bind alt-right forward-word` in `fish_user_key_bindings`.
- **Apple keyboard / Kitty / Wayland:** Right-Arrow, Ctrl-F, Alt-F, Alt-Right pass straight through (Kitty doesn't
  `map` them by default). The Apple left-Alt is an ordinary Mod1 here (`macos_option_as_alt` is macOS-only,
  irrelevant). Only possible steal: Hyprland binding `Alt+Right` (unlikely — Hyprland binds use Super).

**[LIVE-TEST AT EXECUTION] (2 min):**
1. Kitty → Fish. Run `echo hello world` once (seed history).
2. Type `echo hel`, stop — grey `lo world` appears (cursor at EOL).
3. Press **Right-Arrow** → whole suggestion fills. ✔ full-accept.
4. Retype `echo hel`, **Ctrl-F** → same (confirms the non-arrow key on the Apple keyboard).
5. Retype, **Alt-Right** (or Alt-F) → only next word fills. ✔ word-accept.
6. If step 5 does nothing: `hyprctl binds | grep -i alt` (Hyprland may own Alt+Right) — use Right-Arrow / Ctrl-F
   for full-accept regardless.

---

## 9. BONUS FINDS (dev-quality wins, flagged)

- **caelestia Fish abbreviations** (`fish/config.fish`) — ready git/ls set (`lg lazygit`, `gs git status`,
  `gd git diff`, `ga git add .`, `gc git commit -am`, `l/ll/la/lla`). Cheap daily-quality win; vendor the block. (§6)
- **caelestia `windowinfo/Buttons.qml`** doubles as the **§4.15 per-window controls** source (Float/Tile, Pin,
  Kill, move-grid) via `hl.dsp.window.*` — one source serves §7 movement + §4.15.
- **caelestia `fastfetch/config.jsonc`** — boxed dark-blue-gradient system-info panel; strong §6 startup-art
  candidate distinct from saatvik333's nvim-dashboard ASCII.
- **iNiR AltSwitcher perf guards** (`isHighLoad` disables blur/anim >15 windows; icon LRU cache; 50 ms debounce) —
  a reusable pattern for ANY heavy QuickShell surface on this i3 (§10 performance budget), even if the switcher
  itself isn't adopted.
- **snappy-switcher `cyberpunk` theme** is already ~90% the target "teal-on-dark-glass" token set — a near-free
  aesthetic head start for B1.
- **fzf `--style full`** and **television transparent + channels** both make a pretty overlay; television's `text`
  channel is a fast in-terminal live-grep worth binding alongside find-file.
- **hyprexpo** (Hyprland plugin) — cheap mouse-driven expo overview; pairs with Alt+Tab for the redundancy
  philosophy.

---

## 10. LIVE-TEST-AT-EXECUTION checklist (nothing run this session)

- Claude Stop hook fires a toast; `async:true` non-blocking behavior; D-Bus reach from the hook.
- Codex `notify` toast; `codex --yolo` current behavior.
- Fish accept keys on the Apple keyboard (steps in §8); `hyprctl binds | grep -i alt`.
- Kitty `--class`/`--title`/`window_logo_path` override keys; `kitten hints` `map` lines; overlay launch.
- Live `ScreencopyView` per-window preview cost on Iris Plus (B1 Tier B); snappy/hyprshell render cost.
- zellij vs tmux idle RAM on the actual machine; agent-TUI keybinding collisions under zellij.
- Neovim startup/RAM on the i3 (LazyVim vs NvChad) — the gate for the §14 decision.

---

## 11. WHAT I ACTUALLY READ / VIEWED vs WHAT I DID NOT

**Read in full (local disk, this session):**
- `MASTER_REQUIREMENTS.md` (entire); `SYNTHESIS.md` Terminal/Kitty (l.228–242) + §7 (l.276–289) closely (rest of
  the 858-line file NOT read line-by-line); `caelestia.md` (entire).
- iNiR `modules/altSwitcher/AltSwitcher.qml` (l.1–1507 directly; remainder confirmed via grep of
  functions/NiriService lines through l.2002); iNiR `services/CompositorService.qml` (head) +
  `WindowPreviewService.qml` (grep — NiriService coupling).
- caelestia `shell-main/.../modules/windowinfo/Preview.qml` + `Buttons.qml` (entire); `hypr/hyprland/keybinds.lua`
  (entire), `rules.lua` (special-ws/rules), `variables.lua` (kb*/app vars);
  `cli-main/.../subcommands/toggle.py` (entire); `fish/config.fish` (abbr/init) + `fastfetch/config.jsonc` (head).
- saatvik333 `nvim/lua/plugins/dashboard.lua` (entire), `starship/starship.toml` (entire), `kitty/kitty.conf`
  (grep), `fish/fish_variables` (accept-key line).
- DankMaterialShell `quickshell` Modules/Services layout + Dock (`DockApps.qml`, `DockAppButton.qml`) Hyprland
  toplevel usage + switcher grep (confirmed NO dedicated Alt+Tab module).

**Images I VIEWED myself (opened with the image viewer — the ranking basis):**
- Switcher: `snappy-liquid-glassB.png`, `snappy-cyberpunk.png`, `hyprshell-switch.png`, `hyprshell-img.png`.
- Neovim: `lazyvim-03-ide-screenshot.png`, `nvchad-banner.webp`, `astronvim-dark.webp`.
- Starship: `catppuccin-powerline.png`, `tokyo-night.png`.
- Find-file: `fzf-style-full.png`, `television-tv-transparent.png`.
- (Downloaded but not opened by me: the remaining snappy themes, hyprshell launcher/calc extras, television/fzf
  alt shots, LazyVim logo/dashboard, astronvim-light — redundant variants of what I did view.)

**Web-verified by subagents (each read SESSION_PREAMBLE.md first; returned verified-vs-inferred audits):**
- Claude Code hooks (docs-verified; only `async` behavior inferred → flagged). Codex `notify` + yolo flags
  (docs-verified). tmux vs zellij (docs-verified; RAM figures order-of-magnitude only). Neovim versions/weights +
  Starship palette version (v1.11.0) + Fish accept keys (docs-verified). Kitty overlay + `kitten hints` syntax
  (kitty docs). Subagents did NOT do full-repo reads of end-4/caelestia (only switcher-relevant modules) and did
  not benchmark on the machine.

**NOT read/done (open or out of scope):**
- Rest of `SYNTHESIS.md` (l.429–858); iNiR `waffle/altSwitcher/*` thumbnail variant (noted to exist, not read in
  full); end-4 overview beyond the ScreencopyView confirmation; caelestia CLI beyond `toggle.py`; DMS beyond
  Dock/overview grep.
- No live-machine work (all tests are execution-time — §10). `hypr-alttab` not viewable (no still) — excluded on
  low confidence, not declared nonexistent.
