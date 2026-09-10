local group = vim.api.nvim_create_augroup("Workstation", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function() vim.highlight.on_yank({ timeout = 130 }) end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "help", "man", "qf", "lspinfo", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(args)
    local ok, conform = pcall(require, "conform")
    if ok and vim.bo[args.buf].modifiable then
      conform.format({ bufnr = args.buf, lsp_fallback = true, timeout_ms = 2000 })
    end
  end,
})
