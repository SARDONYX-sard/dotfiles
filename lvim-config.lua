-- lvim packer dir: ii "$HOME\AppData\Roaming\lunarvim\site\pack\packer"
-- lvim compiled.lua: ii "$HOME\AppData\Local\lvim\plugin"

-- nvim packer dir: ii "$HOME\AppData\local\lunarvim\site\pack\packer"
-- nvim compiled.lua: ii "$HOME\AppData\Local\nvim\plugin"

--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]] -- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
-- general
lvim.format_on_save = false
lvim.log.level = "warn"
lvim.transparent_window = true
lvim.builtin.telescope.defaults.layout_config.prompt_position = "bottom"
lvim.builtin.treesitter.rainbow.enable = true -- need nvim-ts-rainbow plugin
local components = require("lvim.core.lualine.components")
lvim.builtin.lualine.sections.lualine_a = { "mode" }
lvim.builtin.lualine.sections.lualine_y = {
    components.diagnostics,
    components.scrollbar,
}

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-q>"] = ":q<cr>"
lvim.keys.insert_mode["jj"] = "<ESC>"
lvim.keys.insert_mode["jk"] = "<ESC>"
lvim.keys.insert_mode["kj"] = "<ESC>"

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

lvim.builtin.which_key.mappings["t"] = {
    name = "Diagnostics",
    t = { "<cmd>TroubleToggle<cr>", "trouble" },
    w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
    d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
    q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
    l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
    r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"

-- Add executables to config.lua { exec, keymap, name}
lvim.builtin.terminal.execs = {
    { "lazygit", "tg", "lazygit" },
    { "pwsh", "tp", "Powershell Core" },
    { "zsh", "tz", "zsh" },
    { "pwsh -Command \"& {mingw64 -shell zsh }\"", "tm", "MinGW64" }
}

-- -------------------------------------------------------------------------------------------------
-- Languages settings
-- -------------------------------------------------------------------------------------------------
local languages =
{ "bash", "c", "go", "javascript", "json", "lua", "python", "typescript", "css", "rust", "java", "yaml" }

-- Syntax highlighting
lvim.builtin.treesitter.ensure_installed = languages
lvim.builtin.treesitter.highlight.enabled = true

-- Language server
lvim.lsp.installer.setup.automatic_servers_installation = true

-- -------------------------------------------------------------------------------------------------
-- Vim settings
-- -------------------------------------------------------------------------------------------------
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.fileencoding = "utf-8" -- the encoding written to a file
-- fileformat is local. fileformats is global.see more...(https://vim.fandom.com/wiki/File_format)
vim.opt.fileformats = "unix" -- use unix line endings for windows too.(if you want to change, you can use :set ff=dos)

vim.opt.list = true
vim.opt.listchars = {
    eol = '↵',
    nbsp = '␣',
    -- space = '·'
    tab = '>-',
    trail = '·',
}

if vim.fn.has("wsl") then
    -- For WSL clipboard issue.
    vim.cmd [[ autocmd TextYankPost * if v:event.operator ==# 'y' | call system('/mnt/c/Windows/System32/clip.exe', @0) | endif ]]
end


-- -------------------------------------------------------------------------------------------------
-- set a formatter, this will override the language server formatting capabilities (if it exists)
-- -------------------------------------------------------------------------------------------------
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {
        command = "black",
        extra_args = { "--line-length=79" },
        filetypes = { "python" }
    },
    {
        -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
        command = "prettier",
        ---@usage arguments to pass to the formatter
        -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
        extra_args = { "--print-with", "100" },
        ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
    },
    {
        command = "gofmt",
        filetypes = { "go" }
    }
}

-- -------------------------------------------------------------------------------------------------
-- set additional linters
-- -------------------------------------------------------------------------------------------------
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    {
        -- need `Linux: apt install python3.10-venv`
        command = "codespell",
        filetypes = languages
    },
    {
        command = "flake8",
        filetypes = { "python" }
    },
    {
        command = "shellcheck",
        extra_args = { "--severity", "warning" }
    },
    {
        command = "eslint_d",
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
    }
}

-- Additional Plugins
lvim.plugins = {
    {
        "nvim-lua/lsp_extensions.nvim"
    },
    {
        "folke/trouble.nvim",
        cmd = "TroubleToggle",
    },
    {
        "nacro90/numb.nvim",
        event = "BufRead",
        config = function()
            require("numb").setup {
                show_numbers = true, -- Enable 'number' for the window while peeking
                show_cursorline = true -- Enable 'cursorline' for the window while peeking
            }
        end
    },
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        config = function()
            require("nvim-ts-autotag").setup()
        end
    },
    {
        "p00f/nvim-ts-rainbow"
    },
    {
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
    },
    {
        "rmagatti/goto-preview",
        config = function()
            require('goto-preview').setup {
                width = 120, -- Width of the floating window
                height = 25, -- Height of the floating window
                default_mappings = true, -- Bind default mappings
                debug = false, -- Print debug information
                opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
                post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
                vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>"),
                vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>"),
                vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
            }
        end
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        config = function()
            require "lsp_signature".setup()
        end
    },
    -- {
    --     "Pocco81/AutoSave.nvim",
    --     config = function()
    --         require("autosave").setup(
    --         )
    --     end
    -- },
    {
        "felipec/vim-sanegx",
        event = "BufRead"
    },
    -- {
    --     "github/copilot.vim"
    -- },
    -- {
    --     "zbirenbaum/copilot.lua",
    --     event = { "VimEnter" },
    --     config = function()
    --         vim.defer_fn(function()
    --             require("copilot").setup()
    --         end, 100)
    --     end
    -- },
    -- {
    --     "zbirenbaum/copilot-cmp",
    --     after = { "copilot.lua", "nvim-cmp" },
    -- },
    {
        -- if you use windows, you need $HOME/.wakatime/wakatime-cli.exe
        -- In my case, I renamed wakatime-cli-windows-amd64.exe to wakatime-cli.exe.
        "wakatime/vim-wakatime"
    }
}
