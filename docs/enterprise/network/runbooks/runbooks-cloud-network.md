---
Last Reviewed: 2025-09-04
Tags: runbook, network, recovery, azure
---
# Cloud Network Runbooks

This collection contains short, actionable runbooks for common cloud network incidents and maintenance tasks.

## Runbooks

- Restore VNet peering after accidental delete
- Recreate Azure Firewall policy from policy-as-code templates
- Recover Private DNS zones from backups
- Rotate shared service endpoints and update consumers

### Example: Restore VNet Peering
1. Identify peering direction and missing link (hub->spoke or spoke->hub).
2. Verify address space overlap and required permissions.
3. Recreate peering using ARM template or az cli with --allow-vnet-access flags.
4. Validate routes and NSG rules.

Return to [Network Index](../_index.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
