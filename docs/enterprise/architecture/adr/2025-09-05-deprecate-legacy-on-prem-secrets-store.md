---
Last Reviewed: 2025-09-04
Tags: adr, template
---
Title: Deprecate Legacy On-Prem Secrets Store

Status: deprecated

Context
- Legacy store lacks HSM-backed keys, auditing, and has no OIDC integration.

Decision
- Deprecate and sunset in favor of the accepted cloud-native secrets manager.

Consequences
- Read-only from date X; remove writers; delete after 90 days when 0 consumers.

