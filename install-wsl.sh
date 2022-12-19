#!/bin/bash

if [ "$(whoami)" != "root" ] && [ "$SUDO_USER" != "" ]; then
  echo "Please run with sudo."
  exit 1
fi

# --------------------------------------------------------------------------------------------------
# Constant variables
# --------------------------------------------------------------------------------------------------
# - msys2 or WSL => windows $HOME (e.g. /mnt/c/Users/SARDONYX)
# - Linux => $HOME
HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  if [ ! "$(command -v cmd.exe)" ]; then #! use cmd.exe, powershell.exe is very slowly
    echo "command \"cmd.exe\" not exists."
    echo "$(tput setaf 1)"Windows or r path is not inherited."$(tput sgr0)"
    exit 1
  fi

  if (command -v wslpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(wslpath "$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>/dev/null)" | sed -E 's/\r//g')
  elif (command -v cygpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(cygpath "$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>/dev/null)" | sed -E 's/\r//g')
  else
    echo "Not found path changer"
    exit 1
  fi

  WIN_USER=$(echo "$HOME_DIR" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER
fi
export HOME_DIR

# --------------------------------------------------------------------------------------------------
# Check dotfiles installed
# --------------------------------------------------------------------------------------------------
if (command -v yay) >/dev/null 2>&1; then
  yay -S git python3 --noconfirm
elif (command -v pacman) >/dev/null 2>&1; then
  sudo pacman -S git python3 --noconfirm
elif (command -v apt) >/dev/null 2>&1; then
  sudo apt install git python3 -y
else
  echo "Not supported package manager."
  exit 1
fi

[ ! -d "$HOME_DIR"/dotfiles ] && echo "Not found $HOME_DIR/dotfiles/ dirctory." &&
  git clone --depth 1 -- https://github.com/SARDONYX-sard/dotfiles.git "$HOME_DIR"/dotfiles

# --------------------------------------------------------------------------------------------------
# Options
# --------------------------------------------------------------------------------------------------
POSITIONAL=()
while (($# > 0)); do
  case "${1}" in
  -z | --zsh)
    is_zsh_mode="true"
    shift # shift once since flags have no values
    ;;
  -f | --fish)
    is_fish_mode="true"
    shift # shift once since flags have no values
    ;;
  -l | --light)
    export IS_LIGHT="true"
    shift
    ;;
  *) # unknown flag/switch
    POSITIONAL+=("${1}")
    shift
    ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional params

# find "$HOME_DIR"/dotfiles -type d -exec chmod 755 {} +
# find "$HOME_DIR"/dotfiles -type f -exec chmod 644 {} +

# --------------------------------------------------------------------------------------------------
# Setup setting files
# --------------------------------------------------------------------------------------------------
echo "Setting up symlink..."
bash "$HOME_DIR"/dotfiles/linux/symlink.sh

# --------------------------------------------------------------------------------------------------
# Git
# --------------------------------------------------------------------------------------------------
echo "Setting up gitcofig..."
gitcofig_path="$HOME/.gitconfig"
if [ -f "$gitcofig_path" ]; then
  echo "File ${gitcofig_path} exists. Skip gitconfig setup."
else
  cat "$HOME_DIR"/dotfiles/common/data/git/git-config.txt >"$gitcofig_path"
fi

# --------------------------------------------------------------------------------------------------
# Install libs
# --------------------------------------------------------------------------------------------------
echo "Installation by package manager, etc."
[ "$IS_LIGHT" ] && echo "$(tput setaf 4)"light mode selected."$(tput sgr0)"
bash "$HOME_DIR"/dotfiles/linux/bin/all-installer.sh

if [ "$is_zsh_mode" ]; then
  echo "$(tput setaf 4)"zsh selected. Enable zsh."$(tput sgr0)"
  chsh -s /bin/zsh # Change shell to zsh.(option)
elif [ "$is_fish_mode" ]; then
  echo "$(tput setaf 4)"fish selected. Enable fish."$(tput sgr0)"
  # chsh -s /usr/bin/fish
  fish -c "curl -L git.io/fisher | source && fisher install_fisher_plugins"
fi
