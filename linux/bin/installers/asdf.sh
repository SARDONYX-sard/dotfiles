#!/usr/bin/env bash

# asdf installer
# - asdf: languages manager
# - dependencies: curl git

function message() {
  local message=$1
  local state=$2

  local red
  red="$(tput setaf 1)"
  local green
  green="$(tput setaf 2)"
  local yellow
  yellow="$(tput setaf 3)"
  local blue
  blue="$(tput setaf 4)"
  local reset_color
  reset_color="$(tput sgr0)"

  case ${state} in
  error)
    echo "${red}""[Err] ${message}""${reset_color}"
    ;;
  success)
    echo "${green}""[Success] ${message}""${reset_color}"
    ;;
  warn)
    echo "${yellow}""[Warn] ${message}""${reset_color}"
    ;;
  info)
    echo "${blue}""[Info] ${message}""${reset_color}"
    ;;
  *)
    echo "${message}"
    ;;
  esac

}

function check_cmd() {
  local command="$1"
  local fallback_cmd="$2"

  if (! command -v "${command}") >/dev/null 2>&1; then
    eval "${fallback_cmd}"
  fi
}

function check_commands() {
  for command in "${@}"; do
    check_cmd "${command}" "message \"${command} is required to run this script..\" \"error\""
  done
}

check_commands "curl" "git"

# http://asdf-vm.com/guide/getting-started.html#_1-install-dependencies

message "asdf installing..." "info"

if (! command -v asdf) >/dev/null 2>&1; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
fi

source . "$HOME"/.bashrc

asdf update
asdf plugin add nodejs
asdf plugin add ruby

#? The rust plugin is deprecated because rustup allows you to put a .rust-toolchain file in your project.
# asdf plugin add rust

if [[ -n "${IS_LIGHT}" ]]; then
  message "Light mode enabled. no install languages." "info"
else
  asdf install nodejs lts
  # asdf install python latest
  # asdf install ruby latest

  "nodejs lts" >>"${HOME}"/.tool-versions

  corepack enable pnpm yarn npm
  asdf reshim
fi

if (! command -v fish) >/dev/null 2>&1; then
  mkdir -p ~/.config/fish/completions
  and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
fi
