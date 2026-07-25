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

$failed = @()
foreach ($package in $packages) {
    & winget list --id $package --exact --accept-source-agreements *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK: $package"
        continue
    }

    Write-Host "Installing: $package"
    & winget install --id $package --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $package"
        $failed += $package
    }
}

if ($failed.Count -gt 0) {
    Write-Host
    Write-Host "Failed packages: $($failed -join ', ')"
    exit 1
}

Write-Host "OK: winget packages ready ($($packages.Count) total)"
exit 0
