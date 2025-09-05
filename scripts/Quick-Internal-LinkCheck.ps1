Param(
  [string]$Root = (Resolve-Path "$PSScriptRoot/..")
)

$mdFiles = Get-ChildItem -Path (Join-Path $Root 'docs') -Recurse -Filter *.md | Where-Object { $_.FullName -notmatch '\\reports\\' }
$linkPattern = '\[([^\]]+)\]\(([^)\s]+)(?:\s+"[^"]*")?\)'
$failures = @()
$total = 0
foreach ($f in $mdFiles) {
  $content = Get-Content -Path $f.FullName -Raw
  $matches = [regex]::Matches($content, $linkPattern)
  foreach ($m in $matches) {
    $fullMatch = $m.Groups[0].Value
    # skip image links which start with '!'
    if ($fullMatch.StartsWith('!')) { continue }
    $url = $m.Groups[2].Value.Trim()
    if ($url -like 'http*' -or $url -like 'mailto:*' -or $url.StartsWith('#')) { continue }
    $total = $total + 1
    $parts = $url -split '#',2
    $pathPart = $parts[0]
    $candidate = Join-Path (Split-Path $f.FullName) $pathPart
    if (-not (Test-Path $candidate)) {
      $failures += [pscustomobject]@{ File = $f.FullName; Link = $url }
    }
  }
}

$reportDir = Join-Path $Root 'docs/reports'
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$mdPath = Join-Path $reportDir 'internal-link-report.md'
@(
  '# Internal Link Report'
  "Generated: $(Get-Date -Format s)"
  ''
  "Total internal links scanned: $total"
  "Failures: $($failures.Count)"
  ''
  '## Broken Links'
) + (
  $failures | ForEach-Object { "- $($_.Link) (in file: $($_.File))" }
) | Out-File -FilePath $mdPath -Encoding utf8

if ($failures.Count -gt 0) { Write-Warning "Found $($failures.Count) broken internal links. See $mdPath" } else { Write-Host "No broken internal links found" -ForegroundColor Green }
