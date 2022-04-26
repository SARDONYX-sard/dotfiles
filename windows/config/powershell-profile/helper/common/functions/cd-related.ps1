@(
  @{ name = "`~"; option = "$HOME" }
  @{ name = ".."; option = ".." }
  @{ name = "..."; option = "../.." }
  @{ name = "...."; option = "../../.." }
  @{ name = "bb"; option = "-;Write-Host `"Back to previous directory.`" -ForegroundColor Green" }
)
| ForEach-Object {
  New-DynamicFunction -CommandName $_.name -FunctionBody  "cd `$args $_.option"
}
