local M = {}

M.plugins = {
  'nvim-tree/nvim-tree.lua',
  -- :help nvim-tree
  -- See: https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt#L217https://github.com/nvim-tree/nvim-tree.lua/blob/master/doc/nvim-tree-lua.txt#L217
  config = function()
    require('nvim-tree').setup {
      sort_by = 'case_sensitive',
      diagnostics = {
        enable = true,
        icons = {
          hint = '',
          info = '',
          warning = '',
          error = '',
        },
      },
      view = {
        width = 30,
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
        icons = {
          show = {
            git = true,
          },
          glyphs = {
            -- For VSCode like
            -- See: https://stackoverflow.com/questions/48304195/what-are-the-u-and-m-file-markers-in-visual-studio-code
            git = {
              unstaged = 'M',
              staged = 'A',
              unmerged = '',
              renamed = 'R',
              untracked = 'U',
              deleted = 'D',
              ignored = '◌',
            },
          },
        },
      },
      actions = {
        change_dir = {
          restrict_above_cwd = true,
        },
      },
      update_cwd = true,
      update_focused_file = {
        enable = true,
        -- update_cwd = true, -- Deprecated as enabling this will disable git root.
      },
    }
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Explorer' })
  end,
}

return M
