#!/usr/bin/env bash

# The Missing Package Manager for macOS (or Linux)  (https://brew.sh/)

# For oh-my-posh linux version (Warn: Core install  436.82 MiB)

if (! which brew) >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "To enable the brew command"
  echo "$(tput setaf 3)"Please restart your terminal."$(tput sgr0)"
fi

# Manege oh-my-posh by Homebrew
brew tap jandedobbeleer/oh-my-posh
brew install broot # A better way to navigate directories
brew install duf   # instead of `df`. It's volume size analyzer.
brew install dust  # du + rust = dust. Like du but more intuitive.
brew install ghq   # Manage remote repository clones
