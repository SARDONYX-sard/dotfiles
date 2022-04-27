if (Get-Command zoxide) {
  # For zoxide v0.8.0+
  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --cmd cd --hook $hook powershell | Out-String)
    })
}
