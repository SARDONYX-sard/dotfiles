# creates a new function dynamically
function New-DynamicFunction {
  [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
  param(
    [string] $CommandName,
    [string] $FunctionBody,
    [scriptblock] $ScriptBlock
  )

  if ($FunctionBody -eq $null) {
    $Body = $ScriptBlock
  }
  elseif ($ScriptBlock -eq $null) {
    $Body = $FunctionBody
  }
  else {
    $Body = ""
  }
  # create new function in function: drive and set scope to "script:"
  $null = New-Item -Path function: -Name "script:$CommandName" -Value $Body
}

$ImportBaseDirectory = "$HOME\dotfiles\windows\config\powershell-profile\helper";

@("behaviors", "common", "external-modules-settings", "linux-compatible", "powershell-only") | ForEach-Object {
  $ImportFullDirectory = "$ImportBaseDirectory\$_";

  if (Test-Path $ImportFullDirectory) {
    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.ps1" -Exclude "*.lazy.ps1" |
    ForEach-Object {
      . $_.FullName
    }
  }

}

Remove-Variable -Name "ImportFullDirectory"
Remove-Variable -Name "ImportBaseDirectory"
