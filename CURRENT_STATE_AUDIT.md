# CURRENT STATE AUDIT — 2026-07-29, generation 31

> ## ⚠ OUT OF DATE — the machine is now on generation 32, which PHYSICALLY FAILED
>
> This file is a **generation 31** snapshot taken on the afternoon of 2026-07-29. The
> machine was subsequently rebooted into **generation 32**
> (`62aim1mw2c26siwlymv9r5xa0qqa5ryw`), which passed the automated structural gate
> 41/41 and then **failed the physical operator gate on ten distinct defects**.
>
> For current ground truth read **`PM_HANDOFF_GEN32_HARD_FAIL_2026-07-29.md`**, and start
> from **`PM_KICKOFF_GEN32_RECOVERY_2026-07-29.md`**. Verify the machine live rather than
> trusting either file.
>
> Stage 2 is **OPEN**. The operator gate was **stopped**. No Stage 3 deployment is
> permitted. Generation 31 is comparison evidence only, **not** an accepted fallback.

**Established from the live machine and repository on 2026-07-29, afternoon.**
Supersedes the 2026-07-28 / generation-26 snapshot, archived intact at
`archive/superseded-docs/2026-07-29/CURRENT_STATE_AUDIT-2026-07-28-gen26.md`.
No generation claim in this file is copied forward from that document — every
number below was re-read from the machine.

**Stage status: `STAGE 2 — OPEN`.**

---

## 0. How to read this file

Seven states are distinct and never collapsed: **written · built · installed ·
activated · tested · passed · accepted**. A row that is `written` is not
progress toward `built`; it is only written. Any check not actually run is
`UNVERIFIED`, never blank and never an implied pass.

---

## 1. Repository

| Fact | Value | Evidence |
|---|---|---|
| Branch | `codex/macbook-desktop` | `git branch -vv` |
| HEAD | `39a5285` — "stage2: correction batch for the failed runtime gate" | `git log -1` |
| Sync with origin | **0 ahead / 0 behind** | `git rev-list --left-right --count origin/codex/macbook-desktop...HEAD` |
| Tree state before this session's documentation work | Clean except a deleted `GRAND_PLAN.md` and the operator's supplied revision file | `git status --porcelain` |
| Worktrees | `/home/alex/nix` (Stage 2) · `/home/alex/aurora-stage3` on `stage3/topbar` @ `dbd3c72` | `git worktree list` |

Stage 3 work is correctly isolated in its own worktree and is **not** in the
Stage 2 closure.

---

## 2. Generations and boot state

| Fact | Value | Evidence |
|---|---|---|
| `/run/current-system` | `wirdp0v9…-nixos-system-macbook` | `readlink -f` |
| `/run/booted-system` | `wirdp0v9…` — **identical** | `readlink -f` |
| `/nix/var/nix/profiles/system` | `system-31-link` → `wirdp0v9…` | `readlink -f` |
| Newest generation on disk | **31**, created 2026-07-29 06:06 | `ls -l /nix/var/nix/profiles/` |
| Bootloader default entry | `nixos-94a953e9…conf`, written 06:06 — the generation-31 entry | `/boot/loader/loader.conf` |
| Fallback | **generation 26** → `92bdqiip…`, 2026-07-21 23:03 | `ls -l /nix/var/nix/profiles/` |
| Failed system units | **none** | `systemctl --failed` |
| Failed user units | **none** | `systemctl --user --failed` |

Current, booted and profile-default all agree on generation 31. There is no
generation 32, and no newer entry in `/boot/loader/entries/`.

---

## 3. The question the previous session left open: did the correction build run?

**No. It did not complete, did not stage, and is not running.** The evidence is
consistent across five independent checks:

| Check | Result |
|---|---|
| Any `nixos-rebuild` / `nix build` process alive | **None** — `ps aux` shows no build process |
| Newer generation | **None** — 31 is the newest link and the newest boot entry |
| Nix temporary GC roots | All five holder PIDs (`31968`, `34108`, `34127`, `34141`, `34174`) are **dead**; the roots are stale leftovers |
| Current-source system closure present in the store | **No.** Current source evaluates to `dw6iv3h1…drv`, whose output `sscnkxwacl30fnvm13szywd877v7pdl8-nixos-system-macbook` **does not exist** |
| Timeline | Generation 31 was built at **06:06**; the correction commits land **06:53 – 07:23** — every one of them postdates the generation |

**Conclusion:** the correction batch is **written and committed only**. Nothing
from it has been built, installed, activated or tested. There is no reusable
post-generation-31 closure to salvage, so nothing is being rebuilt for
bookkeeping — the build genuinely has not happened yet.

---

## 4. Compositor: the next build is expensive, and reuse is not available

| Fact | Value |
|---|---|
| Running compositor | Hyprland 0.55.4 (`hyprctl version`), commit `a0136d8c` |
| Patched output in generation 31 | `wrz9r718…-hyprland-0.55.4` (2 patches: drag-anchor, deco-border-grab) |
| Hyprbars in generation 31 | `8s56v8nb…-hyprbars-0.55.0` |
| Patch set now declared in `flake.nix` | **3** patches — the above two **plus** `hyprland-dwindle-resize-workarea.patch`, added 2026-07-29 07:16 (commit `fc78ebe`) |

**The `wrz9r718…` compositor output cannot be reused.** The PM rule is to check
the patch list rather than the calendar, and the patch list genuinely changed
after generation 31 was built. The third patch alters `pkgs.hyprland`, so
Hyprland rebuilds and **hyprbars rebuilds against it in the same closure** —
they cannot be deployed separately without ABI drift. The next closure is
therefore an hour-class compositor build and must run in a detached
`systemd-run --user` unit, not a tool-managed background task.

---

## 5. Shell and desktop runtime

