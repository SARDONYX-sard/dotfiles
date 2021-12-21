# --------------------------------------------------------------------------------------------------
# Module settings
# --------------------------------------------------------------------------------------------------
Invoke-Expression (&scoop-search --hook) # Makes scoop search 50 times faster.

if ($PSVersionTable.PSEdition -eq "Core") {
  Set-PSReadLineOption -PredictionSource History # need `PSReadLine` module(Core only)
  Import-Module DockerCompletion
  Import-WslCommand "awk", "emacs", "fgrep", "egrep", "head", "less", "sed", "seq", "ssh", "tail", "man"#, "ls", "vim"
  $WslDefaultParameterValues = @{}
  $WslDefaultParameterValues["grep"] = "-E --color=auto"
  $WslDefaultParameterValues["less"] = "-i"
  $WslDefaultParameterValues["ls"] = "--color=auto --human-readable --group-directories-first"

  # PsFzf (This option is heavy processing.)
  Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }; # Tab completion
  # Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'  # Search for file paths in the current directory
  # Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' #  Search command history

  # fzf
  if ( Get-Command bat -ea 0 ) {
    $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"bat --pager=never --color=always --style=numbers --line-range :300 {}`""
    if ( Get-Command rg -ea 0 ) {
      $env:FZF_CTRL_T_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    }
  }
  else {
    $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"cat {}`""
  }
}
