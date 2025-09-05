---
Last Reviewed: 2025-09-04
Tags: 
---

# Using SAML with Azure AD

Azure Active Directory (EntraID) supports SAML 2.0 for single sign-on (SSO) to web applications.

## Overview
- SAML (Security Assertion Markup Language) is an XML-based protocol for exchanging authentication and authorization data.
- Azure AD acts as an identity provider (IdP), issuing SAML assertions to service providers (SPs).

## How Apps Use SAML with Azure AD
1. **Register the Application in Azure AD**
   - Go to Azure Portal > Azure Active Directory > Enterprise applications > New application
   - Select "Non-gallery application" or choose from the gallery
2. **Configure SAML Settings**
   - Set Identifier (Entity ID), Reply URL (Assertion Consumer Service), and Sign-on URL
   - Download the IdP metadata XML and provide it to the service provider
3. **Assign Users and Groups**
   - Assign users/groups to the application for access
4. **Test SSO**
   - Use the Test SSO feature in Azure Portal or initiate login from the service provider

## Example SAML Assertion
```xml
<saml:Assertion ...>
  <saml:Subject>
    <saml:NameID>user@domain.com</saml:NameID>
  </saml:Subject>
  <saml:AttributeStatement>
    <saml:Attribute Name="email">
      <saml:AttributeValue>user@domain.com</saml:AttributeValue>
    </saml:Attribute>
  </saml:AttributeStatement>
</saml:Assertion>
```

## References
- [Azure AD SAML SSO Documentation](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/add-application-portal)
- [SAML Protocol Overview](https://learn.microsoft.com/en-us/entra/identity-platform/single-sign-on-saml-protocol)

---

For troubleshooting and advanced configuration, see the Microsoft documentation linked above.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
