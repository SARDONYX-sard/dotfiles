#!/usr/bin/env bash

function readFile {
  PATH="$1"
  if [ -f "$PATH" ]; then
    # shellcheck disable=SC1090
    . "$PATH"
  else
    echo "$(tput setaf 1) WARNING$(tput sgr0): \"$PATH\" not found"
  fi
}

DIR_PATH="${HOME}/common"
# customs
ALIAS_FILE="${DIR_PATH}/.bash_aliases"         # alias
FUNCTIONS_FILE="${DIR_PATH}/bash_functions.sh" # functions
ENV_PATH="${DIR_PATH}/.env_path.sh"            # env path

readFile "$FUNCTIONS_FILE"
readFile "$ENV_PATH"
readFile "$ALIAS_FILE"

# apt
alias agi='sudo apt install'
alias agr='sudo apt remove'
alias agu='sudo apt update'
