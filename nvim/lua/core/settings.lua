local settings = {}
local home = require('core.global').home
local is_windows = require('core.global').is_windows

-- Set it to false if you want to use https to update plugins and treesitter parsers.
---@type boolean
settings['use_ssh'] = false

-- Set it to false if there are no need to format on save.
---@type boolean
settings['format_on_save'] = true

-- Set the format disabled directories here, files under these dirs won't be formatted on save.
---@type string[]
settings['format_disabled_dirs'] = {
  home .. '/format_disabled_dir_under_home',
}

-- NOTE: The startup time will be slowed down when it's true.
-- Set it to false if you don't use nvim to open big files.
---@type boolean
settings['load_big_files_faster'] = true

-- Change the colors of the global palette here.
-- Settings will complete their replacement at initialization.
-- Parameters will be automatically completed as you type.
-- Example: { sky = "#04A5E5" }
---@type palette
settings['palette_overwrite'] = {}

-- Set the colorscheme to use here.
-- Available values are: `catppuccin`, `catppuccin-latte`, `catppucin-mocha`, `catppuccin-frappe`, `catppuccin-macchiato`, `edge`, `nord`.
---@type 'catppuccin'|'catppuccin-latte'|'catppucin-mocha'|'catppuccin-frappe'|'catppuccin-macchiato'|'onedark'|'nord'
settings['colorscheme'] = 'onedark'

-- Set background color to use here.
-- Useful if you would like to use a colorscheme that has a light and dark variant like `edge`.
-- Valid values are: `dark`, `light`.
---@type "dark"|"light"
settings['background'] = 'dark'

-- Set the command for handling external URLs here. The executable must be available on your $PATH.
-- This entry is IGNORED on Windows and macOS, which have their default handlers builtin.
---@type string
settings['external_browser'] = (function()
  if is_windows == 1 then
    return "powershell.exe -Command 'Start-Process '"
  else
    return 'start '
  end
end)()

-- Filetypes in this list will skip lsp formatting if rhs is true
---@type table<string, boolean>
settings['formatter_block_list'] = {
  lua = false, -- example
}

-- Servers in this list will skip setting formatting capabilities if rhs is true
---@type table<string, boolean>
settings['server_formatting_block_list'] = {
  lua_ls = true,
  tsserver = true,
  clangd = true,
}

-- Set the language servers that will be installed during bootstrap here
-- check the below link for all the supported LSPs:
-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations
---@type string[]
settings['lsp_deps'] = {
  'clangd',
  'lua_ls',
}

-- Set the general-purpose servers that will be installed during bootstrap here
-- check the below link for all supported sources
-- in `code_actions`, `completion`, `diagnostics`, `formatting`, `hover` folders:
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
---@type string[]
settings['null_ls_deps'] = {
  'clang_format',
  'editorconfig_checker',
  'gitlint',
  'selene',
  'stylua',
  'yamllint',
  -- 'vint',
}

if vim.fn.executable 'bash' == 1 then
  table.insert(settings['null_ls_deps'], 'shellcheck')
  table.insert(settings['null_ls_deps'], 'shfmt')
end
if vim.fn.executable 'cargo' == 1 then
  table.insert(settings['lsp_deps'], 'rust_analyzer')
end
if vim.fn.executable 'fish' == 1 then
  table.insert(settings['null_ls_deps'], 'fish_indent')
end
if vim.fn.executable 'node' == 1 then
  table.insert(settings['lsp_deps'], 'jsonls')
  table.insert(settings['lsp_deps'], 'html')
  -- table.insert(settings['null_ls_deps'], 'cspell')
  table.insert(settings['null_ls_deps'], 'prettierd')
  -- table.insert(settings['null_ls_deps'], 'eslintd')
  table.insert(settings['null_ls_deps'], 'stylelint')
end
if vim.fn.executable 'python3' == 1 then
  table.insert(settings['null_ls_deps'], 'black')
  table.insert(settings['null_ls_deps'], 'mypy')
  table.insert(settings['null_ls_deps'], 'ruff')
end

return settings
