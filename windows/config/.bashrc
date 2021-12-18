#!/usr/bin/env bash

# インタラクティブではない場合，終了
case $- in
*i*) ;;
*) return ;;
esac

# ---- vim の環境変数を削除
unset VIM
unset VIMRUNTIME
unset MYVIMRC
unset MYGVIMRC

# ---- hisotry 向上

# i: 直前の履歴 30件を表示する。引数がある場合は過去 1000件を検索
function i {
  if [ "$1" ]; then history 1000 | grep "$@"; else history 30; fi
}

# I: 直前の履歴 30件を表示する。引数がある場合は過去のすべてを検索
function I {
  if [ "$1" ]; then history | grep "$@"; else history 30; fi
}

export PATH="$HOME/.pyenv/pyenv-win/bin:$PATH"
export PATH="$HOME/.pyenv/pyenv-win/versions/3.8.10:$PATH"

# --------------------------------------------------------------------------------------------------
# Prompt Design
# --------------------------------------------------------------------------------------------------
usrPath="/usr/share"

# ---- git の情報を表示
[ -f "${usrPath}/git/completion/git-prompt.sh" ] && source ${usrPath}/git/completion/git-prompt.sh
[ -f "${usrPath}/git/completion/git-completion.bash" ] && source ${usrPath}/git/completion/git-completion.bash

export GIT_PS1_SHOWDIRTYSTATE=true
export PS1='\[\033[32m\]\u@ \[\033[1;33m\]\w\[\033[34m\]$(__git_ps1)\[\033[00m\]'$'\n\$ '

# --------------------------------------------------------------------------------------------------
#  aliases and functions
# --------------------------------------------------------------------------------------------------
# Common
source "${HOME}"/dotfiles/common/read-common-settings.sh

# Msys2(Windows)-only
if [ -e /c/ ]; then
  function wincmd() {
    CMD=$1
    shift
    $CMD "$*" 2>&1 | iconv -f CP932 -t UTF-8
  }

  alias cmd='winpty cmd'
  alias pwsh='winpty powershell'
  alias ipconfig='wincmd ipconfig'
  alias netstat='wincmd netstat'
  alias netsh='wincmd netsh'
  alias ping='wincmd /c/windows/system32/ping'
  alias s='scoop'
fi
