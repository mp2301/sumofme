---
Last Reviewed: 2025-09-03
Tags: kerberos, ldap, security, hardening, detection
---
# Kerberos and LDAP Security

Securing Kerberos and LDAP in a Windows Active Directory environment reduces credential theft, relay, and downgrade attack risk.

## Kerberos Security
- Enforce AES encryption for service accounts (remove RC4 where possible)
- Rotate KRBTGT account password twice for compromise response
- Monitor for abnormal TGT lifetime or unusual service ticket volumes
- Enable FAST (Flexible Authentication Secure Tunneling) if supported for pre-auth hardening
- Constrain delegation: prefer KCD (protocol transition only when required)

### Kerberos Attack Surface
| Threat | Description | Mitigation |
|--------|-------------|------------|
| Pass-the-Ticket | Reuse of stolen Kerberos tickets | LSASS protection, Credential Guard, monitoring abnormal TGS requests |
| Golden Ticket | Forged TGT using KRBTGT hash | Secure DCs, monitor DC replication metadata, periodic KRBTGT rotation |
| Kerberoasting | Offline cracking of service account hashes via SPNs | Strong random passwords / gMSA, detect high service ticket requests |
| Unconstrained Delegation | Ticket reuse across services | Audit & remove unconstrained delegation, use KCD |

## LDAP Security
- Require LDAP signing and channel binding (audit â†’ enforce)
- Disable simple binds over clear text
- Limit anonymous binds; monitor anonymous LDAP operations
- Filter privileged group queries; detect mass directory enumeration patterns

### Hardening Steps
1. Enable LDAP signing audit policy
2. Collect logs for 90 days; remediate incompatible clients
3. Enforce signing & channel binding via registry/GPO
4. Monitor Event IDs 2889 (unsigned/simple binds) and 1644 (expensive queries)

## Monitoring & Detection
| Category | Event / Signal | Purpose |
|----------|----------------|---------|
| Unsigned LDAP | 2889 | Detect legacy/insecure clients |
| Expensive LDAP Query | 1644 (with diagnostics) | Detect recon / inefficient queries |
| Kerberos AS-REQ / TGS-REQ | 4768 / 4769 | Spot brute force, roasting patterns |
| Privileged Use | 4672 | Correlate with unusual ticket activity |
| Service Ticket Volume | Baseline vs spike | Indication of kerberoasting enumeration |

## Metrics
- % of LDAP binds signed (target 100%)
- # of RC4 encrypted tickets (drive to zero)
- Time between KRBTGT resets (documented & controlled)

## References
- Microsoft: [How to enable LDAP signing in Windows Server](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/enable-ldap-signing-in-windows-server)
- Microsoft: [Kerberos authentication overview](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview)
- Microsoft: [Defender for Identity health & detection signals](https://learn.microsoft.com/en-us/defender-for-identity/health-alerts) (map ticket / LDAP related health & detection capabilities)
- Microsoft Advisory: [ADV190023 LDAP Channel Binding & Signing Guidance](https://portal.msrc.microsoft.com/security-guidance/advisory/ADV190023)
- Microsoft: [2020â€“2024 LDAP channel binding & signing requirements](https://support.microsoft.com/topic/2020-2023-and-2024-ldap-channel-binding-and-ldap-signing-requirements-for-windows-kb4520412-ef185fb8-00f7-167d-744c-f299a66fc00a)
- MITRE ATT&CK Tactics: [Credential Access](https://attack.mitre.org/tactics/TA0006/) | [Lateral Movement](https://attack.mitre.org/tactics/TA0008/)
- Related Internal: [Hardening Baselines](ad-hardening-baselines.md) | [AD Monitoring Matrix](../monitoring/active-directory-security-monitoring-matrix.md)

---
Return to [Identity Index](../_index.md) | [Hardening Baselines](../hardening/ad-hardening-baselines.md) | [AD Monitoring Matrix](../monitoring/active-directory-security-monitoring-matrix.md)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
