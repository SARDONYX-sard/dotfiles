<#
e.g.: nodejs.ps1 -Manager pnpm
#>

param (
  [ValidateSet("npm" , "pnpm", "yarn")]$m = "npm",
  [ValidateSet("npm" , "pnpm", "yarn")]$Manager = "npm",
  [switch]$rm,
  [switch]$Uninstall
)

if ($m) { $Manager = $m }
if ($rm) { $Uninstall = $rm }

Write-Host "$Manager has been selected."

$libs = @(
  # Basic
  @{ name = "fs-extra"; }
  @{ name = "nexe"; description = "exe generator." }

  # Optimization
  @{ name = "svgo"; description = "A Node.js-based tool for optimizing SVG." }

  # For update libs
  @{ name = "conventional-changelog-cli"; description = "Generate a changelog from git metadata." }
  @{ name = "license-checker"; description = "Automated auditing, performance metrics." }
  @{ name = "lighthouse"; description = "Find newer versions of dependencies." }
  @{ name = "npm-check-updates"; description = "Check for outdated dependencies." }
  @{ name = "webpack-bundle-size-analyzer"; description = "Analyze your webpack bundle size." }

  # Code linter
  @{ name = "eslint"; description = "An AST-based pattern checker for JavaScript." }
  @{ name = "prettier"; description = "An opinionated code formatter" }

  # Replacement of existing commands
  @{ name = "shx"; description = "Multi platform commands(e.g: `shx mkdir dirs`)" }
  @{ name = "tree-cli"; description = "Instead of tree command." }
  @{ name = "zx"; description = "A tool for writing better scripts." }

  # Transpiler
  @{ name = "typescript"; description = "Super set of JS." }
  @{ name = "ts-node"; description = "TypeScript execution environment." }
  @{ name = "@types/node"; description = "Type of Nodejs" } # for ts-node

  @{ name = "@swc/cli"; description = "CLI for super-fast alternative for babel" }
  @{ name = "@swc/core"; description = "Super-fast alternative for babel" } # swc/cli peer dependency
  @{ name = "@napi-rs/cli"; description = "Tool to write Node-API in Rust instead of C/C++." } # swc/cli peer dependency

  @{ name = "assemblyscript"; description = "Definitely not a TypeScript to WebAssembly compiler." }

  # React Native
  @{ name = "expo-cli"; description = "Creating and publishing Expo apps." }

  # VS Code extension generator
  @{ name = "generator-code"; }
  @{ name = "yo"; }
  @{ name = "vsce"; }
)

# Setup
if ($Manager -eq "pnpm") {
  if ((Get-Command pnpm).Name -notmatch "pnpm") {
    npm i -g pnpm;
  }
}
elseif ($Manager -eq "yarn") {
  if ((Get-Command yarn).Name -notmatch "yarn") {
    npm i -g yarn;
  }
}

function manage_lib($lib) {
  if ($lib.Description) {
    Write-Host "";
    if ($Uninstall -eq $true) {
      Write-Host "Uninstall $($lib.name)" -ForegroundColor Green;
    }
    else {
      Write-Host "Installing...: $($lib.name)" -ForegroundColor Green;
    }

  }

  if ($lib.Description) {
    Write-Host "INFO: $($lib.description)" -ForegroundColor Blue;
  }

  if ($Uninstall) {
    switch ($Manager) {
      "pnpm" { pnpm remove -g $lib.name; }
      "yarn" { yarn remove -g $lib.name; }
      Default { npm uninstall -g $lib.name; }
    }
  }
  else {
    switch ($Manager) {
      "pnpm" { pnpm add -g $lib.name; }
      "yarn" { yarn add -g $lib.name; }
      Default { npm install -g $lib.name; }
    }
  }
}


foreach ($lib in $libs) {
  manage_lib $lib;
}
