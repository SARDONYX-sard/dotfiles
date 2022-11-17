#? This file is now shared by Linux and Msys2. It may be separated in the future.

# Original source and copyright: Kali Linux and Offensive Security
# https://www.kali.org/docs/policy/kali-linux-open-source-policy/

# Modifications by Erik Larson, or otherwise attributed

# ~/.zshrc file for zsh non-login shells.

# all shell read this env file
source "${HOME}/common_profile.sh" # get $HOME_DIR
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
