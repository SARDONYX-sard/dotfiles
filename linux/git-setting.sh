#!/usr/bin/env bash

mkdir -p "$HOME"/.config/git
cat "common/data/git/gitignore-global.txt" >"$HOME"/.config/git/ignore
