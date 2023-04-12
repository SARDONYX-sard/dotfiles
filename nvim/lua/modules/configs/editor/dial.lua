return function()
  local augend = require 'dial.augend'
  require('dial.config').augends:register_group {
    -- default augends used when no group name is specified
    default = {
      augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
      augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
      augend.date.alias['%Y/%m/%d'], -- date (2022/02/19, etc.)
    },

    -- augends used when group with name `mygroup` is specified
    mygroup = {
      augend.integer.alias.decimal,
      augend.constant.alias.bool, -- boolean value (true <-> false)
      augend.date.alias['%m/%d/%Y'], -- date (02/19/2022, etc.)
    },
  }
  vim.keymap.set('n', '<C-a>', require('dial.map').inc_normal(), { noremap = true })
  vim.keymap.set('n', '<C-x>', require('dial.map').dec_normal(), { noremap = true })
  vim.keymap.set('n', 'g<C-a>', require('dial.map').inc_gnormal(), { noremap = true })
  vim.keymap.set('n', 'g<C-x>', require('dial.map').dec_gnormal(), { noremap = true })
  vim.keymap.set('v', '<C-a>', require('dial.map').inc_visual(), { noremap = true })
  vim.keymap.set('v', '<C-x>', require('dial.map').dec_visual(), { noremap = true })
  vim.keymap.set('v', 'g<C-a>', require('dial.map').inc_gvisual(), { noremap = true })
  vim.keymap.set('v', 'g<C-x>', require('dial.map').dec_gvisual(), { noremap = true })
end
