" References:
"
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

" pure neovim settings
if has('nvim') && !exists('g:vscode') && has('win32')
    lua pcall(require, 'init')
    :colorscheme tokyonight-storm
else
    " :set clipboard+=unnamed
    :set mouse=a " use mouse
    :set number  " show line numbers
    :set showcmd " show temporary commands

    :map <Space> <Leader>
    :map <Leader>q :q!<CR>
    :map <Leader>w :w<CR>
    vnoremap <C-y> :'<,'>w !xclip -selection clipboard<Cr><Cr>

    " Move current line to up/down
    " Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
    nnoremap <A-j> :m .+1<CR>==
    nnoremap <A-k> :m .-2<CR>==
    inoremap <A-j> <Esc>:m .+1<CR>==gi
    inoremap <A-k> <Esc>:m .-2<CR>==gi
    vnoremap <A-j> :m '>+1<CR>gv=gv
    vnoremap <A-k> :m '<-2<CR>gv=gv
    " ---end

endif

" mode change
:inoremap jj <Esc>
:inoremap jk <Esc>
:inoremap kj <Esc>

:nmap <Leader>e :Vexplore<CR>
