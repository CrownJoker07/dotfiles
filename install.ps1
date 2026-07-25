# Dotfiles installer - Windows entry point

[CmdletBinding()]
param(
    [Alias("d")]
    [switch]$DryRun,

    [Alias("f")]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$dotfilesDir = $PSScriptRoot
$configDir = if ($env:XDG_CONFIG_HOME) {
    $env:XDG_CONFIG_HOME
} else {
    Join-Path $HOME ".config"
}

Write-Host "Dotfiles dir: $dotfilesDir"
Write-Host "Config dir:   $configDir"
Write-Host

& (Join-Path $dotfilesDir "scripts/symlink-windows.ps1") `
    -DotfilesDir $dotfilesDir `
    -ConfigDir $configDir `
    -DryRun:$DryRun `
    -Force:$Force

if ($DryRun) {
    Write-Host "- dry-run: skip package installer"
} else {
    & (Join-Path $dotfilesDir "scripts/install-windows.ps1") -DotfilesDir $dotfilesDir
    if ($LASTEXITCODE -ne 0) {
        Write-Host
        Write-Host "Done with package installer errors."
        exit $LASTEXITCODE
    }
}

Write-Host
Write-Host "Done."
