require("builtin")

if vim.g.vscode then
	require("core.pack")
else
	require("core")
end
