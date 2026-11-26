-- Plugins (lazy.nvim). Surround is built in (lua/builtin/surround.lua).
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system(
    { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
  )
end
vim.opt.rtp:prepend(lazypath)

-- -@type LazySpec
local spec = {
  {
    'monaqa/dial.nvim',
    keys = {
      { '<C-a>',  function() require('dial.map').manipulate('increment', 'normal') end },
      { '<C-x>',  function() require('dial.map').manipulate('decrement', 'normal') end },
      { 'g<C-a>', function() require('dial.map').manipulate('increment', 'gnormal') end },
      { 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gnormal') end },
      { '<C-a>',  function() require('dial.map').manipulate('increment', 'visual') end,  mode = 'v' },
      { '<C-x>',  function() require('dial.map').manipulate('decrement', 'visual') end,  mode = 'v' },
      { 'g<C-a>', function() require('dial.map').manipulate('increment', 'gvisual') end, mode = 'v' },
      { 'g<C-x>', function() require('dial.map').manipulate('decrement', 'gvisual') end, mode = 'v' },
    },
    config = function()
      local augend = require('dial.augend')
      require('dial.config').augends:register_group({
        default = {
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
          augend.constant.alias.bool,
          augend.date.alias['%Y/%m/%d'],
          augend.integer.alias.binary,
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.semver.alias.semver,
        },
        typescript = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.constant.new({ elements = { 'let', 'const' } }),
        },
        visual = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias['%Y/%m/%d'],
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
        },
      })
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    config = function()
      vim.api.nvim_set_hl(0, 'FlashLabel',
        { underline = true, bold = true, fg = 'Orange', bg = 'NONE', ctermfg = 'Red', ctermbg = 'NONE' })
      ---@diagnostic disable-next-line: undefined-field
      require('flash').setup({
        labels = 'asdfghjklqwertyuiopzxcvbnm',
        label = { uppercase = true, current = true, distance = true },
        modes = {
          search = { enabled = false },
          -- f/F/t/T/;/,
          char = { enabled = true, autohide = false, jump_labels = false, multi_line = true, label = { exclude = 'hjkliardc' } },
        },
      })
    end,
  },
  {
    'vscode-neovim/vscode-multi-cursor.nvim',
    cond = vim.g.vscode ~= nil,
    event = 'VeryLazy',
    config = function()
      local mc = require('vscode-multi-cursor')
      mc.setup({ default_mappings = true, no_selection = false })
      -- keybindings.json: { "key": "ctrl+d", "command": "vscode-neovim.send", "args": "<C-d>", "when": "editorFocus && neovim.init" }
      vim.keymap.set({ 'n', 'x', 'i' }, '<C-d>', mc.addSelectionToNextFindMatch)
    end,
  },
}

require('lazy').setup(spec, {
  change_detection = { enabled = false },
  rocks = { enabled = false },
})

if vim.g.vscode then
  local ok, vscode = pcall(require, 'vscode')
  if not ok then ok, vscode = pcall(require, 'vscode-neovim') end
  if ok then vim.notify = vscode.notify end
end
