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
  if [[ $# != 0 ]]; then
    w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa"
  else
    w3m "http://www.alc.co.jp/"
  fi
}

function start() {
  dir="$1"
  [[ -z "$1" ]] && dir="."
  [[ ! -d "${dir}" ]] && dir=$(dirname "$(command -v "${dir}")")

  if [[ -e /mnt/c ]]; then
    dir="$(wslpath -w "${dir}")"
  elif [[ -e /c ]]; then
    dir="$(cygpath -w "${dir}")"
  fi
  echo "${dir}"

  if [[ -e /mnt/c ]] || [[ -e /c ]]; then
    explorer.exe "${dir}"
  elif command -v xdg-open; then
    xdg-open "${dir}"
  else
    echo "No command to open file"
    exit 1
  fi
}

function cd() {
  #cdを打ったら自動的にlsを打ってくれる関数
  builtin cd "$@" && ls
}

# wrap the git command to either run windows git or linux
isBool=isWinDir

function git {
  if [[ ${isBool} = "true" ]]; then
    git.ps1 "$@"
  else
    /usr/bin/git "$@"
  fi
}

function update-all-libs() {
  if [[ -e /c ]]; then # for msys2
    sudo pacman -Syyu --noconfirm
  elif command -v yay >/dev/null 2>&1; then
    yay -Syyu --noconfirm
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove
  fi

  (command -v deno) >/dev/null 2>&1 && deno upgrade
  (command -v node) >/dev/null 2>&1 &&
    python3 -u "${HOME_DIR}"/dotfiles/scripts/update-corepack.py --remove-prev &&
    (command -v npm) >/dev/null 2>&1 && npm up -g &&
    (command -v pnpm) >/dev/null 2>&1 && pnpm up -g

  (command -v asdf) >/dev/null 2>&1 && asdf plugin update --all && asdf update

  (command -v brew) >/dev/null 2>&1 && brew upgrade

  (command -v gem) >/dev/null 2>&1 && gem update && gem cleanup

  (command -v cargo) >/dev/null 2>&1 && cargo install-update -a
  (command -v rustup) >/dev/null 2>&1 && rustup update

  (command -v pip-review) >/dev/null 2>&1 && pip-review -a
  (command -v pipx) >/dev/null 2>&1 && pipx upgrade-all
}

# checks to see if we are in a windows or linux dir
function isWinDir {
  case ${PWD}/ in
  /mnt/*) ;;
  /c/*) echo "true" ;;
  *) echo "false" ;;
  esac
}

# 任意のソースコードを読み込む関数(read source)
function rs() {
  path=$2
  ZSHRC_PATH="${HOME}/.zshrc"

  case "$1" in
  "-b" | "b" | "--bash")
    # shellcheck disable=SC1091
    source "${HOME}/.bashrc"
    echo "Read .bashrc"
    ;;

  "-z" | "z" | "--zsh")
    # shellcheck disable=SC1090
    source "${ZSHRC_PATH}"
    echo "Read .zshrc"
    ;;

  "-f" | "f" | "--file")
    if [[ -n "${path}" ]]; then
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
    shell=$(ps -ocomm= -q $$)

    if [[ "${shell}" = bash ]]; then
      [[ -f "${HOME}/.bashrc" ]] && "${HOME}/.bashrc" && echo "Read .bashrc"
    elif [[ "${shell}" = zsh ]]; then
      [[ -f "${HOME}/.zshrc" ]] && source "${ZSHRC_PATH}" && echo "Read .zshrc"
    fi
    ;;
  esac
}

# --------------------------------------------------------------------------------------------------
# fzf convenience functions
# --------------------------------------------------------------------------------------------------
# fshow - git commit browser
function fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# fd - cd to selected directory
function fd() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune \
    -o -type d -print 2>/dev/null | fzf +m) &&
    cd "${dir}" || return
}

# worktree移動
function cdworktree() {
  # カレントディレクトリがGitリポジトリ上かどうか

  if ! git rev-parse; then
    echo "$(tput setaf 1)"fatal: Not a git repository."$(tput sgr0)"

    return
  fi

  local selectedWorkTreeDir
  selectedWorkTreeDir=$(git worktree list | fzf | awk '{print $1}')

  if [[ "${selectedWorkTreeDir}" = "" ]]; then
    # Ctrl-C.
    return
  fi

  cd "${selectedWorkTreeDir}" || return
}

function fadd() {
  local out q n addfiles
  while out=$(
    git status --short |
      awk '{if (substr($0,2,1) !~ / /) print $2}' |
      fzf --multi --exit-0 --expect=ctrl-d
  ); do
    q=$(head -1 <<<"${out}")
    n=$(($(wc -l <<<"${out}") - 1))
    addfiles=$(tail "-${n}" <<<"${out}")
    for value in "${addfiles[@]}"; do
      [[ -z "${value}" ]] && continue
    done
    if [[ "${q}" = ctrl-d ]]; then
      git diff --color=always "${addfiles[@]}" | less -R
    else
      git add "${addfiles[@]}"
    fi
  done
}

# --------------------------------------------------------------------------------------------------
# broot
# --------------------------------------------------------------------------------------------------
# deep fuzzy cd
function dcd {
  br --only-folders --cmd "$1;:cd"
}
