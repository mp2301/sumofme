---
Last Reviewed: 2025-09-04
Tags: adr, template
---
Title: Adopt Event-Driven Telemetry Bus

Status: accepted

Context
- We need a scalable event backbone for telemetry ingestion across apps. Current direct writes to the warehouse cause contention and coupling.

Decision
- Adopt a managed, event-streaming message bus as the telemetry backbone.

Options considered
- Kafka on managed service (pros: ecosystem; cons: ops overhead)
- Azure Event Hubs / AWS Kinesis (pros: managed; cons: vendor lock-in) — Chosen

Consequences
- Define schema/contract for telemetry events; publish ingestion adapters; update consumers to subscribe.

Related
- Superseded by ADR 2025-09-05-refine-telemetry-bus-partition-strategy for partitioning specifics

