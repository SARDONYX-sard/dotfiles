local editor = {}

editor['rhysd/clever-f.vim'] = {
  lazy = true,
  event = { 'BufReadPost', 'BufAdd', 'BufNewFile' },
  config = require 'editor.cleverf',
}
editor['monaqa/dial.nvim'] = { -- Enhanced increment/decrement
  lazy = true,
}
editor['phaazon/hop.nvim'] = {
  lazy = true,
  branch = 'v2',
  event = 'BufReadPost',
  config = require 'editor.hop',
}
editor['kylechui/nvim-surround'] = {
  lazy = true,
  event = 'VeryLazy',
  config = require 'editor.nvim-surround',
}
editor['romainl/vim-cool'] = { -- Improved highlighting usability
  lazy = true,
  event = { 'CursorMoved', 'InsertEnter' },
}

if not vim.g.vscode then
  editor['rainbowhxch/accelerated-jk.nvim'] = {
    lazy = true,
    event = 'VeryLazy',
    config = require 'editor.accelerated-jk',
  }
  editor['m4xshen/autoclose.nvim'] = {
    lazy = true,
    event = 'InsertEnter',
    config = require 'editor.autoclose',
  }
  editor['max397574/better-escape.nvim'] = {
    lazy = true,
    event = { 'CursorHold', 'CursorHoldI' },
    config = require 'editor.better-escape',
  }
  editor['junegunn/vim-easy-align'] = {
    lazy = true,
    cmd = 'EasyAlign',
  }
  editor['sindrets/diffview.nvim'] = {
    lazy = true,
    cmd = { 'DiffviewOpen', 'DiffviewClose' },
  }
  editor['numToStr/Comment.nvim'] = {
    lazy = true,
    event = { 'CursorHold', 'CursorHoldI' },
    config = require 'editor.comment',
  }
  editor['RRethy/vim-illuminate'] = {
    lazy = true,
    event = { 'CursorHold', 'CursorHoldI' },
    config = require 'editor.vim-illuminate',
  }
  editor['luukvbaal/stabilize.nvim'] = {
    lazy = true,
    event = 'BufReadPost',
  }
  editor['jedrzejboczar/possession.nvim'] = {
    config = require 'editor.possession',
  }
  editor['ojroques/nvim-bufdel'] = {
    lazy = true,
    event = { 'CursorHold' },
  }

  editor['nvim-treesitter/nvim-treesitter'] = {
    lazy = true,
    build = function()
      if #vim.api.nvim_list_uis() ~= 0 then
        vim.api.nvim_command 'TSUpdate'
      end
    end,
    event = { 'BufEnter' },
    config = require 'editor.treesitter',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      { 'mrjones2014/nvim-ts-rainbow' },
      { 'mfussenegger/nvim-treehopper' },
      { 'andymass/vim-matchup' },
      {
        'windwp/nvim-ts-autotag',
        config = require 'editor.autotag',
      },
      {
        'NvChad/nvim-colorizer.lua',
        config = require 'editor.colorizer',
      },
      {
        'abecodes/tabout.nvim',
        config = require 'editor.tabout',
      },
    },
  }
end

return editor
