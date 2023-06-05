@("common", "linux-compatible", "powershell-only") | ForEach-Object {
  $local:ImportFullDirectory = "$HelperDir\$_";

  if (Test-Path $ImportFullDirectory) {
    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.lazy.ps1" -Exclude "*.dyn.lazy.ps1" |
    ForEach-Object { . $_.FullName }

    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.dyn.lazy.ps1" |
    ForEach-Object {
      $FnBody = Get-Content $_.FullName -Raw -Encoding utf8
      # Write-Host $_.Name.Replace(".dyn.lazy.ps1", "")
      New-DynamicFunction -CommandName $_.Name.Replace(".dyn.lazy.ps1", "") -FunctionBody $FnBody
    }
  }
}
