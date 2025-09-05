---
Last Reviewed: 2025-09-04
Tags: private-endpoints, service-endpoints, azure
---
# Private Endpoints & Service Endpoints

Secure access to platform services over private networking using Private Endpoints or Service Endpoints.

---
Return to [Network Index](../_index.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)

## Why use private access to platform services

- Security: prevents data from traversing the public internet and reduces the attack surface.
- Access control: combine with NSGs, Private DNS, and RBAC to enforce which resources can reach PaaS endpoints.
- Compliance: simplifies compliance by keeping traffic on private networking paths and enabling better logging and egress control.

## Key differences

- Private Endpoint (Private Link)
	- Maps a private IP from your VNet to a specific resource instance (for example, a single Storage account or SQL instance).
	- Provides true private connectivity to the resource and removes the need for public endpoint access.
	- Pros: per-resource access control, supports Private DNS zones, good for multi-tenant scenarios where you need instance-level isolation.
	- Cons: requires one endpoint per resource (or per instance/region), and there may be limits and quota considerations.

- Service Endpoint
	- Extends your VNet identity to the Azure platform service namespace (for example, storage or SQL) so the platform sees traffic as coming from your VNet.
	- Pros: simpler to configure per-subnet, fewer objects to manage, useful when you want to limit access to a service namespace rather than an instance.
	- Cons: traffic still uses the Azure backbone and the service maintains a public endpoint; doesn't provide an IP in your VNet and lacks instance-level isolation.

## When to choose which

- Use Private Endpoint when:
	- You need instance-level security/isolation.
	- You want all traffic to the service to use private IPs (no public access).
	- You need DNS resolution within the VNet to resolve the service to the private IP.

- Use Service Endpoint when:
	- You want a quick, per-subnet way to restrict a service namespace to your VNet(s).
	- You have many resources and don't want to create a Private Endpoint per resource.

## How to create and use

### Private Endpoint (Private Link) - example (Azure CLI)

1. Ensure the target resource supports Private Link (most PaaS do: Storage, SQL, KeyVault, Event Hubs, etc.).
2. Create or choose a subnet for the private endpoint (note: the subnet will receive the private IP). Do not enable service endpoints on that subnet if you want to avoid routing conflicts.
3. Create the Private Endpoint and optionally approve the connection on the service side.

```powershell
# Create a Private Endpoint for storage
az network private-endpoint create -g MyRG -n MyStoragePE --vnet-name MyVnet --subnet MySubnet --private-connection-resource-id /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<sa> --group-ids blob --connection-name MyStoragePEConn

# Create a Private DNS Zone and link to the VNet
az network private-dns zone create -g MyRG -n "privatelink.blob.core.windows.net"
az network private-dns link vnet create -g MyRG -n MyDNSLink --zone-name "privatelink.blob.core.windows.net" --virtual-network MyVnet --registration-enabled false

# Optionally add A records or let the platform create them via the Private Endpoint
```

Notes:
- When using Private Endpoint, configure Private DNS zones or use your own DNS server to resolve the service name to the private IP.
- Review quotas: private endpoints per subscription/region and per resource limits.

### Service Endpoint - example (Azure CLI)

1. On the subnet where your resources live, enable the service endpoint for the target service (e.g., Microsoft.Storage).
2. On the platform service (storage account), add the VNet/subnet to the allowed networks.

```powershell
# Enable service endpoint on subnet
az network vnet subnet update -g MyRG --vnet-name MyVnet -n MySubnet --service-endpoints Microsoft.Storage

# On the storage account -> Firewalls and virtual networks -> Selected networks -> Add your VNet/subnet
```

Notes:
- Service Endpoints use the Azure backbone for traffic but the service still has a public endpoint. Use with firewall rules on the service resource to restrict to the VNet.

## DNS and connectivity considerations

- Private Endpoint requires DNS override to map the service hostname to the private IP. Use Azure Private DNS zones or custom DNS forwarding.
- If you have both Service Endpoint and Private Endpoint enabled, Private Endpoint has precedence for DNS resolution when configured.

## Security & RBAC

- Private Endpoint connections may require approval by the resource owner (or auto-approval if within the same subscription and owner consent is configured).
- Use network policies and NSGs carefully: NSGs on the subnet hosting Private Endpoints can block access to the endpoint if not configured correctly.

## Monitoring and troubleshooting

- Use network watcher connection troubleshoot for connectivity checks.
- Check Private Endpoint connection state in the portal and resource health; review activity logs for failed connection attempts.

---
Return to [Network Index](../_index.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
