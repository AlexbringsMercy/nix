# Lock-screen comparison — Hyprland 0.55 / QuickShell

**Research date:** 2026-07-21  
**Target:** 2020 T2 MacBook Air, dual-core i3, Iris Plus, 8 GB, one display  
**Decision:** **adapt Vast Shell's QuickShell lock, but do not enable it until the DMS-style recovery chain below is present and live-tested.** It has the highest source-proven and preview-verified choreography ceiling for §6. Hyprlock remains the fallback if that recovery test fails.

This is an open comparison under MASTER_REQUIREMENTS §6 and §15, not an inheritance of SYNTHESIS's former “Hyprlock, restyled” decision. §3 supplies the 700–1200 ms cinematic motion target. D6 supplies the contested Hyprlock ceiling claim.

## Evidence scale

- **A — source + visual:** I read the complete lock implementation and viewed the lock itself in a showcase or screenshot.
- **B — source strong, visual limited:** I read the complete relevant lock implementation, but the available showcase did not show that lock or showed only a related surface.
- **C — bounded audit:** I read the lock wrapper/core or project documentation, but did not perform the finalist-level full lock-source and visual audit.
- **Shipped** means present in that candidate's repository. **Required adaptation** means it is not a safeguard the candidate currently ships. **Live-test** means source makes the design plausible but cannot prove the end-to-end behavior on this MacBook.

## Candidate inventory

