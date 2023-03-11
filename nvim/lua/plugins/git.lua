-- Git related plugins
local M = {}

M.plugins = {
  {
    'tpope/vim-fugitive',
    config = function()
      require('which-key').register {
        ['<leader>g'] = {
          name = '+Git',
        },
      }
    end,
  },

  'tpope/vim-rhubarb',

  -- Adds git releated signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  },
}

vim.keymap.set('n', '<leader>gC', ':<C-u>Git commit --amend<CR>')
vim.keymap.set('n', '<leader>gN', ':<C-u>Git now --all<CR>')
vim.keymap.set('n', '<leader>gb', ':<C-u>Git blame<CR>')
vim.keymap.set('n', '<leader>gc', ':<C-u>Git commit<CR>')
vim.keymap.set('n', '<leader>gs', ':<C-u>Git<CR>')

return M
