$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Running tests..."
python -m unittest
exit $LASTEXITCODE
