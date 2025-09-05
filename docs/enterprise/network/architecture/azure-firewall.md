---
Last Reviewed: 2025-09-04
Tags: azure-firewall, firewall, network, security
---
# Azure Firewall

Guidance for deploying Azure Firewall, routing traffic to it, VNet placement, and common use cases.

## Overview

Azure Firewall is a managed, stateful network security service that provides inbound/outbound filtering, FQDN and application rules, DNAT/SNAT, and integration with Azure Monitor and Firewall Manager.

Key capabilities:
- DNAT and SNAT
- Network and application rule collections
- Threat intelligence and FQDN filtering
- Integration with Azure Firewall Manager and Policy

## Where to place the firewall

- Deploy Azure Firewall into a dedicated subnet named `AzureFirewallSubnet` in a hub VNet. The subnet name is required.
- For vWAN architectures, use the vWAN-managed firewall or place a standalone Azure Firewall in the hub VNet and use route tables or vWAN route tables to steer traffic.

## How to route traffic to Azure Firewall

- User-Defined Routes (UDRs):
  - Create UDRs on spoke subnets with next hop set to `Virtual appliance` or the firewall private IP to steer 0.0.0.0/0 or specific prefixes to the firewall.
  - Example UDR:

    Address prefix: 0.0.0.0/0
    Next hop: Virtual Appliance
    Next hop IP: <AzureFirewallPrivateIP>

- vWAN integration:
  - When using vWAN-managed firewall, route tables and next-hops are handled by vWAN and Firewall Manager; associate firewall policies via Firewall Manager.

- Forced tunneling / on-prem inspection:
  - To forward internet-bound traffic to on-prem for inspection, route spoke 0.0.0.0/0 to the firewall and configure the firewall to tunnel to your on-prem VPN/ExpressRoute.

## SNAT, DNAT, and scaling considerations

- SNAT: Azure Firewall performs SNAT for outbound flows; if you require many concurrent outbound connections, plan for scale and consider NAT Gateway for per-subnet SNAT instead.
- DNAT: Use DNAT rules on Azure Firewall to publish internal services to the internet with controlled exposure.
- Scaling: choose the appropriate SKU and monitor throughput; use autoscale where appropriate and monitor metrics in Azure Monitor.

## Primary use cases

- Centralized egress inspection and policy enforcement for spokes
- Publishing internal services (DNAT) with WAF or application-layer inspection upstream
- Threat detection and blocking using Threat Intelligence
- Policy distribution across multiple hubs using Azure Firewall Manager

## Deployment checklist (quick)

1. Create a hub VNet and subnet `AzureFirewallSubnet`.
2. Deploy Azure Firewall and allocate Public IP(s).
3. Create Firewall Policy and rule collections (network/app/DNAT).
4. Configure UDRs in spokes to route required traffic to firewall private IP.
5. Enable diagnostic settings to send logs to Log Analytics/Storage/Event Hub.
6. Test connectivity and failover scenarios.

## Example: create a basic firewall and UDR (Azure CLI)

```powershell
# Create firewall public IP
az network public-ip create -g MyRG -n MyFwPIP --sku Standard --allocation-method Static

# Deploy Azure Firewall
az network firewall create -g MyRG -n MyFirewall --vnet-name MyHubVnet

# Create a firewall policy (skeleton)
az network firewall policy create -g MyRG -n MyFwPolicy

# Create a UDR in a spoke to route internet traffic to the firewall
az network route-table create -g MyRG -n SpokeRouteTable
az network route-table route create -g MyRG --route-table-name SpokeRouteTable -n DefaultRoute --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address <AzureFirewallPrivateIP>
az network vnet subnet update -g MyRG --vnet-name SpokeVnet -n SpokeSubnet --route-table SpokeRouteTable
```

## Monitoring and diagnostics

- Enable Azure Firewall diagnostics to Log Analytics (network rule log, application rule log, threat intel alerts).
- Monitor metrics: throughput, SNAT utilization, CPU.

## Cost considerations

- Azure Firewall has base and data processing charges; estimate data egress and inspection costs. Using NAT Gateway for high-volume SNAT can be more cost-effective for pure egress scenarios.

---
Return to [Network Index](../_index.md) | [vWAN](vwan.md) | [Egress Architecture](egress-architecture.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
