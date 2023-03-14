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

      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        -- Standalone UI for nvim-lsp progress.
        'j-hui/fidget.nvim',
        opts = {
          text = {
            ---animation shown when tasks are ongoing
            --- - See: https://github.com/j-hui/fidget.nvim/blob/main/lua/fidget/spinners.lua
            --- This alias created with https://github.com/j-hui/fidget.nvim/blob/main/doc/fidget.md#spinners
            ---@alias Spinner
            ---|'dots_negative'
            ---|'dots_snake'
            ---|'dots_footsteps'
            ---|'dots_hop'
            ---|'line'
            ---|'pipe'
            ---|'dots_ellipsis'
            ---|'dots_scrolling'
            ---|'star'
            ---|'flip'
            ---|'hamburger'
            ---|'grow_vertical'
            ---|'grow_horizontal'
            ---|'noise'
            ---|'dots_bounce'
            ---|'triangle'
            ---|'arc'
            ---|'circle'
            ---|'square_corners'
            ---|'circle_quarters'
            ---|'circle_halves'
            ---|'dots_toggle'
            ---|'box_toggle'
            ---|'arrow'
            ---|'zip'
            ---|'bouncing_bar'
            ---|'bouncing_ball'
            ---|'clock'
            ---|'earth'
            ---|'moon'
            ---|'dots_pulse'
            ---|'meter'
            ---@type Spinner
            spinner = 'dots_ellipsis',
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
          null_ls.builtins.code_actions.cspell,
          null_ls.builtins.code_actions.eslint, -- js, ts linter
          null_ls.builtins.code_actions.eslint_d, -- js, ts linter faster than eslint
          null_ls.builtins.code_actions.gitsigns,
          null_ls.builtins.code_actions.shellcheck,
          null_ls.builtins.completion.luasnip,
          null_ls.builtins.completion.spell,
          -- null_ls.builtins.completion.tags,
          null_ls.builtins.diagnostics.eslint_d, -- js, ts linter
          null_ls.builtins.diagnostics.gitlint,
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

          -- Override configurations
          null_ls.builtins.diagnostics.cspell.with {
            diagnostics_postprocess = function(diagnostic)
              diagnostic.severity = vim.diagnostic.severity['WARN']
            end,
            condition = function()
              return vim.fn.executable 'cspell' > 0
            end,
          },
        },
      }
    end,
  },

  {
    'folke/trouble.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('trouble').setup {}

      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.register {
          ['<leader>x'] = {
            name = '+Diagnostics',
          },
        }
      end

      ---Normal mode diagnostics keymap creator function.
      ---@param keys string
      ---@param func function|string
      ---@param desc string
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'Diagnostics: ' .. desc
        end
        vim.keymap.set('n', keys, func, { silent = true, desc = desc })
      end
      -- NOTE: Override builtin diagnostics if trouble.nvim is enabled.
      nmap('<leader>d', ':TroubleToggle<CR>', '[d]iagnostics')
      nmap('<leader>xw', ':TroubleToggle workspace_diagnostics<CR>', '[w]orkspace')
      nmap('<leader>xD', ':TroubleToggle document_diagnostics<CR>', '[D]ocuments')
      nmap('<leader>xl', ':TroubleToggle loclist<CR>', '[l]ocations')
      nmap('<leader>xq', ':TroubleToggle quickfix<CR>', '[q]uikfixes')
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
