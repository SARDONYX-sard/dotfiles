[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $Force
)

<#
.SYNOPSIS
  write git config settings
.DESCRIPTION
  write git config settings
.EXAMPLE
  Invoke-Expression "$HOME/dotfiles/windows/setup/git-setting.ps1"

.NOTES
  Need $HOME/dotfiles/windows/data/git-config.txt
#>

function main {
  $gitConfigPath = Join-Path $HOME ".gitconfig"

  $hasGitConfig = Test-Path $gitConfigPath

  if ($hasGitConfig) {
    Write-Warning ".gitconfig  Already exists."
    if ($Force -eq $false) { return }

    Write-Warning "Force mode is running..."
    Copy-Item -Path $gitConfigPath -Destination "$gitConfigPath.bak" -Force
    Write-Host "Created backup of .gitconfig to $HOME/.gitconfig.bak" -ForegroundColor Green
  }

  windows\data\git-config.txt > $gitConfigPath
  Write-Host "Successes: Wrote to $HOME/.gitconfig" -ForegroundColor Green
}

main
