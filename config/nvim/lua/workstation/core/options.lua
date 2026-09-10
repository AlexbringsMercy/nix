vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 180
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.cursorlineopt = "number,line"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.conceallevel = 2
opt.confirm = true
opt.completeopt = "menu,menuone,noselect"
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "", foldsep = " " }
opt.laststatus = 3
opt.showmode = false
opt.pumblend = 10
opt.winblend = 8
opt.winborder = "rounded"

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})

if vim.g.neovide then
  vim.o.guifont = "IosevkaTerm Nerd Font:h15"
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_right = 12
  vim.g.neovide_padding_left = 12
  vim.g.neovide_transparency = 0.93
  vim.g.neovide_window_blurred = true
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_animation_length = 0.06
  vim.g.neovide_cursor_trail_size = 0.25
  vim.g.neovide_scroll_animation_length = 0.18
  vim.g.neovide_hide_mouse_when_typing = true
end