| Fact | Value |
|---|---|
| Shell process | `quickshell-wrapped-0.3.0` running `caelestia-shell-1.0.0` from `4fdw4s3v…` |
| Compositor | Hyprland 0.55.4, running, no safe-mode indication |
| Failed units | none, system or user |

---

## 6. Agent CLI resolution — the protected-state regression

Read live this session. **The operator's reported symptom has partly resolved
itself on disk, but the underlying invariant is still not declared anywhere and
remains fragile.** Both halves matter.

### What resolves today

| Command | Resolves to | Version |
|---|---|---|
| `claude` | `/home/alex/.local/bin/claude` → `/home/alex/.local/share/claude/versions/2.1.220` | **2.1.220** — the newer, self-managed lane |
| `codex` | `/home/alex/.local/bin/codex` → `~/.codex/packages/standalone/current` → `releases/0.145.0-x86_64-unknown-linux-musl` | **0.145.0** |

`/home/alex/.npm-global/bin/` is **empty** — the stale `claude` shim that was
winning PATH resolution no longer exists (directory mtime 2026-07-29 16:07).
The package trees `~/.npm-global/lib/node_modules/@anthropic-ai` and
`@openai` **do still exist** and are untouched.

**Codex's canonical lane, established from the machine rather than assumed:** a
self-managed standalone release tree under `~/.codex/packages/standalone/`
with a `current` symlink and an `install.lock`. Configuration, credentials and
history live in `~/.codex/` (`auth.json`, `config.toml`, `history.jsonl`,
`logs_2.sqlite`, `installation_id`). Nixpkgs does not own Codex.

### Why it is still broken as an invariant

PATH ordering is currently **not declared** — `.local/bin` wins only by accident
of three non-Nix sources, and one of them actively inverts it:

| Source | Effect | Managed by |
|---|---|---|
| `home.sessionPath` (`home/alex/default.nix:19`) | prepends **`.npm-global/bin` only** | **Nix/HM** |
| `~/.profile` — `# >>> Codex installer >>>` block | prepends `.local/bin` **before** HM runs, so HM's prepend lands on top of it | Codex installer |
| `~/.config/fish/fish_variables` — `SETUVAR fish_user_paths` | prepends `.local/bin` | mutable fish universal variable |
| `~/.bashrc` (42 bytes, **not** HM-managed) | prepends `.npm-global/bin` **last**, so it wins in bash | leftover |

Measured result — the ordering differs by session type, which is exactly the
non-determinism the operator decision forbids:

| Session | Order | Verdict |
|---|---|---|
| This graphical session's inherited environment | `.npm-global/bin` **before** `.local/bin` | **wrong order** |
| Fresh `fish -l` | `.local/bin` first | right, by accident |
| Fresh `bash -lc` | `.local/bin` first, but `~/.bashrc` re-inverts it for interactive bash | fragile |
| `systemctl --user show-environment` | `.local/bin`, no npm-global at all | right |

Had the npm-global shim still existed, the graphical session would still be
resolving the older 2.1.211. **The correction is therefore still required**, and
is written into this closure (§7).

---

## 7. Written-but-not-built work in the tree

Committed after generation 31, so present in source and absent from every
generation:

| Item | Files | State |
|---|---|---|
| Tiled corner resize (dwindle work-area patch) | `modules/nixos/patches/hyprland-dwindle-resize-workarea.patch`, `flake.nix` | written |
| Deterministic snap | `modules/home/hyprland/hyprland/keybinds.lua` | written |
| Rail previews / grouped apps | `modules/home/aurora-shell/modules/bar/components/AppRail.qml`, `RailTile.qml`, `popouts/RailGroupPreview.qml`, `popouts/Wrapper.qml`, `Bar.qml` | written |
| Rail scroll scoping (brightness-to-zero) | `AppRail.qml`, `Bar.qml` | written |
| Floating hover focus (`float_switch_override_focus = 0`) | `modules/home/hyprland/hyprland/input.lua` | written |
| Screenshot toolbar + focus restoration | `modules/areapicker/Toolbar.qml`, `AreaPicker.qml`, `Picker.qml`, `services/Screenshotter.qml` | written |
| Boot readiness / time sync | `modules/nixos/base.nix`, `scripts/aurora-resume-agent` | written |
| **Agent PATH invariant** (this session) | `home/alex/default.nix`, `modules/home/fish.nix` | written, **HM eval passes** |

Home Manager evaluation of the PATH change succeeded
(`home-manager-generation.drv` resolved), so the change is type- and
syntax-valid. It is **not** built and **not** activated.

---

## 8. Known open debts

- **Wallpaper picker has no ordinary mouse path.** Operator ruling: non-blocking
  for Stage 2, temporary until Stage 4 installs the final skwd workflow. Recorded,
  not being worked around with throwaway UI.
- **Stage 0 physical debts:** TV reachability and Xbox controller pairing, both
  deferred at the Stage 0 gate and never run. Inference-backed, not test-backed.
- **Stage 1 debt:** VA-API / iHD encode verification (`vainfo` is not in the closure).
- **Persistent NixOS default boot** (decision 23) is an operator physical action at
  the next reboot, verified only on the **following** cold boot.
- **npm-global package trees** for `@anthropic-ai` and `@openai` remain on disk.
  Per the operator decision, duplicates are neutralized only after the canonical
  path is proven live post-reboot.

---

## 9. What this audit does not claim

- No runtime behaviour of the correction batch is verified — none of it has run.
- The nine correction items are **source-reviewed as committed**, not built,
  activated, or physically tested.
- The previous session's claim that "all relevant QML/Lua/shell/Nix files parsed"
  is **not** carried forward as fact; the Nix evaluation paths are being re-run in
  this closure, and QML/Lua parse status is re-established at build time.
