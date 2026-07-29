# Source ledger

Every imported idea or adapted component is reviewed before use. Attribution is
upstream repository plus path. Reconciled against GRAND_PLAN.md §13 on 2026-07-29.

## Vendored components

| Component | Upstream repo | Upstream path | Vendored path | Local delta |
|---|---|---|---|---|
| aurora-shell chassis | `github.com/caelestia-dots/shell` | `/` | `modules/home/aurora-shell/` | Attribution headers; path-input revision fallback build shim; aurora scheme defaults (ladder pinned, dark default, accent families); Stage 1C cutover — HM module renamed to `programs.aurora-shell` + unit `aurora-shell` (§2.2 hardening, `KillMode=process`), dunst fallback keeper carried with a static `assets/fallback-dunstrc`, write-if-absent `assets/aurora-scheme.json` state seed. <!-- # Aurora: Stage 1B/1C local delta. --> |
| window-minimize | `github.com/OnlyLyan/omarchy-desktop-shell` | `05-hyprbars-titlebar/files/window-minimize` | `scripts/window-minimize` | Vendored **verbatim** (upstream now cloned to `repos/omarchy-desktop-shell`); only an attribution header added — runtime deps come from the `writeShellApplication` wrapper. The same repo's `hyprbars.conf` traffic-light button values (red/yellow/green ✗/⌄/◇) are used in `modules/home/hyprland/hyprbars.lua.in`, translated to the native-Lua `hl.plugin.hyprbars.add_button` API. (Stage 2A) |

## Bespoke plugins

| Plugin | Source | Built against | Why it exists |
|---|---|---|---|
| `aurora-minimize` | `modules/home/hyprland/aurora-minimize/` — written for this build, not adapted from an upstream | ABI-pinned via `pkgs.hyprlandPlugins.mkHyprlandPlugin` against the patched Hyprland 0.55.4; verified to consume the **same** `hyprland-0.55.4-dev` output as `hyprbars` | The final same-workspace minimize backend, replacing the rejected `special:min-<address>` approach (decision 20 item 13). It reuses the compositor's own primitives — `setHidden()` plus `CLayoutManager::removeTarget()`/`newTarget()`, exactly the pair `Actions::toggleSwallow()` already ships — so a minimized window leaves render/input/layout while **retaining its original workspace**, because `m_workspace` is read and never written. Registers three surfaces: Lua `hl.plugin.auroraminimize.minimize/restore` (consumed by `keybinds.lua`), `addDispatcherV2` entries, and — the form the shell actually uses — `registerHyprCtlCommand` for `hyprctl aurora:minimize [addr]` / `hyprctl aurora:restore <addr>`. The plain `hyprctl dispatch` route is unusable here: under native-Lua config `HyprCtl.cpp:1107-1109` rewrites `dispatch X` into `hl.dispatch(X)`, which needs a Lua callable, not a bare name. |

Prior art note: every public Hyprland minimize tool surveyed (hych, minhypr, pyprland)
uses the special-workspace trick this build rejects. The primitives here are
long-standing compositor internals, but this composition of them is not
community-proven and is treated as requiring a live-test pass.

## Carried compositor and plugin patches

Narrow, isolated patches carried against pinned upstreams. Each is justified by a
proven mechanism read from the pinned source, applies with zero fuzz, and is
listed here before it is adopted.

