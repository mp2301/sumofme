---
Last Reviewed: 2025-09-04
Tags: monitoring, detection, security-operations, entra-id, azure-ad
---
# Entra ID Security Monitoring Matrix

Centralized view of high-value Microsoft Entra ID (Azure AD) identity and access signals: sign-in events, conditional access, high-risk users, app consent, privileged role changes, and directory modifications.

> Intent: Provide a structured baseline for cloud identity detection coverage. Pair with Microsoft Sentinel workbook(s), Identity Protection, Defender for Cloud Apps (MCAS), and PIM audit logs.

## How to Use
1. Confirm diagnostic settings export required categories to Log Analytics / SIEM (Audit, SignIn, NonInteractive, Provisioning, RiskyUsers, RiskyServicePrincipals, EnrichedAuth, DirectoryProvisioning, ApplicationProxy, etc.).
2. Establish a baseline (30 days) for key dimensions: failed vs successful, device compliance, conditional access evaluation outcomes, risky user volume.
3. Tune noisy app / location scenarios (service principals, known automation) before escalating alert severities.
4. Monitor weekly KPIs; adjust Conditional Access (CA) and PIM policies if gaps emerge.

## Legend
| Column | Meaning |
|--------|---------|
| Event / Signal | Source log / API / product |
| Why It Matters | Risk / attack technique mitigated |
| Baseline | Expected qualitative pattern |
| Alert Criteria (Example) | Starting heuristic (refine locally) |
| Response Action | First steps for containment / investigation |

## 1. Privileged Role & Directory Changes
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria (Example) | Response Action |
|----------------|--------|----------------|----------|--------------------------|-----------------|
| Admin role assignment (PIM activated) | PIM Audit | Elevation of privilege | Predictable around change windows | Activation outside normal hours or unusual user | Verify justification; review sign-in context |
| Permanent privileged role added | Audit | Standing privilege risk | Rare | Any creation / update of permanent GA / Privileged Role Admin | Ticket validation; enforce just-in-time model |
| Conditional Access policy modified | Audit | Policy weakening attempt | Infrequent, approved | CA policy change removing MFA / device filter | Capture diff; revert; investigate actor |
| Directory setting changed (company info / security defaults) | Audit | Potential baseline weakening | Rare | Change to security defaults or MFA registration policy | Review actor; confirm approval |

## 2. Authentication & Access Anomalies
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| Sign-in failures (interactive) | SignInLogs | Password spray / brute force | Diurnal; distributed | Many accounts each failing once from single IP / ASN | Block IP / tag in Sentinel; require MFA challenge review |
| Legacy auth protocol usage | SignInLogs (ClientApp) | Bypass of modern auth controls | Declining | Legacy POP/IMAP/EAS usage where blocked | Confirm CA enforcement; disable offending protocol |
| MFA prompt fatigue pattern | SignInLogs + Risk | MFA bombing attempt | Low | Multiple denied MFA for same user within short window | Temporarily block; user callback verification |
| Token anomalies (improbable travel) | SignInLogs (ConditionalAccess status) | Potential session hijack | Low | High-risk sign-in flagged by Identity Protection | Force sign-out; reset password; review risk detections |
| Non-interactive sign-in spike (service principal) | ServicePrincipalSignInLogs | Secret / certificate abuse | Stable | Service principal sign-ins from new IP range/cloud region | Rotate secret/cert; review app owner |

## 3. Risk & Identity Protection Signals
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| High-risk user detected | RiskyUsers | Active compromise indicator | None | Any high-risk user state | Enforce password reset; review recent activity |
| High-risk sign-in | RiskySignIns | Account takeover attempt | Low | Clustered high-risk sign-ins for one user | Confirm MFA registration & device compliance |
| High-risk service principal | RiskyServicePrincipals | App credential theft | None | Any | Disable app; rotate creds; owner escalation |

## 4. Application & Consent Governance
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| Admin consent granted to multi-tenant app | Audit | Privilege/data exposure | Infrequent | New broad Graph permissions (Directory.ReadWrite.All) | Validate business need; restrict scope |
| OAuth app added with high privileges | Audit | Potential backdoor | Low | App with cert creds + privileged Graph scope | Owner validation; restrict secrets; conditional access for app |
| App proxy connector disabled | ApplicationProxy | External access disruption | Stable | Connector offline unexpectedly | Investigate connector host; failover/test |

## 5. Conditional Access & Policy Enforcement
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| CA policy evaluation (failure) | SignInLogs (ConditionalAccessPolicies) | Misconfig causing denial | Low | Surge in denials for a core workforce app | Rollback recent CA change; policy diff |
| Sessions not satisfying device compliance | SignInLogs | Policy bypass attempt | Controlled | Increase above normal variance | Investigate device posture; confirm Intune status |
| MFA not satisfied where required | SignInLogs | Weakening of control | Very low | Unexpected success without strong auth for scoped user/app | Validate CA targeting; adjust exclusions |

## 6. Hybrid & Synchronization
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| Entra Connect sync failure | Provisioning / AAD Connect Health | Identity drift risk | Healthy | Consecutive full sync failures | Review connector logs; credential health |
| Staged / filtered OU changes | Audit (Directory) | Unintended exposure / removal | Rare | Large delta in scoped objects | Confirm change request; rollback if needed |

## 7. API & Automation Abuse
| Event / Signal | Source | Why It Matters | Baseline | Alert Criteria | Response Action |
|----------------|--------|----------------|----------|----------------|-----------------|
| Excessive Graph API calls by app | Audit / SignInLogs | Enumeration / data exfil | Stable | 2x usual volume within short window | Throttle; contact owner; rotate secret |
| App secret near expiry not rotated | Audit | Service disruption risk | Known set | Secret expires within threshold & no rotation scheduled | Notify owner; trigger rotation workflow |

## KPIs Dashboard Summary
| KPI | Target | Review Cadence |
|-----|--------|----------------|
| % Privileged Roles Just-in-Time | All high-impact roles | Monthly |
| Admin Role Activations w/ MFA | 100% | Weekly |
| High-Risk Users Remediated | 100% within SLA | Daily |
| Legacy Auth Usage | Trending to zero | Weekly |
| App Consents Reviewed | All high-priv apps | Quarterly |
| Conditional Access Coverage | All users / apps risk-scoped | Quarterly |

## Data Collection Checklist
| Log / Feed | Status (Y/N) | Notes |
|------------|--------------|-------|
| SignInLogs & NonInteractive |  |  |
| AuditLogs |  |  |
| RiskyUsers / RiskySignIns |  |  |
| ServicePrincipalSignInLogs |  |  |
| Provisioning (AAD Connect) |  |  |
| Conditional Access Policy Insights |  |  |
| PIM Activation Logs |  |  |
| Defender for Cloud Apps (MCAS) |  |  |

## Implementation Phasing
1. Enable diagnostic export & retention.
2. Baseline risk & usage patterns (MFA, device, legacy auth).
3. Deploy detections (KQL analytics) & workbook dashboards.
4. Automate high-confidence response (SOAR for risky users / service principals).

## Governance
- Weekly review: risky users, high-risk sign-ins, PIM activations anomalies.
- Monthly: app consent audit; CA policy drift review.
- Quarterly: purple team (token theft, OAuth consent abuse simulation).

---
Return to [Identity Index](../_index.md) | [Privileged Access Model](../governance/admin-tiering-model.md) | [PIM & RBAC](../governance/entra-pim-rbac.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
