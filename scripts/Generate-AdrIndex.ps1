Param(
  [string]$AdrPath = "docs/enterprise/architecture/adr",
  [string]$IndexFile = "docs/enterprise/architecture/adr/_index.md",
  [int]$Max = 15
)

if(!(Test-Path $AdrPath)){ Write-Host "ADR path not found: $AdrPath" -ForegroundColor Red; exit 1 }

$rows = Get-ChildItem -Path $AdrPath -Filter '20*-*.md' -File |
  Sort-Object Name -Descending |
  Select-Object -First $Max |
  ForEach-Object {
    $name = $_.BaseName
    if($name -match '^(\d{4}-\d{2}-\d{2})-(.*)$'){
      $date = $Matches[1]
      $titleLine = (Get-Content $_.FullName | Select-String '^Title:' | Select-Object -First 1).ToString()
      $statusLine = (Get-Content $_.FullName | Select-String '^Status:' | Select-Object -First 1).ToString()
      $title = ($titleLine -replace '^Title:\s*','').Trim()
      $status = ($statusLine -replace '^Status:\s*','').Trim()
  # Index file now lives in the same folder as ADRs, so use direct relative links
  "| $date | [$title]($($_.Name)) | $status |"
    }
  }

$index = Get-Content $IndexFile -Raw
$startMarker = '<!-- ADR-INDEX-START -->'
$endMarker   = '<!-- ADR-INDEX-END -->'
$startPos = $index.IndexOf($startMarker)
$endPos   = $index.IndexOf($endMarker)
if($startPos -lt 0 -or $endPos -lt 0 -or $endPos -le $startPos){
  Write-Host 'ADR Index markers not found in index file' -ForegroundColor Yellow
  exit 1
}

$prefix = $index.Substring(0, $startPos)
$suffix = $index.Substring($endPos + $endMarker.Length)

$block = @()
$block += $startMarker
$block += 'Below is a lightweight list of recent ADRs. For full history, list files matching `YYYY-*` in this folder.'
$block += ''
$block += '| Date | Title | Status |'
$block += '|------|-------|--------|'
if($rows){ $block += $rows }
$block += $endMarker

$newIndex = $prefix + ($block -join "`n") + $suffix
Set-Content -Path $IndexFile -Value $newIndex -Encoding UTF8
Write-Host "ADR index regenerated with $($rows.Count) entries." -ForegroundColor Green
