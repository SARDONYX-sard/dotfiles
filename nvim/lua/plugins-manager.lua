---Load the plugin by the manager (possibly downloading first).
---
---# Example
---```lua
---local plugins = { 'folke/lazy.nvim' }
---require('plugions-manager').load(plugins)
---```
---
---# References
---- https://github.com/folke/lazy.nvim
---- `:help lazy.nvim.txt` for more info
local M = {
  lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim',
  version = 'stable', ---@type "stable" | "nightly"
}

---Download package manager by `git clone`.
---@private
function M.download_manager()
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=' .. M.version, -- latest stable release
    M.lazypath,
  }
end

---Load the plugin by the manager (possibly downloading first).
---@param plugins table
--
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
function M.load(plugins)
  if not vim.loop.fs_stat(M.lazypath) then
    M.download_manager()
  end
  vim.opt.rtp:prepend(M.lazypath)

  require('lazy').setup {
    plugins,
  }
end

vim.keymap.set('n', '<leader>p', '<cmd>Lazy<CR>', { silent = true, desc = 'Show Plugins' })

return M
