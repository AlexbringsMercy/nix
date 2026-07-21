# Stage 1A — Vendor the aurora-shell chassis

You are a Codex execution session for the Aurora build (NixOS + Hyprland, 2020 MacBook Air T2). You work inside `/home/alex/nix`. Your project manager launches, monitors, and reviews you; your final message is a report to them, not to a human bystander.

## Mandatory reading, in order, before any other action

1. `/home/alex/nix/SESSION_PREAMBLE.md` — in full. Its rules bind this session.
2. `/home/alex/nix/GRAND_PLAN.md` lines 10–20 (§0 rules of engagement), lines 43–80 (§2.1 chassis decision + fork manifest table), lines 100–120 (§2.3 target repository layout).

The §2.1 manifest table is your law: this session VENDORS the chassis; it does not modify, rename, enable, or delete anything beyond what is listed below.

## Scope — Stage 1A only

IN: copy the caelestia shell snapshot into the repo as aurora-shell, add per-file attribution headers, create the SOURCES.md provenance ledger, wire the vendored tree into the parent flake as a `path:` input with an `aurora-shell` package output.

OUT (later sessions — do not touch): renaming `programs.caelestia` → `programs.aurora-shell` (1B), the aurora scheme (1B), importing/enabling the HM module (1C), deleting the old `modules/home/{waybar,rofi,wallpaper,quickshell}` trees (1C), any patch from the manifest's "two patches" notes.

## Hard rules

- NO network access (sandbox enforces this; everything you need is on disk).
- NO `nix build`, `nix flake lock/update`, or any nix evaluation — the PM builds and locks after review.
- NO `git push` — the PM pushes.
- `git add` with EXPLICIT paths only; never `git add -A` or `git add .`.
- `/home/alex/nix/repos/` is READ-ONLY source material. Never write inside it.
- Do not touch the live desktop's config trees (`modules/home/quickshell`, `waybar`, `rofi`, `wallpaper`, `hyprland`) — the machine is someone's running desktop mid-build.
- Attribution style is repo + path only. Do not add any other commentary about the upstream project's terms or status, anywhere, in any file or commit message.
- Report honestly (§0 rule 5): every deviation, mismatch, or skipped item goes in your final report.
- This is an 8 GB machine: use scripts for bulk operations; do not cat 58k lines into your context.

## Tasks

### 1. Vendor the snapshot (commit 1 — byte-identical)

Copy the full tree `/home/alex/nix/repos/caelestia/shell-main/shell-main/` → `/home/alex/nix/modules/home/aurora-shell/` — everything: `shell.qml`, `plugin/`, `services/`, `modules/`, `components/`, `utils/`, `scripts/`, `extras/`, `assets/`, `nix/`, `CMakeLists.txt`, `flake.nix`, `flake.lock`, `LICENSE`, `README.md`. Exclude only a `.git` directory if one exists. This exact snapshot is the audited source of truth (inventoried in `research/caelestia-full-inventory.md`) — do not substitute or refresh anything.

Commit exactly this, byte-identical, so the vendor is auditable:
`feat(stage1a): vendor caelestia shell as the aurora-shell chassis (verbatim snapshot)`

### 2. Attribution headers (commit 2)

Add a ONE-LINE header comment at the top of every commentable text source file in the vendored tree (after a shebang line if present):

- `.qml`, `.cpp`, `.hpp`, `.c`, `.h`: `// Vendored from caelestia-dots/shell — <original relative path>. Aurora build; local changes tracked in git.`
- `.nix`, `.sh`, `.py`, `.fish`, `CMakeLists.txt`: same text with `#`.

Skip (covered by SOURCES.md instead): `.json`, `flake.lock`, `.md`, `LICENSE`, images, fonts, and any other binary or comment-hostile format. Apply via script; verify afterwards that headered + skipped = total file count, and that no file got a duplicate header.

Commit: `docs(stage1a): attribution headers across the vendored chassis`

### 3. SOURCES.md provenance ledger (part of commit 2)

Create `/home/alex/nix/SOURCES.md`: a table with columns Component | Upstream repo | Upstream path | Vendored path | Local delta. First entry: the aurora-shell chassis (delta: attribution headers + the build shim from task 4 only). Below the table, a short provenance note: vendored from the on-disk snapshot audited by the research corpus; upstream remote `github.com/caelestia-dots/shell` recorded for future diffs; history graft deliberately not performed so the audited bytes stay exact (PM decision, 2026-07-21).

### 4. Parent flake wiring (commit 3)

Read the vendored `modules/home/aurora-shell/flake.nix` carefully first. Then:

- Add to `/home/alex/nix/flake.nix` inputs: `aurora-shell.url = "path:./modules/home/aurora-shell";` with `inputs.nixpkgs.follows = "nixpkgs"` if the subflake accepts it.
- Expose `packages.x86_64-linux.aurora-shell` from the parent flake = the subflake's shell package (the one that builds the C++ plugin; find its exact output attr by reading, not guessing).
- Known adaptation point: the subflake uses `rev = self.rev or self.dirtyRev` — as a path input it may have neither. If needed, make the minimal edit in the vendored `flake.nix` to fall back to a fixed string `"aurora-vendored"`, mark that line with a `# Aurora:` comment, and record it as a delta in SOURCES.md.
- Leave every other subflake input (quickshell, m3shapes, the cli input, etc.) exactly as pinned upstream. Do not resolve or lock anything.

Commit: `feat(stage1a): wire aurora-shell into the parent flake as a path input`

### 5. Final report (your last message — raw data)

- Files: vendored count, headered count, skipped count (with the skip-category breakdown).
- The three commit shas + subjects; `git status --short` proof of a clean tree.
- The exact package attr path the parent flake now exposes, and every edit made to either flake.nix (quoted).
- Any mismatch between the on-disk tree and what GRAND_PLAN §2.1 describes (missing modules, unexpected extras) — flag, don't fix.
- Anything you skipped or could not complete, stated plainly.
