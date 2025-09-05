---
Last Reviewed: 2025-09-04
Tags: monitoring, identity, networking, observability, detection
---
# Network & Identity Monitoring Framework

This page unifies core monitoring signals across network and identity boundaries to enable rapid detection, triage, and correlation of lateral movement, data exfiltration, and service degradation.

## Objectives
- Centralize high-value telemetry sources
- Map signals to attacker techniques (MITRE ATT&CK)
- Provide baseline + deviation model for proactive detection

## Core Data Sources
| Layer | Source | Purpose | Key Fields |
|-------|--------|---------|------------|
| Network | NSG Flow Logs (v2) | East/West & egress visibility | src/dst IP, ports, action |
| Network | Azure Firewall Logs | Policy enforcement & deny analysis | rule, action, fqdn |
| Network | Private Endpoint Connection Events | Data exfil & unauthorized access attempts | endpoint, state |
| DNS | Azure DNS / Private DNS Query Logs | Domain resolution patterns, tunneling detection | queryName, response |
| Identity | Entra ID Sign-in Logs | Auth patterns, impossible travel | userPrincipalName, riskLevel |
| Identity | Kerberos (4768/4769) | Ticket volume anomalies | serviceName, status |
| Directory | LDAP (2889 / 1644) | Unsigned binds & expensive queries | client, operation |

## Baseline & Anomaly Strategy
1. Establish 30-day rolling baselines for: ticket issuance volume, NSG deny ratios, firewall outbound FQDN distribution, DNS NXDOMAIN rate.
2. Use z-score or MAD thresholding for sudden spikes (ex: Kerberos TGS requests > 3x baseline).
3. Correlate multi-signal anomalies (e.g., spike in 4769 + unusual outbound FQDN + new Private Endpoint approval).

## Detection Examples
- Excessive Service Ticket Requests (Kerberoasting precursor)
- Sudden growth in denied egress to rare destinations (>95th percentile)
- Private Endpoint creation followed by outbound data spike
- High unsigned LDAP binds post-enforcement window (regression)

## Metrics Dashboard (Recommended)
| Metric | Target | Notes |
|--------|--------|-------|
| % LDAP signed binds | 100% | Alert on any unsigned after enforcement |
| NSG deny ratio | < 10% | Tune allow rules if consistently higher |
| Private Endpoint approval latency | < 1h | SLA for governance workflow |
| Kerberos service ticket volatility | Stable (within 2 std dev) | Outliers = review |
| DNS NXDOMAIN rate | Baseline Â±20% | Spikes may indicate DGA or misconfig |

---
Return to [Network Index](../_index.md) | [AD Monitoring Matrix](../../identity/monitoring/active-directory-security-monitoring-matrix.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
