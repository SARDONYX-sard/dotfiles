
Param([switch]$f, [switch]$force)

Write-Host "Linking Symbolic links..." -ForegroundColor Green

$force = $f.IsPresent -or $force.IsPresent

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
      [Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
  exit $?
}


$files = @(
  @{ target = "init.vim"; path = ""; name = ".vimrc" }
  @{ target = ".gitconfig"; path = ""; name = ".gitconfig" }
  @{ target = "init.vim"; path = "AppData/Local/nvim" }
  @{ target = "ginit.vim"; path = "AppData/Local/nvim" }
  @{ target = "windows/config/windows-terminal.json"; fullpath = Join-Path $env:LocalAppData "Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" }

  #? Passing whitespace as a whole object will not result in a path error.
  @{ target = "windows/config/init.ahk"; fullpath = Join-Path $env:AppData  "Microsoft/Windows/Start Menu/Programs/Startup/init.ahk" }

  "windows/config/.bash_profile"
  "windows/config/.bashrc"
)

# If you have a profile, add it and add it to $files.
if ( (Get-Command pwsh -ea 0) -and (pwsh -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/profile.ps1"; fullpath = @($(pwsh -NoProfile -Command "`$profile"))[0] })
}

if ( (Get-Command powershell -ea 0) -and (powershell -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/profile.ps1"; fullpath = @($(powershell -NoProfile -Command "`$profile"))[0] })
}


foreach ($file in $files) {
  if ($file.GetType() -eq [string]) {
    if (!$file) { continue }

    $file = @{target = $file; path = "" }
  }

  $target_name = Split-Path $file.target -Leaf
  $file.target = Join-Path "$HOME/dotfiles" $file.target

  if ( !$file.path ) { $file.path = "$HOME" }
  else { $file.path = Join-Path "$HOME" $file.path }

  if ($file.fullpath) {
    $file.path = Split-Path $file.fullpath
    $name = Split-Path $file.fullpath -Leaf
    if ($name) {
      $file.name = $name
    }
    $file.Remove("fullpath")
  }

  if (!$file.ContainsKey("name")) { $file.name = $target_name }

  if (!(Test-Path $file.path)) {
    mkdir $file.path
  }

  # ------------------------------------------------------------------------------------------------
  # Create Symbolic link
  # ------------------------------------------------------------------------------------------------
  function Set-SymbolicLink {
    Write-Host ""
    Write-Host "now: $($file.path + "/" + $file.name)"
    if (Test-Path ($file.path + "/" + $file.name)) {
      Write-Host "Already exists." -ForegroundColor Blue
      if ($force) {
        Write-Warning "Deleting..."
      (Get-Item ($file.path + "/" + $file.name)).Delete()
      }
      else {
        continue
      }
    }

    if (!(Test-Path ($file.path + "/" + $file.name))) {
      Write-Host "Making symbolic link..." -ForegroundColor Green

      if (!(Test-Path ($file.path))) {
        mkdir ($file.path)
      }

      New-Item -ItemType SymbolicLink @file | Out-Null
      if (!$?) { Write-Error "${@file} is null. Failed to create symbolic link." }
    }
  }

  Set-SymbolicLink
  # Write-Output @file | Out-File result.txt -Append # for debug
}
