#!/usr/bin/env bash

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
