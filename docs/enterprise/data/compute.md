---
Last Reviewed: 2025-09-04
Tags: compute, quotas, ml, databricks, synapse
---
# Compute for data & ML

Compact guide to common compute types, quota considerations, and recommended choices for typical machine learning and data operations.

## Table of contents

- [Compute types (summary)](#compute-types-summary)
- [Quotas and common limits](#quotas-and-common-limits)
- [Mapping common use cases to compute choices](#mapping-common-use-cases-to-compute-choices)
- [Autoscaling, spot instances, and cost controls](#autoscaling-spot-instances-and-cost-controls)
- [Best practices](#best-practices)
- [Monitoring and observability](#monitoring-and-observability)
- [Quota exhaustion troubleshooting](#quota-exhaustion-troubleshooting)
- [Quick decision checklist before provisioning](#quick-decision-checklist-before-provisioning)

## Compute types (summary)

| Compute type | Example SKUs / services | Typical use cases | Docs |
|---|---|---|---|
| General-purpose VMs | D-series (Dsv3/Dv4), Standard_D* | Data prep, light model training, app servers | [VM sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes) |
| Memory-optimized | E-series (Standard_E*) | ETL, in-memory analytics, large joins in Spark executors | [VM sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes) |
| Compute-optimized | F-series (Standard_F*) | CPU-bound workloads, streaming ingestion preprocessors | [VM sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes) |
| GPU VMs | NC/ND/NV-series (e.g., Standard_NC6, ND40rs) | Model training (NC/ND), visualization (NV) | [GPU sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-gpu) |
| Managed Spark / Analytics | Azure Databricks (clusters, instance pools), Synapse Spark pools | Large-scale ETL, interactive analytics, ML feature engineering | [Databricks clusters](https://learn.microsoft.com/en-us/azure/databricks/clusters/), [Synapse Spark](https://learn.microsoft.com/en-us/azure/synapse-analytics/spark/apache-spark-overview) |
| Managed ML compute | Azure Machine Learning compute instances & clusters | Experimentation, distributed training, real-time endpoints | [Azure ML compute targets (search)](https://learn.microsoft.com/search?search=azure%20machine%20learning%20compute%20targets) |
| Serverless / cloud warehousing | Snowflake virtual warehouses, Synapse serverless SQL | Ad-hoc SQL, analytics, ELT transformations | [Snowflake Docs](https://docs.snowflake.com/en/), [Synapse SQL](https://learn.microsoft.com/en-us/azure/synapse-analytics/) |


## Quotas and common limits

- Subscription vCPU quota (per region): primary quota affecting how many VMs/GPUs you can run concurrently.
- Specialized GPU quotas: some subscriptions limit the number of GPU SKUs (e.g., NC/ND families).
- Service-specific limits: Databricks cluster node limits, Synapse pool limits, Azure ML compute node limits.
- Soft and hard limits: soft quotas can be increased via Azure Support; hard limits are platform-enforced (tenant/service caps).

### How to check and request increases:

1. In Azure Portal go to Subscriptions → Usage + quotas (or "Help + support" → New support request → Quota) to view regional vCPU usage and request increases.
2. Monitor current usage via Cost Management and Activity logs to spot quota exhaustion before it affects production.

RBAC required to request quota increases
- To create quota/support requests you need permission to create support requests against the subscription. Built-in roles that allow this include:
	- Owner
	- Contributor
	- Support Request Contributor (limited to support operations)
- Role "Reader" cannot create quota requests. If you lack the needed role, ask a subscription Owner to either grant the "Support Request Contributor" role or file the quota request on your behalf.

Check your role via Azure CLI (example)

```powershell
# list role assignments for the current user in the subscription
az role assignment list --assignee <userPrincipalName-or-objectId> --subscription <subscriptionId> --output table
```


Note: assigning roles requires Owner/Privileged permissions; do not attempt role changes unless you have the necessary admin rights.

---

### If you need capacity now (workarounds)

- Deploy to a different region with available capacity.
- Use spot/low-priority VMs for non-critical training to reduce on-demand vCPU needs.
- Reduce cluster sizes, use more frequent job scheduling, or stagger runs to smooth peaks.
- Use managed services with independent quotas (e.g., Snowflake, Azure Databricks pools) that may not count directly against subscription vCPU quotas in the same way.

### More details: what to expect and how to request increases

Types of quotas you will commonly encounter

- Regional vCPU quota: a per-region limit on aggregate vCPUs across VM families. This is the most common quota you'll hit when provisioning many instances.
- GPU quotas: per-GPU family limits (NC/ND/NDv2 etc.). These are often lower and must be requested per family and region.
- Service-specific quotas: Azure Machine Learning, Databricks, Synapse, and other PaaS services have their own node/cluster limits and quotas; check each service's limits documentation.

How to view current usage (quick commands)

```powershell
# View VM family usage in a region
az vm list-usage -l eastus -o table

# Check subscription usage in portal: Subscriptions -> Usage + quotas
```

How to request a quota increase (portal method)

1. In the Azure portal go to Help + support -> New support request.
2. For Issue type pick "Service and subscription limits (quotas)" (or similar for your tenant).
3. Select the subscription, the quota type (vCPU, GPU family, etc.), and the target region.
4. Provide a clear justification and planned timeline (see sample fields below) and submit.

What to include in the support request (be precise)

- Subscription ID and target region (e.g., eastus).
- Exact quota to increase (for example: vCPUs for Standard_Dv4 family -> target: 200 vCPUs) or GPU family (ND-series -> target: 8 GPUs).
- Business justification: short description of workload, expected duration (temporary vs permanent), and impact if not approved (production launch, scheduled training job).
- Planned start date and expected steady-state/peak consumption.
- Contact person and support email/phone for follow-up.
- If available, reference architecture diagrams or runbooks (attach a small doc) to speed approval.

Expected lead times and tips

- Soft quota requests (standard vCPU increases) are often processed within hours to a few business days, but can take longer during high demand.
- GPU or large increases may take longer (several days) because they may require capacity planning or manual validation.
- If this is urgent (production launch), open the support ticket early and mark the business impact clearly; paid support plans may get faster handling.


## Mapping common use cases to compute choices

| Use case | Recommended compute | Notes |
|---|---|---|
| Lightweight experimentation / local dev | [Azure ML compute instances (search)](https://learn.microsoft.com/search?search=azure%20machine%20learning%20compute%20targets) or small [Databricks interactive clusters](https://learn.microsoft.com/en-us/azure/databricks/clusters/) (4–8 vCPU, 16–32 GB) | Use on-demand instances and auto-shutdown to control cost |
| Model training (single GPU) | See [Azure GPU VM sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-gpu) (e.g., NC-series) or a Databricks GPU node | Consider [Spot VMs](https://learn.microsoft.com/en-us/azure/virtual-machines/spot-vms) for cheaper, interruption-tolerant training |
| Large-scale training (multi-GPU) | [ND-series / multi-GPU SKUs](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-gpu) or distributed GPU clusters via [Azure ML compute (search)](https://learn.microsoft.com/search?search=azure%20machine%20learning%20compute%20targets) / Databricks | Plan for quotas, inter-node networking, and distributed training frameworks (Horovod/MPI) |
| Batch ETL and Spark workloads | [Azure Databricks autoscaling clusters](https://learn.microsoft.com/en-us/azure/databricks/clusters/) or [Synapse Spark pools](https://learn.microsoft.com/en-us/azure/synapse-analytics/spark/apache-spark-overview) | Use instance pools and autoscaling; tune executor sizes for memory/core balance |
| Real-time inference | [Azure ML real-time endpoints / compute (search)](https://learn.microsoft.com/search?search=azure%20machine%20learning%20compute%20targets) or [AKS](https://learn.microsoft.com/en-us/azure/aks/) for complex networking (CPU/GPU) | Use autoscale and right-size for latency/throughput; use GPU only when required |
| Data warehouse queries | [Snowflake virtual warehouses](https://docs.snowflake.com/en/) (size per concurrency) or [Azure Synapse dedicated SQL / serverless SQL] (https://learn.microsoft.com/en-us/azure/synapse-analytics/) | Use auto-suspend/resume and multi-cluster warehouses for unpredictable workloads; monitor costs |


## Autoscaling, spot instances, and cost controls

- Autoscale: set sensible min/max nodes, and use cooldown periods to avoid thrashing.
- Spot/low-priority VMs: good for preemptible training or ETL; always checkpoint progress and use mixed pools (spot + on-demand) for resilience.
- Instance pools (Databricks) and node pools (AKS) reduce allocation latency and improve quota utilization.
- Use budgets, alerts, and tags to track and control spending per project.

## Best practices

- Plan quotas during capacity planning: estimate vCPU and GPU needs, request quota increases before production launches.
- Use managed identities for compute to access storage and secrets securely.
- Automate shutdown of non-production compute (compute instances, idle clusters) to avoid wasted costs.
- Prefer managed compute (Azure ML, Databricks) when you want simplified lifecycle management and autoscaling.

## Monitoring and observability

- Collect metrics: CPU/GPU utilization, memory, disk throughput, network I/O, and job success/failure rates.
- Use Azure Monitor / Log Analytics for alerts on high utilization and autoscale events.
- Track per-workspace or per-project cost via Cost Management and instrument deployments with tags.

## Quota exhaustion troubleshooting

- Symptoms: provisioning failures, job queueing, or autoscale inability to reach desired instance count.
- Immediate mitigations: reduce cluster size, use smaller instance SKUs, use spot instances, or shift workloads to other regions.
- Long-term: request quota increases, implement job queueing/priority, or refactor workloads for smaller footprints.

## Quick decision checklist before provisioning

1. Define workload profile (CPU vs GPU, memory, throughput, concurrency).
2. Check regional vCPU and GPU quotas for your subscription.
3. Choose managed compute vs IaaS VM based on lifecycle and operational needs.
4. Set autoscale min/max and configure alerts on usage and cost.
5. Use spot/low-priority where tolerated and ensure checkpointing.

---
Include: `../../../_footer.md`
Return to [Data Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
