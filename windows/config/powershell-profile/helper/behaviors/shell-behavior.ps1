# Commands with only one alphabetic character are not kept in the history.
Set-PSReadLineOption -AddToHistoryHandler {
  param ($command)
  switch -regex ($command) {
    "SKIPHISTORY" { return $false }
    "^[a-z]$" { return $false }
  }
  return $true
}

# Don't forget closing brackets when completing methods
Remove-PSReadLineKeyHandler "tab"
Set-PSReadLineKeyHandler -Key "tab" -BriefDescription "smartNextCompletion" -LongDescription "insert closing parenthesis in forward completion of method" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($line[($cursor - 1)] -eq "(") {
    if ($line[$cursor] -ne ")") {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert(")")
      [Microsoft.PowerShell.PSConsoleReadLine]::BackwardChar()
    }
  }
}

Remove-PSReadLineKeyHandler "shift+tab"
Set-PSReadLineKeyHandler -Key "shift+tab" -BriefDescription "smartPreviousCompletion" -LongDescription "insert closing parenthesis in backward completion of method" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::TabCompletePrevious()
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($line[($cursor - 1)] -eq "(") {
    if ($line[$cursor] -ne ")") {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert(")")
      [Microsoft.PowerShell.PSConsoleReadLine]::BackwardChar()
    }
  }
}

# Reloading profiles
Set-PSReadLineKeyHandler -Key "alt+r" -BriefDescription "reloadPROFILE" -LongDescription "reloadPROFILE" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('<#SKIPHISTORY#> . $PROFILE')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Use the variable used immediately before
Set-PSReadLineKeyHandler -Key "alt+a" -BriefDescription "yankLastArgAsVariable" -LongDescription "yankLastArgAsVariable" -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$")
  [Microsoft.PowerShell.PSConsoleReadLine]::YankLastArg()
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($line -match '\$\$') {
    $newLine = $line -replace '\$\$', "$"
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $newLine)
  }
}

# Stores the clipboard contents in a variable named $CLIPPING
Set-PSReadLineKeyHandler -Key "ctrl+V" -BriefDescription "setClipString" -LongDescription "setClipString" -ScriptBlock {
  $command = "<#SKIPHISTORY#> get-clipboard | sv CLIPPING"
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory('$CLIPPING ')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
