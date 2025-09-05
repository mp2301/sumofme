Last Reviewed: 2025-09-04
Tags: azure-sql, database, paass, entra-id, defender
---

# Azure SQL (PaaS)

Compact guidance for choosing, deploying, securing, and operating Azure SQL Database and Managed Instance.

## Table of contents

- [Overview](#overview)
- [When to use](#when-to-use)
- [Key considerations](#key-considerations)
- [Quick create (Azure CLI)](#quick-create-azure-cli)
- [Entra ID authentication, groups, and contained users](#entra-id-authentication-groups-and-contained-users)
- [IaC examples (automating AD admin and post-deploy tasks)](#iac-examples-automating-ad-admin-and-post-deploy-tasks)
- [Client authentication examples (Managed Identity / MSAL)](#client-authentication-examples-managed-identity-msal)
- [Private connectivity and common SSMS connectivity & authentication issues](#private-connectivity-and-common-ssms-connectivity-authentication-issues)
- [Microsoft Defender for SQL (threat protection & vulnerability assessment)](#microsoft-defender-for-sql-threat-protection-vulnerability-assessment)
- [Operational recommendations](#operational-recommendations)

## Overview

- Use Azure SQL for managed OLTP and operational relational workloads. Choose Managed Instance when SQL Server compatibility is required; choose Single DB/Elastic Pools for isolated databases and cost control.

## When to use

- OLTP workloads requiring fully managed relational database capabilities.
- Lift-and-shift SQL Server workloads that benefit from managed backup, patching, and high availability (choose Managed Instance for high compatibility).

## Key considerations

- Deployment options: Single database (elastic pools), Managed Instance, or Flexible Server.
- Networking: prefer Private Endpoint for private connectivity; configure firewall rules and VNet routing for restricted access.
- Backup & DR: configure geo-redundant backups and failover groups for cross-region DR.
- Security: enable TDE (Transparent Data Encryption), Managed Identity, and Always Encrypted for sensitive columns.

## Quick create (Azure CLI)

```powershell
az sql server create -g MyRG -n my-sql-server -l eastus -u adminuser -p '<password>'
az sql db create -g MyRG -s my-sql-server -n mydb --service-objective S0
```

---

## Entra ID authentication, groups, and contained users

Azure SQL supports Entra ID authentication for principals (users and service principals). Entra ID provides centralized identity, short-lived tokens, and improved auditing.

Best practices
- Prefer Entra ID authentication over SQL auth for human and service access.
- Use Managed Identities for Azure services (App Service, Functions, Databricks) to avoid secret management.
- Manage database roles via Entra ID groups; grant roles to groups instead of individuals.
- Automate contained-user creation and grants through your deployment pipeline.

How it works (brief)
- Clients obtain OAuth tokens from Entra ID and present them to Azure SQL; Azure SQL validates and maps the token to a database principal.

Pre-req: configure an Entra ID server admin

```powershell
az sql server ad-admin create --resource-group MyRG --server my-sql-server --display-name "DB Admin" --object-id <aad-object-id>
```

Create contained users (examples)

-- Service principal (app registration)
```sql
CREATE USER [app-myservice] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [app-myservice];
GRANT EXECUTE ON SCHEMA::dbo TO [app-myservice];
```

-- Managed identity
```sql
CREATE USER [mi-myfunction] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datawriter ADD MEMBER [mi-myfunction];
```

-- Entra ID group
```sql
CREATE USER [sg-data-team] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [sg-data-team];
```

Notes and gotchas
- Entra ID admin must be set on the logical server before creating contained users.
- Use the object's display name or object id when mapping principals; verify via sys.database_principals.
- Tokens are short-lived; use MSAL-backed drivers and the AccessToken pattern.
- Cross-tenant/guest scenarios require B2B guest accounts or special mapping.

## IaC examples (automating AD admin and post-deploy tasks)

1) Bicep deploymentScript (Azure CLI inside deployment)

```bicep
resource deployScript 'Microsoft.Resources/deploymentScripts@2019-10-01-preview' = {
	name: 'setSqlAdAdmin'
	location: resourceGroup().location
	kind: 'AzureCLI'
	properties: {
		azCliVersion: '2.0.80'
		scriptContent: '''
			az sql server ad-admin create --resource-group ${resourceGroup().name} --server ${sqlServerName} --display-name "DB Admin" --object-id ${aadAdminObjectId}
		'''
		timeout: 'PT30M'
		cleanupPreference: 'OnSuccess'
	}
}
```

2) ARM snippet for AD admin

```json
{
	"type": "Microsoft.Sql/servers/administrators",
	"apiVersion": "2021-02-01-preview",
	"name": "activeDirectory",
	"properties": {
		"administratorType": "ActiveDirectory",
		"login": "DB Admin",
		"sid": "<aad-object-id>",
		"tenantId": "<tenant-id>"
	}
}
```

3) Terraform local-exec pattern

```hcl
resource "null_resource" "set_sql_ad_admin" {
	provisioner "local-exec" {
		command = "az sql server ad-admin create -g ${azurerm_resource_group.rg.name} -s ${azurerm_mssql_server.main.name} --display-name 'DB Admin' --object-id ${var.aad_admin_object_id}"
	}
	depends_on = [azurerm_mssql_server.main]
}
```

Post-deploy contained-user provisioning should run T-SQL as an admin via pipeline step or deployment script.

## Client authentication examples (Managed Identity / MSAL)

1) C# (.NET) — connect using DefaultAzureCredential (Managed Identity) and ADO.NET

```csharp
using Azure.Core;
using Azure.Identity;
using System.Data.SqlClient;

var credential = new DefaultAzureCredential();
var tokenRequestContext = new TokenRequestContext(new[] { "https://database.windows.net/.default" });
var accessToken = await credential.GetTokenAsync(tokenRequestContext);

var builder = new SqlConnectionStringBuilder();
builder.DataSource = "my-sql-server.database.windows.net";
builder.InitialCatalog = "mydb";
builder.Encrypt = true;

using var conn = new SqlConnection(builder.ConnectionString);
conn.AccessToken = accessToken.Token;
conn.Open();
// run commands
```

2) Python — connect using DefaultAzureCredential and pyodbc

```python
from azure.identity import DefaultAzureCredential
import pyodbc

cred = DefaultAzureCredential()
token = cred.get_token('https://database.windows.net/.default').token
# pyodbc expects the token as bytes prefixed with the length header
exptoken = bytes(token, 'utf-8')
exptoken = b"\x00" + exptoken

conn_str = (
		'Driver={ODBC Driver 18 for SQL Server};'
		'Server=tcp:my-sql-server.database.windows.net,1433;'
		'Database=mydb;Encrypt=yes;TrustServerCertificate=no;'
)

conn = pyodbc.connect(conn_str, attrs_before={1256: exptoken})
cursor = conn.cursor()
cursor.execute("SELECT 1")
```

Notes
- Always request the scope "https://database.windows.net/.default" for SQL access tokens.
- Prefer SDKs that support Azure Identity directly where available. For ad-hoc T-SQL, the AccessToken pattern is widely supported.
- Secure pipeline secrets: object IDs and tenant IDs are configuration values; store them in secure variable stores (Key Vault / pipeline secrets).

## Private connectivity and common SSMS connectivity & authentication issues

This section explains how to consume Azure SQL privately (Private Endpoint / VNet) and common connectivity/authentication issues encountered when using SQL Server Management Studio (SSMS) or on-prem tooling.

Key patterns for private consumption
- Private Endpoint: deploy a Private Endpoint for the server to get a private IP in your VNet. Configure the Azure Private DNS zone (privatelink.database.windows.net) and link it to VNets or on-prem DNS forwarders so the logical server name resolves to the private IP.
- DNS: ensure name resolution from the client (on-prem or peered VNet). For on-prem clients, forward the privatelink zone from your DNS servers to Azure DNS or configure conditional forwarders to the Azure DNS private resolver.
- Routing & egress: clients must be able to reach Entra ID endpoints (login.microsoftonline.com / login.microsoft.com / sts.windows.net) to acquire tokens. If your VNet disables outbound internet, allow egress to the Entra ID endpoints or provide a managed proxy/jump-host inside the VNet.
- Hybrid access: for VPN/ExpressRoute clients, ensure the Private DNS zone is visible to on‑premises DNS and that traffic to the private IP is routable. If routes are missing, use a jumpbox or Azure Bastion in the VNet to connect from a managed host.

SSMS-specific connectivity & authentication notes
- SSMS and Azure AD: use a recent SSMS version that supports Azure AD authentication (look for options "Active Directory - Password", "Active Directory - Integrated", or "Active Directory - Universal with MFA"). SSMS is designed for human interactive authentication — it does not support service-principal (app) auth for interactive sign-in.
- Service principals & automation: SSMS cannot authenticate using service principals or managed identities. For non-interactive scenarios use sqlcmd/ODBC with the AccessToken pattern, or a small script that requests an access token and then connects.
- Common SSMS errors and fixes:
  - "Login failed for user" after Azure AD sign-in: verify the contained user exists in the database (CREATE USER [name] FROM EXTERNAL PROVIDER) and that the Azure AD principal is mapped to DB roles.
  - Server name resolves to public IP instead of private IP: check private DNS zone and VNet links; ensure the client is using DNS that can resolve privatelink names.
  - Cannot reach server / timeout on port 1433: verify network path (Test-NetConnection -ComputerName <server> -Port 1433) and routing; check NSGs, firewall appliances, and VPN/ExpressRoute routes.
  - TLS/driver issues: ensure the latest ODBC/SQL Server drivers are installed (ODBC Driver 17/18) and that TLS 1.2 is allowed; update SSMS if older versions lack required TLS support.
  - Token errors: "Invalid audience" or permission errors usually mean the token scope is wrong. Tokens for Azure SQL must use scope/audience https://database.windows.net/.default.

Recommended troubleshooting steps
1. DNS check: run nslookup against the server name and the privatelink zone to confirm the name resolves to the expected private IP.
2. Network check: use PowerShell Test-NetConnection -ComputerName <server> -Port 1433 to confirm connectivity from the client host.
3. Authentication check: from a VM inside the VNet (or using a jumpbox), try Azure AD interactive sign-in from SSMS or use sqlcmd with -G (Azure AD interactive) to confirm the principal mapping.
	- Example (sqlcmd interactive Azure AD):

```powershell
sqlcmd -S tcp:my-sql-server.database.windows.net,1433 -d mydb -G
```

4. Token-based test (automation): request a token with Azure CLI and use sqlcmd with ODBC token injection or a short Python script to confirm the AccessToken flow.
	- Example (PowerShell/Azure CLI token retrieval):

```powershell
az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv
# Use token in automation or ODBC callers that accept AccessToken
```

5. Use a jumpbox: when on-prem DNS or networking makes direct private connectivity hard, deploy a small VM in the VNet (or use Azure Bastion) and run SSMS from that host.

Operational guidance
- For local developer machines, prefer Azure Data Studio or SSMS with Azure AD interactive auth and connect via a jumpbox when private endpoints are used.
- Document the DNS and routing requirements for each environment and include a small troubleshooting checklist in runbooks.
- For CI/CD and automation, avoid interactive tools. Use AccessToken patterns, managed identities from within Azure, or service principals with appropriate contained DB user mappings.

## Microsoft Defender for SQL (threat protection & vulnerability assessment)

Microsoft Defender for SQL (part of Microsoft Defender for Cloud) provides runtime threat detection, vulnerability assessment, and recommendation-based hardening for Azure SQL (Single DB, Managed Instance, and SQL servers). It helps detect anomalous activities, potential SQL injection, brute force, unusual data exfiltration attempts, and insecure configurations.

Core capabilities
- Threat detection / alerts: behavioral analytics and detection rules surface suspicious activities (SQL injection, anomalous schema changes, suspicious admin operations). Alerts are emitted to Defender for Cloud and can forward to Azure Monitor, Event Hubs, or SIEM solutions.
- Vulnerability Assessment (VA): periodic scans that identify misconfigurations, missing security controls, and vulnerable settings; the VA provides remediation steps and baseline exports.
- Advanced protection: integration with Azure Defender for Cloud controls, automated recommendations, and integration with Microsoft Sentinel for investigation and hunting.
- Reporting & automation: exportable scan results, integration with playbooks (Logic Apps) to automate incident response, and connectors to ticketing systems.

Enablement & configuration (guidance)
- Defender for SQL is managed from Microsoft Defender for Cloud. Enable the Defender plan for SQL resources in the Defender for Cloud pricing & settings blade for the subscription or workspace where your SQL resources live.
- Vulnerability Assessment can be configured per database; VA results can be stored in a storage account for history and for CI/CD gating.
- Configure alert forwarding to a Log Analytics workspace or to Microsoft Sentinel for centralized triage and hunting.

Operational checklist
- Enable Defender for SQL at subscription level for production subscriptions; consider scoped enablement in non-prod environments based on cost/security balance.
- Configure Vulnerability Assessment baseline and address high/critical findings in a tracked backlog (tag findings with remediation owner and due date).
- Tune alert thresholds and suppress known benign activity to reduce noise; maintain a whitelist of service principals or IPs when appropriate.
- Route alerts to an incident management workflow (Logic Apps playbooks or Sentinel playbooks) that enriches alerts with context (owner, recent deployments, asset tags).
- Ensure audit logs and VA results are retained according to policy and are available for forensics (store in Log Analytics or a secure storage account).

Best practices
- Automate VA scans as part of CI/CD: run vulnerability scans after schema changes/migrations and block or require approval on critical findings.
- Use Defender alerts as a signal, not absolute truth: combine with SQL Audit, diagnostic logs, and application logs for context.
- Integrate with Microsoft Sentinel to create detection rules, hunting queries, and automated response playbooks for high-fidelity alerts.
- Keep the Defender for Cloud agent and diagnostic settings consistent across environments to ensure comparable telemetry.

Pricing & cost control
- Defender for SQL is a priced Defender plan; enablement incurs per-resource charges. Enable selectively and monitor cost in non-production until policy is decided.

Notes specific to Managed Instance vs Single Database
- Most Defender features (VA, threat detection) are available for both Managed Instance and Single DB, but some management tasks and diagnostics endpoints differ — verify feature parity for your chosen deployment.

---


2) ARM snippet (example resource to set AD admin)

```json
{
	"type": "Microsoft.Sql/servers/administrators",
	"apiVersion": "2021-02-01-preview",
	"name": "activeDirectory",
	"properties": {
		"administratorType": "ActiveDirectory",
		"login": "DB Admin",
		"sid": "<aad-object-id>",
		"tenantId": "<tenant-id>"
	}
}
```

3) Terraform (local-exec pattern)
- If you use Terraform and the provider doesn't expose a first-class AD admin resource, use a `null_resource` + `local-exec` to call the Azure CLI as a post-deploy step.

```hcl
resource "null_resource" "set_sql_ad_admin" {
	provisioner "local-exec" {
		command = "az sql server ad-admin create -g ${azurerm_resource_group.rg.name} -s ${azurerm_mssql_server.main.name} --display-name 'DB Admin' --object-id ${var.aad_admin_object_id}"
	}
	depends_on = [azurerm_mssql_server.main]
}
```

Post-deploy contained-user provisioning
- Creating contained DB users requires executing T-SQL against the database. Automate this as a post-deploy script executed by your pipeline or via a deploymentScript that runs sqlcmd / invoke-sqlcmd with an administrator principal.

Client authentication examples (Managed Identity / MSAL)

1) C# (.NET) — connect using DefaultAzureCredential (Managed Identity) and ADO.NET

```csharp
using Azure.Core;
using Azure.Identity;
using System.Data.SqlClient;

var credential = new DefaultAzureCredential();
var tokenRequestContext = new TokenRequestContext(new[] { "https://database.windows.net/.default" });
var accessToken = await credential.GetTokenAsync(tokenRequestContext);

var builder = new SqlConnectionStringBuilder();
builder.DataSource = "my-sql-server.database.windows.net";
builder.InitialCatalog = "mydb";
builder.Encrypt = true;

using var conn = new SqlConnection(builder.ConnectionString);
conn.AccessToken = accessToken.Token;
conn.Open();
// run commands
```

2) Python — connect using DefaultAzureCredential and pyodbc

```python
from azure.identity import DefaultAzureCredential
import pyodbc

cred = DefaultAzureCredential()
token = cred.get_token('https://database.windows.net/.default').token
# pyodbc expects the token as bytes prefixed with the length header
exptoken = bytes(token, 'utf-8')
exptoken = b"\x00" + exptoken

conn_str = (
		'Driver={ODBC Driver 18 for SQL Server};'
		'Server=tcp:my-sql-server.database.windows.net,1433;'
		'Database=mydb;Encrypt=yes;TrustServerCertificate=no;'
)

conn = pyodbc.connect(conn_str, attrs_before={1256: exptoken})
cursor = conn.cursor()
cursor.execute("SELECT 1")
```

Notes
- Always request the scope "https://database.windows.net/.default" for SQL access tokens.
- Prefer SDKs that support Azure Identity directly where available (for example, the Azure.Data.AppConfiguration or Azure Key Vault clients). For ad-hoc T-SQL, the AccessToken pattern is widely supported.
- Secure pipeline secrets: object IDs and tenant IDs are configuration values; store them in secure variable stores (Key Vault / pipeline secrets).

## Microsoft Defender for SQL (threat protection & vulnerability assessment)

Microsoft Defender for SQL (part of Microsoft Defender for Cloud) provides runtime threat detection, vulnerability assessment, and recommendation-based hardening for Azure SQL (Single DB, Managed Instance, and SQL servers). It helps detect anomalous activities, potential SQL injection, brute force, unusual data exfiltration attempts, and insecure configurations.

Core capabilities
- Threat detection / alerts: behavioral analytics and detection rules surface suspicious activities (SQL injection, anomalous schema changes, suspicious admin operations). Alerts are emitted to Defender for Cloud and can forward to Azure Monitor, Event Hubs, or SIEM solutions.
- Vulnerability Assessment (VA): periodic scans that identify misconfigurations, missing security controls, and vulnerable settings; the VA provides remediation steps and baseline exports.
- Advanced protection: integration with Azure Defender for Cloud controls, automated recommendations, and integration with Microsoft Sentinel for investigation and hunting.
- Reporting & automation: exportable scan results, integration with playbooks (Logic Apps) to automate incident response, and connectors to ticketing systems.

Enablement & configuration (guidance)
- Defender for SQL is managed from Microsoft Defender for Cloud (formerly Security Center). Enable the Defender plan for SQL resources in the Defender for Cloud pricing & settings blade for the subscription or workspace where your SQL resources live.
- Vulnerability Assessment can be configured per database; VA results can be stored in a storage account for history and for CI/CD gating.
- Configure alert forwarding to a Log Analytics workspace or to Microsoft Sentinel for centralized triage and hunting.

Operational checklist
- Enable Defender for SQL at subscription level for production subscriptions; consider scoped enablement in non-prod environments based on cost/security balance.
- Configure Vulnerability Assessment baseline and address high/critical findings in a tracked backlog (tag findings with remediation owner and due date).
- Tune alert thresholds and suppress known benign activity to reduce noise; maintain a whitelist of service principals or IPs when appropriate.
- Route alerts to an incident management workflow (Logic Apps playbooks or Sentinel playbooks) that enriches alerts with context (owner, recent deployments, asset tags).
- Ensure audit logs and VA results are retained according to policy and are available for forensics (store in Log Analytics or a secure storage account).

Best practices
- Automate VA scans as part of CI/CD: run vulnerability scans after schema changes/migrations and block or require approval on critical findings.
- Use Defender alerts as a signal, not absolute truth: combine with SQL Audit, diagnostic logs, and application logs for context.
- Integrate with Microsoft Sentinel to create detection rules, hunting queries, and automated response playbooks for high-fidelity alerts.
- Keep the Defender for Cloud agent and diagnostic settings consistent across environments to ensure comparable telemetry.

Pricing & cost control
- Defender for SQL is a priced Defender plan; enablement incurs per-resource charges. Enable selectively and monitor cost in non-production until policy is decided.

Notes specific to Managed Instance vs Single Database
- Most Defender features (VA, threat detection) are available for both Managed Instance and Single DB, but some management tasks and diagnostics endpoints differ — verify feature parity for your chosen deployment.

References and where to configure
- Use the Microsoft Defender for Cloud blade in the Azure portal to enable Defender plans and configure alert forwarding and workspace integration.
- Configure Vulnerability Assessment from the database's Vulnerability assessment settings in the Azure portal and set storage for scan results.


---

Include: `../../../_footer.md`
Return to [Data Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)

IaC examples (automating server AD admin and post-deploy DB user creation)

1) Bicep + deploymentScript (recommended pattern)
- Use a deployment script to run the Azure CLI as part of the deployment to set the server Azure AD admin and to run post-deploy SQL against the database. This avoids relying on provider-specific resources whose schemas sometimes lag.

