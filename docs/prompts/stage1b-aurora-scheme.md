# Stage 1B — The aurora scheme: pinned ladder, dark identity, accent defaults

You are a Codex execution session for the Aurora build, working in `/home/alex/nix`. Your PM launches, monitors, and reviews you; your final message is a report to them. A prior session (1A) vendored the caelestia shell to `modules/home/aurora-shell/` — that tree is yours to patch today, minimally.

## Mandatory reading, in order

1. `/home/alex/nix/SESSION_PREAMBLE.md` — in full; its rules bind this session.
2. `/home/alex/nix/GRAND_PLAN.md` lines 131–149 (§3.1 the palette ladder + accent clamp) and lines 211–219 (§4 head: the engine decision + the three patches).
3. The §2.1 manifest rule for the plugin: "No source changes at v1 except the scheme defaults."

## Scope

IN: make the vendored shell *default* to the aurora identity — the §3.1 surface ladder pinned, dark-only, accent defaults from the three named families — so that when it first runs (session 1C), it wears aurora, not stock caelestia.

OUT: the scheme *generator* clamp (lives in the caelestia CLI — lands in Stage 4 with its first consumer), templates, the wallpaper pipeline, renaming anything, enabling anything, deleting light-mode *code* (see below).

## Hard rules

- NO network, NO nix commands, NO git commits (the PM commits), explicit file edits only.
- `/home/alex/nix/repos/` is read-only reference. The live desktop trees (`modules/home/quickshell` etc.) are untouchable.
- Minimal diffs: every changed line gets an `// Aurora:` (or `# Aurora:`) marker. If you find yourself rewriting a file, stop — that is off the plan.
- Report honestly; flag every place where the code's structure forced an interpretation.

## Tasks

### 1. Investigate first (report before patching in your final message)

Map the scheme machinery in `modules/home/aurora-shell/`: `services/Colours.qml` (semantic palette, `scheme.json` watch, CAnim propagation), the plugin's config defaults under `plugin/src/Caelestia/Config/` (appearance/colour-related), and wherever the default/fallback scheme values live (a default scheme JSON, hardcoded QML defaults, or plugin-side defaults — find the actual mechanism by reading; do not guess). Identify how m3-style role names map onto the §3.1 ladder.

### 2. Pin the ladder as the default scheme

Set the default values so the ladder is exact (§3.1): background `#080b14`, surfaceLowest `#0a0e1a`, surfaceLow `#0f1526`, surface `#151d33`, surfaceHigh `#1c2742`, primary text `#e6edf7` (never pure white), secondary text `#aab6c8`. Map these onto caelestia's actual role names (m3background, surfaceContainer tiers, onSurface/onSurfaceVariant, etc.) and include your mapping table in the report — every mapping decision explicit, none silent.

### 3. Accent defaults

Default `primary` to the teal/cyan family (`#00d4aa` / `#38bdf8` anchors), `secondary` to the purple family (`#7c3aed` anchor), `tertiary` to the seafoam/deep-green family (`#34d399` anchor). Values must sit luminous-against-near-black (the §3.1 tone 55–70 intent) — if an anchor needs a small lightness nudge to read against `#0a0e1a`, nudge it and note the final hex in the report. Container/on-color variants: derive consistently with how the scheme structures them (read how stock values relate; keep the same relationships).

### 4. Dark is the identity

Default the shell to dark mode wherever the mode default lives, hard-set if there is a simple switch. Do NOT bulk-delete light-mode code paths — v1 rule is minimal diffs; light-mode *removal* is recorded as a later cleanup, not today's edit.

### 5. Ledger

Update the aurora-shell row in `/home/alex/nix/SOURCES.md`: local delta now includes "aurora scheme defaults (ladder pinned, dark default, accent families)".

### 6. Final report (raw data)

- The investigation map: which files hold the default scheme, how the watch/fallback chain works.
- The role-mapping table (§3.1 role → caelestia role → value).
- Final accent hexes chosen per family.
- Every edited file with its quoted diff (they should all be small).
- `git status --short` output and anything you could not complete or had to interpret.
