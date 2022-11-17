#? This file is now shared by Linux and Msys2. It may be separated in the future.

# Original source and copyright: Kali Linux and Offensive Security
# https://www.kali.org/docs/policy/kali-linux-open-source-policy/

# Modifications by Erik Larson, or otherwise attributed

# ~/.zshrc file for zsh non-login shells.

# --------------------------------------------------------------------------------------------------
# Constant variables
# --------------------------------------------------------------------------------------------------
# - msys2 or WSL => windows $HOME (e.g. /mnt/c/Users/SARDONYX)
# - Linux => $HOME
HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  if [ ! "$(command -v powershell.exe)" ]; then
    echo "command \"powershell.exe\" not exists."
    echo "$(tput setaf 1)"Windows or r path is not inherited."$(tput sgr0)"
    exit 1
  fi

  if (which wslpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(wslpath "$(powershell.exe -command 'echo $HOME')" | sed -E 's/\r//g')
  elif (which cygpath) >/dev/null 2>&1; then
    # shellcheck disable=SC2016
    HOME_DIR=$(cygpath "$(powershell.exe -command 'echo $HOME')" | sed -E 's/\r//g')
  else
    echo "Not found path changer"
    exit 1
  fi

  WIN_USER=$(echo "$HOME_DIR" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER
fi
export HOME_DIR

export ZSH_PROFILE="$HOME_DIR/dotfiles/linux/zsh-profile"

# --------------------------------------------------------------------------------------------------
# Read other modules
# --------------------------------------------------------------------------------------------------
source "${HOME_DIR}/dotfiles/common/read-common-settings.sh" # env-paths, aliases, functions
source "$ZSH_PROFILE/completion.sh"
source "$ZSH_PROFILE/history.sh"
source "$ZSH_PROFILE/shell-behavior.sh"
source "$ZSH_PROFILE/shell-design.sh"
source "$ZSH_PROFILE/znap.sh"
source "$ZSH_PROFILE/module-settings.sh" # read broot file, etc first. For br alias.

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ("$SHLVL" -eq 1 && ! -o LOGIN) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# PATH=$(echo "$PATH" | sed s/:/\\n/g | grep -v '/mnt/c/Users/SARDONYX/scoop/' | sed ':a;N;$!ba;s/\n/:/g')
