Invoke-Expression (&scoop-search --hook) # Makes scoop search 50 times faster. (Couldn't lazy load.)

# For zoxide v0.8.0+
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --cmd cd --hook $hook powershell | Out-String)
  })
