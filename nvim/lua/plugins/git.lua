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
vim.keymap.set('n', '<leader>gC', ':<C-u>Git commit --amend<CR>', { desc = 'Git: modify prev [c]ommit msg' })
vim.keymap.set('n', '<leader>gg', ':<C-u>Git commit -S<CR>', { desc = 'Git: commit(with [g]pg)' })
vim.keymap.set(
  'n',
  '<leader>gG',
  ':<C-u>Git commit --amend -S<CR>',
  { desc = 'Git: modify prev commit msg(with [G]pg)' }
)
-- other
vim.keymap.set('n', '<leader>gb', ':<C-u>Git blame<CR>', { desc = 'Git: [b]lame open' })
vim.keymap.set('n', '<leader>gp', ':<C-u>Git push<CR>', { desc = 'Git: [p]ush to remote' })
vim.keymap.set('n', '<leader>gs', ':<C-u>Git<CR>', { desc = 'Git: [s]tatus tool open' })

return M
