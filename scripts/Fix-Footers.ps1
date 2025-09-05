<#
Fix standardized footers for identity and network documents under docs/.
This script updates the last non-empty line to the expected pattern when missing/invalid.
Usage: .\scripts\Fix-Footers.ps1
#>
$root = (Resolve-Path "$PSScriptRoot/..").Path
$docs = Join-Path $root 'docs'
Write-Host "Docs root: $docs"

$identityFooter = 'Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)'
$networkFooter  = 'Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)'

$files = Get-ChildItem -Path $docs -Recurse -Filter *.md | Where-Object { $_.Name -notmatch '^_index.md$' -and $_.FullName -notmatch 'reports' }

foreach ($f in $files) {
  $path = $f.FullName
  $lines = Get-Content -Path $path
  $trimmed = $lines | Where-Object { $_.Trim() -ne '' }
  if ($trimmed.Count -eq 0) { continue }
  $lastLine = $trimmed[-1]
  if ($path -match '\\identity\\') {
    if ($lastLine -notlike 'Return to [Identity Index]*') {
      Write-Host "Fixing footer in $path"
      # remove trailing empty lines
      while (($lines.Count -gt 0) -and ($lines[-1].Trim() -eq '')) { $lines = $lines[0..($lines.Count-2)] }
      $lines += $identityFooter
      Set-Content -LiteralPath $path -Value $lines -Encoding UTF8
    }
  } elseif ($path -match '\\network\\') {
    if ($lastLine -notlike 'Return to [Network Index]*') {
      Write-Host "Fixing footer in $path"
      while (($lines.Count -gt 0) -and ($lines[-1].Trim() -eq '')) { $lines = $lines[0..($lines.Count-2)] }
      $lines += $networkFooter
      Set-Content -LiteralPath $path -Value $lines -Encoding UTF8
    }
  }
}

Write-Host 'Footer fixes applied.'