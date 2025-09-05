---
Last Reviewed: 2025-09-03
Tags: pkI, certificates, ad-cs, security, hardening
---
# Active Directory Certificate Services (AD CS) Overview

Active Directory Certificate Services provides a customizable public key infrastructure (PKI) for issuing and managing digital certificates used for authentication, encryption, and signing.

## Why It Matters
Compromise or misconfiguration of PKI enables credential theft, machine or user impersonation, and code/signing abuse. PKI must be treated as Tier 0 security infrastructure.

## PKI Components
| Component | Purpose |
|-----------|---------|
| Root CA | Offline trust anchor issuing to subordinate CAs |
| Issuing / Subordinate CA | Issues end-entity certificates (users, machines, services) |
| Certificate Templates | Define issuance parameters & constraints |
| Online Responder (OCSP) | Real-time revocation status checking |
| CRL Distribution Points | Provide certificate revocation lists |

## Common Certificate Use Cases
- Smart card logon / phishing-resistant auth
- TLS for internal web services
- Code signing & driver signing
- S/MIME email encryption
- Network device (802.1X) authentication
- EFS / data recovery agents

## Hardening & Design
- Keep Root CA offline; sign subordinate CRLs & publish on schedule
- Limit who can enroll high-privilege templates (e.g., SmartcardLogon)
- Disable or restrict dangerous template settings (e.g., `ENROLLEE_SUPPLIES_SUBJECT` without strong controls)
- Monitor template permission changes & CA role membership
- Use separate CAs for issuance domains (workstation vs server vs auth certificates)
- Implement CRL & OCSP high availability (test revocation freshness)

## Attack Surface & Risks
| Risk | Description | Mitigation |
|------|-------------|------------|
| ESC1â€“ESC8 (ADCS abuses) | Misconfigurations enabling privilege escalation | Use tools (Certify/Pkifullscan) to enumerate & remediate |
| Weak Template Permissions | Unprivileged enrollment of privileged cert types | Tighten ACLs, remove Authenticated Users where unnecessary |
| Key Archival Abuse | Recovery agents accessing private keys | Limit & monitor Data Recovery Agent usage |
| CRL Unavailability | Clients accept stale revocation data | Monitor CRL validity & publishing jobs |

## Monitoring
- Track template modifications (Event 4899)
- CA configuration changes (4885â€“4890)
- Enrollment spikes or unusual request sources
- OCSP responder errors / CRL publish failures

## Operational Practices
- Annual PKI ceremony for offline root (document steps)
- Quarterly review of templates & permissions
- Maintain dependency map (systems relying on issued certs)
- Test disaster recovery: restore issuing CA from backup & validate trust chain

## Metrics
- % privileged templates reviewed quarterly
- Time to publish updated CRL (within defined SLA)
- # of identified ESC vulnerabilities open > 30 days (drive to zero)

## References
- Microsoft: [Active Directory Certificate Services Overview (search)](https://learn.microsoft.com/en-us/search/?q=active%20directory%20certificate%20services) (platform docs)
- Microsoft: [Best practices for securing AD CS (search)](https://learn.microsoft.com/en-us/search/?q=securing%20active%20directory%20certificate%20services) (hardening)
- SpecterOps: [Certified Pre-Owned â€“ Active Directory Certificate Services](https://posts.specterops.io/certified-pre-owned-d95910965cd2)
- NIST: [SP 800-57 Part 1 Revision 5](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)

---
Return to [Identity Index](../_index.md) | [Kerberos & LDAP Security](kerberos-ldap-security.md) | [Hardening Baselines](ad-hardening-baselines.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
