if (Get-Command fzf -ErrorAction SilentlyContinue) {
  $defaultFZFopts = "--tabstop=4"

  if ( Get-Command bat -ea 0 ) {
    $env:FZF_DEFAULT_OPTS = "
    $defaultFZFopts --preview `"bat --pager=never --color=always --style=numbers --line-range :300 {}`""

    if ( Get-Command rg -ea 0 ) {
      $env:FZF_CTRL_T_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    }

  }
  else { $env:FZF_DEFAULT_OPTS = "$defaultFZFopts --preview `"cat {}`"" }
}
