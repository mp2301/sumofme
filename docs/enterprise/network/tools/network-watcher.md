---
Last Reviewed: 2025-09-04
Tags: tools, azure, monitoring, network
---
# Network Watcher & Diagnostic Tooling

Short notes on using Azure Network Watcher, diagnostic tools, and recommended log retention.

## Capabilities
- IP flow verify
- Connection troubleshoot
- Packet capture (for limited durations)
- NSG flow logging and next-hop diagnostics

## Recommendations
- Enable NSG flow logs to a Log Analytics workspace with 30-90 day retention depending on compliance.
- Use packet capture for short troubleshooting windows (do not enable long-running captures in production).
- Automate connection troubleshooting captures via runbooks to avoid ad-hoc permissions escalation.

Return to [Network Index](../_index.md)

---
Include: `../../../_footer.md`
Return to [Network Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
