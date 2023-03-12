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

  { 'b0o/schemastore.nvim' }, -- Auto fetch json schemas

  -- The handling of the range is nil and other errors occur frequently in python,
  -- so the handling of the range is temporarily stopped.
  -- {
  --   -- Displaying references and definition counts upon functions.
  --   --
  --   'VidocqH/lsp-lens.nvim',
  --   config = function()
  --     require('lsp-lens').setup {}
  --   end,
  -- },

  {
    -- It displays the code results in real time (use cmd `:Codi`).
    'metakirby5/codi.vim',
  },
}

return M
