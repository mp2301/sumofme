# Documentation Quality Scripts

| Script | Purpose | Key Outputs |
|--------|---------|-------------|
| `Test-LinkIntegrity.ps1` | Validates internal & external markdown links with concurrency | `docs/reports/link-report.json` / `.md` |
| `Test-FooterConsistency.ps1` | Ensures standardized footer format across docs | `docs/reports/footer-report.json` |
| `Test-Freshness.ps1` | Flags pages whose `Last Reviewed` date is stale (>=180 days default) | `docs/reports/staleness-report.*` |
| `Invoke-RepoDocsAudit.ps1` | Runs all of the above in sequence | Aggregated reports |

## Usage Examples

```powershell
# Run full audit
pwsh ./scripts/Invoke-RepoDocsAudit.ps1

# Internal links only (skip external HTTP calls)
pwsh ./scripts/Invoke-RepoDocsAudit.ps1 -SkipExternalLinks

# Custom staleness threshold (e.g., 120 days)
pwsh ./scripts/Test-Freshness.ps1 -StaleDays 120

# Standalone link check with higher concurrency & 12s timeout
pwsh ./scripts/Test-LinkIntegrity.ps1 -Concurrency 20 -TimeoutSeconds 12
```

## Footer Standard
Each non-index file ends with a line starting with:
- Identity: `Return to [Identity Index](../_index.md)`
- Network: `Return to [Network Index](../_index.md)`

## Planned Enhancements
- Cache for external link responses (ETags + 24h TTL)
- Anchor existence cache per file
- Optional auto-fix mode for missing footers
- GitHub Action wrapper

## Notes
- Scripts are PS 5.1 compatible; concurrency via async Tasks (link check).
- External link validation may take time; adjust `-Concurrency` if throttled.
