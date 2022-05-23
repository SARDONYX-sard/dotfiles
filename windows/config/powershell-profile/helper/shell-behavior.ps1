Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -EditMode Vi
# https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1
Set-PSReadlineOption -HistoryNoDuplicates

# Debaounce insert mode to normal mode.
# https://github.com/PowerShell/PSReadLine/issues/1701
$j_timer = New-Object System.Diagnostics.Stopwatch

Set-PSReadLineKeyHandler -Key j -ViMode Insert -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("j")
  $j_timer.Restart()
}

Set-PSReadLineKeyHandler -Key k -ViMode Insert -ScriptBlock {
  if (!$j_timer.IsRunning -or $j_timer.ElapsedMilliseconds -gt 150) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("k")
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor, 1)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
  }
}

# Commands with only one alphabetic character are not kept in the history.
Set-PSReadlineOption -AddToHistoryHandler {
  param ($command)
  switch -regex ($command) {
    "SKIPHISTORY" { return $false }
    "^[a-z]$" { return $false }
  }
  return $true
}

# Don't forget closing brackets when completing methods
Remove-PSReadlineKeyHandler "tab"
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

Remove-PSReadlineKeyHandler "shift+tab"
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