| Patch | Upstream | Pinned revision | Touches | Why it is carried |
|---|---|---|---|---|
| `modules/nixos/patches/hyprland-drag-anchor.patch` | `github.com/hyprwm/Hyprland` | `0.55.4` (`a0136d8c`) | `src/layout/supplementary/DragController.cpp`, one hunk inside `if (m_dragThresholdReached)` | Restores Hyprland's own former behaviour: a tiled window picked up for a drag keeps the normalized grab anchor instead of jumping centre-under-cursor. Operator decision #10 (2026-07-22). |
| `modules/nixos/patches/hyprland-deco-border-grab.patch` | `github.com/hyprwm/Hyprland` | `0.55.4` (`a0136d8c`) | `src/managers/input/InputManager.cpp`, three hunks — `processMouseDownNormal` band, its input-decoration guard, and the matching `setCursorIconOnBorder` hover band | `processMouseDownNormal` measured the resize grab band outwards from the *client surface* (`m_realPosition`/`m_realSize`), so on a window carrying a reserved top decoration the band fell 18 px short of the visible top corners; and hyprbars cancels the event-bus button press for any point inside its own box (`hyprbars/barDeco.cpp:221`), which is why `extend_border_grab_area` provably could not reach through. The patch measures the band from `getWindowBoxUnified(RESERVED_EXTENTS)` — the idiom already used at `src/layout/LayoutManager.cpp:226` — and skips it over decorations flagged `DECORATION_ALLOWS_MOUSE_INPUT`, reusing the predicate `setCursorIconOnBorder` already applies, so the click band and hover cursor agree by construction. Upstream `hyprwm/hyprland-plugins#355` is open with no PR and no commit, and the causing code is unchanged on both `main` branches, so there is nothing to backport. Operator decision #19 (2026-07-28). |
| `modules/home/hyprland/patches/hyprbars-hover.patch` | `github.com/hyprwm/hyprland-plugins` | `v0.55.0` (`90e66baf`) | `hyprbars/` button hover state | Adds the button hover-highlight state the plugin does not implement. (Stage 2A) |
| `modules/nixos/patches/hyprland-dwindle-resize-workarea.patch` | `github.com/hyprwm/Hyprland` | `0.55.4` (`a0136d8c`) | `src/layout/algorithm/tiled/dwindle/DwindleAlgorithm.cpp`, one hunk in `resizeTarget` | **Upstream regression, still present on `main`.** Since the 0.55 layout rewrite the dwindle node tree tiles `CSpace::workArea()` — `logicalBoxMinusReserved()` *inset by* `general:gaps_out` — but `resizeTarget` still measured its edge-stick flags against the un-inset monitor box. `STICKS()` tolerates 2 px and this build runs `gaps_out = 8`, so **all four `DISPLAY*` flags were permanently false**, silently disabling the "this side is a work-area edge, move the opposite border instead" fallbacks that give a corner grab its second axis. Confirmed against live geometry: tiled windows sit at x=70 while the code compared against x=60 — a 10 px miss against a 2 px tolerance. Upstream made this exact correction, with the same tolerance, for the same feature, at the *hit-resolution* site (`Compositor.cpp:1054-1099`, already in our build) and missed this one. Carried as a separate patch from the deco-border-grab fix because it is a different subsystem and must be revertible without losing floating corner resize, which already passes. Operator failure report, 2026-07-29. |

The chassis was vendored from the on-disk snapshot audited by the research corpus. The upstream remote `github.com/caelestia-dots/shell` is recorded for future diffs. A history graft was deliberately not performed so the audited bytes stay exact (PM decision, 2026-07-21).

## Source map — repo → verified use (reconciled against GRAND_PLAN.md §13, 2026-07-29 revision)

Reorganized to mirror `GRAND_PLAN.md` §13's structure so this ledger and the plan's own source
map stay legible against each other. **No row below was dropped relative to the previous
version of this file** — rows whose role changed carry a corrected "Use" column; rows for
sources the revised plan no longer treats as primary (Matugen, awww, Waypaper) are kept and
explicitly marked, not deleted, per the project's standing rule against silently narrowing
sources.

### Active implementation donors

