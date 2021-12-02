<#
e.g.: nodejs.ps1 -Manager pnpm
#>

param (
  [ValidateSet("npm" , "pnpm", "yarn")]$Manager = "npm"
)

Write-Host "$Manager has been selected."

$libs = @(
  # Basic
  @{ name = "fs-extra"; }
  @{ name = "nexe"; description = "exe generator." }

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
  @{ name = "@swc/cli"; description = "CLI for super-fast alternative for babel" }
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
  npm i -g pnpm;
}
elseif ($Manager -eq "yarn") {
  if ((Get-Command yarn).Name -notmatch "yarn") {
    npm i -g yarn;
  }
}

function install_lib($libName) {
  if ($lib.Description) {
    Write-Host "";
    Write-Host "INFO: $($lib.name)" -ForegroundColor Blue;
    Write-Host "INFO: $($lib.description)" -ForegroundColor Blue;
  }

  switch ($Manager) {
    "pnpm" { pnpm add -g $libName; }
    "yarn" { yarn add -g $libName; }
    Default { npm install -g $libName; }
  }
}

foreach ($lib in $libs) {
  install_lib $lib.name;
}
