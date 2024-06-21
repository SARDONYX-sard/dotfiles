" Load last open buffer, if no vim args
if argc() == 0
    " autocmd VimEnter to load the last buffer
    autocmd VimEnter * nested :e #<1
    " autocmd BufReadPost to change the working directory to the last buffer's directory
    autocmd BufReadPost * execute "cd " expand("%:p:h")
endif

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

" ---Status Line Custom(https://gist.github.com/meskarune/57b613907ebd1df67eb7bdb83c6e6641)

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

let ff_table = {'dos' : 'CRLF', 'unix' : 'LF', 'mac' : 'CR' }

function! FileSize(bytes)
    let l:bytes = a:bytes | let l:sizes = ['B', 'KB', 'MB', 'GB'] | let l:i = 0
    while l:bytes >= 1024 | let l:bytes = l:bytes / 1024.0 | let l:i += 1 | endwhile
    return l:bytes > 0 ? printf(' %.1f%s ', l:bytes, l:sizes[l:i]) : ''
endfunction

set laststatus=2
set noshowmode
set statusline=
set statusline+=%0*\ %{ModeCurrent()}
set statusline+=%3*\                                          " Separator
set statusline+=%0*\ %n\                                      " Buffer number
set statusline+=%1*\ %<%F%m%r%h%w\                            " File path, modified, readonly, helpfile, preview
set statusline+=%=                                            " Right Side
set statusline+=%2*\ %Y                                       " FileType
set statusline+=%3*│                                         " Separator
set statusline+=%2*\%{''.(&fenc!=''?&fenc:&enc).''}           " Encoding
set statusline+=\(%{ff_table[&ff]})                           " FileFormat (CRLF/LF/CR)
set statusline+=%3*│                                         " Separator
set statusline+=%1*\%01l/%L                                   " Line number / total lines
set statusline+=%3*:                                          " Separator
set statusline+=%2*\%v                                        " Colomn number
set statusline+=%2*\(%p%%)                                    " Percentage of document
set statusline+=%{FileSize(line2byte('$')+len(getline('$')))} " File size
" Got to GUI settings(when hover path, <Ctrl-w> + F): $HOME/.gvimrc

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
au CursorHold * checktime
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
set listchars=extends:»,nbsp:%,precedes:«,space:·,tab:￫\ ,trail:-
set mouse=a                    " - use mouse
set nobackup                   " - Do not create backup file
set noswapfile                 " - Disable swp file output
set noswapfile                 " - Do not create swap file
set noundofile                 " - undo file output disabled
set novisualbell               " - No flash
set number                     " - Show line numbers
set ruler                      " - Show line and column number
set shortmess-=S               " - Removing the S flag will show [number currently in focus/number of matches].
set showcmd                    " - Show incomplete cmds down the bottom
set showmode                   " - Show current mode down the bottom
set wildmenu                   " - Show completion list in Command Mode

colorscheme slate " slate|evening

scriptencoding utf-8
syntax enable

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
nmap <silent> <Leader>v :edit ~/.vimrc<CR>

nnoremap ; :
vnoremap ; :

" `jk`(insert) => normal mode
inoremap jj <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

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

"Binary Edit (xxd) mode (invoked by invoking vim -b or opening the *.bin,*.hkx file)
augroup BinaryXXD
    autocmd!
    autocmd BufReadPre  *.bin,*.exe,*.hkx let &binary =1
    autocmd BufReadPost * if &binary | silent %!xxd -g 1
    autocmd BufReadPost * set ft=xxd | endif
    autocmd BufWritePre * if &binary | %!xxd -r | endif
    autocmd BufWritePost * if &binary | silent %!xxd -g 1
    autocmd BufWritePost * set nomod | endif
augroup END

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

" //////////////////////////////////////////////////////////////////////////////
" Papyrus syntax file
" Filename:     papyrus.vim
" Language:     TES5 Papyrus scripting language
" Maintainer:   Sirtaj Singh Kang <sirtaj@sirtaj.net>
" Version:      1.0
" License: All parts of this plugin are under the public domain. I request that you drop me a note if you redistribute this with modifications, but you are under no legal obligation to do so.
"
" This is based on various references at http://www.creationkit.com/

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syn case ignore

syn keyword papyrusScript       ScriptName Extends

syn keyword papyrusKeyword      Event EndEvent
syn keyword papyrusKeyword      Function EndFunction
syn keyword papyrusKeyword      State EndState Return

