# GitHub Actions Workflow Templates for SOC 2 Evidence Collection

Generate GitHub Actions workflows that automate evidence collection for SOC 2 policies. These workflows run the same scanning patterns used during policy generation (Step 2/5) on a recurring schedule.

## Workflow Types

Generate two workflows:

| Workflow File | Trigger | What It Does |
|--------------|---------|-------------|
| `soc2-code-scan.yml` | PR + weekly + manual | Runs Glob/Grep patterns against the codebase, outputs 5-column evidence tables |
| `soc2-cloud-scan.yml` | Weekly/monthly + manual | Runs cloud CLI commands, outputs 6-column evidence tables |

Only generate `soc2-cloud-scan.yml` if the user chose "Code + Cloud" in Step 2.

## Schedule Mapping

Map policies to scan frequencies based on typical audit expectations:

| Frequency | Cron | Policies |
|-----------|------|----------|
| Weekly | `0 0 * * 1` (Monday 00:00 UTC) | vulnerability-monitoring, network-security, access-control |
| Monthly | `0 0 1 * *` (1st of month) | data-management, change-management, incident-response, business-continuity |
| On demand | `workflow_dispatch` | All policies (always include this trigger) |

## Output Structure

All evidence files go to `soc2-evidence/` in the repository root:

```
soc2-evidence/
  code/
    access-control-evidence.md
    change-management-evidence.md
    network-security-evidence.md
    vulnerability-monitoring-evidence.md
    data-management-evidence.md
  cloud/
    aws-evidence.md
    aws-evidence.json
    gcp-evidence.md         (if applicable)
    gcp-evidence.json
    azure-evidence.md       (if applicable)
    azure-evidence.json
  drift/
    drift-report.md         (IaC vs live comparison)
  README.md                 (auto-generated index with timestamps)
```

## Evidence File Format

### Markdown Evidence Files

Each file starts with a metadata header, then evidence tables matching the policy template formats.

**Code evidence (`soc2-evidence/code/{policy-id}-evidence.md`):**
```markdown
# {Policy Name} - Code Evidence

> Scan date: {YYYY-MM-DD HH:MM UTC}
> Git SHA: {short sha}
> Workflow: soc2-code-scan.yml

| Control | Extracted Value | File | Line | Raw Evidence |
|---------|----------------|------|------|-------------|
| ... | ... | ... | ... | ... |
```

**Cloud evidence (`soc2-evidence/cloud/{provider}-evidence.md`):**
```markdown
# {Provider} Cloud Infrastructure Evidence

> Scan date: {YYYY-MM-DD HH:MM UTC}
> Region: {scanned region(s)}
> Workflow: soc2-cloud-scan.yml

| Control | Extracted Value | Service | Region | Command | Raw Evidence |
|---------|----------------|---------|--------|---------|-------------|
| ... | ... | ... | ... | ... | ... |
```

### JSON Evidence Files

Mirror the table structure for programmatic access:

```json
{
  "scan_date": "2024-01-15T00:00:00Z",
  "provider": "aws",
  "region": "us-east-1",
  "evidence": [
    {
      "control": "Password min length",
      "value": "14 characters",
      "service": "AWS IAM",
      "command": "aws iam get-account-password-policy",
      "raw": "{\"MinimumPasswordLength\": 14}"
    }
  ]
}
```

### Drift Report (`soc2-evidence/drift/drift-report.md`)

Generated when both code and cloud evidence exist:

```markdown
# IaC vs Live Infrastructure Drift Report

> Generated: {YYYY-MM-DD HH:MM UTC}

| Control | IaC Value | Cloud Value | Status |
|---------|-----------|-------------|--------|
| RDS backup retention | **30 days** | **30 days** | Match |
| S3 encryption | **SSE-KMS** | **SSE-S3** | MISMATCH |
```

### Evidence README (`soc2-evidence/README.md`)

Auto-generated index:

