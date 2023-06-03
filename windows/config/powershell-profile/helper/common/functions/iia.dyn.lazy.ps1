# Invoke-Item Open All(e.g. iia scoop)
which $cmd -a | ForEach-Object {
  if ($_.CommandType -ne "Function") {
    Start-Process -FilePath C:\Windows\explorer.exe -ArgumentList "/select, ""$($_.Source)"""
  }
}
