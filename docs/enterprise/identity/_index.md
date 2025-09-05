Last Reviewed: 2025-09-04
Tags: identity, overview
---
# Identity Documentation

Active Directory & Microsoft Entra ID: architecture, governance, security hardening, monitoring, federation/integration, lifecycle operations, and runbooks.

## Detailed Index

### Fundamentals
- [What is Windows Active Directory?](fundamentals/what-is-ad.md)
- [What is Entra ID?](fundamentals/what-is-entra-id.md)
- [Active Directory Objects](fundamentals/objects.md)
- [Security Identifiers (SID)](fundamentals/sid.md)
- [Domain Compatibility Levels](fundamentals/ad-domain-compatibility-levels.md)
- [Active Directory Trusts](fundamentals/trusts.md)

### Architecture
- [Entra ID Integration (Hybrid Identity)](architecture/entra-id-integration.md)
- [Password & Authentication Modernization](architecture/password-auth-modernization.md)
- [Group Policy Strategy and Design](architecture/group-policy-strategy.md)
- [Multi-Tenancy: List Object Mode](architecture/multi-tenancy-list-object-mode.md)

### Governance
- [Administrative Tiering Model](governance/admin-tiering-model.md)
- [Azure RBAC](governance/azure-rbac.md)
- [Privileged Accounts and Groups](governance/privileged-accounts-and-groups.md)
- [Compliance Reporting Frameworks](governance/compliance.md)
- [Azure Policy Regulatory Frameworks](governance/azure-policy-regulatory-frameworks.md)
- [Identity Lifecycle Process (Joiner / Mover / Leaver)](governance/identity-lifecycle-process.md)
- [Training Resources](governance/training.md)
- [Privileged Identity Management (PIM)](governance/entra-pim-rbac.md)

### Hardening
- [Kerberos and LDAP Security](hardening/kerberos-ldap-security.md)
- [AD Hardening Baselines](hardening/ad-hardening-baselines.md)
- [AD Certificate Services Overview](hardening/ad-certificate-services-overview.md)

### Monitoring
- [Diagnosing Common AD Errors](monitoring/diagnosing-ad-errors.md)
- [Active Directory Security Monitoring Matrix](monitoring/active-directory-security-monitoring-matrix.md)
- [Entra ID Security Monitoring Matrix](monitoring/entra-id-security-monitoring-matrix.md)

### Integration
- [OIDC & OAuth with Entra ID](integration/azure-ad-oidc-oauth.md)
- [SAML with Entra ID](integration/azure-ad-saml.md)
- [SCIM Provisioning](integration/azure-ad-scim.md)
- [Cross-Tenant Collaboration](integration/cross-tenant-collaboration.md)
- [DNS & Azure Private Resolver](integration/dns-azure-private-resolver.md)

### Runbooks
- [Backup & Restore Basics](runbooks/backup-restore.md)
- [Break Glass Accounts](runbooks/break-glass-accounts.md)
- [KRBTGT Account Password Rotation](runbooks/runbook-krbtgt-rotation.md)
- [LDAP Signing & Channel Binding Enforcement](runbooks/runbook-ldap-signing-enforcement.md)
- [Active Directory Forest Recovery](runbooks/runbook-ad-forest-recovery.md)

### Tools & Automation
- [Active Roles Management](tools/active-roles.md)
- [CyberArk Privileged Access Management](tools/cyberark.md)

---
Include: `../../_footer.md`

---
Return to [Enterprise](../_index.md) | [Root README](../../../README.md)

