#
# The same alias I had set up as my alias in linux
#

# powershell commands
@(
  @{ name = "$HOME"; alias_name = "~" }
  @{ name = "clear"; alias_name = "c" }
) |
ForEach-Object { Set-Alias $_.alias_name $_.name }

# exe files
@(
  # Virtual machine
  @{ name = "docker-compose"; alias_name = "dc" }
  @{ name = "docker"; alias_name = "dk" }
) |
ForEach-Object {
  if (Get-Command $_.name -ErrorAction SilentlyContinue) { Set-Alias $_.alias_name $_.name }
}
