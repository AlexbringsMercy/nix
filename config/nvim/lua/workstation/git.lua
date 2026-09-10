require("gitsigns").setup({
  current_line_blame = false,
  sign_priority = 6,
  signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" }, topdelete = { text = "‾" }, changedelete = { text = "▎" } },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "<leader>ghs", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
    vim.keymap.set("n", "<leader>ghr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
    vim.keymap.set("n", "<leader>ghp", gs.preview_hunk, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))
  end,
})
