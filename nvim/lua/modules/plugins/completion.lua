-- Copyright (c) 2021 ayamir  MIT License

local completion = {}

completion['neovim/nvim-lspconfig'] = {
  lazy = true,
  event = { 'BufReadPost', 'BufAdd', 'BufNewFile' },
  config = require 'completion.lsp',
  dependencies = {
    { 'ray-x/lsp_signature.nvim' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'folke/neodev.nvim' }, -- Neovim api type definitions
    { 'b0o/schemastore.nvim' }, -- json schemas
    {
      'glepnir/lspsaga.nvim',
      config = require 'completion.lspsaga',
    },
  },
}
completion['jose-elias-alvarez/null-ls.nvim'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'completion.null-ls',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'jay-babu/mason-null-ls.nvim',
  },
}
completion['hrsh7th/nvim-cmp'] = {
  lazy = true,
  event = 'InsertEnter',
  config = require 'completion.cmp',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      dependencies = { 'rafamadriz/friendly-snippets' },
      config = require 'completion.luasnip',
    },
    { 'onsails/lspkind.nvim' },
    { 'lukas-reineke/cmp-under-comparator' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lua' },
    { 'andersevenrud/cmp-tmux' },
    { 'hrsh7th/cmp-path' },
    { 'f3fora/cmp-spell' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-cmdline' },
    { 'petertriho/cmp-git' },
    { 'kdheepak/cmp-latex-symbols' },
    { 'ray-x/cmp-treesitter' },

    -- -- Code AI
    -- {
    --   'tzachar/cmp-tabnine',
    --   build = (function()
    --     if vim.fn.has 'unix' == 1 then
    --       return './install.sh'
    --     end
    --     return 'powershell ./install.ps1'
    --   end)(),
    --   config = require 'completion.tabnine',
    -- },

    -- {
    --   'jcdickinson/codeium.nvim',
    --   dependencies = {
    --     'nvim-lua/plenary.nvim',
    --     'MunifTanjim/nui.nvim',
    --   },
    --   config = require 'completion.codeium',
    -- },
  },
}

return completion
