# -- install keyhac

# Are you root?
$isDebug = $d.IsPresent -or $isDebug.IsPresen
if ($isDebug -eq $false) {
  if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
      [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
    exit $?
  }
}

#! scoop & msys2 throws an error, so omit the process.
$scoopApps = $(scoop list).Name;
foreach ($item in $scoopApps) {
  Write-Host "scoop: $item"
  if ($item -eq "scoop" -or $item -eq "msys2") {
    continue
  }

  scoop reset $item
}

Remove-Item $HOME\scoop\apps\keyhac\current\keyhac.ini
Remove-Item $HOME\scoop\apps\keyhac\current\config.py
Remove-Item $HOME\scoop\apps\keyhac\current\_config.py

$startup_dir = [IO.Path]::Combine($env:AppData, "Microsoft/Windows/Start Menu/Programs/Startup")
if (Test-Path $startup_dir) {
  Remove-Item "$startup_dir\keyhac.exe"
}
New-Item -ItemType SymbolicLink -Target "$HOME\scoop\apps\keyhac\current\keyhac.exe" -Path $startup_dir -Name "keyhac.exe" | Out-Null

$keyhac_path = "$HOME\scoop\apps\keyhac\current"
ln -s "$HOME\dotfiles\windows\config\keyhac\keyhac.ini" "$keyhac_path\keyhac.ini"
ln -s "$HOME\dotfiles\windows\config\keyhac\config.py" "$keyhac_path\config.py"
