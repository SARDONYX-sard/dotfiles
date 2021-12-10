
Param([switch]$f, [switch]$force)

Write-Host "Linking Symbolic links..." -ForegroundColor Green

$force = $f.IsPresent -or $force.IsPresent

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
      [Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
  exit $?
}

$terminalPath = Join-Path $env:LocalAppData "Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
$terminalPreviewPath = $terminalPath.Replace("Terminal", "TerminalPreview")

$files = @(
  # vim
  @{ target = "init.vim"; path = ""; name = ".vimrc" }
  @{ target = "init.vim"; path = "AppData/Local/nvim" }
  @{ target = "ginit.vim"; path = "AppData/Local/nvim" }

  # Terminal
  @{ target = "windows\data\windows-terminal\settings.json"; fullpath = $terminalPath; } # mode = "copy" }
  @{ target = "windows\data\windows-terminal-preview\settings.json"; fullpath = $terminalPreviewPath; } # mode = "copy" }

  @{ target = "windows/config/init.ahk"; fullpath = Join-Path $env:AppData  "Microsoft/Windows/Start Menu/Programs/Startup/init.ahk" }

  # oh-my-posh theme (custom)
  @{ target  = "windows\data\custom-oh-my-posh\themes\gmay.omp.json";
    fullpath = Join-Path (Split-Path (pwsh -NoProfile -Command "`$profile")) "\Modules\oh-my-posh\themes\gmay.omp.json"
  }
  @{ target  = "windows\data\custom-oh-my-posh\themes\night-owl.omp.json";
    fullpath = Join-Path (Split-Path (pwsh -NoProfile -Command "`$profile")) "\Modules\oh-my-posh\themes\night-owl.omp.json"
  }

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



function Set-Msys2Symlink {
  $UserName = Split-Path $HOME -Leaf
  $myss2Home = @{ target = $HOME; path = Join-Path $HOME "scoop\apps\msys2\current\home\$UserName"; }

  Write-Host ""
  Write-Host "now: $($myss2Home.path)"

  if (Test-Path $myss2Home.path) {
    Write-Host "Already exists." -ForegroundColor Blue
    if ($force) {
      Write-Host "Recreating..." -ForegroundColor Yellow
        (Get-Item $myss2Home.path).Delete()
    }
    else {
      Write-Host "Skipping..." -ForegroundColor Yellow
      return
    }
    Write-Host "Making symbolic link..." -ForegroundColor Green
    New-Item -ItemType SymbolicLink @myss2Home | Out-Null
    if (!$?) { Write-Error "${@myss2Home} is null. Failed to create symbolic link." }
  }
}

Set-Msys2Symlink

foreach ($file in $files) {
  if ($file.GetType() -eq [string]) {
    if (!$file) { continue }

    $file = @{target = $file; path = "" }
  }

  $isDrive = (Split-Path $file.target) -match "^C:\\"
  if ($isDrive -ne $true) {
    $target_name = Split-Path $file.target -Leaf
    $file.target = Join-Path "$HOME/dotfiles" $file.target
  }

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

        #? Passing whitespace as a whole object will not result in a path error.
        New-Item -ItemType SymbolicLink @file | Out-Null
      }
      if (!$?) { Write-Error "${@file} is null. Failed to create symbolic link." }
    }
  }

  Set-SymbolicLink
  # Write-Output @file | Out-File result.txt -Append # for debug
}
