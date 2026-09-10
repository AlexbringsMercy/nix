-- nix-wrapper-modules adds its package directory immediately before this file
-- is sourced. Explicitly load the native `start` packages now; Neovim's normal
-- package scan occurred earlier in process startup.
vim.cmd("packloadall!")
require("workstation")
