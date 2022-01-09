
if ($PSVersionTable.PSEdition -eq "Core") {
  if (Get-Command vcpkg) { Import-Module "$HOME\vcpkg\scripts\posh-vcpkg" }
  Import-Module posh-git

  # Commands
  Import-WslCommand "awk", "emacs", "fgrep", "egrep", "less", "sed", "man"
  $WslDefaultParameterValues = @{}
  $WslDefaultParameterValues["less"] = "-i"

  # Complition
  . "$HOME\scoop\apps\bottom\current\completion\_btm.ps1"
  Import-Module DockerCompletion
  Set-PSReadLineOption -PredictionSource History #* Core only module


  # --------------------------------------------------------------------------------------------------
  # =Finder
  # --------------------------------------------------------------------------------------------------

  # PsFzf
  Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }; # Tab completion

  #! This is a heavy option. Should be lazy loading.
  # (If you let it load normally: loading time +1500ms)
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'  # Search for file paths in the current directory
  Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' #  Search command history

  # fzf
  if ( Get-Command bat -ea 0 ) {
    $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"bat --pager=never --color=always --style=numbers --line-range :300 {}`""
    if ( Get-Command rg -ea 0 ) {
      $env:FZF_CTRL_T_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    }
  }
  else { $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"cat {}`"" }
}
