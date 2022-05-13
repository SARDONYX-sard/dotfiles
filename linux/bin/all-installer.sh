#!/usr/bin/env bash

#? need 585 MB Disk volume

HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  # windows home directory
  WIN_HOME=$(which scoop | sed -E 's/scoop.*//g')
  export WIN_HOME
  # windows user name
  WIN_USER=$(echo "$WIN_HOME" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER

  HOME_DIR=$WIN_HOME
fi

export HOME_DIR

if [ ! -d "$HOME_DIR"/dotfiles ]; then
  echo "Not found $HOME_DIR/dotfiles/ dirctory."
  exit 1
fi

if (which yay) >/dev/null 2>&1; then
  python3 "$HOME_DIR"/dotfiles/linux/bin/installers/util-packages.py --manager yay
elif (which pacman) >/dev/null 2>&1; then
  python3 "$HOME_DIR"/dotfiles/linux/bin/installers/util-packages.py --manager pacman
elif (which apt) >/dev/null 2>&1; then
  python3 "$HOME_DIR"/dotfiles/linux/bin/installers/util-packages.py --manager apt
else
  echo "Not found package manager."
  exit 1
fi

bash "$HOME_DIR"/dotfiles/linux/bin/installers/gdb-peda.sh
bash "$HOME_DIR"/dotfiles/linux/bin/installers/lvim.sh
bash "$HOME_DIR"/dotfiles/linux/bin/installers/oh-my-posh.sh #! need brew command.

if [ ! "$IS_LIGHT" ]; then
  (! which rustup) && bash "$HOME_DIR"/dotfiles/linux/bin/installers/rustup.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/asdf.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/homebrew.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/ocaml.sh
  python3 "$HOME_DIR"/dotfiles/linux/bin/installers/pip.py
fi
