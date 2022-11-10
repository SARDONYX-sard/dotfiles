function update-all-libs
    if [ -e /c ]
        # for msys2
        sudo pacman -Syyu --noconfirm
    else if which yay &>/dev/null
        yay -Syyu --noconfirm
    else if which apt&>/dev/null
        sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove
    end

    which node&>/dev/null && \
        python3 -u "$HOME_DIR"/dotfiles/scripts/update-corepack.py --remove-prev

    which brew&>/dev/null && brew upgrade
    which npm&>/dev/null && npm up -g
    which pnpm&>/dev/null && pnpm up -g

    if which asdf&>/dev/null
        asdf plugin update --all
        asdf update
    end

    if which gem&>/dev/null
        gem update
        gem cleanup
    end
end
