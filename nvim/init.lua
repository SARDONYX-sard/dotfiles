-- NOTE: Always load these keymaps first to make it easier to correct and edit plugin settings in case of errors.
vim.keymap.set('n', '<space>v', function()
  -- I'm clenching errors in pcall to prevent buff errors in `editorconfig.nvim`.
  pcall(vim.cmd.edit, debug.getinfo(1, 'S').short_src)
end, { desc = '[v]iew & edit init.lua' })

vim.keymap.set('n', '<space>V', function()
  local pwd = vim.fn.expand '%:p:h'

  if vim.fn.executable 'explorer.exe' == 1 and vim.fn.executable 'powershell.exe' == 1 then
    if vim.fn.has 'win32' == 1 then
      vim.fn.system('explorer.exe ' .. pwd)
      return
    else
      if vim.fn.has 'wsl' == 1 then
        pwd = vim.fn.system("bash -c 'wslpath -w " .. pwd .. "'")
      elseif vim.fn.has 'win32unix' == 1 then
        pwd = vim.fn.system("bash -c 'cygpath -w " .. pwd .. "'")
      end
      -- NOTE: Cannot jump to path location correctly without powershell.
      vim.fn.system("powershell.exe -c 'explorer.exe " .. pwd .. "'")
      return
    end
  elseif vim.fn.has 'linux' == 1 and vim.fn.executable 'xdg-open' == 1 then
    vim.fn.system('xdg-open ' .. pwd)
    return
  elseif vim.fn.has 'mac' == 1 and vim.fn.executable 'open' == 1 then
    vim.fn.system('open ' .. pwd)
    return
  end

  vim.notify(
    'Failed to open the directory(' .. pwd .. ') because there is no expected command',
    vim.log.levels.ERROR,
    { title = 'init.lua' }
  )
end, { desc = '[V]iew(Open) current dir with GUI' })

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

-- Force json to be treated as jsonc because errors in jsonc are annoying.
-- See: https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file
vim.cmd [[
  autocmd FileType json syntax match Comment +\/\/.\+$+ | set filetype=jsonc
]]
