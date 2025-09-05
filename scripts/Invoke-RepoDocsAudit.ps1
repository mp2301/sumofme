<#
.SYNOPSIS
  Run all documentation quality audits (links, footers, freshness).

.PARAMETER SkipExternalLinks
  Pass to avoid outbound HTTP calls (internal link validation only).

.PARAMETER StaleDays
  Override staleness threshold (default 180).
#>
[CmdletBinding()]
param(
  [switch]$SkipExternalLinks,
  [int]$StaleDays = 180
)

$root = Resolve-Path "$PSScriptRoot/.."
Write-Host "[1/3] Link Integrity" -ForegroundColor Cyan
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Test-LinkIntegrity.ps1') -Path $root @(@{SkipExternal=$true}[$SkipExternalLinks.IsPresent])

Write-Host "[2/3] Footer Consistency" -ForegroundColor Cyan
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Test-FooterConsistency.ps1') -Path $root

Write-Host "[3/3] Freshness" -ForegroundColor Cyan
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Test-Freshness.ps1') -Path $root -StaleDays $StaleDays

Write-Host "Audit complete. Reports in docs/reports." -ForegroundColor Green
