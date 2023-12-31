" kaoriya vim is not applied unless you write colorscheme etc in $HOME/.givmrc.
"
" INFO: Example command to read a configuration file from PowerShell from an arbitrary location
" gvimrc.vim -> .gvimrc
" ```powershell
" New-Item -Type SymbolicLink -Target "$HOME\dotfiles/gvimrc.vim -Path $HOME/.gvimrc
" ```

colorscheme slate " slate|evening
set transparency=220

" ==============================================================================
" File:         colors/onedark.vim
" Description:  Colors based on onedark.vim by joshdick
" Maintainer:   bfrg <https://github.com/bfrg>
" Last Change:  Feb 13, 2021
" License:      Same as Vim itself (see :h license)
" ==============================================================================
function! SetupOnedarkColorScheme() abort
    hi clear

    let g:colors_name = 'onedark'

    let g:terminal_ansi_colors = [
            \ '#202329', '#BE5046', '#98C379', '#D19A66', '#61AFEF', '#C678DD', '#56B6C2', '#5C6370',
            \ '#3E4452', '#E06C75', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF'
            \ ]

    " Editor UI (see :help highlight-default)
    hi Normal               ctermbg=235  ctermfg=145  guibg=#282C34 guifg=#ABB2BF cterm=NONE      gui=NONE
    hi Terminal             ctermbg=234  ctermfg=NONE guibg=#24272E guifg=NONE    cterm=NONE      gui=NONE
    hi Directory            ctermbg=NONE ctermfg=39   guibg=NONE    guifg=#61AFEF cterm=NONE      gui=NONE
    hi Visual               ctermbg=237  ctermfg=NONE guibg=#3E4452 guifg=NONE    cterm=NONE      gui=NONE
    hi VisualNOS            ctermbg=237  ctermfg=NONE guibg=#3E4452 guifg=NONE    cterm=bold      gui=bold
    hi Folded               ctermbg=NONE ctermfg=59   guibg=NONE    guifg=#5C6370 cterm=NONE      gui=NONE
    hi ColorColumn          ctermbg=236  ctermfg=NONE guibg=#2C323C guifg=NONE    cterm=NONE      gui=NONE
    hi CursorLine           ctermbg=236  ctermfg=NONE guibg=#2C323C guifg=NONE    cterm=NONE      gui=NONE
    hi Cursor               ctermbg=255  ctermfg=16   guibg=#EEEEEE guifg=#000000 cterm=NONE      gui=NONE
    hi Search               ctermbg=180  ctermfg=235  guibg=#E5C07B guifg=#282C34 cterm=NONE      gui=NONE
    hi IncSearch            ctermbg=170  ctermfg=235  guibg=#C678DD guifg=#282C34 cterm=NONE      gui=NONE
    hi MatchParen           ctermbg=39   ctermfg=233  guibg=#61AFEF guifg=#181A1F cterm=NONE      gui=NONE
    hi Conceal              ctermbg=NONE ctermfg=39   guibg=NONE    guifg=#61AFEF cterm=NONE      gui=NONE
    hi VertSplit            ctermbg=NONE ctermfg=233  guibg=NONE    guifg=#202329 cterm=NONE      gui=NONE
    hi QuickFixLine         ctermbg=114  ctermfg=235  guibg=#98C379 guifg=#282C34 cterm=NONE      gui=NONE

    " Sign column and line column
    hi CursorLineNr         ctermbg=NONE ctermfg=NONE guibg=NONE   guifg=NONE     cterm=NONE      gui=NONE
    hi LineNr               ctermbg=NONE ctermfg=238  guibg=NONE   guifg=#4B5263  cterm=NONE      gui=NONE

    " Top and bottom UI
    hi ErrorMsg             ctermbg=NONE ctermfg=204  guibg=NONE    guifg=#E06C75 cterm=NONE      gui=NONE
    hi ModeMsg              ctermbg=NONE ctermfg=38   guibg=NONE    guifg=#56B6C2 cterm=bold      gui=bold
    hi MoreMsg              ctermbg=NONE ctermfg=38   guibg=NONE    guifg=#56B6C2 cterm=NONE      gui=NONE
    hi WarningMsg           ctermbg=NONE ctermfg=180  guibg=NONE    guifg=#E5C07B cterm=NONE      gui=NONE
    hi Question             ctermbg=NONE ctermfg=170  guibg=NONE    guifg=#C678DD cterm=NONE      gui=NONE
    hi WildMenu             ctermbg=39   ctermfg=235  guibg=#61AFEF guifg=#282C34 cterm=NONE      gui=NONE
    hi StatusLine           ctermbg=233  ctermfg=145  guibg=#202329 guifg=#ABB2BF cterm=NONE      gui=NONE
    hi StatusLineNC         ctermbg=233  ctermfg=59   guibg=#202329 guifg=#5C6370 cterm=NONE      gui=NONE
    hi TabLineSel           ctermbg=NONE ctermfg=145  guibg=NONE    guifg=#ABB2BF cterm=bold      gui=bold
    hi TabLineFill          ctermbg=233  ctermfg=NONE guibg=#202329 guifg=NONE    cterm=NONE      gui=NONE

    " vimdiff
    hi DiffAdd              ctermbg=114  ctermfg=16   guibg=#98C379 guifg=#000000 cterm=NONE      gui=NONE
    hi DiffDelete           ctermbg=204  ctermfg=16   guibg=#E06C75 guifg=#000000 cterm=NONE      gui=NONE
    hi DiffText             ctermbg=16   ctermfg=180  guifg=#000000 guibg=#E5C07B cterm=NONE      gui=NONE
    hi DiffChange           ctermbg=38   ctermfg=16   guibg=#56B6C2 guifg=#000000 cterm=NONE      gui=NONE

    " vimdiff with smoother colors
    " hi DiffAdd              ctermbg=22   ctermfg=NONE guibg=#223a1f guifg=NONE    cterm=NONE      gui=NONE
    " hi DiffDelete           ctermbg=52   ctermfg=16   guibg=#3A1F22 guifg=#000000 cterm=NONE      gui=NONE
    " hi DiffText             ctermbg=20   ctermfg=NONE guibg=#35384D guifg=NONE    cterm=NONE      gui=NONE
    " hi DiffChange           ctermbg=17   ctermfg=NONE guibg=#1f223a guifg=NONE    cterm=NONE      gui=NONE

    " Completion menu
    hi Pmenu                ctermbg=237  ctermfg=NONE guibg=#3E4452 guifg=NONE    cterm=NONE      gui=NONE
    hi PmenuSel             ctermbg=39   ctermfg=235  guibg=#61AFEF guifg=#282C34 cterm=NONE      gui=NONE
    hi PmenuSbar            ctermbg=238  ctermfg=NONE guibg=#3B4048 guifg=NONE    cterm=NONE      gui=NONE
    hi PmenuThumb           ctermbg=145  ctermfg=NONE guibg=#ABB2BF guifg=NONE    cterm=NONE      gui=NONE
    hi CompletePopup        ctermbg=173  ctermfg=235  guibg=#D19A66 guifg=#282C34 cterm=NONE      gui=NONE

    " Languages (see :help W18)
    hi Comment              ctermbg=NONE ctermfg=59   guibg=NONE    guifg=#5C6370 cterm=NONE      gui=NONE
    hi Constant             ctermbg=NONE ctermfg=173  guibg=NONE    guifg=#D19A66 cterm=NONE      gui=NONE
    hi Error                ctermbg=NONE ctermfg=204  guibg=NONE    guifg=#E06C75 cterm=reverse   gui=reverse
    hi PreProc              ctermbg=NONE ctermfg=38   guibg=NONE    guifg=#56B6C2 cterm=NONE      gui=NONE
    hi PreCondit            ctermbg=NONE ctermfg=38   guibg=NONE    guifg=#56B6C2 cterm=bold      gui=bold
    hi Identifier           ctermbg=NONE ctermfg=204  guibg=NONE    guifg=#E06C75 cterm=NONE      gui=NONE
    hi Ignore               ctermbg=NONE ctermfg=NONE guibg=NONE    guifg=NONE    cterm=NONE      gui=NONE
    hi SpecialComment       ctermbg=NONE ctermfg=59   guibg=NONE    guifg=#5C6370 cterm=bold      gui=bold
    hi Statement            ctermbg=NONE ctermfg=170  guibg=NONE    guifg=#C678DD cterm=NONE      gui=NONE
    hi String               ctermbg=NONE ctermfg=114  guibg=NONE    guifg=#98C379 cterm=NONE      gui=NONE
    hi Special              ctermbg=NONE ctermfg=39   guibg=NONE    guifg=#61AFEF cterm=NONE      gui=NONE
    hi Todo                 ctermbg=NONE ctermfg=145  guibg=NONE    guifg=#ABB2BF cterm=bold      gui=bold
    hi Type                 ctermbg=NONE ctermfg=180  guibg=NONE    guifg=#E5C07B cterm=NONE      gui=NONE
    hi Underlined           ctermbg=NONE ctermfg=NONE guibg=NONE    guifg=NONE    cterm=underline gui=underline

    " Spell
    hi SpellBad             ctermbg=NONE ctermfg=NONE guibg=NONE    guifg=NONE    cterm=undercurl gui=undercurl ctermul=196 guisp=Red
    hi SpellCap             ctermbg=NONE ctermfg=NONE guibg=NONE    guifg=NONE    cterm=undercurl gui=undercurl ctermul=226 guisp=Yellow
    hi SpellLocal           ctermbg=NONE ctermfg=NONE guibg=NONE    guifg=NONE    cterm=undercurl gui=undercurl ctermul=51  guisp=Cyan
    hi SpellRare            ctermbg=NONE ctermfg=NONE guibg=NONE    guifg=NONE    cterm=undercurl gui=undercurl ctermul=201 guisp=Magenta

    " Highlight links
    hi! link SignColumn         LineNr
    hi! link TabLine            StatusLineNC
    hi! link StatusLineTerm     StatusLine
    hi! link StatusLineTermNC   StatusLineNC
    hi! link FoldColumn         Folded
    hi! link NonText            LineNr
    hi! link CursorColumn       CursorLine
    hi! link SpecialKey         NonText
    hi! link Title              Identifier

    hi link Number              Constant
    hi link Boolean             Constant
    hi link Float               Constant
    hi link Character           String
    hi link Keyword             Statement
    hi link Conditional         Statement
    hi link Repeat              Statement
    hi link Label               Statement
    hi link Operator            Statement
    hi link Exception           Statement
    hi link Define              PreProc
    hi link Include             PreProc
    hi link Macro               PreProc
    hi link Function            Special
    hi link StorageClass        Type
    hi link Structure           Type
    hi link Typedef             Type
    hi link SpecialChar         Statement
    hi link Tag                 Special
    hi link Delimiter           Normal
    hi link Debug               Normal
    hi link CursorIM            Cursor
    hi link EndOfBuffer         LineNr
endfunction

call SetupOnedarkColorScheme()
