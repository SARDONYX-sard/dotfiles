return function()
  local icons = {
    ui = require('modules.utils.icons').get 'ui',
    misc = require('modules.utils.icons').get 'misc',
  }

  require('modules.utils').load_plugin('which-key', {
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
  })

  require('which-key').register {
    ['<leader><space>'] = {
      name = '+Diff/Save',
    },
    ['<leader>b'] = {
      name = '+Buffer',
    },
    ['<leader>d'] = {
      name = '+Debug',
    },
    ['<leader>f'] = {
      name = '+Find',
    },
    ['<leader>h'] = {
      name = '+Git hunk',
    },
    ['<leader>l'] = {
      name = '+Lsp (Manager)',
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
      name = '+Lsp (Action)',
    },
  }
end
