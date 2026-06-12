$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Installing tomli..."
pip install -e .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Done."
