---
Last Reviewed: 2025-09-04
Tags: 
---

# AD Backup and Restore Basics

Regular backup of Active Directory is vital for disaster recovery. Below are the core principles and practical steps for engineers responsible for backup and recovery:

## System State Backup
System State Backup captures all critical components of a domain controller, including:
- Active Directory database (NTDS.dit)
- SYSVOL folder (Group Policy and scripts)
- Registry
- Boot files
- Certificate Services (if installed)

**How to perform:**
- Use Windows Server Backup or third-party tools.
- Schedule backups regularly (daily or weekly, depending on change rate).
- Store backups securely and offsite if possible.

## Authoritative vs. Non-Authoritative Restore
Restoring AD can be done in two ways:

- **Non-Authoritative Restore:**
  - Restores AD from backup, then updates from other domain controllers via replication.
  - Use when recovering a failed DC without needing to overwrite changes made elsewhere.

- **Authoritative Restore:**
  - Marks specific objects or entire AD as authoritative, forcing replication of restored data to other DCs.
  - Use when you need to recover deleted objects or reverse unwanted changes.
  - Requires Directory Services Restore Mode (DSRM) and the `ntdsutil` tool.

**Steps for restore:**
1. Boot DC into DSRM.
2. Restore System State using backup tool.
3. For authoritative restore, use `ntdsutil` to mark objects as authoritative.
4. Reboot and allow replication.

## Best Practices
- Automate and monitor backup jobs.
- Test restores regularly in a lab environment.
- Document backup schedules, locations, and recovery procedures.
- Ensure backups are protected from unauthorized access.
- Keep at least one recent backup offline to protect against ransomware.

**Engineer Checklist:**
- Verify backup completion and integrity.
- Know the process for both non-authoritative and authoritative restores.
- Practice restores to ensure readiness.
- Maintain documentation and update it after any changes to the environment.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
