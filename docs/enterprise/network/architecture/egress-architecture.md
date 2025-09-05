---
Last Reviewed: 2025-09-04
Tags: egress, architecture, nat, snat
---
# Egress Architecture
Design patterns and prescriptive guidance for outbound (egress) internet access from Azure resources — SNAT, NAT, centralized inspection, forced tunneling, and recommendations per workload (VMs, AKS, App Service, PaaS).

## Goals / contract

- Inputs: Azure workloads located in spokes (VMs, AKS nodes, App Service with VNet Integration, PaaS services), hub networking (Firewall/NVA or NAT), and service endpoints/private endpoints.
- Outputs: predictable outbound IPs (for allowlisting), optional centralized inspection (IDS/IPS, proxy), minimal SNAT port exhaustion risk, telemetry for egress flows.
- Error modes: SNAT port exhaustion, incorrect UDRs causing blackholes, inadvertent public egress for private-data workloads, broken health/metadata access when forced tunneling is used.

## High-level patterns

- Centralized egress (Hub-and-spoke)
	- All outbound internet flows are routed to a hub where an Azure Firewall or NVA provides stateful inspection, logging, and DNAT/SNAT.
	- Pros: single place for policy, easy allowlisting, strong inspection, consolidated logging.
	- Cons: single-hop bottleneck, additional latency/cost, requires scale planning (SNAT/throughput).

- Distributed egress (Spoke-level NAT)
	- Each spoke uses a NAT Gateway (recommended) or a Standard Load Balancer with outbound IPs to provide stable outbound IPs without hairpinning to a hub.
	- Pros: lower latency, simpler scaling, cheaper for high-volume egress.
	- Cons: harder to inspect traffic centrally; require per-spoke allowlisting.

- Hybrid
	- Use NAT Gateways for predictable SNAT and route specific traffic to hub for inspection (proxy/VPN). Useful where most traffic doesn't need inspection.

## Azure building blocks and guidance

- NAT Gateway (recommended for SNAT)
	- Use NAT Gateway for stable outbound IPs per subnet and to avoid SNAT port exhaustion associated with Basic Load Balancer-based outbound.
	- Attach an Azure Public IP or Public IP Prefix to a NAT Gateway for predictable ranges.

- Azure Firewall
	- Use when you need centralized inspection, fully-managed rules, Threat Intelligence, and FQDN filtering.
	- Azure Firewall performs SNAT when it forwards outbound traffic; budget for firewall throughput and scaling.

- User‑Defined Routes (UDR)
	- Route 0.0.0.0/0 (or specific prefixes) from spokes to the hub private IP of the firewall or NVA when central inspection or forced tunneling is required.

- Private Link / Private Endpoint
	- Prefer Private Endpoint for PaaS services (Azure SQL, Storage, KeyVault) to avoid public egress entirely.

- Service Tags
	- Use service tags in NSG/Firewall rules to simplify allowlisting for Microsoft-managed services; combine with application-layer rules where needed.

- App Service with VNet Integration
	- When App Service outbound IPs must be stable or traffic must egress from a specific IP range, use VNet Integration into a subnet with NAT Gateway.

- AKS
	- For AKS clusters that require predictable egress, deploy a NAT Gateway on the node subnet or use a routed approach via a hub firewall. For cluster autoscaling, plan SNAT port capacity and consider cluster-level egress solutions (egress gateway sidecars/proxies) if fine-grained control is needed.

## Recommended decision checklist

1. Do you need centralized inspection/monitoring? -> Yes: hub + Azure Firewall/NVA. No: prefer NAT Gateway in each spoke.
2. Do you need a small set of predictable outbound IPs? -> Use NAT Gateway with assigned Public IP(s) or Public IP Prefix.
3. Do you need to avoid public internet for PaaS? -> Use Private Endpoints / Private Link.
4. Are you worried about SNAT port exhaustion (e.g., many ephemeral connections)? -> Use NAT Gateway with multiple public IPs / prefixes or move to centralized egress with Azure Firewall and scale accordingly.

## Implementation notes and examples

- Simple spoke NAT (recommended for most apps)

	1. Create a NAT Gateway and attach it to the subnet used by your workload.
	2. Assign one or more Public IP(s) or a Public IP Prefix to the NAT Gateway.

	Example (Azure CLI):

	```powershell
	# Create Public IP
	az network public-ip create -g MyRG -n MyNATPIP --sku Standard --allocation-method Static

	# Create NAT Gateway
	az network nat gateway create -g MyRG -n MyNat --public-ip-addresses MyNATPIP --idle-timeout 10

	# Associate with subnet
	az network vnet subnet update -g MyRG --vnet-name MyVnet -n MySubnet --nat-gateway MyNat
	```

- Centralized hub (inspection) with Azure Firewall

	1. Deploy a hub VNet with Azure Firewall and a firewall public IP.
	2. Configure UDR in each spoke to route outbound via the firewall private IP.
	3. Optionally pair with NAT Gateway for predictable SNAT when you don't want SNAT performed by firewall.

	Example UDR (conceptual):

	```text
	Address prefix: 0.0.0.0/0
	Next hop: Virtual Appliance
	Next hop IP: <AzureFirewallPrivateIP>
	```

	Notes: when routing 0.0.0.0/0 to a virtual appliance, ensure system traffic (Azure Service Tags, health probes) is not unintentionally blocked; add exceptions or firewall rules as needed.

## Monitoring, logging, and diagnostics

- Enable NSG Flow Logs for spoke subnets for low-level flow telemetry (written to a Storage Account / Log Analytics via Diagnostic Settings).
- Enable Azure Firewall logging and send to Log Analytics for analytics/alerts and to retain FQDN and network rule logs.
- For NAT Gateway, enable diagnostic settings to record metrics and logs to monitor SNAT usage and health.
- Use Azure Monitor alerts on high SNAT utilization, firewall CPU/throughput, and NSG flow anomalies.

## Cost and scale considerations

- NAT Gateway has per-hour and per-data processed costs; Public IP Prefixes carry a charge. Azure Firewall is billed for throughput and number of rules.
- Centralized inspection (Azure Firewall or NVA) simplifies policy but increases egress data processing and firewall SKU costs; evaluate bandwidth and per-GB charges.

## Edge cases and gotchas

- Forced tunneling: if you route 0.0.0.0/0 to on-prem, remember Azure platform traffic (update endpoints, health, DNS) may be affected—use split-tunnel or exceptions.
- SNAT port exhaustion: workloads that open many outbound connections (e.g., large-scale application testing) can exhaust SNAT ports; mitigate with multiple public IPs or NAT Gateway.
- App Service and Functions: they may still use platform-managed outbound IPs unless VNet Integration + NAT Gateway or ASE is used.

## Quick recommendations

- Default: use NAT Gateway per spoke for predictable SNAT and low-latency egress.
- If you must inspect or proxy all traffic: use hub + Azure Firewall (or NVA) and add scaling/HA capacity.
- For PaaS: prefer Private Endpoint to eliminate public egress.

---
Return to [Network Index](../_index.md) | [vWAN](vwan.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
