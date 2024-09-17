"
" NOTE:
"- VsVim only setting.
" INFO: Read a configuration file from PowerShell from an arbitrary location.(vsvimrc.vim -> .vsvimrc)
" ```powershell
" sudo New-Item -Type SymbolicLink -Target "$HOME/dotfiles/vsvimrc.vim" -Path $HOME/.vsvimrc"
" ```

" Display options
au CursorHold * checktime
set backspace=indent,eol,start " - Press `backspace`(insert mode) => delete character
set history=1000               " - Store lots of :cmdline history
set list
set visualbell                 " - HACK: VsVim is inverse config bug so this is enable. == novisualbell
set number                     " - Show line numbers
set showcmd                    " - Show incomplete cmds down the bottom


" GUI settings
autocmd GUIEnter * :set lines=45
autocmd GUIEnter * :set columns=200

" ----------------------------------------------------------------
" Key config
" ----------------------------------------------------------------
map <Space> <Leader>
map <Leader>q :quitall!<CR>
map <Leader>w :write<CR>

nmap <Leader>rv :so %<CR>                                " - Reload .vimrc
nmap <silent> <Leader>V :!start explorer /select,%:p<CR> " - Open current dir with exploer
nmap <silent> <Leader>c :bd<CR>                          " - Delete buffer

nnoremap ; :
vnoremap ; :

" `jk`(insert) => normal mode
inoremap jj <Esc>
inoremap jk <Esc>
inoremap kj <Esc>
inoremap <C-c> <Esc>

" - Move current line to up/down `Alt+j/k`
" Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <silent> <A-j> :m .+1<CR>==
nnoremap <silent> <A-k> :m .-2<CR>==
inoremap <silent> <A-j> <Esc>:m .+1<CR>==gi
inoremap <silent> <A-k> <Esc>:m .-2<CR>==gi
vnoremap <silent> <A-j> :m '>+1<CR>gv=gv
vnoremap <silent> <A-k> :m '<-2<CR>gv=gv

" - Automatically close parentheses, etc.
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>

" - Switch to alternate file
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>

nnoremap <S-k> :vsc Edit.QuickInfo<CR> "Hover: https://github.com/VsVim/VsVim/issues/1015#issuecomment-12181052

" //////////////////////////////////////////////////////////////////////////////
" Better gx to open URLs.
" Ref: https://gist.github.com/habamax/0a6c1d2013ea68adcf2a52024468752e
func! BetterGx() abort
    if exists("$WSLENV")
        lcd /mnt/c
        let cmd = ":silent !cmd.exe /C start"
    elseif has("win32") || has("win32unix")
        let cmd = ':silent !start'
    elseif executable('xdg-open')
        let cmd = ":silent !xdg-open"
    elseif executable('open')
        let cmd = ":silent !open"
    else
        echohl Error
        echomsg "Can't find proper opener for an URL!"
        echohl None
        return
    endif

    " URL regexes
    let rx_base = '\%(\%(http\|ftp\|irc\)s\?\|file\)://\S'
    let rx_bare = rx_base . '\+'
    let rx_embd = rx_base . '\{-}'

    let URL = ""

    " markdown URL [link text](http://ya.ru 'yandex search')
    try
        let save_view = winsaveview()
        if searchpair('\[.\{-}\](', '', ')\zs', 'cbW', '', line('.')) > 0
            let URL = matchstr(getline('.')[col('.')-1:], '\[.\{-}\](\zs'.rx_embd.'\ze\(\s\+.\{-}\)\?)')
        endif
    finally
        call winrestview(save_view)
    endtry

    " asciidoc URL http://yandex.ru[yandex search]
    if empty(URL)
        try
            let save_view = winsaveview()
            if searchpair(rx_bare . '\[', '', '\]\zs', 'cbW', '', line('.')) > 0
                let URL = matchstr(getline('.')[col('.')-1:], '\S\{-}\ze[')
            endif
        finally
            call winrestview(save_view)
        endtry
    endif

    " HTML URL <a href='http://www.python.org'>Python is here</a>
    "          <a href="http://www.python.org"/>
    if empty(URL)
        try
            let save_view = winsaveview()
            if searchpair('<a\s\+href=', '', '\%(</a>\|/>\)\zs', 'cbW', '', line('.')) > 0
                let URL = matchstr(getline('.')[col('.')-1:], 'href=["'."'".']\?\zs\S\{-}\ze["'."'".']\?/\?>')
            endif
        finally
            call winrestview(save_view)
        endtry
    endif

    " barebone URL http://google.com
    if empty(URL)
        let URL = matchstr(expand("<cfile>"), rx_bare)
    endif

    if empty(URL)
        return
    endif

    exe cmd . ' "' . escape(URL, '#%!')  . '"'

    if exists("$WSLENV") | lcd - | endif
endfunc

nnoremap <silent> gx :call BetterGx()<CR>
