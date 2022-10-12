" References:
" [1] https://github.com/asvetliakov/vscode-neovim/issues/103
" [2] https://github.com/Microsoft/WSL/issues/892
if has('clipboard') || exists('g:vscode')
    let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point [2]
    if executable(s:clip)
        augroup WSLYank
            autocmd!
            autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
        augroup END
    endif
endif

" --Neovide settings (neovim GUI written by Rust)
" Ref: https://github.com/neovide/neovide
if exists("g:neovide")
    let g:neovide_transparency = 0.6
endif

" ----------------------------------------------------------------
" Display options
" ----------------------------------------------------------------
set number         " - Show line numbers
set ruler          " - Show line and column number
set showcmd        " - Show incomplete cmds down the bottom
set showmode       " - Show current mode down the bottom


" - Indentation visualization
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%

colorscheme desert " - color theme


" ----------------------------------------------------------------cation
" Behavior Modification
" ----------------------------------------------------------------
set autoread                   " - Reload files changed outside vim
set backspace=indent,eol,start " - Press `backspace`(insert mode) => delete character
set gcr=a:blinkon0             " - Disable cursor blink
set history=1000               " - Store lots of :cmdline history
set visualbell                 " - No sounds

set mouse=a " - use mouse.
set clipboard+=unnamed " - Yank action == clipboard

" - encoding
set encoding=utf-8
scriptencoding utf-8

set nobackup " - Do not create backup file
set noswapfile " - Do not create swap file


" ----------------------------------------------------------------
" Key config
" ----------------------------------------------------------------
map <Space> <Leader>
map <Leader>q :q!<CR> " <space+q> => quit editor
map <Leader>w :w<CR> " <space+w> => write editor

nmap <Leader>e :Explore<CR>

" `jk`(insert) => normal mode
inoremap jj <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

nnoremap ; :

" - Move current line to up/down `Alt+j/k`
" Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" - automatically close parentheses, etc.
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>

" - Switch to alternate file
nnoremap <C-j> :bnext<CR>
nnoremap <C-k> :bprevious<CR>
