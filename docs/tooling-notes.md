# Workstation tooling notes

Pins/exceptions for the 2026-09-08 "CLI-agent workstation tooling" expansion.
Full inventory with versions: `docs/workstation-tool-manifest.json`.

## Where things live

- `modules/home/dev-toolchain.nix` — source control, search/text/data,
  exec/productivity, native build, language runtimes (Python/Node/Rust/Go/
  other), web/browser extras, network basics, databases, docs/media,
  LSP/format, obvious basics.
- `modules/home/security-tooling.nix` — QA/security/supply-chain scanners,
  RE/debug tools, network recon (nmap/tshark/mitmproxy/nuclei/etc).
- `modules/home/cloud-infra.nix` — docker CLI/compose/buildx, Kubernetes,
  IaC, cloud provider CLIs, deploy targets, secrets tooling.
- `modules/home/workbench.nix` — the original smaller bounded set from
  earlier the same day (ripgrep/fd/jq/ffmpeg-full/imagemagick/pnpm/
  playwright-driver.browsers/ookla-speedtest).
- `modules/home/lib/workstation-python.nix` — single source of truth for the
  Python toolbox package list; imported by both `dev-toolchain.nix` (the
  actual `home.packages` entry) and `fish.nix` (the interactive `python3`
  alias) so there is never more than one `python3.withPackages` derivation
  in the profile.
- `modules/nixos/dev-virtualisation.nix` — the system-level half: Docker
  daemon + `docker` group, `programs.wireshark.enable` + `wireshark` group
  for non-root `tshark`, and the extra font packages.

Each home module is a separate import in `home/alex/default.nix` — drop one
import line to shed that whole category later if disk pressure returns.

## python3 shadowing (pre-existing, not touched)

`~/.nix-profile/bin` (an imperative `nix profile install` package set that
already has a bare `python3` 3.13.13, no extra packages) sits earlier in
`$PATH` than Home Manager's `/etc/profiles/per-user/alex/bin`. A plain,
non-interactive `python3` lookup keeps resolving to that pre-existing bare
interpreter — nothing here removed or reordered it. `modules/home/fish.nix`
adds an explicit `python3` alias for interactive fish shells only, pointing
at the workstation toolbox interpreter (numpy/pandas/polars/... — see
`modules/home/lib/workstation-python.nix`).

## rustup

`rustup` itself is installed, but it does not pre-select a toolchain. Run
**`rustup default stable`** once, after the rebuild completes, to actually
get a working `rustc`/`cargo`.

## Disk-budget cuts (2026-09-08)

An initial verification build of the *full* combined package set (before
any cuts) pushed `/` from ~50 GB free to 14 GB free — over Alex's 15 GB
floor — because `nix build` (used deliberately, to catch package-name
collisions before touching the live system) actually realizes the closure,
not just evaluates it. The coordinator ran `nix-collect-garbage`, which
reclaimed 63.7 GB (root is back to ~80 GB free). Two lessons encoded into
the actual rules going forward, not just this file:

1. Verification from here on is evaluation-only (`nix flake check`,
   `nixos-rebuild dry-build`) — never a real `nix build`/`nix-store
   --realize` of the whole closure. `workbench-rebuild.sh` still does the
   real fetch, but only inside Alex's own sudo window, once.
2. The following were cut to keep the *added* closure (measured via
   `nixos-rebuild dry-build` against the live, post-GC store) at **27.1 GiB
   unpacked / 7.9 GiB download**, under the 30 GB budget:
   - `dotnet-sdk_10`, `temurin-bin-17` (kept `temurin-bin-21` only)
   - `inkscape` (pulls a large GTK/graphics stack)
   - `awscli2`, `azure-cli`, `google-cloud-sdk` (kept `oci-cli`; each of the
     three cut ones drags a large Python dependency tree)

   See `docs/workstation-tool-manifest.json`'s `skipped` list for the
   `uv tool install` / `pip install` / vendor-installer one-liners to get
   any of these back later.

## Local-source-build exclusions (not disk, correctness)

Two packages were dropped not for size but because this exact nixpkgs
snapshot (`567a49d1913ce81ac6e9582e3553dd90a955875f`) has no cached binary
for them on `x86_64-linux` — installing them would silently compile Go (or
Rust) from source on a 7.6 GB RAM machine, which is exactly the failure
mode the no-local-builds rule exists to prevent:

- **`terraform`** — no cached `go-modules` build. `opentofu` (drop-in
  compatible, cached) is installed instead. Get the real binary later via
  HashiCorp's own installer or `mise use terraform@latest`.
- **`packer`** — same problem. `mise use packer@latest`, or HashiCorp's
  installer, later.
- **`nix-index`** — no cached build (would compile Rust). `cargo binstall
  nix-index` later, or wait for a nixpkgs snapshot that has it cached.
  `comma` is still installed (it's cached fine on its own) but is less
  useful without nix-index's database until this is revisited.

Verification method: `nixos-rebuild dry-build` against a scratch **empty**
Nix store (`--store /path/to/empty-dir`), so the "will be built" list can't
be hiding behind whatever happens to already be locally cached. Anything
showing up there as a real package (not a `-fish-completions`/`.patch.drv`/
NixOS-activation-script wrapper) got cut or fixed.

## Skipped — Windows-only or explicitly out of scope

- `burpsuite` — unfree and large; `zap` (OWASP ZAP) installed instead.
- `libreoffice`, `calibre` — large downloads, skipped per the plan's own
  size caveat; add back to `dev-toolchain.nix` if actually needed.
- `ghidra` — large download, deliberately deferred to a Phase 2 pass.
- `imhex`, `ilspycmd` — "skip if large / unless cheap" per the plan; not
  attempted.
- `frida-tools`, `camoufox`, `crawl4ai`, `schemathesis` — deliberately
  deferred to `uv tool install` / `uv pip install`, per the plan.
- `pa11y`, `knip`, `vercel`, `redocly-cli`, `spectral` — not present in
  this nixpkgs snapshot; `pnpm add -g <name>` later.

## Explicitly NOT started

Per instruction, none of the "agent-native repositories" (Serena, Obelisk,
claude-mem, SDL-MCP, Deepcrawl, Stealth Browser MCP, x-tweet-fetcher, REA,
Scenario Lab, OpenConnector, Claw Compactor) were touched. Separate
follow-up, after this rebuild lands.

## bitwarden-cli

Alex's actual password manager wasn't specified in the plan; `bitwarden-cli`
is installed because that's the specific one the plan named. Swap the attr
in `modules/home/cloud-infra.nix` if he uses something else.
