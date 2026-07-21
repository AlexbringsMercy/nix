# Wallpaper pipeline — targeted verification

Research snapshot: 2026-07-21. This closes the remaining wallpaper questions in `MASTER_REQUIREMENTS.md` §5/§6, the A4 post-review verification, and C10. It does not reopen the picker decision: **liixini/skwd-wall V1 is final and remains as-is except for the documented compatibility seam.**

## Bottom line

1. **A4 transition verdict: yes.** I watched the complete 2:05 preview linked by skwd-wall’s README, plus every linked screenshot. Picker-triggered wallpaper changes visibly animate across the whole desktop behind the still-open picker. They are not instantaneous swaps. I saw repeated diagonal/geometric wipes and blended shader-like changes. This is a viewed result, not an inference from settings or source names.
2. **Where the transition actually comes from matters.** In the full upstream application, the default Rust companion renderer, `skwd-paper`, performs those transitions. `SliceDelegate.qml` does not contain the renderer. Therefore awww is redundant for picker clicks only when the skwd daemon/`skwd-paper` path is retained.
3. **For the selected compatibility architecture, awww remains necessary.** The accepted one-line adaptation vendors the QML delegate without the Rust daemon. That removes the backend that implements the native transition. The delegate emits the selected wallpaper to the existing atomic apply authority, and awww supplies the transition for picker and scheduled changes.
4. **The exact one-line compatibility change is real but narrowly scoped:** delete `DaemonClient.preheat(delegateItem.model.path)` at `qml/wallpaper/SliceDelegate.qml:35`. This removes the delegate’s only direct `DaemonClient` call. It does not make the complete standalone skwd-wall application daemon-free; the host still has to provide the delegate’s model and generic `service`/`applyRequest` interface.
5. **Generator chain:** Matugen only after the installed-version behavior is verified at execution time; otherwise Hellwal. Gowall is an optional inverse mode before either generator: recolor a derived wallpaper toward a selected palette, then generate the desktop accents from that derived image.
6. **C10:** one user timer invokes one one-shot selection policy; the policy selects from the curated collection and calls the same atomic apply entry point used by the picker. It never calls awww or a palette generator directly.

This preserves §5’s requirement to replace the janky picker, §6’s skwd-wall/compat and no-half-state requirements, §15’s final picker decision, A4’s transition verification, and C10’s “one timer + policy” constraint.

## 1. Transitions verdict — from viewed previews

### What the preview shows

The README links six screenshots and one 125.2-second, 1920×1080/60 fps preview. I viewed all six screenshots and reviewed the entire video, including denser frame sequences around each visible wallpaper change. During several picker selections:

- the skwd-wall picker stays visible;
- the desktop wallpaper behind it changes over time rather than in one frame;
- the change travels through the background as diagonal/geometric wipes and blended effects;
- the effect is a wallpaper-renderer transition, distinct from the carousel’s own slice movement.

**Verdict: skwd-wall does perform wallpaper transitions in the demonstrated full application.** This closes the visual half of A4.

The source independently explains what was seen:

- `qml/Config.qml:110-113` selects either `skwd-paper` (default) or `awww` as the static wallpaper engine.
- `qml/Config.qml:153-159` enables the native transition by default, selects `random` by default, and defaults to 600 ms.
- `qml/wallpaper/settings/PaperSettings.qml:14-54` exposes 38 concrete native shaders plus the `random` selector; examples include directional wipe, fade, glitch, ink, mosaic, ripple, smoke, and warp effects.
- `skwd-daemon/crates/daemon/src/wall/apply.rs:218-249` creates a transition overlay from the prior and next image, shader, duration, and thumbnails.
- `apply.rs:251-263` installs the steady `skwd-paper-still` image while the bottom-layer transition runs.
- `skwd-daemon/crates/paper/src/transition_paper.rs` is the layer-shell/OpenGL transition renderer.

The important boundary is therefore:

| Integration | What covers a picker click? | Is awww redundant there? |
|---|---|---|
| Full skwd-wall, default `skwd-paper` backend retained | skwd daemon + `skwd-paper` native shader transition | **Yes** |
| Full skwd-wall configured to its `awww` engine | skwd daemon asks awww to render the transition | **No; awww is the selected engine** |
| Vendored `SliceDelegate.qml`, Rust daemon removed, selection routed to the existing apply authority | The delegate only supplies the selection UX; awww renders the actual transition | **No; this is the selected build architecture** |

