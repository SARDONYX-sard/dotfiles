#!/usr/bin/env bash

zsh_plugins_dir="$HOME/.config/zsh/plugins"

# Download Znap, if it's not there yet.
[[ -f "$zsh_plugins_dir" ]] ||
  git clone --depth 1 -- \
    https://github.com/marlonrichert/zsh-snap.git \
    "$zsh_plugins_dir"/zsh-snap

source "$zsh_plugins_dir"/zsh-snap/znap.zsh # Start Znap

function read_znap() {
  local plugin="$1"
  plugin_name=$(echo "${plugin}" | awk -F "/" '{ print $NF }')
  [ ! -e "$zsh_plugins_dir"/"$plugin_name" ] && znap install "$plugin"

  #! msys2 will give an error, so load directly.
  source "$zsh_plugins_dir"/"$plugin_name"/"$plugin_name".plugin.zsh
}

plugins=(
  lincheney/fzf-tab-completion
  marlonrichert/zsh-autocomplete
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
)

for plugin in "${plugins[@]}"; do
  # `znap source` automatically downloads and starts your plugins.
  ([ -e /mnt/c ] && znap source "${plugin}") || read_znap "${plugin}"
done

#! Manual loading because the plugin manager does not read it well.
source "$zsh_plugins_dir"/fzf-tab-completion/zsh/fzf-zsh-completion.sh

# `znap eval` caches and runs any kind of command output for you.
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# shellcheck disable=SC2016,SC2059
# `znap function` lets you lazy-load features you don't always need.
znap function _pyenv pyenvn 'eval "$( pyenv init - --no-rehash )"'
compctl -K _pyenv pyenv
