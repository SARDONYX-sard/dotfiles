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
if has('nvim') && !exists('g:vscode')
    lua pcall(require, 'init')
endif

" vim settings
if !has('nvim')
    :set number " show line numbers
    :set clipboard+=unnamed

    :map <Space> <Leader>
    :map <Leader>q :q!<CR>
    :map <Leader>w :w<CR>

    :inoremap jj <Esc>
    :inoremap jk <Esc>
    :inoremap kj <Esc>
endif
