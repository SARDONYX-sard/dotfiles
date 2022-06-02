if (Get-Command zoxide) {
  Remove-Alias cd
  # we don't want to use hook.Because we want to use cd && ls.
  # cd function Couldn't lazy load.
  function cd {
    zoxide query $args | Set-Location;
    Invoke-Expression "ls"
  }
}
