---
Last Reviewed: 2025-09-04
Tags: runbook, recovery, forest-recovery, disaster-recovery, security
---
# Runbook: Active Directory Forest Recovery (High-Level)

This runbook provides a structured approach for catastrophic forest compromise or destruction (ransomware, malicious privilege escalation, mass DC corruption).

## Triggers
- Confirmed domain controller credential theft + persistence techniques (Golden Ticket / DCShadow)
- Widespread DC ransomware / encryption
- Irrecoverable replication divergence / USN rollback / schema corruption

## Assumptions
- Verified compromise scope warrants isolation & rebuild
- Clean-room environment available
- System state backups < 24h available for at least one DC per domain (if partial restore chosen)

## Strategy Paths
| Path | Use Case | Pros | Cons |
|------|---------|------|------|
| Full Forest Rebuild | Total trust loss | Clean baseline | Long outage window |
| Tiered Phased Recovery | Partial corruption | Faster core auth restoration | Risk of latent persistence |
| Isolated Restore + Selective Object Rehydration | Need subset (users/groups) | Faster priority workload enablement | Complex validation |

## Roles & RACI
| Activity | Security | AD Ops | Network | IAM Governance | Comms |
|----------|---------|--------|--------|---------------|-------|
| Decision to Trigger | A | C | C | C | I |
| Clean Room Provision | C | R | R | I | I |
| Backup Integrity Validation | C | R | I | I | I |
| Credential Hygiene (T0) | R | C | I | C | I |
| Build Tier 0 Assets | C | R | I | C | I |
| Stakeholder Updates | I | I | I | C | R |

(A=Approve, R=Responsible, C=Consulted, I=Informed)

## Phase 0: Contain & Stabilize
1. Disable inbound trusts & external federation tokens
2. Revoke privileged credentials (expire/reset Tier 0 accounts)
3. Quarantine compromised DCs (network ACLs)
4. Preserve forensic images before powering down (where feasible)

## Phase 1: Clean Room Preparation
- Provision isolated network segment (no outbound except update sources)
- Harden baseline images (latest patches, baseline CIS) for new DCs
- Prepare offline copies of required installers / scripts

## Phase 2: Core Directory Restoration / Rebuild
| Step | Action | Notes |
|------|--------|-------|
| 1 | Restore / build first forest root DC | Authoritative baseline |
| 2 | Restore / build additional DC for redundancy | Validate SYSVOL replication |
| 3 | Recreate core OUs & baseline GPOs (tiering, audit, security) | Use version-controlled templates |
| 4 | Reinstate DNS zones (validate SOA, NS records) | Integrity check vs known-good export |
| 5 | Configure secure time source | Prevent Kerberos skew |

## Phase 3: Security Re-Hardening
- Enforce LDAP signing / channel binding
- Deploy tiered admin model (no legacy reuse of compromised accounts)
- Reissue new KRBTGT secrets (two rotations)
- Rebuild PKI or validate AD CS integrity; reissue high-risk cert templates

## Phase 4: Object Rehydration
| Object Type | Source | Validation |
|-------------|--------|-----------|
| Users | Export (LDIF / CSV) | Sample password reset + MFA enforcement |
| Groups | Pre-compromise export (restricted sets first) | Cross-check critical memberships |
| Service Principals | Application registry | Re-issue secrets / gMSA | 
| GPOs | Source control repository | Security diff vs baseline |

## Phase 5: Trust & Integration Restoration
- Recreate federation / conditional access after security review
- Re-establish cross-forest trusts (validate SID filtering)
- Reconnect Entra Connect (fresh staging server, new service account)

## Monitoring & Validation
| Control | Check | Tool |
|---------|-------|------|
| Replication Health | Converged, no lingering objects | `repadmin /replsummary` |
| Kerberos Integrity | New ticket issuance only | Event 4768/4769 pattern |
| Privilege Baseline | Domain Admins near zero | AD query / script |
| GPO Integrity | Hash matches repository | Scripted checksum |

## Communication Cadence
| Audience | Channel | Frequency |
|----------|---------|-----------|
| Executives | Situation Report | 2x daily |
| App Owners | Targeted Updates | Phase transitions |
| Security Operations | War Room | Continuous |

## Metrics
- Time to first DC online (tracked vs internal RTO)
- Time to restore minimum authentication (tracked vs internal RTO)
- % high-risk privileged groups rebuilt & validated (tracked milestone)
- Mean time to revoke compromised creds (tracked response metric)

## Evidence Collection
- Timeline log (UTC) in shared secure workspace
- Hashes of restored system state images
- Commands executed (transcript) archived

## Pitfalls & Avoidance
| Pitfall | Impact | Prevention |
|---------|--------|-----------|
| Restoring compromised artifacts | Reintroduces attacker | Strict artifact validation gates |
| Skipping KRBTGT rotations | Persistence remains | Mandatory checklist gating Phase 3 exit |
| Reusing old service account passwords | Credential replay risk | Force reset all secrets |

## Exit Criteria (Recovery Complete)
- Authentication stable (no mass 4771 / 4769 anomalies)
- Security baselines enforced (LDAP signing, tiering, auditing)
- Core integrations restored with validated least privilege
- Executive sign-off & post-mortem scheduled

## Escalation & RACI (Supplemental)
| Role | Responsible | Accountable | Consulted | Informed |
|------|-------------|------------|-----------|----------|
| Directory Ops | Technical recovery | CIO | Security Engineering | Exec Leadership |
| Security Engineering | Threat eradication validation | CISO | Directory Ops | SOC |
| Infrastructure | Platform rebuild | Infra Director | Directory Ops | Change Advisory |
| Communications | Stakeholder comms | CIO | Directory Ops | All Staff |

Escalate if recovery timelines materially exceed internal RTO objectives or persistence indicators reappear.

## References
- Microsoft: [AD Forest Recovery Guide](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/ad-forest-recovery-guide)
- Microsoft: [Best practices for securing Active Directory (Windows Server security)](https://learn.microsoft.com/windows-server/security)
 - Internal: [Hardening Baselines](../hardening/ad-hardening-baselines.md)
- Internal: [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)
 - Internal: [AD Security Monitoring Matrix](../monitoring/active-directory-security-monitoring-matrix.md)

---
Return to [Identity Index](../_index.md) | Related: [Hardening Baselines](../hardening/ad-hardening-baselines.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
