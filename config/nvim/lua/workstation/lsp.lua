local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
  nixd = { settings = { nixd = { formatting = { command = { "nixfmt" } } } } },
  lua_ls = { settings = { Lua = { runtime = { version = "LuaJIT" }, diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } } } },
  vtsls = {},
  eslint = {},
  jsonls = {},
  yamlls = {},
  bashls = {},
  basedpyright = { settings = { basedpyright = { analysis = { typeCheckingMode = "standard", autoSearchPaths = true, useLibraryCodeForTypes = true } } } },
  tailwindcss = {},
  marksman = {},
}

for name, server in pairs(servers) do
  server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

require("blink.cmp").setup({
  keymap = { preset = "default", ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" } },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 250 },
    menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
  },
  signature = { enabled = true, window = { border = "rounded" } },
  snippets = { preset = "default" },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "lua" }, -- Nix supplies source only; never compile/download mutable matcher state.
})

local group = vim.api.nvim_create_augroup("WorkstationLsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Declaration" }))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Implementation" }))
    vim.keymap.set("n", "<leader>ch", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
    vim.keymap.set("n", "<leader>cI", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
  end,
})
