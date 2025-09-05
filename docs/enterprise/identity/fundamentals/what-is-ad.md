---
Last Reviewed: 2025-09-04
Tags: active-directory, fundamentals, architecture
---
# What is Windows Active Directory?

Windows Active Directory (AD) is a directory service developed by Microsoft for Windows domain networks. It provides centralized authentication, authorization, and management of users, computers, and other resources within an organization. AD is essential for enforcing security policies, managing access, and supporting enterprise IT operations.

> **Note:** DNS is integral to Active Directory. AD relies on DNS for locating domain controllers, enabling authentication, and supporting replication. Proper DNS configuration is critical for AD health and functionality.

## Domain Controller Infrastructure

Domain controllers (DCs) are servers that host Active Directory services. They:
- Store and replicate the AD database across the network
- Authenticate users and computers
- Enforce security policies
- Provide high availability and fault tolerance through replication

A typical AD environment includes multiple domain controllers to ensure redundancy and load balancing. DCs can be located at different sites to support distributed organizations, and their health is critical for the overall stability of the AD infrastructure.

## FSMO Roles

Flexible Single Master Operations (FSMO) roles are specialized domain controller tasks that are not distributed, but assigned to specific DCs to prevent conflicts and ensure proper AD functioning. There are five FSMO roles:

**Forest-wide roles:**
- Schema Master: Controls changes to the AD schema.
- Domain Naming Master: Manages additions and removals of domains in the forest.

**Domain-wide roles:**
- RID Master: Allocates pools of Relative Identifiers to DCs for object creation.
- PDC Emulator: Provides backward compatibility with older systems, manages password changes, and acts as the authoritative time source.
- Infrastructure Master: Maintains references to objects in other domains.

Proper assignment and monitoring of FSMO roles is crucial for AD health. If a DC holding a FSMO role fails, certain operations may be disrupted until the role is transferred or seized by another DC.

## Replication and Synchronization

Active Directory uses multi-master replication to keep domain controllers synchronized. Changes made on one DC are replicated to others, ensuring consistency across the environment.

- **Replication Types:**
	- Intra-site replication: Fast, frequent replication within the same physical site
	- Inter-site replication: Scheduled, optimized replication between different sites
- **Protocols:**
	- Uses Remote Procedure Call (RPC) over IP for most replication
	- Can use SMTP for some inter-site scenarios (rare)

DNS is also replicated between domain controllers using AD-integrated zones. This ensures:
- All DCs have up-to-date DNS records for domain services
- Secure, fault-tolerant DNS updates and queries

**Best Practices:**
- Monitor replication health with tools like `repadmin` and `dcdiag`
- Ensure proper site and subnet configuration for efficient replication
- Regularly review DNS zone replication status

Proper replication and DNS synchronization are critical for authentication, resource access, and overall AD reliability.

Return to [Identity Index](../_index.md) | [Glossary](../../../shared/glossary.md) | [Root README](../../README.md)

Include: `../../../_footer.md`
