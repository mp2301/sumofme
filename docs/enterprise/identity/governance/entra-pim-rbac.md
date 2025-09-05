---
Last Reviewed: 2025-09-04
Tags: 
---

# Privileged Identity Management (PIM) for RBAC and EntraID Roles

## Key Concepts: Eligibility, Activation, Approvals, and Timeboxing

PIM introduces several important concepts for secure role management:

- **Eligibility:** Users or groups are assigned as "eligible" for a role, meaning they can request activation but do not have standing access.
- **Activation:** Eligible users must activate the role to gain permissions. Activation can be time-limited and requires justification.
- **Approvals:** Role activation can require approval from designated approvers (role owners or administrators). Approvers are notified and must approve the request before access is granted.
- **Timeboxing:** Role activations are limited to a specific duration (e.g., 12 hours). After the timebox expires, access is automatically revoked, reducing risk.

These controls help enforce least privilege, reduce standing access, and provide auditability for privileged operations in EntraID and Azure resources.

## Permanently Assigned Roles

While PIM is designed to minimize standing privilege, some roles may be permanently assigned ("active" rather than "eligible") when continuous access is required.

**When Permanent Assignment is Appropriate:**
- Service accounts or automation requiring uninterrupted access
- Break-glass accounts for emergency access (should be tightly controlled and monitored)
- Roles for critical infrastructure management where just-in-time access is not feasible

**Best Practices:**
- Limit permanent assignments to the minimum necessary
- Monitor and audit usage of permanently assigned roles
- Regularly review assignments and remove unnecessary standing access
- Use strong authentication and conditional access policies for these accounts

For most users and administrators, prefer eligible assignments with PIM activation and timeboxing to reduce risk.

Microsoft Entra Privileged Identity Management (PIM) enables just-in-time, timeboxed, and approval-based access to Azure AD (EntraID) roles and resources using role-based access control (RBAC).

## Overview
- PIM allows users to activate roles only when needed, reducing standing privilege risk.
- Roles can be timeboxed (limited duration) and require approval before activation.
- Supports both built-in and custom roles.

## Key Features
- Just-in-time role activation
- Approval workflows for role assignments
- Timeboxing (set activation duration)
- Notification and audit logging
- Custom RBAC roles with granular permissions

## Creating and Managing PIM Roles
1. **Enable PIM in Azure Portal**
   - Azure Portal > Entra ID > Privileged Identity Management
2. **Assign Eligible Roles**
   - Assign users/groups as eligible for built-in or custom roles
3. **Create Custom Roles**
   - Go to Entra ID > Roles and administrators > New custom role
   - Define permissions and scope
   - Assign via PIM for just-in-time access
4. **Configure Approval and Timeboxing**
   - Set role activation to require approval from designated approvers
   - Specify activation duration (e.g., 1 hour, 8 hours)
   - Configure notifications and justification requirements

## Example: Timeboxed Custom Role with Approval

## Example: Create a Custom PIM Role with Approval (Code)

### Using Azure CLI
```powershell
# Create a custom role definition JSON
$role = @{
   Name = "Helpdesk Password Reset"
   Description = "Can reset passwords for users"
   Actions = @("Microsoft.Directory/users/password/reset/action")
   AssignableScopes = @("/")
}
Set-Content -Path role.json -Value ($role | ConvertTo-Json)

# Create the custom role
az role definition create --role-definition role.json

# Assign eligible role via PIM (requires AzureADPreview module)
Connect-AzureAD
New-AzureADMSPrivilegedRoleAssignmentRequest -ResourceId <tenantId> -RoleId <roleId> -SubjectId <userId> -AssignmentState "Eligible" -Type "User"
```

### Using ARM Template (for approval and timeboxing)
```json
{
   "type": "Microsoft.Authorization/roleAssignments",
   "apiVersion": "2020-04-01-preview",
   "properties": {
      "roleDefinitionId": "/providers/Microsoft.Authorization/roleDefinitions/<roleId>",
      "principalId": "<userId>",
      "principalType": "User",
      "canDelegate": false,
      "condition": "@pimApprovalRequired(true) && @pimActivationDuration(12h)",
      "conditionVersion": "1.0"
   }
}
```

### Approval Workflow
- When the user requests activation, role owners (approvers) are notified in the Azure Portal or via email.
- Approvers can approve or deny the request, and activation is timeboxed (e.g., 2 hours).

For more details, see [PIM Approval Workflow](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-activate-role).

## References
- [Microsoft Entra PIM Documentation](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [Create and manage custom roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/custom-create)
- [PIM Approval Workflow](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-activate-role)

---

For advanced scenarios and troubleshooting, see the Microsoft documentation linked above.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
