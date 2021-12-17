<#
.SYNOPSIS
  Short description
.DESCRIPTION
  Long description
.EXAMPLE
  # Install with manager.
  python.ps1 -Manager pip
  python.ps1 -Manager conda

  # Uninstall global packages.
  python.ps1 -Manager pip -Uninstall
  python.ps1 -Manager conda -Uninstall
.NOTES
  # You can install with libraries list(windows\data\requirements.txt)
  pip install -r requirements.txt


  # How to output requirements.txt
  pip freeze > requirements.txt
#>

param (
  [ValidateSet("pip" , "conda")]$Manager = "pip",
  [switch]$uni,
  [switch]$Uninstall
)


# --------------------------------------------------------------------------------------------------
# Install global library
# --------------------------------------------------------------------------------------------------
$libs = @(
  # Formatter & Linter
  @{ name = "autopep8"; description = "formatter." }
  @{ name = "flake8"; description = "linter." }

  # Manager(For update libs)

  @{ name = "pip-review"; description = "update modules." }
  @{ name = "pipx"; description = "(need pip>=19)Install and Run Python Applications in Isolated Environments."; }
  #? Install with pipx to avoid conflict errors. Add poetry to path by `ensurepath` command.
  @{ name = "poetry"; description = "python package manager."; installer = "pipx install poetry;pipx ensurepath" }
  # Other language
  @{ name = "fprettify"; description = "fortran formatter." }

  # Conveniences
  @{ name = "cython"; description = "C." }
  @{ name = "notebook"; description = "jupyter notebook." }
  @{ name = "selenium"; description = "E2E testing library." }

  # Editor
  # @{ name = "neovim"; description = "vim." }
)


# --------------------------------------------------------------------------------------------------
# Installer functions
# --------------------------------------------------------------------------------------------------
function check_python_available {
  if ((Get-Command -Name python) -eq $false) {
    Write-Warning "python is not installed."

    if (Get-Command -Name scoop) {
      Write-Host "Trying to install with scoop..." -ForegroundColor Cyan;
      scoop install python # latest python version (e.g. python3.10)
    }
    else {
      Write-Error "Scoop is not installed."
      Write-Host @'
You can install it in one of the following ways.

Manually install:
    Go to https://python.org


Install with Scoop:
Execute the following commands.↓

    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
    scoop install python
'@
    }
  }
}

function install_lib($lib) {
  Write-Host "";
  Write-Host "Installing $($lib.name)..." -ForegroundColor Blue;
  if ($lib.Description) {
    Write-Host "INFO: $($lib.description)" -ForegroundColor Blue;
  }

  if ($lib.installer) {
    Invoke-Expression $lib.installer;
    return;
  }

  switch ($Manager) {
    "conda" { conda install $lib.name -y }
    Default { pip install "$($lib.name)" }
  }
}

function uninstall_lib($lib) {
  Write-Host "";
  Write-Host "Uninstalling $($lib.name)..." -ForegroundColor Blue;
  if ($lib.Description) {
    Write-Host "INFO: $($lib.description)" -ForegroundColor Blue;
  }

  if ($lib.installer) {
    Invoke-Expression $lib.installer;
    return;
  }

  switch ($Manager) {
    "conda" { conda uninstall $lib.name -y }
    Default { pip uninstall "$($lib.name)" }
  }
}

function update_libs {
  Write-Host "Updating all libraries..." -ForegroundColor Blue;

  switch ($Manager) {
    "conda" {
      Write-Warning "Be careful and run it manually as there may be a startup error."
      "conda update --all -y; "
    }
    Default { pip-review --auto; }
  }
}

function main {
  check_python_available

  Write-Host "$Manager has been selected."
  try {
    foreach ($lib in $libs) {
      if ($uni -or $Uninstall) {
        uninstall_lib($lib);
        continue;
      }

      install_lib($lib);
    }

    if ($uni -or $Uninstall) { return; }
    update_libs
  }
  catch {
    Write-Error "$($_.Exception.Message)"; #? Because there is no library to update.
    return;
  }
  Write-Host "Successes: Finished working on all libraries." -ForegroundColor Green;
}

main
