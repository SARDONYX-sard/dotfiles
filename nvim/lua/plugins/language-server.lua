-- NOTE: This is where your plugins related to LSP can be installed.
--
--  The configuration is done below. Search for lspconfig to find it below.
local M = {}

M.plugins = {
  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    lazy = true,
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason-lspconfig.nvim',
      'williamboman/mason.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        'j-hui/fidget.nvim',
        opts = {
          text = {
            -- animation shown when tasks are ongoing
            spinner = 'dots2', ---@type 'dots_negative'|'dots_snake'|''
          },
        },
      },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim', -- Neovim api type definitions
    },
  },

  {
    -- Lint and formatter results from external commands can be used for lsp hover, code_action, etc.
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local null_ls = require 'null-ls'
      null_ls.setup {
        ---The `null_ls` already has default settings for various external commands.
        ---Some of these cannot be executed without the corresponding command.
        ---
        ----See: https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
        sources = {
          null_ls.builtins.code_actions.eslint_d, -- js, ts linter
          null_ls.builtins.code_actions.gitsigns,
          null_ls.builtins.code_actions.shellcheck,
          null_ls.builtins.completion.luasnip,
          null_ls.builtins.completion.spell,
          null_ls.builtins.diagnostics.codespell,
          null_ls.builtins.diagnostics.gitlint,
          null_ls.builtins.diagnostics.eslint_d, -- js, ts linter
          null_ls.builtins.diagnostics.mypy, -- static type checker for Python
          null_ls.builtins.diagnostics.ruff, -- fast python linter
          null_ls.builtins.diagnostics.selene, -- fast lua linter
          null_ls.builtins.diagnostics.stylelint, -- css linter
          null_ls.builtins.diagnostics.yamllint,
          null_ls.builtins.formatting.black, -- python fmt
          null_ls.builtins.formatting.fish_indent, -- fish shell formatter
          null_ls.builtins.formatting.prettier, -- js,ts,md,yml,css etc. formatter
          null_ls.builtins.formatting.stylua, -- fast lua formatter
          null_ls.builtins.hover.printenv,
        },
      }
    end,
  },

  {
    'folke/trouble.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('trouble').setup {}
      vim.keymap.set('n', '<leader>d', ':TroubleToggle<CR>', { desc = 'Show errors([D]iabonostics)' })
    end,
  },

  {
    -- General framework for context aware hover providers (similar to vim.lsp.buf.hover).
    'lewis6991/hover.nvim',
    config = function()
      require('hover').setup {
        init = function()
          require 'hover.providers.lsp'

          if vim.fn.executable 'gh' then
            require 'hover.providers.gh'
            require 'hover.providers.gh_user'
          end

          require 'hover.providers.man'
          require 'hover.providers.dictionary'
        end,
      }

      -- Setup keymaps
      vim.keymap.set('n', 'K', require('hover').hover, { desc = 'hover.nvim' })
      vim.keymap.set('n', 'gK', require('hover').hover_select, { desc = 'hover.nvim (select)' })
    end,
  },

  { 'b0o/schemastore.nvim' }, -- Auto fetch json schemas
}

return M
