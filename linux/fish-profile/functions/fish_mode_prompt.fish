# empty file
# https://github.com/fish-shell/fish-shell/issues/5783
function fish_prompt
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

  switch $PWD
    case $HOME
      set currentDir '~'
    case '*'
      set currentDir (pwd)
  end

  set_color green
  echo '┌──['(set_color normal)"$currentDir"(set_color green)']' (set_color yellow)(date "+%y/%d/%m") \
    (set_color blue)'['"$mode"(set_color blue)']'
  echo (set_color green)'└─'(set_color blue)'$ '(set_color normal)
end
