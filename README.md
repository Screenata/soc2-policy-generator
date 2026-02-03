# SOC 2 Policy Generator

An AI agent skill that generates draft SOC 2 Type I/II policy documents for startups, with optional codebase scanning for evidence.

## What It Does

- Generates 17 SOC 2 policies covering all Trust Services Criteria
- Tailors policies to your company size, industry, and practices
- **Scans codebase for security patterns** (auth, encryption, CI/CD) and includes file:line references
- Includes evidence checklists with auditor sufficiency criteria
- Uses audit-safe language that under-claims to reduce risk

## Usage

Works with any agent that supports the [Agent Skills](https://agentskills.io) format:
- Claude Code
- Cursor
- Other compatible agents

Just say: "Generate SOC 2 policies"

## Policies Included

1. Governance & Board Oversight
2. Organizational Structure
3. Code of Conduct & Ethics
4. Information Security Policy
5. Incident Response
6. External Communications
7. Vendor Management
8. Risk Management
9. Change Management
10. Access Control
11. Data Management
12. Physical Security
13. Vulnerability & Monitoring
14. Network Security
15. Business Continuity
16. Human Resources
17. Mobile & Endpoint

## Codebase Scanning

When enabled, the skill scans your codebase for security patterns and includes concrete file:line references in generated policies:

| Pattern | Policy | What It Detects |
|---------|--------|-----------------|
| Auth middleware | Access Control | `withAuth`, `requireAuth`, JWT validation |
| MFA config | Access Control | `mfa`, `2fa`, `totp`, authenticator setup |
| Encryption | Data Management | AWS KMS, `encrypted = true`, AES-256 |
| TLS/SSL | Network Security | SSL certs, HTTPS enforcement, TLS config |
| CI/CD | Change Management | GitHub Actions, GitLab CI, Jenkins |
| Lockfiles | Vulnerability Monitoring | package-lock.json, yarn.lock, etc. |

Example output when scanning detects patterns:

```markdown
## Evidence from Codebase

| File | Line | Pattern | Description |
|------|------|---------|-------------|
| src/middleware/auth.ts | 15 | JWT | `jwt.verify(token, secret)` |
| infrastructure/rds.tf | 42 | Encryption | `storage_encrypted = true` |
```

## Example Output

Each policy includes an evidence table with sufficiency criteria:

```markdown
## Proof Required Later

| Status | Evidence | Type | Description |
|--------|----------|------|-------------|
| [ ] | MFA enforcement | Screenshot | IdP admin showing MFA required. Must show: policy enabled, scope = all users, no exceptions |
| [ ] | Access review | Log | Export showing completed review. Must show: reviewer, date, users reviewed, action taken |
```

## Structure

```
soc2-policy-generator/
├── README.md
├── SKILL.md              # Main skill instructions
├── references/
│   └── policies.md       # 17 policy definitions with questions
└── assets/
    └── policy-template.md
```

## License

MIT

## About

Created by [Screenata](https://screenata.com) - Automated SOC 2 evidence collection.

These policies are drafts. The real work is proving they're implemented.
