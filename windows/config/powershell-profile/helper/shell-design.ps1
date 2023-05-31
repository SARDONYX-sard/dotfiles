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
    Write-Host (" ") -NoNewline
    Write-Host (Get-Date -Format g) -NoNewline -ForegroundColor DarkYellow
    Write-Host (" ") -NoNewline
    # Write-Host ("[") -NoNewline -ForegroundColor DarkGreen
    # Write-Host ($env:username) -NoNewline -ForegroundColor DarkCyan
    # Write-Host ("@") -NoNewline -ForegroundColor yellow
    # Write-Host (hostname) -NoNewline -ForegroundColor DarkCyan
    # Write-Host ("]") -NoNewline -ForegroundColor DarkGreen
    Write-Host (" ") -ForegroundColor DarkGray
    if ($PSVersionTable.PSEdition -eq "Core") {
      Write-Host ("└─") -NoNewline -ForegroundColor DarkGreen
    }
    Write-Host ($isAdmin) -NoNewline -ForegroundColor DarkCyan
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

if ($PSVersionTable.PSEdition -eq "Core") {
  oh-my-posh --init pwsh --config "$HOME\dotfiles\common\data\oh-my-posh-themes\my-custom.json" | Invoke-Expression
}

Set-KaliTheme
