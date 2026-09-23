{
  inputs,
  config,
  wlib,
  pkgs,
  lib,
  ...
}:
let
  blinkPairsNative = pkgs.rustPlatform.buildRustPackage {
    pname = "blink-pairs-native";
    version = "0.6.0";
    src = inputs.plugin-blink-pairs;
    cargoHash = "sha256-XLlluprxhVueHhkIufJa7fJXvFxpJJzh89+yL9PZ4GI=";
    doCheck = false;
    installPhase = ''
      mkdir -p "$out/lib"
      library=$(find target -type f -name libblink_pairs_parser.so -print -quit)
      test -n "$library"
      cp "$library" "$out/lib/"
    '';
  };

  upstream = {
    blink-cmp = config.nvim-lib.mkPlugin "blink.cmp" inputs.plugin-blink-cmp;
    blink-lib = config.nvim-lib.mkPlugin "blink.lib" inputs.plugin-blink-lib;
    blink-pairs = (config.nvim-lib.mkPlugin "blink.pairs" inputs.plugin-blink-pairs).overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        mkdir -p "$out/lib"
        cp ${blinkPairsNative}/lib/libblink_pairs_parser.so "$out/lib/"
      '';
    });
    lz-n = config.nvim-lib.mkPlugin "lz.n" inputs.plugin-lz-n;
    gitsigns = config.nvim-lib.mkPlugin "gitsigns.nvim" inputs.plugin-gitsigns;
    oil = config.nvim-lib.mkPlugin "oil.nvim" inputs.plugin-oil;
    grug-far = config.nvim-lib.mkPlugin "grug-far.nvim" inputs.plugin-grug-far;
    neotest = config.nvim-lib.mkPlugin "neotest" inputs.plugin-neotest;
  };
in
{
  imports = [ wlib.wrapperModules.neovim ];

  package = pkgs.neovim-unwrapped;
  binName = "nvim";
  settings.config_directory = ../../config/nvim;
  hosts.neovide.nvim-host.enable = true;

  # `start` contains the small set that establishes the visual shell and
  # editor semantics. Command/filetype-driven integrations live in `opt` and
  # are activated by lz.n from Lua.
  specs = {
    foundation.data = with pkgs.vimPlugins; [
      catppuccin-nvim
      snacks-nvim
      heirline-nvim
      dropbar-nvim
      mini-nvim
      which-key-nvim
      (nvim-treesitter.withPlugins (
        parsers: with parsers; [
          bash
          css
          csv
          html
          javascript
          json
          lua
          markdown
          markdown_inline
          nix
          python
          regex
          toml
          tsx
          typescript
          vim
          vimdoc
          yaml
        ]
      ))
      nvim-treesitter-textobjects
      flash-nvim
      multicursors-nvim
      nvim-ufo
      nvim-treesitter-context
      nvim-lspconfig
      friendly-snippets
      tiny-inline-diagnostic-nvim
      trouble-nvim
      conform-nvim
      nvim-lint
      inc-rename-nvim
      nvim-dap
      nvim-dap-view
      neotest-python
      neotest-jest
      upstream.blink-cmp
      upstream.blink-lib
      upstream.blink-pairs
      upstream.lz-n
      upstream.gitsigns
    ];

    lazy = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        upstream.oil
        upstream.grug-far
        neogit
        diffview-nvim
        markview-nvim
        csvview-nvim
        upstream.neotest
        overseer-nvim
        persistence-nvim
        todo-comments-nvim
        sidekick-nvim
      ];
    };
  };

  runtimePkgs = with pkgs; [
    # Search, Git, and native parser support.
    git
    gh
    ripgrep
    fd
    fzf
    tree-sitter
    gcc
    gnumake

    # The machine already has the broad toolchain; these are the editor-owned
    # language endpoints so `nvim` is self-contained and reproducible.
    nixd
    lua-language-server
    vtsls
    vscode-langservers-extracted
    yaml-language-server
    bash-language-server
    basedpyright
    tailwindcss-language-server
    marksman
    stylua
    nixfmt
    biome
    prettierd
    ruff
    shfmt
    shellcheck
    taplo

    # Neovide uses external viewers instead of terminal graphics protocols.
    swayimg
    mupdf
    mpv
    xdg-utils
  ];
}
