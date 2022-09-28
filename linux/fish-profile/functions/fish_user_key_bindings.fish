function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert


    # put i key(visual mode) => insert mode
    bind -s --preset -M visual -m insert i end-selection repaint-mode

    # ---------- Set the debounce so that pressing jk within 150 ms
    # will allow the system to enter Normal mode. -------------------
    set -g start_time 0
    set -g end_time 0

    # date +%s%N gives us milliseconds
    bind -M insert j 'commandline -i j; set -g start_time $(math (date +%s%N)/1000000)'
    bind -M insert k delay_to_insert_mode

    function delay_to_insert_mode
        set -g end_time $(math (date +%s%N)/1000000)
        set elapsed_time (math $end_time - $start_time)
        if test $elapsed_time -gt 150
            commandline -i k
        else
            changeToNormalMode
            set -g start_time 0
            set -g end_time 0
        end
    end

    # https://github.com/fish-shell/fish-shell/blob/master/share/functions/fish_vi_key_bindings.fish#L56
    function changeToNormalMode
        if commandline -P
            commandline -f cancel
        else
            set fish_bind_mode default
            # function's reference: https://fishshell.com/docs/current/cmds/bind.html
            commandline -f backward-delete-char repaint-mode
        end
    end
end
