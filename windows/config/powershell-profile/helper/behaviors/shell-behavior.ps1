Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -HistoryNoDuplicates # https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1

if (Get-Command nvim -ErrorAction SilentlyContinue) {
  $env:EDITOR = $env:VISUAL = 'nvim'
}

# refference: https://github.com/PowerShell/PSReadLine/issues/3159
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
  $ESC = "$([char]0x1b)"
  if ($args[0] -eq 'Command') {
    Write-Host -NoNewline "${ESC}[1 q" # Set the cursor to a blinking block.
    return
  }
  Write-Host -NoNewline "${ESC}[5 q" # Set the cursor to a blinking line.
}

# DeBounce insert mode to normal mode.(insert mode -> "jj" or "jk" -> normal mode)
# https://github.com/PowerShell/PSReadLine/issues/1701
$local:j_timer = New-Object System.Diagnostics.Stopwatch
function Set-DebounceChangeMode {
  Set-PSReadLineKeyHandler -Key "j" -ViMode Insert -ScriptBlock {
    if (!$j_timer.IsRunning -or $j_timer.ElapsedMilliseconds -gt 300) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("j")
      $j_timer.Restart()
      return
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("j")
    [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
    $local:line = $null
    $local:cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 2)
  }

  Set-PSReadLineKeyHandler -Key "k" -ViMode Insert -ScriptBlock {
    if (!$j_timer.IsRunning -or $j_timer.ElapsedMilliseconds -gt 300) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("k")
      return
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
    $local:line = $null
    $local:cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor, 1)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
  }
}
Set-DebounceChangeMode

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
