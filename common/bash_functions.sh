#!/bin/bash

function color() {
  for fore in $(seq 30 37); do
    # shellcheck disable=SC2059
    printf "\e[${fore}m \\\e[${fore}m \e[m\n"
    for mode in 1 4 5; do
      # shellcheck disable=SC2059
      printf "\e[${fore};${mode}m \\\e[${fore};${mode}m \e[m"
      for back in $(seq 40 47); do
        # shellcheck disable=SC2059
        printf "\e[${fore};${back};${mode}m \\\e[${fore};${back};${mode}m \e[m"
      done
      echo
    done
    echo
  done
  printf " \\\e[m\n"
}

#w3mでALC検索
function alc() {
  if [ $# != 0 ]; then
    w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa"
  else
    w3m "http://www.alc.co.jp/"
  fi
}

function cd() {
  #cdを打ったら自動的にlsを打ってくれる関数
  builtin cd "$@" && ls
}

# wrap the git command to either run windows git or linux
function git {
  if isWinDir; then
    git.exe "$@"
  else
    /usr/bin/git "$@"
  fi
}

# checks to see if we are in a windows or linux dir
function isWinDir {
  case $PWD/ in
  /mnt/*)
    return "$(true)"
    ;;
  *)
    return "$(false)"
    ;;
  esac
}

# 任意のソースコードを読み込む関数(read source)
function rs() {
  path=$2
  ZSHRC_PATH="$HOME/.zshrc"

  case "$1" in
  "-b" | "b" | "--bash")
    # shellcheck disable=SC1091
    source "$HOME/.bashrc"
    echo "Read .bashrc"
    ;;

  "-z" | "z" | "--zsh")
    # shellcheck disable=SC1090
    source "$ZSHRC_PATH"
    echo "Read .zshrc"
    ;;

  "-f" | "f" | "--file")
    if [ "$path" ]; then
      # shellcheck disable=SC1090
      source "${path}"
      echo "Read ${path}"
    else
      echo "Error: path not specified"
    fi
    ;;

  "-h" | "h" | "help")
    echo "
Read source(bashrc, zshrc or the other flie) to GNU/Linux.

Usage: rs [option] [path?(if use f option)]

Option:
  b, -b, --bash         :Set .bashrc
  z, -z, --zsh          :Set .zshrc
  f, -f, --file         :Set the other file
  h, -h, --help         :Show this help

Examples:
  rs                    :Set .zshrc
  rs b                  :Set .bashrc
  rs --file ~/.bashrc   :Set .bashrc
      "
    ;;
  *)
    # shellcheck disable=SC1090
    source "$ZSHRC_PATH"
    echo "Read .zshrc"
    ;;
  esac
}
