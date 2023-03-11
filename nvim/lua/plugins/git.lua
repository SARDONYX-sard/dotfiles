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

  { 'tpope/vim-rhubarb' },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        -- signs = {
        --   add = { text = '+' },
        --   change = { text = '~' },
        --   delete = { text = '_' },
        --   topdelete = { text = '‾' },
        --   changedelete = { text = '~' },
        -- },
      }
    end,
  },
}

--commit keymaps
vim.keymap.set('n', '<leader>gc', ':<C-u>Git commit<CR>', { desc = 'Git: [c]ommit' })
vim.keymap.set('n', '<leader>gv', ':<C-u>Git commit -S<CR>', { desc = 'Git: [v]erifying signed commit' })
vim.keymap.set('n', '<leader>gC', ':<C-u>Git commit --amend<CR>', { desc = 'Git: modify prev commit message' })
-- other
vim.keymap.set('n', '<leader>gb', ':<C-u>Git blame<CR>', { desc = 'Git: [b]lame open' })
vim.keymap.set('n', '<leader>gs', ':<C-u>Git<CR>', { desc = 'Git: [s]tatus tool open' })

return M
