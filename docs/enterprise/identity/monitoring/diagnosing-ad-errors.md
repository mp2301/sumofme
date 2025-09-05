---
Last Reviewed: 2025-09-04
Tags: 
---

# Diagnosing Common Active Directory Errors

Understanding and diagnosing AD errors is crucial before considering restore operations. This guide summarizes common issues, how to distinguish healthy vs. unhealthy states, and when restore actions may be warranted.

## Table of Contents
- [Common Errors](#common-errors)
- [Diagnostic Tools Comparison](#diagnostic-tools-comparison)
- [Copy / Paste Command Examples](#copy--paste-command-examples)
- [When to Consider Restore](#when-to-consider-restore)
- [Footer](#footer)

## Common Errors

| Category | Symptoms / Indicators | Common Causes | Primary Diagnostics |
|----------|----------------------|---------------|---------------------|
| Replication Failures | Event IDs 1311, 1865, 2042; objects not syncing between DCs | Network/firewall issues; DNS misconfiguration; USN rollback; lingering objects | `repadmin /showrepl`, event logs, DNS validation, lingering object scan |
| Database Corruption | DC fails to start; NTDS errors; missing objects | Disk/storage corruption; abrupt shutdown; hardware failure | NTDS event logs; `ntdsutil` semantic & integrity checks; hardware diagnostics |
| SYSVOL / GPO Issues | GPOs not applying; missing / inconsistent SYSVOL share | DFS-R backlog; legacy FRS; permissions problems | `dcdiag /test:sysvolcheck`; DFS-R backlog; share + ACL validation |
| Authentication Failures | Users cannot log in; Kerberos errors; trust failures | Time skew; DNS resolution issues; broken trusts; replication delay | Time sync audit; DNS forward/reverse tests; `netdom trust`; Kerberos event triage |

## Diagnostic Tools Comparison

| Tool | Healthy Indicators | Unhealthy Indicators | Notes / Follow-Up |
|------|--------------------|----------------------|-------------------|
| `dcdiag` | All tests pass; no critical warnings; SYSVOL & NETLOGON accessible | DNS / replication test failures; missing shares; service start errors | Run targeted tests (`dcdiag /test:DNS /e /v`); capture baseline output |
| `repadmin` | All partners succeed; low latency; no lingering objects | Repeated failures; high queue; USN rollback warnings | `repadmin /replsummary` + `/showrepl`; fix DNS/connectivity first |
| Event Viewer (Dir Services / System / DNS / Security) | Predictable volume; low error rate | Flood of 1311/1865/2042; NTDS corruption; Kerberos / trust failures | Baseline normal rates; correlate spikes to change timeline |
| `ntdsutil` | Integrity & semantic checks pass | Integrity / semantic failures; corruption output | Isolate DC; plan authoritative restore or rebuild if corruption confirmed |
| DFS-R (SYSVOL) | Backlog near zero; versions in sync | Persistent backlog; journal wrap; access denied | `dfsrdiag backlog`; confirm permissions; avoid forced non-authoritative resets during backlog |
| Time Sync (`w32tm`) | Consistent hierarchy; minimal skew | Large skew; Kerberos KDC_ERR_SKEW | Validate authoritative source; correct offsets |
| DNS (`nslookup`, zone records) | Complete SRV records; forward/reverse consistent | Missing SRV; stale A/PTR; mis-mapped site subnets | Force zone replication; scavenge stale; correct site/subnet mappings |

Regularly review these indicators to maintain AD health and surface issues before they become recovery events.

Document findings (commands, event excerpts, timestamps) before initiating any restore path; this preserves forensic clarity and informs recovery selection.

## Copy / Paste Command Examples

### Replication & Lingering Objects
```powershell
# Summary replication health (errors, fails, latency)
repadmin /replsummary
# Detailed per-partner attempts for this DC
repadmin /showrepl
# Check for lingering objects (advisory mode)
repadmin /removelingeringobjects <DestDC> <SourceDC_GUID> <NamingContext> /ADVISORY_MODE
```

### DFS-R (SYSVOL) Backlog & Health
```powershell
# Backlog between two partners (adjust names)
dfsrdiag backlog /rgname:"domain system volume" /rfname:sysvol /sendingmember:<DC1> /receivingmember:<DC2> /full
# Health report (HTML)
dfsrdiag health /report:DFSR-Health.html
```

### Time Synchronization
```powershell
w32tm /query /configuration
w32tm /query /status
# Force resync (avoid on PDC emulator while diagnosing)
w32tm /resync /nowait
```

### DNS Core SRV & Controller Listing
```powershell
# _ldap SRV records
nslookup -type=SRV _ldap._tcp.%USERDNSDOMAIN%
# _kerberos SRV records (site example)
nslookup -type=SRV _kerberos._tcp.Default-First-Site-Name._sites.%USERDNSDOMAIN%
# List DCs
Get-ADDomainController -Filter * | Select HostName,Site
```

### Kerberos Ticket & Failure Sampling
```powershell
# TGT requests last 15m
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4768; StartTime=(Get-Date).AddMinutes(-15)} | Measure-Object
# Service tickets last 15m
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4769; StartTime=(Get-Date).AddMinutes(-15)} | Measure-Object
# Pre-auth failures sample
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4771; StartTime=(Get-Date).AddMinutes(-30)} -MaxEvents 20 |
  Select TimeCreated,Id,Message | Format-List
```

### Directory Database Integrity (Isolated)
```powershell
ntdsutil "activate instance ntds" integrity quit quit
# (Authoritative restore placeholder – adapt cautiously)
ntdsutil "authoritative restore" quit quit
```

### Baseline Snapshot Scriptlet
```powershell
$ts = (Get-Date -Format 'yyyyMMdd-HHmmss')
repadmin /replsummary > repl-$ts.txt
repadmin /showrepl > showrepl-$ts.txt
Get-WinEvent -FilterHashtable @{LogName='Directory Service'; StartTime=(Get-Date).AddHours(-1)} -MaxEvents 200 > ds-events-$ts.txt
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-1)} -MaxEvents 200 > system-events-$ts.txt
w32tm /query /status > time-$ts.txt
```

## When to Consider Restore
- After exhausting remediation and confirming unrecoverable data loss or corruption.
- When critical objects or domains cannot be rebuilt or re-synchronized by other means.
- If replication cannot be re-established and integrity risk is escalating.
- When directory database corruption is validated and isolated rebuild is safer than attempting live repair.

## Footer
---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
