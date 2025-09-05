<#
.SYNOPSIS
  Validate standardized footer presence and format in docs.

.DESCRIPTION
  Ensures each non-index markdown file ends with a single standardized footer line:
    Return to [Identity Index](../_index.md) ... (identity domain)
    Return to [Network Index](../_index.md) ... (network domain)
  Allows additional related links after the vertical bars.
  Reports deviations & missing footers.
#>
[CmdletBinding()]
param(
  [string]$Path = (Resolve-Path "$PSScriptRoot/..")
)
Set-StrictMode -Version Latest
$rootDocs = Join-Path $Path 'docs'
$files = Get-ChildItem -Path $rootDocs -Recurse -Filter *.md | Where-Object { $_.Name -notmatch '^_index.md$' -and $_.FullName -notmatch 'reports' }

$patternIdentity = '^Return to \[Identity Index\]\(\.\./_index\.md\)'
$patternNetwork  = '^Return to \[Network Index\]\(\.\./_index\.md\)'
$fail = @()
foreach ($f in $files) {
  $lines = Get-Content -Path $f.FullName
  # find last non-empty line
  $last = ($lines | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1)
  if (-not $last) { $fail += [pscustomobject]@{ File=$f.FullName; Issue='EmptyFile' ; Line=$null }; continue }
  if ($f.FullName -match '\\identity\\') {
    if ($last -notmatch $patternIdentity) { $fail += [pscustomobject]@{ File=$f.FullName; Issue='FooterMissingOrInvalid'; Line=$lines.Length } }
  } elseif ($f.FullName -match '\\network\\') {
    if ($last -notmatch $patternNetwork) { $fail += [pscustomobject]@{ File=$f.FullName; Issue='FooterMissingOrInvalid'; Line=$lines.Length } }
  }
}

if ($fail.Count -eq 0) {
  Write-Host "All footers valid." -ForegroundColor Green
} else {
  Write-Warning "Footer issues: $($fail.Count)"
  $fail | Format-Table -AutoSize
  $fail | ConvertTo-Json -Depth 3 | Out-File (Join-Path $rootDocs 'reports/footer-report.json')
}
