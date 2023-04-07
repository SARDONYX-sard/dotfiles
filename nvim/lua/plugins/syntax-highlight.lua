local M = {}

M.highlight_languages = {
  'bash',
  'c',
  'cmake',
  'cpp',
  'css',
  'dockerfile',
  'go',
  'help',
  'html',
  'java',
  'javascript',
  'jsonc',
  'lua',
  'make',
  'markdown',
  'markdown_inline',
  'php',
  'python',
  'regex',
  'rust',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'yaml',
}

M.plugins = {
  {
    'navarasu/onedark.nvim', -- Theme inspired by Atom
    priority = 1000,
    config = function()
      require('onedark').setup {
        style = 'dark', ---@type 'dark'|'darker'|'cool'|'deep'|'warm'|'warmer'|'light' Default theme style.
        transparent = true, -- Show/hide background
        -- Lualine options --
        lualine = {
          transparent = true, -- lualine center bar transparency
        },
      }
      vim.cmd.colorscheme 'onedark'
    end,
  },

  {
    'xiyaowong/virtcolumn.nvim', -- Display vertical ruler of VSCode like
    config = function()
      vim.g.virtcolumn_char = '┊'
      vim.opt.colorcolumn = '100'
      vim.api.nvim_set_hl(0, 'VirtColumn', {
        -- - VScode ruler color '#979797'
        fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID 'Whitespace'), 'fg', 'gui'),
      })
    end,
  },

  {
    'nvim-lualine/lualine.nvim', -- Set lualine as statusline
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    'norcalli/nvim-colorizer.lua', -- display hex, RGB color
    config = function()
      require('colorizer').setup()
    end,
  },

  {
    'petertriho/nvim-scrollbar',
    dependencies = { 'kevinhwang91/nvim-hlslens' },
    config = function()
      require('scrollbar').setup {
        handle = {
          color = '#808080', ---@type '#008080'|'#808080'
        },
      }
      require('scrollbar.handlers.search').setup()
    end,
  },

  -- Show indent, space, color brackets
  {
    -- Indentation display, showing bracket pair connections.
    'shellRaining/hlchunk.nvim',
    config = function()
      local exclude_filetype = {
        alpha = true,
      }

      require('hlchunk').setup {
        chunk = {
          enable = true,
          style = '#BB0000',
        },
        indent = {
          enable = true,
          chars = { '┊' },
          exclude_filetype = exclude_filetype,
        },
        line_num = {
          enable = true,
          style = '#6b8f81', ---@type '#008080'|'#8b8f81'|'#6b8f81' - Candidate colors.
        },
        blank = {
          enable = true,
          chars = { '·' },
          exclude_filetype = exclude_filetype,
          style = {
            vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID 'Whitespace'), 'fg', 'gui'),
          },
        },
      }
    end,
  },

  {
    -- automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter
    'RRethy/vim-illuminate',
    lazy = true,
    event = { 'CursorHold', 'CursorHoldI' },
    config = function()
      require('illuminate').configure {
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
        delay = 100,
        filetypes_denylist = {
          'DoomInfo',
          'DressingSelect',
          'NvimTree',
          'Outline',
          'TelescopePrompt',
          'Trouble',
          'alpha',
          'dashboard',
          'dirvish',
          'fugitive',
          'help',
          'lsgsagaoutline',
          'neogitstatus',
          'norg',
          'toggleterm',
        },
        under_cursor = false,
      }
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter', -- Highlight, edit, and navigate code
    lazy = true,
    build = function()
      if #vim.api.nvim_list_uis() ~= 0 then
        local ok, _ = pcall(vim.api.nvim_command, 'TSUpdate')
        if not ok then
          vim.notify(
            'Failed update syntax highlighter(treesitter).',
            vim.log.levels.ERROR,
            { title = 'plugins.syntax-highlight' }
          )
        end
      end
    end,
    event = { 'CursorHold', 'CursorHoldI' },
    dependencies = {
      'HiPhish/nvim-ts-rainbow2',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      -- Automatic updates at startup are commented out because they increase startup time by 500ms~1500ms
      -- See `:help nvim-treesitter`
      require('nvim-treesitter.configs').setup {
        ensure_installed = M.highlight_languages,
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true, disable = { 'python' } },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },
        rainbow = {
          enable = true,
          query = 'rainbow-parens', -- Which query to use for finding delimiters
          strategy = require('ts-rainbow').strategy.global, -- Highlight the entire buffer all at once
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      }
    end,
  },
}

return M
