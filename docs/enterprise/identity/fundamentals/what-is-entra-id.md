---
Last Reviewed: 2025-09-04
Tags: fundamentals, entra, overview
---

# What is Entra ID (Azure Active Directory)?

Entra ID (formerly Azure Active Directory, Azure AD) is Microsoft's cloud-based identity and access management service. It provides authentication, authorization, and directory services for users, devices, and applications in the cloud and hybrid environments.

## Key Features of Entra ID
- Single sign-on (SSO) for cloud and on-premises apps
- Multi-factor authentication (MFA)
- Conditional access policies
- Self-service password reset
- Device registration and management
- Application provisioning and lifecycle management
- Integration with Microsoft 365, Azure, and thousands of SaaS apps

## How is Entra ID Different from Windows Active Directory?
- **Windows Active Directory (AD):**
  - On-premises directory service
  - Manages users, computers, groups, and resources within a network
  - Uses Kerberos and NTLM authentication
  - Relies on domain controllers and organizational units
- **Entra ID (Azure AD):**
  - Cloud-based identity platform
  - Manages users, devices, and applications for cloud and hybrid environments
  - Uses modern authentication protocols (OAuth, OIDC, SAML)
  - No domain controllers or OUs; uses tenants and app registrations
  - Designed for internet-scale, SaaS, and mobile scenarios

## Common Misconceptions
- Entra ID is **not** a cloud version of Windows AD; it is a separate service with different architecture and capabilities.
- Entra ID does **not** support traditional AD features like group policy, LDAP, or trusts.
- Hybrid identity is possible using Azure AD Connect, but the directories remain distinct.

## References

## Capturing and Querying Entra ID Sign-In Logs

Entra ID (Azure AD) provides detailed sign-in logs that help monitor authentication activity, detect anomalies, and investigate security incidents.

### How to Access Sign-In Logs
- Go to the Azure Portal > Entra ID (Azure Active Directory) > Monitoring > Sign-in logs.
- You can view interactive dashboards, filter by user, application, status, location, and more.

### Exporting Logs
- Logs can be exported to Azure Monitor, Log Analytics, or SIEM solutions for advanced analysis.
- To automate exports, configure diagnostic settings to send logs to a Log Analytics workspace or storage account.

### Querying for Interesting Activity
Use Kusto Query Language (KQL) in Log Analytics to find suspicious or notable sign-ins. Example queries:

**Find failed sign-ins:**
```kql
SigninLogs
| where ResultType != 0
| project UserPrincipalName, AppDisplayName, Location, ResultType, FailureReason, TimeGenerated
```

**Find sign-ins from unfamiliar locations:**
```kql
SigninLogs
| where Location != "YourExpectedLocation"
| project UserPrincipalName, Location, AppDisplayName, TimeGenerated
```

**Find sign-ins with risky detections:**
```kql
SigninLogs
| where RiskLevelDuringSignIn != "none"
| project UserPrincipalName, RiskLevelDuringSignIn, AppDisplayName, TimeGenerated
```

### References
- [View and analyze sign-in logs in Entra ID](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/overview-monitoring-health)
- [KQL reference for Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/log-query/query-language)
- [What is Microsoft Entra? (fundamentals)](https://learn.microsoft.com/en-us/entra/fundamentals/what-is-entra)
- [Compare Active Directory to Microsoft Entra](https://learn.microsoft.com/en-us/entra/fundamentals/compare)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
