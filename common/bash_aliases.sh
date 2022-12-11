#!/bin/bash
# echo "[$(tput setaf 4)info$(tput sgr0)/enter] common/bash_aliases.sh"

# --------------------------------------------------------------------------------------------------
# Change directory
# --------------------------------------------------------------------------------------------------
alias ....='cd ../../..'
alias ...='cd ../..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..='cd ..'
alias ~='cd ~'
alias bb='cd -' # back to previous directory

# --------------------------------------------------------------------------------------------------
# some more aliases
# --------------------------------------------------------------------------------------------------
if (command -v bat) >/dev/null 2>&1; then # dev/null reference (https://qiita.com/ritukiii/items/b3d91e97b71ecd41d4ea)
  alias cat='bat'                         # need rust or apt
elif (command -v batcat) >/dev/null 2>&1; then
  alias cat='batcat' # need rust or apt
fi

if (command -v br) >/dev/null 2>&1; then
  alias br='br --conf $HOME_DIR/dotfiles/common/data/broot-config.toml  -s -g -h'
fi

alias c=clear
alias chrome='/mnt/c/ProgramFiles(x86)/Google/Chrome/Application/chrome.exe'
alias ii='start'

# --------------------------------------------------------------------------------------------------
# disk sizes
# --------------------------------------------------------------------------------------------------
alias df='df -h'
alias du='du -h'
alias du1='du -d1'

# --------------------------------------------------------------------------------------------------
# -- Virtual Container
# --------------------------------------------------------------------------------------------------
alias dk="docker"
alias dc="docker-compose"
alias tf="terraform"

# --------------------------------------------------------------------------------------------------
# -- git
# --------------------------------------------------------------------------------------------------
alias cl="git clone"
alias gcm="git commit"
alias gph="git push"
alias gil="git log --short"

alias gp="git push"
alias gc="git commit"

alias ga="git add"
alias gl="git log"
alias gpl="git pull"
alias gs="git status --short"

# --------------------------------------------------------------------------------------------------
# grep
# --------------------------------------------------------------------------------------------------
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# --------------------------------------------------------------------------------------------------
# ls
# --------------------------------------------------------------------------------------------------
# -a, --all: Do not ignore entries starting with .
# -l, --long: Display extended file metadata as a table
# -F, --classify: Append indicator (one of */=>@|) at the end of the file names

# -G, --no-group: in a long listing, don't print group names
alias l="ls -GF"
alias la="ls -aGF"
alias ll='ls -al'
alias lla="ls -alGF"

if (command -v exa) >/dev/null 2>&1; then
  alias ls='exa --color=auto --time-style=long-iso -FH --icons' # need rust or apt
elif (command -v lsd) >/dev/null 2>&1; then
  alias l="lsd -F"
  alias la="lsd -aF"
  alias ll='lsd -al'
  alias lla="lsd -alF"
  alias ls='lsd'
fi

# --------------------------------------------------------------------------------------------------
# login
# --------------------------------------------------------------------------------------------------
alias relogin='exec $SHELL -l'
alias re=relogin

# --------------------------------------------------------------------------------------------------
# -- vim
# --------------------------------------------------------------------------------------------------
alias v="vim"
alias vi="vim -u NONE"
alias g+='g++ -Wall -Wextra -Wpedantic -fsanitize=undefined -g'
if (command -v lvim) >/dev/null 2>&1; then
  alias vim="lvim"
elif (command -v nvim) >/dev/null 2>&1; then
  alias vim="nvim"
fi

# -- man
function man_vim() {
  vim "+runtime! ftplugin/man.vim | Man $* | only"
}

[ ! -e /c ] && alias man=man_vim
