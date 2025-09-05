---
Last Reviewed: 2025-09-04
Tags: 
---

# Cross-Tenant Collaboration Settings in Azure AD

Azure Active Directory (EntraID) supports secure cross-tenant collaboration, enabling organizations to work together while maintaining control over their own resources.

## Overview
- Cross-tenant collaboration allows users from different Azure AD tenants to access shared resources securely.
- Common scenarios include B2B (business-to-business) sharing, guest access, and federated applications.

## Key Settings and Features
1. **External Collaboration Settings**
   - Control who can invite guests and manage external access
   - Configure restrictions on guest permissions and access
   - Azure Portal: Azure AD > External Identities > External collaboration settings
2. **Cross-Tenant Access Settings**
   - Define inbound and outbound access policies for specific tenants
   - Set trust settings for multi-factor authentication, device compliance, and user attributes
   - Azure Portal: Azure AD > External Identities > Cross-tenant access settings
3. **B2B Direct Connect**
   - Enable direct collaboration with another tenant without guest accounts
   - Configure trust and access policies for seamless resource sharing
4. **Conditional Access Policies**
   - Apply policies to external users for security and compliance
   - Require MFA, device compliance, or other controls for cross-tenant access

## Example: Configuring Cross-Tenant Access
1. Go to Azure Portal > Azure AD > External Identities > Cross-tenant access settings
2. Add the target tenant and configure inbound/outbound policies
3. Set trust settings for MFA and device compliance
4. Save and test access with a user from the external tenant

## References
- [Cross-Tenant Access Settings Documentation](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-overview)
- [B2B Collaboration Documentation](https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b)
- [Conditional Access for External Users (search)](https://learn.microsoft.com/en-us/search/?q=conditional%20access%20external%20users)

---

For advanced scenarios and troubleshooting, see the Microsoft documentation linked above.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
