---
Last Reviewed: 2025-09-04
Tags: adr, template
---
Title: Select Cloud-Native Secrets Management

Status: accepted

Context
- Secrets sprawl across repos and VMs; inconsistent rotation practices.

Decision
- Use cloud-native secret manager (e.g., Azure Key Vault) with OIDC for GitHub Actions access.

Options considered
- HashiCorp Vault (rich features, more ops)
- Cloud-native (managed, integrated) — Chosen

Consequences
- Migrate existing secrets; establish rotation; remove repo secrets used for prod.

