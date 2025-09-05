---
Last Reviewed: 2025-09-04
Tags: ActiveDirectory, Objects, Delegation, Auditing
---

# Active Directory Objects

Active Directory stores directory data as typed objects with attributes enforced by the schema. A sound operational model depends on understanding: (1) default containers vs Organizational Units (OUs), (2) a deliberate OU hierarchy, (3) which attributes are sensitive, and (4) who can read or write them by default. Concepts and security constructs here reference only active Microsoft documentation (see References section).

## 1. Core Object Classes
Common classes (non‑exhaustive) [1][2]:
- **user** – Security principal used by people or services.
- **group** – Security / distribution aggregation; member attribute controls access paths.
- **computer** – Security principal for a joined workstation/server.
- **organizationalUnit** – Policy & delegation boundary (GPO linking supported).
- **container** – Legacy/system holding object (GPO linking NOT supported).

## 2. Default Containers vs OUs
At domain creation several system containers (NOT OUs) exist. Key differences: containers cannot have Group Policy Objects (GPOs) linked and are poor delegation boundaries; OUs can. Delegation & access behavior relies on ACL semantics (DACL/SACL) [4].

| Logical Name | Distinguished Name (relative) | Type | GPO Linkable | Typical Contents | Delegation Notes |
|--------------|--------------------------------|------|--------------|------------------|------------------|
| Users        | CN=Users                        | Container | No | Newly created user & group objects by default | Should redirect new users to a managed OU; broad read ACL. |
| Computers    | CN=Computers                    | Container | No | Default join target for computer accounts | Redirect to tiered Server/Workstation OUs to apply baselines. |
| Builtin      | CN=Builtin                      | Container | No | Built‑in local groups (Domain Admins, etc.) | Highly sensitive; membership changes audited. |
| System       | CN=System                       | Container | No | AD internal objects (AdminSDHolder, DFSR, etc.) | Avoid manual changes; protect with auditing. |
| Managed Service Accounts | CN=Managed Service Accounts | Container | No | gMSA & sMSA objects | Delegate minimally; sensitive credential material indirectly. |
| Program Data | CN=Program Data                 | Container | No | Application specific directory data | Application owners only. |

### Redirection of Default Containers
Best practice: redirect default user/computer creation to controlled OUs early in a forest’s life to ensure baseline GPOs & delegated workflows apply. Group scoping & protected group behavior (AdminSDHolder) impact delegation surfaces [1].
Commands (run once per domain, requires Domain Admin):
```
redirusr "OU=Identity,OU=Corp,DC=example,DC=com"
redircmp "OU=Workstations,OU=Devices,DC=example,DC=com"
```
If the native documentation pages for these commands are unavailable, verify success via PowerShell:
```
(Get-ADDomain).UsersContainer
(Get-ADDomain).ComputersContainer
```

## 3. Recommended Baseline OU Structure (Example)
Adapt to scale & regulatory context; depth should remain shallow (≤4 levels) to simplify policy targeting.

| Tier | Purpose | Example DN | Notes |
|------|---------|-----------|-------|
| Tier 0 | Domain & forest controllers, PKI, identity security infra | OU=Tier0,DC=example,DC=com | Most restrictive; no helpdesk write. |
| Tier 1 | Servers (application & infrastructure) | OU=Servers,DC=example,DC=com | Sub‑OUs by platform or patch ring optional. |
| Tier 2 | User workstations & VDI | OU=Workstations,DC=example,DC=com | Applied hardening & EDR baselines. |
| Service Accounts | Managed service / gMSA objects | OU=ServiceAccounts,DC=example,DC=com | Distinct lifecycle & monitoring. |
| Privileged Users | Admin & break‑glass accounts | OU=PrivAccounts,DC=example,DC=com | Separate authentication policies. |
| Staging / Join | Quarantine for new or reimaged devices | OU=DeviceStaging,DC=example,DC=com | Minimal access until compliance tags set. |
| Disabled / Archive | Retained for legal hold | OU=Disabled,DC=example,DC=com | No interactive logon; monitored. |

## 4. Common Attributes & Sensitivity Classification
Sensitivity categories (events & auditing: 4738 / 5136 [6][7]):
- L = Low (broad read; write has minimal risk)
- M = Medium (can aid reconnaissance or lateral movement)
- H = High (privilege escalation, impersonation, policy manipulation)

