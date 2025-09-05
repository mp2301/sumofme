<#
Quick external link checker.
Scans .md files under the given root for http/https links and tries a HEAD/GET with timeout.
Usage: powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Quick-External-LinkCheck.ps1 -Root 'C:\Source\sumofme'
#>
param(
    [string]$Root = "${PWD}",
    [int]$TimeoutSeconds = 10,
    [int]$DelayMs = 200
)

$report = "${Root}\docs\reports\external-link-report.md"
New-Item -Path (Split-Path $report) -ItemType Directory -Force | Out-Null
"# External Link Report" | Out-File -FilePath $report -Encoding utf8
"Generated: $(Get-Date -Format o)" | Out-File -FilePath $report -Append -Encoding utf8
"" | Out-File -FilePath $report -Append -Encoding utf8

$mdFiles = Get-ChildItem -Path $Root -Recurse -Include *.md -File | Where-Object { $_.FullName -notmatch '\\docs\\reports\\' }
$linkPattern = '(http[s]?://[^)\s]+)'
$all = @()
foreach ($f in $mdFiles) {
    $text = Get-Content -Raw -Path $f.FullName -ErrorAction SilentlyContinue
    if (-not $text) { continue }
    $matches = [regex]::Matches($text, $linkPattern)
    foreach ($m in $matches) {
        $url = $m.Groups[1].Value.TrimEnd(')')
        $all += [PSCustomObject]@{ File = $f.FullName; Url = $url }
    }
}
$unique = $all | Select-Object -Unique Url | ForEach-Object { $_.Url }
$total = $unique.Count
"Total external links found: $total" | Out-File -FilePath $report -Append -Encoding utf8
"" | Out-File -FilePath $report -Append -Encoding utf8

foreach ($u in $unique) {
    Start-Sleep -Milliseconds $DelayMs
    try {
        # Use System.Net.WebRequest for PowerShell 5.1 compatibility; prefer a HEAD request first, fall back to GET
        $req = [System.Net.WebRequest]::Create($u)
        $req.Method = 'HEAD'
        $req.Timeout = $TimeoutSeconds * 1000
        try {
            $resp = $req.GetResponse()
            $status = "$($resp.StatusCode) - $($resp.StatusDescription)"
            $resp.Close()
        } catch {
            # If HEAD not allowed, try GET
            try {
                $req2 = [System.Net.WebRequest]::Create($u)
                $req2.Method = 'GET'
                $req2.Timeout = $TimeoutSeconds * 1000
                $resp2 = $req2.GetResponse()
                $status = "$($resp2.StatusCode) - $($resp2.StatusDescription)"
                $resp2.Close()
            } catch {
                $status = "ERROR: $($_.Exception.GetType().Name) - $($_.Exception.Message)"
            }
        }
    } catch {
        $status = "ERROR: $($_.Exception.GetType().Name) - $($_.Exception.Message)"
    }
    "- $u -> $status" | Out-File -FilePath $report -Append -Encoding utf8
}

Write-Host "External link report written to: $report"
