local M = {}

M.plugins = {
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    lazy = true,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      }

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')

      -- See `:help telescope.builtin`
      vim.keymap.set(
        'n',
        '<leader>?',
        require('telescope.builtin').oldfiles,
        { desc = '[?] Find recently opened files' }
      )
      vim.keymap.set(
        'n',
        '<leader><space>',
        require('telescope.builtin').buffers,
        { desc = '[ ] Find existing buffers' }
      )
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      require('which-key').register {
        ['<leader>s'] = {
          name = '+Search',
        },
      }
      vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch: Files' })
      vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch: Help' })
      vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch: current Word' })
      vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch: by Grep' })
      vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch: Diagnostics' })
    end,
  },

  {
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },
}
return M
