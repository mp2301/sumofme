---
Last Reviewed: 2025-09-04
Tags: data-lake, adls, analytics
---
# Data Lake (ADLS Gen2 patterns)

Guidance for designing analytic storage using Azure Data Lake Storage Gen2 (hierarchical namespace on Blob Storage) and patterns for ingestion, governance, and compute.

## Table of contents

- [When to use](#when-to-use)
- [Key considerations](#key-considerations)
- [Ingestion patterns](#ingestion-patterns)
- [Troubleshooting patterns](#troubleshooting-patterns)

## When to use

- Large-scale analytics and big data workloads, where hierarchical namespace, POSIX-like semantics, and high-throughput are required.

## Key considerations

- Storage account with hierarchical namespace (HNS) enabled.
- Partitioning strategy and folder layout to optimize reads and compaction for Spark/Databricks.
- Access control: use RBAC + ACLs (POSIX-style) on ADLS Gen2; prefer service principal or managed identity for compute access.
- Lifecycle and retention: use lifecycle policies to move older data to archive and manage costs.

## Ingestion patterns

This section gives practical ingestion patterns, when to use each, and short examples you can apply.

### 1) Batch ingestion (bulk loads)

- Best for: periodic ingest of files (daily/weekly), bulk backfills, and moving large datasets from on-prem or other clouds.
- Typical tools: Azure Data Factory (ADF) / Synapse Pipelines, AzCopy, Storage Transfer Service, Databricks for heavy ETL.
- File formats: land raw files as compressed Parquet/CSV/JSON and convert to Parquet/Delta during transformation for analytics.

Examples:

- AzCopy (simple bulk copy from on-prem or a file share to ADLS Gen2):

```powershell
azcopy copy 'C:\data\exports\' 'https://mystorage.dfs.core.windows.net/raw/myapp/' --recursive
```

- ADF Copy activity (high-level): create a pipeline with a Copy Activity from an on-premises Self-hosted Integration Runtime or Blob Storage source to an ADLS Gen2 sink. Use staging for transformation if needed.

Use case: nightly ingestion of transactional exports from OLTP systems into /raw/yyyy/mm/dd/ folders; follow with Databricks jobs to normalize into /curated/.

Best practices:

- Use partitioning keys (date, customer, region) in folder layout to make partition pruning effective.
- Avoid many small files — write larger, columnar files (e.g., Parquet) and compact small files during downstream processing.

### 2) Streaming ingestion (near real-time)

- Best for: telemetry, clickstreams, IoT, or low-latency analytics where data must be available within seconds to minutes.
- Typical tools: Event Hubs, IoT Hub, Kafka (Confluent), Azure Stream Analytics, Databricks Autoloader or Structured Streaming.

Patterns:

- Ingest events into Event Hubs -> land raw JSON/avro into ADLS Gen2 (via consumer apps or Azure Functions) or
- Event Hubs -> Databricks Structured Streaming / Autoloader -> write parquet/delta to ADLS with micro-batches.

Example (Databricks Autoloader schematic):

1. Stream from Event Hubs using Autoloader or Structured Streaming.
2. Parse events, perform minimal enrichment, then write to a Delta table partitioned by event date.

Key tips:

- Choose an appropriate micro-batch trigger interval to balance latency and file size.
- Use Delta Lake or Parquet with compaction to reduce small files and enable ACID semantics (if you need updates/deletes).

### 3) Change Data Capture (CDC) / incremental ingest

- Best for: replicating transactional data from databases to the lake with minimal latency and lower volume than full extracts.
- Typical tools: ADF with CDC patterns, Azure Data Factory Mapping Data Flows, Debezium (CDC) -> Event Hubs -> Databricks or Synapse.

Patterns & example:

- SQL Server / Azure SQL Database: enable CDC and stream changes into Event Hubs (via Debezium or custom capture), then persist to ADLS as change files or apply to delta tables.
- ADF Mapping Data Flow/Copy: use watermark columns (last-modified) or native CDC connectors to copy only changed rows.

Use case: maintain near-real-time dimensional tables in the lakehouse without full reloads.

### 4) Orchestration & hybrid pipelines

- Orchestration tools: ADF/Synapse Pipelines for CI-like orchestration, Databricks Jobs for heavy transformation, and Azure Logic Apps / Functions for event-driven pieces.

Example pipeline:

1. ADF pipeline triggers nightly extract (Copy Activity) to /raw/.
2. ADF triggers a Databricks job to transform raw files to Delta and write to /curated/ with partitioning and compaction.
3. ADF triggers post-processing jobs (statistics, register table in the metastore, data quality checks).

### 5) File formats, schema, and partitioning

- Prefer columnar formats (Parquet/Delta) for analytics: better compression and query performance.
- Use Delta Lake (or equivalent) when you need transactional guarantees, time travel, and easier merge/upsert operations.
- Partitioning strategy: pick a small number of high-cardinality columns carefully; too many small partitions hurt performance.

### 6) Performance & cost optimizations

- Batch size and file size: aim for file sizes between 64MB and 512MB for efficient reads (tune based on query patterns).
- Use server-side copy (ADF/Copy Activity) to avoid egress charges or intermediate compute when moving between Azure storage accounts.
- Enable compression and column pruning where possible to reduce egress and storage costs.

### 7) Security, governance & lineage

- Use service principals / managed identities for ingestion jobs to avoid key sprawl.
- Use ADLS ACLs + RBAC and Private Endpoints to limit data plane access.
- Record lineage and provenance in a metadata store (e.g., Azure Purview or a lightweight catalog) to track data sources and transformations.

### 8) Troubleshooting patterns

- Monitor pipeline run histories and use retries with exponential backoff for transient failures.
- For streaming, check Event Hubs metrics (throttling, capture errors) and Databricks streaming job metrics (watermark delay, input/output rate).

---
Include: `../../../_footer.md`
Return to [Data Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
