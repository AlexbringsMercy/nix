# MASTER REQUIREMENTS — Full OS Build
## NixOS + Hyprland on MacBook Air 2020 (T2)

**What this is:** The single authoritative requirements document for the complete OS build. Every research session, gap review, plan, and execution stage works against this document. A plan that leaves any item here unaddressed is incomplete. Output that can't be traced back to this document is out of scope.

**Machine:** 2020 MacBook Air Retina 13" — Intel i3 1.1GHz dual-core (Ice Lake), Intel Iris Plus, 8GB LPDDR4X, 250GB SSD (120GB macOS / 121.7GB NixOS dual-boot), 2560x1600 @ 1.5x scale, Apple T2, Broadcom WiFi/BT, Apple keyboard (Cmd = Super). Single display. NixOS 26.11, Hyprland 0.55 (native Lua config), QuickShell (aurora-shell), Kitty, Fish.

---

## 0. THE GOVERNING STANDARD

Every component, decision, and proposal gets tested against one question:

> "If I compared this to a perfect Linux build, to Windows, or to macOS — what's missing or harder to reach here? Does it require hotkey memorization? Is it pretty? Is it smooth? Is it hidden or tucked away? Is it streamlined enough that anyone could use it?"

This is a **full operating system build**, not a component checklist. The failure mode of every previous session was thinking in isolation — searching for the easiest, thinnest option per component instead of reasoning about a complete, polished, cohesive OS. Sessions must think like product designers: identify what's missing even when not explicitly requested, propose things the user would appreciate based on the philosophy below, and treat "nobody asked" as no excuse for shipping an incomplete OS.

---

## 1. NON-NEGOTIABLE AGENT RULES

**1.1 Licensing is NOT a constraint — zero mentions permitted.** License status (present, absent, any type) is not an indicator of code quality and not a constraint on use in any way. This build is for a personal computer, not a published product. Do not filter, deprioritize, skip, "clean-room," or re-engineer around any repo based on licensing. Do not mention licensing in any output, plan, thinking, or subagent prompt. Any reference to licenses at all is bloat and a violation of user guidance.

**1.2 Never build from scratch.** Every visual/UI component comes from an existing community implementation, adapted. "Adapt" means compatibility conversion — syntax changes, framework glue, hardware tuning — as minimal as needed for function and polish. It does NOT mean "look at the code once, then write your own version." From-scratch UI produced the current jank and is prohibited. The only acceptable bespoke work is small glue (a min-width override, a dispatch script) that no community implementation could contain.

**1.3 Full-repo reads only.** A build component cannot be understood in isolation. When a repo is a reference, read the whole repo — structure, services, theming system, how components interconnect — not one file matching a keyword. (Prior failure: agridyne read only for blur parameters when its sidebar, widgets, launchers, and cohesion model were the actual reference.)

**1.4 Visual verification is mandatory.** View every repo's preview images/videos (README, linked posts) before ranking or adopting anything. Text extraction does not suffice. Never adopt a component ranked "on source code alone."

**1.5 Multi-candidate evaluation.** For each component: gather multiple candidates, view them, compare against this document's specs and references, rank with reasoning, then choose. No first-match acceptance.

**1.6 No throwaway bridges.** Nothing gets built that is planned to be scrapped later. Everything builds toward the end state. If the end state uses QuickShell for X, don't ship an interim X to be replaced.

**1.7 Report as you go; write to disk.** Sessions surface important findings incrementally so the user can re-steer, and write all outputs to files on disk — no everlong sessions relying on chat context. Keep sessions targeted and focused; avoid massive parallel fan-outs that burn usage limits.

**1.8 The relay race.** The user provided sourced references with annotations — that work is done and must be used, fully. Agents do THEIR end of the detective work on top: for anything without a provided source, search and propose based on the entire design intent — not "no repo given, so skip it."

---

## 2. INTERACTION PHILOSOPHY

- Everything accessible by mouse/cursor click. Hotkeys exist as optional shortcuts and are NEVER the only path. "It's the user's choice whether they want to use a button or remember a hotkey — that's how all OSs should be."
- No memorizing hotkeys for basic operations. Clickable buttons, taskbar icons, and visual controls for all common actions.
- Progressive disclosure: compact elements expand on interaction. No controls buried layers deep (the macOS settings-behind-terminal-commands failure).
- Click-away dismissal on every popup/panel/launcher — clicking elsewhere closes it. Escape also works but is never required.
- Windows/macOS muscle memory respected where it's better: Ctrl+C/V, Cmd+Shift+S region screenshots, drag-and-drop without modifier keys, per-window close buttons.
- Not a keyboard-warrior minimal rice. A functional, beautiful desktop that happens to also have hotkeys.
- Redundancy between button and hotkey is a feature, not waste.

---

## 3. VISUAL DIRECTION

**Palette.** Deep near-black blues, black, purple, teal/seafoam, deep dark green — smooth gradient blobs, dark base with luminous accents. NOT navy (never use the word "navy" — it reliably produces flat corporate assets). NOT green/nature. NOT neon-garish. The overall feel: dark clean modern glass with aurora light bleeding through — Raycast-level UI refinement and polish.

**(corrected 2026-07-29):** this teal/purple/green family is not the system's fixed palette — it is one saved preset, named **Northern Lights**. "Aurora" is the project/shell codename only and does not itself name a color scheme (GRAND_PLAN §1, §10.2 item 15). The system default is wallpaper-derived: see the corrected Cohesion rule immediately below. Every generated palette — Northern Lights or otherwise — is held to the same Raycast-level polish bar stated here.

**Cohesion — the wallpaper-adaptive rule.** Theming must be universal, not touch-here-touch-there. The mubin reference is the standard: Chrome's frame, terminal, bar, panels, widgets, GTK apps, Qt apps — everything recolors together when the wallpaper changes. Validated architecture: pin the dark surface colors (the deep blues/blacks stay constant); only accent colors adapt per wallpaper; all widgets reference named palette slots so a palette swap is a single-file edit.

**(corrected 2026-07-29):** the "pin the dark surface colors, only accent adapts" mechanism above is superseded and must not be built. The full semantic role set — background, surface ladder, foreground/muted foreground, borders, primary/secondary/tertiary, semantic states, gradients — is derived from the active wallpaper, not pinned. Light/dark mode itself follows the wallpaper: Auto is dark-preferred for dark/evening/richly-colored wallpapers and switches to light for clearly light/high-key wallpapers; user control is Auto / Force dark / Force light (GRAND_PLAN §3.1, §4.0). A dark red wallpaper must produce a cohesive burgundy/oxblood system, not black panels with a red accent. Mubin's full-system-recolor *result* remains the standard; its pinned-dark-surface *mechanism* is explicitly retired (GRAND_PLAN §13.2). Named palette slots and single-point palette swap/regeneration remain correct and are preserved as the atomic-transaction model (GRAND_PLAN §4.0).

