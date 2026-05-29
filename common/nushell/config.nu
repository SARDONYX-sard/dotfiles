# Nushell Config File

$env.config.show_banner = false
$env.config.edit_mode = 'vi'

$env.config.cursor_shape = {
  vi_insert: line
  vi_normal: block
  emacs: line
}

$env.config.keybindings ++= [{
  name: exit_insert_mode_with_ctrl_c
  modifier: control
  keycode: char_c
  mode: vi_insert
  event: {
    send: vichangemode
    mode: normal
  }
}]

# Aliases
alias ..  = cd ../..
alias ... = cd ../../..
alias c   = clear
alias l   = ls -d
alias la  = ls -ad
alias ll  = ls -al
alias lla = ls -ald
