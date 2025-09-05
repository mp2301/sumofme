# Glossary

Common terms and acronyms used across the Directory Services and Cloud Network wikis.

> Pattern: Keep definitions concise (1–3 sentences). Add links to authoritative docs where helpful.

## Identity & Directory
- **AD (Active Directory)**: Microsoft on-premises directory service for authentication, authorization, and policy.
- **Entra ID (Azure AD)**: Microsoft's cloud-based identity and access management platform.
- **Object**: Any directory entry (user, group, computer, OU, service principal).
- **SID (Security Identifier)**: Unique immutable identifier for a security principal in Windows AD.
- **UPN (User Principal Name)**: Internet-style login name (user@domain) for an identity.
- **SPN (Service Principal Name)**: Identifier Kerberos uses to associate a service instance with a logon account.
- **PIM (Privileged Identity Management)**: Just-in-time role and privilege elevation system in Entra ID.
- **SCIM**: Open standard for automated user provisioning across systems.
- **OIDC (OpenID Connect)**: Identity layer on top of OAuth 2.0 for authentication.
- **SAML**: XML-based authentication and authorization federation standard.

## Security & Governance
- **RBAC**: Role-Based Access Control defining permissions via assigned roles.
- **JIT (Just-in-Time Access)**: Temporary privileged access granted for a limited time.
- **Least Privilege**: Principle of granting only the minimum access required.
- **Break Glass Account**: Highly protected emergency access account exempt from normal controls.
- **Conditional Access**: Policy engine in Entra ID for access decisions based on context.

## Networking
- **VNet (Virtual Network)**: Azure software-defined private network boundary.
- **Subnet**: Logical partition of a VNet with its own address range and policies.
- **NSG (Network Security Group)**: Stateful filtering construct for subnets or NICs.
- **ASG (Application Security Group)**: Dynamic grouping for simplifying NSG rules.
- **vWAN (Virtual WAN)**: Microsoft-managed global transit networking service.
- **Private Endpoint**: Private IP interface into a PaaS service via Private Link.
- **Service Endpoint**: VNet extension allowing secure access to Azure service public endpoints over backbone.
- **Private DNS Zone**: DNS zone for internal name resolution inside Azure VNets.
- **DNS Resolver (Azure Private Resolver)**: Managed inbound/outbound DNS forwarding service.
- **ExpressRoute**: Private dedicated connectivity to Microsoft cloud.
- **NAT Gateway**: Managed outbound internet source NAT service for a subnet.
- **SNAT**: Source Network Address Translation (rewriting source IP for outbound traffic).

## Operations & Observability
- **Runbook**: Prescribed procedural document for operating or remediating a system condition.
- **Health Probe**: Mechanism used by load balancers/firewalls to test endpoint availability.
- **Flow Logs**: NSG or firewall logs documenting allowed/denied traffic tuples.

## Automation & Infrastructure as Code
- **IaC**: Infrastructure as Code – declarative provisioning via templates/modules.
- **Terraform**: Multi-cloud IaC tool using HCL language.
- **Bicep**: Azure-native declarative language for ARM deployments.
- **Pipeline**: Automated sequence (CI/CD) executing build/test/deploy steps.

## Authentication Protocols
- **Kerberos**: Ticket-based authentication protocol for mutual authentication in AD.
- **NTLM**: Legacy challenge/response authentication protocol (minimize/disable where possible).
- **OAuth 2.0**: Authorization framework enabling delegated access.

## Risk & Compliance
- **Attestation**: Formal periodic review of access or configuration state.
- **RTO (Recovery Time Objective)**: Target time to restore service after disruption.
- **RPO (Recovery Point Objective)**: Maximum acceptable data loss interval.

## Miscellaneous
- **Forest**: Security boundary grouping one or more AD domains.
- **Domain**: Administrative/security partition within a forest.
- **OU (Organizational Unit)**: Container for delegation and policy scoping.
- **Tenant**: Logical boundary for an Entra ID directory instance.

---
Maintenance: When adding a term, keep alphabetical ordering within a section if practical. If a new category is needed, add it above Miscellaneous.
