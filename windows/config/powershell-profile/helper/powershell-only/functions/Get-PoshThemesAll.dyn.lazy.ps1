$ThemesPath = [IO.Path]::Combine("$(which oh-my-posh | Split-Path | Split-Path)", "themes")
if (($null -eq $ThemesPath) -or !(Test-Path $ThemesPath) ) {
  Write-Host "Themes path not found." -ForegroundColor Red
  return
}
Get-PoshThemes -Path $ThemesPath
