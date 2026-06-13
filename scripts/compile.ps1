$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Installing tomli..."

# Remove stale dist-info to avoid Windows file-lock errors during pip uninstall
$sitePackages = python -c "import site; print(site.getsitepackages()[0])"
if ($sitePackages) {
    Get-ChildItem "$sitePackages\tomli*.dist-info" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

pip install -e .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Done."
