---
Last Reviewed: 2025-09-03
Tags: group-policy, configuration-management, delegation, baselines
---
# Group Policy Strategy and Design

A deliberate Group Policy strategy prevents configuration drift, reduces login delays, and enforces security baselines consistently.

## Goals
- Predictable, testable configuration delivery
- Minimal processing overhead
- Clear ownership & change control
- Separation of security baselines from application settings

## Layering Model
1. **Foundational Baselines** (Computer Security, User Security)
2. **Role / Function Policies** (e.g., Domain Controllers, Member Servers, Workstations)
3. **Application / Feature Policies** (e.g., Browser hardening, RDP settings)
4. **Exception / Override Policies** (tightly scoped, temporary)

Use WMI filters sparingly (prefer security groups). Avoid deep OU nesting - keep OU depth shallow (under 5 levels) for clarity and performance.

## Naming Conventions
| Type | Prefix | Example |
|------|--------|---------|
| Baseline | BL- | BL-Computer-Security-Baseline |
| Role | RL- | RL-DomainControllers-Core |
| Application | AP- | AP-Edge-Hardening |
| Exception | EX- | EX-Legacy-App-UnsignedLDAP |

Keep GPO names concise but descriptive. Do not encode version numbers; track revisions in documentation or source control.

## Link Order & Precedence
- Baseline GPOs linked at domain root (lowest precedence)
- Role / Function GPOs linked at dedicated OUs
- Application policies layered above role policies
- Exception GPOs closest to target objects (highest precedence)

Document ordering rationale. Avoid linking the same GPO in many OUsâ€”prefer security group scoping.

## Security Filtering & Delegation
- Use Authenticated Users for read + apply unless intentionally excluding
- Pair with security groups for targeted application
- Delegate GPO edit vs. link rights explicitly (Principle of Least Privilege)

## Change Control
- Store GPO backups (versioned) in source control (e.g., `GPO-Backups/`)
- Use a staging OU for testing before production link
- Require peer review for security-impacting changes
- Maintain a change log (date, requester, purpose, approver)

## Performance Optimization
- Minimize number of GPOs applying to a given object (target < 15 at user logon)
- Consolidate related settings where stable
- Avoid large logon scripts; prefer scheduled tasks or modern management (Intune) where feasible

## Modern Management Considerations
- Evaluate migration of some user-centric settings to Intune / MDM for hybrid devices
- Use Cloud LAPS (where supported) instead of legacy scripts
- Conditional Access + device compliance for posture controls instead of complex GPO logic

## Monitoring & Auditing
Track:
- GPO creation / deletion (Event IDs 5136, 5137)
- Permission changes on GPOs
- Increases in average user logon time
- Drift between documented baseline and actual GPO contents

Use periodic exports + diff to detect unauthorized changes.

## Lifecycle
- Quarterly review of exception GPOs (expire or integrate into baselines)
- Annual holistic policy audit (remove obsolete settings)

---
Return to [Identity Index](../_index.md) | [Hardening Baselines](../hardening/ad-hardening-baselines.md) | [Kerberos & LDAP Security](../hardening/kerberos-ldap-security.md)

Include: `../../../_footer.md`
