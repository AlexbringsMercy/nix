# Neovim workstation

`nvim` is a Nix-wrapped Neovim 0.12 stable daily driver. Nix owns the binary,
Neovide host, parsers, plugins, language tools, and external viewers; the normal
Lua tree in `config/nvim/` owns behaviour and presentation. No plugin manager,
Mason installation directory, or runtime download is used.

The wrapper is defined in `modules/home/neovim-wrapper.nix` through
`nix-community/nix-wrapper-modules`. It exposes `nvim-neovide` alongside `nvim`;
Home Manager installs the wrapper through `modules/home/neovim.nix`.

The stable editor uses Nix-provided plugins where packaged. The flake pins only
the upstream gaps: Blink v1, Blink Lib/Pairs, lz.n, Gitsigns, Oil, Grug Far,
and Neotest. `lz.n` is an initializer only: it defers command/filetype-driven
tools such as Oil, Neogit, Diffview, Markview, CSV view, tasks, tests, and AI.

An `nvim-edge` can be added cleanly later as a second evaluation of
`neovim-wrapper.nix` with `package` set to a nightly/current Neovim, a distinct
`binName`, aliases disabled, and `settings.dont_link = true`. It is deliberately
not installed yet so the stable executable remains the only daily-driver path.
