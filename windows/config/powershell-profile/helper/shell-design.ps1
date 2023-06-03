# --------------------------------------------------------------------------------------------------
# PowerShell Prompt Theme
# --------------------------------------------------------------------------------------------------
# PowerShell Prompt(Kali-Linux like)
function Set-KaliTheme {
  $promptString = "PowerShell " + $(Get-Location) + ">"
  $isAdmin = '$'
  if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $isAdmin = '#'
  }
  # Custom color for Windows console
  if ( $Host.Name -eq "ConsoleHost" ) {
    if ($PSVersionTable.PSEdition -eq "Core") {
      Write-Host ("┌──") -NoNewline -ForegroundColor DarkGreen
    }
    Write-Host ("[") -NoNewline -ForegroundColor DarkGreen
    Write-Host (Get-ShortenPath([string] (Get-Location).Path)) -NoNewline -ForegroundColor White
    Write-Host ("]") -NoNewline -ForegroundColor Green

    if ((Get-History).count -ge 1) {
      $executionTime = ((Get-History)[-1].EndExecutionTime - (Get-History)[-1].StartExecutionTime).Totalmilliseconds
    }
    $executionTime = [math]::Round($executionTime, 2)
    Write-Host " (" -NoNewline -ForegroundColor darkcyan
    Write-Host "$executionTime" -NoNewline
    Write-Host "ms" -NoNewline -ForegroundColor DarkGray
    Write-Host ") " -NoNewline -ForegroundColor darkcyan

    Write-Host (Get-Date -Format g)  -ForegroundColor DarkYellow
    if ($PSVersionTable.PSEdition -eq "Core") {
      Write-Host ("└─") -NoNewline -ForegroundColor DarkGreen
    }
    Write-Host ($isAdmin) -NoNewline -ForegroundColor darkcyan
  }
  # Default color for the rest
  else {
    Write-Host $promptString -NoNewline
  }

  return " "
}
function Get-ShortenPath([string] $path) {
  # 1. Replace home path to "~"
  # 2. remove prefix for UNC paths
  # 3. make path shorter like tabs in Vim, handle paths starting with \ and . correctly
  return $path.Replace($HOME, '~').Replace('^[^:]+::', '').Replace('\(.?)([^\])[^\]*(?=\)', '$1$2')
}

Set-KaliTheme
