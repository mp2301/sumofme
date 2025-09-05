---
Last Reviewed: 2025-09-04
Tags: 
---

# DNS and Azure Private Resolver

DNS is fundamental to Active Directory, enabling domain controller location and resource access. In environments with many untrusted domains, Azure Private Resolver can be used to securely resolve DNS queries across networks:

Integrating Azure Private Resolver helps maintain reliable name resolution and security in complex AD deployments.

## Example: Three AD Forests and One VPN Client

Suppose you have three separate AD forests (ForestA, ForestB, ForestC) and a remote client connecting via VPN. You want secure DNS resolution between forests and for the client, without exposing all domains to each other.

### Steps to Set Up Azure Private Resolver

1. **Deploy Azure Private DNS Resolver**
   - Create a Private DNS Resolver in a dedicated Azure VNet.
   - Ensure the VNet can route to all three forests (via VPN, ExpressRoute, or peering).

2. **Configure DNS Forwarding Rulesets**
   - Create rulesets for each forest:
     - Forward queries for `forestA.local` to ForestA domain controllers.
     - Forward queries for `forestB.local` to ForestB domain controllers.
     - Forward queries for `forestC.local` to ForestC domain controllers.
   - Use conditional forwarding to direct only relevant queries to each forest.

3. **Integrate with VPN Client**
   - Configure the VPN gateway to use the Azure Private DNS Resolver IP as its DNS server.
   - When the client connects, DNS queries for any forest domain are forwarded securely via Azure.

4. **Security and Isolation**
   - Only allow necessary DNS traffic between forests.
   - Use network security groups (NSGs) and firewall rules to restrict access.
   - Monitor DNS logs for unusual activity.

### Example Topology

```
VPN Client
   |
VPN Gateway
   |
Azure VNet (with Private DNS Resolver)
   |         |         |
ForestA   ForestB   ForestC
```

This content has moved to [Cloud Network/Azure Private DNS Resolver](../../Cloud Network/private-dns-resolver.md).

This setup allows the VPN client to resolve names in any forest, while keeping forests isolated from each other except for DNS queries as defined by forwarding rules.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
