# empty file
# https://github.com/fish-shell/fish-shell/issues/5783
function fish_prompt
    # Fish git prompt
    set __fish_git_prompt_showdirtystate yes
    set __fish_git_prompt_showstashstate yes
    set __fish_git_prompt_showuntrackedfiles yes
    set __fish_git_prompt_showupstream yes
    set __fish_git_prompt_color_branch yellow
    set __fish_git_prompt_color_upstream_ahead green
    set __fish_git_prompt_color_upstream_behind red

    # Status Chars
    set __fish_git_prompt_char_dirtystate '⚡'
    set __fish_git_prompt_char_stagedstate '→'
    set __fish_git_prompt_char_untrackedfiles '☡'
    set __fish_git_prompt_char_stashstate '↩'
    set __fish_git_prompt_char_upstream_ahead '+'
    set __fish_git_prompt_char_upstream_behind -

    switch $fish_bind_mode
        case default
            set mode (set_color --bold green)'Normal'
        case insert
            set mode (set_color --bold red)'Insert'
        case replace_one
            set mode (set_color --bold red)'Replace one'
        case visual
            set mode (set_color --bold brmagenta)'Visual'
        case '*'
            set mode (set_color --bold red)'?'
    end

    if string match -rq "^$HOME(?<current>.*)" $PWD
        set currentDir "~$current"
    else
        set currentDir (pwd)
    end

    # prompt visual
    # ┌──[~/dotfiles/common] 22/23/05 [Insert]   (main ⚡+)
    # └─$

    set_color green
    echo '┌──['(set_color normal)"$currentDir"(set_color green)']' \
        (set_color yellow)(date "+%y/%m/%d") \
        (set_color blue)'['"$mode"(set_color blue)']'(set_color normal) \
        (__fish_git_prompt)

    printf (set_color green)'└─'

    if test $USER = root
        and echo (set_color red)'# '(set_color normal)
    else
        echo (set_color blue)'$ '(set_color normal)
    end

end
