# Stage 2A — hide per-window minimize workspaces from caelestia's UI

You are a Codex execution session for the Aurora build (NixOS + Hyprland, MacBook T2), working in `/home/alex/nix`. Your PM launches and reviews you; your final message is a report to them. You do FILE WORK ONLY — the PM builds, verifies, and deploys.

## Mandatory reading, in order

1. `/home/alex/nix/SESSION_PREAMBLE.md` — in full; its rules bind you (full reads, adapt don't invent, honest reporting, minimal marked diffs).
2. The vendored shell tree `/home/alex/nix/modules/home/aurora-shell/` — specifically every component that lists or renders Hyprland workspaces.

## The problem

Window minimize (the vendored `scripts/window-minimize`) moves a window to its **own** special workspace named `special:min-<window-address>` (one per minimized window — this per-window scheme is deliberate and correct; a single shared `special:minimized` has a dump-all bug, so do NOT change the minimize mechanism). The side effect: **caelestia's workspace switcher displays these `special:min-*` workspaces as visible, navigable workspaces** (the operator sees an "M"-badged workspace per minimized window). That is confusing — minimized windows should be hidden, not surfaced as workspaces to click through.

## Scope

IN: find EVERY caelestia surface that enumerates/renders workspaces and exclude workspaces whose name begins with `special:min` from the display, so minimized windows no longer appear as workspaces. Likely locations to investigate (verify by reading, don't assume): the bar workspaces module, any workspace switcher/OSD, the dashboard, an overview/expo surface, and the `Hypr`/workspaces service that feeds them. Check whether there's already a config-driven filter for special workspaces before adding code.

OUT: do NOT change the minimize script or the `special:min-<addr>` naming; do NOT hide OTHER special workspaces the shell legitimately shows (e.g. `special:dev`, `special:sysmon`, scratchpads) — filter specifically on the `special:min` prefix; no unrelated refactors; no build/nix/git-commit/deploy.

## Tasks

1. **Investigate + report first:** map how caelestia gets the workspace list (the service — likely `services/Hypr.qml` or similar) and every UI component that renders workspace pills/badges. Identify the single cleanest filter point (prefer filtering at the source/service or in each display's model) that hides `special:min*` without affecting other specials or the actual minimize/restore behavior. Report your finding before editing.
2. **Implement the filter** at the point(s) you identified — a name-prefix exclusion (`name.startsWith("special:min")` or the QML equivalent). Keep it minimal; mark each changed line `// Aurora:`. If the shell already exposes a "hide special workspaces" config knob that would over-hide, do NOT use it — filter specifically on the `special:min` prefix.
3. **Confirm the restore path is unaffected:** the `window-minimize restore` flow (and the omarchy script) must still find and restore minimized windows — you're only hiding them from workspace *display*, not from Hyprland. Note in your report why your change doesn't touch restore.

## Final report (raw data)

- The investigation map: how workspaces flow from Hypr → the display components, and the exact filter point(s) you chose and why.
- Every edited file with its quoted `// Aurora:`-marked diff (should be small).
- Confirmation the minimize/restore mechanism and other special workspaces are untouched.
- Anything you had to interpret or couldn't complete.
