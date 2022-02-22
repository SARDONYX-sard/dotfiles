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

# --------------------------------------------------------------------------------------------------
# some more aliases
# --------------------------------------------------------------------------------------------------
if (which bat) >/dev/null 2>&1; then # dev/null reference (https://qiita.com/ritukiii/items/b3d91e97b71ecd41d4ea)
  alias cat='bat'                    # need rust or apt
elif (which batcat) >/dev/null 2>&1; then
  alias cat='batcat' # need rust or apt
fi

if (which br) >/dev/null 2>&1; then
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
alias gs="git status --short"
alias gp="git push"
alias ga="git add"
alias gc="git commit"
alias gl="git log"

# --------------------------------------------------------------------------------------------------
# grep
# --------------------------------------------------------------------------------------------------
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
if (which rg) >/dev/null 2>&1; then
  alias grep='rg' # need rust or apt
fi

# --------------------------------------------------------------------------------------------------
# ls
# --------------------------------------------------------------------------------------------------
alias l="ls -GF"     # show grid `G`
alias la="ls -aGF"   # show dotfile `a` show grid `G`
alias ll='ls -al'    # list permission status
alias lla="ls -alGF" # list grid permission status

if (which exa) >/dev/null 2>&1; then
  alias ls='exa --color=auto --time-style=long-iso -FH --icons' # need rust or apt
elif (which lsd) >/dev/null 2>&1; then
  alias l="lsd -F"     # Append indicator `F`
  alias la="lsd -aF"   # show dotfile `a`, Append indicator `F`
  alias ll='lsd -al'   # show dotfile `a`, list permission status `l`
  alias lla="lsd -alF" # show dotfile `a`, list permission status `l`, Append indicator `F`
  alias ls='lsd'       # need rust or scoop(scoop install lsd)
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
if (which lvim) >/dev/null 2>&1; then
  alias vim="lvim"
elif (which nvim) >/dev/null 2>&1; then
  alias vim="nvim"
fi

# -- man
function man_vim() {
  vim "+runtime! ftplugin/man.vim | Man $* | only"
}
alias man=man_vim
