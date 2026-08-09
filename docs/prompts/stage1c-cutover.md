# Stage 1C — The cutover: enable aurora-shell, retire the old trees, seed the scheme

You are a Codex execution session for the Aurora build (NixOS + Hyprland, 2020 MacBook Air T2), working in `/home/alex/nix`. Your PM launches, monitors, and reviews you; your final message is a report to them, not to a human bystander. Sessions 1A (vendor) and 1B (scheme defaults) are done; today you make the vendored `modules/home/aurora-shell/` chassis the machine's actual shell and delete the old surfaces it replaces.

**You do FILE WORK ONLY. You do not activate anything.** The PM builds, commits, and pushes; live activation happens later at the Stage 1 visual gate with Alex present. Nothing you do today touches the running desktop — you are editing declarations that only take effect on a future rebuild.

## Mandatory reading, in order, before any other action

1. `/home/alex/nix/SESSION_PREAMBLE.md` — in full. Its rules bind this session. (Read the whole repo/system before writing verdicts; never declare something absent from a partial look.)
2. `/home/alex/nix/GRAND_PLAN.md`: §2.1 chassis decision + fork manifest (lines 43–80), §2.2 process topology — the aurora-shell.service hardening row (lines 82–98), §2.3 target repo layout (lines 100–119), §3.1 palette ladder (lines 131–149) — the seed must reproduce this, and §4 head (lines 211–219).
3. `/home/alex/nix/EXECUTION_LOG.md` — the two "Stage 1 — Chassis" subsections at the end (1A and 1B close-outs). The **1B structural caveat** is why task 5 (the seed) exists: a pre-existing `${XDG_STATE_HOME}/caelestia/scheme.json` overrides the QML fallback, and the CLI's own default scheme is Catppuccin Mocha — without a seed, first light is stock, not aurora.
4. `/home/alex/nix/modules/home/aurora-shell/nix/hm-module.nix` — the module you rename today.
5. `git show 9f64c36` — the 1B commit. It shows exactly which palette values were pinned and on which QML properties. The seed in task 5 must reproduce **those exact hexes** — you do not re-pick colors.

## Scope — Stage 1C only

IN:
- Rename the vendored Home-Manager module option namespace `programs.caelestia` → `programs.aurora-shell` and its systemd unit `caelestia` → `aurora-shell`, applying the §2.2 service hardening.
- Wire that module into **both** Home-Manager evaluation paths and enable it for user `alex`.
- Retire `modules/home/{waybar,rofi,wallpaper,quickshell}` — carrying the keepers listed below out first.
- Seed a clean aurora `scheme.json` so first light is aurora.

OUT (do not touch — later stages):
- Renaming the app's **internal** identifiers. The binary stays `caelestia-shell`, the CLI stays `caelestia`, the config dir stays `~/.config/caelestia/`, the state dir stays `~/.local/state/caelestia/`. Only the **HM option namespace** and the **systemd unit name** change today. (The `aurora` CLI rename lives in a later stage — the CLI is a separate flake input, not vendored.)
- The scheme *generator* clamp (Stage 4), templates, the wallpaper/skwd pipeline (Stage 4), the `modules/home/theming` matugen tree (retires in Stage 4 — leave it in place), hyprbars/window model (Stage 2), the top taskbar (Stage 3), Nexus pruning, any bar layout work.
- Any patch from the fork manifest's "two patches" notes (Nmcli password path, NetworkUsage bugs) — those are later.

## Hard rules

- NO network (sandbox enforces it). NO `nix build`, `nix flake lock/update`, `nix eval`, or any nix evaluation — the PM builds and locks after review. NO `git commit`, NO `git push` — the PM commits and pushes. NO live activation, NO `systemctl`, NO touching the running session.
- `git add` / `git rm` with EXPLICIT paths only; never `git add -A`, `git add .`, or a bare `git rm -r` at repo root.
- `/home/alex/nix/repos/` is READ-ONLY reference material. Never write inside it.
- Minimal diffs. Every line you change or add in an existing file gets an `// Aurora:` or `# Aurora:` marker explaining why. If you find yourself rewriting a file wholesale, stop — that is off the plan; report it instead.
- Attribution style is repo + path only. Do not write any commentary anywhere about any upstream project's terms or status.
- 8 GB machine: use scripts for any bulk operation; do not cat large trees into context.
- Report honestly (§0 rule 5): every deviation, mismatch, forced interpretation, or skipped item goes in your final report. If the code's structure contradicts this prompt, flag it — do not improvise around it silently.

## Tasks

### 1. Investigate first — report your findings in your final message before the edits

