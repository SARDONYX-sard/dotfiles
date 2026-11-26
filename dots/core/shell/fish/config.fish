# fish config (shared aliases/env/PATH come from `dot gen`)

# This file is reached through a symlink; autoload functions next to the real file.
set -l here (path dirname (path resolve (status filename)))
contains $here/functions $fish_function_path; or set -g fish_function_path $here/functions $fish_function_path

test -r ~/.local/state/dot/gen/init.fish; and source ~/.local/state/dot/gen/init.fish

if status is-interactive
    set -g fish_greeting

    # vi mode only when DOT_EDIT_MODE=vi (shared.toml [env]): blinking block (normal)
    # / bar (insert); jj/jk in functions/fish_user_key_bindings.fish.
    # Always set (global): a universal `fish_key_bindings` left by older configs
    # would otherwise win.
    if test "$DOT_EDIT_MODE" = vi
        set -g fish_key_bindings fish_vi_key_bindings
    else
        set -g fish_key_bindings fish_default_key_bindings
    end
    set -g fish_sequence_key_delay_ms 200
    set -g fish_cursor_default block blink
    set -g fish_cursor_insert line blink
    set -g fish_cursor_replace_one underscore blink
    set -g fish_cursor_visual block
    set -g fish_color_command brcyan

    # Prompt: re-render the status line only after a command; on vi mode changes
    # just repaint (fish_prompt reuses the cached status line).
    function __dot_prompt_invalidate --on-event fish_postexec
        set -e __dot_status_line
    end
    function __dot_prompt_mode --on-variable fish_bind_mode
        commandline -f repaint
    end

    # auto-ls on directory change (works with zoxide's `cd`, prevd, etc.)
    function __dot_auto_ls --on-variable PWD
        status is-command-substitution; or ls
    end
end
