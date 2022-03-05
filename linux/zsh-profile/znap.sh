#!/usr/bin/env bash

# Download Znap, if it's not there yet.
[[ -f ~/Git/zsh-snap/znap.zsh ]] ||
  git clone --depth 1 -- \
    https://github.com/marlonrichert/zsh-snap.git ~/Git/zsh-snap

source ~/Git/zsh-snap/znap.zsh # Start Znap

function read_znap() {
  local plugin="$1"
  plugin_name=$(echo "${plugin}" | awk -F "/" '{ print $NF }')

  [ ! -e "$HOME"/Git/"$plugin_name" ] && znap install "$plugin"
  source "$HOME"/Git/"$plugin_name"/"$plugin_name".plugin.zsh #! msys2 will give an error, so load directly.
}

plugins=(
  marlonrichert/zsh-autocomplete
  zsh-users/zsh-autosuggestions
  zdharma-continuum/fast-syntax-highlighting
)

for plugin in "${plugins[@]}"; do
  if [ -e /mnt/c ]; then
    znap source "${plugin}" # `znap source` automatically downloads and starts your plugins.

  elif [ -e /c ]; then
    read_znap "${plugin}"
  fi
done

# `znap eval` caches and runs any kind of command output for you.
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# shellcheck disable=SC2016,SC2059
# `znap function` lets you lazy-load features you don't always need.
znap function _pyenv pyenvn 'eval "$( pyenv init - --no-rehash )"'
compctl -K _pyenv pyenv
