# Settings Center & Un-themed System Dialogs — Research

**Session scope:** Source the settings center (B7) and the currently-unthemed system dialogs — polkit/keyring (B8), the post-logout greeter (B12), a system-health watcher (B13), a personal-data backup story (B14), and an emoji/special-char surface + color-emoji font (B15). Research only — no planning, execution, config-writing, or machine diagnostics. Keyring auto-unlock and font-tofu checks are flagged as execution-time live-tests.

**Cross-refs:** MASTER §0 (governing standard: "streamlined enough that anyone could use it"), §2 (mouse-first, click-away, progressive disclosure), §3 (total cohesion — an unthemed default dialog is a jarring "template-like" break), §4.17 (app-level theming — GTK/Qt/libadwaita coverage), §6 (independent dropdown panels), §15 (security deferred; QuickShell bar decided). Gap review B7/B8/B12/B13/B14/B15 + Bonus Find #5 (Nexus).

**Sources on disk:** caelestia shell `~/nix/repos/caelestia/shell-main/shell-main/` (Nexus), iNiR `~/nix/repos/inir/` (polkit, emoji, settings, shellUpdate), DankMaterialShell `~/nix/repos/dankmaterialshell/` (polkit, greeter, services). Previews viewed: 5 running-build screenshots + regreet + tuigreet (web).

---

## 1. SETTINGS CENTER (B7) — Caelestia Nexus

### 1a. Extractability verdict — stated plainly

**Nexus is NOT a drop-in extractable slice. It cannot be lifted "without dragging in the entire caelestia service graph" — it IS welded to that graph.** But its *architecture* (page registry + typed-row vocabulary) is a first-class, reusable settings-center scaffold, and there is a cheap path to a real settings center **if** the build already carries the caelestia substrate for other surfaces.

Evidence (full read of the module — 45 files, **8,569 LOC**):

- **The spine is the native C++ plugin.** `import Caelestia.Config` appears in **57 import statements across the module** — essentially every file. That plugin provides the typed, debounced, persisted config singletons (`Config` = per-screen live config; `GlobalConfig` = writable global) and the design tokens (`Tokens.padding/rounding/font/sizes`). Every settings row reads `Config.*`/`Colours.*` and writes `GlobalConfig.* = value` (e.g. `NotificationsPage.qml`: `onToggled: GlobalConfig.notifs.expire = checked`). Remove `Caelestia.Config` and every page loses both its data binding and its sizing.
- **Plus the shell service + component layers:** `qs.services` (44 imports — `Colours` palette service, Audio, Bluetooth, Network singletons), `qs.components`/`.controls`/`.containers`/`.images`/`.filedialog` (the styled-control library: `StyledText`, `StyledRect`, `MaterialIcon`, `IconButton`, `StyledSwitch`, `StyledSlider`, `SplitButton`, `Anim`, `CAnim`, `SearchBar`, `VerticalFadeFlickable`), and `Caelestia.Blobs` (SDF shaders) + `Caelestia.Components/Models/Services` for the window chrome. Those three layers together **are** "the entire caelestia service graph."
- **The window itself is well-formed and independent-surface-friendly** (this part is good news): `WindowFactory.qml` creates a transparent QuickShell `FloatingWindow`, opened via the `caelestia shell nexus open` IPC. Unlike the dashboard/launcher (embedded in the shared full-screen blob drawer, which §2/§6 reject), **Nexus is already a proper standalone window** — it matches the target's independent-surface requirement. Only its *background chrome* uses `Caelestia.Blobs`; swap that for a glass container and the window shape is target-compatible.
- **The pages already are "thin fronts over a service"** — exactly the task's design goal. They're just fronting *caelestia's* services, not the target's.
- **Revealing gap:** in `PageRegistry.qml`, **Display is a commented-out `// TODO`**, and **Updates + Plugins are `PlaceholderComp` "Page under construction"** stubs. Caelestia itself has NOT built the three System-adjacent pages the target most needs (Display, Updates/rollback). The scaffold is there; those pages are new work regardless of path.

### 1b. Two honest adoption paths — the choice hinges on the launcher/notification decision (gap review A3)

