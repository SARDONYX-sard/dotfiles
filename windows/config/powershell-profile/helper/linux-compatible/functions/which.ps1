function which {
  param (
    [switch]$v,
    [switch]$Verbose
  )

  if ($args -match "scoop" -or $args -eq "s") { return "$HOME/scoop/shims/scoop.ps1"; }

  $path = (Get-Command -Name $args -ErrorAction SilentlyContinue)
  if ($path -match "scoop?:(\/|\\)shims") { return scoop which $args } # Solving the scoop path display problem
  if ($path.CommandType -eq "Alias") { $path = Get-Command $path.Definition }

  if ($v -or $Verbose) { return $path | Format-List }

  $path.Source
}
