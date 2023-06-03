# https://stackoverflow.com/questions/20541456/list-of-all-colors-available-for-powershell

$colors = [enum]::GetValues([System.ConsoleColor])
Foreach ($bgcolor in $colors) {
  Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewline }
  Write-Host " on $bgcolor"
}
