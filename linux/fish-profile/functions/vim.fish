if which lvim &> /dev/null
    alias vim='lvim'
else if which nvim &> /dev/null
    alias vim='nvim'
else
    alias vim='vim'
end
