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
  Need $HOME/dotfiles/common/data/git-config.txt
#>

function main($GitFilePath, $Destination) {

  $hasGitConfig = Test-Path $Destination

  if ($hasGitConfig) {
    Write-Warning ".gitconfig  Already exists."
    if ($Force -eq $false) { return }

    Write-Warning "Force mode is running..."
    Copy-Item -Path $GitFilePath -Destination "$Destination.bak" -Force
    Write-Host "Created $GitFilePath.bak backup file" -ForegroundColor Green
  }

  [System.IO.File]::ReadAllText($GitFilePath)  > $Destination | Write-Host "Successes: Wrote to $GitFilePath" -ForegroundColor Green
}

$gitConfigPath = [IO.Path]::Combine($HOME, ".gitconfig")
main "$HOME/dotfiles/common/data/git/git-config.txt" $gitConfigPath
