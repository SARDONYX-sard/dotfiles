if (Get-Command lsd -ErrorAction SilentlyContinue) {
  # `F` - Append indicator
  # `a` - Show all
  # `l` - Display list permission status

  @(
    @{ name = "l"; option = "" }
    @{ name = "la"; option = "a" }
    @{ name = "ll"; option = "l" }
    @{ name = "lla"; option = "al" }
  ) |
  ForEach-Object {
    New-DynamicFunction -CommandName $_.name -FunctionBody  "lsd -F$($_.option) `$args"
  }
}
