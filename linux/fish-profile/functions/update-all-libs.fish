function update-all-libs
    if [ -e /c ]
        # for msys2
        sudo pacman -Syyu --noconfirm
    else if command -v yay &>/dev/null
        yay -Syyu --noconfirm
    else if command -v apt&>/dev/null
        sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y
    end

    command -v deno&>/dev/null && deno upgrade
    command -v node&>/dev/null && \
        python3 -u "$HOME_DIR"/dotfiles/scripts/update-corepack.py --remove-prev && \
        command -v npm&>/dev/null && npm up -g && \
        command -v pnpm&>/dev/null && pnpm up -g

    command -v asdf&>/dev/null && asdf plugin update --all && asdf update

    command -v brew&>/dev/null && brew upgrade

    command -v gem&>/dev/null && gem update && gem cleanup

    command -v cargo&>/dev/null && cargo install cargo-update # To use `install-update` command
            && cargo install-update -a
    command -v rustup&>/dev/null && rustup update

    command -v pip-review&>/dev/null && pip-review -a
    command -v pipx&>/dev/null && pipx upgrade-all
