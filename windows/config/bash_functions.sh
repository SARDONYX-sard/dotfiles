#!/bin/bash

echo 'windows/bash_functions.sh'

# shellcheck disable=SC1091
source "${HOME}/dotfiles/common/bash_functions.sh"

function pinst() {
  pacman -S "mingw-w64-i686-$1"
}

function puninst() {
  pacman -Rs "mingw-w64-i686-$1"
}
