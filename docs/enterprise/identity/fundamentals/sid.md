---
Last Reviewed: 2025-09-04
Tags: 
---

# Security Identifiers (SID)

A Security Identifier (SID) is a unique value used to identify objects in Windows environments, such as users and groups. SIDs are critical for access control, as permissions are assigned to SIDs rather than object names. SIDs remain constant even if an object's name changes, ensuring consistent security management.

## SID History

SID History is an attribute in Active Directory that stores previous SIDs for migrated objects. This allows users and groups to retain access to resources after being moved between domains, as permissions assigned to old SIDs are still honored.

**Use Cases:**
- Domain migrations and consolidations
- Maintaining access to legacy resources

## Recreating or Migrating Objects with the Same SID

Normally, SIDs are unique to each domain and cannot be manually set. However, during migrations, tools like Active Directory Migration Tool (ADMT) can copy the original SID to the SID History attribute in the target domain. This enables seamless access to resources protected by the old SID.

**Steps to migrate with SID History using ADMT:**
1. Prepare both source and target domains for migration.
2. Use ADMT to migrate users/groups, enabling the option to migrate SID History.
3. Verify that the SID History attribute is populated in the target domain.
4. Test access to resources in both domains.

**Where to get ADMT:**
- The Active Directory Migration Tool (ADMT) is provided by Microsoft and can be downloaded from the official Microsoft Download Center:
  - https://www.microsoft.com/en-us/download/details.aspx?id=19188
- Ensure you download the version compatible with your Windows Server environment.

**Note:**
- Directly creating an object with the same SID in another domain is not supported for security reasons.
- SID History should be cleaned up after migration to reduce security risks.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
