if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
    Set-Alias vi nvim
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    zoxide init powershell | Out-String | Invoke-Expression
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    starship init powershell | Out-String | Invoke-Expression
}

$secretsDir = Join-Path $HOME ".secrets"

if (Test-Path -LiteralPath $secretsDir -PathType Container) {
    Get-ChildItem -LiteralPath $secretsDir -File | ForEach-Object {
        Get-Content -LiteralPath $_.FullName | ForEach-Object {
            if ($_ -match '^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(["'']?)(.*?)\2\s*$') {
                Set-Item -Path "Env:$($matches[1])" -Value $matches[3]
            }
        }
    }
}
