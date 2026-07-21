# GAP REVIEW — L2.5 Full OS Vision Pass

**What this is:** the creative/critical review between research and planning. Inputs: `MASTER_REQUIREMENTS.md`, the build plan (`MACBOOK_NIXOS_HYPRLAND_BUILD_PLAN.md`), `research/SYNTHESIS.md`, `OVERHAUL_PLAN.md`, `EXECUTION_LOG.md`, and the five repo research files (agridyne read in full; others cross-checked against the synthesis). Output: everything missing, underserved, or improvable, plus proposals the user hasn't asked for but would probably want. Organized per the L2.5 brief: Categories A–F. B and C are the main work.

**Reading guide:** Category B is "this OS is incomplete without it." Category C is "this would make it *better than* Windows/macOS, not just equivalent." A/D/E/F are validation and bookkeeping. Everything here is proposal-generous by explicit instruction — cut freely.

---

## Category A — Unresolved comparisons (flag, don't solve)

**A1. The bar itself: Waybar vs QuickShell — an unflagged ownership conflict.**
The build plan and the additive rule say *Waybar is the permanent status bar*. OVERHAUL_PLAN §5.4 designs a Waybar CSS overhaul. But the synthesis's top-bar recommendation is built on iNiR's QuickShell bar (`BarContent.qml`, `BarTaskbar*`, drag-reorderable modules) — that is a QuickShell bar, not a Waybar skin. Meanwhile the strongest *evidence* cuts against Waybar: B2 (every workspace button dead because Waybar's compiled-in module emits legacy dispatch strings Hyprland 0.55 Lua rejects — "not fixable from config"), B1 (child-process cgroup deaths), GTK3's integer-scale softness at 1.5×, and no path to per-workspace drag-targets or a source-app media icon in Waybar. Every requirement in §6 Top bar is easier in QuickShell, which already runs resident. This is the single biggest undecided architecture question and nobody has put it to the user directly. **Needs an explicit decision before L3.** My read: the synthesis's own recommendation only makes sense as a QuickShell bar; the "Waybar stays" rule predates the B2 discovery and should be re-examined rather than inherited.

**A2. Dock/sidebar: a three-way code conflict against a visual reference that doesn't exist as code.**
Three documents name three different code owners: MASTER §6 says DankMaterialShell Modules/Dock is the leading source; SYNTHESIS recommends iNiR's dock (explicitly "provisional — DMS not evaluated," i.e. winner by default); OVERHAUL_PLAN §5.3 decided ekremx25/quickshell's dock. None of the three has been compared against the others. Worse, the *visual* target is a mirage: the agridyne "glass sidebar with themed app launchers" is, per the full agridyne read, a Kurve visualizer strip plus separate desktop widgets plus *Zen Browser pinned-site tiles* — there is no sidebar implementation to lift, and caelestia's "sidebar" is a notification drawer. And iNiR's dock is, per its own research file, "visually conventional… does not provide agridyne-style bespoke glass app tiles." So: the code candidates need a real three-way pass (DMS + ekremx25 read to iNiR's depth), **and** the sidebar's visual design needs to be *specified* (glass tile treatment, Kurve strip placement, pinned/running grouping) because no repo's stock look matches the intent. Code powers visuals; here the visuals must be defined first or the comparison has no criterion.

**A3. Launcher: synthesis and overhaul reached opposite conclusions from the same facts.**
SYNTHESIS: "Caelestia is the launcher source — carry the coherent dependency slice." OVERHAUL §5.5: caelestia's launcher needs its C++ plugin/AppDb and the slice is heavy; a ~200–350 LOC QuickShell-native launcher using stock `DesktopEntries` APIs is cheaper than extracting it (and cheaper at runtime than Rofi). These can't both be right. The decision hinges on one measurable thing nobody has measured: **how big is the minimal caelestia launcher slice really**, and does carrying it drag in the C++ plugin build. One bounded session can answer that. (Note the overhaul's option brushes against the no-from-scratch rule; but its argument — "there is nothing to lift that isn't coupled" — is exactly the legitimate exception MASTER 1.2 allows for. Needs the user's call.)

**A4. Wallpaper picker: skwd-wall is simultaneously "use as-is" (MASTER) and "rejected on three grounds" (OVERHAUL).**
The overhaul's rejection is evidence-backed: upstream announced abandoning the QuickShell version ~2026-07-23 for a Rust rewrite; its daemon `awww kill`s ours in a way systemd won't restart; its own UI is Matugen-themed and structurally can't hold the fixed aurora identity. The synthesis repeats "keep the already selected skwd-wall" without engaging any of this. **User decision needed:** adopt V1 anyway (owning dead code), wait for V2 (Rust daemon, new conflicts), or take the overhaul's path (steal the ~10-line parallelogram `SliceDelegate` geometry into an aurora-native picker panel). The third option is the only one consistent with both the daemon architecture and the fixed-identity rule — but it means the picker is *composed*, not adopted, and should be said plainly.

**A5. Display panel** — ilyamiro `MonitorPopup.qml` won as the only candidate evaluated. Acceptable (the gap is real in every other repo), but a quick check of noctalia/DMS display modules before L3 would make it a choice instead of a default.

**A6. File manager** — already flagged everywhere; noting here that OVERHAUL §5.12 effectively *decided* (stay Thunar, fix the named-color overrides, glass is off the table for GTK windows) while MASTER still asks for a Thunar/Nemo/Nautilus comparison. Either accept the overhaul's ranking (it is reasoned: Nautilus drags a filesystem indexer onto a 2-core/8GB machine; Nemo drags cinnamon deps) or run the visual comparison — but stop carrying both positions. Comparison criteria, if run, should include the daily-experience items no doc lists yet: undo of file operations, tabs, bulk rename, in-manager search, archive integration, device eject affordance — not just looks.

**A7. Recorder backend** — both leading capture UIs front `gpu-screen-recorder`; nobody has run it on Iris Plus/i915. Hardware test, then choose. (Also see B5 — the webcam — which belongs to the same "capture hardware truth" session.)

---

## Category B — Missing OS experiences

These are absent from MASTER_REQUIREMENTS, the synthesis, and the plans. Ordered roughly by how often a daily user hits the moment.

**B1. Alt+Tab — the single biggest Windows-muscle-memory hole.**
Twenty years of Windows means Alt+Tab is reflex, and today it does nothing (or worse, something surprising). No document mentions a window switcher at all. The taskbar/dock covers mouse switching; Alt+Tab covers the keyboard half of the redundancy philosophy, and a styled switcher with window previews is a signature polish moment ("this OS is finished"). Search: QuickShell window-switcher implementations (iNiR's overview window captures are adjacent), `hyprswitch`, DMS switcher modules. Scope: community solutions exist; adaptation to glass tokens. Frequency: dozens of times a day.

**B2. Night light / blue-light shift.**
Windows Night Light, macOS Night Shift — a comfort feature the user's eyes already expect, entirely absent from every document. Evening screen work on a laptop without it feels harsh, and it's cheap: `hyprsunset` (first-party, Hyprland 0.55-era) or `wlsunset`, plus a schedule and a System-group toggle with a slider for warmth. Should participate in the theme story (a warm shift over aurora glass needs a quick visual check). Scope: config + small panel glue. Frequency: nightly.

**B3. Battery lifecycle intelligence.**
Nothing anywhere covers the moments that define laptop trust: **low-battery warning** (20%/10% notifications with urgency escalation), **critical action** (auto-suspend at ~5% — note: zram-only, no swap partition, so hibernate is off the table; suspend is the honest option), **time-remaining estimate** in the power panel, and **automatic power-profile switching** (powersave on battery, balanced/performance on AC — power-profiles-daemon is installed but has no policy). Without the critical-suspend piece, one absorbed coding session ends in a hard power loss. Search: UPower percentage policies, `poweralertd`, iNiR/caelestia battery services for the warning UX. Scope: mostly config + small service glue. Frequency: daily; catastrophic when missed.

**B4. Audio device lifecycle — auto-switch and the call moment.**
§4.7 covers BT device battery but not the actual experience: connect AirPods → audio should *move* there, disconnect → move back, plug 3.5mm → same. WirePlumber policy handles this but must be configured and verified per-device. Related and unmentioned: **mic-in-use / camera-in-use indicators** (the macOS orange/green dot) — during a call you should see at a glance that the mic is live, and a bar-level mute toggle is the mouse-first answer. Also: Bluetooth codec quality for AirPods-class devices (SBC vs AAC — audible difference; BlueZ config). Search: WirePlumber auto-switch policy examples; PipeWire node-state watchers for the in-use dots (caelestia/iNiR audio services already track streams). Scope: config + small widget work. Frequency: every headphone use, every call.

**B5. The webcam — completely unexamined, and video calls are daily life.**
No document says a single word about the camera. On T2 Macs the internal camera needs t2linux driver support and historically has quality/functionality caveats. If it doesn't work, the user finds out **in the first meeting** — the worst possible moment. Needs: verify the T2 camera works under the current kernel, confirm Chrome (Meet/Zoom web) can use it on Wayland, and provide a camera test surface (even just `mpv /dev/video0` behind a System-group "Test camera" action). Pair with B4's in-use indicators. Scope: hardware verification first; may be a driver reality-check rather than a feature. Frequency: whenever meetings exist — and discovering it broken is a trust-destroying event.

**B6. Disk-space stewardship — the NixOS-specific time bomb.**
121GB partition, a Nix store that grows with every generation and every agent-driven rebuild, plus generations 7–10 already retained. Nothing anywhere covers: visible disk usage (bar/system workspace), a **garbage-collection policy** (`nix.gc.automatic` with a retention window that respects the rollback story), generation pruning with an affordance ("keep last N + the known-good"), and a low-space warning. On Windows this is Storage Sense; here it's more acute because the store's growth is invisible until the disk is full — and a full disk on NixOS can block the very rebuild that would fix it. Scope: config (gc policy) + small UI. Frequency: silent until it's an emergency; the policy makes it never.

**B7. A Settings app — the unification the governing standard keeps asking for.**
Every control today lives behind a bar click, a config file, or a terminal command. The pieces exist or are planned (network/BT/audio/power panels, glass tuner, wallpaper, gestures) but there is no *place that is Settings* — the thing every Windows/macOS user reaches for when they think "I want to change how this works." Caelestia's Nexus (Bonus Find #5) is the sourced starting point. Proposed pages, all backed by already-planned machinery: Appearance (wallpaper, palette/accent strategy, glass tuner, motion/reduced-motion), Display (resolution/refresh via A5, night light, brightness), Input (scroll speed!, key repeat!, gestures, tap settings — note the bug log's input complaints become *user-tunable* instead of one-shot fixes), Audio, Network, Notifications (per-app rules — the semantic-filter UI), Default apps (the §4.1 MIME map made visible), Startup apps, and **System** (see C4: generation info, update, rollback). This is the highest-leverage single addition for "OS, not rice." Scope: real but incremental — each page is a thin front over an existing service; ship it page by page. Frequency: weekly, but its *existence* is felt daily.

**B8. The authentication moments — polkit dialog and keyring.**
A polkit agent is installed, so privileged GUI actions summon a dialog — an **unthemed default dialog** in the middle of an otherwise coherent OS is exactly the "template-like" break §3 bans, and nobody has styled it. Same for the GNOME keyring unlock prompt if it ever appears outside auto-unlock. Verify keyring auto-unlock actually rides the greetd PAM login (it's configured; untested in the acceptance list). Search: `hyprpolkitagent` theming, QuickShell polkit agent implementations (some shells ship one — check DMS/noctalia). Scope: small; high polish-per-effort. Frequency: every sudo-grade GUI action.

**B9. The file-picker portal — the dialog every upload goes through.**
Every Chrome file upload, every "attach file," every save-as goes through the xdg-desktop-portal file chooser. Which backend serves it, whether it's dark/themed, whether it remembers the last directory, whether it shows Recents — none of this is specified, and an ugly light-mode picker inside a themed Chrome is a jarring daily moment. Windows users also expect drag-and-drop *onto* the picker or straight into the page. Verify portal config (`xdg-desktop-portal-gtk` vs `-hyprland` per interface), theme it with the GTK work in §4.17, and test Chrome upload + save flows. Scope: config/verification. Frequency: many times a week.

**B10. Archives — chosen opener missing.**
§4.1 says "archives → manager" but no archive tool was ever selected. Double-clicking a .zip must do something sane (extract-here contextual action beats an archive-browser app for most users). Candidates: `file-roller` (GTK, integrates with Thunar), Thunar archive plugin + `xarchiver`. One decision + config. Frequency: weekly.

**B11. Captive portals — the hotel/coffee-shop moment.**
Laptop + travel = captive portals. NetworkManager detects connectivity state (the synthesis's network panel even lists "captive-portal state" as a field) but nothing *acts* on it: the OS should notify "This network needs a sign-in" with a click-through that opens the portal page. Search: NM connectivity-check config + a small dispatcher hook, or how caelestia/iNiR surface `Nmcli` connectivity states. Scope: config + tiny glue. Frequency: every trip.

**B12. The greeter after logout.**
Auto-login covers boot, Hyprlock covers lock — but *logout* drops to whatever greetd fallback exists, which today is raw/unthemed. Low frequency, but it's a hole in the "every surface is intentional" story and it's the recovery path when the session dies. `regreet` (GTK, themeable to the palette) or tuigreet-styled minimalism. Scope: config + theming. Frequency: rare — but it's the face of the OS at its worst moment.

**B13. System health surfacing.**
A failed systemd unit today fails silently; the user discovers breakage by symptom. A tiny watcher that notifies "a background service failed (aurora-shell watchdog restarted it)" — with the journal excerpt one click away — converts mystery jank into legible events. Pairs with the notification history so it's reviewable, not naggy. Scope: small glue (systemd `OnFailure=` hooks or a QuickShell DBus watcher). Frequency: rare, but this is the "do I trust this machine" feature.

**B14. Personal-data backup story.**
The Nix repo protects the *system*; nothing protects `~/Documents`, the wallpaper collection, project repos with uncommitted work, or `~/.local/state` (EQ presets, FocusTime data if adopted). One decision (restic/borgmatic to an external disk or cloud target, scheduled, with a status line in Settings › System) closes the last "a drive failure loses real things" hole. Scope: config + doc. Frequency: invisible until it's everything.

**B15. Emoji & special-character input.**
Win+. / Cmd+Ctrl+Space reflex. iNiR's launcher has an emoji prefix (sourced!), but it should also be a mouse-reachable surface (launcher mode button or System group) and a hotkey. Scope: mostly already sourced via the launcher decision; small. Also verify a color emoji font is actually installed system-wide (tofu in terminals/GTK apps is a classic NixOS miss; Chrome bundles its own, the rest of the OS doesn't). Frequency: daily for anyone who chats.

**B16. Clipboard-history privacy.**
§4.3 specifies cliphist + UI; nobody has said what happens when a password transits the clipboard — by default it lands in history, in plaintext, forever. Adopt: sensitive-type exclusion (`x-kde-passwordManagerHint`, which wl-clipboard-aware password sources set), optional expiry for history entries, and iNiR's work-safety blur for image previews (already sourced). Scope: config + small policy in the sourced clipboard panel. Frequency: invisible, until it isn't.

**B17. Already-identified items — held here for completeness, not re-argued:** keyboard backlight (broken persistence + no bar control; note the T2 path is `apple::kbd_backlight` via `applesmc` — needs a persistence unit like systemd-backlight and a slider in the power/System panel, plus an idle-dim/restore-on-keypress touch, see C13), per-window min/max/close (§4.15 research: current hyprbars state vs alternatives), the NixOS GUI installer (§4.2, tuxmate as UX reference — verify tuxmate isn't Arch-only before anchoring on it), boot experience (§4.4; split: menu-hiding/Plymouth = config+theme work, the no-Option-hold default = careful T2 `bless`/NVRAM research from the macOS side with startup-security caveats), file manager (A6), dev workspace (§7 — see C1–C3 for additions), screen recorder verification (A7), Starship (never researched — small session: pick a community aurora-adjacent preset, wire palette tokens), Neovim (deferred but never evaluated — keep deferred; evaluate only after the dev workspace lands, since it changes what the workspace's editor pane should be).

**B18. Widget/element placement map** (also on the identified list). With B/C additions the System button is at risk of becoming a junk drawer (capture, record, wallpaper, settings, night light, color picker, emoji, camera test, keep-awake, DND…). Before L3, produce a one-page placement map: for every control — where it lives, what triggers it, compact vs expanded state, and which of bar/panel/settings/launcher owns it. Proposed principle: *bar right = status that changes* (network/BT/audio/battery/clock/bell); *System button = actions you take* (capture/record/color-pick/camera-test), capped at ~6 with the rest one level down; *Settings = anything you configure*; *launcher = everything, by name*. The map is a design artifact the user can red-pen in five minutes and it prevents twenty small placement debates during execution.

---

## Category C — Additions the user would probably enjoy

Proposed generously, per instructions. Each fits the stated philosophy (mouse-first, glass/aurora, agent-centric daily work). Rough order: dev-workflow wins first, then hardware-specific wins, then ambient/delight.

**C1. Agent completion notifications (Claude Code/Codex hooks → notification daemon).**
The daily workflow is two agents running long tasks while the user does something else. Claude Code supports hooks; a Stop/attention hook firing `notify-send` ("Claude finished in ~/nix — 3 files changed") turns the notification system into an *agent supervision surface* — arguably the most personally-valuable notification source this user has. Codex equivalently via wrapper. Nearly free; disproportionate daily payoff. Extends naturally into §7's "active agent sessions at a glance."

**C2. Persistent agent terminals (tmux/zellij under the agent Kitty windows).**
Today a compositor crash, an accidental window close, or the Waybar cgroup bug (until B1 lands) kills a running agent session. Running the §7 one-click agent launchers inside tmux/zellij sessions means the *terminal* dying never kills the *agent* — reattach and continue. This converts the scariest current failure mode (lost sessions, documented in the bug log) into a non-event. Small config; belongs in the dev-workspace design.

**C3. Update experience with a diff — "what changed?"**
Make system updates a Settings › System flow: check → build → **show the `nvd` generation diff** (packages added/removed/version bumps) → activate → "rollback" button that boot-selects the previous generation. NixOS is the only OS that can show you *exactly* what an update did and undo it atomically — surfacing that superpower in a GUI is the single strongest "better than Windows/macOS" statement this build can make. Pairs with B6 (gc policy respects the rollback window) and B7 (lives in Settings).

**C4. T2 speaker correction profile (EasyEffects).**
The T2 MacBook speakers under Linux are known to sound flat/tinny vs macOS, and the t2linux community maintains EasyEffects profiles that restore most of the macOS voicing. EasyEffects is *already* the invisible EQ backend. Shipping the community speaker profile as the default output preset is a real, immediately audible quality win on hardware this user touches every day. Search: t2linux wiki/GitHub audio profiles for MacBookAir9,1.

**C5. Per-device EQ auto-switching + AutoEq.**
For a user who cares enough about EQ to make it a headline widget: bind presets to output devices (speakers → C4 profile; headphones → their AutoEq profile from the public database) and switch automatically with B4's device-switch events. The music widget's preset row then shows *why* it sounds right everywhere. Small glue on top of already-planned pieces.

**C6. OCR from screenshot ("copy text from image").**
iNiR already has capture-OCR sourced. macOS Live Text made this an expected power; on Linux it feels like magic. Add "Copy text" as a screenshot-overlay mode (tesseract backend). Cheap, sourced, delightful.

**C7. Phone integration — KDE Connect.**
Notifications mirrored, files beamed both ways, phone-finds-laptop, media control, shared clipboard. Works fine outside KDE (`kdeconnect` + firewall ports + a small indicator). Caveat honestly: full experience is Android; iPhone gets file/clipboard via KDE Connect iOS but not notifications. If Alex is on iPhone, scope shrinks to "still worth it for file drop"; ask before investing panel work.

**C8. Lyrics in the music panel.**
Caelestia's media stack (already the sourced MPRIS/visualizer donor) includes a lyrics service. For a music-centric user this is a high-delight, already-sourced borrow — a lyrics toggle inside the expanded music widget, not a new surface.

**C9. Color picker in the System group.**
`hyprpicker` + auto-copy hex + a toast swatch. For someone actively tuning an aurora palette, this will get real use; it's also the kind of small tool Windows makes you install PowerToys for. Trivial.

**C10. Wallpaper auto-cycling + time-of-day behavior (opt-in).**
Daily/interval shuffle through the curated collection with the atomic apply pipeline (which makes it safe by construction). Optional evening variant: as B2's night light engages, prefer the darker wallpapers — the aurora identity literally deepening at night. Zero new mechanism, one timer + policy; noticeable ambient character.

**C11. Desktop widget layer (iNiR edit mode) — the ambient glance.**
Bonus Find #2, endorsed: a subtle desktop clock/weather/now-playing widget set with drag/edit mode, visibility-gated. The "between tasks, the screen is calm and informative" moment. Keep it restrained (agridyne's negative-space lesson) — two widgets, not a HUD.

**C12. FocusTime analytics (opt-in) + a bar pomodoro.**
Bonus Find #3 (ilyamiro's SQLite usage analytics — genuinely polished) as an opt-in panel, plus a small timer/pomodoro in the bar (iNiR right-sidebar has timers to source from). Fits the "the OS helps you work" story; strictly optional.

**C13. Keyboard-backlight intelligence.**
Beyond fixing B17's persistence bug: dim the keyboard backlight on idle, restore on keypress, and remember the level across boots — the macOS behavior fingers already expect on this exact chassis.

**C14. Fan/thermal awareness (t2fanrd).**
T2 Macs run their own fan policy poorly under Linux defaults; `t2fanrd` is the t2linux answer. Agent workloads pin this dual-core CPU for minutes at a time — a sane fan curve plus a temperature readout in the system workspace (and maybe a quiet "thermal throttling" event in B13's health stream) keeps long builds comfortable and legible. Hardware-specific, community-solved, unmentioned anywhere.

**C15. Screen-share awareness → auto-DND.**
When the screen is being captured/recorded (recording state is already a planned service), suppress notification popups automatically — the classic "private message appears during demo" embarrassment, solved by policy. Two lines in the notification policy layer once recording state exists.

**C16. Chrome polish pack (small verified items).**
(a) Two-finger swipe back/forward — `--enable-features=TouchpadOverscrollHistoryNavigation` on Ozone; muscle memory from macOS. (b) PiP window rules — Chrome's picture-in-picture window should float, pin above tiles, no border, persistent across workspaces: three window rules that make watch-while-working feel native. (c) Confirm VA-API fix (accepted finding) ships early — it's the biggest silent battery win on the machine.

**C17. Micro-status language in the bar.**
A tiny, consistent state vocabulary: battery pill turns amber <20% / pulses gently while charging; network icon shows a soft activity shimmer under real traffic (the Mbps truth from §4.7, expressed ambiently); bell shows a dot only for *unread that matters* (post-semantic-filter). This is the "alive but calm" quality that separates polished bars from static ones — cheap once the services exist, and it exercises the motion vocabulary daily.

**C18. Tailscale/VPN slot in the network panel.**
If the user ever wants to reach home machines or run agents against a remote box, a Tailscale toggle in the network panel (status + on/off + device list) is the modern answer. Propose; drop if there's no second machine that matters.

**C19. Accessibility/comfort toggles that double as demo tools.**
Hyprland cursor zoom (magnifier) on a gesture/hotkey + Settings toggle; the already-planned reduced-motion token exposed as a visible switch. Low cost; widens who can comfortably use the machine and doubles as a "look closer at this UI" tool.

**C20. Calendar events, read-only.**
The calendar panel is date/weather-only. A read-only ICS feed (Google Calendar secret URL) drawing event dots on the month grid + a "next event" line under the clock makes the panel *useful* instead of decorative — without building a calendar client. Sourced pattern exists (build plan Phase 3 mentions optional ICS/CalDAV); this promotes it from "later maybe" to "cheap and worth it."

---

## Category D — "Combine" recommendations that need scrutiny

**D1. Panel architecture combine (cxOrz exclusivity + caelestia focus-grab + iNiR lifecycle) — already built; don't rebuild it.**
The synthesis presents this as future integration work, but EXECUTION_LOG shows the machine *already runs* a `PanelCoordinator`/`PanelHost` implementing exactly this: mutual exclusion, focus-grab click-away, Escape, staged animation, typed IPC, lazy panels. The overhaul explicitly marks it KEEP. The honest framing is "enrich the existing coordinator with iNiR's map/animate/unmap timing and the 230–280ms tokens," not a three-repo synthesis. Re-deriving it would be from-scratch work disguised as combining. **Verdict: reframe, cost drops sharply.**

**D2. Music/EQ combine (ilyamiro EQ UI + caelestia MPRIS/radial cava/lyrics + iNiR cava lifecycle + Kurve sidebar strip) — four donors, one widget: this is composition, not adaptation.**
Each piece is separable at the *service* level (one MPRIS service, one shared Cava), but the widget itself — vinyl + radial visualizer + EQ subview + presets — is a new composition whose glue exceeds any single donor's adaptation. Mitigation: the machine already has a working music/EQ panel (execution log: art, transport, seek, Cava, 10 bands, 8 presets). Treat *that* as the base, upgrade its pieces one donor at a time (caelestia visualizer swap, ilyamiro EQ styling, lyrics last). **Verdict: from-scratch-in-disguise if done as specified; fine if done as staged upgrades to the existing widget.**

**D3. Top-bar combine (iNiR zones + ilyamiro geometry + caelestia tray + agridyne islands)** — unresolvable until A1 is decided. If the bar stays Waybar, the iNiR/caelestia QML pieces don't transfer (different framework — that's a rebuild, the exact trap MASTER 1.2 prohibits); if the bar goes QuickShell, iNiR is the base and the rest are styling/geometry values, which is legitimate adaptation. The combine is only honest in the QuickShell branch. **Verdict: contingent on A1; flag in the plan.**

**D4. Network combine (cxOrz flow + QS native service + caelestia NetworkUsage + Nexus fields)** — mostly legitimate (service swap + rate logic import), **but** the overhaul found two live bugs in caelestia's `NetworkUsage.qml` (stale read-after-reload; 2^64 wraparound spike) and recommends noctalia's `SystemStatService` pattern instead. The synthesis recommends the buggy file. Carry the overhaul's version. **Verdict: combine OK, donor file wrong.**

**D5. Notifications (caelestia service/UI + iNiR ingress caps + bespoke semantic filter)** — porting iNiR's rate-limit policy into caelestia's service is real but bounded glue; the semantic routine-event filter is acknowledged bespoke work (nobody upstream has it). Acceptable — just budget it as development, not adaptation.

**D6. Hyprlock "choreography translation" — over-promised by the synthesis.**
Synthesis: "translate the 750ms ring/orb plus 400–600ms authentication choreography through supported Hyprlock facilities." Overhaul, from Hyprlock v0.9.5 source: there are exactly 8 animation nodes; labels/images cannot fade, move, or scale; four config options in the current config are dead. Most of ilyamiro's choreography is *not translatable* — the honest ceiling is fadeIn/out + placeholder→dots + a baked vignette (the overhaul's ImageMagick path). L3 must plan to the overhaul's verified ceiling, not the synthesis's aspiration. Same class of issue: Kitty Ctrl+Shift+T "reopen closed tab" is proven unimplementable — amend MASTER §5 rather than letting L3 inherit an impossible requirement.

**D7. Glass numbers conflict (not a combine, but the same reconciliation class).** Synthesis: size 12/one pass/xray=false/ignore_alpha≈0.57. Overhaul (shader-source-verified): ignore_alpha 0.10 (0.57 causes a blur pop in the last 9% of every fade-in), xray=true as the decisive Iris Plus perf win, size 8/two passes. These are incompatible starting points; the overhaul's is evidence-graded and machine-specific and should win, with xray's "windows don't show through" trade-off (which matches the stated aesthetic anyway) noted for the user. One `hyprctl eval` A/B session settles it live before any template is written.

---

## Category E — Synthesis's uncovered gaps, triaged

Genuine research tasks (concrete direction given) vs config fixes (no session needed). Marked ⚠ where "it's just config" has burned sessions before.

| Gap | Verdict | Direction |
|---|---|---|
| XDG MIME/default-app map | Config, not research | Write `mimeapps.list` via Home Manager; the *decisions* (which viewer/PDF/video apps) ride the §13 app list. Surface in Settings › Default apps (B7). |
| Developer find-file/opener | Small research | The saatvik333 reference partially dissolved (its terminal features live in nvim config). Evaluate `fzf`/`television`+`bat` in a Kitty overlay window, and kitten hints for path-click (already sourced). One session. |
| NixOS GUI installer | Real research | Verify tuxmate actually supports NixOS (risk: Arch-focused); compare nix-software-center, `nix profile` flows. §4.2's UX bar is the criterion. |
| npm-global path for agent CLIs | Config + doc | Already working; make it durable (HM sessionPath) and document the update flow. No session. |
| Boot default / hidden menu / Plymouth | Split | Menu timeout 0 + Plymouth theme = config/theming work. The no-Option-hold default = careful research: `bless`/NVRAM from macOS on a T2 with startup security — do this one deliberately, it touches the only thing invariants say not to break. |
| Cross-app spellcheck/autocorrect | Research, scope honestly | There is no true system-wide autocorrect on Linux. Achievable: Chrome spellcheck enabled, GTK gspell coverage, hunspell dictionaries. Say what's not achievable rather than half-promising. |
| Fish suggestion accept key | Config/doc, not research ⚠only in that it needs a 2-minute live test | Right-arrow / Ctrl+F; document on the Mac keyboard. |
| Gaming latency stack | Real research | xpadneo vs xone; Hyprland frame timing/tearing options; PipeWire quantum. Include XWayland scaling blurriness check (Steam at 1.5× fractional). End-to-end measured, per §4.6. |
| System sounds | Small research | freedesktop sound theme + libcanberra; who plays events under Hyprland (no daemon does by default) — likely a small hook in the notification service. Toggleable per §4.9. |
| USB automount/trash | Config + verification | udisks2/gvfs present; add `udiskie` (or file-manager-native) for automount+notify; then *test* the §4.12 checklist. ⚠ Don't assume — test. |
| CUPS + HPLIP | Config | `services.printing` + hplip; test page. No session. |
| Per-window controls | Real research | Current hyprbars state vs alternatives; minimize→special-workspace semantics. §4.15. |
| Window move/snap/drag | Mixed | Cmd+arrows = config. Edge snapping for floats = config/plugin check. Drag-window-to-workspace-button = development (DropArea + payload; iNiR pattern is only a pattern). |
| Indexed file search / settings search | Research | File provider (`fsearch`/`recoll`/plocate) feeding the launcher; settings index falls out of B7's page registry. |
| Dedicated process workspace | Mostly decided | Overhaul §5.12's btop-on-workspace-2 design is concrete (with the security-wrapper caveat for Intel GPU stats). Remaining work is integration, not research. |
| Kitty UX beyond colors | Config + C2 | Tabs/hints/scrollback = config. Session restore: kitty's native session support is limited — C2's tmux answer is more honest for agent terminals. |
| Media source-app resolver (MPRIS→desktop entry) | Small development | Genuinely unsourced everywhere; ~50 lines mapping `mpris:desktopEntry`→DesktopEntries with fallbacks. Budget as glue. |
| WAN speed test | Small | Optional `speedtest-cli` action in the network panel, labeled as a test, on click only. Wording per synthesis (live traffic ≠ link rate ≠ WAN test). |
| Diffuse aurora gradient artifact | Resolved-ish | Overhaul §5.4 ships the ML4W radial CSS technique; remaining work is the QML equivalent for panels. Not a research gap anymore. |
| Atomic theme transaction | Development | The existing apply-wallpaper already stages/validates/atomically installs (KEEP per overhaul); extend its consumer list rather than inventing a new coordinator. |
| Hyprland glow config | Config experiment | One evening of live `hyprctl eval` with the accepted decoration:glow finding. |
| VA-API | Config | Four lines, accepted finding; ship in the first stage. |

---

## Category F — Bug log cross-reference (one line each)

- **disable_while_typing ineffective** — no sourced fix; empirical test + libinput DWT pairing theory (overhaul B10); may need a libinput quirk. Research-ish.
- **Backspace repeat too fast** — config tune (repeat_delay ~400/rate ~20–25); acceleration proven impossible (B11). Amend requirement wording.
- **Scroll speed inconsistent** — config tune (scroll_factor ~0.3–0.5) + verify Chrome separately; no repo source needed.
- **4-finger dead / pinch** — caelestia `gestures.lua` sourced for 4-finger; pinch remains research.
- **3rd window closes another** — mechanism identified (Waybar cgroup OOM, B13); fixed by B1 detach; verify by repro after.
- **Corner resize one-directional** — no source; needs repro/diagnosis (dwindle edge behavior). Config investigation.
- **Hover-focus mis-targeting** — focus policy config + §4.15 outcome; no single sourced fix.
- **Workspace 2 button dead** — root-caused (B2, Waybar builtin vs Lua dispatch); fix shape depends on A1.
- **Can't move windows between workspaces** — keybinds = config; drag-to-bar = development (E table).
- **Agents can't close own terminals** — config (kitty `confirm_os_window_close=0` / window-rule); test.
- **Waybar restart kills apps** — root-caused, sourced fix (detached exec, B1). First to land.
- **Bar cramped / media buttons tiny** — sourced sizing (48px bar, ≥34px controls); lands with the A1 bar decision.
- **CPU & Memory open same window** — root-caused (B5); fix designed (workspace-2 + right-click splits).
- **Calendar wall of text** — sourced (ilyamiro/caelestia structure; overhaul §5.8 concrete design).
- **No compact audio panel** — sourced (audio combine, D-clean).
- **Capture controls under battery panel** — sourced (System group move).
- **Notifications ugly/spammy** — sourced UI (caelestia) + bespoke semantic filter (budgeted glue).
- **Launcher broken visuals / Escape-only / Cmd+Space** — root-caused (B8/B7); fix pending A3 decision; keymap redesign is config.
- **Glass near-opaque** — root-caused (template alpha); fix designed (D7 reconciliation first).
- **Palette not universal / cheap gradients** — root-caused (5.1 inversion); architecture designed; gradient technique resolved (E table).
- **EasyEffects visible + legacy preset path** — root-caused (B6/B14); config fixes queued.
- **Thunar dated** — decided path exists (A6 — resolve the doc conflict).
- **Wallpaper switcher jank** — premise corrected (it's Waypaper's GTK window); fix rides A4 decision.
- **No morphing animations** — sourced (motion vocabulary + single-driver morph pattern).
- **Screenshot purple film** — root-caused (slurp `-s` fill, B3); one-line fix.
- **Cmd+Shift+S / Print semantics** — sourced (capture owner + bindings).
- **Kitty Ctrl+T** — config; **Ctrl+Shift+T reopen** — impossible as specified (D6 note); amend requirement.
- **Weather Austin** — root-caused (B4); coordinates fix, collapse the 4 duplicated definitions.

---

## Suggested follow-up research sessions (from this review)

1. **Bar ownership decision brief (A1)** — one session assembling the Waybar-vs-QuickShell evidence into a one-page user decision; blocks the most downstream work.
2. **Dock/sidebar three-way** (A2) — DMS + ekremx25 read to iNiR depth, plus a half-page visual spec of what the sidebar *is*.
3. **Hardware-truth session** — webcam (B5), recorder backend (A7), gpu-screen-recorder on Iris Plus, T2 speaker profile (C4), t2fanrd (C14), keyboard-backlight persistence (B17). One session, all physical-hardware questions.
4. **Daily-guardrails session** — battery policy (B3), audio auto-switch (B4), night light (B2), captive portal (B11), disk/GC policy (B6). All config-class; batch them.
5. **Alt+Tab switcher** (B1-cat-B) — candidate scan (QuickShell switchers, hyprswitch) + glass adaptation estimate.
6. **Settings app scaffold** (B7) — Nexus slice evaluation + page inventory; feeds C3's update/rollback page.
7. **Installer research** (§4.2/E) — tuxmate NixOS reality-check first.
8. Launcher slice measurement (A3) — bounded: extract caelestia launcher minimal closure, count what comes with it.

---

# Post-review additions and decisions

*Appended by the L2.5→L3 research-architect pass (2026-07-17). Fable's Categories A–F above stand unchanged; this section records the user's `MASTER_REQUIREMENTS §15` decisions as they land on the gap list, adds the clarifications the user supplied, marks the deferred items, and closes a sweep-check against §4/§5. The actual research sessions that close every still-open item are specified in `RESEARCH_SESSIONS.md`.*

## 1. §15 DECISIONS LOG — effect on the gap list

The DECISIONS LOG is authoritative and overrides any conflicting text above.

- **A1 (bar ownership) — RESOLVED.** Bar is **QuickShell**; Waybar is retired. The "biggest undecided architecture question" is decided. No decision brief needed. Fable's read ("the synthesis's recommendation only makes sense as a QuickShell bar") is ratified. → **Follow-up session #1 (bar decision brief) is CANCELLED.** All §6 Top-bar work is now plan-time QuickShell composition (the sourcing already exists in SYNTHESIS: iNiR zones/taskbar base + ilyamiro geometry + caelestia tray + agridyne islands). Consequence: **D3** (top-bar combine) collapses to its QuickShell branch — legitimate adaptation, no longer contingent. **F: workspace-2 dead / apps-die-on-restart / bar-cramped** all resolve through the QuickShell bar; no research.
- **A4 (wallpaper picker) — RESOLVED to skwd-wall, with one verify.** skwd-wall is final; the three overhaul objections are overridden (proven built code stays usable; the `awww kill` daemon conflict is a compat edit; the Rust-rewrite announcement does not disqualify the existing QuickShell picker). The composed-picker "third option" is off the table. **Open sub-question carried forward:** previews suggest skwd-wall handles wallpaper **transitions** itself — verify; if confirmed, **awww may be redundant for the picker flow** (still possibly useful for auto-cycling / non-picker changes). → routed to the Wallpaper Pipeline session.
- **A3 (launcher) — direction set, measurement still open.** Caelestia is the launcher (SYNTHESIS + overhaul agree on *appearance/behavior*). The only open item is the **dependency-ownership** decision: how large is the minimal caelestia launcher closure, and does carrying it drag in the C++ plugin build. → routed to the Shell-Surfaces session (measured there while caelestia is already open).
- **Lock screen (D6 / §6 Lock) — the Hyprlock ceiling discussion no longer *constrains* the choice.** §15 states Hyprlock is **not** locked in and QML/QuickShell locks are back in scope, with the "lockout risk" explicitly deemed overstated (boot recovery + root password always exists). So Fable's **D6** ("plan to Hyprlock's verified 8-node ceiling") is reframed: Hyprlock's ceiling is now one *input to an open comparison*, not the settled boundary. The synthesis-vs-overhaul conflict Fable flagged becomes the core question of a dedicated lock-screen session: what choreography ceiling each candidate actually has, and what safeguards the QML locks ship. → Lock Screen session.
- **Panel coordinator (D1) — "already built, don't rebuild" still holds, but "not sacred."** §15: the existing `PanelCoordinator`/`PanelHost` is kept *only if it wins a comparison* — "it already works" is not by itself a decision criterion. Fable's D1 verdict (reframe as "enrich the existing coordinator," not a three-repo rebuild) stands, but the plan session must actually *justify* keeping it against the alternatives rather than inheriting it. Not a research task — a plan-time comparison. → no-session.
- **Music/EQ composition (D2) — deferred to the plan session** by §15 (staged upgrades vs different composition is a plan call). Fable's D2 verdict (fine as staged upgrades to the existing widget) is the recommended framing but not binding. → no-session.
- **Nix generations / GC (B6) — framing fixed.** Generations 1–7 are deletable now; after the first accepted complete build, current-era generations get wiped too. The GC policy (B6) must be designed around *that* lifecycle (retention window + known-good pin that tolerates a post-acceptance wipe), not around preserving today's generations. → folded into the Daily-Guardrails session's GC block.
- **Kitty Ctrl+Shift+T (D6 tail / F) — requirement amended.** Native Kitty tab-restore is confirmed impossible; the real want was **reopening FILES**, which moves into dev-workspace planning (§7), not a Kitty demand. Fable's "amend MASTER §5" note is satisfied by §15. → dev-workspace scope; no standalone research.
- **Neovim — promoted to active evaluation** (§14/§15) during the dev-experience session, decided after the dev workspace lands. Fable's B17/B-list "keep deferred" is superseded. → Dev-Experience & Workspace session.

## 2. User clarifications and additions (this pass)

- **Contested-claims rule (from §15) applies across the whole gap review.** Any claim that flip-flopped between sessions is **UNSETTLED** regardless of which session spoke last, until a *targeted* verification pass settles it against the actual repo (file paths + VIEWED previews as evidence). This is not limited to the caelestia sidebar — it governs any inherited single-session read used in Categories A–F. Each research session below carries an explicit "settle these contested claims" instruction for the claims in its area.
- **Caelestia sidebar — the canonical contested claim.** "It's just a notification drawer" has flip-flopped ("no dock" → "3-module composite" → "notification drawer" in A2). Declared **UNSETTLED**. The Shell-Surfaces session must open the actual caelestia main repo and settle definitively *what the sidebar is*, with file paths and viewed previews.
- **QML lock safeguards — reframed, not a ceiling.** The earlier "QML lock = laptop lockout" framing was overstated. Research target is now affirmative: what safeguards do the top r/unixporn QML locks actually ship (PAM fallback, TTY escape, watchdog restart), and what is the real choreography ceiling of *each* option (Hyprlock included). Boot recovery + root password is the always-present floor.
- **skwd-wall transitions / awww redundancy** — verify natively-handled transitions (see A4 above).
- **Dev-experience is ONE session:** Alt+Tab switcher (B1) + Starship (B17) + Neovim evaluation + terminal autosuggestions / Fish accept-key (§4.5) + related input polish + the §7 dev-workspace sourcing (named/icon terminals, agent launchers, C1 completion hooks, C2 persistent sessions, find-file). Folded together because the Neovim/editor decision *is* the dev-workspace editor-pane decision.
- **Category C is all wanted.** All 20 additions carry into research/planning scope with **generous inclusion** — the user cuts at review time, agents do **not** cut preemptively. Items already sourced in the existing research (C6 OCR, C8 lyrics, C9 picker, C11 desktop widgets, C12 FocusTime, C16 Chrome pack, C15/C17 policy-once-services-exist) flow straight to the plan; items still needing sourcing get a session slot (see the no-session list in `RESEARCH_SESSIONS.md`, which accounts for every C-item explicitly).

## 3. DEFERRED — no research/plan/build session may pick these up

Per §15 ("Security & diagnostics: fully deferred until the OS is complete and usable"):

- **B16 clipboard-history privacy — the *policy* parts** (sensitive-type exclusion, history expiry). The base cliphist + visual UI (§4.3) is NOT deferred and is already sourced (iNiR service + ilyamiro grid); only the password/privacy policy layer waits.
- **WiFi-password-in-argv fix** (cxOrz/caelestia/iNiR anti-pattern; SYNTHESIS network section). The safe credential API is a plan/adaptation detail; the security *hardening* framing is deferred. In practice: use the safe API when composing the network panel, do not open a session *about* the argv exposure.
- **Any system-hardening or system-health *diagnostic*** as a standalone effort. Note the distinction the research sessions rely on: **reading the community's known-good hardware configs is research** (allowed); **running health checks / verifying on the live machine is execution-time** (not a research-session task). Hardware "verification" items (webcam works? recorder works on i915?) are researched as *sourcing + a flagged live-test step*, never as a diagnostic run inside a research session.

## 4. Sweep-check against MASTER §4 (fundamentals) and §5 (bug log)

Confirming nothing slipped through Fable's Categories B/E/F.

**§4 fundamentals — coverage:** 4.1 file assoc → E (MIME map = config; dev find-file = small research). 4.2 install/update → B17 + E (installer session). 4.3 clipboard → sourced; privacy deferred (above). 4.4 boot → B17 + E (split: config Plymouth/menu, careful T2 research). 4.5 text input → E (spellcheck honest-scope + Fish key). 4.6 gaming → E (real research). 4.7 network truth → SYNTHESIS network/BT panels + E (WAN test). 4.8 gestures → F + E (caelestia gestures.lua + pinch research). 4.9 sounds → E (small research). 4.10 recording → A7. 4.11 search → E (indexed provider). 4.12 media/trash → E (config + verify). **4.13 right-click everywhere → SEE BELOW (the one true gap in Fable's coverage).** 4.14 printing → E (config). 4.15 per-window controls → B17 + E (hyprbars research). 4.16 window move/snap → E (mixed). 4.17 app theming → SYNTHESIS palette architecture.

**§4.13 — ADDED (was not an explicit line item in A–F).**
> **Right-click everywhere (§4.13).** *Verdict: partly sourced, partly config, one small development piece.* Taskbar-task and tray context menus are **sourced** (SYNTHESIS §4.13: caelestia `Tray*.qml`/`TrayMenu.qml` + iNiR dock/taskbar context menus) → plan/config, no research. File-manager context menu is **native** to the chosen file manager → rides the File-Management session (config/theming). **Desktop** right-click context menu (right-click on the wallpaper/root surface → new-terminal / change-wallpaper / display-settings) is **unsourced** in all five repos and is a **small QuickShell development** item on the desktop layer → assigned to the File-Management & Dialogs session as a small dev sub-task (it shares the context-menu component with the file manager). No item is left unaccounted.

**§5 bug log — coverage:** every bug-log line is cross-referenced in Category **F** (verified line-by-line: all four Input & typing items, all seven Window-management items, all six Bar & panels items, all three Launcher items, all six Visual items, all four Capture & keys items). No §5 item is missing. The still-*open* (non-config, non-root-caused) F items — `disable_while_typing` empirical, backspace repeat tuning, scroll-speed normalization, pinch gesture, corner-resize one-directional, 3rd-window-close verify, hover-focus policy — are gathered into the Window-Management, Input & Gestures session so they get sourced values/repro rather than being assumed "just config."

## 5. Net change to the open-item inventory

- **Closed by §15 (→ plan, not research):** A1, D3-contingency, D1 (compare-not-rebuild), D2 (plan-time), Kitty Ctrl+Shift+T, the bar/workspace-2/restart bug cluster.
- **Reframed (still researched, question changed):** A3 (measurement only), A4 (transition verify only), D6 → Lock-Screen open comparison.
- **Added:** §4.13 desktop right-click (small dev).
- **Deferred out:** B16 privacy policy, WiFi argv, all standalone hardening/diagnostics.
- **Everything else open** (A2, A5, A6, A7, B1–B15 minus deferred parts, B17 bundle, C-items needing sourcing, E research rows, open F rows) is assigned to exactly one session in `RESEARCH_SESSIONS.md`, or to the no-session list there with its verdict.
