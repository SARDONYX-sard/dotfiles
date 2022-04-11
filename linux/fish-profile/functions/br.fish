function br \
    --description 'execute broot.'
    if which br
        br --conf $HOME_DIR/dotfiles/common/data/broot-config.toml -s -g -h
    end
end
