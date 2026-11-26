function rm --description 'disabled; use trash or command rm'
    echo "rm is disabled, use trash or `command rm` instead." >&2
    return 1
end
