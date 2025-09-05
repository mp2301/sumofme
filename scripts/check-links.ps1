Param(
    [string]$Root = (Resolve-Path '..' ),
    [switch]$FailOnWarning
)

Write-Host "Scanning markdown files under $Root" -ForegroundColor Cyan
$md = Get-ChildItem -Path $Root -Recurse -Include *.md -File
$errors = @()
foreach ($file in $md) {
    $content = Get-Content $file.FullName -Raw
    $links = Select-String -InputObject $content -Pattern '\]\((https?://[^)]+)\)' -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    foreach ($link in $links) {
        # skip known noisy patterns that block programmatic access or are developer placeholders
        if ($link -match 'linkedin\.com' -or $link -match 'localhost') {
            Write-Host "Ignoring link (pattern match): $link" -ForegroundColor Yellow
            continue
        }
        try {
            $resp = Invoke-WebRequest -Uri $link -Method Head -TimeoutSec 15 -ErrorAction Stop
            if ($resp.StatusCode -ge 400) {
                $errors += [pscustomobject]@{ File=$file.FullName; Link=$link; Code=$resp.StatusCode }
                Write-Warning "Bad status $($resp.StatusCode) $link ($($file.Name))"
            }
        }
        catch {
            $errors += [pscustomobject]@{ File=$file.FullName; Link=$link; Code='EXCEPTION' }
            Write-Warning "Exception accessing $link ($($file.Name)) : $($_.Exception.Message)"
        }
    }
}
if ($errors.Count -gt 0) {
    Write-Host "Found $($errors.Count) problematic links" -ForegroundColor Red
    $errors | Format-Table -AutoSize
    if ($FailOnWarning) { exit 1 }
} else {
    Write-Host "All links OK" -ForegroundColor Green
}