### User Object
| Attribute | Purpose | Risk if Modified | Sensitivity |
|-----------|---------|------------------|-------------|
| userPrincipalName | Primary sign‑in alias | Hijack sign‑in mapping | M |
| sAMAccountName | Legacy logon name | Credential phishing consistency / collisions | M |
| userAccountControl | Security flags (delegation, smartcard, etc.) | Enable weak auth, delegation abuse (see flag list) [3] | H |
| pwdLastSet | Password rotation indicator | Force password change timing manipulation | M |
| msDS-AllowedToDelegateTo | Kerberos constrained delegation targets | Unauthorized lateral movement [8] | H |
| servicePrincipalName | SPN set (if service acct) | Kerberoasting / impersonation [8] | H |
| memberOf (back-link) | Group memberships | Privilege escalation | H |
| sIDHistory | Historical SIDs | Reintroduce migrated privileges [2] | H |
| displayName / mail | Directory presentation | Spear phishing accuracy | L |
| logonHours | When account can authenticate | Expand attack window | M |

### Group Object
| Attribute | Purpose | Risk | Sensitivity |
|-----------|---------|------|-------------|
| member | Effective access via nested principals | Add stealth privilege path [1][4] | H |
| managedBy | Delegated owner | Abuse to socially engineer | M |
| groupType | Scope & security flag | Change to expand reach | M |
| description | Human context | Recon signal | L |
| adminCount | Protected status marker | Signals privileged lineage (AdminSDHolder) [1] | M |

### Computer Object
| Attribute | Purpose | Risk | Sensitivity |
|-----------|---------|------|-------------|
| dNSHostName | FQDN mapping | Targeting for attacks | L |
| servicePrincipalName | Service identity entries | Kerberoasting, relay [8] | H |
| msDS-AllowedToDelegateTo | Delegation targets | Lateral movement [8] | H |
| userAccountControl | Machine trust flags | Enable DES / unconstrained delegation [3][8] | H |
| lastLogonTimestamp | Activity signal | Recon of dormant assets | M |

### OU Object
| Attribute | Purpose | Risk | Sensitivity |
|-----------|---------|------|-------------|
| gPLink | Linked GPO list | Inject malicious policy [4] | H |
| gPOptions | GPO inheritance control | Bypass security baselines [4] | H |
| managedBy | Administrative contact | Social engineering [1] | M |
| description | Documentation | Recon | L |
| distinguishedName | Hierarchical identity | Used in ACL/policy targeting | L |

## 5. Default Read & Write Access Patterns
High‑level defaults in a new domain (default group scopes & ACL behaviors) [1][4]:
- **Authenticated Users**: Read most attributes (directory discovery is broadly available) [1][4].
- **SELF**: Limited write to certain personal attributes (e.g., some certificate or phone fields if enabled) [4].
- **Domain Admins / Enterprise Admins**: Full control across domain / forest scope respectively [1].
- **Account Operators**: Legacy; can create/modify most user/computer objects excluding highly privileged accounts—should remain empty (risk of privilege escalation) [1].
- **Server Operators / Backup Operators / Print Operators**: Do NOT delegate directory object management responsibilities here; groups are service‑admin oriented and protected.
- **AdminSDHolder Protection**: Members of protected groups inherit a locked ACL template every ~60 minutes; custom delegation on those objects will be reverted unless applied to AdminSDHolder [1][4].

### Practical Enumeration Examples (PowerShell)
```
# List effective ACEs on a sensitive OU
Get-Acl 'AD:OU=Tier0,DC=example,DC=com' | Select -ExpandProperty Access | ft IdentityReference,ActiveDirectoryRights,InheritanceType

# Examine who can write a critical attribute on a user
([adsi]'LDAP://CN=Admin,OU=PrivAccounts,DC=example,DC=com').psbase.ObjectSecurity.Access | ? { $_.ActiveDirectoryRights -match 'WriteProperty' -and $_.ObjectType -eq 'bf9679c0-0de6-11d0-a285-00aa003049e2' }  # example GUID for userPrincipalName

# Review delegation vs protected accounts (adminCount=1)
Get-ADUser -LDAPFilter '(adminCount=1)' -Properties adminCount | Select SamAccountName,DistinguishedName
```

> Note: Native command references for `dsacls`, `redirusr`, and `redircmp` pages may intermittently return 404. Use PowerShell & RSAT tooling for authoritative current-state enumeration.