- **Model A — Nexus rides the shell slice. CHEAP. Recommended IF caelestia is adopted for launcher + notifications.**
  The launcher research (A3) leans toward carrying the packaged caelestia shell (unused surfaces disabled) because the caelestia launcher already needs the C++ plugin/AppDb + services + components. In that world, `Caelestia.Config`, `qs.services`, `qs.components`, and `Caelestia.Blobs` are **all already present**. Enabling Nexus then costs: flip it on → prune the page list to the target inventory → retheme tokens to the fixed dark-blue palette (map surface roles to pinned near-black-blue, accents adaptive — the exact palette policy already mandated for the whole shell per §3 and caelestia.md finding #4) → re-point the wallpaper page at skwd-wall. **Marginal cost is low.** This is the single strongest argument *for* the packaged-shell launcher path: the settings center comes almost for free.
- **Model B — adopt the scaffold, not the window. REAL per-page work. If NOT carrying caelestia.**
  Dragging the whole caelestia substrate (native plugin + services + component library ≈ the entire shell) *just for a settings window* is a bad trade (~8.5k LOC + a Qt6/C++ plugin build + the service graph, for one window). Instead vendor the **pattern**: `PageRegistry` (declarative `{label, icon, description, category}` list) + `PageCompRegistry` (`StackPage` sub-page nav-stacks) + `Pages` (cross-fade page loader) + `NavPane`/`NavLocations` (searchable, category-grouped nav) + the `common/` typed-row vocabulary (`ToggleRow`, `SliderRow`, `SelectRow`, `StepperRow`, `PopupRow`, `SectionHeader`, `InfoRow`, `PageBase`, `ConnectedRect`, `ItemList`) — re-pointed at the target's own service singletons + config store, wrapped in a target-native glass `FloatingWindow`/`PanelWindow` instead of the Blobs chrome. This is legitimate adaptation per §1.2 (the row components are clean, self-contained QML being adapted, not rebuilt), but it is genuine per-page development.

  Alternative scaffolds exist if the build is DMS- or iNiR-derived instead of caelestia: **DMS** ships `Modules/Settings/` + `Services/SettingsSearchService.qml`; **iNiR** ships `modules/settings/` (25 files — Aurora/Angel style editors, per-area config tabs, `SettingsOverlay.qml`). **Rule:** use whichever shell's substrate the rest of the build already carries; never import a *second* shell's substrate for the settings window alone.

**Recommendation:** Decide the launcher/notification substrate first (A3). If caelestia → **Model A** (enable + prune + retheme Nexus — the cheapest route to a genuine settings center). If not → **Model B** (scaffold-only adaptation over target services). Either way, **the Nexus page/row architecture is the reference; do not import the caelestia service graph merely for the settings window** (this ratifies caelestia.md finding #12: "Adapt selected patterns/pages… do not import the entire service graph merely for appearance").

### 1c. Page inventory — each page a thin front over an already-planned service

| Page | Group | Fronts (already planned) | Nexus template? | New work |
|---|---|---|---|---|
| **Appearance** | Appearance | wallpaper (skwd-wall), palette/accent (Matugen/hellwal), glass tuner (alpha+blur), motion / reduced-motion token | `WallpaperAndStyle.qml` (+ WallpaperSelect/ColourSelect sub-pages) | Add glass sliders (Nexus has only a transparency *toggle*, no opacity/blur sliders — see caelestia.md §Glass); expose reduced-motion switch; re-point wallpaper at skwd-wall |
| **Display** | System | resolution/refresh (ilyamiro `MonitorPopup` / A5), night light (`hyprsunset`, B2), brightness | ❌ commented-out TODO | New page; night-light warmth slider + schedule |
| **Input** | System | scroll speed, key repeat delay/rate, gestures, tap / disable-while-typing | ❌ | New page — **the bug-log input complaints become user-tunable rows** (`scroll_factor`, `repeat_delay`/`repeat_rate`, DWT, 4-finger gestures). High relief-per-effort; pure config bindings |
| **Audio** | Connectivity | PipeWire sinks/sources, per-app volumes, EQ access | `AudioPage.qml` + `AppVolumes.qml` | Directly adaptable; wire EQ (EasyEffects) access |
| **Network** | Connectivity | NetworkManager: SSID/IP/**speed**/saved/VPN | `NetworkPage.qml` (461 LOC) + 6 detail pages | Adaptable — but **drop the argv-password path**; use the safe secret-agent API (cxOrz/Nmcli finding) |
| **Notifications** | System | per-app rules + DND + semantic routine-event filter | `NotificationsPage.qml` = shell-toast events only | Per-app rules are **new** (built with the same row vocabulary); the §5 "no home-WiFi spam" filter gets a UI here |
| **Default apps** | Shell | the §4.1 MIME map made visible (`mimeapps.list`) | `AppsPage.qml`/`AppInfo.qml` (favourites/hidden) | Add default-handler mapping UI |
| **Startup apps** | Shell | autostart entries | ❌ | Small new page |
| **System** | System | generation info / update diff (`nvd`) / rollback (C3) + **backup status (B14)** + **health (B13)** | ❌ Updates is a placeholder | Build it; mechanism from the app-lifecycle session; the capstone "better than Windows/macOS" page |
| **Language & region** | Shell | locale, weather location (**fix Austin**), units | `LanguageAndRegion.qml` | Adaptable; collapse the 4 duplicated weather defs (§5) |
| **About** | About | system info, credits | `AboutPage.qml` | Adaptable |

Note: **settings search is already built in** — Nexus's `NavPane` has a "Search settings" `SearchBar`, and DMS has `SettingsSearchService`. The §4.11 settings-search surface falls out of the page registry for free.

### 1d. Ship order (page by page, value-first, each behind an existing service)

1. **Appearance** — highest daily visibility; wallpaper/palette/glass/motion are what the user tunes most; template exists. Ships the "it's a product, not a rice" feeling first.
2. **Input** — converts the bug-log one-shot fixes into user-tunable rows (scroll/repeat/DWT/gestures); high relief-per-effort; pure config bindings.
3. **Audio** + **Network** — adapt the two richest existing Nexus pages onto safe backends; these also serve as the dropdown-panel "full view."
4. **Notifications** — per-app rules + semantic filter (gives §5 no-spam a UI); new work, on the row vocabulary.
5. **Display** — resolution/refresh (A5) + night light (B2) + brightness.
6. **Default apps** + **Startup apps** — surface the MIME map (§4.1) + autostart; small.
7. **System** — generation / update-diff / rollback (C3) + backup status (B14) + health (B13). Depends on the app-lifecycle session's mechanism → ship last; it's the capstone.
8. **Language & region** + **About** — cheap finishers.

Rationale: front-load pages whose backing service already exists and the user touches daily; defer pages needing a new mechanism (System/updates) or new UI (Notifications per-app, Display).

---

## 2. POLKIT + KEYRING (B8)

### 2a. Polkit — recommend an in-shell QuickShell agent themed to the palette (not a separate process)

QuickShell ships a first-party, documented `Quickshell.Services.Polkit.PolkitAgent` (queues incoming requests; exposes `flow` + auth-succeeded/failed/cancelled signals — quickshell.org/docs/master/types/Quickshell.Services.Polkit). **Both candidate shells already wrap it in a themed dialog:**

- **iNiR `modules/polkit/`** (155 LOC — cleanest to adapt):
  - `Polkit.qml`: a `Scope` → `Loader` gated on `PolkitService.available && PolkitService.active` → per-screen `PanelWindow` (WlrLayer.Overlay, `keyboardFocus: OnDemand`, namespace `quickshell:polkit`, `exclusionMode: Ignore`).
  - `PolkitContent.qml`: a 450 px `WindowDialog` — "security" MaterialSymbol, "Authentication" title, the request message, a password `MaterialTextField` (password echo unless `responseVisible`), Cancel/OK, **Esc-to-cancel**. Themed entirely via `Appearance.colors`. Animated scrim.
- **DMS `Modals/PolkitAuthContent.qml` + `Services/PolkitService.qml`** (richer, more surface): `PolkitService` is a 25-line singleton over `Quickshell.Services.Polkit.PolkitAgent` (with a `DMS_DISABLE_POLKIT` env kill-switch). `PolkitAuthContent` reads `/etc/pam.d/polkit-1` (+ `system-auth`/`common-auth`/`password-auth`) to detect **`pam_fprintd`** and show a **fingerprint** affordance; handles response-required/fingerprint interplay; window controls (move/maximize/close); password-visibility toggle; "Authentication failed — try again".
- **vs standalone `hyprpolkitagent`** (C++/hyprtoolkit, separate process): themes only via `~/.config/hypr/hyprtoolkit.conf` (colors / corner rounding / font — hot-reloaded, no restart). **Not palette-adaptive, not wallpaper-cohesive, a separate aesthetic/process.** It's the fallback, not the target.

**Recommendation:** the build already runs a resident QuickShell shell, so **make the polkit agent part of the shell** via `Quickshell.Services.Polkit` — adapt **iNiR's compact dialog** to the target glass tokens (or DMS's if a fingerprint reader is wanted). The sudo-grade dialog then IS the same glass/aurora surface as the launcher and panels — the §3 "no template-like break" satisfied by construction, with zero extra process. Fall back to hyprpolkitagent (themed via `hyprtoolkit.conf`, best-effort) only if the shell doesn't own the agent.

**Live-test / caveats:** (1) Confirm `Quickshell.Services.Polkit` is present in the QuickShell revision the build pins — it's under `master` docs, and both shells consume it, so it's real, but pin-check at execution. (2) **Exactly one** polkit agent may run — ensure no other (gnome/kde/mate/hyprpolkitagent) autostarts alongside the shell agent.

### 2b. Keyring (gnome-keyring)

Wire `pam_gnome_keyring` into the greetd PAM stack — NixOS `services.gnome.gnome-keyring.enable = true` (or `services.gnome.gnome-keyring` via the desktop module) + `security.pam.services.greetd.enableGnomeKeyring = true` (and hyprlock/login services as needed).

**The auto-login gotcha (confirmed via ArchWiki + GNOME PAM docs + NixOS Discourse):** with greetd **true auto-login**, no password ever reaches PAM, so `pam_gnome_keyring` has nothing to unlock the *login keyring* with → **it will NOT auto-unlock**, and the first secret consumer (Chrome saved logins, NetworkManager secrets, VPN) triggers gnome-keyring's own **gcr unlock prompt** — an unthemed GTK dialog, exactly the §3 break to avoid. Resolutions (an execution-time decision + live-test):

- **(a) Blank login-keyring password** → auto-unlocks silently; keyring stored **unencrypted at rest**. The usual pragmatic answer for a single-user personal laptop with auto-login (aligns with §0 "anyone could use it"; security hardening is deferred per §15). **Recommended default** for this machine.
- **(b) Unlock via the disk/LUKS key** — there is a NixOS-Discourse recipe for exactly *greetd + Hyprland* unlocking gnome-keyring with the LUKS key. More secure, more setup.
- **(c) Don't auto-login** (enter a password at the greeter) — conflicts with the current auto-login boot design.

If a keyring prompt *does* appear (path (a) not taken), it's a GTK/gcr dialog and inherits the §4.17 GTK theming (best-effort cohesion). **The robust cohesion answer is to make it never appear** (path (a)).

**Flag (per the acceptance list — "configured but untested"):** keyring auto-unlock riding the greetd PAM login is an **execution-time live-test**. After wiring, verify no keyring prompt appears on first secret access under auto-login; if it does, apply (a) or (b).

---

## 3. GREETER / LOGOUT (B12)

Previews viewed: **regreet** (2 screenshots downloaded, 1 viewed in full + set described) and **tuigreet** (`contrib/screenshot.png`).

- **regreet** (GTK/Rust greetd greeter) — *viewed:* full-screen wallpaper (Fill/Cover/Contain/ScaleDown), a themeable dark rounded card (clock pill, **User** + **Session** dropdowns each with an edit pencil, accent **Login** button, **Reboot**/**Power Off** at the bottom). Configurable GTK theme + cursor + icon theme + font, plus **GTK4 custom CSS** for anything beyond. Mouse-driven; structurally a real macOS/Windows login. Accent colors come from the GTK theme → **the target palette flows in via the §4.17 GTK work**, and the wallpaper matches the desktop. **Strong cohesion.**
- **tuigreet** (TUI console greeter) — *viewed:* a bordered Username/Password box on a flat dark screen, date up top, function-key hints (ESC/F2/F3) at the bottom. No compositor needed; rock-solid and lightweight — but a **TTY aesthetic that hard-breaks** the glass identity.
- **QuickShell greeter (DankGreeter / dms-greeter)** — bonus find: DMS ships a full greetd greeter built on the **same QuickShell** (`Modules/Greetd/GreeterContent.qml` ≈ 2,900 LOC + a Go installer/session-launcher/user-cache-sync; productized as "DankGreeter" with wallpapers, multi-user sync, auto-login). This is the **cohesion-MAX** option — the login screen is literally the desktop shell — proving a QuickShell greeter is feasible, but it's DMS-coupled and heavy. (iNiR uses SDDM `dots/sddm/pixel`, not greetd; caelestia has a lock module but no greeter.)

**Recommendation:** **regreet as the primary logout greeter**, themed to the palette (wallpaper background + GTK theme + GTK4 extra-CSS, riding the §4.17 GTK work). It carries the aurora identity, is mouse-first (§2), and makes logout an intentional surface rather than a raw fallback. Configure **tuigreet as the TTY recovery fallback** for when the graphical greeter can't start (the session-died path — the greeter's real job). Flag the **QuickShell greeter (dms-style) as the future cohesion-max option** if the build later wants the login screen pixel-identical to the desktop. NixOS: `programs.regreet.enable` + `services.greetd` wiring; theme via `programs.regreet.settings` (background image, GTK theme name) + `extraCss`.

---

## 4. SYSTEM HEALTH (B13)

Goal: turn silent systemd unit failures into legible, reviewable events with the journal excerpt one click away. Two mechanisms compared.

**(a) `OnFailure=` → dispatcher template unit — the reliable base.** NixOS: `systemd.services.<name>.onFailure = [ "notify-failure@%n.service" ]` + a template `notify-failure@.service` that pulls the failed unit's journal excerpt (`journalctl -u %i -n 20 --no-pager`, `%i`/`%n` passing the unit name in) and emits one notification with a "click for detail" action, routed into the **notification history** so it's reviewable, not naggy.
- **The system→user notification bridge is the real work.** A system-level `OnFailure` job has no session bus / `DBUS_SESSION_BUS_ADDRESS`, so `notify-send` can't reach the shell. Clean answer: **`pkgs.systembus-notify`** (rfjakob) — a tiny *user* service that listens for `net.nuetzlich.SystemNotifications.Notify` signals on the **system** bus and re-emits them onto the **user** bus, straight into the QuickShell notification daemon (which owns `org.freedesktop.Notifications`). The template sends the system-bus signal; systembus-notify delivers it to history. (Hardcoding `DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus` works on a single-user box but is brittle.)
- **Reliability nuance:** `OnFailure` fires only when a unit reaches the **`failed`** state. If `Restart=on-failure` successfully restarts a crash, the unit re-enters `active` and never touches `failed` — so a *transient* watchdog restart is invisible to (a); it fires only once the restart rate-limit (`StartLimitBurst`/`StartLimitIntervalSec`) is exhausted and systemd gives up. That's correct for "died for good," but the "watchdog quietly restarted it once" event needs (b).
- **Noise control by construction:** apply `onFailure` only to user-relevant units (the shell, restic, wallpaper pipeline, audio, network) — not every transient system unit.

**(b) Long-running QuickShell/DBus watcher on `org.freedesktop.systemd1`** — `Subscribe()` then watch `JobRemoved` (result ≠ `done`) and/or per-unit `ActiveState`→`failed`. Surfaces failures *live* and catches transient restarts that (a) misses — **but** only works while the shell runs (misses boot/pre-shell failures — the moments you most want) and needs the same relevance filter. Realistic QML path: `busctl monitor --system org.freedesktop.systemd1` or poll `systemctl --failed --no-legend` behind a `Process`; or reuse a DBus-IPC helper (DMS routes `login1`/DBus subscriptions through its Go daemon via `DMSService.qml` `dbusSubscribe()` — not native QML system-bus subscription).

**restic/borgmatic (B14) failures route through this same channel** — they're ordinary units; add `onFailure = [ "notify-failure@%n.service" ]` so backups land in the same notification history with one status vocabulary.

**Recommendation (B13): the `OnFailure` template unit bridged via `pkgs.systembus-notify` is the reliable base; add the live DBus watcher only as an optional enhancement.** (a) is event-driven, catches hard/boot failures, queues even if the shell is down, and gets the excerpt via `journalctl -u %i`. Apply `onFailure` selectively for zero noise. (b) is a nice-to-have for surfacing transient restarts live; it is NOT the base because it misses everything before the shell starts.

**Bonus find — the shell's OWN resilience (directly fixes a MASTER bug):** iNiR's `assets/systemd/inir.service` is a watchdog masterclass worth adopting for the target's QuickShell shell unit:
- `Restart=on-failure`, `RestartSec=5`, `StartLimitIntervalSec=30` / `StartLimitBurst=3` (crash-loop guard — 3 restarts in 30 s then stop; the comment correctly notes these must live in `[Unit]`, not `[Service]`). This rate-limit is exactly what makes (a) fire *for the shell*: 3 rapid crashes → `failed` → `notify-failure@` → "aurora-shell watchdog gave up after 3 restarts."
- **`KillMode=process` + `KillSignal=SIGTERM`** — only the shell's main PID is signalled, so **user-launched apps (terminals, media players, agent sessions) SURVIVE a shell restart.** This is a systemd-level fix for the §5 / accepted-findings bug *"apps launched from the bar die when it restarts"*, beyond the setsid/disown detach pattern.
- `SuccessExitStatus=143` (clean SIGTERM excluded from "failure"), `ExecStopPost=-… cleanup-orphans`, `PartOf`/`After`/`Requisite=graphical-session.target`, `LimitCORE=0` + `QS_DISABLE_CRASH_HANDLER=1` (avoid 45–90 MB coredumps on QS hot-reload segfaults).

DMS's `dms.service` is the alternative shape: `Type=dbus` owning `org.freedesktop.Notifications`, `Restart=on-failure`, `RestartSec=1.23`, `ExecReload=pkill -USR1`.

---

## 5. BACKUP (B14) — restic vs borgmatic

One decision: single laptop pushing `~/Documents`, the wallpaper collection, project repos (possibly-uncommitted work), and `~/.local/state` to an external disk **and/or** a cloud target, scheduled/unattended, with a "last backup: OK/failed, N h ago" line in Settings › System and failures routed into the B13 channel. Hardware envelope: dual-core i3 / 8 GB / 121 GB / zram-only.

**The deciding axis is the target.** restic and Borg/borgmatic are close on dedup/compression/encryption/FUSE-restore, but diverge exactly on "cloud, unattended, one laptop":

| Dimension | **restic** | **borgmatic** (BorgBackup + wrapper) |
|---|---|---|
| Backends/targets | **Native local disk, SFTP, S3, Backblaze B2, GCS, Azure, + anything via rclone** — decisive | **SSH/local only**; cloud needs an awkward `rclone serve`/`mount` shim |
| Dedup / compression | content-defined chunking; zstd on by default | slightly tighter archives |
| Encryption | AES, **password-only** (no keyfile to lose) | repokey/keyfile — more to manage |
| NixOS module | first-class `services.restic.backups.<name>` → generates `.service` + `.timer` | `services.borgmatic` → `borgmatic.service`/`.timer`; **historic footgun**: nixpkgs #206928 installed the timer but didn't enable it (backups silently never ran) — workaround `systemd.timers.borgmatic.wantedBy = [ "timers.target" ]`; whether still needed on 26.11 is a live-test |
| Restore | `restic restore` + **`restic mount`** (FUSE-browse every snapshot) | `borg extract` + `borg mount` — also excellent |
| Status source | `restic snapshots --json --latest 1` (last-good time) + systemd unit `Result`/`ExecMainStatus`; exits non-zero on failure | `borgmatic info --json` + native monitoring hooks (Healthchecks/ntfy) — richer but heavier than one laptop needs |

**Key restic NixOS options** (`services.restic.backups.<name>.*`): `.repository`/`.repositoryFile` (e.g. `/mnt/backup/restic`, `sftp:…`, `b2:bucket:path`, `rclone:remote:path`), `.passwordFile`, `.environmentFile` (backend creds), `.paths`, `.exclude`, `.pruneOpts` (`["--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12"]`), `.timerConfig` (`{ OnCalendar = "daily"; Persistent = true; }`), `.initialize = true`, and **`.createWrapper` (default true)** — installs a `restic-<name>` wrapper preloaded with repo+password so restore, `mount`, and the status query run without re-specifying creds (ideal for the Settings status tile: `Process`-run `restic-<name> snapshots --json --latest 1`, parse `time`).

**Recommendation (B14): use restic via `services.restic.backups`.** For one laptop that may target an external disk *and/or* a cloud bucket, restic's native local+SFTP+S3/B2+rclone backend support is decisive (Borg is SSH/local-only + rclone shim); the NixOS module is first-class and free of borgmatic's timer footgun; `createWrapper` makes restore, FUSE-browse, and the status line trivial; password-only encryption is one less secret to lose. Schedule nightly (`OnCalendar = "daily"; Persistent = true`) with keep-daily/weekly/monthly prune, and add `onFailure = [ "notify-failure@%n.service" ]` so backup failures ride the B13 channel. Compression level + off-peak schedule are the only i3/8 GB knobs.

---

## 6. EMOJI / SPECIAL CHARS (B15)

### 6a. Surface — iNiR sourced (BOTH mouse+hotkey paths exist)

iNiR provides two complementary paths, both traced in source:

- **In-launcher emoji mode (QuickShell):** typing the `:` prefix (`SearchWidget.qml`/`LauncherSearch.qml`/`SearchBar.SearchPrefixType.Emojis`) runs `Emojis.fuzzyQuery()` — fuzzy search over a **1,897-line emoji database** in `scripts/emoji/emoji-data.sh` (parsed after a `### DATA ###` marker by `services/deferred/Emojis.qml`). Selecting a result runs `execute: () => { Quickshell.clipboardText = emoji }` (**copies** to clipboard). Plus `Overview.toggleEmojis()` → `openWithPrefix(":")` — a **dedicated action** bindable to a **System-group button AND a hotkey** (Win+. / Cmd+Ctrl+Space) that opens the launcher straight into emoji mode. This is precisely the "launcher-mode button + hotkey reflex" the task asks for.
- **Standalone picker `emoji-data.sh [type|copy|both]`:** a fuzzel dmenu (`--match-mode fzf`) that **`wtype`s the selected emoji directly into the focused field** (with `wl-copy` fallback) — the true Windows-Win+. reflex (it types into the app, not just the clipboard). Bind Cmd+Ctrl+Space / Win+. to `emoji-data.sh type`.

**Adaptation (small glue on a sourced surface):** retheme fuzzel/launcher to glass; package `wtype` + `wl-clipboard` (`wtype` needs the virtual-keyboard protocol — Hyprland supports it); choose the launcher path (copy) vs the `wtype` path (type-into-field), or expose both (a System-group "😀" button → launcher `:` mode; a hotkey → `emoji-data.sh type`). Special characters ride the same DB/fuzzy surface.

### 6b. Color emoji font — verification

Three moving parts to get color emoji (not tofu) in terminals + GTK/Qt apps:

1. **Install the font — current attribute is `pkgs.noto-fonts-color-emoji`** (the old `noto-fonts-emoji` was renamed ~2024; if a rebuild throws an "attribute renamed" note, that's the alias — verify against installed 26.11 nixpkgs). Add to `fonts.packages`.
2. **fontconfig emoji fallback: `fonts.fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];`** (real NixOS option, nixpkgs PR #67667) — maps the generic `emoji` family so any missing glyph cascades to Noto Color Emoji.
3. **`fonts.fontconfig.useEmbeddedBitmaps = true;`** — Noto Color Emoji is a CBDT/CBLC **bitmap** font; without this, some apps (Firefox is the classic) render tofu even with the font installed.

**The Chrome gap (real):** Chrome/Chromium **bundle their own emoji**, so they show color emoji even when system fontconfig is misconfigured. "Chrome looks fine" is **not** evidence the OS is fixed — the tofu check must be done in a terminal + a GTK app + a Qt app, never in Chrome.

**Kitty:** renders color emoji via normal fontconfig fallback once the font is installed — **no `symbol_map` needed for standard emoji** (`symbol_map` is for forcing codepoint ranges, e.g. Nerd Font glyphs; kitty #6572 shows it doesn't reliably fix the narrow dual-presentation-no-VS16 edge case anyway). Keep `font_family` = FiraCode Nerd Font (§3), let fallback handle emoji. **Avoid `pkgs.google-fonts`** (nixpkgs #327846): it ships a *scalable* `NotoColorEmoji-Regular.ttf` that shadows the correct non-scalable file and breaks Kitty glyph loading — install `noto-fonts-color-emoji` specifically.

```nix
fonts = {
  enableDefaultPackages = true;
  packages = with pkgs; [ noto-fonts noto-fonts-color-emoji /* + FiraCode NF, Inter, Papirus per §3 */ ];
  fontconfig = {
    defaultFonts.emoji = [ "Noto Color Emoji" ];
    useEmbeddedBitmaps = true;
  };
};
# Do NOT add pkgs.google-fonts — breaks Kitty color emoji (nixpkgs #327846).
```

**Recommendation (B15 font): `noto-fonts-color-emoji` + `defaultFonts.emoji` + `useEmbeddedBitmaps`, and no `google-fonts`.** **LIVE-TEST (execution-time):** after rebuild + `fc-cache -f` + re-login, `fc-match emoji` should resolve to `NotoColorEmoji.ttf`, and the "does anything still show tofu?" check must be done visually in Kitty + a GTK app (Thunar) + a Qt app — **explicitly excluding Chrome** (false positive). Not verifiable in a research session.

---

## 7. BONUS FINDS (flagged)

- **DankMaterialShell is a one-stop backend for this entire task cluster.** Beyond the polkit agent and greeter, its `Services/` ship: `SystemUpdateService.qml` (C3 System page), `PortalService.qml` (B9 file-picker portal), `PrivacyService.qml` (B4 mic/cam-in-use dot), `SettingsSearchService.qml` (B7 search), `TailscaleService.qml` (C18), `TrashService.qml` (§4.12), `CupsService.qml` (§4.14 printing), `WallpaperCyclingService.qml` (C10), `PowerProfileWatcher.qml` (B3). If any surface adopts DMS, these come along — worth a look when the app-lifecycle / hardware-truth sessions run.
- **iNiR `modules/shellUpdate/ShellUpdateOverlay.qml`** — an in-shell update overlay (pairs with the C3 System › Updates page).
- **iNiR `inir.service` `KillMode=process`** — the systemd-level fix for the §5 "apps die when the bar restarts" bug (detailed in §4 above).
- **Nexus `NetworkPage`** is the richest sourced network-settings UI found (461 LOC + 6 detail pages: add / saved / ethernet-detail / network-detail / add-VPN / all-networks) — reuse it for the Network settings page and dropdown "full view," **but drop its argv-password path** (use the safe secret-agent API; ratifies the cxOrz/Nmcli finding).
- **Settings search is free** — built into Nexus (`NavPane` "Search settings") and DMS (`SettingsSearchService`); the §4.11 settings-search surface falls out of the page registry.
- **Nexus is missing glass sliders** (only a transparency on/off toggle; base/layer values are display-only) — the target's Appearance glass-tuner must ADD opacity/blur sliders (small glue on Nexus's existing `SliderRow`), matching iNiR's live glass tuner intent. (Confirms caelestia.md §Glass.)
- **hyprpolkitagent live config** (`hyprtoolkit.conf` hot-reload, no restart) — noted if the standalone-agent route is ever taken.

---

## 8. WHAT I ACTUALLY READ / VIEWED vs WHAT I DIDN'T

**Read in full:** `SESSION_PREAMBLE.md`, `MASTER_REQUIREMENTS.md`, `GAP_REVIEW.md`, `research/caelestia.md`.

**Nexus (caelestia shell):** listed all 45 files; counted LOC (8,569) and every import statement (`Caelestia.Config`×57, `qs.services`×44, etc.). Read line-by-line: `Nexus.qml`, `WindowFactory.qml`, `NexusState.qml`, `PageRegistry.qml`, `PageCompRegistry.qml`, `NavPane.qml`, `navpane/NavLocations.qml`, `Pages.qml`, `common/PageBase.qml`, `common/ToggleRow.qml`, `common/SliderRow.qml`, `common/SelectRow.qml`, `pages/WallpaperAndStyle.qml`, `pages/services/NotificationsPage.qml`. **Did NOT** read every page leaf line-by-line (read ~6 of ~30 page files + 4 of ~17 `common/` rows) — enough to establish the pattern and the coupling depth conclusively; the remainder are more rows-over-`Config`.

**iNiR:** read `modules/polkit/Polkit.qml` + `PolkitContent.qml`, `services/deferred/Emojis.qml`, `scripts/emoji/emoji-data.sh` (header + mode logic), `assets/systemd/inir.service`; traced emoji invocation across `SearchWidget.qml`/`SearchBar.qml`/`Overview.qml`/`LauncherSearch.qml`; listed `modules/settings/` (25 files), `modules/shellUpdate/`, `dots/sddm/`. **Did NOT** read the iNiR settings pages line-by-line (noted as an alternative scaffold only).

**DankMaterialShell:** read `Services/PolkitService.qml`, `Modals/PolkitAuthContent.qml`, `assets/systemd/dms.service`; listed `Modules/Greetd/` (file sizes/roles), full `Services/` + `Modules/` dirs, `core/internal/greeter/`, `core/internal/pam/`, systemd assets. **Did NOT** read `Modules/Greetd/GreeterContent.qml` in full (88 KB / ~2,900 LOC — confirmed size and role, not line-by-line).

**VIEWED (images):** 5 running-build screenshots the user captured (left vertical bar; nested per-app tray menus — Bluetooth + Discord; the multi-tab dashboard drawer; a live window-preview popout — feishin; keep-awake/DND duration submenus) — these establish the exact component/visual system a themed Nexus/polkit dialog inherits. **regreet** login screen (viewed) + set of 6 screenshots enumerated. **tuigreet** `contrib/screenshot.png` (viewed).

**Web (text):** confirmed `Quickshell.Services.Polkit.PolkitAgent` is a real, documented module (quickshell.org docs); regreet theming/config (background fit, GTK theme, GTK4 CSS); hyprpolkitagent theming ceiling (hyprtoolkit.conf only); DankGreeter productization; the gnome-keyring + greetd-autologin no-password gotcha (ArchWiki / GNOME PAM / NixOS Discourse).

**NOT viewed / honest gaps:**
- **No discrete standalone Nexus screenshot found.** Web search returned docs/guides, not a Nexus still; the caelestia showcase video (linked in the shell README as a GitHub user-attachments asset) may contain Nexus frames, but I could not frame-extract a video with available tools. **Nexus visual grounding is therefore via the full code read + the running build's shared component system** (same `StyledRect` cards, `ConnectedRect` rows, `MaterialIcon`, blob chrome, cream/dark theming) seen in the 5 screenshots — not a dedicated Nexus capture. Stated plainly so the user can catch the gap.
- **No hyprpolkitagent or in-shell-polkit dialog screenshot** (none published for hyprpolkitagent). Polkit assessed via line-by-line code read of both QuickShell dialogs + the running-build dialog/menu language.
- **Backup (B14), the B13 OnFailure-vs-DBus mechanism detail + NixOS wiring, and the B15 color-emoji font config** were researched by a parallel subagent (instructed to read `SESSION_PREAMBLE.md` first; research-only) and are **integrated inline** in §4/§5/§6b. It read `MASTER_REQUIREMENTS.md` + `GAP_REVIEW.md` (B13/B14/B15) + both shells' systemd units + the DMS `DMSService.qml` `dbusSubscribe()` helper, grep-confirmed neither shell ships a backup/failure-watcher module, and web-sourced the NixOS options (restic/borgmatic modules, `systembus-notify`, `noto-fonts-color-emoji`, fontconfig `defaultFonts.emoji`, Kitty/google-fonts caveats). It viewed no images (these three legs are non-visual by framing).

**Open execution-time live-tests (carry to the plan/execution sessions):** (1) keyring auto-unlock under greetd auto-login — confirm no gcr prompt on first secret access; else blank-keyring or LUKS-key path (B8). (2) `Quickshell.Services.Polkit` present in the pinned QuickShell revision, and no second polkit agent running (B8). (3) color-emoji tofu render check in Kitty + GTK + Qt, excluding Chrome (B15). (4) whether borgmatic's timer `wantedBy` workaround is still needed on 26.11 — moot if restic is chosen (B14). (5) regreet builds/themes correctly under the target's greetd + GTK theme (B12).
