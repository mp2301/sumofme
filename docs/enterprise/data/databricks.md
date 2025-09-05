---
Last Reviewed: 2025-09-04
Tags: databricks, spark, analytics
---
# Databricks

Guidance for using Azure Databricks as the analytics compute plane against ADLS Gen2 or other data stores.

## Table of contents

- [When to use](#when-to-use)
- [Key considerations (deep dive)](#key-considerations-deep-dive)
- [Reference architectures](#reference-architectures)
	- [Batch / Medallion ETL](#batch--medallion-etl)
	- [Unified Streaming + Batch](#unified-streaming--batch)
	- [Machine Learning Platform](#machine-learning-platform)
	- [Multi-Region DR & Resilience](#multi-region-dr--resilience)
	- [Secure Multi-Tenant / Domain Isolation](#secure-multi-tenant--domain-isolation)
- [References](#references)

## When to use

- Data engineering, machine learning, and interactive analytics workloads that require managed Spark with collaborative notebooks and operational pipelines.

## Key considerations
Inline bracket numbers map to References. Content reorganized for scan speed: skim the At‑a‑Glance table, then dive into categories as needed.

### At a Glance
| Category | Focus | Top Controls |
|----------|-------|--------------|
| Networking & Security | Eliminate public exposure; controlled egress | VNet injection + Private Link; NSGs; deny outbound except allowlist [1][2] |
| Identity & Governance | Least privilege data & compute access | Unity Catalog RBAC; SCIM groups; cluster policies [3][4][5] |
| Data Architecture | Reliable zone progression & performance | Medallion layering; Delta OPTIMIZE/VACUUM; quality gates [6][7][8] |
| Ingestion & Streaming | Consistent incremental loads | Autoloader; Structured Streaming checkpoints; MERGE patterns [10][11] |
| Cost & Operations | Reduce idle & over-spec | Jobs clusters; autotermination; spot mix; tagging & DBU monitoring [5][9] |
| ML & Advanced Analytics | Reproducible models & features | MLflow tracking/registry; Feature Store; lineage & approval workflow [16][17] |
| Resilience & DR | Fast recovery & auditability | Delta time travel; storage replication; checkpointed streams [6][10] |

### 1. Networking & Workspace Isolation [1][2]
Use VNet‑injected workspaces so traffic is inspectable. Add Private Link (front & back end) to remove public ingress/egress. Restrict outbound (firewall / UDR) to required Azure service tags (Storage, Event Hubs, Key Vault, Log / Metrics). Separate transit / user access from compute where possible.

Key practices:
- Dedicated subnets (host/container) sized for cluster scale; avoid IP exhaustion.
- Enforce no public network access when both Private Link modes enabled.
- Stable egress IP for allow‑listing external SaaS.

### 2. Identity & Access Control [3][4][5]
Centralize identities in Entra ID with SCIM group sync. Apply cluster policies to constrain runtime versions, node types, autotermination, libraries. Prefer service principals + short‑lived tokens over user PATs. Rotate secrets automatically.

### 3. Data Governance & Medallion Zones [4][6][7]
Bronze (raw append) → Silver (validated & conformed) → Gold (curated / serving). Apply schema & data quality expectations before promotion. Capture lineage (Unity Catalog system tables / Purview). Tag sensitive datasets; implement environment isolation via workspace‑catalog bindings where required.

### 4. Performance Optimization [6][8]
Right‑size autoscaling (tight min, moderate max). Use instance pools to reduce spin‑up. For table layout: predictive optimization or scheduled OPTIMIZE + VACUUM respecting retention (compliance & time travel). Apply ZORDER (or prefer liquid clustering when available) for selective predicates. Broadcast small dims; cache hot reference data. Monitor small file counts → trigger compaction.

### 5. Cost Management [5][9]
Treat idle time as waste: aggressive autotermination on interactive (≤15 min). Prefer ephemeral Jobs clusters; avoid oversized all‑purpose clusters. Mix spot with on‑demand for fault‑tolerant ETL (configure max spot %) and monitor preemption. Tag clusters (env, domain, cost-center); alert on DBU or storage anomalies.

### 6. Storage & Access Patterns [7][10]
Use direct ABFS URIs for ADLS Gen2 (simpler ACL/audit) rather than mounts where possible. Partition by frequently filtered, bounded cardinality columns (e.g., event_date). Avoid “Hive style” over‑partitioning leading to tiny files. Use Autoloader (cloudFiles) for incremental discovery + schema evolution; quarantine bad records.

### 7. Streaming & Incremental Ingestion [10][11]
Structured Streaming with checkpoint & exactly‑once sinks (Delta). Idempotent upserts (MERGE INTO) for CDC / late data. Use watermarks to bound state and manage late arrival. Expose latency & input rate metrics; alert if SLA thresholds breached.

### 8. Secrets & Key Management [2][12]
Key Vault‑backed secret scopes only; restrict scope creation. No secrets in notebooks or job parameters. Classify & optionally client‑side encrypt highly sensitive fields before landing in Bronze. Rotate keys automatically; document break‑glass procedure.

### 9. Observability & Audit [9][13]
Enable audit & billable usage logs → Log Analytics / storage archive. Dashboards: pipeline success %, mean duration, cost per run, cluster utilization, small file growth. Collect Spark metrics (Prometheus/Ganglia). Anomaly detection for cost spikes & throughput drops.

### 10. DevOps & CI/CD Promotion [14][15]
Git (Repos) as source of truth. IaC (Terraform/Bicep) for workspace, policies, secret scope definitions. Package code as wheels; use automated tests (unit + data quality) pre‑deploy. Parameterize jobs across dev/test/prod; enforce promotions via PR + tag.

### 11. Multi‑Workspace Strategy [3][4]
Minimize sprawl: create new workspaces only for strong isolation drivers (regulatory boundary, blast radius). Standardize catalog naming and policy baselines. Keep consistent cluster policies & logging across all workspaces.

### 12. Machine Learning Lifecycle [16][17]
MLflow for experiment tracking (params, metrics, artifacts). Feature Store for point‑in‑time correct features. Enforce model registry stage transitions with approval & automated validation (drift, bias checks). Use separate serving / training clusters; automate batch & streaming inference pipelines.

### 13. Resilience & Disaster Recovery [6][10]
Define RPO/RTO per zone. Use Delta time travel + version retention policies; snapshot critical tables (export manifests) if stricter requirements. Geo‑replicate storage (GRS) or replicate selected datasets; script metadata export (Unity Catalog objects & permissions) for rapid rebuild. Maintain runbooks for failover & streaming resume.

### 14. Security Hardening [1][2][5]
Disallow arbitrary internet downloads (restrict init scripts). Limit cluster creation to admins + controlled policy set. Enforce private networking for control & data planes. Periodic permission recertification (jobs, notebooks, models). Supply chain scan custom libraries.

### 15. Governance & Access Reviews [3][4][5]
Quarterly automated diff: Unity Catalog privileges, cluster policy JSON, secret scope ACLs, model registry permissions. Store intended baseline in source control; generate report + remediation issues.

### Quick Checklist
| Item | Status |
|------|--------|
| VNet injection & Private Link configured |  |
| Cluster policies (size/runtime/autotermination) enforced |  |
| Unity Catalog RBAC least privilege verified |  |
| Autoloader for high‑volume ingestion |  |
| Delta OPTIMIZE + VACUUM schedule defined |  |
| Jobs clusters (ephemeral) over long‑running all‑purpose |  |
| Audit & usage logs exported + monitored |  |
| Key Vault secret scopes only; no inline secrets |  |
| MLflow registry gated promotions (tests, approvals) |  |
| DR runbook & RPO/RTO documented |  |

### Common Pitfalls & Anti‑Patterns
- Oversized always‑on interactive clusters → runaway cost.
- Excessive tiny Delta files (no compaction) → degraded query latency.
- Mounts with broad permissions → weak auditability.
- Unbounded streaming state (missing watermark) → memory pressure.
- Inconsistent catalog naming across workspaces → governance drift.

### Adoption Roadmap (Sample)
1. Foundations: VNet injection, Private Link, logging, SCIM.
2. Governance: Unity Catalog rollout, cluster policies, secret scopes.
3. Data Architecture: Medallion refactor, quality expectations, Autoloader.
4. Optimization: Delta layout tuning, cost dashboards, predictive optimization.
5. ML Enablement: Feature Store, MLflow registry automation.
6. Resilience: DR drills, metadata export scripts, streaming recovery tests.

## Reference architectures
The following reference patterns illustrate common deployments. Adjust sizing, zones, and tool selection to your org’s scale and compliance requirements.

### Batch / Medallion ETL
Flow: ADLS Gen2 (landing/raw/Bronze) → Databricks Jobs (Autoloader or batch) → Silver (cleansed, conformed) → Gold (curated, aggregated) → Serving (Power BI via Direct Lake / Import, Synapse Serverless, or external warehouse). Key elements:
- Bronze: Append-only, minimal transformations; schema evolution allowed.
- Silver: Data quality rules (expectations), standardized types, surrogate keys.
- Gold: Dimensional models, aggregated fact tables for BI and ML feature extraction.
Controls: Cluster policies restrict instance sizes; quality checks fail fast & raise alerts; cost tagging per zone. [6][7][10]

### Unified Streaming & Batch
Flow: Event Hubs / Kafka → Structured Streaming (Autoloader or direct EH source) → Bronze Delta (raw events) → Streaming transformations with watermarking → Silver Delta (enriched) → Gold (aggregated / near-real-time metrics) + Batch Backfill Jobs for late data.
Key Concepts: Checkpoint directories for exactly-once semantics; incremental MERGE for dimension updates; Delta change feed for downstream incremental consumers. [10][11]

### Machine Learning Platform
Flow: Bronze/Silver curated feature sources → Feature engineering notebooks/jobs → Feature Store (Delta tables with point-in-time correctness) → Experiment tracking (MLflow) → Model training jobs (on ephemeral clusters) → Model Registry (staging) → CI tests (bias/perf) → Promotion to Production → Batch/Streaming serving (Model Serving endpoints or job-based batch scoring writing predictions back to Gold/Serving layer).
Controls: Reproducibility (dataset version + code commit hash + env spec), model lineage (MLflow), governance on who can transition model stages. [16][17]

### Multi-Region DR & Resilience
Primary region hosts workspace + ADLS Gen2 (GRS). Delta tables replicated via storage replication (for geo) + optional periodic snapshot export of critical tables. Unity Catalog metadata (if supported) exported (backup scripts) or recreated via IaC. In failover: deploy standby workspace template, attach to secondary storage endpoint, replay job definitions (exported JSON) and restart streaming with existing checkpoints if replicated. [6][10]

### Secure Multi-Tenant / Domain Isolation
Pattern: One workspace per high-trust boundary OR single workspace with Unity Catalog providing logical isolation (catalogs per domain). Use cluster policies to prevent cross-domain data exfiltration (disable external IPs, restrict instance profiles). Private Link for data plane; secret scopes only accessible to domain-specific groups. Tag clusters/jobs with domain for chargeback. [3][4][5]

## References
1. Databricks Networking (VNet injection, private access) – https://learn.microsoft.com/azure/databricks/administration-guide/cloud-configurations/azure/vnet-inject
2. Azure Private Link for Databricks – https://learn.microsoft.com/azure/databricks/administration-guide/cloud-configurations/azure/private-link
3. Unity Catalog Overview – https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/
4. Unity Catalog Privileges & Access Control – https://learn.microsoft.com/azure/databricks/data-governance/unity-catalog/manage-privileges
5. Cluster Policies – https://learn.microsoft.com/azure/databricks/administration-guide/clusters/policies
6. Delta Lake Overview – https://docs.delta.io/latest/delta-intro.html
7. Medallion Architecture / Lakehouse – https://learn.microsoft.com/azure/databricks/lakehouse/medallion
8. Delta Optimization (ZORDER / OPTIMIZE) – https://learn.microsoft.com/azure/databricks/delta/optimize
9. Cost Optimization (DBUs & autoscaling) – https://learn.microsoft.com/azure/databricks/administration-guide/account-settings/usage
10. Autoloader / Incremental Ingestion – https://learn.microsoft.com/azure/databricks/ingestion/auto-loader/
11. Structured Streaming Guide – https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html
12. Secrets & Key Vault Scopes – https://learn.microsoft.com/azure/databricks/security/secrets/secret-scopes#--azure-key-vault-backed-scopes
13. Audit & Diagnostic Logs – https://learn.microsoft.com/azure/databricks/administration-guide/account-settings/billable-usage-log-delivery
14. Repos (Git Integration) – https://learn.microsoft.com/azure/databricks/repos/
15. CI/CD & DevOps (dbx / workflows) – https://learn.microsoft.com/azure/databricks/dev-tools/best-practices
16. MLflow Model Registry – https://learn.microsoft.com/azure/databricks/mlflow/model-registry
17. Feature Store – https://learn.microsoft.com/azure/databricks/machine-learning/feature-store/

---
Include: `../../../_footer.md`
Return to [Data Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
