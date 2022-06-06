if (Get-Command zoxide) {
  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
      (zoxide init --cmd z --hook $hook powershell) -join "`n"
    })

  Remove-Item alias:cd -Force

  # we don't want to use hook.Because we want to use cd && ls.
  # cd function Couldn't lazy load.
  function cd {
    Invoke-Expression "z $args;ls"
  }
}
