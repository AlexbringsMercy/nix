{ pkgs, ... }:
# Alex's general dev "workbench" tooling: CLI utilities, media/image tools,
# a batteries-included Python, Node package manager, and Playwright browsers.
# Deliberately separate from modules/home/packages.nix (desktop/theming
# packages) and modules/home/desktop-apps.nix so this bounded, reusable set
# can be reviewed and rolled back on its own.
let
  workbenchPython = pkgs.python3.withPackages (
    ps: with ps; [
      numpy
      pillow
      requests
      matplotlib
    ]
  );
in
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

    # -- Python (numpy/pillow/requests/matplotlib) --
    # Home Manager links this package's bin/python3 into
    # /etc/profiles/per-user/alex/bin. PATH order on this host puts
    # ~/.nix-profile/bin (the imperative `nix profile` package set, which
    # already has a bare python3 3.13.13 installed via `nix profile
    # install`) ahead of /etc/profiles/per-user/alex/bin, so a plain,
    # non-interactive `python3` lookup keeps resolving to that existing
    # bare interpreter, unchanged — nothing here removes or reorders it.
    # For interactive fish shells (Alex's shell), modules/home/fish.nix
    # adds an explicit alias so `python3` at the prompt gets THIS
    # numpy/pillow/requests/matplotlib interpreter instead.
    workbenchPython

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
