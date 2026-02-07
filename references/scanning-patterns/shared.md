# Shared Scanning Guidelines

These guidelines apply to all policy scanning patterns. Read this file alongside the policy-specific scanning file.

## How to Scan

For each pattern group in a policy scanning file:
1. Use the Glob patterns to find candidate files
2. Run the Grep patterns against found files to extract values from capture groups
3. Record results in the enriched evidence table (see [Evidence Table Format](#evidence-table-format))
4. Use extracted values directly in policy procedure text instead of placeholders

## Value Usage Guidelines

When concrete values are extracted from the codebase:

1. **Replace placeholders** - Use extracted values in policy procedure text instead of `[placeholder]`. Bold the value: "Passwords must be a minimum of **12 characters**"
2. **Environment variables** - If the match is `process.env.SESSION_TIMEOUT` or `os.getenv("SESSION_TIMEOUT")`, note: "configured via environment variable — verify production value." If `.env.example` or `.env.sample` has a default, extract that and note it as "default/example value"
3. **Computed expressions** - Evaluate math like `60 * 30 * 1000` → 1,800,000 ms → 30 minutes. Present the human-readable form
4. **Conflicting values** - If the same control has different values in different files, report all with a warning: "⚠️ Multiple values found — verify which applies to production"
5. **Secrets** - Never include actual secrets, API keys, or key material in evidence. For KMS key ARNs, include the reference but not full ARN values
6. **Framework defaults** - Only report explicitly configured values, not assumed framework defaults

### Common Unit Conversions

| Raw Value | Human-Readable |
|-----------|---------------|
| 1800000 ms | 30 minutes |
| 3600000 ms | 1 hour |
| 86400000 ms | 24 hours |
| 900 seconds | 15 minutes |
| 3600 seconds | 1 hour |
| 86400 seconds | 24 hours |
| bcrypt rounds 10 | 2^10 = 1,024 iterations |
| bcrypt rounds 12 | 2^12 = 4,096 iterations |
| HSTS 31536000 seconds | 1 year |
| HSTS 15768000 seconds | 6 months |

## Evidence Table Format

Use the **5-column format** with extracted values bolded. Group findings by sub-heading when a policy has multiple control areas:

```markdown
## Evidence from Codebase

The following security configurations were detected and their concrete values extracted:

| Control | Extracted Value | File | Line | Raw Evidence |
|---------|----------------|------|------|-------------|
| [Control name] | **[value]** | [file path] | [line] | `[code snippet]` |
```

Use these extracted values directly in the Policy Procedures section:
- "Passwords must be a minimum of **12 characters** (see `src/validation/password.ts:18`)"
- "The **main** branch requires **2 approving reviews** (see `infrastructure/github.tf:48`)"

If only basic patterns are detected (presence without extractable values), fall back to:

```markdown
| File | Line | Pattern | Description |
|------|------|---------|-------------|
| .github/workflows/ci.yml | - | CI/CD | GitHub Actions pipeline configured |
```

*Always append: "Concrete values extracted during codebase scan. Verify values match production configuration before audit submission."*
