
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
  @{ target = "init.vim"; path = "AppData/Local/nvim" }
  @{ target = "ginit.vim"; path = "AppData/Local/nvim" }
  @{ target = "windows/config/settings.json"; fullpath = Join-Path $env:LocalAppData "Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"; mode = "copy" }

  #? Passing whitespace as a whole object will not result in a path error.
  @{ target = "windows/config/init.ahk"; fullpath = Join-Path $env:AppData  "Microsoft/Windows/Start Menu/Programs/Startup/init.ahk" }

  # oh-my-posh theme (custom)
  @{ target = "windows\data\gmay.omp.json"; fullpath = Join-Path (Split-Path (pwsh -NoProfile -Command "`$profile")) "\Modules\oh-my-posh\themes\gmay.omp.json" }


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
    Write-Host "now: $(Join-Path $file.path $file.name)"

    $fullPathName = Join-Path $file.path $file.name
    if (Test-Path $fullPathName) {
      Write-Host "Already exists." -ForegroundColor Blue
      if ($force) {
        Write-Host "Recreating..." -ForegroundColor Yellow
      (Get-Item $fullPathName).Delete()
      }
      else {
        continue
      }
    }

    if (!(Test-Path $fullPathName)) {

      if (!(Test-Path ($file.path))) {
        mkdir ($file.path)
      }


      # Copy or SymbolicLink
      if ($file.mode -eq "copy") {
        Write-Host "Copying..." -ForegroundColor Green
        Copy-Item $file.target -Destination $file.path -Force
      }
      else {
        Write-Host "Making symbolic link..." -ForegroundColor Green
        New-Item -ItemType SymbolicLink @file | Out-Null
      }
      if (!$?) { Write-Error "${@file} is null. Failed to create symbolic link." }
    }
  }

  Set-SymbolicLink
  # Write-Output @file | Out-File result.txt -Append # for debug
}
