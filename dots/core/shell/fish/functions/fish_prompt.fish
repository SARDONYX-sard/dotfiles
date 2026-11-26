# Status line from `dot` (cached until the next command, see config.fish) +
# input line drawn here: `└─$` / vi: `└I$` `└N$` `└V$` `└R$`. Mode changes only
# repaint, so `dot` is not re-run on every key.
function fish_prompt
    set -l code $status
    if not command -q dot
        printf '%s> ' (prompt_pwd)
        return
    end
    if not set -q __dot_status_line
        set -g __dot_status_line (dot prompt --shell fish --status-only --status $code --duration $CMD_DURATION)
    end
    printf '%s\n' $__dot_status_line

    set_color green
    printf └
    if test "$DOT_EDIT_MODE" = vi
        switch $fish_bind_mode
            case default
                set_color yellow
                printf N
            case insert
                set_color blue
                printf I
            case visual
                set_color magenta
                printf V
            case replace replace_one
                set_color red
                printf R
            case '*'
                printf ─
        end
    else
        printf ─
    end
    if fish_is_root_user
        set_color red
        printf '# '
    else
        set_color cyan
        printf '$ '
    end
    set_color normal
end
