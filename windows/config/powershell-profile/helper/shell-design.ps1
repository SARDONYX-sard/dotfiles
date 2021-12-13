# --------------------------------------------------------------------------------------------------
# PowerShell Prompt(Kali-Linux like)
# --------------------------------------------------------------------------------------------------
function Prompt {
  $promptString = "PowerShell " + $(Get-Location) + ">"
  $isAdmin = '$'
  if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $isAdmin = '#'
  }
  # Custom color for Windows console
  if ( $Host.Name -eq "ConsoleHost" ) {
    if ($PSVersionTable.PSEdition -eq "Core") {
      Write-Host ("┌──") -nonewline -foregroundcolor DarkGreen
    }
    Write-Host ("[") -nonewline -foregroundcolor DarkGreen
    write-host (Get-ShortenPath([string] (Get-Location).Path)) -nonewline -foregroundcolor White
    Write-Host ("]") -nonewline -foregroundcolor Green
    Write-Host (" ") -nonewline
    Write-Host (Get-Date -Format g) -nonewline -foregroundcolor yellow
    Write-Host (" ") -nonewline
    Write-Host ("[") -nonewline -foregroundcolor DarkGreen
    Write-Host ($env:username) -nonewline -foregroundcolor DarkCyan
    Write-Host ("@") -nonewline -foregroundcolor yellow
    Write-Host (hostname) -NoNewline -ForegroundColor DarkCyan
    Write-Host ("]") -nonewline -foregroundcolor DarkGreen
    Write-Host (" ") -foregroundcolor DarkGray
    if ($PSVersionTable.PSEdition -eq "Core") {
      Write-Host ("└─") -nonewline -foregroundcolor DarkGreen
    }
    Write-Host ($isAdmin) -nonewline -foregroundcolor DarkCyan
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


# --------------------------------------------------------------------------------------------------
# PowerShell Prompt Theme
# --------------------------------------------------------------------------------------------------
if ($PSVersionTable.PSEdition -eq "Core") {
  Import-Module posh-git
  Import-Module oh-my-posh
  Set-PoshPrompt Paradox
  # Set-PoshPrompt -Theme 'gmay'
  Set-PoshPrompt -Theme 'night-owl'

  $env:RunFromPowershell = 1

  Write-Host (Get-Date -Format g) -ForegroundColor DarkCyan
}