```bicep
resource deployScript 'Microsoft.Resources/deploymentScripts@2019-10-01-preview' = {
	name: 'setSqlAdAdmin'
	location: resourceGroup().location
	kind: 'AzureCLI'
	properties: {
		azCliVersion: '2.0.80'
		scriptContent: '''
			az sql server ad-admin create --resource-group ${resourceGroup().name} --server ${sqlServerName} --display-name "DB Admin" --object-id ${aadAdminObjectId}
			# optionally run sqlcmd to apply post-deploy T-SQL (contained users)
		'''
		timeout: 'PT30M'
		cleanupPreference: 'OnSuccess'
	}
}
```

2) ARM snippet (example resource to set AD admin)

```json
{
	"type": "Microsoft.Sql/servers/administrators",
	"apiVersion": "2021-02-01-preview",
	"name": "activeDirectory",
	"properties": {
		"administratorType": "ActiveDirectory",
		"login": "DB Admin",
		"sid": "<aad-object-id>",
		"tenantId": "<tenant-id>"
	}
}
```

3) Terraform (local-exec pattern)
- If you use Terraform and the provider doesn't expose a first-class AD admin resource, use a `null_resource` + `local-exec` to call the Azure CLI as a post-deploy step.

```hcl
resource "null_resource" "set_sql_ad_admin" {
	provisioner "local-exec" {
		command = "az sql server ad-admin create -g ${azurerm_resource_group.rg.name} -s ${azurerm_mssql_server.main.name} --display-name 'DB Admin' --object-id ${var.aad_admin_object_id}"
	}
	depends_on = [azurerm_mssql_server.main]
}
```

