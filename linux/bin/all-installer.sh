#!/usr/bin/env bash

#? need 585 MB Disk volume

# --------------------------------------------------------------------------------------------------
# Constant variables
# --------------------------------------------------------------------------------------------------
# - msys2 or WSL => windows $HOME (e.g. /mnt/c/Users/SARDONYX)
# - Linux => $HOME
HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  if [ ! "$(command -v powershell.exe)" ]; then
    echo "command \"powershell.exe\" not exists."
    echo "$(tput setaf 1)"Windows or r path is not inherited."$(tput sgr0)"
    exit 1
  fi

  if (command -v wslpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(wslpath "$(powershell.exe -command 'echo $HOME')" | sed -E 's/\r//g')
  elif (command -v cygpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(cygpath "$(powershell.exe -command 'echo $HOME')" | sed -E 's/\r//g')
  else
    echo "Not found path changer"
    exit 1
  fi
fi

# --------------------------------------------------------------------------------------------------
# Install
# --------------------------------------------------------------------------------------------------
manager=""
if (command -v yay) >/dev/null 2>&1; then
  yay -S git python3
  manager="yay"
elif (command -v pacman) >/dev/null 2>&1; then
  sudo pacman -S git python3
  manager="pacman"
elif (command -v apt) >/dev/null 2>&1; then
  sudo apt install git python3
  manager="apt"
else
  echo "Not supported package manager."
  exit 1
fi

python3 "$HOME_DIR"/dotfiles/linux/bin/installers/util-packages.py --manager $manager
bash "$HOME_DIR"/dotfiles/linux/bin/installers/gdb-dashboard.sh
bash "$HOME_DIR"/dotfiles/linux/bin/installers/oh-my-posh.sh

if [ ! "$IS_LIGHT" ]; then
  (! command -v rustup) && bash "$HOME_DIR"/dotfiles/linux/bin/installers/rustup.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/asdf.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/homebrew.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/lvim.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/ocaml.sh
  python3 "$HOME_DIR"/dotfiles/linux/bin/installers/pip.py
fi