```markdown
# SOC 2 Evidence Collection

Automated evidence collected by GitHub Actions workflows.

## Latest Scans

| Evidence File | Last Updated | Workflow |
|--------------|-------------|----------|
| [Access Control (Code)](code/access-control-evidence.md) | 2024-01-15 | soc2-code-scan |
| [AWS Cloud](cloud/aws-evidence.md) | 2024-01-15 | soc2-cloud-scan |
| [Drift Report](drift/drift-report.md) | 2024-01-15 | soc2-cloud-scan |

## Workflows

- **Code Scan**: Runs weekly (Monday) and on every PR
- **Cloud Scan**: Runs weekly (Monday) with manual dispatch available
```

---

## Code Scan Workflow Template (`soc2-code-scan.yml`)

Use the YAML template at [assets/workflow-soc2-code-scan.yml.template](../assets/workflow-soc2-code-scan.yml.template) as the base structure.

**Customization rules:**
- Only include steps for policies the user has generated
- Each policy gets its own step with the relevant grep/glob patterns from `references/scanning-patterns/{policy-id}.md`
- Translate Glob patterns to `find` commands and Grep patterns to `grep -rE` commands
- Format output as markdown tables using `echo` and shell string formatting
- Final step commits all evidence files to the `soc2-evidence/code/` directory

**Example step for access-control policy:**
```yaml
- name: Scan Access Control patterns
  run: |
    echo "# Access Control - Code Evidence" > soc2-evidence/code/access-control-evidence.md
    echo "" >> soc2-evidence/code/access-control-evidence.md
    echo "> Scan date: $(date -u '+%Y-%m-%d %H:%M UTC')" >> soc2-evidence/code/access-control-evidence.md
    echo "> Git SHA: ${GITHUB_SHA::8}" >> soc2-evidence/code/access-control-evidence.md
    echo "" >> soc2-evidence/code/access-control-evidence.md
    echo "| Control | Extracted Value | File | Line | Raw Evidence |" >> soc2-evidence/code/access-control-evidence.md
    echo "|---------|----------------|------|------|-------------|" >> soc2-evidence/code/access-control-evidence.md

    # Auth middleware detection
    grep -rnE 'withAuth|requireAuth|isAuthenticated|authMiddleware' --include='*.ts' --include='*.js' src/ \
      | head -5 \
      | while IFS=: read -r file line match; do
          echo "| Auth middleware | **detected** | $file | $line | \`$(echo "$match" | head -c 60)\` |"
        done >> soc2-evidence/code/access-control-evidence.md

    # Password minimum length
    grep -rnE 'min(?:imum)?[_-]?(?:length|len).*[:=]\s*(\d+)' --include='*.ts' --include='*.js' --include='*.json' . \
      | head -3 \
      | while IFS=: read -r file line match; do
          value=$(echo "$match" | grep -oE '[0-9]+' | tail -1)
          echo "| Password min length | **${value} characters** | $file | $line | \`$(echo "$match" | xargs | head -c 60)\` |"
        done >> soc2-evidence/code/access-control-evidence.md

    # (additional patterns from access-control.md...)
```

---

## Cloud Scan Workflow Template (`soc2-cloud-scan.yml`)

Generate this workflow based on the cloud providers available. Structure:

```yaml
name: SOC 2 Cloud Evidence Collection
on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly Monday
  workflow_dispatch:
    inputs:
      region:
        description: 'AWS region to scan'
        default: 'us-east-1'
        type: string

permissions:
  contents: write  # To commit evidence files

# Include only the jobs for providers the user configured
jobs:
  aws-scan:      # Include if AWS was selected
  gcp-scan:      # Include if GCP was selected
  azure-scan:    # Include if Azure was selected
  drift-check:   # Include if both code and cloud scanning
```

