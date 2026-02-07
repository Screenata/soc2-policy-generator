# Cloud Scanning Shared Guidelines

Shared guidelines for scanning live cloud infrastructure via CLI tools.
For codebase scanning guidelines, see [shared.md](shared.md).

## Provider Detection

Check which CLIs are installed:

```bash
aws --version        # AWS CLI
gcloud --version     # Google Cloud SDK
az --version         # Azure CLI
```

Only scan providers where the CLI is present. Report which providers are available.

## Authentication Verification

Verify active credentials before running any scan commands:

| Provider | Command | Success Indicator |
|----------|---------|-------------------|
| AWS | `aws sts get-caller-identity` | Returns `Account`, `Arn`, `UserId` |
| GCP | `gcloud auth list --filter=status:ACTIVE --format="value(account)"` | Returns active account email |
| Azure | `az account show --query "{name:name, id:id}" -o json` | Returns subscription name and ID |

If authentication fails, guide the user:
- AWS: "Run `aws configure` or set `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`"
- GCP: "Run `gcloud auth login` or `gcloud auth application-default login`"
- Azure: "Run `az login`"

Do NOT proceed with cloud scanning for a provider if credentials are not configured.

## Safety Rules

1. **READ-ONLY ONLY**: Every command must be a `describe`, `list`, `get`, or `show` operation. NEVER run commands that modify infrastructure (`create`, `update`, `delete`, `put`, `set`, `attach`, `detach`).
2. **No secrets in output**: Never include actual secret values, private keys, access keys, or connection strings in evidence. Redact with `[REDACTED]`. For KMS key ARNs, include the alias but not the full ARN.
3. **Timeout protection**: Use `--timeout 30000` on all Bash calls to prevent hanging on unresponsive endpoints.
4. **Error handling**: If a command fails (permission denied, resource not found), note it in evidence as "Not accessible — [error]" and move on. Do not retry or escalate permissions.

## Region Handling

Ask the user which region(s) to scan. If not specified, detect defaults:

- AWS: `aws configure get region`
- GCP: `gcloud config get-value project` and `gcloud config get-value compute/region`
- Azure: `az group list --query "[].{name:name, location:location}" -o table`

For multi-region deployments, scan each region separately and note the region in evidence.

## Resource Discovery Pattern

Use a two-phase approach:

1. **Discovery**: Run list commands to find what resources exist (e.g., `aws rds describe-db-instances` to find all RDS instances)
2. **Inspection**: Run describe/get commands on specific discovered resources to extract configuration details

If a list command returns empty results, note "No [resource type] found" and skip inspection.

## Cloud Evidence Table Format

Cloud evidence uses a **6-column format** (adds Service and Region vs the codebase 5-column format):

```markdown
| Control | Extracted Value | Service | Region | Command | Raw Evidence |
|---------|----------------|---------|--------|---------|-------------|
| Password policy min length | **14 characters** | AWS IAM | global | `aws iam get-account-password-policy` | `"MinimumPasswordLength": 14` |
| RDS encryption | **enabled, KMS** | AWS RDS | us-east-1 | `aws rds describe-db-instances` | `"StorageEncrypted": true` |
```

- Bold extracted values in the **Extracted Value** column
- Use the `Command` column as the source reference (replaces File + Line from codebase format)
- Always include the region (use "global" for region-independent services like IAM)

Use extracted values in policy text:
- "IAM password policy requires a minimum of **14 characters** (see `aws iam get-account-password-policy`)"
- "RDS instances use **AES-256 encryption with KMS** in **us-east-1** (see `aws rds describe-db-instances`)"

Append to all cloud evidence sections:
> *Values extracted from live cloud infrastructure. These represent point-in-time configuration. Re-scan and verify before audit submission.*

## Output Parsing

Use `--output json` (AWS/Azure) or `--format=json` (GCP) for parseable output. Reference extracted values using JSON path notation:

- AWS: `.PasswordPolicy.MinimumPasswordLength`
- GCP: `.settings.backupConfiguration.enabled`
- Azure: `.properties.encryption.services.blob.enabled`

## IaC vs Live Drift Detection

When both codebase (IaC) and cloud (live) values exist for the same control, compare them:

| Scenario | Action |
|----------|--------|
| **Match** | Report the value once, note both sources |
| **Mismatch** | Flag with `MISMATCH` warning, report both values |
| **IaC only** | Note as "configured in code, not verified against live infrastructure" |
| **Cloud only** | Note as "detected in live infrastructure, no corresponding IaC found" |

Use this comparison table format when both sources exist:

```markdown
### IaC vs Live Infrastructure Comparison

| Control | IaC Value | Cloud Value | Status |
|---------|-----------|-------------|--------|
| RDS backup retention | **30 days** (`infrastructure/rds.tf:38`) | **30 days** (`aws rds describe-db-instances`) | Match |
| S3 encryption | **SSE-KMS** (`infrastructure/s3.tf:15`) | **SSE-S3** (`aws s3api get-bucket-encryption`) | MISMATCH |
```
