#!/usr/bin/env bash

#* This file cannot be executed by itself.
#* (It can be run after constant-values.sh has been executed and dependent variables have been registered.)

#* The following constants are required.
#* - COMMON

function readFile {
  FILE_PATH=$1
  if [ -f "$FILE_PATH" ]; then
    source "$FILE_PATH"
  else
    echo "$(tput setaf 1)WARNING$(tput sgr0): \"$FILE_PATH\" not found"
  fi
}

# not read msys2
[ -e /mnt/c ] && readFile "${COMMON}/.env_path.sh"

# customs
readFile "${COMMON}/bash_aliases.sh"
readFile "${COMMON}/functions/bash_functions.sh"

if [[ $SHELL =~ zsh ]]; then
  readFile "${HOME_DIR}/.config/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# command wrapper
if (which apt) >/dev/null 2>&1; then
  source "${COMMON}"/functions/apt-wrapper.sh
elif (which pacman) >/dev/null 2>&1; then
  source "${COMMON}"/functions/pacman-wrapper.sh
fi
