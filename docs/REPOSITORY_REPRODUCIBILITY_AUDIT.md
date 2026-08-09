# Repository Reproducibility Audit

_Audit date: 2026-08-09. Scope: normalize the NixOS/Aurora project onto a
canonical `main`, guarantee remote backup, and determine whether any
load-bearing source lives only on this laptop._

This document is a point-in-time record. It does not change the build.

---

## 1. Identity

| | |
|---|---|
| GitHub owner | `AlexbringsMercy` |
| Repository | `AlexbringsMercy/nix` |
| Canonical branch | `main` |
| Default branch on GitHub | `main` |
| Local canonical checkout | `/home/alex/nix` (branch `main`, upstream `origin/main`) |
| Rebuild entry flake (machine-local) | `/home/alex/.config/nixos-local` — see §6 |

**Final project HEAD after normalization (before this audit commit):**
`b2000f4b20d27cf409eafe497e26e426a21eb92f`

The commit that adds this document advances `main` one further; the final
remote SHA is recorded in the git history and the completion report.

---

## 2. Starting topology (before normalization)

The repository had drifted into an accidental agent-branch layout:

```
origin/main            4974921  "Update configuration.nix"  (≈79-line bootstrap, obsolete)
origin/codex/macbook-desktop  b2000f4  ← the actual project (76 commits ahead of main, 0 behind)
origin/stage3/topbar   dbd3c72  ← experimental Stage 3 WIP (see §8)
```

- `main` was a straight ancestor of `codex/macbook-desktop` (76 ahead / 0 behind) —
  a clean descendant, not a competing history.
- `stage3/topbar` forked from merge-base `de96b77`
  (`docs(plan): correct palette, bar, minimize and snap architecture`) and carried
  **one** unique WIP commit; the mainline (`codex`) carried 29 commits past that
  merge-base. `codex` is therefore newer and more complete
  (`b2000f4` 2026-07-29 22:15 vs `dbd3c72` 2026-07-29 03:44).

The delegation had warned that a newer PM session might have advanced HEAD past
`b2000f4`. Verified: it had not. `b2000f4` was still the newest mainline commit,
both worktrees were clean, no process held either tree, and nothing had been
committed in 11 days. `b2000f4` was confirmed authoritative by inspection, not
assumed.

---

## 3. Local-only work / backup risk

**None.** Every local branch matched its remote exactly (0 ahead / 0 behind on
all of `main`, `codex/macbook-desktop`, `stage3/topbar`). No stashes. Both
worktrees (`/home/alex/nix`, `/home/alex/aurora-stage3`) had clean working trees
— no modified tracked files, no meaningful untracked source.

> **If `/home/alex/nix` had been destroyed before this audit and GitHub cloned,
> zero committed source would have been lost.** The only material outside git is
> enumerated in §6 (firmware, machine-local wrapper, generated caches,
> user-managed agent installs) — none of it is unique project *source* except the
> tiny wrapper flake, whose exact contents are reproduced below.

---

## 4. Normalization performed

1. `git checkout main` (was `4974921`).
2. `git merge --ff-only codex/macbook-desktop` → **fast-forward** `4974921..b2000f4`.
   No squash, no rebase, no rewrite, no merge commit, no force.
3. `git push origin main` → fast-forward `origin/main` to `b2000f4` (non-force).
4. Verified `main == origin/main`, tree identical to the retired branch, 0/0.
5. Retired the obsolete agent branch:
   - `git branch -d codex/macbook-desktop` (safe delete; history fully reachable from `main`).
   - `git push origin --delete codex/macbook-desktop`.

Result:

```
main = b2000f4 (→ this audit commit)   local == remote, 0 ahead / 0 behind
stage3/topbar = dbd3c72                preserved (see §8)
codex/macbook-desktop                  removed local + remote
```

GitHub default branch remains `main` and now exposes the complete project.

---

## 5. Source completeness

The repository is essentially source-complete for the declarative configuration.
Confirmed present and tracked:

- **Nix core** — `flake.nix` (all inputs pinned to explicit revs: nixpkgs,
  nixos-hardware, t2fanrd, home-manager, in-tree `aurora-shell`), `flake.lock`,
  host `hosts/macbook/{default.nix,hardware-configuration.nix}`, Home Manager
  `home/alex/default.nix`, `modules/nixos/*`, `modules/home/*`.
- **Hyprland compositor patches** (applied via overlay in `flake.nix`):
  `modules/nixos/patches/hyprland-drag-anchor.patch`,
  `hyprland-deco-border-grab.patch`, `hyprland-dwindle-resize-workarea.patch`,
  and `modules/home/hyprland/patches/hyprbars-hover.patch`.
- **Custom plugin source** — `modules/home/hyprland/aurora-minimize/`
  (`main.cpp`, `CMakeLists.txt`).
- **Aurora shell** — `modules/home/aurora-shell/` (~457 files: QML, `extras/version.cpp`, nix).
- **All `builtins.readFile` inputs resolve to tracked files** —
  `modules/home/hyprland/hyprbars.lua.in`, `scripts/aurora-resume-agent`,
  `modules/home/theming/matugen/aurora.toml`.
- **Theming generators** — `modules/home/theming/matugen/templates/aurora/*`
  (the templates that produce the `~/.cache/aurora-theme/*` runtime files).
- **Scripts** — `scripts/{apply-wallpaper,aurora-resume-agent,aurora-stage2-gate-auto.sh,equalizer-state,weather-fetch}`, `checks/preflight.sh`.
- **Governance / source-of-truth docs** — see the source index
  (`docs/NIXOS_CURRENT_SOURCE_INDEX.md`).