**AWS job template:**
```yaml
aws-scan:
  runs-on: ubuntu-latest
  env:
    AWS_REGION: ${{ inputs.region || 'us-east-1' }}
  steps:
    - uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Verify AWS authentication
      run: aws sts get-caller-identity

    - name: Initialize evidence file
      run: |
        mkdir -p soc2-evidence/cloud
        cat > soc2-evidence/cloud/aws-evidence.md << 'HEADER'
        # AWS Cloud Infrastructure Evidence

        > Scan date: $(date -u '+%Y-%m-%d %H:%M UTC')
        > Region: ${{ env.AWS_REGION }}
        > Workflow: soc2-cloud-scan.yml
        HEADER

    - name: Scan IAM Password Policy
      run: |
        result=$(aws iam get-account-password-policy --output json 2>&1) || true
        if echo "$result" | jq -e '.PasswordPolicy' > /dev/null 2>&1; then
          min_length=$(echo "$result" | jq -r '.PasswordPolicy.MinimumPasswordLength')
          max_age=$(echo "$result" | jq -r '.PasswordPolicy.MaxPasswordAge')
          echo "| Password min length | **${min_length} characters** | AWS IAM | global | \`aws iam get-account-password-policy\` | \`MinimumPasswordLength: ${min_length}\` |" >> soc2-evidence/cloud/aws-evidence.md
        fi

    # (additional scan steps from aws.md...)

    - name: Commit evidence
      run: |
        git config user.name "github-actions[bot]"
        git config user.email "github-actions[bot]@users.noreply.github.com"
        git add soc2-evidence/
        git diff --staged --quiet || git commit -m "chore: update SOC 2 cloud evidence [skip ci]"
        git push
```

**GCP job template:**
```yaml
gcp-scan:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Authenticate to GCP
      uses: google-github-actions/auth@v2
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v2

    # (scan steps from gcp.md...)
```

**Azure job template:**
```yaml
azure-scan:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v2
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    # (scan steps from azure.md...)
```

---

## Secrets Setup Guide

Include this in the output when generating workflows:

### AWS Secrets

| Secret Name | Value | How to Get |
|------------|-------|-----------|
| `AWS_ACCESS_KEY_ID` | IAM access key | Create a read-only IAM user with the policy below |
| `AWS_SECRET_ACCESS_KEY` | IAM secret key | Paired with the access key above |

**Minimum IAM Policy (read-only):**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListVirtualMFADevices",
      "iam:ListRoles",
      "s3:ListAllMyBuckets",
      "s3:GetEncryptionConfiguration",
      "rds:DescribeDBInstances",
      "kms:ListKeys",
      "kms:DescribeKey",
      "kms:GetKeyRotationStatus",
      "logs:DescribeLogGroups",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeListeners",
      "ec2:DescribeSecurityGroups",
      "wafv2:ListWebACLs",
      "cloudfront:ListDistributions",
      "cloudfront:GetDistribution",
      "ecr:DescribeRepositories",
      "securityhub:DescribeHub",
      "guardduty:ListDetectors",
      "config:DescribeConfigRules",
      "backup:ListBackupPlans",
      "cloudwatch:DescribeAlarms",
      "cloudtrail:DescribeTrails",
      "sns:ListTopics",
      "codepipeline:ListPipelines"
    ],
    "Resource": "*"
  }]
}
```

Recommend: Use **GitHub OIDC** with `aws-actions/configure-aws-credentials@v4` and an IAM role instead of static keys for better security.

### GCP Secrets

| Secret Name | Value | How to Get |
|------------|-------|-----------|
| `GCP_SA_KEY` | Service account JSON (base64) | Create a service account with `roles/viewer` |

### Azure Secrets

| Secret Name | Value | How to Get |
|------------|-------|-----------|
| `AZURE_CREDENTIALS` | Service principal JSON | `az ad sp create-for-rbac --role Reader --scopes /subscriptions/{id}` |

---

## Additive Workflow Generation

When the user generates multiple policies across sessions:

1. **Check if workflows already exist**: Read `.github/workflows/soc2-code-scan.yml` and `soc2-cloud-scan.yml`
2. **If they exist**: Add new policy steps to the existing workflow rather than overwriting
3. **If they don't exist**: Create new workflow files from the templates
4. **Deduplication**: If a policy's steps are already present, skip adding them again

This ensures the workflows grow incrementally as more policies are generated.
