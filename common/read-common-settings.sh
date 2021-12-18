#!/usr/bin/env bash

function readFile {
  FILE_PATH=$1
  if [ -f "$FILE_PATH" ]; then
    source "$FILE_PATH"
  else
    echo "$(tput setaf 1)WARNING$(tput sgr0): \"$FILE_PATH\" not found"
  fi
}

HOME_DIR="$HOME"
if [ -e /mnt/c ]; then # Current shell is WSL ?
  #! Hard-coded the user name for UFN restriction.
  #! You need to change it to your windows user name.
  WINDOWS_USER='SARDONYX'
  HOME_DIR="/mnt/c/Users/$WINDOWS_USER"
  readFile "${HOME_DIR}/dotfiles/common/.env_path.sh" # env path
fi

DIR_PATH="${HOME_DIR}/dotfiles/common"

# customs
readFile "${DIR_PATH}/bash_aliases.sh"   # alias
readFile "${DIR_PATH}/functions/bash_functions.sh" # functions

# command wrapper
if (which apt) >/dev/null 2>&1; then
  source "${DIR_PATH}"/functions/apt-wrapper.sh
elif (which pacman) >/dev/null 2>&1; then
  source "${DIR_PATH}"/functions/pacman-wrapper.sh
fi
