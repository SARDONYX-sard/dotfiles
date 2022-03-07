#!/usr/bin/env bash

#
#.SYNOPSIS
#   Install msys2 and global libraries
#.DESCRIPTION
#   Install msys2 and global libraries.
#.EXAMPLE
#   Install libraries.
#   msys2.ps1
#>

function install_libs {
  # Update database
  pacman -Suy --noconfirm

  # Utils
  pacman -S \
    diffutils \
    git \
    grep \
    man \
    sed \
    tar \
    unzip \
    vim \
    wget \
    --noconfirm

  # need 1.07 GB of disk space
  pacman -S ccache --noconfirm
  pacman -S findutils --noconfirm
  pacman -S make --noconfirm
  pacman -S mingw-w64-x86_64-toolchain --noconfirm
  pacman -S ncurses-devel --noconfirm
  pacman -S openssh --noconfirm
  pacman -S subversion --noconfirm
  pacman -S tmux --noconfirm
  pacman -S winpty --noconfirm # For interactive languages.  reference: (https://qiita.com/magichan/items/7702d7865deaaca2ad44)
  pacman -S zsh --noconfirm    # A shell with better completion than bash

  # syntax highlighting for zsh
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ~/path/to/fsh
}

function main {
  install_libs
}

main
