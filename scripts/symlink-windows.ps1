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

function Link-Tree([string]$SourceRoot, [string]$DestinationRoot) {
    if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
        Write-Host "- skip tree (not found): $SourceRoot"
        return
    }

    Get-ChildItem -LiteralPath $SourceRoot -File -Recurse |
        Sort-Object FullName |
        ForEach-Object {
            $relative = $_.FullName.Substring($SourceRoot.Length).TrimStart("\", "/")
            New-DotfileLink $_.FullName (Join-Path $DestinationRoot $relative)
        }
}

Write-Host "OS: windows"

Write-Section "Base config"
Link-Tree (Join-Path $dotfilesRoot "config/base") $ConfigDir

Write-Section "windows config"
Link-Tree (Join-Path $dotfilesRoot "config/windows") $ConfigDir

Write-Section "Base home"
Link-Tree (Join-Path $dotfilesRoot "home/base") $HOME

Write-Section "windows home"
Link-Tree (Join-Path $dotfilesRoot "home/windows") $HOME
