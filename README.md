# Compliance Automation

An AI agent skill that generates draft compliance policy documents (SOC 2, ISO 27001) for startups, with codebase scanning, cloud infrastructure scanning, SaaS tool integration, automated GitHub Actions evidence collection, auditor control matrix response mapping, and audit readiness assessments.

![Compliance policies and evidence workflows from a single conversation](https://github.com/user-attachments/assets/c49c4f7f-de8c-4c99-8d34-f0223297955d)

## What It Does

One skill, five workflows:

1. **Generate policies** — Answer questions, scan your codebase/cloud/SaaS for evidence, generate 17 draft policies with concrete values and audit-safe language
2. **Automate evidence collection** — Set up scripts for SaaS tools, cloud providers, and codebase scanning, wired into GitHub Actions for recurring collection
3. **Respond to auditors** — Map control matrices and security questionnaires to your policies, generate draft responses, write back to XLSX
4. **Assess audit readiness** — Scan your codebase, cloud, and SaaS for existing controls, score readiness (0-100%), identify gaps, and generate a remediation roadmap
5. **Get oriented** — Conversational SOC 2 101 for newcomers — what it is, what auditors expect, realistic costs and timelines

The skill routes automatically based on what you ask for. The `.compliance/` directory is the shared state — policies, evidence, and responses all live there and reference each other.

## Usage

Works with any agent that supports the [Agent Skills](https://agentskills.io) format (Claude Code, Codex, OpenCode, Cursor, Windsurf).

**Option 1: Install via CLI**
```bash
npx skills add https://github.com/screenata/compliance-automation --skill compliance-automation
```

**Option 2: Manual install**

Copy the skill to your project's `.claude/skills/` folder.

Then just say: "Generate compliance policies", "Set up evidence collection", "How ready are we for SOC 2?", or paste a control matrix.

## Policies Included

17 policies covering SOC 2 Trust Services Criteria and ISO 27001:2022 Annex A: Governance, Organizational Structure, Code of Conduct, Information Security, Incident Response, External Communications, Vendor Management, Risk Management, Change Management, Access Control, Data Management, Physical Security, Vulnerability & Monitoring, Network Security, Business Continuity, Human Resources, and Mobile & Endpoint.

## Codebase Scanning

Extracts concrete values from your codebase — not just "auth exists" but "bcrypt uses 12 rounds":

| Policy | What It Extracts |
|--------|-----------------|
| Access Control | Password min length, bcrypt/argon2 config, RBAC roles, JWT expiry, session timeout, rate limits, account lockout |
| Data Management | Encryption algorithms (AES-256-GCM), KMS keys, backup retention periods, log retention |
| Network Security | TLS versions, SSL policies, CORS origins, HSTS config, CSP directives |
| Change Management | Required reviewers, status checks, CI/CD stages, security scanning tools (Snyk/Trivy/CodeQL) |
| Vulnerability Monitoring | Scan schedules, severity thresholds, audit levels, Dependabot config |

## Cloud Infrastructure Scanning

Scans live AWS, GCP, and Azure environments using CLI tools (read-only commands only):

| Provider | What It Scans |
|----------|--------------|
| AWS | IAM password policy, MFA status, S3 encryption, RDS backups, KMS rotation, ALB TLS, security groups, WAF, ECR scanning, SecurityHub, GuardDuty, CloudTrail, Backup plans |
| GCP | IAM policies, Cloud SQL backups, KMS keys, SSL policies, firewall rules, Cloud Armor, Security Command Center |
| Azure | Conditional access, RBAC assignments, storage encryption, SQL TDE, Key Vault, NSGs, App Gateway WAF, Defender assessments |

## SaaS Tool Integration

| Category | Tools | Evidence Collected |
|----------|-------|-------------------|
| Identity & Access | Okta, Auth0, Google Workspace, JumpCloud | MFA enrollment rates, password policies, admin roles, deprovisioned users |
| Monitoring & Alerting | Datadog, PagerDuty, New Relic, Splunk | Active monitors, escalation policies, on-call schedules, incident metrics |
| Project & Change Mgmt | Jira, Linear, GitHub | Change ticket metrics, branch protection, PR review stats, Dependabot alerts |
| HR & People | BambooHR, Gusto, Rippling | Employee counts, termination tracking, policy compliance |
| Endpoint Management | Jamf, Kandji, Intune | Managed device counts, encryption status, compliance policies |
| Security Scanning | Snyk, SonarCloud | Vulnerability counts by severity, quality gate status, monitored projects |

## Automated Evidence Collection

Pre-built scripts for 26 tools ship in `assets/scripts/`. The agent copies them, configures, tests locally, then wires into GitHub Actions workflows:

- **Code scanning** — Weekly + on every PR, outputs to `.compliance/evidence/code/`
- **Cloud scanning** — Weekly/monthly, outputs to `.compliance/evidence/cloud/`
- **SaaS scanning** — Weekly, outputs to `.compliance/evidence/saas/`
- **Git audit trail** — Evidence files are committed with timestamps for audit history

## Small-Team Support

For teams with 10 or fewer employees, the skill automatically adapts. Instead of controls that assume dedicated security staff or multiple reviewers, it suggests auditor-accepted compensating controls — CI/CD as independent reviewer, vCISO arrangements, automated access reviews, and more. Policies are framed around what your team *does*, not what it lacks.

## Session Persistence

The skill tracks progress in the `.compliance/` folder (committed to your repo):

- **`.compliance/config.json`** — org context persists across conversations
- **`.compliance/status.md`** — policies generated, tools configured, workflows created
- **`.compliance/assessment.md`** — readiness score and gap analysis
- **`.compliance/answers/{policy}.md`** — per-policy Q&A answers (editable before generation)
- **`.compliance/responses/`** — auditor response mappings and filled spreadsheets

If a session ends mid-way, the next session picks up where you left off.

## Structure

```
compliance-automation/
├── SKILL.md                          # Router — detects intent, loads workflow
├── references/
│   ├── workflow-policies.md          # Policy generation steps (1-6)
│   ├── workflow-evidence.md          # Evidence collection steps
│   ├── workflow-responses.md         # Auditor response mapping steps
│   ├── workflow-assessment.md        # Audit readiness assessment steps
│   ├── workflow-orientation.md       # SOC 2 orientation for newcomers
│   ├── policies.md                   # 17 policy definitions with questions
│   ├── frameworks/
│   │   ├── soc2.md                  # SOC 2 TSC control mappings
│   │   └── iso27001.md              # ISO 27001 Annex A control mappings
│   ├── workflow-templates.md         # GitHub Actions generation guidelines
│   ├── script-templates.md           # Script conventions
│   ├── task-system.md                # Task queue specification
│   ├── saas-integrations/            # SaaS API patterns per category
│   └── scanning-patterns/            # Codebase + cloud scanning patterns
└── assets/
    ├── policy-template.md            # Output template with evidence formats
    ├── assessment-template.md        # Readiness assessment report template
    ├── workflow-*.yml.template       # GitHub Actions templates
    └── scripts/                      # 26 pre-built evidence collection scripts
```

**Generated at runtime** (committed to user's repo):
```
.compliance/
├── config.json               # Global config — persists across conversations
├── status.md                 # Progress tracking (policies, tools, workflows)
├── assessment.md             # Readiness assessment report (generated by assessment workflow)
├── secrets.env               # API tokens (DO NOT commit — in .gitignore)
├── tasks/                    # Filesystem task queue for tracking work items
├── answers/{policy-id}.md    # Per-policy Q&A answers (editable)
├── policies/{policy-id}.md   # Generated policy documents
├── scripts/                  # Evidence collection scripts + configs
├── evidence/                 # Collected evidence (code/, cloud/, saas/, manual/)
└── responses/                # Auditor response mappings + filled spreadsheets
```

## Procedural Evidence Collection

The automated workflows above collect API-based evidence such as configurations and user lists. For procedural evidence, [Screenata](https://screenata.com) provides an AI-agent powered browser automation tool with self-healing to reliably collect and monitor evidence such as:

- **Access reviews** — periodic user access verification in identity providers
- **Change approvals** — approval workflows and audit trails in ticketing systems
- **Security training completion** — training status and completion records from LMS platforms
- **Incident response drills** — documented runbook execution and response timelines
- **Backup restoration tests** — verified recovery procedures with timestamps
- **Vendor security reviews** — third-party risk assessment documentation

## License

MIT
