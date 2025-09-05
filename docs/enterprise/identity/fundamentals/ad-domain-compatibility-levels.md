---
Last Reviewed: 2025-09-04
Tags: 
---

# AD Domain Compatibility Levels

Domain and forest functional levels in Active Directory determine which features are available and which versions of Windows Server domain controllers can participate.

## Table of Contents
- [Functional Levels](#functional-levels)
- [Common Levels](#common-levels)
- [Why Compatibility Levels Matter](#why-compatibility-levels-matter)
- [How to Check and Change](#how-to-check-and-change)
	- [1. View Current Levels](#1-view-current-levels)
	- [2. Inventory Domain Controllers & OS Versions](#2-inventory-domain-controllers--os-versions)
	- [3. Replication Health Baseline](#3-replication-health-baseline)
	- [4. Confirm Backups (Log Analytics / KQL)](#4-confirm-backups-log-analytics--kql)
	- [5. Raise Domain Functional Level (Example)](#5-raise-domain-functional-level-example)
	- [6. Raise Forest Functional Level (After all domains raised)](#6-raise-forest-functional-level-after-all-domains-raised)
	- [7. Post-Change Verification](#7-post-change-verification)
	- [8. Log / Audit Entry](#8-log--audit-entry)
	- [Functional Level Target Reference](#functional-level-target-reference)
	- [Modern Feature Availability by Level](#modern-feature-availability-by-level)
	- [Preconditions Checklist](#preconditions-checklist)
	- [Safety & Rollback Notes](#safety--rollback-notes)
	- [References](#references)

## Functional Levels
- **Domain Functional Level**: Controls features within a single domain.
- **Forest Functional Level**: Controls features across all domains in the forest.

## Common Levels
- Windows 2000
- Windows Server 2003
- Windows Server 2008/2008 R2
- Windows Server 2012/2012 R2
- Windows Server 2016
- Windows Server 2019
- Windows Server 2022

## Why Compatibility Levels Matter
- Higher levels enable advanced security and management features.
- All domain controllers must run a compatible Windows Server version before raising the level.
- Some features (fine-grained password policies, AD recycle bin, group managed service accounts, newer Kerberos protections) require higher functional levels.

### Security & Management Impact Deep Dive
Raising functional levels (and modernizing DC OS versions) progressively unlocks security controls and operational efficiencies. Many capabilities are OS-gated rather than strictly functional-level (FL) gated—separating the two prevents stalled upgrades. Where a capability depends primarily on DC OS (not the functional level), that dependency is explicitly noted. Inline bracket numbers map to the References section below.

| Capability Area | 2003 → 2008 | 2008 R2 | 2012 | 2012 R2 | 2016 (and later) |
|-----------------|-------------|---------|------|---------|-------------------|
| Password Policy Flexibility | Introduces Fine-Grained Password Policies (FGPP) at DFL 2008 [2] |  |  |  |  |
| Recovery & Object Lifecycle |  | AD Recycle Bin (FFL 2008 R2) [4] |  |  | Admins standardize rapid undelete workflows [4] |
| SYSVOL Integrity & Scale | Start DFSR Migration (DFL 2008) [3] |  |  |  | FRS fully deprecated; higher security baselines assume DFSR [3][13] |
| Kerberos Security | AES support baseline solidified (OS dependent) |  | FAST (Armoring) & Claims (DFL 2012) [6][7] | Authentication Policies & Silos (DFL 2012 R2) [10] | Modern hardened defaults, better cipher / protocol posture (OS-driven) [7] |
| Claims & Dynamic Authorization |  |  | Dynamic Access Control (DFL 2012 + 2012 DCs) [6] | Mature with Auth Policies integration [10] | Often superseded by conditional access + file classification hybrids |
| Service Account Hygiene | Basic Managed Service Accounts (earlier OS) |  | gMSA (2012 DC OS; no FL raise required) [8] |  | Wider adoption + tooling maturity [8] |
| Credential Exposure Reduction |  |  |  | Protected Users (2012 R2 DC OS) [9] | Baseline enforcement + integration with time-bound privilege models [9][11] |
| High Privilege Containment |  |  |  | Auth Policies & Silos (DFL 2012 R2) [10] | PAM (FFL 2016) time-bound group membership central to Tier model [11][12] |
| Time-Bound Privilege |  |  |  |  | Privileged Access Management (FFL 2016) + Expiring memberships [11][12] |
| Auditing & Forensics | Legacy | Improved replication consistency & tombstone restore timeline with Recycle Bin [4] | Claims-based auditing contexts [6] | Expanded policy scoping for privileged accounts [10] | Shorter MTTR with Recycle Bin + time-bound membership evidence; enriched change tracking via events 4738 / 5136 [16][17] |

Key Security Advantages by Transition:
- To 2008 DFL: Enables FGPP [2] → granular control of sensitive account password posture (privileged vs service vs standard users).
- To 2008 R2 FFL: Enables AD Recycle Bin [4] → eliminates authoritative restore for common accidental deletes, shrinking recovery RTO/RPO and reducing risky tombstone reanimation methods.
- To 2012 DFL + 2012 DC OS: Unlocks Kerberos Armoring (FAST) [7] and claims issuance / Dynamic Access Control [6] → channel hardening against KDC spoofing / offline pre-auth cracking; foundation for attribute/claims-based authorization.
- To 2012 R2 DFL / DC OS: Adds Protected Users [9] and Authentication Policies & Silos [10] → reduces credential replay / NTLM fallback paths; constrains high-value accounts to trusted hosts.
- To 2016 FFL + DC OS 2016+: Enables native time-bound group membership / PAM [11][12] → reduces standing privilege windows, aligns with Zero Standing Privilege (ZSP) models, and simplifies just-in-time (JIT) uplift workflows.

Risk of Remaining on Lower Levels:
- Prolonged reliance on static privileged group membership (no time-bound controls) increases blast radius of credential theft [11][12].
- Lack of Kerberos Armoring [7] & Protected Users [9] leaves pre-auth & ticket flows more susceptible to relay, downgrade, or offline brute-force tactics.
- Absence of Recycle Bin [4] forces complex authoritative restore operations (higher risk of USN rollback mistakes, longer outage windows).
- FGPP unavailability or underuse [2] drives over-permissive domain-wide password policy compromises (e.g., length/expiration compromises for legacy service accounts).

Operational Management Benefits:
- Faster, lower-risk recovery workflows (Recycle Bin) reduce engineering toil and unplanned change windows [4].
- Granular password segmentation (FGPP) enables differentiated hardening without multi-domain proliferation [2].
- Auth Policies & Silos formalize host-based trust boundaries for Tier 0/1/2 segmentation strategies [10].
- Time-bound membership simplifies audit narratives (“who had what, when”) and tightens SOX / privileged access review cycles [11][12].

Prioritization Guidance (If Staged):
1. Ensure DFSR migration is complete (pre-2016 raise blocker) to retire FRS and remove replication fragility.
2. Raise to 2008 R2 quickly if still below—Recycle Bin provides immediate resiliency; low regression risk.
3. Modernize DC OS versions in parallel with (or before) functional level raises to unlock Protected Users & Armoring, even if DFL temporarily lags.
4. Target 2016 baseline for PAM/time-bound membership and to align with contemporary security reference architectures.
5. After functional raises, operationalize: enable Recycle Bin, deploy Kerberos Armoring (staged policy), create KDS root key for gMSA (if not present), enroll privileged accounts into Protected Users, design Authentication Policies & Silos, then implement time-bound membership flows.

Validation Artifacts to Capture in Change Record:
- Current vs target DFL/FFL.
- Completed DFSR migration evidence (state from `dfsrmig /getmigrationstate`).
- Backup freshness table (KQL results from Step 4).
- Replication health summary (`repadmin /replsummary` excerpt).
- List of privileged groups prepared for time-bound membership (if moving to 2016 FFL).

Post-Raise Quick Wins (Execute Within 7–14 Days):
- Enable AD Recycle Bin (if first crossing to 2008 R2 FFL) [4].
- Configure Kerberos Armoring in audit → then enforce mode [7].
- Seed gMSA adoption for service tiers with previously shared credentials [8].
- Migrate static domain admin group membership to just-in-time model leveraging PAM/time-bound membership [11][12].
- Implement Protected Users for Tier 0 accounts after verifying NTLM & older cipher dependencies are absent [9].

Escalation / Abort Criteria During Raise:
- Any replication error spikes (e.g., lingering objects, schema mismatch).
- Discovery of non-migrated FRS SYSVOL replication after initiating level raise (halt; revert plan until remediated).
- Backup window breach (no fresh system state for any DC within policy).

Outcome Metric Suggestions:
- Reduction in standing privileged group members (baseline vs 30 days post-PAM enablement) [11][12].
- Mean time to restore deleted object (pre vs post Recycle Bin adoption) [4].
- Percentage of Tier 0 accounts in Protected Users group [9].
- Coverage of gMSA adoption for service principals vs legacy shared passwords [8].

All enhancements should be validated against authoritative documentation already cited in the References section; no new feature assertions introduced here rely on undocumented behavior.

## How to Check and Change
- Use GUI (Active Directory Domains and Trusts) or PowerShell to view current functional levels.
- Only raise after: all DC OS versions supported, replication healthy, recent system state backups verified, change window approved.
- Functional level raises are one‑way (rollback requires forest/domain recovery from backup).

### 1. View Current Levels
```powershell
Get-ADForest | Select-Object Name,ForestMode
Get-ADDomain | Select-Object DNSRoot,DomainMode
```
Sample:
```
Name        ForestMode
----        ----------
example.com Windows2016Forest

DNSRoot      DomainMode
-------      ----------
example.com  Windows2016Domain
```
Alternate (.NET reflection):
```powershell
[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().ForestMode
[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().DomainMode
```

### 2. Inventory Domain Controllers & OS Versions
```powershell
Get-ADDomainController -Filter * | Select HostName,IPv4Address,OperatingSystem,Site | Sort HostName
```
Find any DC below target (example excludes 2016+):
```powershell
Get-ADDomainController -Filter * | Where-Object {$_.OperatingSystem -notmatch '2016|2019|2022'} |
	Select HostName,OperatingSystem
```
Sample:
```
HostName  IPv4Address  OperatingSystem                      Site
--------  -----------  ---------------                      ----
DC01      10.10.10.11  Windows Server 2019 Standard         Default-First-Site-Name
DC02      10.10.10.12  Windows Server 2019 Standard         Default-First-Site-Name
```

### 3. Replication Health Baseline
```powershell
repadmin /replsummary
repadmin /showrepl * /csv > repl-baseline.csv
```
Sample (healthy):
```
Replication Summary Start: 2025-09-05 12:01:10

 Source DSA    largest delta    fails/total %%   error
 DC01          00m:45s          0 / 30    0
 DC02          00m:47s          0 / 30    0

Replication Summary End: 2025-09-05 12:01:15
```

### 4. Confirm Backups (Log Analytics / KQL)
Goal: Prove every domain controller has a successful System State (or full) backup within the last 24–48 hours, and there are no recent failed jobs blocking recovery confidence.

Assumptions:
- Backup / monitoring solutions are forwarding job results and Windows Event Logs into an Azure Log Analytics workspace.
- One (or more) of the following data sources is available (adjust queries to what you actually have):
	- Resource-specific Azure Backup tables (e.g., `BackupJobs`, `BackupItems`, or `AzureDiagnostics` legacy records)
	- Windows Event logs (`Event` table) for `Microsoft-Windows-Backup` (native Windows Server Backup) or vendor agent logs
	- Custom ingestion (e.g., `CustomBackup_CL`) standardizing fields

Set common parameters (adjust the list of DCs and lookback window as required):
```kusto
// Parameters
let LookbackHours = 48;            // Acceptable freshness window
let DCs = dynamic(["DC01","DC02","DC03"]); // Expected domain controllers
```

#### A. Azure Backup (Resource-Specific Table) Example
If you have the modern Azure Backup resource-specific schema (names can differ slightly by region / evolution):
```kusto
let LookbackHours = 48;
let DCs = dynamic(["DC01","DC02","DC03"]);
BackupJobs
| where TimeGenerated > ago(LookbackHours * 1h)
| where OperationType in ("Backup")
| where ProtectedItemType in ("SystemState", "WindowsServerSystemState", "Files") // broaden if mixed
```
