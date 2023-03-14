-- autoformat.lua
--
-- Use your language server to automatically format your code on save.
-- Adds additional commands as well to manage the behavior

local M = {}
M.plugins = {
  { -- If an `.editorconfig` file exists in the parent directory, its character encoding, line feed code, etc. must be followed.
    --? Not required since neovim 0.9.0 or higher comes standard.
    -- see :lua print(vim.fn.has("nvim-0.9.0"))
    'gpanders/editorconfig.nvim',
  },

  {
    -- Does no formatting by itself, but sets up an autocmd to format on save,
    -- preferring null-ls over LSP client formatting.
    'https://git.sr.ht/~nedia/auto-format.nvim',
    event = 'BufWinEnter',
    config = function()
      require('auto-format').setup {
        -- The name of the augroup.
        augroup_name = 'AutoFormat',

        -- If formatting takes longer than this amount of time, it will fail. Having no
        -- timeout at all tends to be ugly - larger files, complex or poor formatters
        -- will struggle to format within whatever the default timeout
        -- `vim.lsp.buf.format` uses.
        timeout = 2000,

        -- These filetypes will not be formatted automatically.
        exclude_ft = {},

        -- Prefer formatting via LSP for these filetypes.
        prefer_lsp = {},
      }
    end,
  },
}

return M
