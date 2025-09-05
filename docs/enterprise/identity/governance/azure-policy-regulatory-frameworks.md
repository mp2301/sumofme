---
Last Reviewed: 2025-09-04
Tags: 
---

# Enforcing Regulatory Frameworks with Azure Policy

Azure Policy is a governance tool that enables you to create, assign, and manage policies to enforce organizational standards and regulatory requirements across your Azure environment. It helps ensure resources are compliant with frameworks such as HIPAA, SOC 2, PCI DSS, and more.

## What is Azure Policy?
- Azure Policy evaluates resources for compliance with assigned policies.
- Policies can restrict resource types, enforce naming conventions, require tags, control locations, and more.
- Initiatives are collections of policies grouped to address specific compliance or regulatory needs.

## Common Regulatory Frameworks Supported
- HIPAA
- SOC 2
- PCI DSS
- ISO 27001
- NIST SP 800-53

## How to Use Azure Policy for Compliance
1. **Browse Built-In Policies and Initiatives**
   - Azure provides built-in policy definitions for many regulatory frameworks.
   - Go to Azure Portal > Policy > Definitions > Type: Built-in.
2. **Assign Policies/Initiatives to Scope**
   - Assign to subscriptions, resource groups, or management groups.
   - Example: Assign the "HIPAA HITRUST" initiative to a production subscription.
3. **Remediate Non-Compliant Resources**
   - Use policy remediation tasks to bring resources into compliance automatically.
4. **Monitor Compliance**
   - View compliance state in the Azure Policy dashboard.
   - Export reports for audits and regulatory reviews.

## Example: Assigning a Regulatory Initiative
```powershell
# Assign the built-in HIPAA HITRUST initiative to a subscription
New-AzPolicyAssignment -Name "HIPAA-HITRUST" -Scope "/subscriptions/<subscriptionId>" -PolicyDefinitionId "/providers/Microsoft.Authorization/policySetDefinitions/hipaa-hitrust"
```

## Best Practices
- Use management groups to enforce policies across multiple subscriptions.
- Regularly review and update policy assignments as regulations change.
- Integrate policy compliance checks into CI/CD pipelines.
- Document all policy assignments and remediation actions for audit purposes.

## References
- [Azure Policy documentation](https://learn.microsoft.com/en-us/azure/governance/policy/)
- [Built-in policy definitions](https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies)
- [Azure compliance offerings](https://learn.microsoft.com/en-us/azure/compliance/)

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
