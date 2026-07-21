#!/usr/bin/env bash
set -euo pipefail

repo=${1:-/home/alex/nix}
local_flake=${2:-/home/alex/.config/nixos-local}
repo_ref="path:$repo"
local_ref="path:$local_flake"

git -C "$repo" diff --check HEAD --
nix flake check "$repo_ref" --no-build --show-trace --max-jobs 2 --cores 2

# Aurora: the legacy wallpaper option retired in Stage 1C; Stage 4 adds the skwd-wall gate.

out=$(nix build --no-link --print-out-paths \
  "$local_ref#nixosConfigurations.macbook.config.system.build.toplevel" \
  --override-input macbook-config "$repo_ref" \
  --override-input firmware path:/etc/nixos/firmware \
  --max-jobs 2 --cores 2)

closure=$(nix-store -q --requisites "$out")
for required in linux-t2 brcm-firmware quickshell nix-ld; do
  if ! grep -F "$required" <<<"$closure" >/dev/null; then
    printf 'FAIL: required closure component is missing: %s\n' "$required" >&2
    exit 1
  fi
done

if git -C "$repo" ls-files | grep -E 'firmware/brcm|\.bin$|\.ptb$|clm_blob|txcap_blob'; then
  echo "FAIL: proprietary firmware is tracked" >&2
  exit 1
fi

if git -C "$repo" ls-files assets/wallpapers | grep -q .; then
  echo "FAIL: personal wallpaper images are tracked" >&2
  exit 1
fi

printf 'Preflight passed: %s\n' "$out"
