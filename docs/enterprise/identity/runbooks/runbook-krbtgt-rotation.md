---
Last Reviewed: 2025-09-04
Tags: runbook, kerberos, krbtgt, recovery, security
---
# Runbook: KRBTGT Account Password Rotation

Rotating the two KRBTGT account passwords (forest root & child domains) is a critical control to invalidate forged Golden Tickets after suspected privilege compromise.

## When to Execute
- Post-incident (any indication of DC compromise, DCSync, Golden Ticket, DC hash extraction)
- Scheduled hygiene (every 12 months if no incident)
- Before/after forest recovery exercises (test environment)

## Preconditions / Validation Checklist
| Item | Requirement | Verified |
|------|-------------|----------|
| Enterprise Admin / Domain Admin temporary elevation | Approved & time-bound |  |
| Replication health stable | `repadmin /replsummary` errors = 0 critical |  |
| System State backups | < 24h old for all DCs |  |
| Monitoring quiet period scheduled | Change window agreed |  |
| SIEM baselines captured | Pre-rotation authentication baseline exported |  |

## Risk & Impact
| Risk | Mitigation |
|------|------------|
| Service Accounts caching old TGTs | Low — plan two rotations separated by at least one full ticket lifetime interval |
| Replication delay causing inconsistent auth | Monitor replication convergence after each reset |
| Accidental execution in wrong domain | Explicit confirmation step with `whoami /fqdn` & domain context |

## Rotation Strategy
Two sequential password resets are required. First reset invalidates future minted tickets that use prior key; second ensures any tickets minted using compromised key are fully invalidated.

## High-Level Steps
1. Baseline & Prepare
2. First KRBTGT Reset
3. Validate & Monitor
4. Second KRBTGT Reset (after ticket lifetime interval passes)
5. Post-Rotation Verification & Documentation

## Detailed Procedure
### 1. Baseline & Prepare
```powershell
# Export replication & DC list
repadmin /showrepl * /csv > pre-krbtgt-repl.csv
Get-ADDomainController -Filter * | Select-Object HostName,Site,OperatingSystem > dcs.txt

# Optional: Count tickets (sample via 4769 volume last hour)
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4769; StartTime=(Get-Date).AddHours(-1)} | Measure-Object
```
Confirm no backlog in DFSR/NTFRS (if legacy) and AD replication latency <15m.

### 2. First Reset
```powershell
# Module import
Import-Module ActiveDirectory
# Confirm krbtgt account
Get-ADUser -Identity krbtgt -Properties LastLogonDate,PwdLastSet
# Reset (1)
Set-ADAccountPassword -Identity krbtgt -Reset -NewPassword (Read-Host -AsSecureString 'First New KRBTGT Password')
# Force replication
Get-ADDomainController -Filter * | ForEach-Object {repadmin /syncall $_.HostName /AdeP}
```
Record the new `PwdLastSet` timestamp.

### 3. Validate & Monitor
- Watch Security Event IDs 4768/4769 for abnormal spikes
- Confirm no 4771 (pre-auth failed) surge
- Replication: `repadmin /replsummary` every 15m until convergence
- SIEM: Golden Ticket detections should drop (if previously active)

### 4. Second Reset (After Ticket Lifetime Interval)
Execute second reset only after the environment's maximum Kerberos ticket lifetime has elapsed:
```powershell
Set-ADAccountPassword -Identity krbtgt -Reset -NewPassword (Read-Host -AsSecureString 'Second New KRBTGT Password')
Get-ADUser krbtgt -Properties PwdLastSet
Get-ADDomainController -Filter * | ForEach-Object {repadmin /syncall $_.HostName /AdeP}
```

### 5. Post-Rotation Verification
| Verification | Command / Method | Result |
|--------------|------------------|--------|
| Authentication still succeeds | Logon test (regular user) |  |
| Service Tickets issued with new key | Capture 4769 & inspect encryption type |  |
| No replication errors | `repadmin /replsummary` |  |

## Rollback (Emergency)
KRBTGT cannot be rolled back to the previous password (it is unknown). Rollback means: restore system state of all DCs from before first reset (catastrophic). Avoid by validating preconditions.

## Metrics
- Time to complete both rotations (tracked vs internal objective)
- Ticket failures (4771) relative spike magnitude
- Replication convergence time (observed; investigate prolonged variance)

## Escalation & RACI
| Role | Responsible | Accountable | Consulted | Informed |
|------|-------------|------------|-----------|----------|
| Directory Ops | Execute resets | CISO | Security Engineering | Service Owners |
| Security Engineering | Monitor anomalies | CISO | Directory Ops | SOC |
| Change Mgmt | Approve window | CIO | Directory Ops | Stakeholders |

Escalate if authentication failure rate shows sustained abnormal elevation or replication errors persist beyond normal convergence patterns.

## Logging & Evidence
Store artifacts in secure share:
- `pre-krbtgt-repl.csv`
- Screenshots or exports of `repadmin /replsummary` pre & post
- Event count diffs (4768/4769, 4771) pre/post

## Common Pitfalls
| Issue | Cause | Resolution |
|-------|-------|------------|
| Users forced to re-auth unexpectedly | Cached tickets expired sooner | Within tolerance; communicate early |
| Replication lingering objects warning | Pre-existing replication health issues | Address before rotation |

## References
- Microsoft: [Kerberos authentication overview](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview)
- Microsoft: [Resetting the KRBTGT account password â€“ considerations (search)](https://learn.microsoft.com/search?search=reset%20krbtgt)
 - Internal: [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)
 - Internal: [AD Security Monitoring Matrix](../monitoring/active-directory-security-monitoring-matrix.md)

---
Return to [Identity Index](../_index.md) | Related: [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
