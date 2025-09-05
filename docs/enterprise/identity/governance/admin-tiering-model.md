---
Last Reviewed: 2025-09-03
Tags: tiering, privileged-access, security, hardening
---
# Administrative Tiering Model

A tiered administration model reduces lateral movement risk by isolating credentials and limiting blast radius of compromise. This model aligns privileged actions with controlled workstations, networks, and identity boundaries.

## Tier Definitions
| Tier | Scope | Examples | Workstation Requirements |
|------|-------|----------|--------------------------|
| 0 | Identity & Security Control Plane | Domain Controllers, PKI, ADFS, Entra roles, Privilege mgmt systems | Hardened PAW (Privileged Access Workstation), no email/web |
| 1 | Enterprise Servers & Core Infrastructure | File/Print, SQL, Line-of-Business App Servers | Managed admin workstation (segmented VLAN) |
| 2 | User Workstations & Productivity | End-user devices, VDI | Standard managed workstation |
| 3 (Optional) | External / Edge / DMZ | Reverse proxies, perimeter systems | Isolated mgmt enclave |

## Core Principles
- No credential reuse across tiers
- Administrative actions performed only from authorized tier-aligned workstations
- Network segmentation prevents lower-tier initiated management to higher-tier assets
- PIM / JIT elevation â†’ short-lived role tokens rather than standing membership

## Credential Controls
| Control | Purpose |
|---------|---------|
| PAM Vault (e.g., CyberArk) | Rotate & broker privileged credentials |
| PIM (Azure / Entra) | Time-bound role assignment & approval workflows |
| gMSA for Services | Avoid static service account secrets |
| Passwordless for Tier 0 | Reduce phishing / replay |

## Workstation Strategy
| Aspect | Tier 0 PAW | Tier 1 Admin WS | Rationale |
|--------|------------|-----------------|-----------|
| Internet Access | Blocked | Restricted (proxy) | Reduce exploit / phishing |
| E-Mail Client | None | Optional | Eliminate payload delivery |
| Productivity Apps | None | Minimal | Focused admin scope |
| Local Admin Rights | Strictly limited | Controlled | Reduce persistence |

## Network Segmentation
- Tier 0 systems only accessible from Tier 0 management VLAN / jump host
- Block lateral RDP/WinRM from Tier 2 â†’ Tier 0/1
- Use firewall policy + conditional access device filters for cloud console access

## Enforcement Mechanisms
| Layer | Control |
|-------|---------|
| Identity | PIM, passwordless, conditional access |
| Endpoint | Application control, EDR, credential guard |
| Network | Segmented VLANs, ACLs, firewall policies |
| Process | Access reviews, change control, incident drills |

## Monitoring Focus
- Detect cross-tier logon attempts (event correlation)
- Alert on privileged role activation from non-compliant workstation
- Track growth in permanent privileged memberships

## Metrics
| KPI | Target |
|-----|--------|
| Permanent Domain Admin Members | <= 2 |
| Tier 0 Access from Non-PAW | 0 |
| JIT Elevation Approval SLA | < 15 min |
| % Tier 0 Accounts with Passwordless | 100% |

## Implementation Phases
1. Inventory privileged accounts & map to tiers
2. Deploy PAWs & enforce conditional policies
3. Migrate admin workflows to JIT elevation
4. Reduce legacy service accounts â†’ gMSA
5. Continuous monitoring & attestation cycles

## Common Pitfalls
| Pitfall | Mitigation |
|---------|-----------|
| Shadow Admin Accounts | Periodic BloodHound & AD ACL review |
| Admin Uses Non-PAW for Quick Fix | Enforce conditional access + logging consequences |
| Over-broad Tier 0 Scope | Strict scoping review quarterly |
| Drift in JIT Approval Discipline | Automate approval metrics dashboard |

---
Return to [Identity Index](../_index.md) | [Hardening Baselines](../hardening/ad-hardening-baselines.md) | [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
