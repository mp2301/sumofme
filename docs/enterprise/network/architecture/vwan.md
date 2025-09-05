---
Last Reviewed: 2025-09-04
Tags: vwan, architecture
---
# Virtual WAN (vWAN)

Virtual WAN (vWAN) is a managed transit service that provides a global, scalable backbone for connecting branch sites, VPN/ExpressRoute gateways, and Azure Virtual Networks with simplified management.
---
Last Reviewed: 2025-09-04
Tags: vwan, architecture, hub-and-spoke
---
# Virtual WAN (vWAN)

Virtual WAN provides a managed global transit network for connecting branch sites, VPN gateways, and virtual networks.

## Patterns
- Hub-and-spoke for global transit
- Managed VPN termination at regional hubs

## Why use vWAN?

- Scale and global reach: vWAN abstracts the complexity of connecting many regions and branch sites with a managed Microsoft backbone and regional hubs.
- Operational simplicity: centralized configuration for VPN and ExpressRoute, with simplified hub provisioning and connectivity policies.
- Performance consistency: Microsoft-managed global backbone can reduce hop count and improve performance for inter-region transit.
- Integration: native integration with Azure Firewall Manager, Secure Hub constructs, and branch connectivity (SD-WAN partners).

## What is a Secure Hub?

- A Secure Hub is a vWAN hub configuration that combines the vWAN transit with integrated security services (typically Azure Firewall or partner NVA) and centralized policy management via Firewall Manager.
- Purpose: provide an inspection/segmentation point for traffic that traverses the transit network — for example, inspect branch-to-spoke or spoke-to-internet traffic at the hub before allowing egress.
- Implementation notes:
  - Use Azure Firewall Manager to associate the hub with firewall policies and security configurations.
  - Deploy hub firewall in a secured subnet within the vWAN hub; use routing policies to steer traffic into the firewall.

## vWAN-managed Firewall vs standalone Azure Firewall

1. Management model
	- vWAN-managed Firewall: deployed and managed as part of the vWAN hub lifecycle and integrated with Azure Firewall Manager. Management is optimized for the vWAN context (simplified deployment, policy association across hubs).
	- Standalone Azure Firewall: deployed into a hub VNet you manage directly. Offers the same core firewall capabilities but you manage the VNet, routes, and scaling boundaries.

2. Deployment and scale
	- vWAN-managed Firewall: provisioning and scaling are aligned with the vWAN service expectations; Microsoft may control placement and scale orchestration to suit global transit.
	- Standalone Firewall: you control the VNet placement, SKUs, and scale settings (THRU and rules). Provides flexibility but requires more operational effort.

3. Integration and features
	- Both support core Azure Firewall features (DNAT, SNAT, FQDN filtering, TLS inspection depending on SKU/features). However, vWAN-managed Firewall is tightly integrated with vWAN routing/peering and Firewall Manager for policy distribution.
	- Standalone Firewall may be preferred if you need fine-grained control over network layout, custom UDRs, or hybrid routing scenarios.

4. Routing model
	- vWAN routes and policies are handled within the vWAN construct; when using vWAN-managed Firewall, some routing and next-hop handling is abstracted.
	- With standalone Firewalls you author UDRs to steer traffic and must manage potential hairpin/NAT interactions.

5. Use cases
	- vWAN-managed Firewall is ideal for enterprises that want a managed global transit with integrated security and lower operational overhead.
	- Standalone Azure Firewall is ideal when you need full control of the hub VNet, custom NVA mixes, or specific deployment topologies.

## Tradeoffs & guidance

- Choose vWAN when you need global transit with minimal wiring and integrated partner connectivity (SD-WAN) and you prefer Microsoft-managed hub lifecycle.
- Choose standalone hub + Azure Firewall when you require precise control over VNet layout, have complex hybrid routing, or must deploy partner NVAs in specific ways.
- Cost: vWAN introduces additional service costs (hub and data processing); evaluate data processing costs for transit vs standalone hub egress models.

## Practical checklist for adoption

1. Inventory: list regions, spokes, branch sites, and expected throughput.
2. Decide on inspection model: per-spoke NAT vs hub inspection.
3. Choose firewall model: vWAN-managed if you want integrated policy and lower ops; standalone if you want full control.
4. Plan routing: UDRs or vWAN route tables to steer traffic correctly and avoid loops.
5. Test: deploy a pilot hub in one region, validate routing and failover, and measure latency and throughput.


---
Return to [Network Index](../_index.md) | [Egress Architecture](egress-architecture.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
