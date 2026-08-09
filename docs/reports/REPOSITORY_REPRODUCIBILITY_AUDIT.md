# Repository Reproducibility Audit

_Audit date: 2026-08-09. Scope: normalize the NixOS/Aurora project onto a
canonical `main`, guarantee remote backup, and determine whether any
load-bearing source lives only on this laptop._

This document is a point-in-time record. It does not change the build.

> **Finalization update (2026-08-09).** After the normalization recorded below,
> a repository-finalization pass completed the following, and this report now
> describes that **final** state:
> - The Stage 3 `stage3/topbar` branch/worktree was **retired**; its unique source
>   is now dormant on `main` at `modules/home/aurora-shell/stage-3-in-progress/`
>   (see §8).
> - The machine-local wrapper now has a **tracked canonical template** at
>   `hosts/macbook/nixos-local/` (flake + README), closing the §7 debt (see §6/§7).
> - The `rebuild-macbook`/`test-macbook` shortcuts, `checks/preflight.sh`, and
>   active build instructions no longer use the unsafe raw `path:/home/alex/nix`
>   input; they use `git+file:///home/alex/nix`.
> - All project documentation was reorganized under `docs/{plans,reports,
>   references,research,briefs,prompts,instructions,archive}` with a
>   `docs/README.md` index.

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

**Project HEAD after the initial normalization:**
`b2000f4b20d27cf409eafe497e26e426a21eb92f` (then advanced by the audit commit
`7c37c3d…`, and again by the 2026-08-09 finalization commit — see `git log`).

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
  (`docs/references/NIXOS_CURRENT_SOURCE_INDEX.md`) and `docs/README.md`.

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

Invocation (from `modules/home/fish.nix`), now using the git-backed input:

```
rebuild-macbook = sudo nixos-rebuild switch --flake /home/alex/.config/nixos-local#macbook \
    --override-input macbook-config git+file:///home/alex/nix \
    --override-input firmware path:/etc/nixos/firmware
```

`flake.lock` (6 KB) is regenerated from these inputs; only `flake.nix` is
required to reconstruct the wrapper. **As of the 2026-08-09 finalization the
wrapper's `flake.nix` is tracked canonically at `hosts/macbook/nixos-local/flake.nix`**
(with a `README.md` giving the recreation steps), so it no longer lives only on
the laptop.

---

## 7. Reference migrations — resolved (2026-08-09)

Both items previously owed here are now done:

1. **Machine-local wrapper canonicalization — DONE.** The wrapper's `flake.nix`
   is tracked at `hosts/macbook/nixos-local/flake.nix` (a copy-ready template with
   a big header) alongside `hosts/macbook/nixos-local/README.md`. The live copy at
   `~/.config/nixos-local/` is recreated by copying that template. The template
   keeps the safe `git+file:///home/alex/nix` input and documents the external
   firmware path; it is intentionally not evaluated by the repo's own flake
   (`hosts/macbook/default.nix` imports explicit files, never this subtree).
2. **Firmware provisioning path — DONE.** Restoring `/etc/nixos/firmware/brcm`
   from backup before the first rebuild is documented in
   `hosts/macbook/nixos-local/README.md`, `docs/instructions/recovery.md`, and the
   root `README.md`.

The proprietary firmware itself remains external by design (§6) and is **not**
reproducibility debt.

---

## 8. `stage3/topbar` — absorbed and retired (2026-08-09)

Discovered during the original audit as an isolated Stage 3 worktree/branch
(`dbd3c72`, `stage3(wip): ilyamiro top widget bar …`) carrying **one unique
commit** of topbar/widget-bar source reachable from nowhere else. The
finalization pass resolved it:

- Its 23 QML files were checked out verbatim from `dbd3c72` and placed, **dormant**,
  on `main` at `modules/home/aurora-shell/stage-3-in-progress/topbar/` — not
  installed by the shell's CMake (`assets components modules services utils` only),
  not imported by `shell.qml`, and using a `qs.modules.topbar.*` namespaced import
  that cannot resolve outside `modules/topbar/`. Three independent guarantees that
  it is inert. Provenance and reactivation steps are in that directory's `README.md`.
- The commit's 5-line `shell.qml` activation was **deliberately not carried**.
- With the unique source now on `main`, the `stage3/topbar` branch and the
  `/home/alex/aurora-stage3` worktree were removed locally and remotely. No unique
  source was lost.

There is now **no permanent Stage 3 Git branch** merely storing incomplete source.

---

## 9. Clean-clone verdict

> If the laptop were lost tonight, `AlexbringsMercy/nix` cloned at `main`, only
> documented secrets/machine-local prerequisites restored, and the repo
> instructions followed — would the source needed to reconstruct the intended
> Aurora/NixOS configuration still exist?

Two distinct questions, kept separate:

**(a) Is all project source needed to understand/reconstruct the configuration
represented in Git? — YES.** After finalization, a clone at `main` contains the
complete declarative source — flake, lockfile, host, hardware config, all modules,
all compositor patches, the custom `aurora-minimize` plugin, the full Aurora shell,
the dormant Stage 3 topbar source, theming generators, scripts, the machine-local
wrapper **template** (`hosts/macbook/nixos-local/`), and the full documentation
corpus. The repo self-evaluates `nixosConfigurations.macbook`. Nothing load-bearing
lives only on the laptop anymore.

**(b) Can you rebuild bit-for-bit from the clone alone? — No, and that is by
design.** Two **intentional machine-local prerequisites** must be restored; neither
is missing *source*:

1. **Proprietary T2 firmware** (`/etc/nixos/firmware/brcm`) — restore from backup;
   it cannot appropriately live in Git. Without it, Bluetooth/Wi-Fi firmware is
   absent. Provisioning is documented (`hosts/macbook/nixos-local/README.md`,
   `docs/instructions/recovery.md`).
2. **The live machine-local wrapper** (`~/.config/nixos-local/flake.nix`) — recreate
   by copying the tracked template `hosts/macbook/nixos-local/flake.nix`
   (documented). Or build directly against the repo, accepting `firmwareSource = null`.

### Verdict: **YES** for source completeness — every piece of project source is in Git.

The only things outside Git are the deliberate machine-local prerequisites above
(firmware, plus credentials/runtime state per §6) — documented, not reproducibility
debt. Bit-for-bit reconstruction requires restoring those prerequisites.
