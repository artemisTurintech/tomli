param(
    [int]$Runs = 1
)

$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

$throughputs = @()
$msPerParse  = @()
$avgTimes    = @()

for ($i = 1; $i -le $Runs; $i++) {
    Write-Host "Run $i of $Runs..."
    python run_benchmark.py | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Error "Benchmark run $i failed."; exit $LASTEXITCODE }
    $data = (Get-Content artemis_results.json | ConvertFrom-Json)[0]
    $throughputs += $data.throughput_parses_per_sec
    $msPerParse  += $data.ms_per_parse_mean
    $avgTimes    += $data.avg_time_for_500_parses_sec
}

function Get-Mean($arr) {
    ($arr | Measure-Object -Sum).Sum / $arr.Count
}

function Get-Std($arr) {
    if ($arr.Count -lt 2) { return 0.0 }
    $mean     = Get-Mean $arr
    $variance = ($arr | ForEach-Object { [math]::Pow($_ - $mean, 2) } | Measure-Object -Sum).Sum / $arr.Count
    [math]::Sqrt($variance)
}

$config = (Get-Content artemis_results.json | ConvertFrom-Json)[0]

$result = @(
    [ordered]@{
        runs              = $Runs
        repeats_per_run   = $config.repeats
        parses_per_trial  = $config.parses_per_trial
        throughput_parses_per_sec = [ordered]@{
            mean      = [math]::Round((Get-Mean $throughputs), 2)
            std       = [math]::Round((Get-Std  $throughputs), 2)
            direction = "higher_is_better"
        }
        ms_per_parse = [ordered]@{
            mean      = [math]::Round((Get-Mean $msPerParse), 4)
            std       = [math]::Round((Get-Std  $msPerParse), 4)
            direction = "lower_is_better"
        }
        avg_time_for_500_parses_sec = [ordered]@{
            mean      = [math]::Round((Get-Mean $avgTimes), 6)
            std       = [math]::Round((Get-Std  $avgTimes), 6)
            direction = "lower_is_better"
        }
    }
)

$json = ConvertTo-Json $result -Depth 4
Set-Content -Path artemis_results.json -Value $json -Encoding utf8
Write-Host $json
