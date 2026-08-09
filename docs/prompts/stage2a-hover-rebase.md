PM AUDIT FEEDBACK — your hover patch needs a rebase onto the correct Hyprland version. The LOGIC is good; the base revision is wrong.

The problem: you wrote the patch against `repos/hyprland-plugins` at HEAD `7644cec` ("chase hyprland (#687)"), whose latest tag is v0.56.0 — that targets Hyprland 0.56. **Our Hyprland is 0.55.4, and nixpkgs builds hyprbars from tag v0.55.0.** The patch does NOT apply against v0.55.0: it fails at `hyprbars/globals.hpp:30` and `hyprbars/main.cpp:215`. Three of the four patched files (`barDeco.cpp`, `globals.hpp`, `main.cpp`) differ between v0.55.0 and HEAD; only `barDeco.hpp` is identical. Building the HEAD/0.56 plugin against 0.55.4 would fail to compile or be rejected at load (plugin API mismatch).

I have checked out the local source at the correct version for you:
- `repos/hyprland-plugins` is now at tag **v0.55.0** (rev `90e66baf99c9025b1d5e9c9e58dd3c80d0911ea2`). Re-read the four files at THIS version.

Do this (still PROPOSE-ONLY — no build, no nix, no git commit, no deploy):

1. **Rebase the same hover logic onto v0.55.0.** Keep the exact behavior you designed: the hover-highlight rect in `renderBarButtons` gated on `m_iButtonHoverState & (1 << i)`; the `damageOnButtonHover` rewrite to a per-button bitfield that calls `damageEntire()` only when the computed hover set differs; the removal of `m_bButtonHovered`; and the `plugin:hyprbars:hover_color` config value (default `0x22FFFFFF`) registered in `main.cpp` + `globals.hpp`. Adjust the surrounding context lines to match v0.55.0.

2. **Rewrite `modules/home/hyprland/patches/hyprbars-hover.patch`** so it applies cleanly against v0.55.0 (paths `a/hyprbars/...` / `b/hyprbars/...`, `-p1`). You MAY run `git apply --check` inside `repos/hyprland-plugins` to verify (that is read-only — do not modify anything under `repos/`). Confirm it passes.

3. **Fix the Nix wiring in `modules/home/hyprland/default.nix`: drop the HEAD source override.** Prefer building from nixpkgs' own v0.55.0 hyprbars source so ABI is guaranteed — ideally just:
   `patchedHyprbars = pkgs.hyprlandPlugins.hyprbars.overrideAttrs (_: { patches = [ ./patches/hyprbars-hover.patch ]; });`
   with NO `src`/`cmakeDir` override. Read how nixpkgs' hyprbars derivation is structured (its `src`/`sourceRoot`) to confirm the patch paths resolve against it; if they genuinely don't, say so and fall back to pinning `src` to the **v0.55.0 tag** rev (`90e66baf99c9025b1d5e9c9e58dd3c80d0911ea2`) with a placeholder `hash = ""` — NOT HEAD. Keep the `@HYPRBARS_PLUGIN@` substitution pointing at `patchedHyprbars`.

4. Leave `hyprbars.lua.in` (size = 24) as-is.

Report: the rebased patch (quoted), confirmation that `git apply --check` passes against v0.55.0, the corrected `default.nix` wiring, and whether you kept nixpkgs' src or had to pin v0.55.0 (with why).
