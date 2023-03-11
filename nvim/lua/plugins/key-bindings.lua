local M = {}

M.plugins = {
  {
    -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    opts = {},
  },

  {
    -- "gc" to comment visual regions/lines
    'numToStr/Comment.nvim',
    opts = {},
  },

  {
    -- Type `cs"'` in normal mode to switch double quotes to single quotes.
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
}

return M
