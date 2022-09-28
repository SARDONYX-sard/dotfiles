if which bat&>/dev/null
    alias cat='bat' # need rust or pacman 
else if which batcat&>/dev/null
    alias cat='batcat' # need rust or apt
end