### Exactly what awww would still cover

If the full `skwd-paper` path were kept, it covers static-wallpaper changes sent through the skwd daemon, including clicks from its picker and its own built-in random-rotation feature. awww would then only be useful for a change made **outside** that backend—for example, an external auto-cycle/CLI path whose atomic apply owner invokes awww—or as the deliberately selected alternative renderer. awww does not schedule wallpaper changes itself; it animates changes requested by a caller.

In the accepted daemon-free delegate adaptation, this conditional distinction disappears: the picker, timer, and any other non-picker caller all converge on the existing atomic apply command, and that command uses awww as the single transition renderer.

## 2. `SliceDelegate.qml` compatibility seam

Exact upstream file:

`liixini/skwd-wall/qml/wallpaper/SliceDelegate.qml`

Exact current block at lines 29-37:

```qml
Timer {
    id: _preheatTimer
    interval: 120
    repeat: false
    onTriggered: {
        if (delegateItem.model && delegateItem.model.path)
            DaemonClient.preheat(delegateItem.model.path)
    }
}
```

Exact functional change:

```diff
-                DaemonClient.preheat(delegateItem.model.path)
```

Deleting that line makes the timer inert; removing the now-inert timer afterward is optional cleanup, not part of the claimed one-line compatibility change. The `import "../services"` may also become removable only if the host’s other vendored dependencies no longer need that import; it is not required for the functional seam.

Why the claim is valid, and its limit:

- `DaemonClient.preheat(...)` is the delegate’s only direct reference to the Rust-daemon singleton.
- The delegate already has an abstract `property var service` and `property var applyRequest` (`SliceDelegate.qml:19-20`).
- Its click handler at lines 846-861 first invokes `applyRequest(model, forcePicker)` when supplied; otherwise it calls the generic service’s `applyStatic`, `applyVideo`, or `applyWE` method.
- The host can therefore retain the visual/interaction component and route a static selection to the already-decided atomic apply authority with small glue.

**Do not inflate this into “the entire skwd-wall app is daemon-free after one line.”** Other full-app services still use `DaemonClient` for wallpaper inventory, cache/preheat, metadata operations, apply, and random rotation. The proven claim is specifically that the vendored `SliceDelegate` loses its only direct daemon call while preserving its generic application seam.

This also explains the A4 result: removing the delegate’s daemon connection does not transplant `skwd-paper`. Native transitions belong to the backend, so the compatibility build still needs awww.

## 3. awww relationship and coexistence

### What awww is

