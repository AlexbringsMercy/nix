require("tiny-inline-diagnostic").setup({
  preset = "minimal",
  options = { show_source = { enabled = true, if_many = true }, multilines = { enabled = true, always_show = false } },
})
require("trouble").setup({
  auto_close = true,
  modes = { diagnostics = { auto_open = false, auto_close = true, win = { position = "bottom", size = 0.30 } } },
})
