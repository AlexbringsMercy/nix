require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" }, nix = { "nixfmt" }, javascript = { "biome" }, javascriptreact = { "biome" }, typescript = { "biome" }, typescriptreact = { "biome" }, json = { "biome" },
    python = { "ruff_format" }, sh = { "shfmt" }, bash = { "shfmt" }, zsh = { "shfmt" }, toml = { "taplo" }, yaml = { "prettierd" }, markdown = { "prettierd" },
  },
})

local lint = require("lint")
lint.linters_by_ft = {
  python = { "ruff" }, sh = { "shellcheck" }, bash = { "shellcheck" }, zsh = { "shellcheck" }, javascript = { "biomejs" }, typescript = { "biomejs" }, json = { "biomejs" },
}
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then lint.try_lint() end
  end,
})
