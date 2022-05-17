if ($PSVersionTable.PSEdition -eq "Core") {
  Import-Module posh-git
  Set-PSReadLineOption -PredictionSource History #* Core only module
}

$ImportBaseDirectory = "$HOME\dotfiles\windows\config\powershell-profile\helper";
@("common", "external-modules-settings", "linux-compatible", "powershell-only") | ForEach-Object {
  $ImportFullDirectory = "$ImportBaseDirectory\$_";

  if (Test-Path $ImportFullDirectory) {
    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.lazy.ps1" |
    ForEach-Object { . $_.FullName }
  }
}

Remove-Variable -Name "ImportFullDirectory"
Remove-Variable -Name "ImportBaseDirectory"
