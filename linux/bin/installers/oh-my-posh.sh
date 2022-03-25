#!/usr/bin/env bash

if (which brew) >/dev/null 2>&1; then
  brew install oh-my-posh
else
  printf "brew not found. \n Changed manual install oh-my-posh."

  sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
  sudo chmod +x /usr/local/bin/oh-my-posh
fi

echo "$(tput setaf 4)"Nerd font installing..."$(tput sgr0)"

curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CodeNewRoman.zip -o "$HOME"/CodeNewRoman.zip
mkdir -p "$HOME"/.local/share/fonts
unzip "$HOME"/CodeNewRoman.zip -d "$HOME"/.local/share/fonts
fc-cache -fv

echo "$(tput setaf 4)"Remove zCodeNewRoman.zip file..."$(tput sgr0)"
rm "$HOME"/CodeNewRoman.zip

echo "$(tput setaf 2)"Nerd font installed."$(tput sgr0)"
