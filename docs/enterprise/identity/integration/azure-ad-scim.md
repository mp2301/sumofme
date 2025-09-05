---
Last Reviewed: 2025-09-04
Tags: 
---

# Using SCIM with Azure AD

Azure Active Directory (EntraID) supports SCIM (System for Cross-domain Identity Management) for automated user provisioning to SaaS applications.

## Overview
- SCIM is an open standard for automating the exchange of user identity information between identity providers and service providers.
- Azure AD acts as the identity provider, provisioning users and groups to applications that support SCIM.

## How SCIM Works with Azure AD
1. **Register the Application in Azure AD**
   - Go to Azure Portal > Azure Active Directory > Enterprise applications > New application
   - Select or create the target application
2. **Configure Provisioning**
   - In the app, go to Provisioning > Automatic
   - Enter the SCIM endpoint URL and secret token provided by the service provider
   - Test connection and save settings
3. **Map Attributes**
   - Configure attribute mappings (e.g., userName, email, groups)
   - Customize as needed for the application
4. **Assign Users and Groups**
   - Assign users/groups to the application for provisioning
5. **Monitor Provisioning**
   - Use the Azure Portal to monitor provisioning logs and status

## Example SCIM Payload
```json
{
  "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
  "userName": "user@domain.com",
  "name": {
    "givenName": "John",
    "familyName": "Doe"
  },
  "emails": [
    { "value": "user@domain.com", "primary": true }
  ]
}
```

## Advanced SCIM Attribute Mapping and Transformations

When provisioning users via SCIM, Azure AD can map and transform attributes to match the target application's requirements.

### Common SCIM Attribute Mappings
- `userName` â†’ UPN or email address
- `name.givenName` â†’ First name
- `name.familyName` â†’ Last name
- `emails` â†’ Primary and secondary email addresses
- `groups` â†’ Group memberships

### Example: Mapping Azure AD Attributes to SCIM
In Azure AD provisioning configuration:
```
Azure AD attribute: userPrincipalName
SCIM attribute: userName

Azure AD attribute: givenName
SCIM attribute: name.givenName

Azure AD attribute: surname
SCIM attribute: name.familyName

Azure AD attribute: mail
SCIM attribute: emails[type eq "work"].value
```

### Example: Custom Attribute Transformation
You can use expressions to transform attributes, e.g.:
```
Azure AD attribute: department
SCIM attribute: customDepartment
Expression: ToUpper([department])
```

### References
- [SCIM Attribute Mapping in Azure AD](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/customize-application-attributes)
- [Azure AD SCIM Provisioning Documentation](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/use-scim-to-provision-users-and-groups)
- [SCIM Protocol Overview](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/user-provisioning#what-is-scim)

---

For troubleshooting and advanced configuration, see the Microsoft documentation linked above.
---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
