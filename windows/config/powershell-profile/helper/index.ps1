# creates a new function dynamically
function New-DynamicFunction {
  [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
  param(
    [string] $CommandName,
    [string] $FunctionBody,
    [scriptblock] $ScriptBlock
  )

  if ($FunctionBody -eq $null) {
    $Body = $ScriptBlock.ToString()
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

@("common", "linux-compatible", "powershell-only") | ForEach-Object {
  $local:ImportFullDirectory = "$HelperDir\$_";
  if (Test-Path $ImportFullDirectory) {
    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.ps1" -Exclude "*.lazy.ps1" |
    ForEach-Object {
      . $_.FullName
    }
  }
}