## 6. Sensitive Attribute Monitoring & Auditing
| Goal | Event ID(s) | Notes |
|------|-------------|-------|
| Track user attribute change (flags, delegation, logon settings) | 4738 | Generate on DCs; monitor deltas for high-risk fields (userAccountControl, msDS-AllowedToDelegateTo, sIDHistory) [6][3][8][2]. |
| Track any directory object attribute modification (with SACL) | 5136 | Requires appropriate SACL entries (Write / Write Property). Correlate Value Deleted + Value Added pairs [7][4]. |

Audit strategy (leverages DACL/SACL + events) [4][6][7]:
1. Add SACL on critical OUs (Tier0, PrivAccounts, ServiceAccounts) for: Write All Properties, Write Property on gPLink, member, servicePrincipalName, msDS-AllowedToDelegateTo, sIDHistory [4][8][2].
2. Collect Security logs from all DCs centrally (e.g., via agent). Filter for Event IDs 4738 & 5136 then project high‑risk attributes.
3. Baseline expected volume; alert on: sudden spike in 5136 targeting gPLink, unexpected msDS-AllowedToDelegateTo additions, new sIDHistory values.
4. Implement least privilege: review ACEs granting GenericAll / GenericWrite on OUs or privileged groups; remediate broad Authenticated Users write exposures.

## 7. Delegation & Change Control Guidance
| Activity | Recommended Role / Group | Control Point |
|----------|--------------------------|---------------|
| Routine user provisioning | Identity Operations (delegated OU) | OU-level Write rights only |
| Service account lifecycle | Restricted Service Account Admins | Change advisory + logging |
| Computer join (bulk) | Join Staging Group (rights to create in Staging OU) | Automated join scripts |
| GPO Link changes to Tier0 OU | Domain Admin subset (PIM eligible) | Change ticket + 4-eyes review |
| Group membership for privileged groups | Tier0 Admins only | Just-in-time elevation |

## 8. Hardening Checklist (Quick)
Use the Status column to track completion.

| Status | Task | Rationale / Ref |
|--------|------|-----------------|
| [ ] | Redirect default Users & Computers containers | Baseline GPO & delegation alignment [1] |
| [ ] | Create & enforce tiered OU model (Tier0 isolated) | Segregate privilege + policy scoping [1][4] |
| [ ] | Remove members from legacy operator groups (keep empty) | Reduce lateral privilege paths [1] |
| [ ] | Enable auditing: Directory Service Changes + User Account Management | Capture Events 5136 & 4738 [7][6] |
| [ ] | Add SACLs for delegation/SPN/membership/GPO link attributes | Detect privilege manipulation [4][8] |
| [ ] | Monitor for unconstrained delegation, DES, unexpected SPNs | Prevent credential abuse [3][8] |
| [ ] | Adopt Protected Users for Tier 0 accounts | Cut credential exposure (no NTLM/DES/RC4) [5] |
| [ ] | Introduce gMSA for eligible services | Eliminate shared static passwords [9] |
| [ ] | Export & diff ACLs of Tier0 / Privileged OUs periodically | Detect unauthorized ACL drift [4] |

## 9. References
Only active (non‑404) Microsoft sources included below:
1. Active Directory security groups – https://learn.microsoft.com/windows-server/identity/ad-ds/manage/understand-security-groups
2. Security identifiers (SIDs) – https://learn.microsoft.com/windows/access-protection/access-control/security-identifiers
3. UserAccountControl flags – https://learn.microsoft.com/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties
4. Access control lists (DACLs & SACLs) – https://learn.microsoft.com/windows/win32/secauthz/access-control-lists
5. Protected Users security group – https://learn.microsoft.com/windows-server/security/credentials-protection-and-management/protected-users-security-group
6. Event 4738 (user account changed) – https://learn.microsoft.com/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4738
7. Event 5136 (directory service object modified) – https://learn.microsoft.com/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-5136
8. Kerberos authentication overview (delegation, SPNs, pre-auth hardening) – https://learn.microsoft.com/windows-server/security/kerberos/kerberos-authentication-overview
9. Group Managed Service Accounts overview – https://learn.microsoft.com/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview
10. Access control overview – https://learn.microsoft.com/windows/security/identity-protection/access-control/access-control

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
