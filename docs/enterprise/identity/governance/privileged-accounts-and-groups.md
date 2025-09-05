---
Last Reviewed: 2025-09-04
Tags: 
---

# Privileged Accounts and Security Group Standards

Proper management of privileged accounts and security groups is critical for Active Directory security and compliance.

## Security Group Ownership and Attestation

In the Microsoft ecosystem, group membership and attestation (access reviews) are managed differently for EntraID (Azure AD) and Windows AD:

### EntraID (Azure AD) Groups
- Use Microsoft Entra Access Reviews to automate attestation of group membership
- Owners can be assigned and notified for access reviews
- Access reviews can be scheduled (e.g., quarterly) and require owners to approve or remove members
- If reviews are not completed for two consecutive cycles, groups can be flagged for deletion or remediation
- Membership requests can be managed via self-service (if enabled) and require owner approval
- Reference: [Access Reviews in Microsoft Entra](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview)

### Windows AD Groups
- Attestation is typically manual or managed via third-party tools (e.g., Quest Active Roles)
- Owners should review group membership regularly (e.g., quarterly) and document approvals/removals
- Membership requests are managed by IT or delegated owners
- Groups with unanswered attestations for two consecutive quarters should be deleted or remediated

**Standard:**
- Every privileged group must have **three owners** assigned
- Owners are responsible for:
  - Approving new membership requests
  - Approving new owners
  - Performing rolling quarterly attestation/access reviews of group members
- Any user with a valid account can request membership; owners must approve
- Attestation/access review process:
  - Each quarter, owners review and confirm group membership
  - If attestation/access review is unanswered for **two consecutive quarters**, the group is deleted

## Best Practices
- Document group ownership and attestation procedures
- Use automated tools or scripts to track attestation and membership changes
- Notify owners of upcoming attestation deadlines
- Log all membership requests, approvals, and deletions for audit purposes

## Reporting and Monitoring

- Implement reporting to detect anomalies in security group membership and ownership activities
- Monitor for:
  - Unexpected changes in group membership (e.g., mass additions/removals)
  - Ownership changes outside of approved workflows
  - Groups without the required number of owners
  - Attestation/access reviews not completed on schedule
- Use built-in tools (Microsoft Entra reporting, Azure AD logs) or SIEM solutions (e.g., Microsoft Sentinel) to generate and review reports
- Alert on suspicious or non-compliant activities for investigation
- Regularly review reports and take corrective action as needed

## Privileged Account Password Management

- Passwords for privileged accounts must be rotated by CyberArk every 12 hours.
- Accessing privileged account passwords in CyberArk requires:
  - Multi-factor authentication (MFA)
  - VPN connection from a compliant device

These controls help ensure that privileged credentials are protected and only accessible by authorized users under secure conditions.

## Example Workflow
1. User requests membership in a security group
2. Owners receive notification and approve or deny the request
3. Quarterly, owners receive attestation reminders and confirm group membership
4. If attestation is missed for two quarters, group is flagged for deletion
5. All actions are logged for compliance and review

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
