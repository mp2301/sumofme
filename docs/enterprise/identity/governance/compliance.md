---
Last Reviewed: 2025-09-04
Tags: 
---

# Compliance Reporting Frameworks


Active Directory plays a key role in meeting compliance requirements such as HIPAA and SOC 2. Below is how AD addresses each framework:

## HIPAA
HIPAA requires:
- **Access Controls**: AD enforces user/group permissions, OU delegation, and role-based access.
- **Audit Logs**: Enable AD auditing for logon events, object access, and changes. Use tools like Event Viewer and SIEM solutions to collect and review logs.
- **User Authentication**: AD supports strong authentication (Kerberos, NTLM, smart cards, MFA via EntraID integration).
- **Account Management**: Regularly review and disable unused accounts, enforce password policies, and monitor group membership changes.

## SOC 2
SOC 2 focuses on:
- **Security**: AD provides centralized access control, password policies, and supports MFA.
- **Availability**: Use multiple domain controllers, backup/restore procedures, and monitor DC health.
- **Confidentiality**: Limit access to sensitive data via AD permissions and group policies.
- **Audit Trails**: Enable and retain AD logs for user activity, changes, and access attempts.
- **Change Management**: Document and review changes to AD objects, GPOs, and permissions.

**Preparing for Audits:**
- Enable and review AD auditing
- Document access controls and changes
- Regularly review permissions and group memberships
- Retain logs for required periods

Proper configuration and monitoring of AD is essential for compliance. Use built-in tools and third-party solutions to automate reporting and alerting.

## Onboarding New AD Environments

For any new Active Directory deployment, an onboarding exercise is essential to ensure compliance areas (access controls, auditing, authentication, change management) are properly configured from the start.

**Recommended Steps:**
- Review and set up access controls and group policies
	- Limit membership in privileged groups (Domain Admins, Enterprise Admins)
	- Apply least privilege principles and use role-based access
- Enable and configure auditing for key security events:
	- Logon/logoff events (Event IDs 4624, 4625, 4634)
	- Account management (Event IDs 4720, 4722, 4723, 4724, 4725, 4726)
	- Directory service changes (Event IDs 5136, 5141)
	- Object access (Event IDs 4662, 4663)
	- Group membership changes (Event ID 4732, 4733)
- Establish password policies and authentication requirements:
	- See Microsoft's official password policy guidance: [Microsoft Password Policy Recommendations (search)](https://learn.microsoft.com/en-us/search/?q=password%20policy%20recommendations)
	- Reference: [Microsoft ESAE (Enhanced Security Admin Environment) Guidance](https://learn.microsoft.com/en-us/windows-server/identity/securing-privileged-access/securing-privileged-access-reference-material)
		- Minimum length: 12+ characters
		- Complexity: Require uppercase, lowercase, numbers, and symbols
		- Maximum password age: Not set (Microsoft and ESAE recommend removing periodic password expiration for user accounts)
		- Enforce password history: 24 previous passwords
		- Account lockout threshold: 5 attempts
				- Enable multi-factor authentication (MFA):
					- For Windows AD: Use smart cards, certificate-based authentication, or third-party MFA solutions integrated with AD (e.g., Duo, RSA, Yubikey)
					- For EntraID (Azure AD): Use built-in MFA options such as authenticator apps, FIDO2 security keys, biometrics, or SMS
					- Reference: [Microsoft Entra multifactor authentication documentation](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-mfa-howitworks)
				- Implement risk-based authentication and monitoring:
	- **Sending Windows AD Logs to Sentinel:**
		- Forward security and event logs from domain controllers to an Azure Log Analytics workspace using the Microsoft Monitoring Agent or Azure Arc.
		- Connect the Log Analytics workspace to Microsoft Sentinel for monitoring and analysis.
		- Use Sentinel's built-in connectors for Windows Security Events and Active Directory.
		- References:
			- [Connect Windows Security Events to Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/connect-windows-security-events)
			- [Collect security events from domain controllers](https://learn.microsoft.com/en-us/azure/sentinel/connect-windows-security-events#collect-security-events-from-domain-controllers)
					- For Windows AD: Monitor logon events, account lockouts, and use SIEM solutions (such as Microsoft Sentinel) for anomaly detection and advanced threat monitoring
					- Reference: [Microsoft Sentinel documentation](https://learn.microsoft.com/en-us/azure/sentinel/)
					- For EntraID: Use conditional access policies and Identity Protection to require MFA based on user risk, location, device, or behavior
					- Reference: [Microsoft Entra Identity Protection (search)](https://learn.microsoft.com/en-us/search/?q=Entra%20Identity%20Protection)
			- Educate users on password hygiene and security best practices
				- Provide training on recognizing phishing, using strong passwords, and enabling MFA
				- Encourage use of password managers that meet current Microsoft recommendations (such as Bitwarden, 1Password, or other enterprise-approved solutions)
		- Microsoft recommends using the built-in password manager in Microsoft Edge for personal and enterprise accounts. See [Microsoft Edge password manager (search)](https://learn.microsoft.com/search?search=Microsoft%20Edge%20password%20manager)
				- Reference: [Microsoft Security Awareness Training (search)](https://learn.microsoft.com/en-us/search/?q=security%20awareness%20training)
				- Reference: [Microsoft password manager guidance](https://learn.microsoft.com/en-us/search/?q=password%20managers)
- Document initial configuration and change management procedures
	- Record all changes to AD objects, GPOs, and permissions
	- Use ticketing systems or change logs for traceability
- Set up regular reviews and reporting:
	- Review privileged group membership monthly
	- Audit access to sensitive resources quarterly
	- Retain security logs for at least 1 year (HIPAA/SOC 2 may require longer)
	- Use automated tools (PowerShell, SIEM, reporting solutions) to generate compliance reports

**Automation:**
Many onboarding tasks can be automated using PowerShell scripts or configuration management tools (such as Desired State Configuration, Group Policy templates, or third-party solutions). Automation helps ensure consistency and reduces manual errors.

> Tip: Maintain onboarding scripts and checklists as part of your AD documentation to streamline future deployments and audits.

---
Include: `../../../_footer.md`
Return to [Identity Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
