<#
.SYNOPSIS
  Install msys2 and global libraries
.DESCRIPTION
  Install msys2 and global libraries.
.EXAMPLE
  # Install libraries.
  msys2.ps1
#>

sudo ln -s $HOME "$HOME\scoop\apps\msys2\current\home\$env:USERNAME"

function check_msys2_available {
  if ((Get-Command -Name msys2) -eq $false) {
    Write-Warning "msys2 is not installed."

    if (Get-Command -Name scoop) {
      Write-Host "Trying to install with scoop..." -ForegroundColor Cyan;
      scoop install msys2;
    }
    else {
      Write-Error "Scoop is not installed."
      Write-Host @'
Install with Scoop:
    Execute the following commands.↓

    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
    scoop install msys2;
'@
    }
  }
}

function main {
  check_msys2_available;

  install_modules;

  # Inherit PATH.from windows.
  [System.Environment]::SetEnvironmentVariable("MSYS2_PATH_TYPE", "inherit", "User")

  Write-Host "msys2 is available!" -ForegroundColor Green;
  Write-Host @'
Next:
    Execute the following commands.↓

    msys2 # Enter the msys2(bash) shell.
    $HOME/dotfiles/windows/bin/installers/pacman.sh # Install libraries with pacman.
'@
}

main