[awww](https://codeberg.org/LGFae/awww) is a persistent Wayland layer-shell wallpaper daemon plus a runtime client. It displays static images and animated GIFs, targets individual outputs, and transitions between images without restarting the renderer. Its documented transition controls include none/simple/fade; directional and wipe/wave effects; grow/center/outer/any/random; duration, FPS, step, angle, position, Bézier curve, wave geometry, resize/filter, and per-output selection. It is a renderer, not a palette generator or scheduler.

iNiR’s `services/AwwwBackend.qml` is a useful community adaptation: it maps shell transition names to awww’s native types, debounces duplicate applies, queues a changed request instead of killing a transition in progress, targets monitors, probes/reuses an existing daemon, and only starts one if absent. Those are the reusable behaviors; the target’s existing atomic command remains the state authority.

### The daemon conflict, precisely

The inherited warning is real but the current upstream behavior is narrower than “skwd-wall always kills awww.” Current `skwd-daemon` main does this in `crates/daemon/src/wall/apply.rs:101-106`:

```rust
let prev_engine = swap_last_engine(config.paper.engine).await;
if prev_engine == Some(config::PaperEngine::Awww)
    && config.paper.engine != config::PaperEngine::Awww
{
    kill_awww_if_running().await;
}
```

`crates/daemon/src/wall/apply/awww.rs:33-37` implements the stop as:

```rust
awww kill >/dev/null 2>&1; pkill -x awww-daemon 2>/dev/null; true
```

Thus current skwd-daemon kills awww when its own last engine was awww and it changes to a non-awww engine. When `paper.engine` stays pinned to `awww`, `apply_awww()` first runs `awww query`, reuses the running daemon when found, and spawns one only when absent (`apply/awww.rs:40-48`).

Why the service can remain dead: the checked-in awww user unit has `Restart=on-failure`. An intentional `awww kill` is a clean shutdown, so this policy does not treat it as a failure requiring restart.

### Minimal compatibility choices

For the selected architecture, the smallest and cleanest coexistence fix is architectural: **do not run skwd-daemon.** Vendor the delegate, remove its line-35 preheat call, route its `applyRequest` to the existing transaction, and let that transaction own the one awww daemon. There is then no second daemon with authority to kill it.

If the complete skwd-wall daemon is retained instead, there are two minimal options:

1. Pin `paper.engine = "awww"` and do not switch it at runtime. Current upstream then reuses the systemd-owned daemon and never enters the guarded kill branch.
2. If runtime engine switching must remain possible, delete the single call at `skwd-daemon/crates/daemon/src/wall/apply.rs:105`:

   ```diff
   -        kill_awww_if_running().await;
   +        // awww is externally owned; do not stop it here.
   ```

   Removing the now-empty conditional and unused helper is optional cleanup. The behavioral compatibility patch is the removal of that call.

Coexisting processes are not the same as coherent renderer ownership. `skwd-paper` and awww can both hold layer-shell wallpaper surfaces, leaving visual ordering ambiguous. Use one visible static-wallpaper renderer at a time: full skwd-wall pinned to awww, full skwd-wall using native `skwd-paper` with awww not acting on that output, or the selected daemon-free delegate with awww as sole renderer. The third arrangement is the one consistent with §6’s compatibility-only picker adaptation and single atomic authority.

## 4. Generators and fallback chain

### Matugen → Hellwal fallback

The decision remains exactly the one in §6 and `SYNTHESIS.md`:

```text
installed Matugen passes the execution-time generated-contract test
    → use Matugen
otherwise
    → use Hellwal
```

This research session did **not** run or verify the installed Matugen. The known `custom_colors` silent-discard behavior must be checked against the installed version during execution, using the actual target contract. Successful process exit is not sufficient: required keys and values must be validated in the staged output. If that check does not pass, Hellwal is the accepted fallback rather than an invitation to create a new generator.

### Hellwal’s relevant capabilities

[Hellwal](https://github.com/danihek/hellwal) is a small image/theme-to-16-color palette generator:

- Its current implementation derives the palette using median-cut partitions plus dominant histogram bins, then blends those results (`hellwal.c:1424-1479`).
- Dark mode is default; it also supports light and colorized modes, brightness/darkness offsets, inversion, grayscale, and optional neon treatment.
- `--check-contrast` adjusts foreground/palette colors toward a 4.5:1 WCAG-style text contrast threshold.
- Static background and foreground overrides are supported, useful for keeping the fixed deep-dark surface ladder while allowing accents to follow the wallpaper.
- `--json` writes the wallpaper path, background, foreground, and colors 0-15 to stdout and skips template processing. This is the cleanest adapter input for the existing generated contract.
- Its template engine exposes hex, RGB, individual channels, wallpaper/background/foreground, and alpha. The repository ships examples for Kitty, GTK, Qt, Hyprland, Fuzzel, Waybar, and others.
- It can cache palettes, disable the cache, choose an image randomly from a folder, and run a success hook.

For this build, use Hellwal only as a generator inside the existing transaction. Prefer JSON into the staging area (or point template output at a staging directory), pass `--skip-term-colors` to prevent immediate terminal escape-code side effects, validate all 16 colors and the mapped semantic contract, then atomically publish. Do not use Hellwal’s direct final-path template writes or `--script` hook as a second apply/reload authority: `template_write()` opens final paths with `fopen(path, "w")`, so it is not atomic by itself.

### Gowall’s inverse role

[Gowall](https://github.com/Achno/gowall) started specifically as a wallpaper recoloring tool. Its relevant command is `gowall convert INPUT --theme THEME`:

- It can recolor an image toward one of its built-in palettes, a custom theme from `~/.config/gowall/config.yml`, or a runtime JSON theme.
- The primary conversion path builds/caches a palette-derived Hald CLUT and applies it to the image (`internal/image/convert.go:24-87`). A configurable nearest-neighbor backend instead replaces each pixel with the nearest target-palette color (`convert.go:90-134`).
- It supports explicit output paths, directory/batch input, and PNG/WebP/JPEG-family output.
- `gowall extract` separately extracts dominant colors, but that does not make Gowall the chosen forward desktop generator; Hellwal is the accepted fallback for that job.

I viewed the repository’s original-versus-Catppuccin, Everforest, and custom-theme examples. They show the intended inverse behavior: composition and recognizability remain, while the wallpaper is driven toward the supplied palette.

The correct optional branch is:

```text
curated original wallpaper
  → Gowall + selected fixed/user palette
  → staged derived wallpaper (never overwrite the original)
  → Matugen-if-verified, otherwise Hellwal, analyzes the derived image
  → validate the generated contract
  → atomic commit displays the derived image and publishes its matching accents
```

Gowall is therefore **upstream of** the palette generator, not a fallback beside it. For unattended use, disable its image-preview behavior and give it an explicit staging destination; iNiR’s `GowallService` also encountered viewer spawning and used a no-op viewer shim, which is a useful warning for headless/one-shot integration.

## 5. C10 auto-cycling: one timer + one policy

Two community implementations supply the pattern, but neither should be copied as the final authority:

- awww’s `example_scripts/awww_randomize.sh` shuffles a directory and loops over `awww img`; `awww_init_according_to_time_of_day.sh` selects by hour band.
- skwd-wall already exposes one-shot/continuous random selection, a configurable interval, media-type filters, favorites-only mode, and per-monitor application (`README.md:58-59`, `qml/wallpaper/FilterBar.qml:151-172`).

Adapt the useful policy ideas, not their direct apply mechanics. C10’s safe pattern is:

```text
one systemd user timer
  → one short-lived selection policy
      → choose one eligible curated wallpaper
      → invoke the existing atomic apply entry point exactly once
          → optional Gowall derivation in staging
          → Matugen-if-verified, else Hellwal, in staging
          → validate the complete generated contract
          → commit coherent wallpaper/palette/current-state artifacts
          → renderer transition + one reload/fan-out wave
```

### Selection policy

- **Cadence:** select either a daily calendar trigger or an interval trigger in the same timer definition; do not run a permanent shell loop. Optional timer jitter avoids every login producing an immediate predictable swap.
- **Pool:** enumerate only the curated collection and supported static formats. Exclude the current wallpaper. Keeping a small recent-history list prevents immediate repeats without introducing another service.
- **Evening variant:** use the same day/evening state that drives night light. During the evening window, prefer candidates tagged `dark` (or placed in a curated `dark/` subset). “Prefer” is deliberate: if the dark subset is empty, fall back to the full curated pool rather than fail the timer.
- **One authority:** after choosing the path, call the existing atomic `apply-wallpaper` entry point once. The timer/policy must not call `awww img`, skwd-daemon random rotation, Matugen, Hellwal, Gowall, app reloads, or QuickShell state writes independently.
- **Overlap:** the existing apply lock serializes manual and scheduled requests. If an apply is already in progress, coalesce/skip the timer event rather than allowing two generation and reload waves to race.
- **Failure:** retain the prior wallpaper and generated contract unless staging and validation both succeed. Update current/recent state only with the successful commit.
- **Renderer:** in the selected daemon-free picker architecture, the atomic entry point uses awww for both manual and scheduled transitions. If full native `skwd-paper` were chosen instead, the same rule applies: the timer still calls the atomic authority, and that authority must be the only path into the renderer.

This is “safe by construction” only because picker, CLI, and timer converge on the same staged transaction. Calling awww directly from the timer would change the image before palette/application state and recreate the half-applied condition §6 explicitly forbids.

## Bonus finds

- **skwd-wall has far more than a crossfade.** The current native settings expose 38 concrete shader transitions plus random selection. This strengthens the visual verdict, but those shaders belong to the Rust `skwd-paper` backend and are not carried by the vendored QML delegate.
- **skwd-wall already has continuous shuffle UX.** Its configurable interval, favorites-only restriction, media filters, and per-monitor modifier are good interaction references. Its daemon-owned rotation must not become a parallel state authority in the selected atomic architecture.
- **Current daemon conflict is guarded.** Current `skwd-daemon` does not unconditionally kill awww on every apply. Pinning its engine to awww already cooperates with a running daemon; the destructive path is specifically an awww→non-awww engine switch.
- **awww namespaces do not solve dual ownership.** They can isolate IPC instances, but two wallpaper surfaces still compete visually. A single visible renderer remains the sound rule.
- **Hellwal has useful fixed-surface controls.** Static background/foreground plus contrast checking can help preserve the master requirement’s fixed dark surfaces while wallpaper-derived accents vary.
- **Gowall has a relevant preview-side-effect gotcha.** Give it explicit staged output and suppress preview/viewer launching in unattended applies.
- **iNiR’s generated-contract behavior is the right defensive donor.** `switchwall.sh` writes temporary JSON/SCSS/palette/terminal/meta artifacts and moves successful nonempty files into place; `MaterialThemeLoader.qml` validates nonempty parseable JSON with a required background role, debounces updates, and triggers one delayed external fan-out. The target still needs a transaction boundary across the complete artifact set, because a series of individually atomic renames is not globally all-or-nothing.

## Source anchors

Repository snapshots inspected:

- `liixini/skwd-wall` V1 at `74be65663538ee6175ecc73f896a9d6229d4b612`
- `liixini/skwd-daemon` main at `36f165a68611dfc55f1878ddd34491cdb6e22a44`
- `LGFae/awww` at `25ea4fd7a42359379da9ddadedda1c477caa4ae0`
- `Achno/gowall` main at `96345aaaa5c8be88b62e7649a7815ada359a5caf`
- `danihek/hellwal` main at `c485eb6bb75fc2ccd3c3e9a59f23a980a996e912`

Primary upstream documents/source used:

- skwd-wall: `README.md`, every README-linked preview asset, `qml/Config.qml`, `qml/services/DaemonClient.qml`, `qml/services/WallpaperSelectorService.qml`, `qml/wallpaper/SliceDelegate.qml`, `WallpaperSelector.qml`, `FilterBar.qml`, and wallpaper settings/views/components; skwd-daemon’s config, apply/awww/paper paths, and transition renderer.
- awww: `README.md`, the client/daemon/kill/img manuals, systemd unit, and all example scripts.
- Gowall: `README.md`, all checked-in and linked README media, command/global-output handling, theme loading, conversion/CLUT/nearest-color, extraction, inversion, image I/O, configuration, and related tests/docs.
- Hellwal: `README.md`, preview media, `hellwal.c`, `hell_colors.h`, `hell_parser.h`, shipped themes/templates/completions/example hook, and build metadata; the vendored image decoder was identified but is not material to the palette contract.
- Local research: `MASTER_REQUIREMENTS.md` §5, §6, §15; `GAP_REVIEW.md` A4, its post-review resolution, and C10; `SYNTHESIS.md` “Wallpaper picker, transitions, and apply pipeline”; `iNiR.md` wallpaper/theming contract sections; and the actual iNiR `AwwwBackend.qml`, `switchwall.sh`, generator, loader, and wallpaper docs.

## What I actually read/viewed vs what I didn’t

**Read/viewed:** I read `SESSION_PREAMBLE.md` in full before research; read the required master/gap/synthesis/iNiR sections; enumerated the complete relevant repository trees; read skwd-wall’s full README and its wallpaper/config/service/component source relevant to selection, application, random rotation, and transitions; read the companion daemon’s apply and renderer paths; read awww’s documentation, unit, and examples; read Gowall and Hellwal’s full capability documentation and all source paths that implement the claims above. I viewed all six skwd-wall README screenshots and the complete 2:05 preview, including dense transition-focused sequences. The transition verdict comes from that viewed preview. I also viewed all Gowall examples checked into or linked from its README and Hellwal’s preview/showcase media.

**Did not:** I did not launch skwd-wall, awww, Gowall, Hellwal, or Matugen on this machine; did not alter services, wallpaper state, configuration, or the live generated contract; and did not test the installed Matugen version. That Matugen check remains explicitly execution-time. I did not line-review dependency lockfiles, generated metadata, binary media bytes, Gowall’s unrelated OCR/background-removal/upscaler internals, or Hellwal’s vendored `stb_image.h`; none is evidence for the wallpaper-pipeline claims above.
