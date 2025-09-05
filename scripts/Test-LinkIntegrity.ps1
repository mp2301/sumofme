<#
.SYNOPSIS
  Validate external and internal Markdown links with summary & reports.

.DESCRIPTION
  Scans all *.md under docs/ (excluding reports/) extracting links from markdown.
  Performs HEAD then fallback GET (for 405/403/400) with timeout & retry.
  Internal links validated for file existence & section anchors.
  Generates:
    reports/link-report.json  (raw result set)
    reports/link-report.md    (human summary)

.PARAMETER Path
  Root directory to scan (default: repo root of script).

.PARAMETER TimeoutSeconds
  Per-request timeout (default 8).

.PARAMETER Concurrency
  Maximum simultaneous external requests (default 12). Uses async Tasks.

.PARAMETER SkipExternal
  Only validate internal links when set.

.NOTES
  Designed for Windows PowerShell 5.1+ (uses HttpClient Tasks for concurrency).
#>
[CmdletBinding()]
param(
  [string]$Path = (Resolve-Path "$PSScriptRoot/.."),
  [int]$TimeoutSeconds = 8,
  [int]$Concurrency = 12,
  [switch]$SkipExternal
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-HttpClient {
  $handler = New-Object System.Net.Http.HttpClientHandler
  $handler.AllowAutoRedirect = $true
  $client = [System.Net.Http.HttpClient]::new($handler)
  $client.Timeout = [TimeSpan]::FromSeconds($TimeoutSeconds)
  $client.DefaultRequestHeaders.UserAgent.ParseAdd('DocsLinkChecker/1.0')
  return $client
}

function Get-MarkdownFiles {
  Get-ChildItem -Path (Join-Path $Path 'docs') -Recurse -Filter *.md | Where-Object { $_.FullName -notmatch '\\reports\\' }
}

function Get-LinksFromFile($file) {
  $content = Get-Content -Path $file.FullName -Raw
  # Markdown links: [text](url) ignoring images ![]()
  $pattern = '(?<!\\)!?\[(?<text>[^\]]+)\]\((?<url>[^)\s]+)(?:\s+"[^"]*")?\)'
  $results = [System.Text.RegularExpressions.Regex]::Matches($content, $pattern)
  $lines = $content -split "`n"
  foreach ($m in $results) {
    if ($m.Value.StartsWith('!')) { continue } # skip images
    $url = $m.Groups['url'].Value.Trim()
    if ($url.StartsWith('#')) { continue } # intra-page anchor
    # locate line number (first match containing the exact fragment)
    $lineIndex = ($lines | Select-String -SimpleMatch $m.Value -List).LineNumber
    [pscustomobject]@{
      File = $file.FullName
      Relative = $file.FullName.Substring($Path.Length + 1)
      Line = $lineIndex
      Url  = $url
    }
  }
}

function Test-InternalLink($linkObj) {
  $url = $linkObj.Url
  # Only relative (no scheme) & not starting with mailto:
  if ($url -match '^[a-z]+://') { return $null }
  if ($url -match '^mailto:') { return $null }
  # Remove anchor if present
  $parts = $url.Split('#',2)
  $pathPart = $parts[0]
  $anchor = $null
  if ($parts.Count -eq 2) { $anchor = $parts[1] }
  $candidate = Join-Path (Split-Path $linkObj.File) $pathPart | Resolve-Path -ErrorAction SilentlyContinue
  $exists = [bool]$candidate
  $anchorOk = $true
  if ($exists -and $anchor) {
    $fileText = Get-Content -Path $candidate -Raw
    $anchorPattern = '(?im)^#+\s+' + [Regex]::Escape($anchor).Replace(' ','[- ]')
    $anchorOk = [Regex]::IsMatch($fileText, $anchorPattern)
  }
  [pscustomobject]@{
    Type = 'Internal'
    File = $linkObj.Relative
    Line = $linkObj.Line
    Url = $url
    Exists = $exists
    AnchorValid = $anchorOk
    Ok = ($exists -and $anchorOk)
  }
}

function Split-LinkSets($links) {
  $internal = @()
  $external = @()
  foreach ($l in $links) {
    if ($l.Url -match '^[a-z]+://' -or $l.Url -match '^mailto:') { $external += $l } else { $internal += $l }
  }
  return @{ Internal=$internal; External=$external }
}

function Invoke-ExternalChecks($linkObjs) {
  if (-not $linkObjs) { return @() }
  $client = New-HttpClient
  $sem = [System.Threading.SemaphoreSlim]::new($Concurrency, $Concurrency)
  $tasks = foreach ($l in $linkObjs) {
    $null = $sem.WaitAsync()
    [System.Threading.Tasks.Task]::Run( {
      try {
        $uri = [Uri]$l.Url
        $method = [System.Net.Http.HttpMethod]::Head
        $req = [System.Net.Http.HttpRequestMessage]::new($method,$uri)
        $resp = $client.SendAsync($req).GetAwaiter().GetResult()
        if ($resp.StatusCode.value__ -in 400,403,405,501) {
          # retry GET
          $req2 = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get,$uri)
          $resp = $client.SendAsync($req2).GetAwaiter().GetResult()
        }
        $finalUri = $resp.RequestMessage.RequestUri.AbsoluteUri
        [pscustomobject]@{
          Type='External'; File=$l.Relative; Line=$l.Line; Url=$l.Url; Status=[int]$resp.StatusCode; FinalUrl=$finalUri; Ok=($resp.IsSuccessStatusCode) ; Error=$null }
      } catch {
        [pscustomobject]@{ Type='External'; File=$l.Relative; Line=$l.Line; Url=$l.Url; Status=$null; FinalUrl=$null; Ok=$false; Error=$_.Exception.Message }
      } finally { $null = $sem.Release() }
    })
  }
  [System.Threading.Tasks.Task]::WaitAll($tasks)
  $results = $tasks | ForEach-Object { $_.Result }
  $client.Dispose()
  return $results
}

