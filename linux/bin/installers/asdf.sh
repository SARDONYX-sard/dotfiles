#!/usr/bin/env bash

# asdf installer
# - asdf: languages manager
# - dependencies: curl git

function message() {
  local message=$1
  local state=$2

  case $state in
  error)
    echo "$(tput setaf 1)""[Err] $message""$(tput sgr0)"
    ;;
  success)
    echo "$(tput setaf 2)""[Success] $message""$(tput sgr0)"
    ;;
  warn)
    echo "$(tput setaf 3)""[Warn] $message""$(tput sgr0)"
    ;;
  info)
    echo "$(tput setaf 4)""[Info] $message""$(tput sgr0)"
    ;;
  *)
    echo "$message"
    ;;
  esac

}

function check_cmd() {
  local command="$1"
  local fallback_cmd="$2"

  if (! which "${command}") >/dev/null 2>&1; then
    eval "$fallback_cmd"
  fi
}

function check_commands() {
  for command in "${@}"; do
    check_cmd "$command" "message \"$command is required to run this script..\" \"error\""
  done
}

check_commands "curl" "git"

# http://asdf-vm.com/guide/getting-started.html#_1-install-dependencies

echo "$(tput setaf 4)"adsf installing..."$(tput sgr0)"

if (! which asdf) >/dev/null 2>&1; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
fi

source . "$HOME"/.bashrc

asdf update
asdf plugin add nodejs
asdf plugin add ruby

#? The rust plugin is deprecated because rustup allows you to put a .rust-toolchain file in your project.
# asdf plugin add rust

if [ "$IS_LIGHT" ]; then
  echo "$(tput setaf 2)"Light mode enabled. no install languages."$(tput sgr0)"
else
  asdf install nodejs lts
  # asdf install python latest
  # asdf install ruby latest

  corepack enable pnpm yarn npm
  asdf reshim
fi

if (! which fish) >/dev/null 2>&1; then
  mkdir -p ~/.config/fish/completions
  and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
fi
