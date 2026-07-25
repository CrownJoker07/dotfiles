# Windows setup - installs packages from packages/packages.conf with winget

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DotfilesDir
)

$ErrorActionPreference = "Stop"
$packageFile = Join-Path $DotfilesDir "packages/packages.conf"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required. Install App Installer from the Microsoft Store and run this script again."
}

if (-not (Test-Path -LiteralPath $packageFile -PathType Leaf)) {
    throw "Package manifest not found: $packageFile"
}

$packages = foreach ($line in Get-Content -LiteralPath $packageFile) {
    if ($line -match "^\s*windows\.winget\s*=\s*([^#]+?)\s*$") {
        $Matches[1] -split "\s+" | Where-Object { $_ }
    }
}
$packages = $packages | Sort-Object -Unique

Write-Host
Write-Host "=== winget packages ==="

$installedPackages = (& winget list --accept-source-agreements 2>&1) -join [Environment]::NewLine
if ($LASTEXITCODE -ne 0) {
    throw "Failed to read installed packages from winget."
}

$failedPackages = @()
foreach ($package in $packages) {
    $packagePattern = "(?m)(^|\s)$([Regex]::Escape($package))(\s|$)"
    if ($installedPackages -match $packagePattern) {
        Write-Host "OK: $package"
        continue
    }

    Write-Host "Installing: $package"
    & winget install --id $package --exact --no-upgrade --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $package"
        $failedPackages += $package
    }
}

$miseCommand = (Get-Command mise -ErrorAction SilentlyContinue).Source
if (-not $miseCommand) {
    $misePath = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\mise.exe"
    if (Test-Path -LiteralPath $misePath -PathType Leaf) {
        $miseCommand = $misePath
    }
}

Write-Host
Write-Host "=== mise dev tools ==="

$miseFailed = $false
if (-not $miseCommand) {
    Write-Host "- skip: mise not found"
} else {
    Write-Host "Installing tools from ~/.config/mise/config.toml"
    & $miseCommand install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: mise dev tools"
        $miseFailed = $true
    } else {
        Write-Host "OK: mise dev tools ready"
    }
}

if ($failedPackages.Count -gt 0) {
    Write-Host
    Write-Host "Failed packages: $($failedPackages -join ', ')"
}

if ($failedPackages.Count -gt 0 -or $miseFailed) {
    exit 1
}

Write-Host
Write-Host "OK: Windows setup complete"
exit 0
