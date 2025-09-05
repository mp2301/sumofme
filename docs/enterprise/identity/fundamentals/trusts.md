---
Last Reviewed: 2025-09-04
Tags: 
---

# Active Directory Trusts

Trusts in Active Directory allow users in one domain to access resources in another domain. They are essential for enabling collaboration and resource sharing across different domains and forests.

## Types of Trusts
- **Parent-child trust**: Automatically created between domains in the same forest.
- **Tree-root trust**: Automatically created between root domains in the same forest.
- **External trust**: Manually created between domains in different forests or with non-AD domains.
- **Forest trust**: Manually created between two AD forests.
- **Shortcut trust**: Manually created to optimize authentication between domains in a complex forest.

## Trust Directions
- **One-way trust**: Only one domain trusts the other.
- **Two-way trust**: Both domains trust each other.

## Security and Management
Trust design directly affects blast radius, lateral movement pathways, and administrative complexity. Apply least privilege, minimize attack surface, and continuously verify integrity. (References: [netdom trust](#ref1), Kerberos event auditing [4768](#ref2)/[4769](#ref3)/[4771](#ref4), enterprise access model [#ref5](#ref5)).

### Core Hardening Principles
1. Minimize Trust Count: Create a trust only when a clear business/application dependency exists (document owner + data classification + review cadence). Each additional trust expands the transited path an attacker can traverse.
2. Prefer Two-Way Forest Trusts ONLY when bi‑directional access is required. Otherwise use one‑way to limit authentication scope: resource forest trusts account / identity forest.
3. Remove Stale Trusts: Quarterly (or at M&A integration milestones) list trusts and validate active use (e.g., successful cross-domain authentications in last 30–90 days using Event 4768/4769 correlation). Decommission unused ones.

### Authentication Scope Controls
| Control | When to Use | Mechanism | Rationale | Reference |
|---------|------------|-----------|-----------|-----------|
| Selective Authentication | External / Forest trust where you do NOT want implicit AuthN to all servers | Set trust to Selective Auth; grant "Allowed to Authenticate" on target computer objects | Prevents broad lateral movement; requires explicit host-level grants | [netdom /selectiveauth](#ref1) |
| SID Filtering (Quarantine) | External & forest trusts by default | `/quarantine:yes` (enabled) | Blocks injected / forged SID history from trusted forest | [netdom /quarantine](#ref1) |
| Disable SID History Usage | After migration complete | `/enablesidhistory:no` on outbound forest trust | Reduces risk of stale elevated SIDs being honored | [netdom /enablesidhistory](#ref1) |
| Block Kerberos Full Delegation | Unless explicitly required cross-forest | `/enabletgtdelegation:no` | Prevents unconstrained delegation token forwarding across trust | [netdom /enabletgtdelegation](#ref1) |
| Authentication Target Validation | Always (hardening) | `/authtargetvalidation:yes` | Ensures remote forest DC targeting validation; reduces spoofing | [netdom /authtargetvalidation](#ref1) |
| Name Suffix Routing Hygiene | Forest trusts | `/namesuffixes` + `/togglesuffix` to disable unused | Shrinks namespace that will route → reduces spoof & collision surface | [netdom /namesuffixes](#ref1) |
| PIM Trust Behaviors | JIT scenarios with identity governance | `/enablepimtrust:yes` (forest transitive required) | Enables privileged identity management semantics across trust | [netdom /enablepimtrust](#ref1) |

### Delegation & Lateral Movement
- Eliminate unconstrained delegation in both forests before enabling or broadening trusts; test for SPNs with `TrustedForDelegation` flag.
- For constrained delegation across a trust, review necessity; prefer resource-side service abstraction (API / proxy) to reduce trust breadth.
- Disable `/enabletgtdelegation` unless a vetted workload (documented data flow + owner) requires cross-forest full delegation.

### Monitoring & Detection
Use Security Event Logs on domain controllers for cross-forest activity baselining:
- Event 4768 (TGT request) & 4769 (Service ticket) – Tag requests where `TargetDomainName` (or realm) differs from local domain to measure cross-forest authentications (refs [#ref2](#ref2), [#ref3](#ref3)).
- Event 4771 (Pre-auth failures) – Identify brute-force / enumeration attempts sourced via trust (ref [#ref4](#ref4)).
- Track spike thresholds (% increase over 30-day moving average) for external principal authentications.
- Alert on legacy / weak Kerberos encryption types (DES, RC4) in 4768/4769 tickets—indicator of down-level systems in a trusted forest.

Example (KQL concept – adapt to your schema) to find cross-forest Kerberos activity from remote forest FQDN:
```kusto
SecurityEvent
| where EventID in (4768,4769)
| where TargetDomainName =~ "OTHERFOREST.LOCAL" or ServiceName has "OTHERFOREST" 
| summarize Count = count() by EventID, bin(TimeGenerated, 1h)
```

### Operational Governance
- Change Control: Any trust parameter modification (/selectiveauth, /quarantine, /enabletgtdelegation, /namesuffixes toggles) requires CAB ticket with rollback (captured netdom verification output before & after).
- Documentation: Maintain per-trust record: business owner, direction (inbound/outbound), authentication scope (selective / not), delegation exceptions, last validation date.
- Validation Cadence: At least quarterly execute `netdom trust <trusting> /domain:<trusted> /verify /kerberos` (ref [#ref1](#ref1)). Investigate failures promptly.

### Lifecycle / M&A Scenarios
- Stage migration with one-way inbound trust first (production resources remain isolated) → migrate identities → evaluate necessity of bidirectional expansion.
- Decommission trusts only after audit confirms zero authentications (4768/4769) for defined cool-down period (e.g., 30 days) from source forest accounts.

### Risk Indicators (Action Triggers)
| Indicator | Potential Issue | Immediate Action |
|----------|-----------------|------------------|
| Sudden increase (>200% baseline) 4769 failures from trusted domain | Brute force / enumeration | Investigate source hosts; enable selective auth if absent |
| Appearance of DES/RC4 encryption types in cross-forest tickets | Legacy DC / policy regression | Audit encryption policy; enforce AES-only | 
| New enabled name suffix without CAB record | Unauthorized routing expansion | Disable suffix; review change trail |
| `/quarantine:no` on external trust undocumented | Potential SID history abuse path | Set `/quarantine:yes`; verify no dependency broken |
| Unconstrained delegation SPN in either forest with cross-forest access | Kerberos ticket theft lateral path | Convert to constrained or remove delegation |

### Verification Commands (Examples)
```powershell
# List trusts for current domain
nltest /domain_trusts /all /v

# Verify a specific trust (Kerberos)
netdom trust corp.local /domain:partner.local /verify /kerberos

# Show name suffix routing (forest trust)
netdom trust corp.local /domain:partner.local /namesuffixes

# Enable selective authentication (outbound forest trust example)
netdom trust corp.local /domain:partner.local /selectiveauth:yes
```

### Reference Integrity
Only active or archived (previous-versions) Microsoft Learn pages with stable URLs are cited below—404 endpoints (e.g., older planning pages for selective authentication / name suffix routing) have been excluded to avoid dead link drift.

### References
1. <a id="ref1"></a>netdom trust command – https://learn.microsoft.com/windows-server/administration/windows-commands/netdom-trust
2. <a id="ref2"></a>Kerberos TGT Request Event 4768 – https://learn.microsoft.com/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4768 (Archived)
3. <a id="ref3"></a>Kerberos Service Ticket Event 4769 – https://learn.microsoft.com/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4769 (Archived)
4. <a id="ref4"></a>Kerberos Pre-authentication Failure Event 4771 – https://learn.microsoft.com/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4771 (Archived)
5. <a id="ref5"></a>Enterprise Access Model (Privileged Access Strategy) – https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-access-model

Archived Link Legend: References marked (Archived) indicate “previous-versions” docs retained for technical accuracy after restructuring. Validate behaviors in lab where critical.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
