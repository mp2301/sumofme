---
Last Reviewed: 2025-09-03
Tags: hardening, security, baselines, active-directory
---

# Active Directory Hardening and Security Baselines

Securing Active Directory (AD) is foundational to enterprise security. A compromised AD often leads to full environment compromise. This page summarizes practical hardening actions and references.

## Objectives
- Reduce attack surface
- Enforce least privilege & tiered administration
- Detect and respond to abnormal activity
- Ensure recoverability after compromise

## Core Baseline Areas
1. Identity & Authentication
2. Admin Tiering & Delegation
3. Host & Service Hardening
4. Credential Protection
5. Monitoring & Detection
6. Backup & Recovery

## 1. Identity & Authentication
- Enforce strong Kerberos policies (short ticket lifetimes where feasible)
- Disable or constrain legacy protocols: NTLM (audit then restrict), unsigned LDAP binds
- Require smart card / phishing-resistant MFA for privileged accounts
- Enforce password protection (Entra Password Protection on-premises if in hybrid)
- Restrict delegation: Prefer Kerberos Constrained Delegation (KCD) over unconstrained

## 2. Admin Tiering & Delegation
- Implement a tiering model (e.g., Tier 0: DCs/AD, Tier 1: Servers, Tier 2: Workstations)
- Use separate admin accounts per tier (no cross-tier logon)
- Limit Domain Admins: keep membership near zero; prefer delegated RBAC & just-in-time elevation
- Control ACLs on critical objects (AdminSDHolder, Domain root, Configuration partition)

## 3. Host & Service Hardening
- Domain Controllers:
  - Remove unnecessary roles (no file/print/web on DCs)
  - Patch cadence: expedited for critical security updates
  - Apply CIS or Microsoft security baseline GPOs
- Secure time synchronization (DC authoritative time source hardened)
- Disable SMBv1; limit legacy cipher suites

## 4. Credential Protection
- Enforce LSASS protection (RunAsPPL) on DCs and admin workstations
- Deploy Credential Guard on administrative endpoints
- Prevent interactive logon to servers/hosts by service accounts
- Use gMSA (Group Managed Service Accounts) for services instead of static passwords
- Audit logon types; eliminate 3 & 10 for privileged accounts where possible

## 5. Monitoring & Detection
| Category | What to Monitor | Why |
|----------|-----------------|-----|
| Privileged Group Changes | Add/remove in Domain Admins, Enterprise Admins | Lateral movement & escalation |
| DC Replication Metadata | Unexpected replication partners | Rogue DC / DCSync detection |
| Kerberos Tickets | Unusual service tickets, Golden Ticket indicators | Persistence & impersonation |
| LDAP Queries | Large attribute harvest patterns | Reconnaissance |
| Logon Events | 4624/4625/4672 anomalies | Brute force / privilege misuse |
| GPO Changes | 4739, 5136 (GPO objects) | Policy tampering |

## 6. Backup & Recovery
- Perform regular system state backups of DCs (offline copies, immutable retention)
- Maintain clean-room recovery process / isolated forest recovery plan
- Periodically test authoritative restore & tombstone reanimation scenarios

## Quick Wins (First 30 Days)
- Inventory & prune privileged group membership
- Turn on LDAP signing/auditing; move to enforcement
- Enable LSASS protection on all DCs
- Audit NTLM usage; start blocking by profile
- Baseline replication health (repadmin /showrepl export + schedule)

## Tooling & References
- Microsoft: [Security baseline settings (Group Policy) (search)](https://learn.microsoft.com/en-us/search/?q=security%20baselines) â€“ map to enforced GPOs
- Microsoft: [Defender for Identity prerequisites & deployment](https://learn.microsoft.com/en-us/defender-for-identity/prerequisites) (sensor & detection scope)
- PingCastle: [Official Site](https://www.pingcastle.com/)
- Semperis Purple Knight: [Product Page](https://www.semperis.com/products/purple-knight/)
- BloodHound: [GitHub Project](https://github.com/BloodHoundAD/BloodHound) (internal use; secure outputs)

## Metrics & KPIs
- Domain Admin count trend
- % privileged accounts with phishing-resistant MFA
- NTLM authentication count (declining objective)
- Time to restore DC from backup (goal < 4 hours)
- Mean time to detect privilege escalation events

## Governance
- Quarterly hardening review: update baseline vs. discovered gaps
- Maintain risk register for accepted deviations (expiration dates required)

---
Return to [Identity Index](../_index.md) | [AD Monitoring Matrix](../monitoring/active-directory-security-monitoring-matrix.md) | [Group Policy Strategy](../architecture/group-policy-strategy.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
