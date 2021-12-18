#!/usr/bin/env bash

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
mkdir -p "$(dirname "$ZINIT_HOME")"
git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# ref: (https://github.com/zdharma-continuum/fast-syntax-highlighting)
zinit light zdharma-continuum/fast-syntax-highlighting
