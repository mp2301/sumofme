---
Last Reviewed: 2025-09-03
Tags: authentication, passwords, mfa, conditional-access, modernization
---
# Password & Authentication Modernization

Modern authentication strategy reduces reliance on static passwords, moves toward phishing-resistant factors, and accelerates conditional, risk-based access decisions.

## Strategic Objectives
- Eliminate legacy authentication (NTLM, basic auth)
- Increase phishing-resistant MFA coverage (FIDO2, certificate-based, smart card)
- Reduce password reset volume & helpdesk load
- Enable risk-adaptive access control (Conditional Access + Identity Protection)

## Maturity Phases
| Phase | Focus | Key Outcomes |
|-------|-------|-------------|
| 1: Hygiene | MFA for admins + baseline risk policies | All privileged roles protected |
| 2: Expansion | MFA for all users + legacy auth reduction | >95% users MFA enabled |
| 3: Hardening | Passwordless pilot (FIDO2 / Windows Hello) | 30% adoption in target cohort |
| 4: Optimization | Full passwordless for high-value apps | 70% passwordless for Tier 0/1 admins |
| 5: Adaptive | Risk-based continuous access | Session re-eval + token protection |

## Legacy Authentication Reduction
| Action | Metric | Target |
|--------|--------|--------|
| Audit NTLM usage (AAD + On-prem) | NTLM auth count | Decrease to < 5% all auth |
| Block Basic Auth (Exchange/SMTP) | Basic auth events | 0 |
| Disable POP/IMAP unless exceptioned | Legacy protocol events | Near 0 |
| Enforce modern auth clients | Non-modern user agents | Each exception documented |

## Phishing-Resistant MFA
Preferred order of factors:
1. FIDO2 security keys
2. Smart card / CBA (certificate-based authentication)
3. Windows Hello for Business (PIN + biometrics)
4. App-based number match (Authenticator)
5. SMS / Voice (only for break glass / fallback)

## Conditional Access Patterns
| Scenario | Policy Example |
|----------|----------------|
| High-Risk Sign-In | Block or require step-up (FIDO2) |
| Medium Risk | Force password change + phishing-resistant MFA |
| Sensitive Apps (Admin Portals) | Require compliant + hybrid joined device + phishing-resistant MFA |
| Legacy Protocol Attempt | Block if primary auth context = legacy |
| Non-Compliant Device | Require device compliance or deny |

## Password Policy Modernization
- Shift from periodic rotation â†’ risk-based (NIST 800-63 guidance)
- Enforce banned password lists (global + custom) via Entra Password Protection
- Monitor password spray indicators (many users, single failure each)
- Encourage passphrases > 14 chars (password length > complexity)

## Helpdesk Impact Reductions
| Initiative | Expected Benefit |
|-----------|------------------|
| Self-service password reset (SSPR) integration | Reduce reset tickets 50â€“70% |
| Passwordless deployment to admins | Remove high-risk password reuse |
| Automated lockout pattern detection | Fewer escalations |

## Monitoring & Metrics
| KPI | Target |
|-----|--------|
| Users with MFA Enabled | > 98% |
| Privileged Roles with Phishing-Resistant Factor | 100% |
| NTLM Authentication Events (weekly) | Declining to minimal residual |
| Password Reset Tickets / User / Month | < 0.05 |
| Passwordless Adoption (Pilot Cohort) | > 30% |

## Risk & Mitigation
| Risk | Mitigation |
|------|-----------|
| MFA Fatigue / Push Bombing | Number matching + disable push-only |
| Token Theft (Refresh Replay) | Conditional Access token binding + sign-in frequency |
| Legacy Line of Business apps blocking modern auth removal | App modernization plan + compensating controls |
| Resistance to FIDO2 onboarding | User comms + pilot champions |

## Roadmap Enhancements
- Continuous access evaluation expansion (Exchange, SharePoint, Teams)
- Conditional Access authentication strength policies
- Identity protection risk remediation automation (auto password reset)

## References
- NIST: [Digital Identity Guidelines (SP 800-63B)](https://pages.nist.gov/800-63-3/sp800-63b.html)
- Microsoft: [Microsoft Entra passwordless authentication options](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless)
 - Microsoft: [Microsoft Entra passwordless authentication options](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless)
 - Microsoft: [Authentication strengths & phishing-resistant MFA (search results)](https://learn.microsoft.com/en-us/search/?q=authentication%20strengths)
- FIDO Alliance: [FIDO2 Specifications](https://fidoalliance.org/specifications/)

---
Return to [Identity Index](../_index.md) | [PIM](../governance/entra-pim-rbac.md) | [Identity Lifecycle](../governance/identity-lifecycle-process.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
