local M = {}

M.plugins = {
  { -- Errors and canyon notices appear from right to left.
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup {
        -- Prevent errors in transparency by defining a background color for notify.
        background_colour = '#282A36',
      }
      vim.notify = require 'notify'
    end,
  },
}

return M
