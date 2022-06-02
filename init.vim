if exists('g:vscode')

    let SessionLoad = 1
    let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
    let v:this_session=expand("<sfile>:p")
    silent only
    silent tabonly
    if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
        let s:wipebuf = bufnr('%')
    endif
    set shortmess=aoO
    argglobal
    %argdel
    wincmd t
    let s:save_winminheight = &winminheight
    let s:save_winminwidth = &winminwidth
    set winminheight=0
    set winheight=1
    set winminwidth=0
    set winwidth=1
    tabnext 1
    badd +0 ~/dotfiles/__vscode_neovim__-file:///c\%3A/Users/SARDONYX/dotfiles/common/vs-code-init.vim
    if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
        silent exe 'bwipe ' . s:wipebuf
    endif
    unlet! s:wipebuf
    set winheight=1 winwidth=20 shortmess=filnxtToOFI
    let &winminheight = s:save_winminheight
    let &winminwidth = s:save_winminwidth
    let s:sx = expand("<sfile>:p:r")."x.vim"
    if filereadable(s:sx)
        exe "source " . fnameescape(s:sx)
    endif
    let &g:so = s:so_save | let &g:siso = s:siso_save
    set hlsearch
    nohlsearch
    doautoall SessionLoadPost
    unlet SessionLoad
    " vim: set ft=vim :

    " References:
    " [1] https://github.com/asvetliakov/vscode-neovim/issues/103
    " [2] https://github.com/Microsoft/WSL/issues/892
    set clipboard=unnamedplus " default
    if has('clipboard') || exists('g:vscode') " [1]
        let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point [2]
        if executable(s:clip)
            augroup WSLYank
                autocmd!
                autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
            augroup END
        endif
    endif
else
    lua require('init')
endif
