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

" Status Line Custom(https://gist.github.com/meskarune/57b613907ebd1df67eb7bdb83c6e6641)

" status bar colors
au InsertEnter * hi statusline guifg=black guibg=#d7afff ctermfg=black ctermbg=magenta
au InsertLeave * hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan
hi statusline guifg=black guibg=#8fbfdc ctermfg=black ctermbg=cyan

" Status line
" default: set statusline=%f\ %h%w%m%r\ %=%(%l,%c%V\ %=\ %P%)

let g:currentmode={
    \ 'n'      : 'Normal',
    \ 'no'     : 'Normal·Operator Pending',
    \ 'v'      : 'Visual',
    \ 'V'      : 'V·Line',
    \ '\<C-V>' : 'V·Block',
    \ 's'      : 'Select',
    \ 'S'      : 'S·Line',
    \ '^S'     : 'S·Block',
    \ 'i'      : 'Insert',
    \ 'R'      : 'Replace',
    \ 'Rv'     : 'V·Replace',
    \ 'c'      : 'Command',
    \ 'cv'     : 'Vim Ex',
    \ 'ce'     : 'Ex',
    \ 'r'      : 'Prompt',
    \ 'rm'     : 'More',
    \ 'r?'     : 'Confirm',
    \ '!'      : 'Shell',
    \ 't'      : 'Terminal'
    \}

function! ModeCurrent() abort
    let l:modecurrent = mode()
    " use get() -> fails safely, since ^V doesn't seem to register
    " 3rd arg is used when return of mode() == 0, which is case with ^V
    " thus, ^V fails -> returns 0 -> replaced with 'V Block'
    let l:modelist = toupper(get(g:currentmode, l:modecurrent, 'V·Block '))
    let l:current_status_mode = l:modelist
    return l:current_status_mode
endfunction

set laststatus=2
set noshowmode
set statusline=
set statusline+=%0*\ %{ModeCurrent()}\
set statusline+=%3*\                                     " Separator
set statusline+=%0*\ %n\                                 " Buffer number
set statusline+=%1*\ %<%F%m%r%h%w\                       " File path, modified, readonly, helpfile, preview
set statusline+=%=                                       " Right Side
set statusline+=%2*\ %Y\                                 " FileType
set statusline+=%3*│                                     " Separator
set statusline+=%2*\ %{''.(&fenc!=''?&fenc:&enc).''}     " Encoding
set statusline+=\ (%{&ff})                               " FileFormat (dos/unix..)
set statusline+=%3*│                                     " Separator
set statusline+=%2*\ \%v                                 " Colomn number
set statusline+=%3*:                                     " Separator
set statusline+=%1*\%02l/%L\ (%3p%%)\                    " Line number / total lines, percentage of document

hi User1 ctermfg=007 ctermbg=239 guibg=#4e4e4e guifg=#adadad
hi User2 ctermfg=007 ctermbg=236 guibg=#303030 guifg=#adadad
hi User3 ctermfg=236 ctermbg=236 guibg=#303030 guifg=#303030
hi User4 ctermfg=239 ctermbg=239 guibg=#4e4e4e guifg=#4e4e4e

" --Neovide settings (neovim GUI written by Rust)
" Ref: https://github.com/neovide/neovide
if exists("g:neovide")
    let g:neovide_transparency = 0.6
endif

" Display options
set autoread                   " - Reload files changed outside vim
set backspace=indent,eol,start " - Press `backspace`(insert mode) => delete character
set belloff=all                " - No sounds
set clipboard+=unnamed         " - Yank action == clipboard
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set fileformats=unix,dos,mac
set gcr=a:blinkon0             " - Disable cursor blink
set history=1000               " - Store lots of :cmdline history
set list
set listchars=extends:»,nbsp:%,precedes:«,space:·,tab:»-,trail:-
set mouse=a                    " - use mouse
set number                     " - Show line numbers
set ruler                      " - Show line and column number
set showcmd                    " - Show incomplete cmds down the bottom
set showmode                   " - Show current mode down the bottom
set spell                      " - add spell check
set nobackup                   " - Do not create backup file
set noswapfile                 " - Do not create swap file
set novisualbell               " - No flash

" colorscheme evening
colorscheme slate

scriptencoding utf-8
syntax enable

" GUI settings
autocmd GUIEnter * :set lines=45
autocmd GUIEnter * :set columns=200

" ----------------------------------------------------------------
" Key config
" ----------------------------------------------------------------
map <Space> <Leader>
map <Leader>q :quit!<CR>
map <Leader>w :write<CR>

nmap <Leader>c :bd<CR>                " delete buffer
nmap <Leader>v :edit ~/.vimrc<CR>
nnoremap ; :

" --- Explore
let g:netrw_altv = 1
let g:netrw_banner = 0
let g:netrw_browse_split = 3
let g:netrw_liststyle = 3
let g:netrw_winsize = 20

let g:NetrwIsOpen=0
function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore
    endif
endfunction

augroup AutoStartExplore
    autocmd!
    autocmd TabNew * :call ToggleNetrw()
    autocmd VimEnter * :call ToggleNetrw()
augroup END
noremap <silent> <Leader>e :call ToggleNetrw()<CR>
" --- Explore end

" `jk`(insert) => normal mode
inoremap jj <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

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
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>