Read and map, do not guess:
- **The two HM eval paths.** (a) The NixOS-integrated path: `modules/nixos/base.nix` sets `home-manager.users.alex = import ../../home/alex;` and `extraSpecialArgs = { };`. (b) The standalone path: `flake.nix` `homeConfigurations.alex = home-manager.lib.homeManagerConfiguration { modules = [ ./home/alex ]; }` — this exists so `nix flake check` / the `home-activation` package evaluate without the NixOS graph. **Both must import the aurora-shell HM module or the eval fails on the unknown `programs.aurora-shell` option.** The subflake already exposes it ready-to-import as `inputs.aurora-shell.homeManagerModules.default` (see `modules/home/aurora-shell/flake.nix` last line — `self` is pre-bound, so `self.packages.<sys>.with-cli` and `self.inputs.caelestia-cli` resolve). Confirm how `inputs` is (or is not) currently threaded into `base.nix` (signature is `{ pkgs, ... }`; system `specialArgs` carries `inputs`) and into `home/alex/default.nix`.
- **The scheme.json format.** `modules/home/aurora-shell/services/Colours.qml`: the `FileView` watches `${Paths.state}/scheme.json` (`Paths.state` = `${XDG_STATE_HOME:-~/.local/state}/caelestia`), and `load()` parses `{ name, flavour, mode, colours: { <role>: "<hex-no-#>" } }`, mapping each `colours` key `<role>` → the QML property `m3<role>` (keys starting with `term` are used verbatim). Record the exact key→property rule.
- **What 1B pinned** (`git show 9f64c36`): the M3Palette property defaults that are the fallback palette. Extract the property→hex list; the seed reproduces it exactly (inverse-mapped to `colours` keys by stripping the `m3` prefix).
- **The keeper that lives inside a retiring tree:** `modules/home/quickshell/default.nix` defines `systemd.user.services.aurora-notification-fallback` (the inactive dunst failure fallback) and wires it to the old `aurora-shell.service` via `OnFailure` + an `ExecStartPre` stop. This is the one keeper physically inside a tree you delete — it must be re-created (task 4) before the tree goes.
- **Keepers that already survive:** confirm `equalizer-state` and `weather-fetch` are wired from `modules/home/theming/default.nix` (`home.file.".local/bin/…"`) and the weather cache config from the same module — i.e. they are NOT inside any of the four retiring trees, so retirement does not remove them. State this explicitly (don't assume — verify).

### 2. Rename + harden the HM module (`modules/home/aurora-shell/nix/hm-module.nix`)

- Rename the option namespace `programs.caelestia` → `programs.aurora-shell` throughout (the `mkRenamedOptionModule` import, the `options.programs.caelestia` block, the `cfg = config.programs.caelestia` binding, every internal reference).
- Rename the systemd unit `systemd.user.services.caelestia` → `systemd.user.services.aurora-shell`.
- Apply the §2.2 hardening to that unit so a shell restart never kills user apps and crash-loops are bounded:
  - `[Service]`: `KillMode = "process"`, `SuccessExitStatus = "143"`, `LimitCORE = "0"`, keep `Restart = "on-failure"`, set `RestartSec = "5s"`.
  - `[Unit]`: `StartLimitIntervalSec = 30`, `StartLimitBurst = 3`.
  - Keep the existing `Slice = "session.slice"`, `Type = "exec"`, `ExecStart = "${shell}/bin/caelestia-shell"` (internal binary name — unchanged), and the `X-Restart-Triggers`/`WantedBy`/`PartOf` wiring.
- Do NOT change the `xdg.configFile."caelestia/shell.json"` / `"caelestia/cli.json"` paths — the app reads `~/.config/caelestia/`. Only the HM option namespace and unit name change.
- Every edited line gets an `# Aurora:` marker.

### 3. Thread the module in and enable it

- **NixOS-integrated path:** make `modules/nixos/base.nix` add the module to Home-Manager for all users via `home-manager.sharedModules = [ inputs.aurora-shell.homeManagerModules.default ];`. Thread `inputs` into `base.nix` the minimal way (add it to the module signature — it is present in the system `specialArgs`). Marker-comment the additions.
- **Standalone path:** in `flake.nix`, add the same module to `homeConfigurations.alex`'s `modules` list (`inputs` is in scope in `outputs`). This keeps `nix flake check` and the `home-activation` package evaluating.
- **Enable it** in `home/alex/default.nix`: `programs.aurora-shell.enable = true;` and `programs.aurora-shell.cli.enable = true;`. Set `systemd.environment` only if a value is actually needed (e.g. `QT_QPA_PLATFORMTHEME`) — otherwise leave defaults. Leave `settings = {}` for now (empty settings means no `shell.json` is generated and the `X-Restart-Triggers` stays inert — that is fine at v1; the shell runs on its baked defaults + the seed).

### 4. Retire the four trees — carry the dunst keeper first

Order matters. First **re-create the dunst fallback** so it survives the deletion, then delete.
- Add `systemd.user.services.aurora-notification-fallback` in a surviving location (recommended: fold it into the aurora-shell HM module beside the `aurora-shell` unit, or a small new keepers file imported by `home/alex`). Preserve its semantics: `ExecCondition` = `systemctl --user is-failed aurora-shell.service`, started only on failure, and wire the new `aurora-shell` unit's `[Unit] OnFailure = [ "aurora-notification-fallback.service" ]` + `[Service] ExecStartPre = "-… systemctl --user stop aurora-notification-fallback.service"` (the `-` prefix keeps a failed stop non-fatal), mirroring the old wiring in `modules/home/quickshell/default.nix`.
- **Make the fallback self-contained:** the old unit's `ExecStart` points dunst at `~/.cache/aurora-theme/dunstrc`, which was rendered by the matugen/`apply-wallpaper` pipeline in the retiring `wallpaper` tree. That renderer is going away this stage, so ship a **static minimal dark `dunstrc`** in the repo (e.g. `modules/home/aurora-shell/assets/fallback-dunstrc` or via `xdg.configFile`) and point the fallback at it. It only needs to show notifications when the shell is dead — plain, dark, no palette dependency.
- Confirm `easyeffects`, `equalizer-state`, and `weather-fetch` remain wired from `modules/home/theming/default.nix` (untouched this stage).
- Now retire: remove the `../../modules/home/{waybar,rofi,quickshell,wallpaper}` entries from `home/alex/default.nix`'s `imports`, and `git rm -r` those four directories with explicit paths. Do not touch `theming`, `hyprland`, `kitty`, `lock`, `fish.nix`, `desktop-apps.nix`, `packages.nix`.

### 5. Seed a clean aurora `scheme.json`

- Author a static `scheme.json` whose `colours` map reproduces the **exact** 1B-pinned palette (from task 1 / `git show 9f64c36`): each M3Palette property `m3<role>` → a `colours` key `<role>` with the hex **without** the leading `#`; include the `term0…term15` slots if 1B set them (verbatim keys); `mode: "dark"`, `name: "aurora"`, `flavour`: use whatever 1B/the shell expects (report your choice). Ship the file in the repo (e.g. `modules/home/aurora-shell/assets/aurora-scheme.json`).
- Install it via a Home-Manager `home.activation` step that writes it to `${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json` **only if that file does not already exist** (write-if-absent — the file must stay a mutable regular file, NOT a read-only store symlink, because the shell overwrites it on every future scheme change). Use `run` + `$VERBOSE_ARG` per HM activation conventions; order it after `writeBoundary`.
- Report the full seed JSON in your final message so the PM can diff it against §3.1 and the 1B fallback.

### 6. Static self-checks (no nix eval — the PM builds)

- `git status --short` shows only intended changes; the four trees are staged as deletions; new files staged with explicit paths.
- Sanity-scan your edits: balanced braces in the `.nix` files you touched, valid JSON in the seed (`python3 -m json.tool` or `jq . <file>` is fine — no network, no nix), no stray `programs.caelestia` references left in files you were supposed to rename, and no leftover imports of the deleted trees.
- Do a quick inventory of the shell's IPC targets and global shortcuts (`Shortcuts.qml` / the IPC layer in the vendored tree) and note whether anything references a path/name you changed — you should find nothing broke, since app internals stayed `caelestia`. Report the inventory.

## Final report (your last message — raw data, not prose)

- The task-1 investigation map: the two eval paths and exactly how you threaded the module into each; the scheme.json key→property rule; the 1B property→hex list you extracted; the dunst-keeper wiring you reproduced; the equalizer-state/weather-fetch survival confirmation.
- Every edited or created file with its quoted diff (they should all be small and `# Aurora:`-marked). Quote the full seed JSON and the static fallback dunstrc.
- The exact `home-manager.sharedModules` edit, the `flake.nix` `homeConfigurations.alex` edit, and the `home/alex/default.nix` enable + import-removal edits — quoted.
- `git status --short` proof (deletions + additions), and the JSON-validity check output.
- Any mismatch between the on-disk reality and this prompt's description, anything you had to interpret, and anything you could not complete — stated plainly.
