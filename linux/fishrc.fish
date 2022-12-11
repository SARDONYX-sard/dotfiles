set fish_greeting

# --------------------------------------------------------------------------------------------------
# Constant variables
# --------------------------------------------------------------------------------------------------
# - msys2 or WSL => windows $HOME
# - Linux => $HOME.
set HOME_DIR "$HOME"

# -----------------------------------------
# winodows environment variables
# -----------------------------------------
if [ -e /mnt/c ] || [ -e /c ]
    if [ ! "$(command -v cmd.exe)" ]
        then #! use cmd.exe, powershell.exe is very slowly
        echo "command \"cmd.exe\" not exists."
        echo "$(tput setaf 1)"Windows or r path is not inherited."$(tput sgr0)"
        exit 1
    end

    if command -v wslpath &>/dev/null
        set HOME_DIR $(wslpath "$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>/dev/null)" | sed -E 's/\r//g')
    else if command -v cygpath&>/dev/null
        set HOME_DIR $(cygpath "$(cmd.exe /c "echo %HOMEDRIVE%%HOMEPATH%" 2>/dev/null)" | sed -E 's/\r//g')
    else
        echo "Not found path changer"
        exit 1
    end

    set WIN_USER $(echo "$HOME_DIR" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
    export WIN_USER
end

export HOME_DIR


set -x SHELL_NAME fish
set -e NO_FISH

if test -z "$CUSTOM_FISH_FUNCTIONS"
    set -g CUSTOM_FISH_FUNCTIONS "$HOME_DIR/dotfiles/linux/fish-profile/functions"
    set -g fish_function_path "$CUSTOM_FISH_FUNCTIONS" $fish_function_path
end

# -- color
set fish_color_command brcyan

# -- cd improved
functions --copy cd cd_default
function cd
    cd_default $argv; and ls
end

# -- vi mode
set fish_cursor_default block
# Set the insert mode cursor to a line
set fish_cursor_insert line
# Set the replace mode cursor to an underscore
set fish_cursor_replace_one underscore
# The following variable can be used to configure cursor shape in
# visual mode, but due to fish_cursor_default, is redundant here
set fish_cursor_visual block

if status --is-interactive
    # https://github.com/ellie/atuin
    command -sq atuin&>/dev/null && atuin init fish | source
end
