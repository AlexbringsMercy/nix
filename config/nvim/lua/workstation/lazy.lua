local lz = require("lz.n")

lz.load({
  { "oil.nvim", cmd = "Oil", after = function() require("oil").setup({ default_file_explorer = false, view_options = { show_hidden = true }, keymaps = { ["<C-l>"] = false, ["<C-h>"] = false } }) end },
  { "grug-far.nvim", cmd = "GrugFar", after = function() require("grug-far").setup({ headerMaxWidth = 80, transient = true }) end },
  { "neogit", cmd = "Neogit", after = function() require("neogit").setup({ integrations = { diffview = true }, kind = "floating" }) end },
  { "diffview.nvim", cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" }, after = function() require("diffview").setup({ view = { default = { layout = "diff2_horizontal" } } }) end },
  { "markview.nvim", ft = { "markdown", "quarto", "rmd" }, cmd = "Markview", after = function() require("markview").setup({ preview = { modes = { "n", "no", "c" }, hybrid_modes = { "n" } }, markdown = { headings = { enable = true }, tables = { enable = true } } }) end },
  { "csvview.nvim", ft = "csv", after = function() require("csvview").setup({ view = { display_mode = "border" } }) end },
  { "neotest", cmd = "Neotest", after = function() require("neotest").setup({ adapters = { require("neotest-python")({}), require("neotest-jest")({}) } }) end },
  { "overseer.nvim", cmd = { "OverseerToggle", "OverseerRun" }, after = function() require("overseer").setup({ strategy = "toggleterm", task_list = { direction = "bottom", min_height = 12 } }) end },
  { "persistence.nvim", event = "BufReadPre", after = function() require("persistence").setup({ options = { "buffers", "curdir", "tabpages", "wins", "globals" } }) end },
  { "todo-comments.nvim", event = "BufReadPost", after = function() require("todo-comments").setup({ signs = false }) end },
  { "sidekick.nvim", cmd = "Sidekick", after = function()
      require("sidekick").setup({
        cli = {
          watch = true,
          prompts = {
            diagnostics = "Help fix the diagnostics in {file}:\n{diagnostics}",
            review = "Review {file} for correctness, security, and maintainability.",
          },
        },
      })
    end },
})

-- Neovide deliberately uses system viewers rather than pretending Kitty's
-- graphics protocol exists. This remains useful in either frontend.
vim.api.nvim_create_user_command("OpenMedia", function(opts)
  local file = opts.args ~= "" and opts.args or vim.api.nvim_buf_get_name(0)
  if file == "" then return vim.notify("No file to open", vim.log.levels.WARN) end
  local ext = file:match("%.([^.]+)$") or ""
  local program = ({ pdf = "mupdf", mp4 = "mpv", webm = "mpv", mkv = "mpv", png = "swayimg", jpg = "swayimg", jpeg = "swayimg", gif = "swayimg", webp = "swayimg" })[ext:lower()] or "xdg-open"
  vim.fn.jobstart({ program, file }, { detach = true })
end, { nargs = "?", complete = "file", desc = "Open media externally" })
