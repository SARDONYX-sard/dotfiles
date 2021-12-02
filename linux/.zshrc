# Original source and copyright: Kali Linux and Offensive Security
# https://www.kali.org/docs/policy/kali-linux-open-source-policy/

# Modifications by Erik Larson, or otherwise attributed

# ~/.zshrc file for zsh non-login shells.

setopt auto_pushd          # pushd to the directory you are in
setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt ksharrays           # arrays start at 0
setopt list_packed         # show completion suggestions as closely as possible.
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt
setopt pushd_ignore_dups   # no pushd history is left.

WORDCHARS=${WORDCHARS//\//} # Don't consider certain characters part of the word

# hide EOL sign ('%')
export PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                     # emacs key bindings
bindkey ' ' magic-space                        # do history expansion on space
bindkey '^[[3;5~' kill-word                    # ctrl + Supr
bindkey '^[[1;5C' forward-word                 # ctrl + ->
bindkey '^[[C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                # ctrl + <-
bindkey '^[[D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history # page up
bindkey '^[[6~' end-of-buffer-or-history       # page down
bindkey '^[[Z' undo                            # shift + tab undo last action

# enable completion features
autoload -Uz compinit && compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# History configurations
HISTFILE="$HOME/.zsh_history" #履歴を保存するファイル指定
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  # PROMPT_USER_MACHINE='%F{green}┌──(%B%F{blue}%n%m%b%F{green})-'
  # PROMPT_PATH='[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{green}]'
  # PROMPT_GIT='%F{011}${vcs_info_msg_0_}'
  # PROMPT_LINE2=$'\n%F{green}└─%B%F{blue}$%b%F{reset} '
  # PROMPT='$PROMPT_USER_MACHINE''$PROMPT_PATH''$PROMPT_GIT''$PROMPT_LINE2'
  PROMPT=$'%F{green}┌──[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{green}]%F{yellow}%t %F{green}(%B%F{cyan}%n@%m%b%F{green})\n%F{green}└─%B%F{blue}$%b%F{reset} '
  RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'

  # enable syntax-highlighting (fast-syntax-highlighting.plugin)
  if [ -f $HOME/path/to/fsh/fast-syntax-highlighting.plugin.zsh ]; then
    source "$HOME/path/to/fsh/fast-syntax-highlighting.plugin.zsh"
  fi

else
  PROMPT='%n@%m:%~%# '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm* | rxvt*)
#   TERM_TITLE='\e]0;%n@%m: %~\a'
#   ;;
# *) ;;

# esac

new_line_before_prompt=yes

export LESS_TERMCAP_mb=$'\E[1;31m'  # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'     # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'     # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'  # begin underline
export LESS_TERMCAP_ue=$'\E[0m'     # reset underline

# enable auto-suggestions based on the history
if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  . /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  # change suggestion color
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# add other alias or other config
if [ -f ~/.bash_aliases ]; then
  # shellcheck disable=SC1091
  . "$HOME"/.bash_aliases
fi

# For time measurement
if (which zprof >/dev/null 2>&1); then
  zprof
fi

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
