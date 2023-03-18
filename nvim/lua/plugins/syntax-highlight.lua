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
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
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
    -- Display vertical ruler of VSCode like
    'xiyaowong/virtcolumn.nvim',
    config = function()
      vim.g.virtcolumn_char = '┊'
      vim.opt.colorcolumn = '100'
      vim.api.nvim_set_hl(0, 'VirtColumn', { fg = '#979797' }) -- VScode ruler color '#979797'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
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
    -- display hex, RGB color
    'norcalli/nvim-colorizer.lua',
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

  {
    'xiyaowong/nvim-transparent',
    config = function()
      require('transparent').setup {
        enable = true, -- boolean: enable transparent
        extra_groups = { -- table/string: additional groups that should be cleared
          -- In particular, when you set it to 'all', that means all available groups
          'BufferLineTabClose',
          'BufferlineBufferSelected',
          'BufferLineFill',
          'BufferLineBackground',
          'BufferLineSeparator',
        },
        exclude = {}, -- table: groups you don't want to clear
      }
      vim.cmd 'highlight Pmenu guibg=None' -- transparent complition menu
    end,
  },

  -- Show indent, space, color brackets
  {
    -- Indentation display, showing bracket pair connections.
    'shellRaining/hlchunk.nvim',
    config = function()
      local exclude_filetype = {
        alpha = true,
        lazy = true,
      }

      require('hlchunk').setup {
        chunk = {
          enable = true,
          support_filetypes = {
            '*.ts',
            '*.js',
            '*.json',
            '*.go',
            '*.c',
            '*.cpp',
            '*.rs',
            '*.h',
            '*.hpp',
            '*.lua',
            '*.vue',
          },
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
        },
      }
    end,
  },

  {
    -- automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter
    'RRethy/vim-illuminate',
  },

  {
    -- Rainbow delimiters for Neovim through Tree-sitter
    'HiPhish/nvim-ts-rainbow2',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        rainbow = {
          enable = true,
          query = 'rainbow-parens', -- Which query to use for finding delimiters
        },
      }
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      -- Automatic updates at startup are commented out because they increase startup time by 500ms~1500ms
      -- local ok, _ = pcall(require('nvim-treesitter.install').update {})
      -- if not ok then
      --   vim.notify(
      --     'Failed update syntax highlighter(treesitter).',
      --     vim.log.levels.ERROR,
      --     { title = 'plugins.syntax-highlight' }
      --   )
      -- end

      -- See `:help nvim-treesitter`
      require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = M.highlight_languages,

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
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
