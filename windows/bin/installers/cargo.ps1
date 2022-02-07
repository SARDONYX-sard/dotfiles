<#
.SYNOPSIS
  Install #Requires -RunAsAdministrator and global libraries
.DESCRIPTION
  Install #Requires -RunAsAdministrator and global libraries.
.EXAMPLE
  # Install libraries.
  cargo.ps1

  # Uninstall libraries.
  cargo.ps1 -Uninstall
#>

param (
  [switch]$uni,
  [switch]$Uninstall,
  [ValidateSet("cargo")]$m = "cargo",
  [ValidateSet("cargo")]$Manager = $null
)

if (!$Manager) { $Manager = $m }
if ($uni) { $Uninstall = $uni }

# --------------------------------------------------------------------------------------------------
# Install global library
# --------------------------------------------------------------------------------------------------
$libs = @(
  # For update libs
  @{ name = "cargo-update"; url = "https://github.com/nabijaczleweli/cargo-update";
    description = "Checking and applying updates to installed executables."
  }
  @{ name = "cargo-edit"; description = "cargo add command" }
  @{ name = "cargo-binutils"; url = "https://github.com/rust-embedded/cargo-binutils"; description = "Invoke the LLVM tools shipped with the Rust toolchain" }

  # Development
  @{ name = "git-cliff"; url = "https://github.com/orhun/git-cliff"; description = "generate changelog files." }
  @{ name = "trunk"; url = "https://github.com/thedodd/trunk"; description = "Build, bundle & ship your Rust WASM application to the web." }
  @{ name = "rustfilt"; url = "https://github.com/luser/rustfilt"; description = "Demangle Rust symbol names using rustc-demangle. " }

  # calculation + conversion. (e.g. cpc '1KB to Byte' => 1000 Byte)
  @{ name = "cpc"; url = "https://github.com/probablykasper/cpc"; description = "cpc parses and evaluates strings of math." }
  @{ name = "choose"; url = "https://github.com/theryangeary/choose"; description = "similar to Python's list slices" }
)


# --------------------------------------------------------------------------------------------------
# Installer functions
# --------------------------------------------------------------------------------------------------
function check_rustup_available {
  if ((Get-Command -Name rustup) -eq $false) {
    Write-Warning "rustup is not installed."

    if (Get-Command -Name scoop) {
      Write-Host "Trying to install with scoop..." -ForegroundColor Cyan;
      scoop install rustup # Nodejs Package Manager(e.g: rustup (1.24.3))
    }
    else {
      Write-Error "Scoop is not installed."
      Write-Host @'
You can install it in one of the following ways.

Manually install:
    Go to https://rust.org

    LTS version with longer security support is recommended.


Install with Scoop:
    Execute the following commands.↓

    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
    scoop install rustup
'@
    }
  }
}

# Implemented for later use or to make it similar to other files
function setup_manager { return; }

function manage_lib($lib) {
  if ($lib.Description) {
    Write-Host "";
    if ($Uninstall -eq $true) {
      Write-Host "Uninstall $($lib.name)" -ForegroundColor Green;
    }
    else {
      Write-Host "Installing...: $($lib.name)" -ForegroundColor Green;
    }

  }

  if ($lib.Description) {
    Write-Host "Description: $($lib.description)";
  }

  if ($lib.url) {
    Write-Host "        URL: " -NoNewline;
    Write-Host "$($lib.url)" -ForegroundColor Blue;
  }

  if ($Uninstall) {
    switch ($Manager) {
      Default { cargo uninstall $lib.name; }
    }
  }
  else {
    switch ($Manager) {
      Default { cargo install $lib.name; }
    }
  }
}

function main {
  check_rustup_available
  setup_manager

  Write-Host "$Manager has been selected."
  try {
    foreach ($lib in $libs) {
      manage_lib $lib;
    }

    if (!$Uninstall) {
      cargo install-update -a
    }
  }
  catch {
    Write-Error "$($_.Exception.Message)";
    return;
  }
  Write-Host "Successes: Finished working on all libraries." -ForegroundColor Green;
}

main
