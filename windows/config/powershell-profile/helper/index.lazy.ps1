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

if ($PSVersionTable.PSEdition -eq "Core") {
  # https://docs.microsoft.com/powershell/module/psreadline/about/about_psreadline?view=powershell-7.2
  Set-PSReadLineOption -PredictionSource History #* Core only module
}

@("common", "linux-compatible", "powershell-only") | ForEach-Object {
  $local:ImportFullDirectory = "$HelperDir\$_";

  if (Test-Path $ImportFullDirectory) {
    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.lazy.ps1" -Exclude "*.dyn.lazy.ps1" |
    ForEach-Object { . $_.FullName }

    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.dyn.lazy.ps1" |
    ForEach-Object {
      $FnBody = Get-Content $_.FullName -Raw
      # Write-Host $_.Name.Replace(".dyn.lazy.ps1", "")
      New-DynamicFunction -CommandName $_.Name.Replace(".dyn.lazy.ps1", "") -FunctionBody $FnBody
    }
  }
}
