local ui = {}

ui['goolord/alpha-nvim'] = {
  lazy = true,
  event = 'BufWinEnter',
  config = require 'ui.alpha',
}
ui['akinsho/bufferline.nvim'] = {
  lazy = true,
  event = { 'BufReadPost', 'BufAdd', 'BufNewFile' },
  config = require 'ui.bufferline',
}
ui['catppuccin/nvim'] = {
  lazy = false,
  name = 'catppuccin',
  config = require 'ui.catppuccin',
}
ui['j-hui/fidget.nvim'] = {
  lazy = true,
  event = 'BufReadPost',
  config = require 'ui.fidget',
}
ui['lewis6991/gitsigns.nvim'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'ui.gitsigns',
}
ui['shellRaining/hlchunk.nvim'] = {
  lazy = true,
  event = 'BufWinEnter',
  config = require 'ui.hlchunk',
}
ui['nvim-lualine/lualine.nvim'] = {
  lazy = true,
  event = { 'BufReadPost', 'BufAdd', 'BufNewFile' },
  config = require 'ui.lualine',
}
ui['kosayoda/nvim-lightbulb'] = {
  lazy = false,
  config = require 'ui.lightbulb'
}
-- ui['zbirenbaum/neodim'] = { -- Now it's buggy and therefore not used.
--   lazy = true,
--   event = 'LspAttach',
--   config = require 'ui.neodim',
-- }
ui['karb94/neoscroll.nvim'] = {
  lazy = true,
  event = 'BufReadPost',
  config = require 'ui.neoscroll',
}
ui['shaunsingh/nord.nvim'] = {
  lazy = true,
  config = require 'ui.nord',
}
ui['rcarriga/nvim-notify'] = {
  lazy = true,
  event = 'VeryLazy',
  config = require 'ui.notify',
}
ui['petertriho/nvim-scrollbar'] = {
  lazy = true,
  event = 'BufReadPost',
  dependencies = { 'kevinhwang91/nvim-hlslens' },
  config = require 'ui.nvim-scrollbar',
}
ui['navarasu/onedark.nvim'] = {
  lazy = true,
  config = require 'ui.onedark',
}
ui['folke/paint.nvim'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'ui.paint',
}
ui['edluffy/specs.nvim'] = {
  lazy = true,
  event = 'CursorMoved',
  config = require 'ui.specs',
}
ui['folke/todo-comments.nvim'] = {
  lazy = true,
  event = 'BufReadPost',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = require 'ui.todo-comments',
}
ui['xiyaowong/virtcolumn.nvim'] = {
  lazy = true,
  event = 'BufReadPost',
  config = require 'ui.virtcolumn',
}
return ui
