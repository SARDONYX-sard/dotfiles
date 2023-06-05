#
# The same alias I had set up as my alias in linux
#

# powershell commands
@(
  @{ name = "$HOME"; alias_name = "~" }
  @{ name = "clear"; alias_name = "c" }

  #! Conditional branching by `Get-Command` causes a delay of `100ms` or more,
  #! so assume that the command is present to prevent reading delays.
  # Virtual machine
  @{ name = "docker-compose"; alias_name = "dc" }
  @{ name = "docker"; alias_name = "dk" }
) |
ForEach-Object { Set-Alias $_.alias_name $_.name }
