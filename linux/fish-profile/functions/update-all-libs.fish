function update-all-libs
    if [ -e /c ]
        # for msys2
        sudo pacman -Syyu --noconfirm
    else if command -v yay &>/dev/null
        yay -Syyu --noconfirm
    else if command -v apt&>/dev/null
        sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove
    end

    command -v node&>/dev/null && \
        python3 -u "$HOME_DIR"/dotfiles/scripts/update-corepack.py --remove-prev

    command -v brew&>/dev/null && brew upgrade
    command -v node and command -v npm&>/dev/null && npm up -g
    command -v node and command -v pnpm&>/dev/null && pnpm up -g

    if command -v asdf&>/dev/null
        asdf plugin update --all
        asdf update
    end

    if command -v gem&>/dev/null
        gem update
        gem cleanup
    end
end
