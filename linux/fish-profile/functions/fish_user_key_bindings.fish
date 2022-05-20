function fish_user_key_bindings
      # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert

    # https://github.com/fish-shell/fish-shell/blob/master/share/functions/fish_vi_key_bindings.fish#L56
    set changeToNormalMode "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char repaint-mode; end"
    bind -s --preset -M insert jj $changeToNormalMode
    bind -s --preset -M insert jk $changeToNormalMode
    bind -s --preset -M insert kj $changeToNormalMode
end
