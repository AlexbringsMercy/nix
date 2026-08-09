# Stage 2D — carry the tiled-drag grab-anchor patch (operator approved)

## Read first

1. `/home/alex/nix/SESSION_PREAMBLE.md` — binds you, always.
2. `modules/home/hyprland/default.nix` — the existing hyprbars patch carrier; your
   nix wiring must match this repo's idiom (including the `# Aurora:` comment style).
3. `flake.nix` — both eval paths (`homePkgs` and the `nixosSystem`) that your
   overlay must cover.

## The approved fix (do not re-litigate the diagnosis)

Hyprland 0.55.4 regression, proven live and by deep research: when the drag
controller picks up a TILED window (Super+drag or hyprbars titlebar drag), it
places the new floating box centered under the cursor — `cursor - windowSize/2` —
discarding the grab offset. See pinned source
[`src/layout/supplementary/DragController.cpp` lines 58–80 at tag v0.55.4]
(https://github.com/hyprwm/Hyprland/blob/a0136d8c04687bb36eb8a28eb9d1ff92aea99704/src/layout/supplementary/DragController.cpp#L58-L80),
upstream issue #3712 (closed "not planned"). Hyprland's own 2022 implementation
preserved the offset (`originalPosition + (currentMouse - beginMouse)`); mirror
provenance: commits `3e36f1c42c2cd561ac84c78c20261f950ee37269` and
`8a4f6d01f3ac3016403924064567791371c83f88` at tearforge.net/cry/Hyprland.

The operator approved forward-porting that invariant as a small carried patch.
Mechanism at the tiled-to-floating pickup transition:

1. Before the float conversion, capture the tiled box and cursor position.
2. Compute the normalized anchor: `anchor = (cursor - tiledTopLeft) / tiledSize`
   (componentwise; anchor is inherently in [0,1]).
3. Let the existing code choose the remembered/scaled floating size as it does today.
4. After conversion, position the floating box so the anchor stays under the
   cursor: `floatingTopLeft = cursor - anchor * floatingSize`.
5. Record the drag-begin cursor/window positions (`m_beginDragXY` /
   `m_beginDragPositionXY` or their 0.55.4 equivalents) only AFTER the corrected
   placement, so subsequent motion math is consistent.

## Scope — ISOLATION IS THE OPERATOR'S EXPLICIT CONDITION

IN:
- One patch file (suggest `modules/nixos/patches/hyprland-drag-anchor.patch` or
  alongside the hyprbars patch — your call, cite the precedent you follow)
  touching ONLY the tiled-pickup placement path in DragController.
- A nixpkgs overlay applying it to `hyprland` via `overrideAttrs` with
  `patches = (old.patches or []) ++ [ ... ]`, wired into BOTH eval paths in
  `flake.nix` so `pkgs.hyprland` AND `pkgs.hyprlandPlugins.hyprbars` (which
  builds against it) see the same patched compositor.

OUT — must remain byte-identical in behavior:
- The already-floating drag branch (works today).
- Resize mode (MBIND_RESIZE), drag threshold, animation handling, focus policy,
  drop/retile heuristics, group and fullscreen handling, config surface.
- No new config options, no Lua changes, no other files.
- No commits, no staging, no live hyprctl/Hyprland commands, no system builds
  (PM builds). If the fix cannot be kept inside this scope, STOP and escalate
  with evidence instead of widening it.

## Verification you must do

- Locate the pinned 0.55.4 source (nix store copy from prior builds, or the
  tagged GitHub tree) and confirm your hunks apply cleanly: `patch -p1 --dry-run`
  (or `git apply --check`) against that exact tree. Paste the command + output.
- Confirm by reading the surrounding 0.55.4 code that your insertion point is the
  ONLY place the tiled pickup discards the offset, and that the floating branch
  bypasses your code.
- `nix eval` sanity on the touched flake expressions if evaluable in your
  sandbox; if not, say so — do not fake it.

## Report (raw data)

- Exact patch hunks and the reasoning for each line against the 0.55.4 source.
- The overlay diff and which precedent file:line you matched for idiom.
- What is verified statically vs. what needs the live gate. The live gate matrix
  the PM will run with the operator: top-left / center / titlebar / bottom-right
  grabs on short and tall tiled windows; Super+LMB and hyprbars bar drag;
  already-floating drag unchanged; drop/retile still works; remembered-floating-
  size window (size differs from tiled size) keeps the anchor within ~1 logical
  pixel on eDP-1 2560×1600 @ 1.5.
- Anything you could not verify, stated plainly.