| Source | Planning revision | Use |
|---|---|---|
| AlexbringsMercy/nix | `4974921` | Original host configuration and repository |
| NixOS/nixpkgs | `567a49d1913ce81ac6e9582e3553dd90a955875f` | Pinned package/system base |
| NixOS/nixos-hardware | `fccfa9031a85b78a437f2f153c1f6449f3bc3185` | Apple T2 module |
| nix-community/home-manager | `165228b0efefc3e635e5174020c40ea64271dc25` | User configuration |
| caelestia-dots/shell (main repo + CLI, distinct from the vendored chassis fork above) | `172fdd3b662eeae94b32bac27d7fc669e6061e8f` (recorded pin; live reference clone under `repos/caelestia` has since advanced to `2e5598c6` — PM to confirm which should be tracked) | Hyprland Lua patterns (gestures/keybinds/rules), `toggle.py`, CLI subcommands, scheme/theme fan-out, btop/fastfetch/Fish assets |
| ilyamiro/nixos-configuration | `d66c4a5915d2991d2e1cebe16f4c9b21f9fa0e6e` | **Top bar structure nearly 1:1** and its independent expanding widgets (media/EQ, calendar/weather, network/BT/battery panels); motion/choreography vocabulary (`morph`, `selectionStretch`, cinematic staging); selected lock-screen interaction/motion details only (not the lock's visual identity); clipboard grid/morph presentation; FocusTime. Does not own the left rail, shell backends, or palette generation. |
| agridyne-dotfiles-dt/rice-contents | `ede48282609c997a465d923b5e6a7fe7a89f1567` | Major glass/negative-space visual language; left-rail app-button treatment; KDE/Chrome color-role mapping; Kurve visualizer sizing reference; **primary visual-composition owner of the lock screen** (UNRESOLVED — the checked-out repo's own README lists the lock screen as unfinished/WIP with no lock asset present; see reconciliation report §3.1 before treating this as a finished visual reference) |
| liixini-skwd-wall (+ its `skwd-daemon` flake input, pinned separately) | `74be65663538ee6175ecc73f896a9d6229d4b612` (app); daemon pin `36f165a…` per `GRAND_PLAN.md` §4.1, not yet materialized in `flake.lock` (Stage 4 not reached) | The complete wallpaper system: UI, Rust daemon, 38 shader transitions, library/import, JSON-RPC socket (`wall.apply`/`wall.list`/`wall.random_start`/…), `skwd.wall.applied` broadcast — the palette pipeline's trigger. **Not** the semantic palette authority. Its internal Matugen use is scoped to its own picker UI only (confirmed present at `repos/liixini-skwd-wall/data/matugen/`), pointed back at the published system scheme. |
| AvengeMedia/DankMaterialShell | `fe1a783ec210071f6c71453e18479bfe3f2496d2` (recorded pin; live clone under `repos/dankmaterialshell` has since advanced to `bf12665a` — PM to confirm which should be tracked) | `DisplayConfig`/`DisplayService` (functional Display backend); lock lifecycle donor (`LockedHint`, re-acquisition, bounded PAM retries — not the lock's visual identity); drag/drop mechanics where needed; greeter/safety patterns. **Not** primary rail/dock owner — caelestia's `modules/bar/`+`modules/windowinfo/` hold that role; DMS supplies grouping/context/drag *patterns* only. |
| snowarch/iNiR | `01434067705d9dfce10709dbe680474dacc35261` | Polkit dialog (`modules/polkit/`, 155 lines); Cliphist service/panel (`services/deferred/Cliphist.qml`); emoji DB+picker; desktop `ContextMenu`; `MicToggle` pattern; notification ingress cap + fullscreen/game suppression; systemd unit-hardening pattern (`assets/systemd/inir.service` — `Restart=on-failure`, `KillMode=process`, `StartLimitBurst`); GTK/Qt/Kitty theme writers. **Not** top-bar/task-list owner; not primary lock face. |
| Vast shell (web only — `github.com/myamusashi/vast-shell`, not cloned under `repos/`, consistent with `SESSION_PREAMBLE.md`'s own web-only source list) | rev `288493781669210aa45072d7d2b983e928dc1d91` | Lock-screen depth planes (two-plane wallpaper, foreground/background separation) and the gated multi-beat unlock engine. Documented in `research/lock-screen.md`; safety caveats recorded there (no persistent lock intent on restart as shipped, hard-coded `wayland-1`) are not yet re-verified against source this session. |
| hyprwm/hyprland-plugins | `90e66baf99c9025b1d5e9c9e58dd3c80d0911ea2` (pinned `v0.55.0`) | **hyprbars** (confirmed present) — carried hover patch, narrow ABI-matched patches. **Hyprexpo is NOT present in this checkout** (no `hyprexpo/` directory; repo's own README "Plugin list" omits it) — its actual current source needs re-verification before Stage 5; do not assume this repo supplies it until confirmed. |
| luisbocanegra/kurve (web only, via agridyne's screenshots + `research/agridyne.md`) | not applicable — reference only | Optional left-rail cava-strip visualizer: sizing/behavior reference (orientation, block width/gap, transparent bg). A KDE Plasma plasmoid, not QuickShell-native — requires reimplementation over the existing shared `cava` provider, not a code port. |
| end-4/dots-hyprland | `c04b0bbc8143a2b2166c1f699f7583cb28ff78fe` (recorded pin; live clone under `repos/end4-dots-hyprland` has since advanced to `446504ad` — PM to confirm which should be tracked) | Hyprland Lua organization and motion reference; hypridle staged-dim/lock/DPMS/suspend pattern; selected animation/base snap references |
| LinuxBeginnings/Hyprland-Dots | `bca86bb` | ML4W diffuse radial wallpaper-derived gradient technique for hero surfaces (lock, session menu, expanded music, Nexus sidebar). *(Corrected — previously recorded as "Waybar glass layout/style patterns"; Waybar is retired and was never the actual contribution.)* |
| Frost-Phoenix/nixos-config | `66cc581645bef74898bd3eb36d9f4138d1069d02` | Nix/Home Manager wiring patterns |
| newmanls/rofi-themes-collection | `43ec2f5` | Launcher layout reference *(historical — Rofi itself is retired; the layout ideas informed the carried caelestia launcher, not a live Rofi theme)* |
| snes19xx/surface-dots | `7bb430e22c6a532ae8b8be19b53d45130ba36325` | Launcher/widget sizing and terminal-startup reference. *(New row — previously conflated with the newmanls row above under one entry; these are two different upstream repos.)* |
| cxOrz/dotfiles-hyprland | `0961d64cf73dd61b6e8aac9a2ba0070c52c1afa2` | Selected panel/service and OSD-timing patterns. *(Narrowed from "QuickShell control/power/notification UI" — the revised plan is explicit that cxOrz is not the primary system-panel architecture.)* |
| saatvik333/hyprland-dotfiles | `3085c4a745fd619a40398661a7da6e34d860ebad` | Terminal/dev-experience quality bar; sourced fastfetch pieces (`star.txt`, `cyberpunk-mask.txt`, `illuminati.txt`, `satan-cross.txt` — vendored renamed `gothic-cross.txt`, operator call) |
| abusoww/tuxmate | `f73be3a8969f126caa5b1f3cd0b377f4b5306c35` | Installer UX/interaction reference (a Next.js web app, not a Nix/Hyprland source — confirmed not a package-backend authority) |
| omarchy-desktop-shell | `0a6a6cc6b96d2ef92899c95587b456690ff99c21` | Historical hyprbars config values (vendored, see Vendored components table above); minimize research reference. `special:min-*` explicitly rejected as the final minimize backend. |

### Palette-pipeline ownership (called out separately — this is a chain, not a single row)

`skwd-wall` (wallpaper authority, triggers) → **the project's patched caelestia scheme engine**
(semantic authority — generates and publishes the complete auto-light/auto-dark role set) →
iNiR + agridyne (consumer-mapping/cohesion donors) → Hellwal (fallback generator only) →
Matugen (**not** system-wide authority; scoped to skwd's own picker UI, confirmed present at
`repos/liixini-skwd-wall/data/matugen/`, and pointed back at the published system scheme so the
picker itself stays on-theme). See `GRAND_PLAN.md` §4.0 for the full ownership-chain diagram.

### Policy/visual references (not primary code owners)

| Source | Planning revision | Use |
|---|---|---|
| mubin-thinks/minimal-wm-config | `f0f3d653d9e6fac8d6931e6bed6e8c942ce22d80` | Whole-system cohesion quality reference; surfaced `gowall`. Its pinned-dark-surface policy is explicitly not adopted. |
| nathanhoulamy/macos-dotfiles | `bb6b8fda9368234b6509045437b0ff824104647f` | Whole-system theming/cohesion reference; no primary component ownership |
| SherLock707/hyprland_dot_yadm | `2e31e0702b7d44ceac2d0e2bf3ab61ecc71171f1` | Wallpaper color-picking/theming research reference (incomplete read — must not silently become final code) |
| elifouts/waybar | `5abd962a0e2bbdf196d764f6fe1d5e1c7ab5df9d` | Historical bar/glass mechanics reference. Waybar implementation is retired; kept as a geometry/alpha reference only. |
| GlassesArch | `fd20770f131dcb56d0f6c62394a2bfa26ed912f7` | Historical bar geometry reference. Waybar implementation is retired. |
| Sharddots | `866e4a0a3979bca4af3fd0e56f225e49941ec675` | Historical blur-parameter reference. Waybar implementation is retired. |
| ekremx25 (web only, not cloned — consistent with `SESSION_PREAMBLE.md`'s web-only list) | not applicable | Display-panel row-layout visual reference; DMS remains the functional Display backend |
| angelobdev/t2-easyeffects-preset + AutoEq (web only, not cloned) | not applicable | Default speaker preset (`mbp.json`) + per-headphone AutoEq exports; audio backend role only |
| Harshil-Anuwadia wintux GRUB theme | `525dc38fce1e3ba0bf86c8a7f5241a31fcdc14eb` | Deferred; current bootloader path unchanged |

### Fallback, optional, deferred, or retired — kept, not dropped

| Source/tool | Planning revision | Status |
|---|---|---|
| InioX/matugen | upstream research `4112d352914742ba69f6380fd07984adba02d376`; runtime nixpkgs `4.0.0` | **Retired as system-wide palette authority.** May remain scoped inside skwd-wall's own picker UI only (confirmed present in skwd's tree). Do not create a second independent Matugen fan-out. *(Corrected — previously listed unqualified as "wallpaper-derived palette generation," implying primary-authority status it no longer has.)* |
| InioX/matugen-themes | `901efeb1dfbcb436c327d581e176cc145654c990` | Same scope note as above — templates relevant only to the scoped internal use, if used there at all |
| Hellwal (web tool, not cloned) | not applicable | Named fallback generator **to the patched caelestia scheme engine** only, if it fails acceptance. Must feed the same semantic role contract and atomic transaction. *(Corrected — previously implied as a fallback to Matugen; the primary chain no longer runs through Matugen at all.)* |
| Hyprlock | system package | **Emergency lock fallback only**, never concurrently launched with the composite lock. Not a placeholder to build toward — the "old hyprlock, matugen-colored, default avatar" seen mid-build (`ISSUE_LOG.md` #27) is this fallback, not a work-in-progress final surface. |
| gowall (web tool) | not applicable | Optional inverse wallpaper-recoloring tool for images that fight a chosen manual preset |
| snappy-switcher (web tool) | not applicable | Cut-list fallback for Alt+Tab, used only if the composed live cycler (caelestia preview + Hypr MRU + ilyamiro motion) fails |
| LGFae/awww | nixpkgs `0.12.1` | **Retired entirely.** skwd-wall's own daemon owns wallpaper rendering/transitions; the `awww kill` guard path is unreachable by design. Kept as a row for provenance, not as an active dependency. |
| anufrievroman/waypaper | `f2d2fa0` / nixpkgs `2.7-unstable-2026-01-13` | **Superseded by skwd-wall.** No longer the active picker. Kept as a row for provenance. |
| noctalia-dev/noctalia-shell | `3abfa1fc09b62dc4cdeeb7b787886f075696f0b7` | **UNRESOLVED status, not confirmed dropped.** Absent from `GRAND_PLAN.md` §13 entirely; last substantive mention is in `EXECUTION_LOG.md`'s explicitly-retired-architecture section, grouped with DMS/caelestia/iNiR as a lifecycle/palette comparison reference — those three were carried forward into the current plan, noctalia was not. No explicit rejection decision was found. PM to confirm whether this is a deliberate cut before removing this row. |
| DMS primary dock, iNiR top task list | roles, not repos | Rejected ownership roles; narrow donor patterns from each remain usable per their rows above |
| omarchy `special:min-*` | reference only | Rejected minimize backend; the *window-minimize script* (Vendored components table) is unaffected — it's a titlebar-button script, not the special-workspace model |

### Runtime/native and utility layer

| Source | Planning revision | Use |
|---|---|---|
| quickshell-mirror/quickshell | `59e9c47b0eb48a9e4bcf9631fa062ee939bd2e83` / nixpkgs `0.3.0` | Native shell/service/IPC APIs; polkit agent backend (`Quickshell.Services.Polkit.PolkitAgent`) |
| quickshell-mirror/quickshell-examples | `c6d1236efe265ae34e8c78a27ee9e196ea19d895` | Native mixer and service examples |
| wwmm/easyeffects | tag `v8.2.0` (`469a51700aeb18bf2c1d7810de2846f898bdfd0a`) | Validated modern `equalizer#0` output-preset schema and service loading; invisible backend for the ilyamiro-sourced EQ widget UI |
| karlstav/cava | nixpkgs `0.10.7` | On-demand 28-bar, 30 fps raw visualizer stream — shared provider consumed by both the top media island and the optional rail-foot Kurve-style visualizer |
| Open-Meteo Forecast API | `https://api.open-meteo.com/v1/forecast` | HTTPS weather data normalized into a 15-minute offline cache, feeding the top calendar/weather expansion |
| Alex's existing local wallpaper collection | curated set under `~/Pictures/Wallpapers` (skwd's library dir) via skwd's own import; not tracked by Git | Palette-diverse test set and lock-screen backgrounds for the Stage 4 glass/palette gate |
| nix-software-center / `nh` / `nvd` / restic / udiskie / systembus-notify / gpu-screen-recorder / t2fanrd / hyprsunset / hyprpicker / tesseract / zellij / fzf+bat+fd / Starship / LazyVim / regreet+tuigreet / plocate | named tools, in-flake or nixpkgs | Named utility layer — each keeps only the role assigned in its `GRAND_PLAN.md` section; no utility becomes a surface owner by convenience (§13.4) |

## QuickShell component adaptation notes

- `cxOrz/dotfiles-hyprland`: reviewed `modules/controlcenter/`
  (`ControlCenter`, `FeatureTile`, `WifiSection`, `BluetoothSection`,
  `BrightnessSection`, and `VolumeSection`), `modules/notifications/`,
  `modules/osd/VolumeOsd.qml`, `modules/powermenu/`, `modules/shelf/`,
  `shell.qml`, and `Theme.qml`. The build adapts its progressive control-card,
  notification-stack, power-confirmation, and transient-OSD interaction grammar
  to native QuickShell services and the Aurora palette; it does not copy its
  shell wholesale. Its persistent shelf role maps to the current-workspace
  pinned/running/minimized application stack on the caelestia left rail, while
  the progressive cards map to independent top-bar panel expansions. This
  deliberately avoids a second dock without dropping any shelf function.
- `ilyamiro/nixos-configuration`: the shared motion tokens and top-bar panel
  coordination use the reference build's staged animation quality (`morph`,
  `selectionStretch`, cinematic staging — GRAND_PLAN.md §3.3), but retain the
  requested independent-panel model rather than its unified single-hub morph.
  *(Corrected — previously read "independent-surface dashboard model," which
  now misleadingly echoes "dashboard," a name reserved in this project for the
  retired Caelestia drawer UI. The panels being described here are the
  top-bar's independent expanding widgets, not that surface.)*
- `quickshell-mirror/quickshell` and `quickshell-examples`: validated the native
  notification, networking, BlueZ, PipeWire, UPower, power-profile, focus-grab,
  lazy-loader, and typed IPC contracts against the pinned QuickShell 0.3.0 API.
  Source inspection also established replacement-notification refresh behavior
  and freedesktop notification timeout units before those semantics were
  implemented locally.

Additional component-level sources are added here before their code is adapted.
```

---

## 8. Decision-level summary

- **Sources that changed role** (per the per-source table above): 9 — ilyamiro (top-bar
  structure owner, not just an EQ/animation donor), agridyne (added entirely, now primary lock
  visual owner — UNRESOLVED), DMS (DisplayConfig/lock-lifecycle role added, dock-primacy
  explicitly revoked), iNiR (role broadened well past "glass edge reference"), cxOrz (role
  narrowed — no longer "the" panel architecture), LinuxBeginnings (Waybar-specific description
  replaced with its actual ML4W gradient contribution), Matugen (demoted from primary generator
  to scoped internal tool), Hellwal (fallback target flipped from Matugen to the caelestia
  engine), awww/Waypaper (retired, kept as provenance rows).
- **Sources added that were missing entirely:** agridyne, Vast, skwd-wall, hyprland-plugins (as
  its own row, distinct from the already-correct patches table), Kurve, saatvik333, abusoww,
  mubin-thinks, nathanhoulamy, SherLock707, snes19xx (previously conflated with newmanls),
  elifouts/GlassesArch/Sharddots, ekremx25, angelobdev+AutoEq, Hellwal, Hyprlock, gowall,
  snappy-switcher, Harshil-Anuwadia — 19 rows.
- **Multi-source compositions preserved:** 12 — lock screen (the reference case), palette
  pipeline, left-rail app stack, top bar + expansions, clipboard history, the theming
  consumer/template fan-out (itself ~10 sub-compositions), motion vocabulary, file-manager
  theming, notifications, Alt+Tab cycler, desktop right-click menu, session menu, speaker/EQ
  chain, fastfetch art, and polkit dialog — full donor breakdown for each in §6.
- **UNRESOLVED, needing the operator or PM, not guessed at:** agridyne's lock-visual-composition
  claim (repo shows it as WIP with no finished asset — §3.1); Vast (load-bearing, web-only,
  unverified this session — §3.2); Hyprexpo (cited repo doesn't contain it in this checkout,
  already flagged elsewhere in the project but not resolved — §3.3); noctalia-dev/noctalia-shell
  (active row in `SOURCES.md`, absent from the revised plan, no explicit rejection found —
  §3.4); three repo-pin drifts where `repos/` HEAD has moved past the recorded pin (§4).
- **Concrete non-doc finding worth the PM's attention:** `keybinds.lua:16` currently binds
  `SUPER + K` to the retired dashboard drawer, a live consequence of the same stale attribution
  this task was asked to hunt down in documents (§5, item 8). Not fixed — flagged, per scope.

---

## 9. What I read vs. what I didn't

**Read in full:** `SESSION_PREAMBLE.md`; `GRAND_PLAN.md` (all 940 lines, not just §13/§2.1 as
strictly required — needed the whole document to know which body-text sections corroborate or
contradict the source map); `SOURCES.md` (78 lines); `EXECUTION_LOG.md` (all 1918 lines, plus
the header banner in detail); `MASTER_REQUIREMENTS.md` (350 lines); `STAGE2_CLOSEOUT_WORK_ORDER.md`
(246 lines); `ISSUE_LOG.md` (1061 lines, close read of the sections returned by targeted greps
plus the full "16a" retrospective and the closing findings #23–28); `agridyne-dotfiles-dt/
README.md` in full; `docs/wallpapers.md`, `docs/controls.md`, `docs/recovery.md` in full;
`codex-prompts/stage2b-keymap-osd-input.md` in full; the full `git diff` of `GRAND_PLAN.md`
against `HEAD` (1030 lines) to establish exactly what the 2026-07-29 revision changed versus
what was already true.

**Verified on disk (directory/file listings, not just grep):** every repo named in `GRAND_PLAN.md`
§13.1 and §13.2 that SESSION_PREAMBLE's table says should be cloned — `caelestia` (both the
shell-main and cli-main/hypr trees), `agridyne-dotfiles-dt`, `ilyamiro-nixos-configuration`,
`liixini-skwd-wall`, `dankmaterialshell`, `inir`, `hyprland-plugins`, `end4-dots-hyprland`,
`cxorz-dotfiles-hyprland`, `linuxbeginnings-hyprland-dots`, `saatvik333-hyprland-dotfiles`,
`abusoww-tuxmate`, `omarchy-desktop-shell`, `mubin-minimal-wm-config`,
`nathanhoulamy-macos-dotfiles`, `sherlock707-hyprland-dot-yadm`, `snes19xx-surface-dots`,
`elifouts-waybar`, `glassesarch`, `sharddots`, `newmanls-rofi-themes-collection`,
`frost-phoenix-nixos-config`, `iniox-matugen`, `iniox-matugen-themes`, `lgfae-awww`,
`anufrievroman-waypaper`, `harshil-wintux-grub-theme`. Pulled `git rev-parse HEAD` + commit date
for every one of them (§4/proposed table) rather than assuming the pins already in `SOURCES.md`
were still current.

**Spot-checked specific claimed paths, not just directory existence:** caelestia's
`modules/{dashboard,bar,windowinfo,lock,sidebar}`; ilyamiro's `TopBar.qml`, `Main.qml`,
`Lock.qml`, and the panel-popup set (`NetworkPopup`, `BatteryPopup`, `VolumePopup`,
`ClipboardManager`, `CalendarPopup`, `focustime/`); DMS's `DisplayService.qml`,
`Modules/Lock/*`, `Modules/Dock/*`; iNiR's `modules/polkit/`, `assets/systemd/inir.service`;
skwd-wall's `DaemonClient.qml` and `data/matugen/`; hyprland-plugins' README "Plugin list" and
`hyprpm.toml` (specifically to check for hyprexpo); saatvik333's fastfetch art filenames against
§7.2's exact claims (including the `satan-cross.txt`→`gothic-cross.txt` rename).

**Did not do:** re-clone or attempt to reach any web-only source (Vast, Kurve, ekremx25,
angelobdev/AutoEq, noctalia, Hellwal, gowall, snappy-switcher) — consistent with the task's "do
not run git write commands" constraint and with these already being correctly categorized as
web-only in `SESSION_PREAMBLE.md`. Did not open every file inside every verified repo (e.g., I
confirmed `modules/dashboard/` exists in caelestia and that its README/manifest describe it, but
did not read the dashboard QML itself — not relevant to an ownership/attribution reconciliation
task). Did not read `research/*.md` in full beyond `lock-screen.md`, `agridyne.md`, `SYNTHESIS.md`,
and `RESEARCH_SESSIONS.md` (targeted, via grep hits, not full reads) — these are explicitly
superseded-where-conflicting per `GRAND_PLAN.md`'s own header, so I treated them as lower
priority than the five documents the task named directly. Did not read `CURRENT_STATE_AUDIT.md`
or `PM_OPERATING_RULES.md` (referenced by `STAGE2_CLOSEOUT_WORK_ORDER.md` but not named in this
task's scope). Did not inspect `archive/superseded-handoffs/2026-07-28/` beyond the one grep hit
in `FABLE_PLAN_PROMPT.md` — it's explicitly archived/superseded, so further reading there was
judged low-value for this task. Made no changes to `modules/home/hyprland/hyprland/keybinds.lua`
despite finding a live stale-attribution consequence there — flagged only, per the hard
constraint against modifying anything under `~/nix`.
