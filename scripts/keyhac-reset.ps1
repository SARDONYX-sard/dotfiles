# -- install keyhac

# Are you root?
if ($isDebug -eq $false) {
  if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
    exit $?
  }
}

Remove-Item $HOME\scoop\apps\keyhac\current\keyhac.ini
Remove-Item $HOME\scoop\apps\keyhac\current\config.py
Remove-Item $HOME\scoop\apps\keyhac\current\_config.py

$startup_dir = [IO.Path]::Combine($env:AppData, "Microsoft/Windows/Start Menu/Programs/Startup")
if (Test-Path $startup_dir) {
  Remove-Item "$startup_dir\keyhac.exe"
}
New-Item -ItemType SymbolicLink -Target "$HOME\scoop\shims\keyhac.exe" -Path $startup_dir -Name "keyhac.exe" | Out-Null
