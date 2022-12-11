if command -v lvim &>/dev/null
    alias vim='lvim'
else if command -v nvim &>/dev/null
    alias vim='nvim'
else
    alias vim='vim'
end
