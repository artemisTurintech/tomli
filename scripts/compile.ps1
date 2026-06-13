$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Installing tomli..."

# Remove stale dist-info to avoid Windows file-lock errors during pip uninstall
$pipShow = pip show tomli 2>&1 | Out-String
if ($pipShow -match "Location: (.+)") {
    $location = $matches[1].Trim()
    Get-ChildItem "$location\tomli*.dist-info" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

pip install -e .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Done."
