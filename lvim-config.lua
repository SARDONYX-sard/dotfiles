-- ii $HOME/AppData/Local/lvim/config.lua
-- windows: ii $HOME\AppData\Roaming\lunarvim\lvim
--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]] -- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
-- general
lvim.autocommands.custom_groups = { { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" } } -- (https://neovim.io/doc/user/autocmd.html)
lvim.format_on_save = false
lvim.log.level = "warn"
lvim.transparent_window = true

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
lvim.keys.normal_mode["<C-Up>"] = false
-- edit a default keymapping
lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous
  }
}

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = {
  name = "+Trouble",
  r = { "<cmd>Trouble lsp_references<cr>", "References" },
  f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" }
}

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.alpha = true
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0

-- Add executables to config.lua { exec, keymap, name}
lvim.builtin.terminal.execs = { { "lazygit", "tg", "lazygit" }, { "pwsh", "tp", "Powershell Core" }, { "zsh", "tz", "zsh" },
  { "pwsh -Command \"& {mingw64 -shell zsh }\"", "tm", "MinGW64" } }

-- -------------------------------------------------------------------------------------------------
-- Languages settings
-- -------------------------------------------------------------------------------------------------
local languages =
{ "bash", "c", "go", "javascript", "json", "lua", "python", "typescript", "css", "rust", "java", "yaml" }

-- Syntax highlighting
lvim.builtin.treesitter.ensure_installed = languages
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true
-- Language server
lvim.lsp.automatic_servers_installation = true

-- -------------------------------------------------------------------------------------------------
-- Vim settings
-- -------------------------------------------------------------------------------------------------
vim.cmd('set fileformat=unix') -- use unix line endings for windows too.(if you want to change, you can use :set ff=dos)

-- For rust-analayzer TypeHint
vim.cmd [[ autocmd BufEnter,BufWinEnter,BufWritePost,InsertLeave,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{ prefix = '=>', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} } ]]

-- -------------------------------------------------------------------------------------------------
-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
-- -------------------------------------------------------------------------------------------------
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup { {
  command = "black",
  filetypes = { "python" }
}, {
  command = "isort",
  filetypes = { "python" }
}, {
  -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
  command = "prettier",
  ---@usage arguments to pass to the formatter
  -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
  extra_args = { "--print-with", "100" },
  ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
  filetypes = { "typescript", "typescriptreact" }
}, {
  command = "gofmt",
  filetypes = { "go" }
} }

-- -------------------------------------------------------------------------------------------------
-- -- set additional linters
-- -------------------------------------------------------------------------------------------------
local linters = require "lvim.lsp.null-ls.linters"
linters.setup { {
  command = "codespell",
  filetypes = { "bash", "go", "javascript", "json", "lua", "python", "typescript", "css", "rust", "java", "yaml" }
}, {
  command = "flake8",
  filetypes = { "python" }
}, {
  command = "shellcheck",
  extra_args = { "--severity", "warning" }
}, {
  command = "eslint_d",
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
} }

-- Additional Plugins
lvim.plugins = { { "nvim-lua/lsp_extensions.nvim" }, { "folke/tokyonight.nvim" }, {
  "folke/trouble.nvim",
  cmd = "TroubleToggle"
}, {
  "nacro90/numb.nvim",
  event = "BufRead",
  config = function()
    require("numb").setup {
      show_numbers = true, -- Enable 'number' for the window while peeking
      show_cursorline = true -- Enable 'cursorline' for the window while peeking
    }
  end
}, {
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  config = function()
    require("nvim-ts-autotag").setup()
  end
}, { "p00f/nvim-ts-rainbow" }, {
  "norcalli/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({ "*" }, {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      rgb_fn = true, -- CSS rgb() and rgba() functions
      hsl_fn = true, -- CSS hsl() and hsla() functions
      css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = true -- Enable all CSS *functions*: rgb_fn, hsl_fn
    })
  end
}, {
  "rmagatti/goto-preview",
  config = function()
    require('goto-preview').setup {
      width = 120, -- Width of the floating window
      height = 25, -- Height of the floating window
      default_mappings = true, -- Bind default mappings
      debug = false, -- Print debug information
      opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
      post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
      -- You can use "default_mappings = true" setup option
      -- Or explicitly set keybindings
      vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>"),
      vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>"),
      vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
    }
  end
}, {
  "ray-x/lsp_signature.nvim",
  event = "BufRead",
  config = function()
    require "lsp_signature".setup()
  end
}, {
  "Pocco81/AutoSave.nvim",
  config = function()
    require("autosave").setup(
    -- {
    --     enabled = true,
    --     execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
    --     events = {"InsertLeave", "TextChanged"},
    --     conditions = {
    --         exists = true,
    --         filename_is_not = {},
    --         filetype_is_not = {},
    --         modifiable = true
    --     },
    --     write_all_buffers = false,
    --     on_off_commands = true,
    --     clean_command_line_interval = 0,
    --     debounce_delay = 1000
    -- }
    )
  end
}, {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufRead",
  setup = function()
    vim.g.indentLine_enabled = 1
    vim.g.indent_blankline_char = "▏"
    vim.g.indent_blankline_filetype_exclude = { "help", "terminal", "dashboard" }
    vim.g.indent_blankline_buftype_exclude = { "terminal" }
    vim.g.indent_blankline_show_trailing_blankline_indent = false
    vim.g.indent_blankline_show_first_indent_level = false
  end
}, {
  -- open url with gx
  "felipec/vim-sanegx",
  event = "BufRead"
} }
