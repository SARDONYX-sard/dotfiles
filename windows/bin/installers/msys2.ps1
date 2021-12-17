<#
.SYNOPSIS
  Install msys2 and global libraries
.DESCRIPTION
  Install msys2 and global libraries.
.EXAMPLE
  # Install libraries.
  msys2.ps1
#>

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


function install_libs {
  # need 1.07 GB of disk space
  pacman -S git --noconfirm
  pacman -Sy ccache --noconfirm
  pacman -Sy findutils --noconfirm
  pacman -Sy make --noconfirm
  pacman -Sy mingw-w64-x86_64-toolchain --noconfirm
  pacman -Sy ncurses-devel --noconfirm
  pacman -Sy openssh --noconfirm
  pacman -Sy subversion --noconfirm
}

function main {
  check_msys2_available;

  ridk install 3;
  install_libs;
}

main