**Glass.** REAL glass — wallpaper visibly showing through panels. Starting spec: surfaces ~rgba(10,14,26,0.55–0.65), blur 12–16px, 1px border at ~10% white — then tune live. Not the current near-opaque black ("more black than glass"); not ultra-frosted either. The test: "Can you see the wallpaper through it? If no, too opaque."

**Motion.** Smooth property animations on every state transition — ilyamiro is the fluidity bar. Controls/panels: ~160–300ms ease-out (fade + slight scale, e.g. opacity 0→1 + scale 0.95→1.0). Cinematic 700–1200ms choreography reserved for lock screen and expanded-widget entrances — never slowing everyday clicks. Nothing pops; everything slides/fades/morphs. Morphing transitions within widgets (compact ↔ expanded states) are a first-class requirement, not decoration.

**Gradients.** Polished and diffuse (ML4W-style radial aurora technique), present cohesively across surfaces — not two lonely spots, not "decent custom Android build" quality.

**Typography & icons.** FiraCode Nerd Font (terminal/code), Inter or similar clean sans (UI), Papirus icons applied consistently everywhere (taskbar, launcher, tray). Font rendering is currently good — do not regress it.

---

## 4. MISSING OS FUNDAMENTALS
None of these exist today. Each needs a sourced, proposed solution. These are the "nobody thought about it" items — the difference between a rice and an operating system.

**4.1 File opening & associations.** Nothing opens files today — not even this project's own .md files. Requirement: a complete xdg default-app map. Dev-lane files (.md, code, .json, configs, logs) → VS Code (or the dev workspace editor); images → proper viewer; video → mpv; PDF → viewer; archives → manager. Double-click in the file manager just works, like Windows/macOS "Open with." Additionally: a terminal-style file search/opener for dev-lane work (saatvik333-style find-file interface).

