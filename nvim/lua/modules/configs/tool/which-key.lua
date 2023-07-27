return function()
  local icons = {
    ui = require('modules.utils.icons').get 'ui',
    misc = require('modules.utils.icons').get 'misc',
  }

  require('which-key').setup {
    plugins = {
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = true,
        g = true,
      },
    },

    icons = {
      breadcrumb = icons.ui.Separator,
      separator = icons.misc.Vbar,
      group = icons.misc.Add,
    },

    window = {
      border = 'none',
      position = 'bottom',
      margin = { 1, 0, 1, 0 },
      padding = { 1, 1, 1, 1 },
      winblend = 0,
    },
  }

  local wk = require 'which-key'
  wk.register {
    ['<leader><space>'] = {
      name = '+GitDiffClose',
    },
    ['<leader>b'] = {
      name = '+Buffer',
    },
    ['<leader>f'] = {
      name = '+Find',
    },
    ['<leader>g'] = {
      name = '+Git',
    },
    ['<leader>h'] = {
      name = '+GitSign',
    },
    ['<leader>l'] = {
      name = '+LspMason',
    },
    ['<leader>n'] = {
      name = '+FileTree',
    },
    ['<leader>p'] = {
      name = '+Plugins',
    },
    ['<leader>s'] = {
      name = '+Session',
    },
    ['<leader>t'] = {
      name = '+Trouble',
    },
  }
end
