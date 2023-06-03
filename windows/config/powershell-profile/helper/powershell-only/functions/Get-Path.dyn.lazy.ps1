$toReplaceStr = "; `n"
[regex]::Replace($ENV:PATH, ";", "$toReplaceStr") | Sort-Object | Write-Host
