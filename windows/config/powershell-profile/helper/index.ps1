# creates a new function dynamically
function New-DynamicFunction {
  [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
  param(
    [string] $CommandName,
    [string] $FunctionBody
  )

  # create new function in function: drive and set scope to "script:"
  $null = New-Item -Path function: -Name "script:$CommandName" -Value $FunctionBody
}

$ImportBaseDirectory = "$HOME\dotfiles\windows\config\powershell-profile\helper";

@("common", "linux-compatible", "powershell-only") | ForEach-Object {
  $ImportFullDirectory = "$ImportBaseDirectory\$_";

  if (Test-Path $ImportFullDirectory) {
    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Exclude "*.md"
    | ForEach-Object {
      . $_.FullName
    }
  }

}
