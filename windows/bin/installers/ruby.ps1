<#
.SYNOPSIS
  Install ruby and global libraries
.DESCRIPTION
  Install ruby and global libraries.
.EXAMPLE
  # Install libraries.
  ruby.ps1
#>

function check_ruby_available {
  if ((Get-Command -Name ruby) -eq $false) {
    Write-Warning "Ruby is not installed."

    if (Get-Command -Name scoop) {
      Write-Host "Trying to install with scoop..." -ForegroundColor Cyan;
      scoop install ruby;
    }
    else {
      Write-Error "Scoop is not installed."
      Write-Host @'
You can install it in one of the following ways.

Manually install:
    Go to https://www.ruby-lang.org/


Install with Scoop:
    Execute the following commands.↓

    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
    scoop install ruby;
'@
    }
  }
}


function install_libs {
  gem install rubocop;
  gem install ruby-debug-ide;
  gem install solargraph;
  gem install minitest;
}

function main {
  check_ruby_available;

  ridk install 3;
  install_libs;
}

main
