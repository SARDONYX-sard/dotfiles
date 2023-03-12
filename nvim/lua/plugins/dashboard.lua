---The role of the dashboard is to provide easy access to recently used files.
local M = {}

M.plugins = {
  'goolord/alpha-nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  config = function()
    require('alpha').setup(require('alpha.themes.startify').config)
  end,
}

vim.keymap.set('n', '<leader>;', '<cmd>Alpha<CR>', { silent = true, desc = 'Show dashboard' })

return M
