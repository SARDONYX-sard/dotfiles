#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------
# Prompt Design
# --------------------------------------------------------------------------------------------------
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  # PROMPT_USER_MACHINE='%F{green}┌──(%B%F{blue}%n%m%b%F{green})-'
  # PROMPT_PATH='[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{green}]'
  # PROMPT_GIT='%F{011}${vcs_info_msg_0_}'
  # PROMPT_LINE2=$'\n%F{green}└─%B%F{blue}$%b%F{reset} '
  # PROMPT='$PROMPT_USER_MACHINE''$PROMPT_PATH''$PROMPT_GIT''$PROMPT_LINE2'
  PROMPT=$'%F{green}┌──[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{green}]%F{yellow}%t %F{green}(%B%F{cyan}%n@%m%b%F{green})\n%F{green}└─%B%F{blue}$%b%F{reset} '
  RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'
else
  PROMPT='%n@%m:%~%# '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm* | rxvt*)
#   TERM_TITLE='\e]0;%n@%m: %~\a'
#   ;;
# *) ;;

# esac

new_line_before_prompt=yes

export LESS_TERMCAP_mb=$'\E[1;31m'  # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'     # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'     # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'  # begin underline
export LESS_TERMCAP_ue=$'\E[0m'     # reset underline

# poshThemePath="${WIN_HOME}/scoop/apps/oh-my-posh/current/themes"
# pooshTheme="${poshThemePath}"/atomic.omp.json
# pooshTheme="${WIN_HOME}"/dotfiles/common/data/oh-my-posh-themes/my-custom.json # custom theme
pooshTheme="${HOME_DIR}"/dotfiles/common/data/oh-my-posh-themes/atomic.omp.json # custom theme

# Theme dir e.g: C:\Users\SARDONYX\scoop\apps\oh-my-posh\current\themes
if [ "$(command -v oh-my-posh)" ]; then
  eval "$(oh-my-posh --init --shell zsh --config "${pooshTheme}")"
fi
