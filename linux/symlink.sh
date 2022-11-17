#!/bin/bash

# Usage: bash ./symlink.sh.
#! Please do not sudo bash ./symlink.sh Because $HOME is /root/ when use `sudo bash`

# ? Strict setting of immediate termination if an error occurs.(for test command)
# -u(nounset): During parameter expansion, if there are any variables that have not been set, an error will occur.
# -e(errexit): If a command or pipeline returns a non-zero status, the shell will exit immediately.
# -x(execute): Print commands and their arguments as they are executed.
# -o(option-name): If any command in a pipeline has a non-zero exit status, the entire pipeline will be non-zero.
set -euxo pipefail

# reference: (https://www.reddit.com/r/bashonubuntuonwindows/comments/8dhhrr/is_it_possible_to_get_the_windows_username_from/)
# WSL can assign windows $HOME.
HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  if [ ! "$(command -v powershell.exe)" ]; then
    echo "command \"powershell.exe\" not exists."

    echo "$(tput setaf 1)"Windows or r path is not inherited."$(tput sgr0)"
    exit 1
  fi

  if (which wslpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    WIN_HOME=$(wslpath "$(powershell.exe -command 'echo $HOME')")
  elif (which cygpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    WIN_HOME=$(cygpath "$(powershell.exe -command 'echo $HOME')")
  else
    echo "Not found path changer"
    exit 1
  fi
  HOME_DIR=$WIN_HOME
  export WIN_HOME

  WIN_USER=$(echo "$WIN_HOME" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER
fi

# If the link is to a directory, it will fail.
# (you can force it with -n, but it might be dangerous)

# git
mkdir -p "$HOME"/.config/git
sudo ln -sf "$HOME_DIR"/dotfiles/common/data/git/gitignore-global.txt "$HOME"/.config/git/ignore

# vim
sudo ln -sf "$HOME_DIR"/dotfiles/init.vim "$HOME"/.vimrc

# tmux
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.tmux.conf "$HOME"/.tmux.conf

# Neovim
mkdir -p "$HOME"/.config/nvim
sudo ln -sf "$HOME_DIR"/dotfiles/nvim/init.lua "$HOME"/.config/nvim/init.lua

sudo ln -sf "$HOME_DIR"/dotfiles/nvim/lua "$HOME"/.config/nvim
sudo ln -sf "$HOME_DIR"/dotfiles/nvim/ftplugin "$HOME"/.config/nvim

# mkdir -p "$HOME"/.config/lvim
# sudo ln -sf "$HOME_DIR"/dotfiles/lvim-config.lua "$HOME"/.config/lvim/config.lua

# fish shell
mkdir -p "$HOME"/.config/fish
sudo ln -sf "$HOME_DIR"/dotfiles/linux/fishrc.fish "$HOME"/.config/fish/config.fish

# dot rc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.bashrc "$HOME"/.bashrc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.zshrc "$HOME"/.zshrc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.inputrc "$HOME"/.inputrc

# autokey
if (which autokey) >/dev/null 2>&1 || (which autokey-shell) >/dev/null 2>&1; then
  mkdir -p "$HOME"/.config/autokey/data
  sudo ln -sf "$HOME_DIR"/dotfiles/common/data/autokey "$HOME"/.config/autokey/data
fi
