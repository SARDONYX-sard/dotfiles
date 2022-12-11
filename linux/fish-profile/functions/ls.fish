if command -v exa &>/dev/null
    alias ls='exa --color=auto --time-style=long-iso -FH --icons' # need rust or apt
else if command -v lsd &>/dev/null
    alias ls='lsd'
end