**4.2 App install & update.** Today there is no GUI installer, the Nix store blocks normal npm/app update flows, and everything requires terminal config edits — unacceptable as a daily experience. Requirement: installing VS Code or Spotify must be as easy as on Windows/macOS; updating Claude Code/Codex as easy as `npm install -g` is elsewhere. Candidates to evaluate: **tuxmate** (https://github.com/abusoww/tuxmate — the UX reference: seamless, quick, pretty), nix-software-center-class GUIs, `nix profile` imperative flows, and a permanently-working npm-global path for agent CLIs. Propose the best NixOS-compatible solution that matches tuxmate's ease.

**(corrected 2026-07-29 — daily-QoL plan revision):** the ease-of-install requirement stands; "updating Claude Code/Codex as easy as `npm install -g`" and "a permanently-working npm-global path for agent CLIs" are superseded. **The visible minimum is now Windows-equivalent native application behavior.** Where an application's native Linux build actually exposes update/check/install/relaunch UI, that in-app control is the required primary path and the Nix/vendor bridge adapts invisibly underneath — no extension, injected button, Aurora titlebar control, global app-update notification, terminal command, software-center detour, or full NixOS rebuild/reboot. A graphical, click-driven fallback (app-specific where practical, else Nexus › Applications & updates) is permitted **only** after source inspection, runtime tracing and package/build inspection prove the native build has no updater UI or callable updater path. Apps retain **current + two previous** binary versions maximum; rollback is app-local. For the agent CLIs specifically, the canonical lanes are the self-managed `~/.local/bin/claude` → `~/.local/share/claude/versions/` tree (`claude update`) and Codex's user-owned standalone lane; Nix owns runtime/environment/PATH declarations only and may never pin, shadow, replace or downgrade either agent. Owner: **M28**, GRAND_PLAN §8.8 (Stage 6 mechanics) and §5.8 (Stage 9 surfaces); the PATH-ownership half is pulled forward into the next compatible Stage 2 closure (GRAND_PLAN §10.2).

**4.3 Clipboard history.** None exists. cliphist + wl-clipboard + a themed visual history UI (the Win+V equivalent). Copy anything, recall past copies visually.

**4.4 Boot experience.** Today: hold Option on every single boot, then watch ugly NixOS terminal scroll. Requirement: seamless power-on → branded splash (Plymouth, themed to palette) → lock screen. Default boot target set so no Option hold is needed (nvram/bless fix from the Mac side), systemd-boot menu hidden with timeout 0 (hold a key to reveal for recovery/macOS selection). Booting normally should never feel like going through a boot manager.

**4.5 Text input intelligence.** No autocorrect anywhere; no known suggestion-accept key in Kitty. Requirement: a system-level spellcheck/autocorrect story for GUI text fields (Chrome and beyond), plus terminal autosuggestions (Fish) with a documented, working accept key on the Mac keyboard.

**(corrected 2026-07-29 — daily-QoL plan revision):** "a system-level spellcheck story" is sharpened into an acceptance bar. **Red underlines alone do not satisfy this requirement** — actionable *replacement suggestions* are mandatory. Hunspell dictionaries and each application's native correction menu remain the first layer; Stage 6 additionally selects and integrates one standard input-method candidate service (evaluate **Fcitx5 vs IBus/Typing Booster on the physical machine**) so ordinary text fields lacking a useful native surface still receive candidates. Suggestions must be actionable by **both mouse and keyboard**, support a custom dictionary, and stay **disabled in password/secure fields**; automatic replacement stays **off by default**. Coverage gate proves replacement suggestions in Chrome, Discord/Electron, VS Code, a GTK field, a Qt/KF6 field, Dolphin rename, and one further ordinary daily text field; genuine per-app refusals are recorded as real exclusions and never used to narrow coverage elsewhere. Fish command autosuggestions remain a separate terminal feature with their own accept-key check. Owner: **M29**, GRAND_PLAN §8.4 (Stage 6) and §5.8 (Stage 9 controls).

**4.6 Gaming input stack.** The Xbox controller had button latency, video/frame latency, AND audio latency — same hardware worked fine on macOS, so this is pure NixOS configuration debt. Two hours of ad-hoc Codex debugging produced nothing. Requirement: deliberate research and setup of the full low-latency pipeline — controller driver (xpadneo/xone evaluation), compositor/frame latency settings, audio latency (PipeWire quantum tuning) — verified end-to-end.

**4.7 Network truth.** WiFi widget/panel must show actual internet/link speed (Mbps), not just a meaningless %. Bluetooth panel shows device battery.

**4.8 Gestures.** Four-finger gestures currently do nothing; pinch-to-zoom is app-dependent and hit-or-miss. Requirement: a deliberate full gesture map — 3-finger workspace swipe (exists, keep), plus 4-finger and pinch behaviors where sensible.

**(corrected 2026-07-29):** resolved. Four-finger up opens Hyprexpo Overview, with a visible mouse-accessible path also required (never gesture-only); four-finger down opens the sysmon workspace (GRAND_PLAN §5.16, §6.2, §10.2 item 14). **Pinch-to-zoom has already physically passed** on the machine and drives `cursor_zoom` — it is no longer "hit-or-miss"; do not schedule a retest unless the zoom code path is touched (GRAND_PLAN §10.2 item 13).

**4.9 System sounds.** Currently silent by omission, not by choice. Make it a choice: a tasteful optional sound theme, configured and toggleable.

**4.10 Screen recording.** None exists. wf-recorder/OBS-class solution with a clickable trigger (in the System button group), region + full screen.

**4.11 System-wide search.** Beyond app launching: files, settings, actions. Evaluate community solutions (QuickShell search surfaces, fsearch, etc.).

**4.12 Removable media & trash.** USB plug-in → automount + notification + file manager access, verified to behave like Windows/macOS (UDisks flow actually tested). Trash semantics verified: delete goes to trash, not permanent oblivion.

**4.13 Right-click everywhere.** Context menus on desktop, file manager, taskbar tasks (right-click-close exists — keep), tray icons.

**(corrected 2026-07-29):** "taskbar tasks" now means the left-rail's app/window entries (§5.3) — the top bar carries no task list (GRAND_PLAN §5.1, §10.2 items 1–2). Right-click actions on rail entries include focus/restore, close, close others, float, pin, and move to workspace (GRAND_PLAN §5.2–§5.3).

**4.14 Printing.** CUPS + HPLIP configured for the HP printer.

**4.15 Per-window controls.** Min/Max/Close buttons on EVERY window — not only in the top bar. Redundancy is fine; user choice is the point. Acceptable pattern: buttons reveal on hover at window top. Hyprbars was previously deferred over upstream bugs — find the working community solution (re-evaluate hyprbars current state vs alternatives); "minimize" may map to a special workspace under the hood. Traveling to the top of the screen for every close is tedious, and hover-follows-focus makes it error-prone.

**(corrected 2026-07-29):** "minimize maps to a special workspace" is resolved and rejected — omarchy's `special:min-*` model is explicitly not the final backend. Minimized windows keep their original workspace, leave layout/render/input, and are represented dimmed in the left rail; one click restores/focuses (a restore-last hotkey may exist only as optional redundancy). See the new window-model requirement added at the end of §6 Component Requirements. "Not only in the top bar" is also stale: the top bar carries no window controls at all in the resolved architecture — hyprbars gives every window its own titlebar controls, and the left rail is the mandatory one-click recovery surface (GRAND_PLAN §6.2, §10.2 items 5–6).

**4.16 Window movement & snapping.** Move windows between workspaces via hotkey AND mouse (drag onto workspace buttons in the bar, or equivalent). Drag-to-edge snapping (half/full) configured. Cmd+arrows moves windows. Drag windows without holding Cmd — grab via bar/titlebar like Windows.

**(corrected 2026-07-29; snap model clarified 2026-08-09):** "drag-to-edge snapping (half/full) configured" is now a fully specified deterministic model — the **reservation/reflow** model, not a pair model: `Super+Left`/`Super+Right` always produce exact left/right halves regardless of dwindle-tree shape or window count. A half-snap **reserves** a half; ordinary windows **reflow** in the opposite half and stay visible. Ordinary windows minimize **only** when both halves are reserved by explicit half-snap owners and no ordinary tiled region remains. Snapping onto an already-reserved side **demotes** the previous owner to ordinary (not minimizes it). Releasing a reservation returns that region to ordinary tiling, restoring prior state where possible. There is no pair/MRU state model (GRAND_PLAN §6.2, `docs/reports/gen32-recovery-diagnosis.md`). Move-to-workspace by drag now targets the top bar's workspace pills specifically (apps/windows live on the left rail, not the top bar).

**4.17 App-level theming.** Spotify (spicetify), VS Code, Discord themed to the palette so cohesion doesn't break the moment an app opens. GTK + Qt + libadwaita coverage completed (apply the 19 GTK3 named colors + 4 libadwaita root vars finding — this is literally why Thunar looks generic).

---

## 5. BUG LOG — OBSERVED DEFECTS

> **Status as of 2026-08-11.** Many items below were first recorded against the pre-Aurora
> Waybar/Rofi-era system. Several have since been resolved by architecture changes (Stages
> 0–2), root-caused by the gen32 recovery investigation, or transformed into named defects
> D1–D9. Items are annotated inline with their current status. For the authoritative current
> defect record see `docs/reports/gen32-recovery-diagnosis.md`; for current machine state see
> `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md`.

### Input & typing
- disable_while_typing still not effective — cursor clicks into text while typing. Empirical before/after test required. (Tap-to-click and two-finger scrolling DO work today — do not regress.) **(status 2026-08-11):** root cause found — the T2 trackpad carries `ID_INPUT_TOUCHPAD_INTEGRATION=external` (USB), so DWT was a silent no-op. A hwdb reclassification fix is written and was included in gen32 (DWT became `enabled` on gen31+), but gen32 hard-failed. The fix is not physically accepted. Further palm threshold tuning may be needed after the fix is live.
- Backspace/delete key repeat far too fast, not progressive — tune repeat delay/rate. **(status 2026-08-11):** `repeat_delay 350` / `repeat_rate 22` set in gen26. Empirical feel-check never run — remains UNVERIFIED.
- Scrolling speed wildly inconsistent: fine in terminal, way too fast and jumpy in Chrome and everywhere else. **(status 2026-08-11 — SUPERSEDED by D8):** gen32 recovery evidence refined this. Chrome focused vs hovered-unfocused is essentially **equal** (not "too fast"). Kitty hovered-unfocused is dramatically **slower** than focused Kitty — the opposite of the original characterization. This reproduces even when another Kitty has keyboard focus. The issue is **D8 — UNRESOLVED, no accepted root cause.** Do not fix with a global multiplier, generic unfocused boost, or by removing Chrome tuning. See `docs/reports/gen32-recovery-diagnosis.md` D8.
- Four-finger gestures dead (see 4.8). **(corrected 2026-07-29):** pinch-to-zoom is no longer listed as inconsistent — it has since physically passed and is not a retest item unless touched (see corrected 4.8).

### Window management
- Opening a 3rd+ window sometimes resizes and CLOSES an existing window. **(status 2026-08-11):** this was the Waybar `KillMode=control-group` bug. Resolved by Stage 1 cutover to `aurora-shell.service` with `KillMode=process` — shell restart confirmed not to kill user apps (Stage 1 gate, gen18).
- Border/corner resize only works in one direction — can expand, can't shrink from a corner (e.g. upper-right corner only goes upper-right). **(status 2026-08-11 — SUPERSEDED by D7):** gen32 recovery evidence refined this into four sub-defects: D7a (cursor changes to diagonal on mouse-down), D7b (outer edges anchor as opposite/inner), D7c (top/bottom arm but don't resize), D7d (hidden layer surface intercepts input). The original broad description is obsolete. See `docs/reports/gen32-recovery-diagnosis.md` D7. All OPEN.
- Hover-based focus makes targeting the bar's close button error-prone — must avoid hovering other windows en route (fixed by per-window buttons + saner focus behavior). **(status 2026-08-11):** addressed by `follow_mouse = 2` (pointer scroll follows hover, keyboard focus stays on click) plus hyprbars per-window titlebar buttons. Written in gen32; gen32 hard-failed on other defects. The focus model is untested in an accepted generation.
- Workspace 2 button does nothing. **(status 2026-08-11):** this was the Waybar legacy-dispatch-string bug. Resolved by replacing Waybar with the QuickShell-based aurora-shell (Stage 1).
- Cannot move windows between workspaces at all (see 4.16). **(status 2026-08-11):** planned via cross-surface drag from rail app/window to top-bar workspace pill (GRAND_PLAN §5.1/§6.2). Not yet implemented.
- CLI agents (Claude Code/Codex) cannot close their own terminal windows — blocked pending manual accept, silently breaking sessions that then need resuming. Remove whatever confirm-on-close is responsible (kitty confirm_os_window_close / Hyprland behavior). **(status 2026-08-11):** `confirm_os_window_close = 0` is in the plan (GRAND_PLAN §6.4). Status against running gen32 unknown.
- Apps launched from Waybar die when Waybar restarts (Chrome took the browser tabs and a Claude session with it) — launches must be detached (setsid/disown pattern). **(status 2026-08-11):** resolved. aurora-shell.service uses `KillMode=process`; Waybar itself is retired from final architecture. The class of bug (bar cgroup kills children) is dead by construction.

