---
Last Reviewed: 2025-09-04
Tags: 
---

# Break Glass Accounts for EntraID and Windows AD

Break glass accounts are emergency access accounts designed to provide administrators with a way to regain control of EntraID (Azure AD) or Windows Active Directory in case of lockout or critical failure.

## EntraID (Azure AD) Break Glass Accounts
- **Purpose:** Ensure access to the tenant if all normal admin accounts are unavailable (e.g., MFA outage, accidental lockout).
- **Best Practices:**
  - Create at least one cloud-only global administrator account
  - Exclude from conditional access and MFA policies (with strong password and monitoring)
  - Store credentials securely (e.g., password vault)
  - Monitor usage and alert on sign-in
  - Regularly review and rotate credentials
- **References:**
  - [Microsoft Guidance: Break Glass Accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-planning#emergency-access-accounts)

## Windows AD Break Glass Accounts
- **Purpose:** Provide emergency access to domain controllers and AD management tools
- **Best Practices:**
  - Create a dedicated domain admin account for break glass
  - Store credentials offline and securely
  - Restrict use to emergencies only
  - Monitor and alert on usage
  - Regularly review and rotate credentials
- **References:**
  - [Microsoft ESAE Guidance](https://learn.microsoft.com/en-us/windows-server/identity/securing-privileged-access/securing-privileged-access-reference-material)

## General Recommendations
- Limit privileges to only what is necessary
- Document procedures for use and recovery
- Test access periodically to ensure functionality
- Audit and review usage after any activation

Break glass accounts are a critical part of identity and access management resilience. Use them only when absolutely necessary and follow best practices to minimize risk.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
