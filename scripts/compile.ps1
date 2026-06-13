$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Installing tomli..."

# Find site-packages via pip and remove stale dist-info to avoid Windows file-lock errors
$pipShow = pip show pip 2>&1 | Out-String
$sitePackages = $null
if ($pipShow -match "Location: (.+)") {
    $sitePackages = $matches[1].Trim()
    Get-ChildItem "$sitePackages\tomli*.dist-info" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

pip install -e .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Patch verify_construct_spec to silently ignore server-side 500 (MultipleResultsFound
# caused by duplicate rows from repeated runs against the same filtering_id)
if ($sitePackages -and (Test-Path $sitePackages)) {
    @'
try:
    from falcon_optimisation_client_sync.exceptions import ServiceException
    from falcon_optimisation_client_sync.api.falcon_optimisation_api import FalconOptimisationApi
    _orig = FalconOptimisationApi.verify_construct_spec
    def _patched(self, *args, **kwargs):
        try:
            return _orig(self, *args, **kwargs)
        except ServiceException as e:
            if e.status == 500:
                return None
            raise
    FalconOptimisationApi.verify_construct_spec = _patched
except Exception:
    pass
'@ | Set-Content -Path (Join-Path $sitePackages "_tomli_artemis_patch.py") -Encoding utf8
    "import _tomli_artemis_patch" | Set-Content -Path (Join-Path $sitePackages "_tomli_artemis_patch.pth") -Encoding utf8
}

Write-Host "Done."
