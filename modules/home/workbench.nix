{ pkgs, ... }:
# Alex's general dev "workbench" tooling: CLI utilities, media/image tools,
# Node package manager, and Playwright browsers. Deliberately separate from
# modules/home/packages.nix (desktop/theming packages) and
# modules/home/desktop-apps.nix so this bounded, reusable set can be reviewed
# and rolled back on its own.
#
# The batteries-included Python toolbox that used to live here moved to
# modules/home/dev-toolchain.nix (modules/home/lib/workstation-python.nix is
# now its single source of truth) as part of the broader workstation-tooling
# expansion — keeping only one python3.withPackages derivation in the profile
# avoids a bin/python3 collision between two differently-scoped ones.
{
  home.packages = with pkgs; [
    # -- CLI tooling --
    ripgrep # already resolves on PATH via a transitive dep; declared explicitly so it survives that dep going away
    fd
    jq # already resolves on PATH via a transitive dep; declared explicitly for the same reason
    tree
    htop
    unzip
    p7zip
    sqlite
    ncdu
    mediainfo

    # -- Media / imaging --
    ffmpeg-full # provides ffmpeg + ffprobe
    imagemagick # provides magick / convert
    libwebp
    oxipng

    # -- Node tooling (nodejs_22 stays system-level in modules/nixos/base.nix) --
    pnpm

    # -- Playwright --
    playwright-driver.browsers

    # -- Network diagnostics (bridge Network page; refuses substitutes) --
    ookla-speedtest
  ];

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";
  };
}
