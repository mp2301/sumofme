---
Last Reviewed: 2025-09-03
Tags: identity, lifecycle, provisioning, governance, processes
---
# Identity Lifecycle Process (Joiner / Mover / Leaver)

A clear identity lifecycle model reduces orphaned access, accelerates onboarding, and enables compliance evidence. This page defines standardized processes for joiners, movers, and leavers across hybrid AD + Entra ID environments.

## Objectives
- Automate entitlement granting & revocation
- Provide auditable trails for regulators (SOX / SOC 2 / HIPAA)
- Minimize time-to-productivity for new hires
- Reduce manual provisioning risk & delays

## Core Stages
| Stage | Trigger | Primary Systems | Outcomes |
|-------|--------|-----------------|----------|
| Pre-Provision | Recruit accepted / HR event | HRIS â†’ Identity Governance | Staging identity, attributes (legal name, dept, manager) |
| Joiner | Start date (T0) | AD, Entra ID, HR, Ticketing | Account enabled, base groups, mailbox, MFA bootstrap |
| Mover | HR org change / role change | AD, Entra ID, IAM | Entitlements realigned (add/remove), manager & cost center updated |
| Leaver (Planned) | Scheduled termination | IAM, AD, Entra ID, HR | Access disabled timed with exit, tokens revoked, mailbox retention applied |
| Leaver (Urgent) | Immediate termination | IAM, AD, Entra ID, SIEM | Immediate disable, sign-in revoked, sessions invalidated |

## Attribute Governance
| Attribute | Source of Truth | Sync Target | Notes |
|-----------|-----------------|------------|-------|
| Display Name | HRIS (formatted) | AD / Entra | Normalize casing |
| Department | HRIS | AD / Entra | Drives dynamic groups |
| Manager | HRIS | AD / Entra | Supports access reviews / approvals |
| Cost Center | HRIS | Entra (extension) | Billing & chargeback tagging |
| Employment Type | HRIS | Entra | Conditional access & risk decisions |

## Provisioning Model
1. Authoritative HR feed (daily or near-real-time) to identity governance engine.
2. Identity governance triggers creation of AD account (disabled until start date).
3. On start date: enable account, assign baseline groups (prod vs non-prod separation), introduce to MFA registration.
4. Application access granted via:
   - Dynamic groups (department / role attributes) for broad entitlements
   - Request-based PIM groups for elevated or niche access
   - SCIM provisioning to SaaS (license assignment rules)

## Movers Handling
- Detect attribute changes (dept, manager, role) â†’ recalc dynamic group membership
- Remove legacy access before applying new high-privilege roles (sequence matters)
- Trigger re-attestation for sensitive entitlements after role elevation

## Leavers Handling
| Step | Timing | Action |
|------|--------|--------|
| Disable interactive sign-in | T0 | Disable AD + Entra account; revoke refresh tokens |
| Revoke privileged roles | Pre-T0 (if known) | Expire PIM eligibilities & active assignments |
| Archive mailbox / OneDrive | T0 + 0h | Move to retention / litigation hold as needed |
| Remove from groups | T0 + 1h | Batch job clears security / distribution groups |
| Wipe devices (if corporate) | T0 + 1â€“4h | MDM remote wipe / retire |
| Delete account (logical) | Post retention (30â€“90d) | Hard delete per retention policy |

## Controls & Metrics
| Control | Metric | Target |
|---------|--------|--------|
| Timely Joiner Enablement | % accounts enabled before 9AM local day 1 | > 98% |
| Orphaned Access | Accounts with last sign-in > 90d & not disabled | = 0 |
| Leaver Disable SLA | % within 15 min of HR termination | > 99% |
| Role Change Cleanup | Access removed prior to new role entitlement add | 100% |
| Entitlement Recertification | Quarterly completion rate | > 95% |

## Automation Patterns
- Event-driven (webhook from HRIS) vs batch CSV ingestion
- Use Entra ID dynamic groups with attribute normalization (avoid multi-value collisions)
- SCIM integration for major SaaS (GitHub, ServiceNow, Salesforce, Slack)
- PIM APIs for scheduled removal of stale eligible roles

## Risk Scenarios & Mitigations
| Risk | Example | Mitigation |
|------|---------|-----------|
| Orphan Account | Contractor leaves; account active 60 days | Automated disable after inactivity + HR feed reconciliation |
| Privilege Creep | Role changes accumulate groups | Periodic differential entitlements check (old vs new) |
| Delayed Disable | HR feed latency | Near-real-time webhook; urgent manual disable runbook |
| Mis-sourced Attribute | Wrong manager leads to over-provisioning | Attribute integrity validation job |

## Runbooks
- Urgent Termination Runbook: Immediately disable AD/Entra, revoke sessions, expire PIM roles
- Attribute Correction Runbook: Sync mismatch reconciliation script (HRIS vs AD)

## Integration with Monitoring
- Feed lifecycle events to SIEM for correlation (e.g., leaver performing data exfil activity pre-disable)
- Alert on provisioning anomalies (account created outside process path)

## Roadmap Enhancements
- Adaptive access based on risk (Entra ID risk signals + conditional policies)
- Attribute signing / integrity attestation
- Auto-expiry tags for temporary entitlements

---
Return to [Identity Index](../_index.md) | [Privileged Accounts](privileged-accounts-and-groups.md) | [PIM](entra-pim-rbac.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
