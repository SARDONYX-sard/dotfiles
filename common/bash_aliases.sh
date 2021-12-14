#!/bin/bash
# echo "[$(tput setaf 4)info$(tput sgr0)/enter] common/bash_aliases.sh"

# Change directory aliases
alias ....='cd ../../..'
alias ...='cd ../..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..='cd ..'
alias ~='cd ~'

# some more ls aliases

alias l="ls -GF"     # show grid `G`
alias la="ls -aGF"   # show dotfile `a` show grid `G`
alias ll='ls -al'    # list permission status
alias lla="ls -alGF" # list grid permission status
if (which exa >/dev/null 2>&1); then
  alias ls='exa --color=auto --time-style=long-iso -FH --icons' # need rust
fi

alias relogin='exec $SHELL -l'
alias re=relogin

alias c=clear

alias df='df -h'
alias du='du -h'
alias du1='du -d1'

# -- vim
alias v="vim"
alias vi="vim -u NONE"
alias g+='g++ -Wall -Wextra -Wpedantic -fsanitize=undefined -g'
alias vim="nvim"

# -- man
function man_vim() {
  vim "+runtime! ftplugin/man.vim | Man $* | only"
}
alias man=man_vim

# -- git
alias gs="git status --short"
alias gp="git push"
alias ga="git add"
alias gc="git commit"
alias gl="git log"

# -- some
alias dk="docker"
alias dc="docker-compose"
alias tf="terraform"

# enable color support of ls, less and man, and also add handy aliases
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
if (which rg >/dev/null 2>&1); then
  alias grep='rg --color' # need rust
fi

# read after .bashrc
alias chrome='/mnt/c/ProgramFiles(x86)/Google/Chrome/Application/chrome.exe'
