-- Edit vimrc keymap
vim.keymap.set('n', '<space>v', function()
  -- I'm clenching errors in pcall to prevent buff errors in `editorconfig.nvim`.
  pcall(vim.cmd.edit, debug.getinfo(1, 'S').short_src)
end, { desc = '[v]iew & edit init.lua' })

-- Imports dependencies
local utils = {
  table = require 'utils.table',
  module_loader = require 'utils.module-loader',
}

-- stdpath
local base_plugins_dir = vim.fn.stdpath 'config'

-- 1/4: Read all files directly under the `builtin` folder.
utils.module_loader.load_all(base_plugins_dir .. '/lua/builtin', 'builtin.')

-- 2/4:
-- - Read all files directly under the `plugins` folder.
-- - At this time, keymap and settings for plug-ins are also loaded.
local plugin_features = {}
for _, file in ipairs(vim.fn.readdir(base_plugins_dir .. '/lua/plugins', [[v:val =~ '\.lua$']])) do
  plugin_features[#plugin_features + 1] = file:gsub('%.lua$', '')
end
local plugins = utils.table.concat_fields(plugin_features, 'plugins', 'common_plugins')

-- 3/4: External plugins are loaded by the Plugin Manager.
require('plugins-manager').load(plugins)

-- 4/4: Load plugins settings.
utils.module_loader.load_all(base_plugins_dir .. '/lua/plugins-settings', 'plugins-settings.')

-- Show White space.
-- https://gist.github.com/kawarimidoll/ed105a754f3d64f9f174d2c4c43c0a6a#file-highlight_extra_whitespaces-vim
vim.cmd [[ autocmd VimEnter * ++once
      \ call matchadd('ExtraWhitespace', "[\u00A0\u2000-\u200B\u3000]")
      \ | highlight default ExtraWhitespace  ctermbg=239 guibg=none
]]
