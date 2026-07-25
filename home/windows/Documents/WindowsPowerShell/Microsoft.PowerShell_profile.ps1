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
