if (Get-Command fzf -ErrorAction SilentlyContinue) {
  Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }; # Tab completion

  #! This is a heavy option. Should be lazy loading.
  # (If you let it load normally: loading time +1500ms)
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl-t'  # Search for file paths in the current directory
  Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' #  Search command history
  Set-PSReadLineKeyHandler -Key 'Ctrl+f'  -ScriptBlock {
    Invoke-Expression   'cd (Get-ChildItem . -Recurse | Where-Object { $_.PSIsContainer } | Invoke-Fzf)'
  }

}
