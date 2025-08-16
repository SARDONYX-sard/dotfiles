Write-Host "Calculating disk usage for directories..." -ForegroundColor Cyan

Get-ChildItem -Directory | ForEach-Object { $size = (Get-ChildItem $_.FullName -Recurse -File |
    Measure-Object -Property Length -Sum).Sum;

  [PSCustomObject]@{Directory = $_.FullName; SizeGB = [math]::Round($size / 1GB, 2) } } |

Sort-Object SizeGB -Descending |
ForEach-Object { "{0,-50} {1,10:N2} GB" -f $_.Directory, $_.SizeGB }
