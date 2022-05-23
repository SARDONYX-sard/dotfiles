# Parentheses/quotes input completion
Set-PSReadLineKeyHandler -Key "(", "{", "[" -BriefDescription "InsertPairedBraces" -LongDescription "Insert matching braces or wrap selection by matching braces" -ScriptBlock {
  param($key, $arg)
  $openChar = $key.KeyChar
  $closeChar = switch ($openChar) {
    <#case#> "(" { [char]")"; break }
    <#case#> "{" { [char]"}"; break }
    <#case#> "[" { [char]"]"; break }
  }

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $openChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    return
  }
  $nOpen = [regex]::Matches($line, [regex]::Escape($openChar)).Count
  $nClose = [regex]::Matches($line, [regex]::Escape($closeChar)).Count
  if ($nOpen -ne $nClose) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($openChar)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($openChar + $closeChar)
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
  }
}

# Do not enter extra closing brackets
Set-PSReadLineKeyHandler -Key ")", "]", "}" -BriefDescription "SmartCloseBraces" -LongDescription "Insert closing brace or skip" -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($line[$cursor] -eq $key.KeyChar) {
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.KeyChar)
  }
}


Set-PSReadLineOption -WordDelimiters ";:,.[]{}()/\|^&*-=+'`" !?@#$%&_<>「」（）『』『』［］、，。：；／"


Set-PSReadLineKeyHandler -Key "`"", "'" -BriefDescription "smartQuotation" -LongDescription "Put quotation marks and move the cursor between them or put marks around the selection" -ScriptBlock {
  param($key, $arg)
  $mark = $key.KeyChar

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $mark + $line.SubString($selectionStart, $selectionLength) + $mark)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    return
  }

  if ($line[$cursor] -eq $mark) {
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    return
  }

  $nMark = [regex]::Matches($line, $mark).Count
  if ($nMark % 2 -eq 1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($mark)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($mark + $mark)
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
  }
}

# Enclose the command in parentheses
Set-PSReadLineKeyHandler -Key "alt+w" -BriefDescription "WrapLineByParenthesis" -LongDescription "Wrap the entire line and move the cursor after the closing parenthesis or wrap selected string" -ScriptBlock {
  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, "(" + $line.SubString($selectionStart, $selectionLength) + ")")
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
  }
}