### Bar & panels
**(status 2026-08-11):** the bar/panel bugs below were recorded against the retired Waybar/Rofi-era UI. The entire top-bar architecture was replaced by the ilyamiro-derived QuickShell top bar, and the left application rail replaced the old Waybar task list (GRAND_PLAN §5.1). Many of these items are resolved by the architecture change; those that survive as requirements are captured in GRAND_PLAN §5.

- Top bar cramped: tiny hit targets forced into 3 pills. **(resolved by architecture):** the ilyamiro top bar uses independent islands with proper sizing.
- CPU button and Memory button both open the same CPU window. **(resolved by architecture):** separate independent top-bar islands.
- Compact calendar is a wall of text. **(carried forward):** calendar/weather expansion redesigned in GRAND_PLAN §5.1–§5.2; not yet built (Stage 3).
- No compact audio panel on volume click/hover. **(carried forward):** audio island and expanded panel planned (GRAND_PLAN §5.2); not yet built (Stage 3).
- Screenshot/wallpaper controls tucked under the battery window. **(resolved by architecture):** System surface (GRAND_PLAN §5.7) owns capture/record/wallpaper/settings.
- Notifications look bad, and routine events (home WiFi connect on every boot) must not notify at all. **(carried forward):** notification restyling and semantic event filter planned (GRAND_PLAN §5.6); not yet built.

### Launcher
- Apps button/launcher visually broken (pink/beige alternating rows, dashed border). **(resolved by architecture):** Rofi retired; caelestia launcher with HyprlandFocusGrab is the replacement (GRAND_PLAN §5.5).
- No click-away dismissal — Escape-only today. **(resolved by architecture):** the caelestia launcher uses `HyprlandFocusGrab` for click-away dismissal.
- Cmd+Space must open the launcher (currently bound to window focus). **(resolved):** rebound in Stage 2B.

### Visual
- Glass is near-opaque black — apply the confirmed template-alpha fix. **(carried forward):** glass A/B is Stage 4 scope (decision 16). Current glass is not accepted.
- Palette not universal; gradients exist in only ~2 spots and look cheap. **(carried forward):** full wallpaper-derived semantic palette is Stage 4 scope (GRAND_PLAN §3–§4).
- EasyEffects appears as a user-facing app window — it is backend-only EQ infrastructure and must be invisible (and its presets moved from the deprecated config dir to the XDG data dir). **(partially addressed):** EQ preset path correction written; EasyEffects visibility not yet resolved.
- File manager (Thunar) looks dated. **(carried forward):** Dolphin is the planned replacement (GRAND_PLAN §5.17); Stage 6 scope.
- Wallpaper switcher is custom jank — replace with skwd-wall. **(carried forward):** skwd-wall is the planned replacement (GRAND_PLAN §4.1); Stage 4 scope. Temporary picker discoverability deferred by decision 28.
- No morphing/smooth animations anywhere yet despite being a core requirement. **(carried forward):** motion system planned (GRAND_PLAN §3.3); work begins with Stage 3 top bar.

### Capture & keys
- Screenshots broken: purple overlay film baked into captures (slurp selection-color bug). **(status 2026-08-11):** root cause found and proven (slurp's selection overlay composited into the frame, finding 19a). The final Areapicker architecture replaced slurp in gen32. Gen32 hard-failed on other defects; screenshot behavior on gen32 was partially tested (focus issues remain — see D4/EXECUTION_LOG gate failure items 7).
- Cmd+Shift+S = adjustable region select → clipboard + timestamped PNG; Print = full screen; identical UX to Win+Shift+S. **(corrected 2026-07-29 — daily-QoL plan revision):** "Print = full screen" is superseded — **Alex's keyboard has no Print key**, so `Print` is optional redundancy only and never the required full-screen path. Whenever screenshot mode opens it presents one compact Windows-style toolbar **centred at the top** with **Region · Window · Full screen** (GRAND_PLAN §5.12, decision 27).
- Kitty: Ctrl+T opens new tab; Ctrl+Shift+T reopens last closed tab. **(clarified 2026-07-29):** "Ctrl+Shift+T reopens last closed tab" means the last closed Kitty terminal tab, not editor files. Owned by Stage 8 (dev workspace). Native Kitty tab-restore is confirmed impossible.
- Weather set to Austin, TX. **(resolved):** weather location corrected.

---

## 6. COMPONENT REQUIREMENTS

**Top bar — QuickShell (decided: Waybar removed).** Waybar's workspace module sends legacy dispatch strings incompatible with Hyprland 0.55 Lua (root cause of dead workspace buttons), its cgroup kills child-launched apps on restart, and GTK3 renders soft at 1.5x fractional scale. QuickShell is already running and supports every ambitious bar feature natively. One coherent QuickShell bar (sections acceptable if properly sized/spaced). Left: Apps button + pinned quick-launch (Chrome, Kitty, Thunar/file manager). Center: workspace indicators (clickable, drag-targets for moving windows) + running tasks (click activate, right-click close) + active title + window controls. Right: media (usably sized controls; source-app icon à la caelestia — click opens the themed source app), CPU/RAM (opening the CORRECT views), volume, WiFi (with speed), Bluetooth, battery, clock/calendar, tray, notification bell, System button (capture / record / wallpaper / settings). All launches detached from the bar process.

**(corrected 2026-07-29):** the QuickShell-over-Waybar decision and its rationale stand. The layout above does not: it is superseded by the resolved top/left split (GRAND_PLAN §5.1, §10.2 items 1–4). The top bar is ilyamiro's independent-island composition nearly 1:1 and carries **no pinned quick-launch, no running-task list, no active window title, and no window controls** — those belong to the left application rail (see the corrected Sidebar/dock entry below). Corrected top-bar composition: **Left** — search/launcher icon, notification bell, then three workspace pills + `+` (active extras expand responsively, no fixed eight-slot row). **Media island** — current source/track/transport, click expands Music/EQ. **Center** — clock/date/weather. **Right** — tray/language, network, Bluetooth, audio, battery, and the approved CPU/RAM/System islands, each its own anchored popout. All launches remain detached from the bar process.

**Launcher.** Community-sourced — caelestia's QuickShell launcher is research's current pick (click-away via HyprlandFocusGrab; needs visual verification), surface-dots' Rofi theme as fallback. Glass, icons, search-as-type, click-away + Escape dismissal, opens from Apps button AND Cmd+Space.

**Sidebar/dock.** The second UI surface (every good build has two surfaces — top bar + vertical side). Organization/design language from agridyne and caelestia; DankMaterialShell's Modules/Dock as the leading code source (left-vertical, pinned + running grouped). Glass app icons (agridyne's YouTube-style themed launchers). Audio visualizer element placed tastefully on the sidebar (agridyne reference sizing).

