<#
.SYNOPSIS
  Set up these dotfiles on a Windows machine. No git or Rust needed.
.DESCRIPTION
  Remote (fresh machine):  irm https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/bootstrap/install.ps1 | iex
    With options:          & ([scriptblock]::Create((irm <same URL>))) -Profile sardonyx -Install
  From a clone:            pwsh -File bootstrap/install.ps1 [options]

  1. Get `dot` + `dots/`: the latest release archive (SHA256-verified) -> dot.exe in
     ~/.local/bin, dots/ in -Dir (default ~/dotfiles; kept if it already exists).
     From a clone, the clone is used instead; -FromSource builds dot with cargo.
  2. With -Profile, activate dots/profiles/<name> (`dot profile use`).
  3. dot gen; show `dot deploy -n`; deploy after confirmation (undo: `dot rollback`).
  4. Create ~/.gitconfig.local from the template if missing (and no profile links one).
  5. With -Install: install scoop if missing, then `dot install` (tools.toml).
  Safe to re-run. Works in Windows PowerShell 5.1 and pwsh 7.
#>
[CmdletBinding()]
param(
  # Deploy without asking.
  [switch]$Yes,
  # Also install scoop (if missing) and the tool groups from tools.toml.
  [switch]$Install,
  # Pass --force to `dot deploy` (back up and replace conflicting real files).
  [switch]$Force,
  # Pass --prune to `dot deploy` (remove unmanaged links into this repo).
  [switch]$Prune,
  # Build `dot` with cargo instead of downloading a release (clone only).
  [switch]$FromSource,
  # Activate this profile (dots/profiles/<name>) before generating/deploying.
  # (Not named $Profile: that would shadow the automatic $PROFILE variable.)
  [Alias('Profile')]
  [string]$ProfileName,
  # Where to unpack dots/ when not running from a clone.
  [string]$Dir = (Join-Path $HOME 'dotfiles'),
  # GitHub owner/repo to download releases from (forks: set this or $env:DOT_REPO).
  [string]$Repo = $(if ($env:DOT_REPO) { $env:DOT_REPO } else { 'SARDONYX-sard/dotfiles' })
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # Invoke-WebRequest is very slow with the progress bar
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # PS 5.1

function Invoke-Step([string]$Title, [scriptblock]$Body) {
  Write-Host "==> $Title" -ForegroundColor Green
  & $Body
  if ($LASTEXITCODE) { throw "$Title failed (exit $LASTEXITCODE)" }
}

# Running from a clone? ($PSScriptRoot is empty under `irm | iex`.)
$Clone = $null
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot '..\dots\core\dot.toml'))) {
  $Clone = Split-Path -Parent $PSScriptRoot
}

# Download + verify + extract the latest release; returns the extracted dir.
function Get-Release([string]$Tmp) {
  $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'aarch64' } else { 'x86_64' }
  $asset = "dot-$arch-pc-windows-msvc.zip"
  # $env:DOT_RELEASE_URL overrides the download base URL (mirrors, testing).
  $base = if ($env:DOT_RELEASE_URL) { $env:DOT_RELEASE_URL } else { "https://github.com/$Repo/releases/latest/download" }
  Invoke-WebRequest "$base/$asset" -OutFile "$Tmp/$asset" -UseBasicParsing
  Invoke-WebRequest "$base/SHA256SUMS" -OutFile "$Tmp/SHA256SUMS" -UseBasicParsing
  # `<hash>  <file>` or, from binary mode, `<hash> *<file>`.
  $line = Select-String -Path "$Tmp/SHA256SUMS" -Pattern "^([0-9a-fA-F]{64}) [ *]$([regex]::Escape($asset))$"
  $expected = if ($line) { $line.Matches[0].Groups[1].Value } else { $null }
  if (-not $expected -or $expected -ne (Get-FileHash "$Tmp/$asset" -Algorithm SHA256).Hash) {
    throw "SHA256 mismatch for $asset"
  }
  Expand-Archive "$Tmp/$asset" -DestinationPath $Tmp
  return (Join-Path $Tmp "dot-$arch-pc-windows-msvc")
}

