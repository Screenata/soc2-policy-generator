# Data Management Scanning Patterns (CC6.5-6.7)

For policy: **Data Management** (`data-management`)
See [shared.md](shared.md) for evidence formatting and value usage guidelines.

## Basic Detection

**Encryption at Rest:**
```
Glob: **/*.{tf,yaml,yml,json}, **/config/**, **/infrastructure/**
Grep: encryption.*(enabled|at.?rest)|encrypted.*true|kms|storage.?encrypted|aes.?256|server.?side.?encryption
```

## Deep Scanning (Value Extraction)

### Encryption Specifics

Extract encryption algorithm, key size, mode, and KMS configuration.

**Find files:**
```
Glob: **/*.{tf,yaml,yml,json}, **/config/**/*.{ts,js,py,go}, **/utils/**/*crypt*.*, **/infrastructure/**/*.*, **/*encrypt*.*, **/*crypto*.*, **/*kms*.*
```

**Extract values:**
```
Grep: (?:algorithm|cipher)\s*[:=]\s*['"]?(aes-(?:128|192|256)-(?:cbc|gcm|ctr|ecb))['"]?  → encryption algorithm (Node.js)
Grep: (?:key[_\-]?(?:size|length|bits))\s*[:=]\s*(\d+)  → key size in bits
Grep: sse_algorithm\s*=\s*["']?(aws:kms|AES256)["']?  → AWS S3 encryption algorithm
Grep: storage_encrypted\s*=\s*(true)  → RDS encryption enabled
Grep: kms_key_id\s*=\s*["']?(\S+)["']?  → KMS key reference
Grep: (?:encryptionType|encryption_type|ENCRYPTION_ALGORITHM)\s*[:=]\s*['"]([A-Za-z0-9_-]+)['"]  → encryption type string
```

**Use in policy text:**
- Instead of: "Data at rest is encrypted using industry-standard encryption"
- Write: "Data at rest is encrypted using **AES-256-GCM** for application-level encryption (see `src/utils/crypto.ts:18`) and **AWS KMS** for database encryption (see `infrastructure/rds.tf:42`). S3 buckets use **SSE-KMS** server-side encryption (see `infrastructure/s3.tf:15`)."

### Backup and Retention Configuration

Extract backup frequency, retention periods, point-in-time recovery, and lifecycle rules.

**Find files:**
```
Glob: **/*.tf, **/infrastructure/**/*.*, **/terraform/**/*.*, **/config/**/*.{yaml,yml,json}, **/*backup*.*, **/*retention*.*, **/*lifecycle*.*
```

**Extract values:**
```
Grep: backup_retention_period\s*=\s*(\d+)  → RDS backup retention (days)
Grep: (?:backup_window|preferred_backup_window)\s*=\s*["'](\d{2}:\d{2}-\d{2}:\d{2})["']  → RDS backup window
Grep: point_in_time_recovery\s*[:=]\s*(true|enabled)  → PITR enabled
Grep: retention_in_days\s*=\s*(\d+)  → CloudWatch log retention (days)
Grep: (?:LOG_RETENTION|log[_\-]?retention|retentionDays|retention_days)\s*[:=]\s*['"]?(\d+)['"]?  → log retention (days)
Grep: (?:days|expiration)\s*[:=]\s*(\d+)  → S3 lifecycle expiration (days) — use in lifecycle context
Grep: schedule\s*=\s*["']cron\(([^)]+)\)["']  → AWS Backup schedule (cron expression)
```

**Use in policy text:**
- Instead of: "Data backups are performed regularly"
- Write: "Database backups are performed **daily during the 03:00-04:00 UTC window** with **30-day retention** (see `infrastructure/rds.tf:36-38`). **Point-in-time recovery is enabled** (see `infrastructure/rds.tf:40`). Application logs are retained for **90 days** in CloudWatch (see `infrastructure/cloudwatch.tf:12`)."

## Example Evidence Table

| Control | Extracted Value | File | Line | Raw Evidence |
|---------|----------------|------|------|-------------|
| Encryption algorithm | **AES-256-GCM** | src/utils/crypto.ts | 18 | `algorithm: 'aes-256-gcm'` |
| S3 encryption | **SSE-KMS** | infrastructure/s3.tf | 15 | `sse_algorithm = "aws:kms"` |
| RDS encryption | **enabled, KMS** | infrastructure/rds.tf | 42 | `storage_encrypted = true` |
| Backup retention | **30 days** | infrastructure/rds.tf | 38 | `backup_retention_period = 30` |
| Log retention | **90 days** | infrastructure/cloudwatch.tf | 12 | `retention_in_days = 90` |

## Cloud Scanning Cross-Reference

For live infrastructure evidence related to data management:
- AWS: S3 encryption, RDS encryption/backups, KMS keys, CloudWatch retention -- see [aws.md](aws.md#data-management-cc65-67)
- GCP: Cloud SQL backups, KMS keys, Cloud Storage -- see [gcp.md](gcp.md#data-management-cc65-67)
- Azure: Storage account encryption, SQL database, Key Vault -- see [azure.md](azure.md#data-management-cc65-67)
