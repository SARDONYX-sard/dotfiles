local lang = {}

lang['kevinhwang91/nvim-bqf'] = {
  lazy = true,
  ft = 'qf',
  config = require 'lang.bqf',
  dependencies = {
    { 'junegunn/fzf', build = ':call fzf#install()' },
  },
}
lang['mrcjkb/rustaceanvim'] = {
  lazy = true,
  ft = 'rust',
  version = '*',
  init = require 'lang.rust',
  dependencies = 'nvim-lua/plenary.nvim',
}
lang['Saecki/crates.nvim'] = {
  lazy = true,
  event = 'BufReadPost Cargo.toml',
  config = require 'lang.crates',
  dependencies = 'nvim-lua/plenary.nvim',
}
lang['MeanderingProgrammer/render-markdown.nvim'] = {
  lazy = true,
  ft = { 'markdown', 'codecompanion' },
  config = require 'lang.render-markdown',
}
lang['chrisbra/csv.vim'] = {
  lazy = true,
  ft = 'csv',
}
return lang
