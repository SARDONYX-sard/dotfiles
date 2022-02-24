#!/usr/bin/env bash

bash "$HOME_DIR"/dotfiles/linux/bin/installers/apt.sh

if (which apt) >/dev/null 2>&1; then
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/asdf.sh
fi

bash "$HOME_DIR"/dotfiles/linux/bin/installers/autosuggestions.sh
if (which brew) >/dev/null 2>&1; then
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/homebrew.sh
fi

python3 "$HOME_DIR"/dotfiles/linux/bin/installers/pip.py

if (which rustup) >/dev/null 2>&1; then
  [ "$1" = "light-mode" ] || bash "$HOME_DIR"/dotfiles/linux/bin/installers/rustup.sh
fi