**(corrected 2026-07-29):** structural ownership is resolved and narrower than "leading code source." The left rail's structural owner is **caelestia's `modules/bar/` app entries plus `modules/windowinfo/` preview machinery** (forked into aurora-shell); DankMaterialShell supplies dock grouping/context/drag *behavior patterns* only and does not own the surface (GRAND_PLAN §2.1, §5.3, §13.1). The rail holds: launcher entry, pinned apps always visible, running and minimized windows from the **current workspace only**, minimized entries visibly dimmed, one-click focus/restore, grouped exact live previews for multi-window apps. It carries **no duplicate workspace, tray, calendar, network, Bluetooth, audio, or battery stack** — that status information is owned by the top bar (GRAND_PLAN §5.1). Agridyne's glass app-icon treatment and the optional Kurve visualizer remain as specified.

**Dropdown panels.** Independent QuickShell PanelWindows — dashboard architecture, NOT ilyamiro's single-hub morph. Panels: Network (SSID, IP, signal, SPEED, available list), Bluetooth (devices, battery, scan), Audio (output/input selection, compact slider panel, EQ access), System/Power (battery detail, brightness, volume, power profiles, lock/sleep/reboot/shutdown), Display (resolution/refresh). Intra-panel morphing between sub-views. cxOrz service backends (fix its WiFi-password-in-argv bug during adaptation), restyled to spec.

**(corrected 2026-07-29):** "dashboard architecture" above means *multiple independent panels* (as opposed to one morphing hub) — it is not a reference to Caelestia's stock Dashboard drawer, which is retired outright: no drawer, no top-edge hover/swipe trigger, no duplicate calendar/media/performance/weather tabs (GRAND_PLAN §5.4, §10.2 item 14). These independent panels anchor under their corresponding top-bar islands rather than floating unrelated to any bar entry (GRAND_PLAN §5.2), and morphs happen within one anchor per the ilyamiro boundary rule (GRAND_PLAN §3.3) — consistent with, not contradicting, the original line above.

**Music/EQ.** Album art, track, controls, cava visualizer, expandable EQ — ilyamiro's EQ widget is the quality bar. EasyEffects as the invisible backend.

**Notifications.** QuickShell-owned (cxOrz NotificationService backend + caelestia grouping model): styled glass cards top-right, action buttons, history, DND, click dismissal — and no routine-event spam.

**Lock screen — NOT locked to Hyprlock.** Research all options: QML-based locks (ilyamiro, caelestia, iNiR implementations) with crash-safety mechanisms (PAM fallback, TTY escape, watchdog restart), Hyprlock's actual ceiling (v0.9.5: only 8 animation nodes, no label fade/move/scale), and any other Hyprland-compatible lock screens. The top r/unixporn NixOS builds all run QML locks with safeguards — boot recovery via root password means "lockout" is just a reboot to TTY, not a brick. Target: highest choreography ceiling with reasonable safety. Visual target: blurred wallpaper with circular vignette, large clock/date, avatar, PIN field, battery/WiFi status, cinematic depth-of-field. Whatever is chosen: `security.pam.services.<lockscreen>` MUST be configured.

**(corrected 2026-07-29):** the research question is resolved. The lock is a deliberate multi-source composition, not a single QML implementation: **agridyne** visual composition/negative-space/glass identity + **Vast** depth planes and gated multi-beat unlock engine + selected **ilyamiro** clock/PIN/motion mechanics + **iNiR/DMS** status pills + **DMS** crash-safe lifecycle; Hyprlock stays installed as emergency fallback only, never the daily driver (GRAND_PLAN §5.10, §10.2 item 11). Do not collapse this to a single owner. `security.pam.services.aurora-lock = {}` is the concrete unit.

**Wallpaper system.** skwd-wall parallelogram picker used as-is + compat only (research: vendor SliceDelegate.qml, one-line change frees it from its Rust daemon). awww for transitions. Palette pipeline: Matugen IF verified working on the installed version (custom_colors silent-discard finding), hellwal as fallback, gowall (recolor wallpaper toward the palette) as the inverse option. Atomic apply: wallpaper → palette → every surface reloads together, no half-applied states.

**(corrected 2026-07-29):** the vendor-SliceDelegate / awww-for-transitions plan is retired. Decision: keep the **complete skwd-wall application and its Rust daemon** (`skwd-daemon.service`); awww is retired entirely. The daemon's `skwd.wall.applied` broadcast is the palette trigger via an `SkwdBridge.qml` subscriber (GRAND_PLAN §4.1). Palette pipeline is corrected: the **project's patched caelestia scheme engine is the system-wide semantic authority** — it analyzes the wallpaper, picks Auto dark/light, and derives the complete role set; **Matugen is explicitly not the system-wide authority** and may remain scoped to skwd's own picker UI only; **Hellwal is fallback only**, used exclusively if the patched caelestia generator fails acceptance, and must still feed the same semantic role contract (GRAND_PLAN §4.0, §13.3). gowall remains an optional inverse tool. Atomic apply — generate to staging, validate, atomic rename, `scheme.json` last — is unchanged and confirmed (GRAND_PLAN §4.0).

