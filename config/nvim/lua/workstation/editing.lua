-- nvim-treesitter's Neovim 0.12 rewrite deliberately moved highlighting and
-- folding to native APIs. Nix supplies parsers/queries; no :TSInstall writes
-- mutable parser state at runtime.
require("nvim-treesitter").setup({})
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldmethod = "expr"
  end,
})

require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true, selection_modes = { ["@function.outer"] = "V" } },
  move = { set_jumps = true },
})
local select = require("nvim-treesitter-textobjects.select")
for lhs, query in pairs({ af = "@function.outer", ["if"] = "@function.inner", ac = "@class.outer", ic = "@class.inner", aa = "@parameter.outer", ia = "@parameter.inner" }) do
  vim.keymap.set({ "x", "o" }, lhs, function() select.select_textobject(query, "textobjects") end, { desc = "Treesitter " .. query })
end
local move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function" })
vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Previous function" })

require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()
require("mini.align").setup()
require("mini.move").setup({ mappings = { left = "<M-h>", right = "<M-l>", down = "<M-j>", up = "<M-k>", line_left = "<M-h>", line_right = "<M-l>", line_down = "<M-j>", line_up = "<M-k>" } })
require("mini.bracketed").setup()

require("flash").setup({ modes = { search = { enabled = false }, char = { enabled = false } } })
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })

require("multicursors").setup({})
require("blink.pairs").setup({ mappings = { enabled = true } })
require("treesitter-context").setup({ max_lines = 3, multiline_threshold = 1, trim_scope = "outer" })
require("ufo").setup({ provider_selector = function(_, _, _) return { "treesitter", "indent" } end })
vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
