{ pkgs, ... }:
# Docker CLI/compose/buildx, Kubernetes, IaC, cloud provider CLIs, deploy
# targets, and secrets tooling from Alex's workstation tooling plan. Split out
# from modules/home/dev-toolchain.nix because this category is the heaviest
# (multiple cloud SDKs) and the one most likely to get pruned later if disk
# pressure shows up — easy to drop this one import to shed weight.
#
# The Docker *daemon* (virtualisation.docker.enable) and alex's membership in
# the docker group are system-level, in modules/nixos/dev-virtualisation.nix
# — not here. This module only adds the CLI/compose/buildx front ends.
{
  home.packages = with pkgs; [
    # -- CONTAINERS --
    docker-compose
    docker-buildx

    # -- KUBERNETES --
    kubectl
    kubernetes-helm
    kustomize
    kind
    k3d
    k9s
    stern

    # -- IaC --
    opentofu # drop-in terraform-compatible CLI; cached
    # terraform: this nixpkgs snapshot has no cached go-modules build for
    # 1.15.6 on x86_64-linux — installing it would compile Go from source
    # (confirmed via nixos-rebuild dry-build against an empty store: it
    # showed up as a real, non-trivial "will be built" derivation, not just
    # a wrapper). Dropped per the no-source-builds rule. opentofu above is
    # the cached, license-compatible substitute; get the real binary later
    # with the official HashiCorp installer, or `mise use terraform@latest`.
    # packer: same problem (uncached go-modules build). `mise use
    # packer@latest`, or the official HashiCorp installer, later.
    ansible
    bazelisk

    # -- CLOUD PROVIDER CLIs --
    awscli2
    azure-cli
    google-cloud-sdk
    oci-cli

    # -- DEPLOY TARGETS --
    wrangler
    firebase-tools
    netlify-cli
    supabase-cli
    # vercel: not in this nixpkgs snapshot — `pnpm add -g vercel`.

    # -- API TOOLING --
    openapi-generator-cli
    # redocly-cli, spectral: not in this nixpkgs snapshot —
    #   `pnpm add -g @redocly/cli @stoplight/spectral-cli`.
    # schemathesis: not in this nixpkgs snapshot (python3Packages or
    #   top-level) — `uv tool install schemathesis`.

    # -- SECRETS --
    sops
    age
    gnupg
    bitwarden-cli # Alex's actual password manager wasn't specified; this is
    # the one named in the plan. If he uses something else, swap this attr.
    dotenvx
  ];
}
