# Stage 3 — in progress (dormant source)

This directory holds **unfinished Stage 3 source that is deliberately not loaded
by the running shell.** It is parked here so the work survives on canonical
`main` without activating anything. Stage 2 is still open; do not wire this in.

## Provenance

All source under `topbar/` was taken verbatim from:

    branch: stage3/topbar
    commit: dbd3c72af19031a84929a582e642e65a91da48ac
    "stage3(wip): ilyamiro top widget bar — islands, expansions, Hyprexpo entry"

That branch was an isolated Stage 3 worktree that forked from the mainline at
`de96b77`. Its 23 QML files were copied **byte-identically** into this directory
on `main`, and the branch and its worktree were then retired. The original commit
`dbd3c72af19031a84929a582e642e65a91da48ac` was **not** merged into `main`, so the
commit itself is **not reachable through `main`** — only its **source content** is
preserved here. The full SHA above is the durable provenance record; recover the
original commit (e.g. its withheld `shell.qml` change) from a backup/clone if ever
needed.

## What it is

An ilyamiro-derived top widget bar: 23 QML files — eleven independent islands
(`topbar/islands/`), a shared morph-engine `Expansion.qml`, `IslandBar.qml`,
eight expanded panels (`topbar/panels/`, including a Music/EQ surface bound to
`scripts/equalizer-state` through `topbar/services/Equalizer.qml`), and the
`TopBar.qml` entry point. Data is sourced from caelestia's existing services,
not stubs. It is a new surface, independent of the caelestia left rail
(`modules/bar/`); it does not modify the rail.

## Why it is dormant (two independent reasons)

1. **Not built into the shell.** The shell's `CMakeLists.txt` installs only the
   `assets components modules services utils` directories into the Quickshell
   config. This `stage-3-in-progress/` directory is not one of them, so nothing
   here is shipped to the running shell.
2. **Not imported.** `shell.qml` does **not** import `modules/topbar` and does
   **not** instantiate `TopBar {}`. The Stage 3 commit's 5-line `shell.qml`
   change was intentionally left behind.

The QML also uses the namespaced import `qs.modules.topbar.services`, which only
resolves when the tree lives at `modules/topbar/`. Parked here, that import
cannot resolve — a third, structural guarantee that it is inert.

## How a future Stage 3 session activates it

Only when Stage 2 is closed and Stage 3 is approved:

1. Move the tree back into the live module path:

   ```sh
   git mv modules/home/aurora-shell/stage-3-in-progress/topbar \
          modules/home/aurora-shell/modules/topbar
   ```

2. Re-apply the activation wiring in `modules/home/aurora-shell/shell.qml`
   (this is the exact change that was withheld):

   ```diff
    import "modules/lock"
   +import "modules/topbar"
    import QtQuick
   ...
        Lock {
            id: lock
        }
   +
   +    // Aurora Stage 3: the ilyamiro-composed top widget bar — an independent surface from
   +    // the caelestia left rail above (Drawers/BarWrapper). See modules/topbar/TopBar.qml.
   +    TopBar {}
   +
        ConfigToasts {}
   ```

3. Build and verify per the normal Stage discipline. Then remove this directory.

## Known stubbed / flagged work (from the source commit)

- **Hyprexpo** entry point (next to the workspace pills) dispatches the real
  `hyprexpo:expo` verb but is **inert** — Hyprexpo was retired from upstream
  `hyprwm/hyprland-plugins` (~May 2026, hyprland-plugins#672) and is absent from
  the pinned checkout, `repos/`, and nixpkgs. A maintained continuation exists at
  `sandwichfarm/hyprexpo`; it is deliberately not wired to a substitute until a
  plugin build is added.
- Stubbed and flagged, not silently dropped: the radial Bluetooth constellation,
  the battery-ring composite, media width-morph, and workspace overflow.

See `docs/prompts/stage3-taskbar-mapping.md` for the Stage 3 mapping prompt.
