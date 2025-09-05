---
Last Reviewed: 2025-09-04
Tags: 
---

# Multi-Tenancy in Windows AD: List Object Mode

Windows Active Directory can support multi-tenancy scenarios by leveraging List Object Mode, which allows fine-grained control over which objects are visible to users and applications during AD/LDAP queries. This is especially useful for organizations hosting multiple business units, departments, or tenants within a single AD forest or domain.

## What is List Object Mode?
List Object Mode is an advanced feature in AD that enables administrators to restrict the visibility of directory objects. When enabled, users can only see objects for which they have explicit permissions, rather than seeing all objects in a container.

- By default, users with read access to a container can enumerate all child objects.
- With List Object Mode, users must have the "List Contents" permission on each object to see it in query results.

## Use Cases for Multi-Tenancy
- Hosting multiple business units or tenants in a single AD domain
- Delegating administration and access to specific OU/object sets
- Preventing cross-tenant visibility of users, groups, or resources

## How to Enable List Object Mode
1. **Enable List Object Mode on the Domain**
   - Use `ntdsutil` or ADSI Edit to set the domain property:
   - In ADSI Edit, navigate to the domain object, set `dSHeuristics` to a value that enables List Object Mode (e.g., add or modify the 7th character to "1").
   - Example PowerShell:
     ```powershell
     Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=domain,DC=com" -Replace @{dSHeuristics="0000001"}
     ```
2. **Delegate List Contents Permission**
   - Use ADUC or PowerShell to grant "List Contents" permission on specific objects or OUs.
   - Example PowerShell:
     ```powershell
     $acl = Get-Acl "AD:\OU=Tenant1,DC=domain,DC=com"
     $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule("CN=User1,OU=Tenant1,DC=domain,DC=com", "ListChildren", "Allow")
     $acl.AddAccessRule($rule)
     Set-Acl "AD:\OU=Tenant1,DC=domain,DC=com" $acl
     ```

### Important Notes
- `dSHeuristics` lives in the Configuration partition and replicates forest-wide—treat changes as a controlled change (CAB / peer review).
- Only change the specific character you need. If other characters already have non-zero values, preserve them. Example: existing value `000000200100000` becomes `000000210100000` (7th char flipped to 1).
- You don't have to pad unused characters: the shortest string up to the highest non-zero position is valid per the schema spec.
- List Object Mode limits enumeration visibility; it does not grant or revoke underlying attribute read permissions—pair with least-privilege ACL design.
- Prefer assigning rights to tenant-specific groups instead of individual user accounts.

## Best Practices
- Use separate OUs for each tenant/business unit
- Delegate permissions using groups for easier management
- Regularly audit permissions and visibility
- Document all changes to dSHeuristics and delegated permissions

### Visibility / Permission Mapping
| Goal | Minimum Rights | Notes |
|------|----------------|-------|
| Hide unrelated tenant objects | Remove ListChildren/ListObject on those objects | Users receive empty result sets instead of partial metadata. |
| Tenant admin sees only their OU | ListChildren + ListObject on tenant OU path | Add ReadProperty for attributes required by tools/apps. |
| Application directory searches | ReadProperty (+ ListObject where needed) | Avoid broad ListChildren on high-level OUs. |
| Prevent lateral discovery | Restrict ListChildren on parent OUs; grant explicit on leaves | Combine with monitoring of unusual enumeration attempts. |

## References
- (Historical Microsoft KB describing List Object Mode was retired; rely on schema + specification references below.)
- `dSHeuristics` attribute schema reference: https://learn.microsoft.com/en-us/windows/win32/adschema/a-dsheuristics
- Active Directory Technical Specification (`dSHeuristics` character definitions): https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/
- Access control model (security descriptors / ACL fundamentals): https://learn.microsoft.com/en-us/windows/security/identity-protection/access-control/access-control
- Security & delegation via groups (service vs data admin separation): https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups
- Protected admin accounts / AdminSDHolder inheritance considerations: https://support.microsoft.com/topic/delegated-permissions-are-not-available-and-inheritance-is-automatically-disabled-56a70fa8-6d17-35ac-0f2c-87ec14b61980


---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
