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

      ---Normal mode keymap creator function.
      ---@param keys string
      ---@param func function|string
      ---@param desc string
      local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { noremap = true, silent = true, desc = 'Search: ' .. desc })
      end
      nmap('<leader>sf', require('telescope.builtin').find_files, '[f]iles')
      nmap('<leader>sh', require('telescope.builtin').help_tags, '[h]elp')
      nmap('<leader>sw', require('telescope.builtin').grep_string, 'current [w]ord')
      nmap('<leader>sg', require('telescope.builtin').live_grep, 'By [g]rep')
      nmap('<leader>sd', require('telescope.builtin').diagnostics, '[d]iagnostics')
    end,
  },

  {
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = (function()
      if vim.fn.has 'win32' then
        return 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
      elseif vim.fn.has 'unix' then
        return 'make'
      end
    end)(),
    cond = function()
      if vim.fn.has 'win32' then
        return vim.fn.executable 'cmake' == 1 and vim.fn.executable 'cl.exe' == 1
      elseif vim.fn.has 'unix' then
        return vim.fn.executable 'make' == 1 and (vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1)
      end
    end,
  },
}
return M
