---
Last Reviewed: 2025-09-04
Tags: overview, azure, networking
---
# Cloud Network Wiki

This wiki covers key concepts and practical solutions for building and managing cloud networks in Azure. Topics include virtual networks (VNets), peering, Virtual WAN (vWAN), DNS (private and public), network security groups (NSGs), Azure Firewall, VPN solutions, and modern alternatives like Tailscale.

... (content preserved)
---
Last Reviewed: 2025-09-04
Tags: overview, azure, networking, documentation
---
# Cloud Network Wiki

This wiki covers key concepts and practical solutions for building and managing cloud networks in Azure. Topics include virtual networks (VNets), peering, Virtual WAN (vWAN), DNS (private and public), network security groups (NSGs), Azure Firewall, VPN solutions, and modern alternatives like Tailscale.

## Table of Contents

### Core Concepts
- [Azure Virtual Network (VNet)](vnets.md): Overview and fundamentals of VNets
- [VNet Peering](vnet-peering.md): Connecting VNets for seamless communication
- [Azure Virtual WAN (vWAN)](../architecture/vwan.md): Global transit network architecture
- [IP Address Management](../governance/ip-address-management.md): Options and best practices for managing IPs in cloud networks
- [Private DNS in Azure](../dns/private-dns.md): Internal name resolution for cloud resources
- [Private DNS Resolver](../dns/private-dns-resolver.md): Azure's managed resolver for private DNS queries
- [Public DNS in Azure](../dns/public-dns.md): Managing public DNS zones and records

### Security & Connectivity
- [Network Security Groups (NSGs)](../security/nsgs.md): Traffic filtering and segmentation
- [Azure Firewall](../security/azure-firewall.md): Centralized network protection and logging
- [Azure VPN Gateway](../integration/azure-vpn.md): Secure site-to-site and point-to-site connectivity
- [Tailscale](../tools/tailscale.md): Modern VPN replacement for secure mesh networking
- [WireGuard](../tools/wireguard.md): VPN protocol for secure hybrid and multi-cloud connectivity
- [Private Endpoints and Service Endpoints](../architecture/private-endpoints-and-service-endpoints.md): Secure access to Azure services using private networking

### Monitoring & Operations
- [Network Watcher](../tools/network-watcher.md): Monitoring, diagnostics, and insights for Azure networks
- [Egress Architectures](../architecture/egress-architecture.md): Outbound traffic management, SNAT exhaustion, and controlled internet access

---

Explore: [Monitoring & Detection](../monitoring/network-identity-monitoring.md) | [Hardening Baseline](../hardening/cloud-network-hardening.md) | [Runbooks](../runbooks/runbooks-cloud-network.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
