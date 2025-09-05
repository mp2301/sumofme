---
Last Reviewed: 2025-09-04
Tags: 
---


# Azure RBAC: Role-Based Access Control for Developers

Azure Role-Based Access Control (RBAC) lets you manage access to Azure resources by assigning roles to users, groups, and applications. RBAC ensures only authorized identities can perform specific actions on resources such as storage accounts, key vaults, app settings, queues, and service bus.

## Key Concepts
- **Role Definition:** A collection of permissions (actions) that can be performed on Azure resources.
- **Scope:** The set of resources to which access applies (subscription, resource group, or resource).
- **Assignment:** A user, group, or service principal is assigned a role at a specific scope.

## Common Developer Scenarios

### Storage Account Access
- **Reader:** Can view storage account properties and data.
- **Contributor:** Can manage storage account resources but not access keys.
- **Storage Blob Data Contributor:** Can read/write/delete blobs.
- **Storage Blob Data Reader:** Can read blobs only.

### Key Vault Access
- **Key Vault Reader:** Can view key vault properties but not secrets/keys/certificates.
- **Key Vault Secrets User:** Can read secrets.
- **Key Vault Contributor:** Can manage key vaults and all contents.

### App Service & App Settings
- **Website Contributor:** Can manage web apps but not publish code.
- **App Configuration Data Reader:** Can read app configuration data.
- **App Configuration Data Owner:** Can manage app configuration data.

### Storage Queues & Service Bus Access
- **Storage Queue Data Contributor:** Can manage messages in Azure Storage queues.
- **Storage Queue Data Reader:** Can read messages in queues.
- **Service Bus Data Sender:** Can send messages to Service Bus queues/topics.
- **Service Bus Data Receiver:** Can receive messages from Service Bus queues/topics.
- **Service Bus Data Owner:** Full control over Service Bus resources.

## Assigning Roles
1. Go to the Azure Portal and navigate to the resource (e.g., storage account, key vault).
2. Click on "Access control (IAM)".
3. Click "Add role assignment".
4. Select the appropriate role and assign it to a user, group, or service principal.

## Best Practices
- Assign roles at the lowest scope needed (resource > resource group > subscription).
- Use built-in roles when possible; create custom roles only if necessary.
- Regularly review role assignments for least privilege.
- Use managed identities for applications to avoid storing credentials.

## Environment-Based RBAC: Increasing Restriction in Higher Environments
Access to Azure resources should become more restrictive as you move from development to production environments.

- **Development:** Broader access for developers to experiment and troubleshoot.
- **Test/Staging:** Moderate access, with more controls and monitoring (treat like production if it holds customer data).
- **Production:** Least privilege; only essential personnel with just-in-time (PIM) elevation.

**Best Practices:**
- Separate subscriptions/resource groups per environment.
- Assign roles at lowest viable scope; review regularly.
- Require PIM activation with approval + justification for production.
- Monitor activations and audit higher environments continuously.

## Storage Queues & Service Bus Access
 [Azure Storage Queue roles](https://learn.microsoft.com/en-us/azure/storage/queues/storage-queues-introduction)
## Managing RBAC & PIM with Infrastructure as Code (IaC)
Codify role assignments and (where possible) PIM settings to ensure consistency, peer review, and traceability.

- ARM/Bicep/Terraform for role assignments.
- Graph / API automation for PIM (activation settings, notifications).
- Embed security reviews in CI/CD.

## References
- [Azure RBAC Overview](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)
- [Built-in roles for Azure resources](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Assign Azure roles using the portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
- [Manage Azure RBAC with ARM templates](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-template)
- [Azure RBAC security best practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/identity-management-best-practices)
- [Automate PIM (Graph overview - search)](https://learn.microsoft.com/en-us/search/?q=privileged%20identity%20management%20graph)
- [Automate PIM (Privileged Identity Management docs)](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/)
- [Azure PIM for RBAC roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-roles)
- [Azure Storage Queue roles](https://learn.microsoft.com/en-us/azure/storage/queues/storage-queues-introduction)
- [Azure Service Bus roles](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-role-based-access-control)

<!-- Removed duplicated second half content to normalize document -->

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
