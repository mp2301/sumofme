Last Reviewed: 2025-09-04
Tags: data, index, overview
---
## Data Platform Documentation

Azure data platform building blocks: storage (Blob, ADLS Gen2), databases & warehousing (Azure SQL, Snowflake), analytics & ML compute (Databricks, distributed & managed compute), and secure enterprise file transfer patterns.

Use this index to jump to detailed guidance for planning, deploying, securing, operating, and integrating core data services.

### Storage & Data Foundation
- [Azure Storage](azure-storage.md) – Core blob/object storage options, redundancy, encryption, lifecycle management.
- [Data Lake (ADLS Gen2 patterns)](data-lake.md) – Hierarchical namespace, zone design (landing/raw/refined), naming & ACL strategy.

### Data Services & Warehousing
- [Azure SQL (PaaS)](azure-sql.md) – Managed relational workloads (OLTP/operational analytics), sizing & HA/DR guidance.
- [Snowflake (cloud data warehouse)](snowflake.md) – Elastic compute clusters, governed analytics, data sharing & cost controls.

### Compute & Processing
- [Compute for data & ML](compute.md) – Selecting batch, streaming, and ML execution platforms; comparison of serverless vs cluster options.
- [Databricks](databricks.md) – Lakehouse (Delta), collaborative notebooks, streaming pipelines, ML/feature engineering patterns.

### Integration & Transfer
- [Enterprise File Transfer (EFT)](eft.md) – Secure managed file ingress/egress patterns (SFTP replacement, auditing, automation).

---
Include: `../../_footer.md`

---
Return to [Enterprise](../_index.md) | [Root README](../../README.md)