The repo's `flake.nix` exposes both `lib.mkMacbook` **and** a self-evaluating
`nixosConfigurations.macbook = mkMacbook { }` (firmware defaults to `null`), so
`nix flake check` / evaluation works from a clone without the machine-local
wrapper. The wrapper only injects proprietary firmware.

---

## 6. Load-bearing state that lives outside git

| Item | Path | Class | Disposition |
|---|---|---|---|
| Proprietary T2 Broadcom firmware (163 files) | `/etc/nixos/firmware/brcm` | A/B — proprietary, machine-local | **Correctly excluded.** Gitignored + separately located. Restore-from-backup prerequisite. |
| Machine-local rebuild wrapper flake | `~/.config/nixos-local/{flake.nix,flake.lock}` | **F/hybrid** — load-bearing source, but binds machine paths | **Not committed** (would embed absolute paths / add a second flake). Reproduced verbatim below → now remotely backed up via this doc. Reference migration owed (§7). |
| Generated theme cache | `~/.cache/aurora-theme/{kitty.conf,hyprlock.conf,gtk.css,…}` | C — generated | Rebuilt at runtime from tracked matugen templates. Not source. |
| Lock-screen avatar | `~/.face` | B — machine-local user state | Cosmetic; restore from backup if desired. |
| User-managed agent installs | `~/.local/bin/claude`, `~/.local/bin/codex` (symlinks) | E — intentionally user-managed | Not git-owned by design. Do not replace with Nix copies. |
| Agent credentials / sessions | `~/.claude.json`, `~/.claude`, `~/.codex/auth.json`, `~/.codex/config.toml` | A — secrets | Never commit. |
| Research upstream clones (~11 GB) | `/repos/` | C — re-cloneable | Gitignored. Vendored copies with attribution enter the tree at Stage 1. |
| Wallpapers, `result*`, `*.qcow2`, `.direnv` | various | C/D — generated/assets | Gitignored. |

### The machine-local wrapper, verbatim

`~/.config/nixos-local/flake.nix` — this is the actual `nixos-rebuild` entry
point invoked by the `rebuild-macbook` / `test-macbook` fish abbreviations:

```nix
{
  description = "Machine-local MacBook wrapper with proprietary firmware";

  inputs = {
    # git+file (not path:): the path fetcher would copy the whole worktree into
    # the store — including the 11 GB repos/ research clones — on every eval.
    # The git fetcher ships the committed tree only.
    macbook-config.url = "git+file:///home/alex/nix";
    firmware = {
      url = "path:/etc/nixos/firmware";
      flake = false;
    };
  };

  outputs = { macbook-config, firmware, ... }: {
    nixosConfigurations.macbook = macbook-config.lib.mkMacbook {
      firmwareSource = "${firmware}/brcm";
    };
  };
}
```

Invocation (from `modules/home/fish.nix`):

```
rebuild-macbook = sudo nixos-rebuild switch --flake /home/alex/.config/nixos-local#macbook \
    --override-input macbook-config path:/home/alex/nix \
    --override-input firmware path:/etc/nixos/firmware
```

`flake.lock` (6 KB) is regenerated from these inputs; only `flake.nix` is
required to reconstruct the wrapper.

---

## 7. Reference migrations still owed

Deferred deliberately — none are required for backup, and doing them now would
risk changing the running build:

1. **Machine-local wrapper canonicalization.** The `~/.config/nixos-local`
   flake is not in git and hard-codes `git+file:///home/alex/nix` and
   `/etc/nixos/firmware`. A future portability project should decide whether to
   bring a parameterized wrapper into the repo (or document `nix build` with a
   `firmwareSource` argument). Its exact contents are preserved in §6.
2. **Firmware provisioning path** should be documented as an explicit install
   prerequisite (restore `/etc/nixos/firmware/brcm` from backup before the first
   rebuild) as part of that same portability work.

---

## 8. `stage3/topbar` — intentionally retained

Not part of the delegation's known topology; discovered during audit and
**preserved on purpose**:

- SHA `dbd3c72af19031a84929a582e642e65a91da48ac`
  (`stage3(wip): ilyamiro top widget bar — islands, expansions, Hyprexpo entry`).
- Carries **one unique commit** (topbar/widget-bar source) reachable from
  nowhere else — deleting it would lose source.
- Has its own live worktree at `/home/alex/aurora-stage3` (clean).
- Already backed up at `origin/stage3/topbar`.

It is not an agent-namespace duplicate of the project; it is genuine unmerged
next-stage work. Left untouched. The operator/portability chat should decide its
fate (merge, rebase onto `main`, or discard) — this audit did not.

---

## 9. Clean-clone verdict

> If the laptop were lost tonight, `AlexbringsMercy/nix` cloned at `main`, only
> documented secrets/machine-local prerequisites restored, and the repo
> instructions followed — would the source needed to reconstruct the intended
> Aurora/NixOS configuration still exist?

### Verdict: **MOSTLY**

You would recover the **complete declarative source** — flake, lockfile, host,
hardware config, all modules, all compositor patches, the custom plugin, the full
Aurora shell, theming generators, scripts, and governance docs. The repo even
self-evaluates `nixosConfigurations.macbook`.

The gaps are external-by-design, and both are now documented:

1. **Proprietary T2 firmware** (`/etc/nixos/firmware/brcm`) must be restored from
   backup — it cannot legally/appropriately live in git. Without it,
   Bluetooth/Wi-Fi firmware is absent.
2. **The machine-local wrapper** (`~/.config/nixos-local/flake.nix`) must be
   recreated — trivial, contents preserved verbatim in §6. (Or build directly
   against the repo, accepting `firmwareSource = null`.)

Not **YES**, because a bit-for-bit rebuild depends on the two external items
above. Not **NO**, because every piece of *project source* is either committed or
reproduced in this document.
