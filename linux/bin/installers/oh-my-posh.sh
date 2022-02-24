#!/usr/bin/env bash

if (which brew) >/dev/null 2>&1; then
  brew install oh-my-posh
  echo "$(tput setaf 4)"Nerd font installing..."$(tput sgr0)"

  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CodeNewRoman.zip -o "$HOME"/CodeNewRoman.zip
  unzip CodeNewRoman.zip -d "$HOME"/.fonts
  fc-cache -fv
  echo "$(tput setaf 2)"Nerd font installed."$(tput sgr0)"

else
  echo "brew not found."
fi
