local M = {}

M.plugins = {
  {
    -- vscode-like pictograms for neovim lsp completion icons
    'onsails/lspkind.nvim',
    lazy = true,
    config = function()
      require('lspkind').init {
        -- defines how annotations are shown
        -- default: symbol
        ---@type 'text'|'text_symbol'|'symbol_text'|'symbol'
        mode = 'symbol_text',

        -- default symbol map(default: 'default')
        -- - 'default': requires `nerd-fonts` font
        -- - 'codicons': requires `vscode-codicons` font
        preset = 'default', ---@type 'default'|'codicons'

        -- override preset symbols
        --
        -- default: {}
        symbol_map = {
          Text = '',
          Method = '',
          Function = '',
          Constructor = '',
          Field = 'ﰠ',
          Variable = '',
          Class = 'ﴯ',
          Interface = '',
          Module = '',
          Property = 'ﰠ',
          Unit = '塞',
          Value = '',
          Enum = '',
          Keyword = '',
          Snippet = '',
          Color = '',
          File = '',
          Reference = '',
          Folder = '',
          EnumMember = '',
          Constant = '',
          Struct = 'פּ',
          Event = '',
          Operator = '',
          TypeParameter = '',
        },
      }
    end,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    lazy = true,
    dependencies = {
      -- dependencies
      'nvim-lua/plenary.nvim', -- required by cmp-git
      'L3MON4D3/LuaSnip',
      -- add-ons
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'petertriho/cmp-git',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  {
    -- Generative AI technology to predict and suggests your next lines of code.
    'tzachar/cmp-tabnine',
    lazy = true,
    dependencies = 'hrsh7th/nvim-cmp',
    build = (function()
      if vim.fn.has 'win32' then
        return 'powershell ./install.ps1'
      end
      return './install.sh'
    end)(),
    config = function()
      require('cmp_tabnine.config'):setup {
        show_prediction_strength = true,
      }
    end,
  },
}

return M