**Terminal (Kitty).** Glass background per spec; clickable tab bar; Ctrl+C/V semantics (working — keep); Ctrl+T / Ctrl+Shift+T; 10k scrollback; clickable file paths in output open the editor (kitten hints); nameable terminal windows with icons; startup system-info art — saatvik333-quality clean custom ASCII/fastfetch, NOT bare-terminal basic; find-file and session-restore features; Starship prompt themed to the palette.

**File manager.** Evaluate: fully-themed Thunar vs Nemo vs Nautilus. Must land modern-dark-glass adjacent (agridyne/saatvik333 explorer references — current favorite look was "dark glass, a bit too dark"), with working thumbnails, trash, and automount integration.

**System monitor.** Terminal-style presentation (btop-class, saatvik333 aesthetic) — and a DEDICATED system/processes workspace, not a cramped widget. "All the system processes info should be a workspace entirely."

**Window model (added 2026-07-29; snap model clarified 2026-08-09).** `follow_mouse = 2`: pointer scroll/interaction follows the hovered window; keyboard focus changes only on click. Minimized windows retain their original workspace and are recovered via the left rail's one-click restore — `special:min-*` is rejected as the final backend. Deterministic two-pane snap uses the **reservation/reflow** model (not a pair model): `Super+Left`/`Super+Right` always give exact halves; a half-snap **reserves** a half, and ordinary windows **reflow** in the opposite half — they are **not** minimized merely because one side is reserved. Minimize occurs only when both halves are reserved by explicit owners and no ordinary tiled region remains. Snapping onto an already-reserved side **demotes** the prior owner to ordinary. Releasing a reservation returns the region to ordinary tiling, restoring prior state where possible. Sourced from `hyprwm/hyprland-plugins` (hyprbars, Hyprexpo) with narrow carried patches; omarchy is a historical minimize reference only, its `special:min-*` backend explicitly rejected (GRAND_PLAN §6.2, §13.1, `docs/reports/gen32-recovery-diagnosis.md`).

**Dashboard UI (added 2026-07-29).** The stock Caelestia dashboard drawer is retired as a final surface: no drawer, no top-edge hover/swipe trigger, no duplicate calendar/media/performance/weather tabs. Reusable dashboard services/components may still feed the top-bar's independent widget expansions, Nexus, notifications, or sysmon. Retiring the dashboard UI does not retire caelestia as the shell chassis/donor (GRAND_PLAN §5.4, §10.2 item 14).

---

## 7. DEV WORKSPACE (major requirement)

A purpose-built, one-action-away workspace for the daily two-agent workflow (potentially reducing/replacing VS Code reliance over time):
- Multiple named terminals — names AND icons per terminal window
- One-click launchers: Claude Code with `--dangerously-skip-permissions` in its own terminal; Codex in yolo mode in its own terminal
- Quick terminal spawn with preset working directories
- File viewer/search pane; click any path in terminal output to open that file (VS Code-like path handling)
- System info visible (the terminal-style monitor)
- Git status summary for active repos
- Active agent sessions/status at a glance
- Easy access (button + hotkey) and easy window movement into/out of it

---

## 8. REFERENCE BUILDS — CORRECTED MAP
The user did an hour of detective work sourcing these. Agents extend this list; they never shrink it. Each entry states what to pull. Prior sessions' dismissals of these references were incorrect and are overridden here.

- **ilyamiro/nixos-configuration** — TIER 1 for fluidity: morphing transitions, animated QuickShell widget quality, the EQ widget, lock choreography, palette-slot architecture (widgets reference named slots; swap = one ~40-line file). It was never claimed to have glass. NOT pulled: hub architecture, green palette, the QML lock implementation. Full 15k-LOC QML read still outstanding.
- **agridyne/dotfiles-dt** — TIER 1 for cohesion: sidebar, cohesive glass widgets, glass app icons/launchers (the YouTube tile), login screen, sidebar visualizer sizing, whole-system monochrome-glass consistency. KDE is NOT a disqualifier — it's a code check + compat pass, like any framework difference. FULL repo read required. **(corrected 2026-07-29):** agridyne is a visual-direction donor for the rail and lock — not the structural owner of either surface; caelestia owns left-rail structure (GRAND_PLAN §2.1, §5.3) and the lock is the multi-source composite in §5.10, not agridyne alone.
- **caelestia-dots/caelestia** — the MAIN repo, not just /shell: launcher (click-away via HyprlandFocusGrab), sidebar (3-module composite), hover popout top bar with music + source-app icon (Spotify) that opens the themed app, runtime-configurable opacity. **(corrected 2026-07-29):** the "sidebar (3-module composite)" here is caelestia's real left-side app/window surface (`modules/bar/` + `modules/windowinfo/`) — not the module literally named `modules/sidebar/`, which is the notification-history drawer (SESSION_PREAMBLE). Caelestia's stock Dashboard UI is retired as a final surface; only reusable data/services carry forward (GRAND_PLAN §5.4).
- **snowarch/iNiR** — aurora/angel dark-glass style presets, live glass tuner, palette/token architecture, motion curves, font sizing. Niri-first: ADAPT for Hyprland (compat conversion), never rebuild from scratch. **(corrected 2026-07-29 note):** "aurora/angel" here are iNiR's own upstream preset names, unrelated to this project's Aurora codename or the Northern Lights preset — the donor role is glass tuner/token architecture/motion curves, not palette naming or ownership (GRAND_PLAN §13.1).
- **mubin-thinks/minimal-wm-config** (+ /themes, + showcases/) — THE cohesion standard: everything recolors together (Chrome frame, terminal, bar). Mechanism-agnostic — the RESULT is the reference. Also surfaced gowall (recolors wallpapers toward a palette — the inverse approach).
- **nathanhoulamy/macos-dotfiles** — theming reference with previews, similar cohesion achievement.
- **SherLock707/hyprland_dot_yadm** — wallpaper color-picking/theming reference (read was rate-limited at 3 dirs; finish it).
- **hellwal** — palette-generation alternative if Matugen stays problematic. **(corrected 2026-07-29):** resolved as fallback-only — used solely if the project's patched caelestia semantic generator fails acceptance, feeding the same semantic contract (GRAND_PLAN §4.0, §13.3); not an alternative to Matugen specifically, since Matugen was never the system-wide authority.
- **liixini/skwd-wall** — the wallpaper picker. Use as-is, compat only. It looks beautiful already; no rewriting.
- **saatvik333/hyprland-dotfiles** — terminal art (lives in the nvim dashboard config), find-file + session restore, clean terminal windows, terminal-style system process view, file explorer look.
- **snes19xx/surface-dots** — widget structure/sizing, modern launcher look, terminal startup info; its Rofi theme rated "best cost/value artifact found." (Its opacity was never the reference — structure was.)
- **cxOrz/dotfiles-hyprland** — QuickShell panel/service backends: WiFi, BT, volume, notifications, power. Fix the WiFi password argv exposure during adaptation.
- **DankMaterialShell** — Modules/Dock (≈4 files): left-vertical dock, pinned + running grouped icons. **(corrected 2026-07-29):** behavior-pattern donor only (grouping/context/drag) — not the primary rail owner; caelestia's rail structure is primary (GRAND_PLAN §2.1).
- **elifouts / GlassesArch / LinuxBeginnings (ML4W-Glass-3d.css) / Sharddots** — the Waybar blend: elifouts mechanics (clean alpha, no antipatterns), ML4W diffuse radial aurora gradient technique, GlassesArch geometry, Sharddots blur params.
- **abusoww/tuxmate** — app installer UX reference (see 4.2).
- **Harshil-Anuwadia wintux GRUB theme** — matrix-style dual-boot menu. DEFERRED (bootloader is currently systemd-boot).

