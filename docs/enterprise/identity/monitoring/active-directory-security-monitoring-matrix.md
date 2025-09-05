---
Last Reviewed: 2025-09-04
Tags: monitoring, detection, security-operations, kpi, active-directory
---
# Active Directory Security Monitoring Matrix

Centralized view of high-value signals, event IDs, telemetry sources, baseline expectations, and response guidance for AD environments (with hybrid context where relevant).

> Intent: Provide engineers & responders with a single reference to validate coverage, tune detections, and track KPIs. Pair this with SIEM / MDI (Defender for Identity) workbooks.

## How to Use
1. Confirm each category is onboarded to logging platform (Sentinel / Splunk / QRadar, etc.).
2. Establish a 30-day baseline (volume, unique principals, variance).
3. Create alert tiers (Critical = immediate response, High = same day, Medium = trend review, Informational = baseline drift watch).
4. Review KPIs weekly; remediate gaps (missing events, excessive noise).

## Legend
| Column | Meaning |
|--------|---------|
| Event / Signal | Windows Event ID, MDI alert, or derived analytic |
| Source | DC, Member, MDI, AAD Sign-In, GPO, PKI, Firewall |
| Why It Matters | Risk addressed / attack stage |
| Baseline | Expected pattern / threshold concept |
| Alert Criteria (Example) | Suggested starting logic (tune locally) |
| Response Action | First investigative / containment step |

## 1. Privileged Access Changes
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria (Example) | Response Action |
|----------------|--------|----------------|----------|--------------------------|-----------------|
| 4728 / 4729 (Add/Remove to global security group) | DC | Privilege escalation vector | Low, predictable | Add to Domain Admins / Enterprise Admins | Verify initiator; confirm change ticket; revert if unauthorized |
| 4732 / 4733 (Local group changes) | Server / DC | Lateral movement prep | Low | Addition of non-admin account to local Administrators | Pull host timeline; confirm process ancestry |
| 4670 (Permissions on object modified) | DC | ACL backdoor attempt | Rare | Critical object DACL change (AdminSDHolder, DC computer object) | Export old/new ACL; revert unauthorized entries |
| MDI: Unusual group membership change | MDI | Behavioral privilege anomaly | Controlled | High-risk group surge | Correlate with 4728 initiator; escalate |

## 2. Authentication & Credential Abuse
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| 4768 (TGT request) | DC | Kerberos brute force / anomalous preauth failures | High, diurnal | Sustained spike materially above normal baseline; concentrated failures from a single source | Check source host; isolate if malicious |
| 4769 (Service ticket) | DC | Kerberoasting enumeration | High | Single account requesting an unusually high volume vs typical distribution | Force service account password reset (strong length) |
| 4625 (Failed logon) | DC / Member | Password spray / brute force | Moderate | Many distinct accounts each failing once in a narrow window | Lock source IP; review AAD sign-in logs (if hybrid) |
| 4648 (Logon with explicit creds) | DC / Member | Credential theft / pass-the-hash | Low | From a workstation not designated for privileged administration | Memory capture & triage; rotate privileged creds |
| MDI: Suspected Golden Ticket | MDI | Domain persistence | None | Any occurrence | Full incident response; KRBTGT double reset plan |

## 3. Directory Replication & DC Integrity
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| 4662 (Replicating directory service objects) | DC | DCSync attempt by non-privileged principal | Low | 4662 with replication GUID filtering to non-privileged user | Confirm initiating account; disable & investigate |
| 4742 (Computer account change) | DC | DC object tampering | Low | DC account attribute change outside maintenance | Review change; compare AD timeline |
| Repadmin /showrepl errors | Scheduled Task | Replication health degradation | Zero critical errors | Repeated consecutive failures outside maintenance window | Diagnose site link / network / USN rollback |
| MDI: Suspicious replication | MDI | Credential harvesting | None | Any | Contain account; audit privileged groups |

