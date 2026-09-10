vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "Explorer" })
vim.keymap.set("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart picker" })
