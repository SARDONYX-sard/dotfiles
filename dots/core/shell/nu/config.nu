# Nushell config

$env.config.show_banner = false
# Line editing: vi when DOT_EDIT_MODE=vi. The generated env (autoload) loads after
# this file, so apply it before each prompt.
$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt? | default [] | append {||
  $env.config.edit_mode = if ($env.DOT_EDIT_MODE? == 'vi') { 'vi' } else { 'emacs' }
})
$env.config.cursor_shape = { vi_insert: blink_line, vi_normal: blink_block, emacs: line }

$env.config.keybindings ++= [
  { name: insert_to_normal_ctrl_c, modifier: control, keycode: char_c, mode: vi_insert,
    event: { send: vichangemode, mode: normal } }
]

# auto-ls on directory change
$env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD? | default [] | append {|_, _| ls | print })

# prompt
# Status line from `dot`; the input line is the mode indicator below.
$env.PROMPT_COMMAND = {||
  if (which dot | is-not-empty) {
    # Both are unset until the first command has run.
    let status = $env.LAST_EXIT_CODE? | default 0
    let ms = $env.CMD_DURATION_MS? | default '0' | into int
    dot prompt --shell nu --status-only --status $status --duration $ms
  } else {
    $"($env.PWD)\n"
  }
}
$env.PROMPT_COMMAND_RIGHT = ''
# Input line: `└─$` (emacs) / `└I$` `└N$` (vi); `#` when admin.
let dot_mark = if (is-admin) { $"(ansi red)#" } else { $"(ansi cyan)$" }
$env.PROMPT_INDICATOR = $"(ansi green)└─($dot_mark) (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi green)└(ansi blue)I($dot_mark) (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi green)└(ansi yellow)N($dot_mark) (ansi reset)"
$env.PROMPT_MULTILINE_INDICATOR = '::: '

alias c = clear
alias l = ls
alias la = ls -a
alias ll = ls -l
alias lla = ls -la
