-- Neovim: used mainly through vscode-neovim. Own modules live in lua/builtin
-- (no dependencies); a few plugins are loaded via lazy.nvim in lua/plugins.lua.
require("builtin")
require("plugins")

local opts = { noremap = true, silent = true }
for _, lhs in ipairs({ "jk", "kj", "jj" }) do
	vim.keymap.set("i", lhs, "<Esc>", opts)
end