function Install-FromSource([string]$Root) {
  $cargo = Join-Path $HOME '.cargo\bin\cargo.exe'
  if (Get-Command cargo -ErrorAction Ignore) {
    $cargo = 'cargo'
  } elseif (-not (Test-Path $cargo)) {
    Invoke-Step 'Install Rust (rustup)' {
      winget install --exact --id Rustlang.Rustup --accept-package-agreements --accept-source-agreements
    }
  }
  Invoke-Step 'Build dot' { & $cargo install --locked --path (Join-Path $Root 'crates\dot_cli') }
  return (Join-Path $HOME '.cargo\bin\dot.exe')
}

# --- 1. dot + dots/ -------------------------------------------------------------
$bin = Join-Path $HOME '.local\bin'
$dot = $null
if ($Clone -and $FromSource) {
  $dot = Install-FromSource $Clone
} else {
  if ($FromSource) { throw '-FromSource needs a clone (git clone ... && pwsh -File bootstrap/install.ps1)' }
  Write-Host "==> Download dot + dots/ (latest release of $Repo)" -ForegroundColor Green
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ('dot-' + [guid]::NewGuid())
  New-Item -ItemType Directory $tmp | Out-Null
  try {
    $rel = Get-Release $tmp
    New-Item -ItemType Directory -Force $bin | Out-Null
    Copy-Item (Join-Path $rel 'dot.exe') $bin -Force
    $dot = Join-Path $bin 'dot.exe'
    if (-not $Clone) {
      if (Test-Path (Join-Path $Dir 'dots\core\dot.toml')) {
        Write-Host "keeping existing $Dir\dots (only dot.exe was updated)"
      } else {
        New-Item -ItemType Directory -Force $Dir | Out-Null
        Copy-Item (Join-Path $rel 'dots') $Dir -Recurse -Force
        Write-Host "unpacked dots/ -> $Dir\dots"
      }
    }
  } catch {
    if ($Clone) {
      Write-Warning "Download failed ($_); building from source."
      $dot = Install-FromSource $Clone
    } else {
      throw "Download failed: $_ (no release yet? clone the repo and use -FromSource)"
    }
  } finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
}
$Root = if ($Clone) { $Clone } else { $Dir }
$env:DOT_ROOT = $Root

# --- 2-3. profile, gen, deploy -----------------------------------------------------
if ($ProfileName) { Invoke-Step "Use profile $ProfileName" { & $dot profile use $ProfileName } }
Invoke-Step 'Generate shell init scripts' { & $dot gen }
Invoke-Step 'Plan (dry run)' { & $dot deploy --dry-run }

$deployArgs = @('deploy')
if ($Force) { $deployArgs += '--force' }
if ($Prune) { $deployArgs += '--prune' }
if ($Yes -or (Read-Host 'Apply this plan? [y/N]') -match '^(y|yes)$') {
  Invoke-Step 'Deploy' { & $dot @deployArgs }
  Write-Host 'Undo with: dot rollback' -ForegroundColor Yellow
} else {
  Write-Host 'Skipped deploy.'
}

# --- 4. git identity -------------------------------------------------------------
$gitLocal = Join-Path $HOME '.gitconfig.local'
if (-not (Test-Path $gitLocal)) {
  Copy-Item (Join-Path $Root 'dots\core\home\git\config.local.example') $gitLocal
  Write-Host "Created $gitLocal - set your git name/email there." -ForegroundColor Yellow
}

# --- 5. tools --------------------------------------------------------------------
if ($Install) {
  if (-not (Get-Command scoop -ErrorAction Ignore)) {
    Invoke-Step 'Install scoop' { Invoke-RestMethod https://get.scoop.sh | Invoke-Expression }
    $env:PATH = (Join-Path $HOME 'scoop\shims') + [IO.Path]::PathSeparator + $env:PATH
  }
  Invoke-Step 'Install tools' { & $dot install }
}

Write-Host 'Done. Open a new shell.' -ForegroundColor Green
if (-not $Clone) {
  Write-Host "To track $Dir with git later (keeps local edits):" -ForegroundColor DarkGray
  Write-Host "  git -C `"$Dir`" init; git -C `"$Dir`" remote add origin https://github.com/$Repo; git -C `"$Dir`" fetch origin; git -C `"$Dir`" reset origin/main" -ForegroundColor DarkGray
}