syn keyword papyrusConditional  If ElseIf Else EndIf
syn keyword papyrusRepeat       While EndWhile
syn keyword papyrusImport       Import

syn keyword papyrusTodo         TODO FIXME XXX
syn region  papyrusComment      start=/{/ end=/}/ contains=papyrusTodo
syn match   papyrusComment      /;.*$/ contains=papyrusTodo

syn keyword papyrusType         Bool Boolean Int Integer Float String
syn keyword papyrusConstant     None    Self Parent
syn keyword papyrusBoolean      true false

syn keyword papyrusStorage      Global Native Property EndProperty Auto AutoReadOnly
syn keyword papyrusOperator     Length New As
syn match   papyrusOperator     /[-+*/,=%.!<>]/
syn match   papyrusOperator     /[-+*/<>!=%]=/
syn match   papyrusOperator     /&&/
syn match   papyrusOperator     /||/
syn match   papyrusOperator     /\[\s*\]/
syn match   papyrusOperator     /(\s*)/


syn match   papyrusNumber       /[0-9]\+/
syn match   papyrusNumber       /[0-9]*\.[0-9]\+/
syn match   papyrusNumber       /-[0-9]\+/
syn match   papyrusNumber       /0x[0-9abcdef]\+/

syn match   papyrusNumber       /-[0-9]\+\.[0-9]+/
syn match   papyrusNumber       /-[0-9]*\.[0-9]+/
syn match   papyrusNumber       /-0x[0-9abcdef]\+/

syn region  papyrusString      start=/"/ skip=/\\"/ end=/"/
syn region  papyrusArray        start=/\[/ end=/\]/ contains=ALL contained

" Basic TES5 Script types via http://www.creationkit.com/Category:Script_Objects
syn keyword papyrusScriptType    Action Activator ActiveMagicEffect Actor ActorBase Alias
syn keyword papyrusScriptType    Ammo Apparatus Armor ArmorAddon AssociationType Book
syn keyword papyrusScriptType    Cell Class ColorForm CombatStyle ConstructibleObject Container
syn keyword papyrusScriptType    Debug Door EffectShader Enchantment EncounterZone Explosion
syn keyword papyrusScriptType    Faction Flora Form FormList Furniture Game GlobalVariable
syn keyword papyrusScriptType    Hazard HeadPart Idle ImageSpaceModifier ImpactDataSet Ingredient Input
syn keyword papyrusScriptType    Key Keyword LeveledActor LeveledItem LeveledSpell Light Location LocationAlias LocationRefType
syn keyword papyrusScriptType    MagicEffect Math Message MiscObject MusicType ObjectReference Outfit
syn keyword papyrusScriptType    Package Perk Potion Projectile Quest
syn keyword papyrusScriptType    Race ReferenceAlias
syn keyword papyrusScriptType    Scene Scroll Shout SKSE SoulGem Sound SoundCategory Spell Static StringUtil
syn keyword papyrusScriptType    TalkingActivator TextureSet Topic TopicInfo
syn keyword papyrusScriptType    UI Utility
syn keyword papyrusScriptType    VisualEffect VoiceType
syn keyword papyrusScriptType    Weapon Weather WordOfPower WorldSpace


" Not currently used
syn match   papyrusIdentifier   "\s*[a-zA-z_][a-zA-Z0-9_]*" contained

" Define the default highlighting.
if version >= 508 || !exists("did_papyrus_syn_inits")
    if version < 508
        let did_papyrus_syn_inits = 1
        command -nargs=+ HiLink hi link <args>
    else
        command -nargs=+ HiLink hi def link <args>
    endif


    HiLink papyrusScript Keyword
    HiLink papyrusKeyword Keyword
    HiLink papyrusScriptType Type
    HiLink papyrusType Type
    HiLink papyrusBoolean Boolean
    HiLink papyrusConditional Conditional
    HiLink papyrusRepeat Repeat
    HiLink papyrusStorage StorageClass

    HiLink papyrusImport Import

    HiLink papyrusComment   Comment
    HiLink papyrusTodo Todo

    HiLink papyrusConstant  Constant
    HiLink papyrusNull  Constant
    HiLink papyrusOperator Operator
    HiLink papyrusNumber Number
    HiLink papyrusString String


    delcommand HiLink
endif
let b:current_syntax = "papyrus"
au BufRead,BufNewFile *.psc set filetype=papyrus

" //////////////////////////////////////////////////////////////////////////////
