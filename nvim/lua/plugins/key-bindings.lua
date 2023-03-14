local M = {}

M.plugins = {
  -- key bindings
  {
    -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    lazy = true,
  },

  {
    -- Type `cs"'` in normal mode to switch double quotes to single quotes.
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup {}
    end,
  },
}

return M
