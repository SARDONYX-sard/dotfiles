local M = {}

M.plugins = {
  'nvim-tree/nvim-tree.lua',
  config = function()
    require('nvim-tree').setup {
      sort_by = 'case_sensitive',
      sync_root_with_cwd = true,
      diagnostics = {
        enable = false,
        icons = {
          hint = '',
          info = '',
          warning = '',
          error = '',
        },
      },
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      view = {
        width = 36,
        side = 'left',
        mappings = {
          custom_only = false,
          list = {
            { key = 'u', action = 'dir_up' },
          },
        },
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
      },
      actions = {
        use_system_clipboard = true,
        change_dir = {
          enable = false,
        },
      },
    }

    local ok, wk = pcall(require, 'which-key')
    if ok then
      wk.register {
        ['<leader>t'] = { name = '+NvimTree' },
      }
    else
      vim.notify('Warn registing `NvimTree` prefix.', vim.log.levels.WARN, { title = 'buildin.highlight' })
    end
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Explorer' })
  end,
}

return M
