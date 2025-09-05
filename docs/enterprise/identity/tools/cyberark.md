---
Last Reviewed: 2025-09-04
Tags: privileged-access, pam, vault, session-monitoring, credential-rotation, cyberark
---
# CyberArk Privileged Access Management

- [Product Overview](#product-overview)
- [Core Components](#core-components)
- [Licensing](#licensing)
- [Key Capabilities](#key-capabilities)
- [Security & Governance Benefits](#security--governance-benefits)
- [Example Use Cases](#example-use-cases)
- [Deployment Patterns](#deployment-patterns)
- [Operational Runbook Pointers](#operational-runbook-pointers)
- [Integration Touchpoints](#integration-touchpoints)
- [Onboarding Workflow (Example)](#onboarding-workflow-example)
- [KPIs & Metrics](#kpis--metrics)
- [References](#references)

## Product Overview
CyberArk is a leading Privileged Access Management (PAM) platform used to secure, manage, rotate, and monitor credentials and sessions for high-risk accounts (human, service, application, cloud, and infrastructure).

It reduces lateral movement and credential theft impact by vaulting secrets, enforcing least privilege, rotating credentials automatically, and brokering audited sessions.

## Core Components
| Component | Purpose |
|-----------|---------|
| Digital Vault | Secure storage for privileged credentials & secrets |
| PVWA (Portal) | Web interface for users, workflows, and approvals |
| CPM (Credential Provider / Password Manager) | Automated password rotation & policy enforcement |
| PSM (Privileged Session Manager) | Session brokering, isolation, keystroke/video recording |
| PTA (Threat Analytics) | Behavioral analytics & anomaly detection for privileged use |
| EPV / APIs | Programmatic access to retrieve and inject credentials |
| Secrets Manager (Conjur / Application Access Manager) | Non-human / DevOps secret injection |

## Licensing
Licensed per component scope and number of managed privileged accounts / secrets. Common license dimensions:
- Managed accounts (human + service)
- Session monitoring (PSM) add-ons
- Application / DevOps secrets (AAM / Conjur)
- Analytics (PTA) modules
Consult vendor for current packaging.

## Key Capabilities
- Secure vault with tamper-resistant architecture
- Automated credential rotation (Windows, Unix, DB, network devices, cloud)
- Check-out / check-in with dual-control & approvals
- Session brokering & isolation (no direct credential exposure)
- Full session recording (keystroke + video) and searchable metadata
- Just-in-time elevation & ephemeral access models
- API / DevOps secret injection (no hard-coded credentials)
- Threat analytics: anomalous behavior, credential misuse patterns
- Fine-grained RBAC, workflow, and policy enforcement

## Security & Governance Benefits
| Goal | CyberArk Contribution |
|------|-----------------------|
| Eliminate shared admin passwords | Vault + rotation + check-out workflow |
| Reduce credential theft blast radius | Session proxy + no credential delivery to endpoint |
| Meet compliance (SOX, PCI, ISO) | Immutable audit, approval trails, rotation policy evidence |
| Detect privilege abuse | PTA analytics + session forensics |
| Support Zero Trust | Brokered, just-in-time, segmented access |
| Reduce secret sprawl | Central secret management & API delivery |

## Example Use Cases
1. Rotate all AD Tier 0 service accounts every X days with automatic dependency update scripts.
2. Broker RDP / SSH sessions to DCs through PSM with full video capture and keystroke indexing.
3. Inject database credentials into application startup via Conjur without exposing plaintext to developers.
4. Require dual approval for domain admin credential checkout with automatic time-bound lease.
5. Detect anomalous elevation pattern (outside maintenance window) and trigger SIEM alert.

## Deployment Patterns
| Pattern | When to Use | Notes |
|---------|-------------|-------|
| Minimal Core | Pilot / initial rollout | Vault + PVWA + CPM |
| Session Control Expansion | Need audit & isolation | Add PSM components |
| Threat Analytics Enabled | Mature monitoring posture | Integrate PTA with SIEM |
| DevOps Secret Management | CI/CD, containerized apps | Deploy Conjur / AAM plugins |
| Cloud Privileged Access | Multi-cloud admin growth | Use cloud plugin rotation policies |

## Operational Runbook Pointers
| Area | Focus |
|------|-------|
| Rotation Failures | Retries, dependency script logs, sync windows |
| Vault Backups | Secure off-platform copies; test restore path |
| Certificate / TLS Maintenance | PVWA & PSM endpoints renewal schedule |
| Session Recording Storage | Retention policy, archive & purge workflow |
| Policy Drift | Regular export & version control of platform policies |
| Access Reviews | Quarterly privileged account attestation using platform reports |

## Integration Touchpoints
| System | Integration | Purpose |
|--------|------------|---------|
| Active Directory | Directory auth / group-based access | Centralize operator identity |
| SIEM (Sentinel / Splunk) | Log & event forwarding | Correlate privileged activity |
| Ticketing (ServiceNow / Jira) | Workflow gating | Require change/incident context |
| Identity Governance (IGA) | Access certification sync | Attestation alignment |
| DevOps (Jenkins, Kubernetes, GitHub Actions) | Secrets injection | Remove hard-coded creds |
| MFA Provider | Strong auth for vault access | Enforce phishing-resistant factors |

## Onboarding Workflow (Example)
1. Classify account (human / service / application) & criticality.
2. Create safe / folder & assign owning team.
3. Import or enroll credential (auto-discover optional for Windows/Unix).
4. Apply rotation policy (interval, complexity, dual-control if needed).
5. Test rotation (non-production) then enable in production scope.
6. Configure session policy (PSM) & recording if applicable.
7. Tie to change / incident process (ticket reference tagging).
8. Validate SIEM ingestion of session & rotation events.
9. Document in inventory & schedule periodic access review.

## KPIs & Metrics
| Metric | Intent |
|--------|--------|
| % Privileged Accounts Vaulted | Coverage of high-risk accounts |
| Rotation Success Rate | Reliability of automation |
| Mean Time to Rotate After Add | Onboarding efficiency |
| Session Recording Coverage | Audit completeness |
| Secrets Hard-Coded Findings | Reduction of embedded credentials |
| Dual-Control Approval Time | Access friction vs responsiveness |

## References
- Vendor: https://www.cyberark.com/
- Docs / Support Landing: https://docs.cyberark.com/
- Privileged Access Strategy (internal) – align with tiering model
- Integration: Conjur OSS (GitHub) for DevOps secret delivery

CyberArk materially reduces privileged credential risk when paired with strong identity hygiene (MFA, tiering) and monitoring.

---
Return to [Identity Index](../_index.md) | [AD Monitoring Matrix](../monitoring/active-directory-security-monitoring-matrix.md)

---
Include: `../../../_footer.md`
