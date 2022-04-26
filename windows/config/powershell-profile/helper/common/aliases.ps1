#
# The same alias I had set up as my alias in linux
#

@(
  @{ name = "$HOME"; alias_name = "~" }
  @{ name = "clear"; alias_name = "c" }

  # Virtual machine
  @{ name = "docker-compose"; alias_name = "dc" }
  @{ name = "docker"; alias_name = "dk" }
)
| ForEach-Object {
  if (Get-Command $_.name -ErrorAction SilentlyContinue) { Set-Alias $_.alias_name $_.name }
}
