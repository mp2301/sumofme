---
Last Reviewed: 2025-09-04
Tags: meta, taxonomy, navigation
---
# Domain Category Reference

Central registry of documentation categories for each domain. Index pages reference this file to avoid drift.

## Identity Categories

| Category | Folder | Purpose | Representative Pages |
|----------|--------|---------|----------------------|
| Fundamentals | `fundamentals/` | Core AD / Entra ID concepts & objects | `what-is-ad.md`, `what-is-entra-id.md`, `objects.md` |
| Architecture | `architecture/` | Hybrid & modernization patterns | `entra-id-integration.md`, `password-auth-modernization.md` |
| Governance | `governance/` | Tiering, RBAC, PIM, lifecycle & policy | `admin-tiering-model.md`, `azure-rbac.md`, `entra-pim-rbac.md` |
| Hardening | `hardening/` | Protocol & service hardening baselines | `kerberos-ldap-security.md`, `ad-hardening-baselines.md` |
| Monitoring | `monitoring/` | Health & security detection | `active-directory-security-monitoring-matrix.md`, `diagnosing-ad-errors.md` |
| Integration | `integration/` | Federation & provisioning protocols | `azure-ad-scim.md`, `azure-ad-saml.md`, `azure-ad-oidc-oauth.md` |
| Runbooks | `runbooks/` | Operational workflows & recovery | `runbook-krbtgt-rotation.md`, `runbook-ad-forest-recovery.md` |
| Tools | `tools/` | Management & automation tooling | `active-roles.md`, `cyberark.md` |

## Network Categories

| Category | Folder | Purpose | Representative Pages |
|----------|--------|---------|----------------------|
| Fundamentals | `fundamentals/` | Core virtual networking primitives | `overview.md`, `vnets.md`, `vnet-peering.md` |
| Architecture | `architecture/` | Large-scale & transit patterns | `vwan.md`, `egress-architecture.md` |
| DNS | `dns/` | Name resolution strategy & services | `private-dns.md`, `private-dns-resolver.md`, `public-dns.md` |
| Security | `security/` | Perimeter & segmentation controls | `azure-firewall.md`, `nsgs.md` |
| Governance | `governance/` | Policy & address management | `ip-address-management.md` |
| Hardening | `hardening/` | Defensive baselines & posture | `cloud-network-hardening.md` |
| Monitoring | `monitoring/` | Telemetry & correlation | `network-identity-monitoring.md` |
| Integration | `integration/` | Connectivity (VPN & related) | `azure-vpn.md` |
| Runbooks | `runbooks/` | Operational procedures | `runbooks-cloud-network.md` |
| Tools | `tools/` | Diagnostics & visibility tooling | `network-watcher.md`, `wireguard.md`, `tailscale.md` |

## Change Process
1. Propose new category in PR (ensure it applies to â‰¥2 pages or a planned set).
2. Update this file first, then adjust affected index pages if needed.
3. Avoid renaming categories without migration note in PR description.

---
Return to [Style Guide](STYLEGUIDE.md) | Return to [Root README](../../README.md)

---
Include: `../_footer.md`

