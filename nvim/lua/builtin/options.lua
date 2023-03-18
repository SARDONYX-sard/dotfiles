-- [[ Setting options ]]
-- See `:help vim.o`

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Editor behavior
vim.opt.ai = true -- always set autoindenting on
-- vim.opt.autochdir = true -- change the current working directory whenever you open a file.
vim.opt.ambiwidth = 'single'
vim.opt.autoread = true
vim.opt.backup = false
vim.opt.breakindent = true -- Enable break indent
vim.opt.bs = 'indent,eol,start' -- allow backspacing over everything in insert mode
vim.opt.conceallevel = 1
vim.opt.display = 'uhex'
vim.opt.history = 10000
vim.opt.mouse = 'a' -- Enable mouse mode
vim.opt.nu = true
vim.opt.pumblend = 5 -- completions windows opacity
vim.opt.shada = "'100,<1000,:10000,h"
vim.opt.swapfile = false
vim.opt.termguicolors = true -- NOTE: You should make sure your terminal supports this
vim.opt.timeout = true
vim.opt.timeoutlen = 500
vim.opt.ttimeout = true -- Decrease update time(key code)
vim.opt.ttimeoutlen = 200
vim.opt.undofile = true -- Save undo history
vim.opt.updatetime = 300 -- Decrease update time

-- File encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8' --
vim.opt.fileencodings = 'ucs-bom,utf-8,euc-jp,cp932,sjis,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213'
vim.opt.fileencodings = 'utf-8'
vim.opt.fileformats = 'unix,dos,mac' -- Automatic identification of line break code, left side has priority.
vim.opt.bomb = false
vim.opt.termencoding = 'utf-8'

-- Appearance settings
-- There are many detailed settings, so put them all together
vim.opt.background = 'dark'
vim.opt.cursorline = false -- highlight cursor line, use highlight to change display content
vim.opt.list = false -- Display tabs and line breaks. It's pretty annoying, so I leave it as no.
vim.opt.matchtime = 3 -- set the number of seconds to display the above showmatch to 3 seconds
vim.opt.number = true -- display line numbers
vim.opt.ruler = true
vim.opt.scrolloff = 5 -- always take 5 lines extra from the cursor position opt.virtualedit = 'block'
vim.opt.showmatch = true -- show the corresponding parentheses when typing parentheses, flush the corresponding parentheses
vim.opt.signcolumn = 'yes' -- Keep signcolumn on by default
vim.opt.title = false -- display title
vim.opt.tw = 0 -- screen width (number of characters) for automatic line breaks. 0 for no line breaks
vim.opt.wrap = true -- Wrap long lines. This is just for appearance, no line breaks.

-- Status line settings
vim.opt.cmdheight = 2 -- Command line height
vim.opt.laststatus = 2
vim.opt.showcmd = true
vim.opt.showmode = false
vim.opt.wildmenu = true
vim.opt.wildmode = 'list:full'

-- Indent settings
vim.opt.autoindent = true
vim.opt.backspace = 'indent,eol,start' -- Allow backspace indentation and line breaks to be removed.
vim.opt.expandtab = true -- Expand tabs to space.
vim.opt.shiftwidth = 2 -- Width to increase or decrease with `smartindent`
vim.opt.smarttab = true --  Advanced autoindent when creating a new line.
vim.opt.softtabstop = 0 -- Width of tab or backspace cursor movement for consecutive spaces.
vim.opt.tabstop = 2 -- Tab width on screen.

-- Fold settings
vim.opt.foldcolumn = 'auto:3'
vim.opt.foldmethod = 'marker'

-- Search settings
vim.opt.hlsearch = true -- Set highlight on search.
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search.
vim.opt.incsearch = true -- incremental search. Perform a search for each character entered.
vim.opt.smartcase = true -- Case sensitive if both upper and lower case are included.
vim.opt.wrapscan = true -- Go back to the beginning if you reach the end of the file when searching.