---

## 9. ACCEPTED FINDINGS — DO NOT RE-DIAGNOSE
Diagnostics are DONE. No session re-runs system health checks unless a specific fix requires a before/after measurement. Accepted as inputs:

- Matugen 4.0 silently discards the custom_colors teal bias key (verify against installed version; explains palette drift). **(corrected 2026-07-29 note):** this diagnostic finding stands, but is now historical — Matugen is not the system-wide palette authority; the patched caelestia generator is (GRAND_PLAN §4.0).
- Glass problem = template alpha values, NOT blur — blur has been running behind opaque panels the whole time (fix is template hex → alpha hex)
- The pink/mauve = tone-80 lightness destroying saturation, not hue rotation
- Chrome recolor = one `BrowserThemeColor` enterprise-policy Nix line
- VA-API was never installed — Chrome software-decodes video at ~53% of a core; four Nix lines, install it (major daily win on a dual-core i3)
- vibrancy_darkness is inverted vs prior assumption: 0 = maximum effect
- Hyprland 0.55 has decoration:glow — per-window rim glow, default cyan, one draw per window: a cheap native aurora accent
- Hyprlock without `security.pam.services.hyprlock = {}` rejects correct passwords = laptop lockout risk
- Rofi 2.0's Wayland backend does not implement click-away dismissal (root basis for the QuickShell launcher decision)
- cxOrz WiFi panel passes passwords via argv (readable by any local process) — fix on adaptation
- EasyEffects is Qt6/Kirigami, not GTK4 — its mauve window was Qt bridging GTK3 colors
- Waybar restart kills its child-launched apps until launches are detached
- Codex's recorded priorities stand: detach Waybar launches; move EasyEffects presets to XDG data dir

---

## 10. HARDWARE CONSTRAINTS & INVARIANTS

Preserved unconditionally: T2 kernel + apple modules, /etc/nixos/firmware/brcm (163 files) via the local non-Git adapter, programs.nix-ld.enable, allowUnfree, hostname `macbook`, user `alex`, Fish, NetworkManager, PipeWire, stateVersion 26.11, systemd-boot dual-boot with recovery generations, untouched channel-based /etc/nixos/configuration.nix until final acceptance.

Performance budget is real: 8GB RAM, dual-core i3, Iris Plus. Blur passes/xray affordability must be measured, not assumed; animation settings tuned for this GPU, not desktop-GPU defaults. zram swap stays.

Infrastructure is NOT gospel: if a piece is suspect (e.g., the Matugen pipeline that burned an hour and got discarded), verify it. Issues in infrastructure are still issues.

---

## 11. WORKING TODAY — DO NOT REGRESS

Font rendering. Cursor theme/behavior (pointer/I-beam/resize states). Tap-to-click. Two-finger scrolling. WiFi from boot. Ctrl+C/V semantics in Kitty. Dual-boot + generation rollback. Claude Code and Codex execution. Chrome on native Wayland.

**(corrected 2026-07-29 — daily-QoL plan revision):** "Claude Code and Codex execution" is strengthened from *runs* to *survives a rebuild without shadowing or downgrade*. A NixOS/Home Manager activation must never make an older duplicate agent binary win PATH resolution — from the operator's perspective that is a rollback and it is forbidden. Canonical Claude Code is `~/.local/bin/claude` → `~/.local/share/claude/versions/`; Codex is its user-owned standalone lane at `~/.local/bin/codex` → `~/.codex/packages/standalone/current`. `~/.local/bin` must deterministically precede `~/.npm-global/bin` in interactive **and** graphical sessions. Credentials, configuration, sessions and resumable state are protected state (GRAND_PLAN §8.7). Duplicates are neutralized only **after** the canonical path is proven live in current shell, fresh terminal and fresh graphical login. Gate rows for all four contexts plus post-reboot belong to the closure that ships the fix.

---

## 12. PROCESS — SESSION PIPELINE

- **L1 — Targeted research (Codex):** one repo or one topic per session, full-depth, writes to `~/nix/docs/research/<name>.md`. No diagnostics. No planning. Sessions: ilyamiro full QML read · agridyne full repo · caelestia main repo · iNiR · cxOrz · SherLock707 completion · gap-topic research (installer/clipboard/boot/gaming/window-decorations/autocorrect/search/recording) · Starship.
- **L2 — This document.** The requirements backbone.
- **L2.5 — Gap review (fresh session):** reads ALL research + this document + the governing standard; sole job is proposing remaining gaps and beneficial additions the user might appreciate. User reviews → targeted follow-up research as needed. No planning, no execution.
- **L3 — Plan (fresh, highest-reasoning session):** reads everything; produces the FULL build plan MD — every component sourced, attributed, compat delta stated, and tied to the intent it serves. No execution, no code.
- **L4 — User reviews the plan.**
- **L5 — Staged execution with test gates:** separate session per stage, logs written per stage, user tests at each gate before the next stage proceeds.

---

## 13. APPS TO HAVE

Working install path required for all (see 4.2): VS Code, Spotify (+ spicetify theming), Discord, mpv, btop, fastfetch, cava, OBS or wf-recorder, Steam + Proton (later), Audacity, Python 3 + pip/venv, Node/npm (agent CLIs already working — keep), Rust toolchain, Docker, Git + GitHub CLI.

---

## 14. DEFERRED (explicitly later — not forgotten)

- Animated/live wallpapers (mpvpaper / linux-wallpaperengine) — revisit once the OS itself is polished; CPU cost on this hardware already measured as heavy
- Matrix-style dual-boot menu theme (requires bootloader consideration; systemd-boot today)
- Alienware 14 port — dual-monitor layout, NVIDIA legacy driver, the original two-screen dashboard architecture
- Self-hosted music library + own EQ/mixing project (ties into the music widget)
- Neovim evaluation (LazyVim/AstroNvim) — promoted from deferred to active evaluation in the dev-experience research session; decision after the dev workspace lands