Write-Host "Scanning markdown..." -ForegroundColor Cyan
$allLinks = Get-MarkdownFiles | ForEach-Object { Get-LinksFromFile $_ }
$sets = Split-LinkSets $allLinks
Write-Host ("Internal links: {0} | External links: {1}" -f $sets.Internal.Count,$sets.External.Count)

$internalResults = $sets.Internal | ForEach-Object { Test-InternalLink $_ }
$externalResults = @()
if (-not $SkipExternal) { $externalResults = Invoke-ExternalChecks $sets.External }

$report = $internalResults + $externalResults
$summary = [pscustomobject]@{
  Timestamp = (Get-Date).ToString('s')
  InternalTotal = $internalResults.Count
  InternalFailures = ($internalResults | Where-Object { -not $_.Ok }).Count
  ExternalTotal = $externalResults.Count
  ExternalFailures = ($externalResults | Where-Object { -not $_.Ok }).Count
  OverallFailures = ($report | Where-Object { -not $_.Ok }).Count
}

New-Item -ItemType Directory -Path (Join-Path $Path 'docs/reports') -Force | Out-Null
$jsonOut = @{ Summary=$summary; Results=$report } | ConvertTo-Json -Depth 4
$jsonPath = Join-Path $Path 'docs/reports/link-report.json'
$jsonOut | Out-File -FilePath $jsonPath -Encoding utf8

$mdPath = Join-Path $Path 'docs/reports/link-report.md'
@(
  '# Link Integrity Report'
  "Generated: $($summary.Timestamp)"
  ''
  "| Metric | Count |"
  "|--------|-------|"
  "| Internal Links | $($summary.InternalTotal) |"
  "| Internal Failures | $($summary.InternalFailures) |"
  "| External Links | $($summary.ExternalTotal) |"
  "| External Failures | $($summary.ExternalFailures) |"
  "| Overall Failures | $($summary.OverallFailures) |"
  ''
  '## Failures'
) + (
  $report | Where-Object { -not $_.Ok } | ForEach-Object { "- ``$($_.Type)`` $($_.Status) $($_.Url) (File: $($_.File):$($_.Line)) $($_.Error)" }
) | Out-File -FilePath $mdPath -Encoding utf8

if ($summary.OverallFailures -gt 0) { Write-Warning "Link failures detected ($($summary.OverallFailures)). See reports/link-report.md" } else { Write-Host "All links OK" -ForegroundColor Green }
