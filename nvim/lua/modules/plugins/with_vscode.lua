-- Plugins to be enabled in VSCode Neovim & Neovim
local with_vscode = {}

with_vscode['kylechui/nvim-surround'] = {
  lazy = true,
  version = '*', -- Use for stability; omit to use `main` branch for the latest features
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup {}
  end,
}

with_vscode['monaqa/dial.nvim'] = {
  lazy = true,
  event = 'VeryLazy',
  config = function()
    -- https://github.com/monaqa/dial.nvim
    local augend = require 'dial.augend'
    require('dial.config').augends:register_group {
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
        augend.constant.new { elements = { 'let', 'const' } },
      },
      visual = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias['%Y/%m/%d'],
        augend.constant.alias.alpha,
        augend.constant.alias.Alpha,
      },
    }

    vim.keymap.set('n', '<C-a>', function()
      require('dial.map').manipulate('increment', 'normal')
    end)
    vim.keymap.set('n', '<C-x>', function()
      require('dial.map').manipulate('decrement', 'normal')
    end)
    vim.keymap.set('n', 'g<C-a>', function()
      require('dial.map').manipulate('increment', 'gnormal')
    end)
    vim.keymap.set('n', 'g<C-x>', function()
      require('dial.map').manipulate('decrement', 'gnormal')
    end)
    vim.keymap.set('v', '<C-a>', function()
      require('dial.map').manipulate('increment', 'visual')
    end)
    vim.keymap.set('v', '<C-x>', function()
      require('dial.map').manipulate('decrement', 'visual')
    end)
    vim.keymap.set('v', 'g<C-a>', function()
      require('dial.map').manipulate('increment', 'gvisual')
    end)
    vim.keymap.set('v', 'g<C-x>', function()
      require('dial.map').manipulate('decrement', 'gvisual')
    end)
  end,
}

-- NOTE: `flash.nvim` is a powerful plugin that can be used as partial or complete replacements for:
--  > `hop.nvim`,
--  > `wilder.nvim`
--  > `nvim-treehopper`
-- Considering its steep learning curve as well as backward compatibility issues...
--  > We have no plan to remove the above plugins for the time being.
-- But as usual, you can always tweak the plugin to your liking.
with_vscode['folke/flash.nvim'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'editor.flash',
}

-- This is VSCode only
if vim.g.vscode then
  local vscode = require 'vscode-neovim'
  vim.notify = vscode.notify

  with_vscode['vscode-neovim/vscode-multi-cursor.nvim'] = {
    event = 'VeryLazy',
    cond = not not vim.g.vscode,
    opts = {},
    config = function()
      require('vscode-multi-cursor').setup { -- Config is optional
        -- Whether to set default mappings
        default_mapings = true,
        -- If set to true, only multiple cursors will be created without multiple selections
        no_selection = false,
      }

      --[[ keybindings.json in VSCode
        {
          "args": "<C-d>",
          "command": "vscode-neovim.send",
          "key": "ctrl+d",
          "when": "editorFocus && neovim.init"
        }
    ]]
      vim.keymap.set({ 'n', 'x', 'i' }, '<C-d>', function()
        require('vscode-multi-cursor').addSelectionToNextFindMatch()
      end)
    end,
  }
end

return with_vscode