Post-deploy contained-user provisioning
- Creating contained DB users requires executing T-SQL against the database. Automate this as a post-deploy script executed by your pipeline or via a deploymentScript that runs sqlcmd / invoke-sqlcmd with an administrator principal.

Client authentication examples (Managed Identity / MSAL)

1) C# (.NET) — connect using DefaultAzureCredential (Managed Identity) and ADO.NET

```csharp
using Azure.Core;
using Azure.Identity;
using System.Data.SqlClient;

var credential = new DefaultAzureCredential();
var tokenRequestContext = new TokenRequestContext(new[] { "https://database.windows.net/.default" });
var accessToken = await credential.GetTokenAsync(tokenRequestContext);

var builder = new SqlConnectionStringBuilder();
builder.DataSource = "my-sql-server.database.windows.net";
builder.InitialCatalog = "mydb";
builder.Encrypt = true;

using var conn = new SqlConnection(builder.ConnectionString);
conn.AccessToken = accessToken.Token;
conn.Open();
// run commands
```

2) Python — connect using DefaultAzureCredential and pyodbc

```python
from azure.identity import DefaultAzureCredential
import pyodbc

cred = DefaultAzureCredential()
token = cred.get_token('https://database.windows.net/.default').token
# pyodbc expects the token as bytes prefixed with the length header
exptoken = bytes(token, 'utf-8')
exptoken = b"\x00" + exptoken

conn_str = (
		'Driver={ODBC Driver 18 for SQL Server};'
		'Server=tcp:my-sql-server.database.windows.net,1433;'
		'Database=mydb;Encrypt=yes;TrustServerCertificate=no;'
)

conn = pyodbc.connect(conn_str, attrs_before={1256: exptoken})
cursor = conn.cursor()
cursor.execute("SELECT 1")
```

Notes
- Always request the scope "https://database.windows.net/.default" for SQL access tokens.
- Prefer SDKs that support Azure Identity directly where available (for example, the Azure.Data.AppConfiguration or Azure Key Vault clients). For ad-hoc T-SQL, the AccessToken pattern is widely supported.
- Secure pipeline secrets: object IDs and tenant IDs are configuration values; store them in secure variable stores (Key Vault / pipeline secrets).


---
Include: `../../../_footer.md`
Return to [Data Index](../_index.md) | [Enterprise Overview](../_index.md) | [Root README](../../README.md)
