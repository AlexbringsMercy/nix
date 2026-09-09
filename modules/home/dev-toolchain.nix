{ pkgs, lib, ... }:
# Alex's "CLI-agent workstation tooling" plan (2026-09-08 scope expansion),
# general-purpose language/build/runtime/LSP slice. Security/supply-chain/RE
# tooling lives in modules/home/security-tooling.nix and docker/k8s/cloud-IaC
# tooling in modules/home/cloud-infra.nix — split so each bounded category can
# be reviewed, disabled, or rolled back independently. See
# /home/alex/nix/docs/tooling-notes.md for pins/exceptions and
# /home/alex/nix/docs/workstation-tool-manifest.json for the full inventory
# with versions.
{
  home.packages = with pkgs; [
    # -- SOURCE CONTROL --
    git-lfs
    git-filter-repo
    delta
    difftastic
    lazygit
    git-sizer
    git-cliff
    git-absorb
    pre-commit
    jujutsu
    glab
    git-crypt

    # -- SEARCH / TEXT / DATA --
    ripgrep-all
    fzf
    bat
    eza
    zoxide
    broot
    yazi
    yq-go
    dasel
    gron
    fx
    jless
    htmlq
    xmlstarlet
    csvkit
    qsv
    miller
    visidata
    sd
    choose
    tokei
    scc
    universal-ctags
    tree-sitter
    ast-grep

    # -- EXEC / PRODUCTIVITY --
    hyperfine
    just
    go-task
    watchexec
    mprocs
    process-compose
    dust
    duf
    procs
    bottom
    aria2
    xh
    httpie
    hurl
    grpcurl
    websocat
    caddy
    miniserve
    dufs
    rclone
    restic
    zstd
    xz
    brotli
    ouch
    rsync
    socat
    moreutils
    parallel
    entr
    tmux

    # -- NATIVE BUILD --
    gcc
    # clang ships its own bin/cc, c++, cpp and ld wrappers, which collide
    # with gcc's in home-manager's unified profile buildEnv ("two given
    # paths contain a conflicting subpath", rebuild attempt 2026-09-09).
    # gcc owns those generic names; clang is kept at low priority so clang,
    # clang++, clang-cl etc. stay on PATH under their own names.
    # llvmPackages_latest.clang is NOT installed: its bin/cc collides with gcc's in
    # the profile buildEnv even at low priority (rebuild attempts 2026-09-09).
    # clangd/clang-format come from clang-tools; use `nix shell nixpkgs#clang` when
    # a repo needs the clang driver itself.
    llvmPackages_latest.clang-tools # clangd + clang-format
    (lib.lowPrio llvmPackages_latest.lld)
    # llvmPackages_latest.libclang is the unwrapped clang package: its bin/ (cpp,
    # clang-doc, …) collides with gcc and clang-tools in the profile. Library-only
    # consumers get it per project (`nix shell nixpkgs#llvmPackages_latest.libclang`).
    cmake
    ninja
    meson
    gnumake
    nasm
    yasm
    perl
    pkg-config
    sccache
    mold
    autoconf
    automake
    libtool
    gdb
    lldb
    valgrind
    strace
    ltrace
    perf # was `linuxPackages.perf`; nixpkgs now aliases it to a generic build.
    # Perf's ABI is version-sensitive to the *running* kernel — this generic
    # build may warn/mismatch against this T2 host's exact kernel; treat it
    # as best-effort, not guaranteed to attach cleanly.
    patchelf
    # binutils is not listed: gcc-wrapper already exposes ld/as/ar/objdump/strings/…
    # and both wrappers sit at meta.priority 10, so they cannot coexist in the profile.
    protobuf
    buf
    flatbuffers
    conan
    vcpkg
    openssl
    zlib
    icu
    libxml2
    libxslt
    postgresql # server package; also provides libpq + psql client

    # -- PYTHON (uv is the primary per-project manager; the withPackages
    #    toolbox below is the general-purpose interpreter for ad hoc
    #    scripts/notebooks — see modules/home/lib/workstation-python.nix) --
    uv
    (lib.lowPrio (python3.withPackages (import ./lib/workstation-python.nix))) # standalone CLIs (httpx, playwright) win over the env's scripts
    pip-audit

    # -- NODE (nodejs_22 stays system-level, modules/nixos/base.nix) --
    fnm
    bun
    deno
    typescript-language-server
    biome
    lighthouse
    svgo
    mermaid-cli
    marp-cli
    repomix
    npm-check-updates
    web-ext
    prettier
    # pa11y, knip: not in this nixpkgs snapshot — `pnpm add -g pa11y knip`.

    # -- RUST (rustup manages toolchains; run `rustup default stable`
    #    once after this rebuild completes) --
    rustup
    (lib.lowPrio rust-analyzer) # rustup's proxy owns bin/rust-analyzer
    cargo-binstall
    cargo-nextest
    cargo-watch
    cargo-edit
    cargo-audit
    cargo-deny
    cargo-outdated
    cargo-machete
    cargo-llvm-cov
    cargo-expand
    cargo-bloat
    cargo-generate
    cargo-msrv
    cargo-cross # nixpkgs attr for the `cross` cross-compilation tool
    wasm-pack
    wasm-bindgen-cli

    # -- GO --
    go
    gopls
    golangci-lint
    go-tools # provides `staticcheck`
    gotestsum
    goreleaser
    delve
    govulncheck
    gofumpt

    # -- OTHER LANGUAGE RUNTIMES --
    dotnet-sdk
    temurin-bin-21
    (lib.lowPrio temurin-bin-17) # java/javac/jar belong to temurin-bin-21; 17 stays reachable via its store path or mise
    maven
    gradle
    kotlin
    jdt-language-server
    ruby
    php
    phpPackages.composer
    zig
    lua5_4
    (lib.lowPrio luajit) # `lua` is PUC Lua; luajit stays reachable as `luajit`
    rWrapper
    mise

    # -- WEB / BROWSER (playwright-driver.browsers + env vars already in
    #    modules/home/workbench.nix; google-chrome is system-level) --
    playwright-test
    chromium
    firefox

    # -- NETWORK (non-offensive basics; recon/pentest tools are in
    #    modules/home/security-tooling.nix) --
    mkcert
    step-cli
    iperf3
    mtr
    dnsutils # provides `dig`
    doggo
    tailscale
    wireguard-tools
    cloudflared
    k6
    oha
    vegeta

    # -- DATABASES --
    duckdb
    mariadb # client tools; server unused, not enabled as a service
    redis
    mongosh
    usql
    pgcli
    litecli
    sqlfluff
    atlas
    dbmate

    # -- DOCS / MEDIA --
    mkvtoolnix-cli
    yt-dlp
    gallery-dl
    sox
    handbrake
    mpv
    vips
    exiftool
    gifski
    gifsicle
    libavif
    pngquant
    resvg
    inkscape
    libreoffice-fresh
    calibre
    potrace
    pandoc
    typst
    ghostscript
    qpdf
    mupdf
    poppler-utils
    pdfcpu
    tesseract
    ocrmypdf
    graphviz
    plantuml
    d2
    chafa
    asciinema
    agg
    vhs
    silicon
    # noto-fonts-cjk-sans, liberation_ttf, dejavu_fonts: system-level
    # fonts.packages in modules/nixos/dev-virtualisation.nix, not here.

    # -- LSP / FORMAT --
    pyright
    lua-language-server
    bash-language-server
    yaml-language-server
    taplo
    marksman
    dprint
    stylua
    omnisharp-roslyn
    nixfmt # interactive `nixfmt`; the flake's own formatter output uses nixfmt-tree

    # -- OBVIOUS BASICS the plan omitted --
    file
    less
    which
    lsof
    pciutils
    usbutils
    inetutils
    netcat-gnu
    iproute2
    psmisc
    man-pages
    plocate
    nix-tree
    # nix-index: not installed — this nixpkgs snapshot has no cached build
    # for it (confirmed via the same empty-store dry-build check), so it
    # would compile Rust from source. Recommended but skipped per the
    # no-source-builds rule; `cargo binstall nix-index` or a future nixpkgs
    # snapshot later. `comma` (below) is cached fine on its own, it's just
    # less useful without nix-index's database until that's addressed.
    comma
    nil # Nix LSP
    direnv
    nix-direnv
  ];
}
