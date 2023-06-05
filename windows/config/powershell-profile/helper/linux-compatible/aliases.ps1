#
# Standard linux commands
#

# ! Only pwsh is enabled because powershell cannot overwrite existing aliases.
if ($PSVersionTable.PSEdition -eq "Core") {
  # Instead of commnad by Rust
  # The sd command is not registered as an alias because it is not compatible.
  @(
    @{ name = "bat"; alias_name = "cat" }
    @{ name = "dog"; alias_name = "dig" }
    @{ name = "fd"; alias_name = "find" }
    @{ name = "lsd"; alias_name = "ls" }
    @{ name = "procs"; alias_name = "ps" }
    @{ name = "rg"; alias_name = "grep" }
  ) |
  #! Conditional branching by `Get-Command` causes a delay of `100ms` or more,
  #! so assume that the command is present to prevent reading delays.
  ForEach-Object { Set-Alias $_.alias_name $_.name }
}
