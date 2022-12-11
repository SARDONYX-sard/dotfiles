if command -v bat&>/dev/null
    alias cat='bat' # need rust or pacman
else if command -v batcat&>/dev/null
    alias cat='batcat' # need rust or apt
end
