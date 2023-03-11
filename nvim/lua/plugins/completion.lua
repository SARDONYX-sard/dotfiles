local M = {}

M.plugins = {
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    lazy = true,
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'nvim-lua/plenary.nvim', -- required by cmp-git
      'petertriho/cmp-git',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require 'cmp'
      cmp.setup {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },

        sources = cmp.config.sources {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'path' },
          {
            name = 'buffer',
            option = {
              keyword_length = 5,
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end,
            },
          },
          { name = 'nvim_lua' },
          { name = 'luasnip' },
          { name = 'git' },
          { name = 'emoji' },
        },

        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = false }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        },
      }

      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          {
            name = 'buffer',
            option = {
              keyword_length = 5,
            },
          },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })
      require('cmp_git').setup()
    end,
  },

  {
    -- Items that are not originally supported can be displayed as complementary items.
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local null_ls = require 'null-ls'
      null_ls.setup {
        sources = {

          null_ls.builtins.formatting.stylua.with {
            condition = function(utils)
              return utils.root_has_file { '.stylua.toml' }
            end,
          },
          null_ls.builtins.diagnostics.luacheck.with {
            extra_args = { '--globals', 'vim', '--globals', 'awesome' },
          },
          null_ls.builtins.diagnostics.yamllint,
          -- spell checker
          null_ls.builtins.completion.spell,
          null_ls.builtins.diagnostics.codespell.with {
            condition = function()
              return vim.fn.executable 'codespell' > 0
            end,
          },
          -- fast python linter
          function() -- ruff fix
            local helpers = require 'null-ls.helpers'
            local methods = require 'null-ls.methods'

            return helpers.make_builtin {
              name = 'ruff',
              meta = {
                url = 'https://github.com/charliermarsh/ruff/',
                description = 'An extremely fast Python linter, written in Rust.',
              },
              method = methods.internal.FORMATTING,
              filetypes = { 'python' },
              generator_opts = {
                command = 'ruff',
                args = { '--fix', '-e', '-n', '--stdin-filename', '$FILENAME', '-' },
                to_stdin = true,
              },
              factory = helpers.formatter_factory,
            }
          end,
          null_ls.builtins.diagnostics.ruff.with {
            condition = function()
              return vim.fn.executable 'ruff' > 0
            end,
          },
        },
      }
    end,
  },
}

return M
