---
Last Reviewed: 2025-09-04
Tags: azure-front-door, waf, application-delivery
---
# Azure Front Door

Azure Front Door (AFD) is Microsoft’s global, scalable entry point for web applications that provides global HTTP(S) load balancing, TLS termination, Web Application Firewall (WAF), and edge caching.

## Typical use cases

- Global web app front door with latency-based routing and regional failover.
- TLS termination and WAF protection at edge for web applications and APIs.
- Static site hosting with CDN-like caching and direct-to-edge content delivery.
- API gateway patterns with backend routing and path-based rules.

## Key features

- Global anycast frontend with TLS termination
- URL-based routing, rewrite, and header transforms
- Web Application Firewall (managed rules and custom rules)
- Caching and compression at the edge
- Health probes and regional failover

## When to choose Front Door vs Application Gateway vs CDN

- Front Door: best for global HTTP(S) delivery, multi-region failover, and edge WAF.
- Application Gateway: used for regional L7 load balancing with VNet integration (when you need private backend connectivity and WAF close to VNet).
- CDN: use for static content caching; Front Door includes CDN-like caching plus routing and WAF.

## Basic deployment guidance

1. Decide on frontend hostnames (use your custom domain and managed certificates or bring-your-own cert).
2. Create Front Door profile and define backend pools (App Service, VMs behind public IP, Storage static websites, etc.).
3. Configure routing rules and health probes.
4. Attach WAF policy for security and enable managed rulesets.

### Example (Azure CLI) - create a simple Front Door with a backend pool

```powershell
# Create Front Door Standard/Premium profile
az network front-door create -g MyRG -n MyFrontDoor --sku Standard_AzureFrontDoor

# Add backend pool and routing (conceptual; use az network front-door backend-pool/route commands or ARM templates)
```

## WAF and security notes

- Use managed rule sets as a baseline and add custom rules for IP allow/deny or rate limiting.
- Monitor WAF logs and tune rules to reduce false positives.

## Monitoring and observability

- Enable diagnostic logs for Front Door (WAF logs, metrics) and send to Log Analytics or Event Hub.
- Monitor latency, cache hit ratio, and backend health for failover decisions.

## Cost considerations

- Front Door pricing includes charges for routing rules, data processed, and WAF policies (depending on SKU). Evaluate traffic patterns and caching to optimize cost.

---
Return to [Network Index](../_index.md) | [vWAN](vwan.md) | [Egress Architecture](egress-architecture.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
