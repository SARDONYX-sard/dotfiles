if ($PSVersionTable.PSEdition -eq 'Core') {
  if (Get-Command z -ErrorAction SilentlyContinue) {
    Invoke-Expression "z $args;ls"
  }
  return
}

# For powrshell.exe(old powershell)
# - https://superuser.com/questions/593987/change-directory-to-previous-directory-in-powershell
if ($args.Count -eq 0) {
  $tmp_path = ${HOME}
}
elseif ($args[0] -eq '-') {
  $tmp_path = $OLDPWD;
}
else {
  $tmp_path = $args[0];
}

if ($tmp_path) {
  Set-Variable -Name OLDPWD -Value $PWD -Scope global;
  if (Get-Command lsd -ErrorAction SilentlyContinue) {
    Invoke-Expression "Set-Location $tmp_path;lsd"
  }
  else {
    Set-Location $tmp_path;
  }
}
