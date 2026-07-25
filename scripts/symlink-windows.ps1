# Windows dotfiles symbolic-link creator

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DotfilesDir,

    [Parameter(Mandatory)]
    [string]$ConfigDir,

    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$dotfilesRoot = [System.IO.Path]::GetFullPath($DotfilesDir).TrimEnd("\", "/")

function Write-Section([string]$Name) {
    Write-Host
    Write-Host "=== $Name ==="
}

function Test-RepoTarget([string]$Target) {
    if (-not $Target) {
        return $false
    }

    $fullTarget = [System.IO.Path]::GetFullPath($Target)
    return $fullTarget.StartsWith(
        "$dotfilesRoot\",
        [System.StringComparison]::OrdinalIgnoreCase
    )
}

function New-DotfileLink([string]$Source, [string]$Destination) {
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        Write-Host "- skip (not found): $Source"
        return
    }

    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($existing -and ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        $target = [string]$existing.Target
        $resolvedTarget = if ([System.IO.Path]::IsPathRooted($target)) {
            $target
        } else {
            Join-Path $existing.DirectoryName $target
        }

        if ([System.IO.Path]::GetFullPath($resolvedTarget) -eq [System.IO.Path]::GetFullPath($Source)) {
            Write-Host "OK: already linked: $Destination"
            return
        }

        if ((Test-RepoTarget $resolvedTarget) -and (Test-RepoTarget $Source)) {
            if ($DryRun) {
                Write-Host "Would relink: $Destination -> $Source"
            } else {
                Remove-Item -LiteralPath $Destination
                New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
                Write-Host "Relinked: $Destination -> $Source"
            }
            return
        }
    }

    if ($existing) {
        if (-not $Force) {
            Write-Host "- exists, skip: $Destination (use -Force to backup)"
            return
        }

        $backup = "$Destination.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        if ($DryRun) {
            Write-Host "Would backup: $Destination -> $backup"
        } else {
            Move-Item -LiteralPath $Destination -Destination $backup
            Write-Host "Backup: $Destination -> $backup"
        }
    }

    if ($DryRun) {
        Write-Host "+ would link: $Destination -> $Source"
        return
    }

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    Write-Host "OK: linked: $Destination -> $Source"
}

function Link-ConfigTree([string]$SourceRoot) {
    if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
        Write-Host "- skip tree (not found): $SourceRoot"
        return
    }

    Get-ChildItem -LiteralPath $SourceRoot -File -Recurse |
        Sort-Object FullName |
        ForEach-Object {
            $relative = $_.FullName.Substring($SourceRoot.Length).TrimStart("\", "/")
            if ($relative -like "nvim\*") {
                $destination = Join-Path $env:LOCALAPPDATA $relative
            } else {
                $destination = Join-Path $ConfigDir $relative
            }
            New-DotfileLink $_.FullName $destination
        }
}

Write-Host "OS: windows"

Write-Section "Base config"
Link-ConfigTree (Join-Path $dotfilesRoot "config/base")

Write-Section "windows config"
Link-ConfigTree (Join-Path $dotfilesRoot "config/windows")

Write-Section "Base home"
New-DotfileLink `
    (Join-Path $dotfilesRoot "home/base/.codex/AGENTS.md") `
    (Join-Path $HOME ".codex/AGENTS.md")

Write-Section "windows home"
$documentsDir = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
New-DotfileLink `
    (Join-Path $dotfilesRoot "home/windows/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1") `
    (Join-Path $documentsDir "WindowsPowerShell/Microsoft.PowerShell_profile.ps1")
New-DotfileLink `
    (Join-Path $dotfilesRoot "home/windows/Documents/PowerShell/Microsoft.PowerShell_profile.ps1") `
    (Join-Path $documentsDir "PowerShell/Microsoft.PowerShell_profile.ps1")
