function update-all-libs
    if [ -e /c ]
        sudo pacman -Syyu --noconfirm
        pwsh -Command update-all-libs
    else if which yay
        yay -Syyu --noconfirm
    else
        sudo apt update -y && sudo apt upgrade -y
        asdf plugin update --all
        asdf update
        brew upgrade
        python3 -u "$HOME_DIR"/dotfiles/scripts/corepack-update.py
        npm up -g
        pnpm up -g
        gem update
        gem cleanup
    end
end