---

## 15. DECISIONS LOG (2026-07-17 — post gap review)

Firm decisions made after the L2.5 gap review. These override any conflicting statement earlier in this document or in any research/plan file.

- **Bar: QuickShell. Waybar is retired.** (Gap review A1 resolved.) All §6 Top bar requirements are implemented as a QuickShell bar. Rationale: Waybar's compiled-in workspace module emits legacy dispatch strings Hyprland 0.55 Lua rejects (the dead workspace-2 button), Waybar restarts kill child-launched apps via cgroup, GTK3 renders soft at 1.5x fractional scale, and every ambitious bar requirement (drag-to-workspace targets, source-app media icon, drag-reorderable modules) is easier in QuickShell, which already runs resident.
- **Wallpaper picker: skwd-wall is final.** It is the best picker seen, by far. The upstream Rust-rewrite announcement does NOT make the existing QuickShell implementation ineligible — proven built code stays usable. The daemon conflict with awww is a compat edit (patch the `awww kill` behavior), not a disqualifier. VERIFY during research: skwd-wall appears to handle wallpaper transitions itself in previews — if confirmed, awww may be redundant in the picker flow (awww may still serve non-picker changes like auto-cycling). **(corrected 2026-07-29):** confirmed and superseded — skwd-wall's daemon does render its own transitions; **awww is retired entirely**, not merely "possibly redundant," and there is no `awww kill` conflict left to patch. The full skwd-wall application + `skwd-daemon.service` ship as-is; auto-cycling and the evening-variant rotation both use the daemon's own `wall.random_start`/`wall.apply` RPC, not awww (GRAND_PLAN §4.1).
- **Lock screen: Hyprlock is NOT locked in.** Nobody chose it as final. Research ALL candidates — including QML/QuickShell lock screens. The "QML lockout risk" is overstated: boot recovery + root password always exists, and the top r/unixporn builds shipping QML locks will have safeguards (PAM fallback, TTY escape, watchdog restart) — find what those safeguards are rather than avoiding the approach. The requirement is the highest choreography ceiling that can be made safe.
- **Panel coordinator: not sacred.** The existing PanelCoordinator/PanelHost on the machine is kept only if it is genuinely the best option after comparison — "it already works" is not a decision criterion by itself.
- **Music/EQ widget composition: deferred to the plan session.** Whether it's staged upgrades to the existing panel or a different composition is a plan-time call.
- **Nix generations:** generations 1–7 are deletable now. Once the first fully-working complete build is accepted, the current-era generations get wiped too. GC policy (gap review B6) designs around this.
- **Security & diagnostics: fully deferred.** No research, planning, or build session spends any time on security hardening or system diagnostics until the OS is complete and usable. (Examples: WiFi password argv fix, clipboard privacy policy — all post-build.)
- **Kitty Ctrl+Shift+T:** the reopen-closed-tab requirement was primarily about reopening FILES; it moves into dev-workspace planning (§7) rather than standing as a Kitty config demand. Native Kitty tab-restore is confirmed impossible.
- **Neovim:** promoted from "deferred, never evaluated" to "evaluate during dev-experience research" alongside Starship, Alt+Tab, and terminal autosuggestions.
- **Contested-claims rule:** any research finding that has flip-flopped between sessions (e.g., "caelestia's sidebar is/isn't just a notification drawer") is treated as UNSETTLED regardless of which session said it last. Before such a claim is used in planning, a targeted verification pass settles it against the actual repo — treat nothing as gospel, spawn a focused check on the single question.

---

## EXECUTION GOVERNANCE — 2026-07-28

Binding on every execution session, PM session, and delegated agent. Recorded in
full, with reasons, in `docs/reports/EXECUTION_LOG.md` under **OPERATOR DECISIONS — 2026-07-28
— ACTIVE GENERATION 26** (decisions 12–18). Where this section and a stage report
disagree, this section wins.

1. **Planned, written, built, installed, activated, live-tested, and accepted are
   seven distinct states.** They are never collapsed. A report that states one of
   them while implying another is a false report.

2. **A stage closes only after its entire gate passes.** Not when the code is
   written, not when a build succeeds, not when a generation is installed, not
   when most things work, not when the remainder looks small. All seven states
   must be true for every requirement in the stage, and Alex must pass the
   complete gate. Until then the stage is reported as **OPEN**.

3. **No silent deferrals, divergences, scope reductions, or fallback
   substitutions.** No requirement may be moved to another stage, deferred, cut,
   narrowed, declared impossible, or satisfied by a workaround-treated-as-final
   without Alex's explicit approval. A fallback is a proposal until he signs off.

4. **Alex must explicitly approve every plan change.** Any divergence from
   `docs/plans/GRAND_PLAN.md` and any newly discovered incompatibility goes to him as a
   decision, before it is acted on.

5. **Every operator decision is logged in `docs/reports/EXECUTION_LOG.md` the same day**, with
   the date and the **actual confirmed active generation**, using the decision
   template in `docs/instructions/PM_OPERATING_RULES.md`. Conversation memory is not a decision
   record.

6. **Implementation detail stays with the agents; Alex receives decision-level
   summaries.** He is asked for product/architecture calls, tradeoffs, scope
   changes, deferral approvals, and physical gate acceptance — not for
   command-by-command choices.

7. **"Impossible" requires exhaustive evidence.** Configuration options,
   community implementations, older upstream behaviour, and narrow patches must
   all be investigated before a limitation is accepted. A single-lane search that
   concludes "the ecosystem lives with it" is a void conclusion, not a finding.
   (Precedent: the drag bug's fix was Hyprland's own former behaviour,
   forward-ported — the operator was right and the first verdict was wrong.)

8. **A narrow custom patch is a valid answer** when all of the following hold:
   existing configuration cannot solve the problem; community and upstream
   evidence has been properly investigated; the desired behaviour is proven
   technically possible; the patch is isolated and tested; and Alex approves
   carrying it. Carried patches are recorded in `docs/references/SOURCES.md`.

9. **Every stage-gate report carries a requirement-by-requirement table** with
   pass / fail / unverified per requirement. No row may be dropped because it is
   inconvenient, and no skipped check becomes an implied pass. The table format
   is in `docs/instructions/PM_OPERATING_RULES.md`.

The Stage 2 requirements/scope are in `docs/plans/STAGE2_CLOSEOUT_WORK_ORDER.md` (the
prior-cycle gen-32 work order — not the current execution brief). The current recovery
resume path starts at `docs/reports/CURRENT_STATE_AUDIT_2026-08-11.md`. The incoming
PM's operating contract is `docs/instructions/PM_OPERATING_RULES.md`.
