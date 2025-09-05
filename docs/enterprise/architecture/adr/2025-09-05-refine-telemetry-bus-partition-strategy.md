---
Last Reviewed: 2025-09-04
Tags: adr, template
---
Title: Refine Telemetry Bus Partition Strategy

Status: proposed

Supersedes: 2025-09-05-adopt-event-driven-telemetry-bus (partitioning section only)

Context
- Throughput spikes require a clear partitioning key; current guidance is ambiguous causing hotspotting.

Decision
- Use tenantId as primary partition key; cap partitions per namespace; provisioned throughput with auto-inflate.

Options considered
- Partition by deviceId (pros: ordering; cons: hotspot risk)
- Partition by tenantId (balanced) — Chosen

Consequences
- Update producers to compute partition key; revise capacity plan; adjust consumer groups.

