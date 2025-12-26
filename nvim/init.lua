require("builtin")

if vim.g.vscode then
	require("core.pack")
else
	require("core")
end

local opts = { noremap = true, silent = true, expr = false }
-- Insert mode
vim.api.nvim_set_keymap("i", "jk", "<Esc>", opts)
vim.api.nvim_set_keymap("i", "kj", "<Esc>", opts)
vim.api.nvim_set_keymap("i", "jj", "<Esc>", opts)
-- vim.api.nvim_set_keymap("n", ";", ":", opts)
-- vim.api.nvim_set_keymap("n", ":", ";", opts)

-- Visual mode
-- vim.api.nvim_set_keymap("v", "jk", "<Esc>", opts)
-- vim.api.nvim_set_keymap("v", "kj", "<Esc>", opts)
-- vim.api.nvim_set_keymap("v", "jj", "<Esc>", opts)
-- vim.api.nvim_set_keymap("v", ";", ":", opts)
-- vim.api.nvim_set_keymap("v", ":", ";", opts)