| Candidate | Type | Evidence | Why it remains in the comparison |
|---|---|---:|---|
| [Hyprlock v0.9.6](https://github.com/hyprwm/hyprlock/tree/v0.9.6) | native ext-session-lock client | **A** | Small, independent lock process and the safety baseline; current source settles D6. |
| [ilyamiro `Lock.qml`](https://github.com/ilyamiro/nixos-configuration/blob/d66c4a5915d2991d2e1cebe16f4c9b21f9fa0e6e/config/sessions/hyprland/scripts/quickshell/Lock.qml) | standalone QuickShell `WlSessionLock` | **B** | Closest original composition to §6: rings/vignette, huge clock, avatar/PIN, compact status. |
| [Caelestia lock](https://github.com/caelestia-dots/shell/tree/main/modules/lock) | integrated QuickShell `WlSessionLock` | **B** | Richest authentication set and a real gated card-collapse unlock animation. |
| [iNiR lock](https://github.com/snowarch/iNiR/tree/01434067705d9dfce10709dbe680474dacc35261/modules/lock) | integrated QuickShell `WlSessionLock` | **B** | Feature-rich Material lock with Wi-Fi/battery, media and Cava. |
| [DankMaterialShell lock](https://github.com/AvengeMedia/DankMaterialShell/tree/bf12665adb83bb52ebb30d44dc6b391c2deac191/quickshell/Modules/Lock) | integrated QuickShell `WlSessionLock` plus backend | **B** | Best audited recovery/authentication architecture; a strong safety donor, but not the top choreography. |
| [Vast Shell lock](https://github.com/myamusashi/vast-shell/tree/288493781669210aa45072d7d2b983e928dc1d91/Modules/Lock) | integrated QuickShell `WlSessionLock` | **A** | Standout r/unixporn build; preview-verified depth wallpaper and source-proven gated cinematic unlock. Best visual base. |
| [Ricelin lock](https://github.com/Gakuseei/Ricelin/tree/d4a37a875c55cad3e18172978531f143cd4a3fa8/configs/quickshell/lock) | QuickShell daemon + `WlSessionLock` | **B** | Strong 620 ms pill-to-fullscreen reveal and shader work, but its public showcase did not actually show the lock. |
| [Qylock](https://github.com/Darkkal44/qylock/tree/8ff5016773963958870e05c9aee3e3518c597b3f/quickshell-lockscreen) | SDDM themes wrapped as QuickShell `WlSessionLock` | **C** | Top r/unixporn theme collection and visually verified; exceptionally broad theme ceiling, weak lock lifecycle. |
| [swaylock-effects](https://github.com/mortie/swaylock-effects) | wlroots-compatible standalone lock | **C** | Useful non-QML baseline: blur, indicator and whole-surface fades, but not a credible §6 choreography finalist. |

No candidate was credited with a safeguard merely because Linux can recover through boot/root. That is the §15 recovery floor, not a substitute for a usable crash path.

## Hyprlock real ceiling

### Current-source finding

Hyprlock **v0.9.6**, released 2026-07-18, still has the D6-sized animation tree. [`ConfigManager.cpp`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/config/ConfigManager.cpp) creates:

```text
global
├── fade
│   ├── fadeIn
│   └── fadeOut
└── inputField
    ├── inputFieldColors
    ├── inputFieldFade
    ├── inputFieldWidth
    └── inputFieldDots
```

That is **nine nodes including the root, or eight configurable descendants**—the origin of the older “eight nodes” wording. There is no label, image, shape, position, scale, rotation or per-widget opacity animation node.

[`PasswordInputField.cpp`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/renderer/widgets/PasswordInputField.cpp) is the only widget implementation with its own animation variables: input-field alpha, current dot amount, width/size, and inner/outer gradient colors. Labels, images and shapes expose static position/size/rotation data and receive only the renderer's global opacity at draw time. Consequently:

- labels/images/shapes **cannot independently fade, move or scale**;
- the idle clock cannot transform into an avatar/PIN state;
- rings cannot enter in three independently timed stages or orbit;
- an avatar cannot appear on input activity;
- status pills cannot stage in/out;
- failure can change input-field color/text, but Hyprlock cannot reproduce ilyamiro's multi-step positional shake;
- a vignette can be a static image/shape composition, but not the animated depth object in ilyamiro or Vast.

The animation parser's fifth `style` field is explicitly marked **currently unused** and an empty style is sent to the animation tree. Speed and bezier work; a style such as `slide`, `popin` or a geometry style does not add that motion.

### Unlock correction

D6's geometry ceiling remains correct, but the older “Hyprlock has no unlock animation” statement is now false. [`Renderer.cpp`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/renderer/Renderer.cpp#L602) drives the global opacity to zero and releases the session lock only in the fade's end callback. Hyprlock v0.9.6 therefore has a **real gated whole-screen `fadeOut` on successful unlock**. It still has no per-widget exit choreography: clock, avatar, background and input all share that one opacity.

### Four dead options in the target's generated config

The previous overhaul's four-option finding also still holds against v0.9.6:

- `grace` is not a config key; it is the CLI option `--grace` in [`main.cpp`](https://github.com/hyprwm/hyprlock/blob/v0.9.6/src/main.cpp).
- `no_fade_in` is not a config key; the current CLI spelling is `--no-fade-in`.
- `no_fade_out` is neither a registered config key nor a current CLI option.
- `disable_loading_bar` is not registered.

Hyprlock ignores these faulty entries after reporting config errors. Separately, animation `style` is syntactically accepted but functionally unused. `inputFieldWidth` is a real animation, not a dead node, although the overhaul correctly observed that a wide fixed pill may never create a width delta for it to animate.

### Contested claim settled

**D6 wins on the contested translation claim.** SYNTHESIS's instruction to translate ilyamiro's 750 ms rings/orb and 400–600 ms clock-to-avatar choreography “through supported Hyprlock facilities” is not implementable in current Hyprlock. The honest translation is limited to:

1. one static composed scene (including a baked/static vignette),
2. a gated whole-screen fade-in/fade-out,
3. input placeholder-to-dots and input-field alpha/width/color transitions.

That is substantially below §3/§6's choreography target. Hyprlock's current screenshot, which I viewed, is visually clean—dark wallpaper, centered clock/greeting and password pill—but it demonstrates composition, not a path around the source ceiling.

## Per-candidate choreography ceiling and safeguards

QuickShell's own [`WlSessionLock` documentation](https://quickshell.org/docs/master/types/Quickshell.Wayland/WlSessionLock/) states the core failure semantics: destroying the object or exiting QuickShell without setting `locked = false` leaves a conforming compositor locked, showing a solid color. That is secure failure, but it is unusable until a replacement client is allowed to claim the lock. The tables below therefore distinguish a generic user-service restart from a restart that actually remembers it must relock.

| Candidate | Actual choreography ceiling from source | Successful-unlock timing |
|---|---|---|
| **Hyprlock 0.9.6** | Static widget composition; global fade; input alpha/dots/width/colors. No independent label/image/shape geometry or opacity. | **Gated:** global `fadeOut`, then release. No per-widget exit. |
| **ilyamiro** | Cached wallpaper with `MultiEffect` blur; dim layer; two 90-second orbiting translucent circles; four rings; 250/300/350 ms ring stages; orb/icon entry around 750 ms; 140 px clock; input activity drives clock opacity/scale/Y at 400/500/600 ms and stages avatar/PIN; per-character reveal-to-dot; 3×120 ms failure shake; status and power overlays. | **Immediate:** PAM success sets `rootLock.locked = false` and quits. No unlock choreography. |
| **Caelestia** | Full three-column Material dashboard/card: clock/avatar/input, weather, fetch/system metrics, battery, media, notifications. Entry expands a compact lock icon into the card; all QML properties can be staged. | **Gated and real:** success collapses the card/content to the lock icon through width/height/radius, scale and opacity animations; only the sequence's final action releases the lock. |
| **iNiR Material** | Blurred still/video/GIF wallpaper, dim/smoke, huge digital or analog clock, Wi-Fi/Bluetooth/audio/battery header, media+Cava, weather and notifications; 400/450 ms clock-to-login crossfade/scale and a staged 500 ms avatar/password panel; animated password shapes and failure shake. | **Probably not visible:** a 300 ms success overlay exists in `LockSurface.qml`, but `Lock.qml` drops `GlobalStates.screenLocked` on the same signal rather than waiting for it. Source does not show a gated exit. |
| **DMS** | Blurred/dim wallpaper, large clock/date, avatar/password, notifications, Cava/media, weather, Wi-Fi/Bluetooth/audio/battery, power menu and virtual keyboard. Broad state/UI ceiling, but the audited lock mainly uses local component transitions rather than a cinematic scene sequence. | **Immediate:** PAM raises `unlockRequested`; the root drops `shouldLock`. No gated scene exit found. |
| **Vast** | True two-plane depth wallpaper (background plus extracted foreground), independent opacity/scale/blur; entry reveals wallpaper, foreground, password and bottom island; typing zooms both depth planes to 1.12, increases blur to 30 and collapses the bottom bar; error shakes both password and lock icon with color feedback. | **Gated and cinematic:** success performs lock-icon shake/open/green state and pause, then collapses the bar, fades/scales wallpaper and foreground to 1.15, removes blur and fades password; the final `ScriptAction` releases the lock. |
| **Ricelin** | A top-bar pill-shaped aperture expands to a fullscreen lock over 620 ms; live screenshot, 8× downsample multipass shader blur/darkening, Cava shader glow, 130 px clock/date, media and ember-like PIN beads. QML permits further scene choreography. | **Gated:** reverse 620 ms collapse; a 640 ms timer releases after the transition. |
| **Qylock** | Dozens of theme-specific QML scenes: animated pixel rooms/cities, game-like menus and character scenes. Raw decorative ceiling is extremely high, but there is no single coherent lock composition or lifecycle shared by all themes. | Wrapper calls `loginctl unlock-session`, waits only 100 ms (500 ms for Clockwork), then drops `sessionLocked`; any theme exit beyond that is not generically gated. |
| **swaylock-effects** | Blur/pixelation, static indicator customization and whole-screen fades; no evidence of independent scene/widget state choreography comparable with QML. | Whole-surface fade class only; not audited as a finalist. |

### Safeguard matrix

| Candidate | PAM / fallback shipped | Crash watchdog shipped | Lock-state persistence and automatic re-acquire | Repo-specific VT escape | Does successful unlock require its process alive? |
|---|---|---|---|---|---|
| **Hyprlock** | Defaults to PAM module `hyprlock`; NixOS service must be declared. Native optional fingerprint path. | No unit in Hyprlock itself. | No persistent recovery chain shipped; can be supervised and restored by Hyprland 0.55 if configured. | None. | **Yes**, but it is a small dedicated process, not the desktop shell. |
| **ilyamiro** | `PamContext` default, therefore QuickShell's default `login` stack; no dedicated PAM file or alternate auth path. | None. `lock.sh` directly starts QuickShell. | None; the QML begins locked only on a fresh invocation, but no supervisor restarts it. | None. | **Yes.** |
| **Caelestia** | Strong: bundled password stack (`pam_faillock` + `pam_unix`) plus explicit fprint and Howdy configurations in `assets/pam.d/{passwd,fprint,howdy}`. | Home Manager unit: `Restart=on-failure`, `RestartSec=5s`. | **No relock state found.** A restarted shell normally starts with its QML lock false. Restart alone is insufficient. | None. | **Yes.** |
| **iNiR** | Default PAM/login plus a fingerprint configuration; 10 s auth timeout. | Nix/service units use `Restart=on-failure`, 5 s, with a 3-in-30-s start limit. | **No external lock intent found.** Its two-second loader fallback first releases the QuickShell lock and then tries swaylock/Hyprlock, creating an avoidable unlocked handoff window. | None. | **Yes.** |
| **DMS** | Best audited stack: selectable custom service, `/etc/pam.d/dankshell`, user-resolved service, then `login`; fingerprint and U2F; 15 s PAM-stall and 8 s unlock-request timeouts with retries. | [`assets/systemd/dms.service`](https://github.com/AvengeMedia/DankMaterialShell/blob/bf12665adb83bb52ebb30d44dc6b391c2deac191/assets/systemd/dms.service): `Restart=on-failure`, `RestartSec=1.23`. | **Credible shipped pattern:** `Lock.qml` sets logind's `LockedHint`, watches `SessionService`, and on startup/state change re-enters `shouldLock` if logind still says locked. Requires Hyprland's restore option externally. | None. | **Yes**, but the external logind state lets a restarted process know it must reclaim the lock. |
| **Vast** | Bundled `password.conf` with `pam_faillock`/`pam_unix`; no second modality. | Nix unit: `Restart=on-failure`, `RestartSec=5s`. | **None.** `WlSessionLock.locked` is set only by IPC, so a restarted shell does not know the old client died while locked. | None. A Reddit comment claimed global shortcuts could switch VT, but the repository contains no `chvt` path; not credited as shipped. | **Yes.** |
| **Ricelin** | Default `PamContext`/`login`. | None found in the full repository search. | None; daemon state is in-process. | None. | **Yes.** |
| **Qylock** | Default `PamContext`/`login`. | None. Its launcher kills competing locks with `killall -9` before starting QuickShell. | None. The community thread includes a real black-screen/forced-shutdown report, consistent with the missing lifecycle controls. | None. | **Yes.** |
| **swaylock-effects** | Conventional standalone swaylock PAM boundary. | Not audited here. | Not audited here. | Environment/compositor dependent. | **Yes**, in a dedicated process. |

Relevant source paths for the matrix:

- ilyamiro: `config/sessions/hyprland/scripts/quickshell/Lock.qml`, `scripts/lock.sh`, `hypridle.nix`.
- Caelestia: `modules/lock/{Lock,LockSurface,Content,Center,Pam}.qml`, `modules/lock/center/*`, `assets/pam.d/*`, `nix/hm-module.nix`.
- iNiR: `modules/lock/{Lock,LockSurface,LockContext,LockKeyboard,PasswordChars,LockMediaWidget}.qml`, `assets/systemd/inir.service`, `flake.nix`.
- DMS: `quickshell/Modules/Lock/{Lock,LockSurface,LockScreenContent,Pam}.qml`, `assets/systemd/dms.service`, `distro/nix/{nixos,home}.nix`.
- Vast: `Modules/Lock/{Lockscreen,Surface,Pam,Bar,BottomItem,Clock,MediaPlayer}.qml`, `Assets/pam.d/password.conf`, `nix/nixos-modules.nix`.
- Ricelin: `configs/quickshell/lock/{shell,Auth,Content,GlowField,GlyphIcon,LockSurface}.qml`, `scripts/lock.sh`.
- Qylock: `quickshell-lockscreen/lock_shell.qml`, `quickshell-lockscreen/lock.sh`, `quickshell-lockscreen/shim/SddmShim.qml`, `flake.nix`.

### The crash-restart point, resolved against Hyprland 0.55

Hyprland **0.55** already contains the missing compositor half. [`SessionLockManager.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.55.0/src/managers/SessionLockManager.cpp#L51-L58) denies a new lock while the compositor remains locked unless `misc:allow_session_lock_restore` is true. [`ConfigValues.cpp`](https://github.com/hyprwm/Hyprland/blob/v0.55.0/src/config/values/ConfigValues.cpp#L463) describes that option as allowing a crashed lockscreen app to restart; its default is false.

Therefore:

```text
process crash
    → compositor remains securely locked
    → systemd restarts the shell
    → shell reads persistent logind LockedHint = true
    → shell sets WlSessionLock.locked = true again
    → Hyprland allow_session_lock_restore accepts replacement client
    → password can unlock normally
```

Caelestia, iNiR and Vast ship only the second arrow. DMS ships the second through fourth arrows. Hyprland supplies the fifth when explicitly enabled. This is why “has `Restart=on-failure`” alone does not earn a safe rating, and why the QML-lock risk is manageable rather than disqualifying.

## Visual mapping to §6, from viewed previews and source

Legend: **●** present; **◐** partial/static or readily retained from the candidate; **○** absent in the audited implementation; **NV** lock itself was not visible in the showcase, so the mark is source-only.

| Candidate | Blurred wallpaper | Circular vignette | Large clock/date | Avatar + PIN | Battery + Wi-Fi pills | Cinematic depth | Unlock animation | Visual evidence |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| **Hyprlock** | ● | ◐ static/baked only | ● | ● static | ◐ command labels, static | ○ | ◐ global fade | Official README screenshot viewed. |
| **ilyamiro** | ● | ● orbit circles/rings | ● | ● | ◐ battery, no Wi-Fi in lock source | ◐ blur/orbits, not separated planes | ○ | **NV:** its 64 s showcase was viewed, but the lock did not appear. Source marks only. |
| **Caelestia** | ● | ○ | ● | ● | ◐ battery, no lock-local Wi-Fi pill found | ◐ blurred dashboard/card | ● card collapse | **NV:** its 49 s showcase was viewed, but the lock did not appear. Source marks only. |
| **iNiR** | ● | ○ | ● | ● | ● | ◐ blur/smoke | ○ effective | No public lock preview located; source marks only. |
| **DMS** | ● | ○ | ● | ● | ● | ◐ blur | ○ | DMS's `dgreet` image was viewed and confirms the shared clock/avatar/input aesthetic, but it is a greeter, **not** visual proof of lock motion. |
| **Vast** | ● | ○ | ● | ● typographic PIN + avatar island | ○ in lock | **● strongest:** separate foreground/background depth planes | **● strongest viewed/source-proven** | Lock itself viewed in the [r/unixporn showcase](https://www.reddit.com/r/unixporn/comments/1rwyzlx/): heavy blur/depth, huge centered 13:58/date and bottom avatar/media island. Source proves the full exit sequence; the video segment did not include the complete exit. |
| **Ricelin** | ● | ◐ expanding pill aperture, not circle | ● | ◐ PIN, no avatar | ○ | ◐ multipass blur/glow | ● gated collapse | **NV:** the full [r/unixporn showcase](https://www.reddit.com/r/unixporn/comments/1u7qo25/) was viewed, but it did not show the lock. Source marks only. |
| **Qylock** | theme-dependent | theme-dependent | ● in most | theme-dependent | ○ as a common design | ● decorative animated scenes | ◐ wrapper-limited | Full three-minute [22-theme showcase](https://www.reddit.com/r/unixporn/comments/1sgoe4s/sddm_qylock_all_22_themes_showcase_updated/) viewed. |
| **swaylock-effects** | ● | ○ | ○ custom scene | ○ | ○ | ○ | ◐ whole surface | Not visually ranked as a finalist. |

### What the previews actually rank

It would be dishonest to assign a pixel-quality rank to locks that their showcases never displayed. Among locks I actually saw:

1. **Vast — best match and best choreography evidence.** The depth-separated foreground is the only viewed candidate that materially reads as §6 cinematic depth-of-field rather than “wallpaper with blur.” The source-backed exit is also the most authored sequence.
2. **Qylock — highest decorative variety, weaker target match.** The viewed themes are polished animated pixel/game scenes, but they are a theme gallery rather than the requested calm blurred-wallpaper composition. Their wrapper lifecycle is the weakest serious candidate.
3. **Hyprlock — cleanest conservative baseline.** The viewed official screenshot is coherent and legible, but flat and static compared with Vast. It does not visually imply the missing geometry animation capabilities.

DMS's greeter image looks polished but was excluded because it is not the lock. Ilyamiro, Caelestia and Ricelin are **source-ranked**, not preview-ranked: their public videos did not show the lock despite being watched end-to-end.

### Source-backed choreography rank

Where source is allowed to establish behavior that the public video omitted:

1. **Vast** — entry, focus-depth transition, error choreography and a gated multi-beat exit; closest §3/§6 match.
2. **Caelestia / Ricelin** — both have genuine gated geometry-based exits; Caelestia is feature-dense, Ricelin is visually more cinematic but less target-complete.
3. **ilyamiro** — best circular-vignette and clock-to-avatar sequence, but no unlock animation.
4. **iNiR** — richest target status/media composition, but its success overlay is not gated before session-lock release.
5. **DMS** — richest mature lock product and safety state machine; less scene-authored motion.
6. **Qylock** — potentially spectacular per-theme animation, but the generic lock wrapper truncates/does not coordinate exit choreography.
7. **Hyprlock** — dependable global fade and input micro-animation only.
8. **swaylock-effects** — useful low-complexity baseline, below the requested scene ceiling.

## Recommendation

### Choose Vast's lock choreography on a DMS-style recovery substrate

The highest ceiling that can be made safe is **Vast's QuickShell lock**, adapted rather than recreated. Use its existing `Modules/Lock/Surface.qml` depth planes, focus transition, error motion and gated exit. Retain ilyamiro's existing orbit/ring treatment as the small visual donor for §6's circular vignette, and retain iNiR/DMS's existing compact battery/Wi-Fi presentation. This is community-source adaptation; it does not require inventing a lock from scratch.

> **Operator annotation — agreed direction (2026-07-21).** The intended result should look predominantly like an enhanced ilyamiro lock, not like Vast's current layout. Treat the sources as complementary layers: **ilyamiro supplies the visual identity and composition; Vast supplies the cinematic depth/motion engine; DMS supplies the safety lifecycle; iNiR/DMS supply the missing status components.** Concretely, preserve ilyamiro's circular rings/vignette, huge clock/date, avatar-to-PIN transformation and restrained pills; replace its simulated depth with Vast's separated wallpaper/foreground planes; add Vast's authentication-focus zoom, lock-icon/error response and gated multi-stage unlock; add the missing Wi-Fi pill beside battery; and place DMS's PAM timeouts, lock-ready handshake, persistent lock intent and crash re-acquisition underneath it all. Hyprlock remains the emergency fallback. The operator reviewed this decomposition and explicitly concurred with it.

```text
ilyamiro appearance
+ Vast cinematic depth and unlock
+ iNiR/DMS status components
+ DMS safety lifecycle
= target lock
```

The recommendation is conditional because **upstream Vast is not safe enough as shipped**. Its current restart unit has no persistent lock intent, so a shell restart does not automatically request a replacement `WlSessionLock`. The option becomes acceptable only with every safeguard below.

### Required PAM boundary

Use a dedicated NixOS PAM service rather than Vast's repository-local `password.conf`:

```nix
security.pam.services.vast-lock = {};
```

Point the adapted `PamContext` to `config: "vast-lock"` under `/etc/pam.d`. Password through the normal NixOS PAM stack is the mandatory fallback and must remain available even if any future biometric method is added. On this T2 MacBook, password—not Touch ID—is the acceptance path.

### Required safeguards before first enable

1. **Compositor restoration:** set Hyprland 0.55's `misc:allow_session_lock_restore = true`. This is the source-defined permission for a replacement lock client after a crash.
2. **Out-of-process lock intent:** before requesting `WlSessionLock`, set logind's session `LockedHint`; clear it only after PAM success **and after** Vast's gated exit has reached its final release action. On QuickShell startup, query logind; if still locked, immediately request `WlSessionLock` again. DMS `Modules/Lock/Lock.qml` is the concrete donor implementation.
3. **Watchdog:** run the shell as a graphical-session user service with automatic restart. Vast ships `Restart=on-failure`, 5 s; for this adaptation the service must also cover unexpected clean exits (use the equivalent of `Restart=always`, while normal stop remains a systemd stop) and must use the session's imported `WAYLAND_DISPLAY`/runtime environment rather than Vast's hard-coded `wayland-1`.
4. **Secure lock-ready handshake:** suspend/DPMS-off must happen only after the replacement lock has received the locked/ready state and its one display surface has committed. DMS's lock-ready/loginctl coordination is the donor; do not use an arbitrary sleep.
5. **Authentication failure containment:** preserve password entry after failure and add DMS's bounded PAM and unlock-request timeouts/retry behavior. Never release `WlSessionLock` on timeout, loader failure or missing theme resources. In particular, do **not** copy iNiR's “release, then try Hyprlock/swaylock” fallback.
6. **TTY recovery:** keep a root-login-capable text VT and verify the MacBook's actual hardware chord for switching to it (normally Ctrl+Alt+Fn+F3 on the Apple keyboard) while the lock is active and while the QuickShell process is killed. None of the shortlisted QML repositories ships a repo-level `chvt` escape. A Hyprland `bindl` is permitted while an input inhibitor is active, but a command-based `chvt` path is not credited until its permissions and T2 key mapping are live-tested. Boot recovery plus the root password remains the final §15 floor.
7. **Single owner:** only one lock implementation may answer the lock event. Hypridle/loginctl must target the adapted Vast lock; Hyprlock remains an installed emergency fallback, not a concurrently launched client.
8. **Resource ceiling:** on the Iris Plus, use Vast's still wallpaper plus one precomputed foreground depth layer. Do not carry Qylock's animated scenes, iNiR's video/GIF background or lock-screen Cava into the first acceptance build. The §3 acceptance criterion is smooth 700–1200 ms motion with no lock hitch, not maximum simultaneous effects.

### Mandatory live acceptance test

This research did not execute it. Before making the QML lock the idle/suspend owner, the implementation session must verify all of the following on the laptop:

- correct password, incorrect password, empty input and a stalled PAM conversation;
- kill the QuickShell process while locked: the display must stay locked, the service must restart, logind state must cause re-acquisition, and the password must then unlock;
- repeat the crash during the entry animation, during password authentication and during the gated exit;
- suspend/resume, lid close/open and DPMS-off/on only after lock-ready;
- failed wallpaper/avatar/status resource loads still produce a usable password surface;
- VT switch and root login work with the T2 keyboard while the graphical session remains locked;
- reboot recovery remains available;
- motion stays smooth on the single Iris Plus display and memory use remains reasonable.

If the crash/re-acquire test fails even once, **do not ship the QML lock**. Use Hyprlock with:

```nix
security.pam.services.hyprlock = {};
```

and accept the lower D6 ceiling: static composition plus global gated fade and input-field micro-animation. That is the safety fallback, not the visual recommendation.

### Why not choose another finalist?

- **Caelestia** has the second-best complete auth/exit package, but its dashboard-card composition fights §6's quiet vignette and depth-wallpaper target. It also lacks DMS's persisted relock state.
- **DMS** is the safest QML substrate and should donate the lifecycle. Its current lock lacks the authored entry/exit depth sequence that makes Vast the better visual choice.
- **ilyamiro** best supplies rings and clock-to-avatar timing, but immediate unlock and no supervisor make it an animation donor, not the base.
- **iNiR** supplies the closest battery/Wi-Fi/media arrangement, but the apparent ungated exit and unlocked fallback handoff are regressions.
- **Ricelin** has excellent source choreography, but no watchdog, no persisted state, no avatar/status set, and no lock footage in the viewed showcase.
- **Qylock** proves QML's artistic ceiling but is not an acceptable lifecycle base; the wrapper kills competing locks, has no watchdog/relock state, and does not coordinate most theme exits.
- **Hyprlock** wins simplicity and process isolation but cannot meet the reopened §15 objective of choosing the highest safe choreography ceiling.

## Bonus finds

- **Bonus — Hyprland already has the crucial restoration primitive.** `misc:allow_session_lock_restore` is present in the exact 0.55 target, not merely a future/main-branch idea.
- **Bonus — DMS is a reusable safety reference.** Its logind `LockedHint`, startup reconciliation, PAM fallbacks, auth timeouts, lock-ready handshake and fast user-service restart collectively answer the “top builds must have safeguards” question better than any other audited QML shell.
- **Bonus — Hyprlock's ceiling changed in one narrow but useful way.** The geometry limit did not improve, but current source proves a gated global unlock fade. Future planning should amend the old “no unlock animation” statement without reopening the impossible ilyamiro translation.
- **Warning surfaced — iNiR's fallback order is unsafe.** Releasing its session lock before confirming a replacement lock owns the compositor creates an unlocked interval. A fallback must acquire/restore under compositor control, never drop first and hope the next process starts.

## What I actually read/viewed vs what I didn't

### Read in full or as a complete bounded lock implementation

- `SESSION_PREAMBLE.md` and `MASTER_REQUIREMENTS.md` in full; `SYNTHESIS.md` in full, including its reopened lock recommendation and motion row.
- The D6 source statement in `GAP_REVIEW.md` and the relevant lock-session brief in `RESEARCH_SESSIONS.md`.
- ilyamiro `Lock.qml` (all 1,252 lines), `lock.sh`, and `hypridle.nix`.
- Caelestia's complete `modules/lock` QML set, all center/weather components, PAM assets, shell integration and Home Manager service definition.
- iNiR's Material lock root/context/keyboard/password/media files, the complete main `LockSurface.qml`, fingerprint/service/fallback paths and Nix/systemd definitions.
- DMS `Lock.qml`, `LockSurface.qml`, `Pam.qml`, the complete large `LockScreenContent.qml`, lock-ready/loginctl integration, PAM assets, service and Nix definitions.
- Vast's complete `Modules/Lock` QML set, PAM asset and Nix service module.
- Ricelin's complete `configs/quickshell/lock` QML set and launcher.
- Qylock's complete QuickShell session-lock wrapper, SDDM shim, launcher and Nix wrapper; theme structure/searches across the repository.
- Hyprlock v0.9.6's complete animation registration/parser, widget animation creation, renderer fade/release path, relevant widget renderers, PAM defaults, CLI options and full repository path inventory. I did not line-read unrelated build/helper code because it cannot change the animation/widget ceiling established at registration and construction sites.
- Hyprland v0.55's session-lock manager and config-value definition for restoration, plus current QuickShell `WlSessionLock`/PAM behavior documentation.

I used the previous `ilyamiro.md`, `caelestia.md` and `iNiR.md` reports for orientation and cross-checking their lock sections; I did **not** reread every unrelated line of those three prose reports.

### Viewed

- Hyprlock's official current README lock screenshot at original resolution.
- Vast's r/unixporn video, including the actual lock entry/locked state; extracted overview and fine frames. The video did not show the entire source-defined unlock sequence.
- Qylock's full three-minute all-theme showcase and extracted contact sheet.
- Ilyamiro's full 64 s shell showcase and Caelestia's full 49 s shell showcase. Neither showed its lock, so neither received preview-based lock marks.
- Ricelin's full showcase/contact sheets. The lock did not appear, so its motion claims are source-only.
- DMS's `dgreet` image. It is explicitly treated as a related aesthetic reference, not a lock preview.

### Not viewed / not fully audited

- No public iNiR lock video was located.
- No direct Caelestia, ilyamiro or Ricelin lock footage was found in the viewed showcases.
- I did not line-read iNiR's alternate Waffle lock variants; the recommendation concerns its main Material lock.
- I did not line-read all of Qylock's tens of thousands of per-theme QML lines; I fully audited the security-critical QuickShell wrapper and visually inspected all themes in the showcase. Theme-specific claims are deliberately bounded.
- swaylock-effects was retained only as a conventional low-choreography baseline; it did not receive a finalist-level full-source or visual audit.
- I did not run, build, configure, authenticate with, crash, suspend or benchmark any lock on this machine. Every end-to-end safety/performance assertion is correctly marked for live testing.
