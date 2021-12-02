#!/bin/bash
# echo "[$(tput setaf 4)info$(tput sgr0)/enter] common/bash_aliases.sh"

alias ~='cd ~'
alias -- -='cd -'

# Represented by number of dots
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Expressed in numbers
alias ..2='cd ../..'
alias ..3='cd ../../..'

# some more ls aliases
alias l="ls -GF"
alias la="ls -aGF"
alias ll='ls -lA'
alias lla="ls -alGF"
alias ls='ls --color=auto --show-control-chars --time-style=long-iso -FH -A'

alias relogin='exec $SHELL -l'
alias re=relogin

alias c=clear
alias cls=reset

alias df='df -h'
alias du='du -h'
alias du1='du -d1'

# -- vim
alias g+='g++ -Wall -Wextra -Wpedantic -fsanitize=undefined -g'
alias v="vim"
alias vi="vim -u NONE"
alias vim="nvim"

# -- man
function man_vim() {
  vim "+runtime! ftplugin/man.vim | Man $* | only"
}
alias man=man_vim

# -- git
alias g="git"
alias ga="git add"
alias gc="git commit"
alias gl="git log"
alias gp="git push"
alias gs="git status --short"

# -- some
alias dk="docker"
alias dc="docker-compose"
alias tf="terraform"

# enable color support of ls, less and man, and also add handy aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# read after .bashrc
alias chrome='/mnt/c/ProgramFiles(x86)/Google/Chrome/Application/chrome.exe'
