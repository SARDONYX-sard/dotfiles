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
      { 'j-hui/fidget.nvim', opts = {} },

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
          null_ls.builtins.diagnostics.eslint_d,   -- js, ts linter
          null_ls.builtins.diagnostics.mypy,       -- static type checker for Python
          null_ls.builtins.diagnostics.ruff,       -- fast python linter
          null_ls.builtins.diagnostics.selene,     -- fast lua linter
          null_ls.builtins.diagnostics.stylelint,  -- css linter
          null_ls.builtins.diagnostics.yamllint,
          null_ls.builtins.formatting.black,       -- python fmt
          null_ls.builtins.formatting.fish_indent, -- fish shell formatter
          null_ls.builtins.formatting.prettier,    -- js,ts,md,yml,css etc. formatter
          null_ls.builtins.formatting.stylua,      -- fast lua formatter
          null_ls.builtins.hover.printenv,
          null_ls.builtins.hover.dictionary.with {
            -- method = 'NULL_LS_HOVER', -- See: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/methods.lua#L19
            -- filetypes = {}, -- any filetypes == {}
            generator = {
              fn = function(_, done)
                local cword = vim.fn.expand '<cword>'
                local send_definition = function(...)
                  done { ... }
                end

                require('plenary.curl').request {
                  -- https://github.com/nvim-lua/plenary.nvim/blob/master/lua/plenary/curl.lua#L245
                  compressed = false,
                  url = 'https://api.dictionaryapi.dev/api/v2/entries/en/' .. cword,
                  method = 'get',
                  callback = vim.schedule_wrap(function(data)
                    if not (data and data.body) then
                      return
                    end

                    local ok, decoded = pcall(vim.json.decode, data.body)
                    if not ok or not (decoded and decoded[1]) then
                      -- vim.notify("Failed to parse dictionary response", vim.log.levels.ERROR)
                      return
                    end

                    ---See: https://github.com/lewis6991/hover.nvim/blob/main/lua/hover/providers/dictionary.lua#L9
                    ---@type table
                    local json = decoded[1]

                    ---@type string[]
                    local lines = {
                      json.word,
                    }

                    if json.phonetics ~= nil then
                      lines[#lines + 1] = ''
                      local phonetics = 'Phonetics: '
                      for _, phonetic in ipairs(json.phonetics) do
                        if phonetic.text then
                          phonetics = phonetics .. ' ' .. phonetic.text
                        end
                      end
                      lines[#lines + 1] = phonetics
                    end

                    for _, def in ipairs(json.meanings[1].definitions) do
                      lines[#lines + 1] = ''
                      lines[#lines + 1] = def.definition
                      if def.example then
                        lines[#lines + 1] = 'Example: ' .. def.example
                      end
                    end

                    send_definition(lines)
                  end),
                }
              end,
              async = true,
            },
          }, -- --I can't use this to error compressed option
        },
      }
    end,
  },

  { 'b0o/schemastore.nvim' }, -- Auto fetch json schemas

  {
    -- It displays the code results in real time (use cmd `:Codi`).
    'metakirby5/codi.vim',
    config = function()
      -- realtime code evaluate(REPL: Read-Eval-Print Loop). Maybe write each time.
      vim.keymap.set('n', '<leader>r', ':Codi<CR>', { silent = true, desc = '[r]ealtime code evaluate On/Off' })
    end,
  },
}

return M
