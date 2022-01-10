#!/usr/bin/env bash

# The Missing Package Manager for macOS (or Linux)  (https://brew.sh/)

# For oh-my-posh linux version (Warn: Core install  436.82 MiB)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Manege oh-my-posh by Homebrew
brew tap jandedobbeleer/oh-my-posh
brew install oh-my-posh

brew install duf   # instead of `df`. It's volume size analyzer.
brew install dust  # du + rust = dust. Like du but more intuitive.
brew install broot # A better way to navigate directories
