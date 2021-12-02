<# setup
e.g.:
# Install with manager.
windows\setup\options\global-libs\python.ps1 -Manager pip
windows\setup\options\global-libs\python.ps1 -Manager conda

# Uninstall global packages.
windows\setup\options\global-libs\python.ps1 -Manager pip -Uninstall

# libraries list
pip freeze > requirements.txt
#>
param (
  [ValidateSet("pip" , "conda")]$Manager = "pip",
  [switch]$uni,
  [switch]$Uninstall
)


# --------------------------------------------------------------------------------------------------
# Libraries
# --------------------------------------------------------------------------------------------------
$libs = @(
  # Formatter & Linter
  @{ name = "autopep8"; description = "formatter." }
  @{ name = "flake8"; description = "linter." }

  # Manager(For update libs)
  @{ name = "pipx"; description = "(need pip>=19)Install and Run Python Applications in Isolated Environments."; }
  @{ name = "poetry"; description = "python package manager."; installer = "pipx install poetry" } #? Install with pipx to avoid conflict errors.
  @{ name = "pip-review"; description = "update modules." }

  @{ name = "notebook"; description = "jupyter notebook." }
  # Other language
  @{ name = "fprettify"; description = "fortran formatter." }

  # Conveniences
  @{ name = "cython"; description = "C." }
  @{ name = "selenium"; description = "E2E testing library." }

  # Editor
  # @{ name = "neovim"; description = "vim." }
)


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
    Write-Error "$($_.Exception.Message)";
    return;
  }
  Write-Host "Successes: All libraries are installed." -ForegroundColor Green;
}

main
