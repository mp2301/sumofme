---
Last Reviewed: 2025-09-04
Tags: runbook, ldap, signing, channel-binding, hardening
---
# Runbook: Enforcing LDAP Signing & Channel Binding

This runbook governs phased enforcement of LDAP signing and channel binding to eliminate downgrade and relay risks.

## Objectives
- Inventory and remediate insecure LDAP clients
- Enforce signing (integrity) and channel binding without service disruption
- Provide measurable progress & rollback path

## Phases
| Phase | State | Duration | Exit Criteria |
|-------|-------|----------|---------------|
| 0 | Baseline Audit | Baseline period | 2889 volume profiled; offenders classified |
| 1 | Targeted Remediation | Iterative | Majority of offenders remediated & risk accepted |
| 2 | Pre-Enforcement Validation | Short validation | No critical business apps dependent on unsigned binds |
| 3 | Enforcement (Signing) | Change window | Policy applied; stable observation without high-severity incidents |
| 4 | Channel Binding Tightening | Post enforcement | No residual unsigned binds |

## Key Events
| Event ID | Meaning | Action |
|----------|---------|--------|
| 2886 | DC not requiring signing | Track until enforcement |
| 2887 | Daily summary unsigned binds | Baseline & trend |
| 2888 | Rejected unsigned binds post-enforcement | Investigate offender |
| 2889 | Per-client unsigned bind detail | Inventory mapping |

## Data Collection
```powershell
# Enable diagnostic logging (temporary)
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics' -Name '16 LDAP Interface Events' -Value 2 -PropertyType DWORD -Force

# Collect 2889 events (example)
Get-WinEvent -FilterHashtable @{LogName='Directory Service';ID=2889; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated,@{n='Client';e={($_.Message -split "\n" | Where-Object {$_ -match 'Client IP address'}) -replace '.*Client IP address:','' }},Message |
  Export-Csv ldap-unsigned-clients.csv -NoTypeInformation
```

## Classification Matrix
| Category | Description | Action |
|----------|-------------|--------|
| Legacy Device | Unsupported / appliance | Isolate via LDAPS proxy or retire |
| App Server | .NET / Java using LDAP | Patch + enforce LDAPS / signing |
| Script / Tool | Admin script | Modify to use Secure LDAP / sign |
| Misconfig | GPO / registry not applied | Correct configuration |

## Enforcement Steps
1. Confirm zero Sev1 dependencies on unsigned binds (stakeholder sign-off)
2. Apply GPO: Domain Controller: LDAP server signing requirements = Require signing
3. Apply GPO: Network security: LDAP client signing requirements = Require signing
4. Force replication; validate via 2888 absence (should be none if clean)
5. Maintain enhanced diagnostics for 72h then revert logging level to default (0)

## Channel Binding
If TLS is in use (LDAPS), enforce channel binding post-signing success (ADV190023 guidance). Validate application libraries support Extended Protection.

## Monitoring Post-Enforcement
| Signal | Goal | Tool |
|--------|------|------|
| Event 2888 Count | 0 | SIEM query / daily report |
| Event 2889 Count | 0 | (Should cease after logging reverted) |
| App Incident Tickets | 0 Sev1 | ITSM dashboard |

## Rollback
Set DC policy to "None" (signing not required) ONLY if critical outage. Document offender; re-enter Phase 1 remediation.

## Metrics
- Days to reach enforcement
- # unique client IPs pre vs post (2889)
- MTTR for non-compliant client remediation

## Escalation & RACI
| Role | Responsible | Accountable | Consulted | Informed |
|------|-------------|------------|-----------|----------|
| Directory Ops | Apply policies | CISO | Security Engineering | App Owners |
| Security Engineering | Detection tuning | CISO | Directory Ops | SOC |
| App Owners | Remediate clients | App Director | Directory Ops | Governance |

Escalate if unsigned bind rejections persist beyond initial observation window or any high-severity application outage occurs.

## Pitfalls
| Issue | Cause | Mitigation |
|-------|-------|-----------|
| Hidden LDAP usage | Embedded library | Extended test window, deep packet inspection |
| Appliance no update path | Vendor EOL | Segmentation + LDAPS proxy or replace |
| Missed remote site DC | Stale GPO replication | Pre-change replication validation |

## References
- Microsoft: [LDAP channel binding & signing requirements for Windows (KB4520412)](https://support.microsoft.com/topic/2020-2023-and-2024-ldap-channel-binding-and-ldap-signing-requirements-for-windows-kb4520412-ef185fb8-00f7-167d-744c-f299a66fc00a)
- Microsoft Advisory: [ADV190023 LDAP Channel Binding & Signing Guidance](https://portal.msrc.microsoft.com/security-guidance/advisory/ADV190023)
- Microsoft: [How to enable LDAP signing in Windows Server](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/enable-ldap-signing-in-windows-server)
- Internal: [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)
 - Internal: [AD Security Monitoring Matrix](../monitoring/active-directory-security-monitoring-matrix.md)

---
Return to [Identity Index](../_index.md) | Related: [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
