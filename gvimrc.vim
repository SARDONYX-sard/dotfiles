" NOTE:
" - No plugins are used to achieve portability with a single file (so there is a mix of scripts that should not be written here).
" - kaoriya vim is not applied unless you write colorscheme etc in $HOME/.givmrc.
"
" INFO: Read a configuration file from PowerShell from an arbitrary location.(gvimrc.vim -> .gvimrc)
" ```powershell
" New-Item -Type SymbolicLink -Target "$HOME/dotfiles/gvimrc.vim -Path $HOME/.gvimrc
" ```

" colorscheme slate " slate|evening
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
" SPDX-FileCopyrightText: (C) 2018 MTDL9
" SPDX-License-Identifier: MIT
"
" Vim syntax file
" Language:         Generic log file
" Maintainer:       MTDL9 <https://github.com/MTDL9>
" Latest Revision:  2020-08-23
" URL: https://github.com/MTDL9/vim-log-highlighting
function! LoadLogSyntax()
    set filetype=log

    " Operators
    "---------------------------------------------------------------------------
    syn match logOperator display '[;,\?\:\.\<=\>\~\/\@\!$\%&\+\-\|\^(){}\*#]'
    syn match logBrackets display '[\[\]]'
    syn match logEmptyLines display '-\{3,}'
    syn match logEmptyLines display '\*\{3,}'
    syn match logEmptyLines display '=\{3,}'
    syn match logEmptyLines display '- - '


    " Constants
    "---------------------------------------------------------------------------
    syn match logNumber       '\<-\?\d\+\>'
    syn match logHexNumber    '\<0[xX]\x\+\>'
    syn match logHexNumber    '\<\d\x\+\>'
    syn match logBinaryNumber '\<0[bB][01]\+\>'
    syn match logFloatNumber  '\<\d.\d\+[eE]\?\>'

    syn keyword logBoolean    TRUE FALSE True False true false
    syn keyword logNull       NULL Null null

    syn region logString      start=/"/ end=/"/ end=/$/ skip=/\\./
    " Quoted strings, but no match on quotes like "don't", "plurals' elements"
    syn region logString      start=/'\(s \|t \| \w\)\@!/ end=/'/ end=/$/ end=/s / skip=/\\./


    " Dates and Times
    "---------------------------------------------------------------------------
    " Matches 2018-03-12T or 12/03/2018 or 12/Mar/2018
    syn match logDate '\d\{2,4}[-\/]\(\d\{2}\|Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\)[-\/]\d\{2,4}T\?'
    " Matches 8 digit numbers at start of line starting with 20
    syn match logDate '^20\d\{6}'
    " Matches Fri Jan 09 or Feb 11 or Apr  3 or Sun 3
    syn keyword logDate Mon Tue Wed Thu Fri Sat Sun Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec nextgroup=logDateDay
    syn match logDateDay '\s\{1,2}\d\{1,2}' contained

    " Matches 12:09:38 or 00:03:38.129Z or 01:32:12.102938 +0700
    syn match logTime '\d\{2}:\d\{2}:\d\{2}\(\.\d\{2,6}\)\?\(\s\?[-+]\d\{2,4}\|Z\)\?\>' nextgroup=logTimeZone,logSysColumns skipwhite

    " Follows logTime, matches UTC or PDT 2019 or 2019 EDT
    syn match logTimeZone '[A-Z]\{2,5}\>\( \d\{4}\)\?' contained
    syn match logTimeZone '\d\{4} [A-Z]\{2,5}\>' contained


    " Entities
    "---------------------------------------------------------------------------
    syn match logUrl        'http[s]\?:\/\/[^\n|,; '"]\+'
    syn match logDomain     /\v(^|\s)(\w|-)+(\.(\w|-)+)+\s/
    syn match logUUID       '\w\{8}-\w\{4}-\w\{4}-\w\{4}-\w\{12}'
    syn match logMD5        '\<[a-z0-9]\{32}\>'
    syn match logIPV4       '\<\d\{1,3}\(\.\d\{1,3}\)\{3}\>'
    syn match logIPV6       '\<\x\{1,4}\(:\x\{1,4}\)\{7}\>'
    syn match logMacAddress '\<\x\{2}\(:\x\{2}\)\{5}'
    syn match logFilePath   '\<\w:\\[^\n|,; ()'"\]{}]\+'
    syn match logFilePath   '[^a-zA-Z0-9"']\@<=\/\w[^\n|,; ()'"\]{}]\+'


    " Syslog Columns
    "---------------------------------------------------------------------------
    " Syslog hostname, program and process number columns
    syn match logSysColumns '\w\(\w\|\.\|-\)\+ \(\w\|\.\|-\)\+\(\[\d\+\]\)\?:' contains=logOperator,logSysProcess contained
    syn match logSysProcess '\(\w\|\.\|-\)\+\(\[\d\+\]\)\?:' contains=logOperator,logNumber,logBrackets contained


    " XML Tags
    "---------------------------------------------------------------------------
    " Simplified matches, not accurate with the spec to avoid false positives
    syn match logXmlHeader       /<?\(\w\|-\)\+\(\s\+\w\+\(="[^"]*"\|='[^']*'\)\?\)*?>/ contains=logString,logXmlAttribute,logXmlNamespace
    syn match logXmlDoctype      /<!DOCTYPE[^>]*>/ contains=logString,logXmlAttribute,logXmlNamespace
    syn match logXmlTag          /<\/\?\(\(\w\|-\)\+:\)\?\(\w\|-\)\+\(\(\n\|\s\)\+\(\(\w\|-\)\+:\)\?\(\w\|-\)\+\(="[^"]*"\|='[^']*'\)\?\)*\s*\/\?>/ contains=logString,logXmlAttribute,logXmlNamespace
    syn match logXmlAttribute    contained "\w\+=" contains=logOperator
    syn match logXmlAttribute    contained "\(\n\|\s\)\(\(\w\|-\)\+:\)\?\(\w\|-\)\+\(=\)\?" contains=logXmlNamespace,logOperator
    syn match logXmlNamespace    contained "\(\w\|-\)\+:" contains=logOperator
    syn region logXmlComment     start=/<!--/ end=/-->/
    syn match logXmlCData        /<!\[CDATA\[.*\]\]>/
    syn match logXmlEntity       /&#\?\w\+;/


    " Levels
    "---------------------------------------------------------------------------
    syn keyword logLevelEmergency EMERGENCY EMERG
    syn keyword logLevelAlert ALERT
    syn keyword logLevelCritical CRITICAL CRIT FATAL
    syn keyword logLevelError ERROR ERR FAILURE SEVERE
    syn keyword logLevelWarning WARNING WARN
    syn keyword logLevelNotice NOTICE
    syn keyword logLevelInfo INFO
    syn keyword logLevelDebug DEBUG FINE
    syn keyword logLevelTrace TRACE FINER FINEST


    " Highlight links
    "---------------------------------------------------------------------------
    hi def link logNumber Number
    hi def link logHexNumber Number
    hi def link logBinaryNumber Number
    hi def link logFloatNumber Float
    hi def link logBoolean Boolean
    hi def link logNull Constant
    hi def link logString String

    hi def link logDate Identifier
    hi def link logDateDay Identifier
    hi def link logTime Function
    hi def link logTimeZone Identifier

    hi def link logUrl Underlined
    hi def link logDomain Label
    hi def link logUUID Label
    hi def link logMD5 Label
    hi def link logIPV4 Label
    hi def link logIPV6 ErrorMsg
    hi def link logMacAddress Label
    hi def link logFilePath Conditional

    hi def link logSysColumns Conditional
    hi def link logSysProcess Include

    hi def link logXmlHeader Function
    hi def link logXmlDoctype Function
    hi def link logXmlTag Identifier
    hi def link logXmlAttribute Type
    hi def link logXmlNamespace Include
    hi def link logXmlComment Comment
    hi def link logXmlCData String
    hi def link logXmlEntity Special

    hi def link logOperator Operator
    hi def link logBrackets Comment
    hi def link logEmptyLines Comment

    hi def link logLevelEmergency ErrorMsg
    hi def link logLevelAlert ErrorMsg
    hi def link logLevelCritical ErrorMsg
    hi def link logLevelError ErrorMsg
    hi def link logLevelWarning WarningMsg
    hi def link logLevelNotice Character
    hi def link logLevelInfo Repeat
    hi def link logLevelDebug Debug
    hi def link logLevelTrace Comment

    let b:current_syntax = 'log'
endfunction

au BufNewFile,BufRead *.log call LoadLogSyntax()
au BufNewFile,BufRead *_log call LoadLogSyntax()
au BufNewFile,BufRead *.LOG call LoadLogSyntax()
au BufNewFile,BufRead *_LOG call LoadLogSyntax()
" //////////////////////////////////////////////////////////////////////////////
