#!/bin/bash

if [ "$(whoami)" != "root" ] && [ "$SUDO_USER" != "" ]; then
  echo "Please run with sudo."
  exit 1
fi

# ? Strict setting of immediate termination if an error occurs.(for test command)
# -u(nounset): During parameter expansion, if there are any variables that have not been set, an error will occur.
# -e(errexit): If a command or pipeline returns a non-zero status, the shell will exit immediately.
# -x(execute): Print commands and their arguments as they are executed.
# -o(option-name): If any command in a pipeline has a non-zero exit status, the entire pipeline will be non-zero.
set -euxo pipefail

# --------------------------------------------------------------------------------------------------
# Constant variables
# --------------------------------------------------------------------------------------------------
# - msys2 or WSL => windows $HOME (e.g. /mnt/c/Users/SARDONYX)
# - Linux => $HOME
HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  if [ ! "$(command -v cmd.exe)" ]; then #! use cmd.exe, powershell.exe is very slowly
    echo "command \"cmd.exe\" not exists."
    echo "$(tput setaf 1)"Windows or r path is not inherited."$(tput sgr0)"
    exit 1
  fi

  if (command -v wslpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(wslpath "$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>/dev/null)" | sed -E 's/\r//g')
  elif (command -v cygpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(cygpath "$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>/dev/null)" | sed -E 's/\r//g')
  else
    echo "Not found path changer"
    exit 1
  fi

  WIN_USER=$(echo "$HOME_DIR" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER
fi
export HOME_DIR

# --------------------------------------------------------------------------------------------------
# Create symlink
# --------------------------------------------------------------------------------------------------
# If the link is to a directory, it will fail.
# (you can force it with -n, but it might be dangerous)

# git
mkdir -p "$HOME"/.config/git
sudo ln -sf "$HOME_DIR"/dotfiles/common/data/git/gitignore-global.txt "$HOME"/.config/git/ignore
sudo ln -sf "$HOME_DIR"/dotfiles/common/data/git/git-config.txt "$HOME"/.gitconfig

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

# common env variables for all shell
sudo ln -sf "$HOME_DIR"/dotfiles/common/common_profile.sh "$HOME"/common_profile.sh

# dot rc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.bashrc "$HOME"/.bashrc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.zshrc "$HOME"/.zshrc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.inputrc "$HOME"/.inputrc

# autokey
if (command -v autokey) >/dev/null 2>&1 || (command -v autokey-shell) >/dev/null 2>&1; then
  mkdir -p "$HOME"/.config/autokey/data
  sudo ln -sf "$HOME_DIR"/dotfiles/common/data/autokey "$HOME"/.config/autokey/data
fi
