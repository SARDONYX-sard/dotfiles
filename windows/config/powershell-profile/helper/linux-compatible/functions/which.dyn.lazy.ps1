param (
  [switch]$v,
  [switch]$Verbose,
  [switch]$a,
  [switch]$All
)

if ($Null -eq $args) { return }

if ($a -or $All) {
  $path = Get-Command $args -All

  if ($v -or $Verbose) {
    return $path | Format-List
  }

  return $path
}

if ($args -match "scoop" -or $args -eq "s") { return "$HOME/scoop/shims/scoop.ps1"; }

$path = (Get-Command -Name $args -ErrorAction SilentlyContinue)

if ($path -match "scoop?:(\/|\\)shims") {
  # Solving the scoop path display problem
  return scoop which $args
}

switch ($path.CommandType) {
  "Alias" { $path = Get-Command $path.Definition }
  "Function" {
    $path = $path.Definition -replace '^(\w+)\s.*$', '$1' | Get-Command -ErrorAction SilentlyContinue
  }
  Default {}
}

if ($v -or $Verbose) { return $path | Format-List }

$path.Source
