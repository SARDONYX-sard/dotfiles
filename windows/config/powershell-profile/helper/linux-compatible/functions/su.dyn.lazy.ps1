if ( Get-Command pwsh -ea 0 ) {
  Start-Process pwsh -Verb RunAs
}
elseif ( Get-Command powershell -ea 0 ) {
  Start-Process powershell -Verb RunAs
}