## 4. Group Policy & Configuration Drift
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| 5136 (Directory object modified - GPO) | DC | Unauthorized GPO change | Low/moderate | Change to security baseline GPO outside an approved window | Compare backup; revert unauthorized settings |
| 4739 (Domain Policy changed) | DC | Domain-wide security impact | Rare | Any | Validate initiator; capture diff; escalate |
| GPO Count per target | Derived | Performance & complexity | Defined threshold | > 15 GPOs applying repeatedly | Consolidate / refactor |

## 5. PKI / Certificate Abuse (AD CS)
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| 4886 / 4887 (Certificate request) | Issuing CA | Abuse of enrollment templates | Moderate | Unusual surge or privileged template usage | Inspect template ACL; reissue with corrections |
| 4899 (Template added/modified) | Issuing CA | Privilege escalation path (ESC) | Rare | Any change to SmartcardLogon / enrollment agent | Freeze enrollment; review ACL & publisher |
| MDI: Suspicious certificate usage (if integrated) | MDI | Credential impersonation | None | Any | Investigate cert lineage; revoke & CRL update |

## 6. LDAP & Enumeration
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| 2889 (Unsigned/simple bind) | DC | Clear-text / insecure auth | Decreasing trend | Persisting count > 0 after enforcement date | Identify client; upgrade or block |
| 1644 (Expensive query) | DC (with diagnostics) | Recon / performance issue | Low | Repeated high-cost queries from single host | Engage app owner; optimize or block |

## 7. Lateral Movement & Privilege Path
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| 7045 (New service installed) | System | Service-based persistence | Low | Unsigned binary / unusual path | Acquire memory & disk image; remove persistence |
| 4697 (Service installation) | Security | Same as above (alternate) | Low | Non-admin host installing service | Trace parent process |
| MDI: Suspected lateral movement (Pass-the-Hash / Overpass-the-Hash) | MDI | Credential reuse | None | Any | Isolate host; revoke tokens |

## 8. Backup & Recovery Integrity
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| Backup job status (success/failure) | Backup System | Recovery readiness | High success | Two consecutive failures for DC job | Triage backup infra; manual backup fallback |
| Unauthorized system state copy | DC | Potential exfiltration | None | System state backup initiated outside schedule | Validate operator; suspend credentials |

## KPIs Dashboard Summary
| KPI | Target | Review Cadence |
|-----|--------|----------------|
| % Privileged Accounts with MFA | All privileged accounts | Weekly |
| Domain Admin Count | Minimal & justified | Weekly |
| Kerberos RC4 Ticket Count | Eliminate legacy crypto | Weekly |
| Unsigned LDAP Binds | None (post enforcement) | Weekly |
| GPO Drift (baseline vs current) | No unauthorized deltas | Monthly |
| PKI Template Changes Reviewed | All changes reviewed | Quarterly |
| Backup Success Rate (DC System State) | > 98% | Weekly |
| Mean Time to Detect Priv Esc | < 15 min | Monthly trend |

## Data Collection Checklist
| Log Source | Status (Y/N) | Notes |
|------------|--------------|-------|
| DC Security Log (Full fidelity) |  |  |
| DC Directory Service Log |  |  |
| Issuing CA Security & CA Logs |  |  |
| MDI Sensors Deployed on all DCs |  |  |
| GPO Change Audit (5136/4739) |  |  |
| LDAP Diagnostic Logging (1644) |  |  |
| PKI Template Change Events |  |  |
| Backup System API / Job Logs |  |  |

## Implementation Phasing
1. Coverage Validation – inventory sources, fix gaps
2. Baseline & Noise Reduction – suppress noisy but benign patterns
3. KPI Tracking – publish dashboard (Sentinel Workbook / PowerBI)
4. Automation – ticket or SOAR playbooks for Critical/High alerts

## Governance
- Weekly operations meeting: review new alerts & false positives
- Monthly control review: adjust thresholds
- Quarterly purple team: validate detection (kerberoasting, DCSync, GPO tamper)

---
Return to [Identity Index](../_index.md) | [Hardening Baselines](../hardening/ad-hardening-baselines.md) | [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
