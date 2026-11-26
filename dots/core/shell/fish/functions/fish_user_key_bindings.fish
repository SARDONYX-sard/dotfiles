function fish_user_key_bindings
    test "$DOT_EDIT_MODE" = vi; or return # emacs-style default bindings

    # Emacs bindings in insert mode, vi bindings take precedence.
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert

    # jj / jk -> normal mode (within fish_sequence_key_delay_ms)
    for seq in jj jk
        bind -M insert $seq 'if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char repaint-mode; end'
    end
    bind -M visual -m insert i end-selection repaint-mode
end
