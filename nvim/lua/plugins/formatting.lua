-- Use your language server to automatically format your code on save.
-- Adds additional commands as well to manage the behavior

local M = {}
M.plugins = {
  {
    -- If an `.editorconfig` file exists in the parent directory, its character encoding,
    -- line feed code, etc. must be followed.
    --
    --? Not required since neovim 0.9.0 or higher comes standard.
    -- See :lua print(vim.fn.has("nvim-0.9.0"))
    'gpanders/editorconfig.nvim',
  },

  {
    -- Does no formatting by itself, but sets up an autocmd to format on save,
    -- preferring null-ls over LSP client formatting.
    'https://git.sr.ht/~nedia/auto-format.nvim',
    event = 'BufWinEnter',
    config = function()
      -- See: https://git.sr.ht/~nedia/auto-format.nvim/tree/main/item/lua/auto-format/config.lua
      require('auto-format').setup {}
    end,
  },
}

return M
