if (Test-Path "$HOME\scoop\apps\archwsl\current\Arch.exe" -ea 0) {
  New-DynamicFunction -CommandName "archwsl" -FunctionBody "$HOME\scoop\apps\archwsl\current\Arch.exe `$args"
}
