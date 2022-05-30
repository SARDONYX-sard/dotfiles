if which exa &>/dev/null
    alias ls='exa --color=auto --time-style=long-iso -FH --icons' # need rust or apt
else if which lsd &>/dev/null
    alias ls='lsd'
end
