local bind = require 'keymap.bind'
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local core_map = {
  ['n|;'] = map_cmd(':'):with_noremap():with_desc 'command',
  -- NOTE: For some reason the lsp key does not work when this is enabled
  -- ['n|:'] = map_cmd(';'):with_desc '',

  -- Suckless
  ['n|<S-Tab>'] = map_cr('normal za'):with_noremap():with_silent():with_desc 'edit: Toggle code fold',
  ['n|<C-s>'] = map_cu('write'):with_noremap():with_silent():with_desc 'edit: Save file',
  ['n|Y'] = map_cmd('y$'):with_desc 'edit: Yank text to EOL',
  ['n|D'] = map_cmd('d$'):with_desc 'edit: Delete text to EOL',
  ['n|n'] = map_cmd('nzzzv'):with_noremap():with_desc 'edit: Next search result',
  ['n|N'] = map_cmd('Nzzzv'):with_noremap():with_desc 'edit: Prev search result',
  ['n|J'] = map_cmd('mzJ`z'):with_noremap():with_desc 'edit: Join next line',
  ['n|<Esc>'] = map_callback(function()
      _flash_esc_or_noh()
    end)
    :with_noremap()
    :with_silent()
    :with_desc 'edit: Clear search highlight',

  ["n|<A-'>"] = map_cr('resize +2'):with_silent():with_desc 'window: Resize +2 horizontally',
  ['n|<A-;>'] = map_cr('resize -2'):with_silent():with_desc 'window: Resize -2 horizontally',
  ['n|<A-S-q>'] = map_cr('q!'):with_desc 'edit: Force quit',
  ['n|<A-[>'] = map_cr('vertical resize -5'):with_silent():with_desc 'window: Resize -5 vertically',
  ['n|<A-]>'] = map_cr('vertical resize +5'):with_silent():with_desc 'window: Resize +5 vertically',
  ['n|<A-j>'] = map_cmd(':m .+1<CR>=='):with_desc 'edit: Move line down',
  ['n|<A-k>'] = map_cmd(':m .-2<CR>=='):with_desc 'edit: Move line up',
  ['n|<C-h>'] = map_cmd('<C-w>h'):with_noremap():with_desc 'window: Focus left',
  ['n|<C-j>'] = map_cmd('<C-w>j'):with_noremap():with_desc 'window: Focus down',
  ['n|<C-k>'] = map_cmd('<C-w>k'):with_noremap():with_desc 'window: Focus up',
  ['n|<C-l>'] = map_cmd('<C-w>l'):with_noremap():with_desc 'window: Focus right',
  ['n|<C-q>'] = map_cr('wq'):with_desc 'edit: Save file and quit',
  ['n|<leader>w'] = map_cr('w!'):with_desc 'edit: Force Save',
  ['n|<leader>o'] = map_cr('setlocal spell! spelllang=en_us'):with_desc 'edit: Toggle spell check',
  ['n|tj'] = map_cr('tabprevious'):with_noremap():with_silent():with_desc 'tab: Move to previous tab',
  ['n|tk'] = map_cr('tabnext'):with_noremap():with_silent():with_desc 'tab: Move to next tab',
  ['n|tn'] = map_cr('tabnew'):with_noremap():with_silent():with_desc 'tab: Create a new tab',
  ['n|to'] = map_cr('tabonly'):with_noremap():with_silent():with_desc 'tab: Only keep current tab',
  ['t|<C-w>h'] = map_cmd('<Cmd>wincmd h<CR>'):with_silent():with_noremap():with_desc 'window: Focus left',
  ['t|<C-w>j'] = map_cmd('<Cmd>wincmd j<CR>'):with_silent():with_noremap():with_desc 'window: Focus down',
  ['t|<C-w>k'] = map_cmd('<Cmd>wincmd k<CR>'):with_silent():with_noremap():with_desc 'window: Focus up',
  ['t|<C-w>l'] = map_cmd('<Cmd>wincmd l<CR>'):with_silent():with_noremap():with_desc 'window: Focus right',
  -- Insert mode
  ['i|<C-u>'] = map_cmd('<C-G>u<C-U>'):with_noremap():with_desc 'edit: Delete previous block',
  ['i|<C-b>'] = map_cmd('<Left>'):with_noremap():with_desc 'edit: Move cursor to left',
  ['i|<C-a>'] = map_cmd('<ESC>^i'):with_noremap():with_desc 'edit: Move cursor to line start',
  ['i|<C-s>'] = map_cmd('<Esc>:w<CR>'):with_desc 'edit: Save file',
  ['i|<C-q>'] = map_cmd('<Esc>:wq<CR>'):with_desc 'edit: Save file and quit',
  -- Command mode
  ['c|<C-b>'] = map_cmd('<Left>'):with_noremap():with_desc 'edit: Left',
  ['c|<C-f>'] = map_cmd('<Right>'):with_noremap():with_desc 'edit: Right',
  ['c|<C-a>'] = map_cmd('<Home>'):with_noremap():with_desc 'edit: Home',
  ['c|<C-e>'] = map_cmd('<End>'):with_noremap():with_desc 'edit: End',
  ['c|<C-d>'] = map_cmd('<Del>'):with_noremap():with_desc 'edit: Delete',
  ['c|<C-h>'] = map_cmd('<BS>'):with_noremap():with_desc 'edit: Backspace',
  ['c|<C-t>'] = map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]])
    :with_noremap()
    :with_desc 'edit: Complete path of current file',
  -- Visual mode
  ['v|<A-j>'] = map_cmd(":m '>+1<CR>gv=gv"):with_desc 'edit: Move this line down',
  ['v|<A-k>'] = map_cmd(":m '<-2<CR>gv=gv"):with_desc 'edit: Move this line up',
  ['v|<'] = map_cmd('<gv'):with_desc 'edit: Decrease indent',
  ['v|>'] = map_cmd('>gv'):with_desc 'edit: Increase indent',
}

bind.nvim_load_mapping(core_map)
