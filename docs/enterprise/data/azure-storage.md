---
Last Reviewed: 2025-09-04
Tags: storage, blob, files, azure-storage
---
# Azure Storage

Overview of Blob, File, Queue, and Table storage and guidance for secure, performant usage.
## Overview

This page covers Azure Blob and File storage concepts most relevant to data platforms: when to use each type, networking and protection options, and guidance for cost and operations.

## Table of contents

- [Overview](#overview)
- [When to use](#when-to-use)
- [Key considerations](#key-considerations)
- [Data protection details: soft delete, versioning, and immutable policies](#data-protection-details-soft-delete-versioning-and-immutable-policies)
- [Cost frame of reference: how protection affects storage costs](#cost-frame-of-reference-how-protection-affects-storage-costs)
- [Practical CLI and policy examples](#practical-cli-and-policy-examples)

---

## When to use

- Blob storage: object storage for backups, archives, app assets, and analytics datasets (ADLS Gen2 when hierarchical namespace is needed).
- File share: lift-and-shift SMB workloads and shared file systems for legacy apps.

---

## Key considerations

- Performance tiers: Hot / Cool / Archive — pick based on access frequency and retrieval needs.
- Networking: prefer Private Endpoint for PaaS-level private access; use Storage firewall and VNet rules for restricted access.
- Data protection: Soft Delete, Blob Versioning, Immutable Blob Storage, and lifecycle management.
- Hierarchical namespace (ADLS Gen2) for analytics workloads requiring POSIX-like semantics and ACLs.

---
## Data protection details: soft delete, versioning, and immutable policies

This section explains the differences between Soft Delete, Blob Versioning, and Immutable Blob Storage (time-based retention / legal hold), their operational behaviour, and the cost & performance implications so you can choose appropriately.

### Soft Delete (Blob soft delete)

- What it does: when enabled, deleted blobs and blob snapshots are retained for a configurable retention period (days). During the retention period you can recover deleted blobs.
- Behaviour: soft delete retains object metadata and content in the same storage account; deletion operations mark the blob as deleted but the data is recoverable until retention expires.

Implications:

- Cost: soft-deleted data is charged as normal blob storage for the duration of the retention period (storage IOPS/size). If many large deletes occur, expect temporary storage growth and charges.
- Performance: read/write performance for active blobs is unaffected, but restore operations may incur additional I/O and egress if data is read-heavy during recovery.

Use cases:

- Accidental deletes recovery, short-term retention for operational safety, and safety nets during large ETL or migration activities.

Recommendations:

- Keep retention short (e.g., 7–30 days) for operational recovery; increase only for compliance needs.
- Monitor storage account used bytes and set alerts to detect unexpected growth following bulk deletes.

---

### Blob Versioning

- What it does: when enabled, every overwrite or snapshot of a blob creates a version record. Versions are immutable references to prior content and enable point-in-time recovery.
- Behaviour: versions accumulate over time unless lifecycle policies clean them up. You can read or restore a prior version by specifying the version ID.

Implications:

- Cost: each version consumes storage; frequent updates to large blobs can multiply storage costs. Plan lifecycle policies to delete old versions after a retention period or convert them to archive.
- Performance: negligible runtime performance impact on regular reads/writes, but listing many versions adds metadata overhead for management operations.

Use cases:

- Audit trails for data modifications, or append-only/correctable datasets where the ability to revert to prior versions is required.

Recommendations:

- Combine versioning with lifecycle management rules to move old versions to cooler tiers (Cool/Archive) or delete after a retention period.
- For high-change blobs, consider writing new blobs with date-based paths instead of frequently overwriting the same blob to reduce version churn.

---

### Immutable Blob Storage (Time-based retention / Legal hold)

- What it does: immutability policies prevent deletion or modification of blobs for a configured retention period or as part of a legal hold. Useful for regulatory compliance and retention requirements.
- Behaviour: once a retention policy is set (time-based) or a legal hold is placed, blobs cannot be deleted or modified until the retention expires or hold is cleared (legal holds may require special privileges to remove).

Implications:

- Cost: retained data continues to incur storage charges for the duration of the retention period. Since data cannot be deleted, storage growth must be planned carefully.
- Performance: normal read performance is unaffected. Management operations that attempt deletion/overwrite will fail during retention.

Use cases:

- Regulatory retention (finance, healthcare), audit evidence preservation, and legal discovery holds.

Recommendations:

- Use immutable storage only when required by regulation; maintain governance to track policies and retention expirations.
- Consider tiering older immutable data to Archive tier where permitted to reduce costs (note: Archive has different retrieval semantics and costs).

---

### Interactions and lifecycle policies

- Versioning + Soft Delete: both can be enabled; soft delete helps recover accidentally deleted blobs/versions, while versioning provides point-in-time history for overwrites.
- Lifecycle Management: implement lifecycle policies to move older versions or soft-deleted items to Cool/Archive or to delete them after retention — this controls cost growth.

---

### Cost & operational checklist

1. Audit current update/delete patterns for blobs to estimate retention storage needs (versions + soft-deleted objects).
2. Estimate storage growth during retention windows and set monitoring/alerts for used capacity.
3. Create lifecycle policies that move older versions to Cool/Archive and purge beyond compliance retention.
4. Include immutability policy ownership and expiration tracking in governance runbooks.

---

---

## Cost frame of reference: how protection affects storage costs

Use these simple formulas and an illustrative example to estimate the storage cost impact of Soft Delete, Versioning, and Immutable policies for your dataset.

Definitions
- S = active dataset size in GB
- P = storage price per GB-month for your chosen tier (Hot/Cool/Archive) — check Azure pricing for current rates
- C = monthly change fraction (fraction of S overwritten/deleted per month, e.g., 0.10 for 10%)
- R = soft-delete retention in days
- Mv = months you retain versions before lifecycle deletes them
- V = average additional versions created per changed object (often 1)

Formulas (approximate)
- Baseline monthly cost = S * P
- Soft delete extra storage (GB) ≈ S * C * (R / 30)
- Versioning extra storage (GB) ≈ S * C * Mv * V
- Immutable retention overhead = size of data under retention (GB) — cannot be removed for retention horizon

Illustrative example (for quick mental math)
- Assumptions: S = 1024 GB (1 TB), P = $0.02 / GB-month (illustrative — use your region price), C = 0.10 (10% churn/month), R = 30 days, Mv = 3 months, V = 1

| Scenario | Extra storage (GB) | Extra cost / month (USD) | Total cost / month (USD) |
|---|---:|---:|---:|
| Baseline (no protection) | 0 | $0.00 | $20.48 |
| Soft Delete (30 days) | 102.4 | $2.05 | $22.53 |
| Versioning (3 months) | 307.2 | $6.14 | $26.62 |
| Soft Delete + Versioning | 409.6 | $8.19 | $28.67 |
| Immutable archive (additional copy of 1 TB) | 1024 | $20.48 | $40.96 |

Notes:
- The example uses an illustrative unit price. Replace P with the exact price from Azure Storage pricing for Hot/Cool/Archive tiers in your region.
- Soft delete overhead depends on how much data is deleted/overwritten during the retention window (C). If deletion spikes occur (e.g., large ETL deletes), temporary growth may be much higher.
- Versioning overhead depends on how often objects are overwritten and how long you keep versions (Mv). Use lifecycle rules to move versions to Cool/Archive to lower ongoing cost.
- Immutable policies mean data cannot be removed — plan capacity for the entire retention horizon.

Operational cost and performance implications
- Lifecycle transitions: moving data between tiers may trigger operation charges and rehydration costs (Archive -> Hot has retrieval costs and latency). See Azure pricing docs.
- Restore operations: recovering soft-deleted blobs or versions reads data and may increase I/O/egress costs during restore periods.
- Metadata/management: listing versions and managing immutability policies increases management API calls; factor in operation costs for high-volume management workflows.

Practical steps to calculate for your environment
1. Measure S (used GB) and estimate monthly churn C (use pipeline logs or object creation metrics).
2. Choose retention settings (R, Mv, immutability horizon) according to recovery/compliance needs.
3. Use the formulas above to estimate extra GB and multiply by your region tier price P.
4. Add operation/rehydration costs from the Azure Storage pricing page for a complete estimate.

Azure pricing reference (check current rates)
- Azure Storage pricing (Blobs): https://learn.microsoft.com/en-us/azure/storage/blobs/storage-pricing-blobs


## Common use cases and recommended protection settings

| Use case | Recommended protection | Rationale & best practices |
|---|---|---|
| SQL backups (database backups, .bak / dump files) | Soft Delete (14–30 days) + Lifecycle to Archive | Backups are immutable artifacts; use soft delete to recover accidental deletes during restore windows and move older backups to Archive to reduce cost. Consider storing a separate immutable set for compliance retention if required. |
| ETL interchange files (raw extracts, staging files) | Soft Delete (7–14 days) or Versioning with lifecycle | ETL files are often transient; short soft-delete windows protect against accidental deletion during pipeline runs. Use versioning if you overwrite files frequently and need point-in-time recovery. Clean up with lifecycle policies. |
| App logs / telemetry | Versioning (optional) + Lifecycle to Cool/Archive | Logs can generate many small files — avoid versioning churn for high-frequency logs. Prefer rolling file names (date-based) and apply lifecycle rules to move to Cool/Archive quickly (e.g., after 7 days). For compliance logs, use immutable storage as required. |
| Data lake raw zone | Versioning + Lifecycle | Raw data often benefits from versioning for auditability; combine with lifecycle to move older versions to cheaper tiers and enforce retention for compliance. Avoid frequent overwrites by using partitioned object paths. |
| Critical compliance archives | Immutable Blob Storage (time-based retention / legal hold) | Use immutability for records that must not be altered or deleted for regulatory reasons. Track policy expirations and plan capacity for the retention horizon. |


---

## Quick create (Azure CLI)

```powershell
az storage account create -n mystorageacct -g MyRG -l eastus --sku Standard_RAGRS --kind StorageV2
az storage container create -n data --account-name mystorageacct
```

---

Include: `../../../_footer.md`
Return to [Data Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)

---

## Practical CLI and policy examples

Note: Blob Versioning is an account-level feature — it cannot be enabled/disabled per container. If you want different behavior for backups vs other workloads, use dedicated storage accounts or containers and manage versioning at the account scope.

1) Disable blob versioning (account-wide) using Azure CLI

```powershell
# Disable versioning for a storage account
az storage blob service-properties update --account-name mystorageacct --enable-versioning false

# Re-enable if needed
az storage blob service-properties update --account-name mystorageacct --enable-versioning true
```

2) Example lifecycle policy JSON to purge old versions and tier older blobs

Save this as `policy.json` and apply with the CLI shown after the JSON. The rule below:
- deletes blob versions older than 30 days,
- moves base blobs to Cool after 7 days and to Archive after 30 days,
- deletes base blobs older than 365 days.

```json
{
	"policy": {
		"rules": [
			{
				"enabled": true,
				"name": "purge-old-versions-and-tier",
				"type": "Lifecycle",
				"definition": {
					"actions": {
						"version": {
							"delete": {
								"daysAfterCreationGreaterThan": 30
							}
						},
						"baseBlob": {
							"tierToCool": {
								"daysAfterModificationGreaterThan": 7
							},
							"tierToArchive": {
								"daysAfterModificationGreaterThan": 30
							},
							"delete": {
								"daysAfterModificationGreaterThan": 365
							}
						}
					},
					"filters": {
						"blobTypes": ["blockBlob"]
					}
				}
			}
		]
	}
}
```

Apply the policy with Azure CLI:

```powershell
az storage account management-policy create --account-name mystorageacct -g MyRG --policy @policy.json
```

3) ARM template snippet for the same management policy (resource type `Microsoft.Storage/storageAccounts/managementPolicies`)

```json
{
	"type": "Microsoft.Storage/storageAccounts/managementPolicies",
	"apiVersion": "2021-04-01",
	"name": "[concat(parameters('storageAccountName'), '/default')]",
	"properties": {
		"policy": {
			"rules": [
				{
					"enabled": true,
					"name": "purge-old-versions-and-tier",
					"type": "Lifecycle",
					"definition": {
						"actions": {
							"version": { "delete": { "daysAfterCreationGreaterThan": 30 } },
							"baseBlob": {
								"tierToCool": { "daysAfterModificationGreaterThan": 7 },
								"tierToArchive": { "daysAfterModificationGreaterThan": 30 },
								"delete": { "daysAfterModificationGreaterThan": 365 }
							}
						},
						"filters": { "blobTypes": ["blockBlob"] }
					}
				}
			]
		}
	}
}
```

Notes and caution
- Test lifecycle policies in a non-production account first; incorrect rules can delete data permanently.
- Applying policy changes can take time to become effective across large accounts.
- Combine account-level versioning settings and lifecycle rules carefully; lifecycle rules are the recommended way to control version retention and cost.

