local mocha = require("catppuccin.palettes").get_palette("mocha")

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  term_colors = true,
  dim_inactive = { enabled = true, shade = "dark", percentage = 0.12 },
  integrations = {
    blink_cmp = true,
    dropbar = { enabled = true, color_mode = true },
    gitsigns = true,
    native_lsp = { enabled = true, inlay_hints = { background = true } },
    neogit = true,
    snacks = { enabled = true, indent_scope_color = "lavender" },
    treesitter = true,
    which_key = true,
  },
  custom_highlights = function(colors)
    return {
      Normal = { bg = "none" },
      NormalNC = { bg = "none" },
      NormalFloat = { bg = colors.mantle },
      FloatBorder = { fg = colors.surface1, bg = colors.mantle },
      FloatTitle = { fg = colors.lavender, bg = colors.mantle },
      WinSeparator = { fg = colors.surface0, bg = "none" },
      CursorLineNr = { fg = colors.lavender, style = { "bold" } },
      StatusLine = { fg = colors.subtext1, bg = colors.mantle },
      StatusLineNC = { fg = colors.overlay0, bg = colors.crust },
      Pmenu = { bg = colors.mantle },
      PmenuSel = { bg = colors.surface1, fg = colors.text },
    }
  end,
})
vim.cmd.colorscheme("catppuccin")

require("mini.icons").setup()
require("which-key").setup({
  preset = "modern",
  delay = 350,
  win = { border = "rounded", padding = { 1, 2 } },
  spec = {
    { "<leader>f", group = "files / search" }, { "<leader>b", group = "buffers" },
    { "<leader>g", group = "git" }, { "<leader>c", group = "code" },
    { "<leader>d", group = "debug" }, { "<leader>t", group = "tests / tasks" },
    { "<leader>a", group = "AI" }, { "<leader>u", group = "UI" },
  },
})

require("snacks").setup({
  bigfile = { enabled = true },
  dashboard = { enabled = true, preset = { header = [[
 ███╗   ██╗██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██║   ██║██║████╗ ████║
 ██╔██╗ ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
]] } },
  explorer = { enabled = true, replace_netrw = true },
  git = { enabled = true },
  image = { enabled = not vim.g.neovide and vim.env.TERM == "xterm-kitty" },
  input = { enabled = true },
  notifier = { enabled = true, style = "compact", timeout = 3000 },
  picker = { enabled = true, layout = { preset = "telescope" }, win = { input = { keys = { ["<Esc>"] = { "close", mode = { "n", "i" } } } } } },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scratch = { enabled = true },
  statuscolumn = { enabled = true, left = { "mark", "sign" }, right = { "fold", "git" }, folds = { open = true, git_hl = true } },
  terminal = { enabled = true, win = { position = "bottom", height = 0.35 } },
  toggle = { enabled = true },
  words = { enabled = true },
  zen = { enabled = true },
})

require("dropbar").setup({
  menu = { quick_navigation = true, scrollbar = { enable = false } },
  bar = { hover = true, padding = { left = 1, right = 1 } },
})

local function vi_mode()
  local mode = vim.fn.mode(1):sub(1, 1)
  return ({ n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", c = "COMMAND", R = "REPLACE", t = "TERMINAL" })[mode] or mode
end
local mode_colors = { NORMAL = mocha.lavender, INSERT = mocha.green, VISUAL = mocha.flamingo, COMMAND = mocha.peach, REPLACE = mocha.red, TERMINAL = mocha.teal }
require("heirline").setup({
  statusline = {
    { provider = "▊", hl = function() return { fg = mode_colors[vi_mode()] or mocha.overlay1 } end },
    { provider = function() return " " .. vi_mode() .. " " end, hl = function() return { fg = mode_colors[vi_mode()] or mocha.text, bold = true } end },
    { provider = "  %<%f", hl = { fg = mocha.text } },
    { provider = "%m", hl = { fg = mocha.peach } },
    { provider = "%=" },
    { provider = function() local c = vim.lsp.get_clients({ bufnr = 0 }); return #c > 0 and (" " .. c[1].name .. " ") or "" end, hl = { fg = mocha.teal } },
    { provider = "%{&filetype}", hl = { fg = mocha.subtext1 } },
    { provider = "  %l:%c ", hl = { fg = mocha.subtext1 } },
  },
})
