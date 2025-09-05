<#
.SYNOPSIS
  Audit Last Reviewed freshness for markdown files.

.DESCRIPTION
  Parses YAML front matter to extract Last Reviewed date. Reports files older than threshold (default 180 days).
  Outputs markdown + JSON reports.
#>
[CmdletBinding()]
param(
  [string]$Path = (Resolve-Path "$PSScriptRoot/.."),
  [int]$StaleDays = 180
)
Set-StrictMode -Version Latest
$now = Get-Date
$docsRoot = Join-Path $Path 'docs'
$files = Get-ChildItem -Path $docsRoot -Recurse -Filter *.md | Where-Object { $_.FullName -notmatch 'reports' }
$results = foreach ($f in $files) {
  $raw = Get-Content -Path $f.FullName -Raw
  if ($raw -notmatch '^---\s*\n(?<fm>.+?)\n---'s) { continue }
  $fm = [Regex]::Match($raw,'^---\s*\n(?<fm>.+?)\n---'s).Groups['fm'].Value
  $date = ($fm -split "`n" | ForEach-Object { if ($_ -match '^Last Reviewed:\s*(.+)$') { $Matches[1].Trim() } }) | Select-Object -First 1
  if (-not $date) { continue }
  $parsed = [DateTime]::Parse($date)
  $age = ($now - $parsed).Days
  [pscustomobject]@{ File=$f.FullName.Substring($Path.Length+1); LastReviewed=$parsed.ToString('yyyy-MM-dd'); AgeDays=$age; Stale=($age -ge $StaleDays) }
}

$stale = $results | Where-Object { $_.Stale }
New-Item -ItemType Directory -Path (Join-Path $docsRoot 'reports') -Force | Out-Null
$outJson = @{ Generated=$now.ToString('s'); Threshold=$StaleDays; Total=$results.Count; Stale=$stale.Count; Items=$stale } | ConvertTo-Json -Depth 4
$outJson | Out-File (Join-Path $docsRoot 'reports/staleness-report.json') -Encoding utf8

@(
  '# Staleness Report'
  "Generated: $($now.ToString('s'))"
  "Threshold Days: $StaleDays"
  "Total Docs Scanned: $($results.Count)"
  "Stale Docs: $($stale.Count)"
  ''
  '| File | Last Reviewed | Age (days) |'
  '|------|---------------|------------|'
) + ($stale | Sort-Object AgeDays -Descending | ForEach-Object { "| $($_.File) | $($_.LastReviewed) | $($_.AgeDays) |" }) |
  Out-File (Join-Path $docsRoot 'reports/staleness-report.md') -Encoding utf8

if ($stale.Count -gt 0) { Write-Warning "$($stale.Count) stale docs (>= $StaleDays days)." } else { Write-Host "No stale docs." -ForegroundColor Green }
