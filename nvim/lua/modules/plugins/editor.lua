local editor = {}

editor['rainbowhxch/accelerated-jk.nvim'] = {
  lazy = true,
  event = 'VeryLazy',
  config = require 'editor.accelerated-jk',
}
editor['olimorris/persisted.nvim'] = {
  lazy = true,
  cmd = {
    'SessionToggle',
    'SessionStart',
    'SessionStop',
    'SessionSave',
    'SessionLoad',
    'SessionLoadLast',
    'SessionLoadFromFile',
    'SessionDelete',
  },
  config = require 'editor.persisted',
}
editor['m4xshen/autoclose.nvim'] = {
  lazy = true,
  event = 'InsertEnter',
  config = require 'editor.autoclose',
}
editor['LunarVim/bigfile.nvim'] = {
  lazy = false,
  config = require 'editor.bigfile',
  cond = require('core.settings').load_big_files_faster,
}
editor['ojroques/nvim-bufdel'] = {
  lazy = true,
  cmd = { 'BufDel', 'BufDelAll', 'BufDelOthers' },
}
editor['numToStr/Comment.nvim'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'editor.comment',
}
editor['sindrets/diffview.nvim'] = {
  lazy = true,
  cmd = { 'DiffviewOpen', 'DiffviewClose' },
}
editor['junegunn/vim-easy-align'] = {
  lazy = true,
  cmd = 'EasyAlign',
}
editor['smoka7/hop.nvim'] = {
  lazy = true,
  version = '*',
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'editor.hop',
}
editor['RRethy/vim-illuminate'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'editor.vim-illuminate',
}
editor['romainl/vim-cool'] = {
  lazy = true,
  event = { 'CursorMoved', 'InsertEnter' },
}
editor['lambdalisue/suda.vim'] = {
  lazy = true,
  cmd = { 'SudaRead', 'SudaWrite' },
  config = require 'editor.suda',
}

----------------------------------------------------------------------
--                  :treesitter related plugins                    --
----------------------------------------------------------------------
editor['nvim-treesitter/nvim-treesitter'] = {
  lazy = true,
  build = function()
    if #vim.api.nvim_list_uis() ~= 0 then
      vim.api.nvim_command [[TSUpdate]]
    end
  end,
  event = 'BufReadPre',
  config = require 'editor.treesitter',
  dependencies = {
    { 'andymass/vim-matchup' },
    { 'mfussenegger/nvim-treehopper' },
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    {
      'abecodes/tabout.nvim',
      config = require 'editor.tabout',
    },
    {
      'windwp/nvim-ts-autotag',
      config = require 'editor.autotag',
    },
    {
      'NvChad/nvim-colorizer.lua',
      config = require 'editor.colorizer',
    },
    {
      'hiphish/rainbow-delimiters.nvim',
      config = require 'editor.rainbow_delims',
    },
    {
      'nvim-treesitter/nvim-treesitter-context',
      config = require 'editor.ts-context',
    },
    {
      'JoosepAlviste/nvim-ts-context-commentstring',
      config = require 'editor.ts-context-commentstring',
    },
  },
}

return editor
