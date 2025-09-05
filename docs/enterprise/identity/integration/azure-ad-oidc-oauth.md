---
Last Reviewed: 2025-09-04
Tags: 
---

# Using OIDC and OAuth with Azure AD

Modern applications can use OpenID Connect (OIDC) and OAuth 2.0 protocols to authenticate and authorize users via Azure Active Directory (EntraID).

## Overview
- **OIDC**: An identity layer on top of OAuth 2.0, used for authentication.
- **OAuth 2.0**: Used for delegated authorization, allowing apps to access resources on behalf of users.
- Azure AD acts as an identity provider, issuing tokens for apps and APIs.

## How Apps Use OIDC and OAuth with Azure AD

1. **Register the Application in Azure AD**
    - Go to Azure Portal > Azure Active Directory > App registrations > New registration
    - Enter a name, select supported account types, and set redirect URI (e.g., `https://localhost:3000/auth/callback`)
    - After registration, note the Application (client) ID and Directory (tenant) ID
    - Example using Azure CLI:
       ```powershell
       az ad app create --display-name "MyApp" --redirect-uris "https://localhost:3000/auth/callback"
       az ad app list --display-name "MyApp"
       az ad app credential reset --id <appId>
       ```

2. **Configure Permissions**
    - In Azure Portal, go to your app > API permissions > Add a permission
    - Select Microsoft Graph or other APIs, and choose delegated or application permissions
    - Example using Azure CLI:
       ```powershell
       az ad app permission add --id <appId> --api <apiId> --api-permissions <permissionId>=Scope
       az ad app permission grant --id <appId> --api <apiId>
       ```

3. **Implement Authentication in the App**
    - Use MSAL libraries (e.g., `msal.js` for JavaScript, `msal` for Python)
    - Example (Node.js with Express and msal-node):
       ```javascript
       const { ConfidentialClientApplication } = require('@azure/msal-node');

       const config = {
          auth: {
             clientId: "<clientId>",
             authority: "https://login.microsoftonline.com/<tenantId>",
             clientSecret: "<clientSecret>"
          }
       };

       const cca = new ConfidentialClientApplication(config);

       // Get auth URL
       const authUrl = cca.getAuthCodeUrl({
          scopes: ["openid", "profile", "User.Read"],
          redirectUri: "https://localhost:3000/auth/callback"
       });

       // Exchange code for token
       const tokenResponse = await cca.acquireTokenByCode({
          code: req.query.code,
          scopes: ["openid", "profile", "User.Read"],
          redirectUri: "https://localhost:3000/auth/callback"
       });
       ```

4. **Validate and Use Tokens**
    - Decode and validate ID/access tokens using libraries (e.g., `jsonwebtoken` for Node.js)
    - Example:
       ```javascript
       const jwt = require('jsonwebtoken');
       const decoded = jwt.decode(tokenResponse.idToken);
       // Validate claims, issuer, audience, etc.
       ```
    - Use access tokens to call Microsoft Graph or other APIs:
       ```javascript
       const fetch = require('node-fetch');
       const response = await fetch('https://graph.microsoft.com/v1.0/me', {
          headers: { Authorization: `Bearer ${tokenResponse.accessToken}` }
       });
       const data = await response.json();
       ```

## References
- [Microsoft Identity Platform Documentation](https://learn.microsoft.com/en-us/entra/identity-platform/)
- [OIDC and OAuth 2.0 Overview](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow)
- [MSAL Libraries](https://learn.microsoft.com/en-us/entra/identity-platform/msal-overview)

## Example Use Cases
- Single sign-on for web and mobile apps
- Secure API access with delegated permissions
- Multi-tenant SaaS applications

For step-by-step guides and code samples, see the Microsoft documentation linked above.


---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
