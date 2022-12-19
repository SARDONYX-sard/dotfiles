#!/usr/bin/env bash

function check_deps() {
  local deps_array=(
    "command"
    "tar"
    "wget"
  )

  local no_deps="false"

  for dep in "${deps_array[@]}"; do
    (command -v "${dep}") >/dev/null 2>&1 && printf "%s not found" dep && no_deps="true"
  done

  [ $no_deps == "true" ] && exit 1
}
check_deps

(command -v nvim) >/dev/null 2>&1 && printf "oh-my-posh already installed." && exit 0

wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb -O "$HOME"/nvim-linux64.deb
sudo apt install "$HOME"/nvim-linux64.deb || read -rep "dangerous fix? y/n" -i "n" answer
test "${answer}" == "y" && sudo dpkg -i --force-overwrite "$HOME"/nvim-linux64.deb

# wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz -o "$HOME"/nvim-linux64.tar.gz
# tar zxf nvim-linux64.tar.gz
# sudo mv "$HOME"/nvim-linux64/bin/nvim /usr/local/bin
# rm "$HOME"/nvim-linux64.tar.gz ./nvim-linux64
