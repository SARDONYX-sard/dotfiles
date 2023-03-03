function update-all-libs
    set prefix ""
    if [ ! -e /c ] # For not msys2
        set prefix sudo
    end

    # openssl is used for `cargo install-update`
    if command -v yay &>/dev/null
        yay -Syyu --noconfirm
        command -v openssl &>/dev/null || yay -S openssl
    else if command -v pacman &>/dev/null
        $prefix pacman -Syyu --noconfirm
        # for msys2
        if [ -e /c ]
            command -v openssl &>/dev/null || pacman -S mingw-w64-x86_64-openssl
        else
            command -v openssl &>/dev/null || $prefix pacman -S openssl
        end
    else if command -v apt &>/dev/null
        $prefix apt update -y && $prefix apt upgrade -y && $prefix apt autoremove -y
        command -v openssl &>/dev/null || $prefix apt install libssl-dev
    end

    command -v deno &>/dev/null && deno upgrade
    command -v node &>/dev/null &&
        python3 -u "$HOME_DIR"/dotfiles/scripts/update-corepack.py --remove-prev &&
        command -v npm &>/dev/null && npm up -g &&
        command -v pnpm &>/dev/null && pnpm up -g

    command -v asdf &>/dev/null && asdf plugin update --all && asdf update

    command -v brew &>/dev/null && brew upgrade

    command -v gem &>/dev/null && gem update && gem cleanup

    [ -e "$HOME/.cargo/bin/cargo-install-update" ] || cargo install cargo-update
    command -v cargo &>/dev/null && cargo install-update -a
    command -v rustup &>/dev/null && rustup update

    command -v pip-review &>/dev/null && pip-review -a
    command -v pipx &>/dev/null && pipx upgrade-all
end
