---
name: compliance-automation
description: Generate draft compliance policy documents (SOC 2, ISO 27001) with codebase, cloud, and SaaS scanning for evidence, automated GitHub Actions workflows for recurring evidence collection, auditor control matrix response mapping, audit readiness assessments, and SOC 2 orientation for newcomers. Use when the user needs compliance policies, evidence collection, audit preparation, readiness assessment, gap analysis, SOC 2 explanation, or wants to respond to a security questionnaire or control matrix.
license: MIT
metadata:
  author: screenata
  version: "3.0"
---

# Compliance Automation

Generate compliance policies, automate evidence collection, assess audit readiness, and respond to auditor control matrices — all from one skill.

## Important Disclaimer

**GENERATED DRAFTS ONLY** - All policies and responses require human review before use. These are starting points, not audit-ready documents.

## When to Use This Skill

Use this skill when the user:
- Needs to create compliance policies (SOC 2, ISO 27001, or both)
- Mentions SOC 2 certification, ISO 27001 certification, or audit preparation
- Asks for security policy templates or compliance documentation
- Wants to set up automated evidence collection or GitHub Actions workflows
- Pastes an auditor's control matrix or security questionnaire
- Asks to respond to a vendor security questionnaire (SIG, CAIQ, or custom)
- Wants to assess audit readiness, run a gap analysis, or understand compliance posture
- Is new to SOC 2 and wants to understand the basics before starting

## Routing

Detect what the user needs and load the appropriate workflow:

### Route A: External Document Response

**Check FIRST** — before starting the normal policy workflow, check if the user is providing an external compliance document. Route here if ANY of these signals are present:

- **Keywords:** "control matrix", "test plan", "security questionnaire", "SIG", "CAIQ", "vendor questionnaire", "RFP", "auditor requirements", "respond to this", "map this to our compliance"
- **Structural signals:** tabular or list format with 10+ items, numbered test IDs (e.g., "1.1", "TST-003"), control codes (e.g., "CC6.1", "A.5.15"), compliance-oriented descriptions
- **Explicit request:** "here's what our auditor needs", "can you generate responses to this"

**If detected →** Load [references/workflow-responses.md](references/workflow-responses.md) and follow its steps.

### Route B: Evidence Collection

Route here if the user specifically asks about evidence collection without needing policies first:

- **Keywords:** "set up evidence collection", "automate compliance monitoring", "GitHub Actions for compliance", "evidence scripts", "configure SaaS tools for compliance"

**If detected →** Load [references/workflow-evidence.md](references/workflow-evidence.md) and follow its steps.

### Route D: Audit Readiness Assessment

Route here if the user wants to understand their current compliance posture before generating policies:

- **Keywords:** "how ready are we", "readiness assessment", "gap analysis", "compliance gaps", "assess our compliance", "compliance posture", "what's missing", "pre-audit check", "compliance scan", "where do we stand", "security assessment", "audit readiness"
- **Structural signals:** User asks an evaluative question about their current state rather than requesting a specific artifact (policy, script, response)
- **Explicit request:** "scan my codebase for compliance", "show me our gaps", "run an assessment"

**If detected →** Load [references/workflow-assessment.md](references/workflow-assessment.md) and follow its steps.

### Route E: Orientation & Getting Started

Route here if the user is new to compliance or asking foundational questions:

- **Keywords:** "what is SOC 2", "where do I start", "new to compliance", "SOC 2 101", "explain SOC 2", "how does SOC 2 work", "getting started", "first time", "help me understand", "what do I need for SOC 2"
- **Structural signals:** User asks broad/foundational questions rather than requesting a specific artifact (policy, script, response) or action
- **Explicit request:** "walk me through SOC 2", "I don't know where to begin"

**If detected →** Load [references/workflow-orientation.md](references/workflow-orientation.md) and follow its steps.

### Route C: Policy Generation (default)

If none of Routes A, B, D, or E match, this is the default. The user wants to generate policies:

- **Keywords:** "generate policies", "SOC 2", "ISO 27001", "compliance policies", "security policies", "audit preparation"

**First-time user nudge:** If Route C triggers AND `.compliance/config.json` does not exist, present this choice before starting the policy workflow:

> Before generating policies, I'd recommend starting with a **readiness assessment** to understand where you stand. This takes about 5 minutes and scans your codebase for existing controls.
>
> Would you like to:
> 1. Run a readiness assessment first (recommended)
> 2. Jump straight to policy generation
> 3. Get a quick orientation on how SOC 2 works

- If **option 1** → Load [references/workflow-assessment.md](references/workflow-assessment.md) and follow its steps
- If **option 2** → Load [references/workflow-policies.md](references/workflow-policies.md) and follow its steps
- If **option 3** → Load [references/workflow-orientation.md](references/workflow-orientation.md) and follow its steps

**If `.compliance/config.json` already exists**, skip the nudge and load [references/workflow-policies.md](references/workflow-policies.md) directly.

**After policies are generated**, the user may continue to evidence collection (Route B) or receive an external document (Route A). The workflows interconnect through the `.compliance/` directory.

## Session State

**CRITICAL: All session state MUST be written to the `.compliance/` folder.** Do NOT rely on in-memory context, agent-internal files, or conversation history.

**CRITICAL: This is a conversational flow. Ask ONE question, wait for answer, then ask the next. NEVER list multiple questions in a single message.**

```
.compliance/
├── config.json               # Company context — created during onboarding, read by all workflows
├── status.md                 # Progress tracking — updated by all workflows
├── assessment.md             # Readiness assessment report (generated by assessment workflow)
├── secrets.env               # API tokens (must be in .gitignore)
├── tasks/                    # Filesystem task queue for tracking work items
│   └── {task-id}.md          # See references/task-system.md
├── answers/{policy-id}.md    # Per-policy Q&A answers (editable before generation)
├── policies/{policy-id}.md   # Generated policy documents
├── scripts/                  # Evidence collection scripts + configs
├── evidence/                 # Collected evidence
│   ├── code/                 # Codebase scan results
│   ├── cloud/                # Cloud infrastructure results
│   ├── saas/                 # SaaS tool results
│   └── manual/{policy-id}/   # User-collected evidence
└── responses/                # Auditor response mappings
    ├── {name}-raw.md          # Parsed input document
    ├── {name}.md              # Draft response document
    └── {name}-filled.xlsx     # Filled spreadsheet
```

## Output Format

### File Header

Every policy file MUST start with:

```markdown
<!--
GENERATED DRAFT ONLY - USER REVIEW REQUIRED

- Not audit-ready
- Not legally binding
- Not a substitute for professional audits

Review, edit, and own all content.
-->
```

### File Footer

Every policy MUST end with:

```markdown
---
**Policy Safety Note:** This draft deliberately under-claims to reduce risk.
Auditors may require stronger language + evidence of operation.

---
Generated with [Compliance Automation](https://github.com/screenata/compliance-automation)
```

### Evidence Types

| Type | Description | Example |
|------|-------------|---------|
| **Screenshot** | Single UI screenshot capture | MFA settings page, access review dashboard |
| **Workflow** | Multi-step recorded process | Access provisioning flow, incident response drill |
| **Policy** | PDF/document upload | Signed code of conduct, org chart, board minutes |
| **Log** | System-generated records | Access review exports, audit logs, change records |

Format evidence requirements as a table with a Status checkbox column. Include **sufficiency criteria** in the Description:

```markdown
## Proof Required Later

| Status | Evidence | Type | Description |
|--------|----------|------|-------------|
| [ ] | MFA enforcement settings | Screenshot | IdP admin console showing MFA required. Must show: policy enabled, scope = all users, no exceptions |
| [ ] | Access provisioning ticket | Workflow | Recording of approval flow. Must show: request, manager approval, IT provisioning, access granted |
```

## Reference Index

### Workflow Details
| Workflow | File | When to Load |
|----------|------|-------------|
| Policy Generation | [workflow-policies.md](references/workflow-policies.md) | User wants to generate policies (Steps 1-6) |
| Evidence Collection | [workflow-evidence.md](references/workflow-evidence.md) | User wants evidence scripts + GitHub Actions |
| Document Response | [workflow-responses.md](references/workflow-responses.md) | User provides a control matrix or questionnaire |
| Audit Readiness Assessment | [workflow-assessment.md](references/workflow-assessment.md) | User wants to assess compliance posture or run a gap analysis |
| Orientation | [workflow-orientation.md](references/workflow-orientation.md) | User is new to SOC 2 and needs foundational understanding |

### Codebase Scanning
| Policy | Scanning File | SOC 2 TSC | ISO 27001 Annex A |
|--------|--------------|-----------|-------------------|
| Access Control | [access-control.md](references/scanning-patterns/access-control.md) | CC6.1-6.3 | A.5.15-5.18, A.8.2-8.3, A.8.5 |
| Data Management | [data-management.md](references/scanning-patterns/data-management.md) | CC6.5-6.7 | A.5.9-5.13, A.8.10-8.12 |
| Network Security | [network-security.md](references/scanning-patterns/network-security.md) | CC6.6-6.7, CC7.1 | A.8.20-8.22, A.8.24 |
| Change Management | [change-management.md](references/scanning-patterns/change-management.md) | CC8.1 | A.8.9, A.8.25, A.8.32 |
| Vulnerability & Monitoring | [vulnerability-monitoring.md](references/scanning-patterns/vulnerability-monitoring.md) | CC7.1-7.2 | A.5.7, A.8.8, A.8.16 |

Shared guidelines: [shared.md](references/scanning-patterns/shared.md). SaaS detection: [saas-detection.md](references/scanning-patterns/saas-detection.md).

### Cloud Scanning
| Provider | Scanning File | Covers |
|----------|--------------|--------|
| AWS | [aws.md](references/scanning-patterns/aws.md) | IAM, S3, RDS, KMS, ELB, EC2, WAF, ECR, SecurityHub, GuardDuty, CloudTrail, Backup |
| GCP | [gcp.md](references/scanning-patterns/gcp.md) | IAM, Cloud SQL, KMS, SSL Policies, Firewall, Cloud Armor, SCC |
| Azure | [azure.md](references/scanning-patterns/azure.md) | Azure AD, RBAC, Storage, SQL, NSG, App Gateway, Defender |

Shared cloud guidelines: [cloud-shared.md](references/scanning-patterns/cloud-shared.md)

### SaaS Integrations
| Category | File | Tools |
|----------|------|-------|
| Identity & Access | [identity.md](references/saas-integrations/identity.md) | Okta, Auth0, Google Workspace, JumpCloud |
| Monitoring & Alerting | [monitoring.md](references/saas-integrations/monitoring.md) | Datadog, PagerDuty, New Relic, Splunk |
| Project & Change Mgmt | [project-management.md](references/saas-integrations/project-management.md) | Jira, Linear, GitHub |
| Communications | [communications.md](references/saas-integrations/communications.md) | Slack, Opsgenie, Statuspage |
| HR & People | [hr.md](references/saas-integrations/hr.md) | BambooHR, Gusto, Rippling |
| Endpoint Management | [endpoint.md](references/saas-integrations/endpoint.md) | Jamf, Kandji, Intune |
| Security Scanning | [security.md](references/saas-integrations/security.md) | Snyk, SonarCloud |

Shared SaaS guidelines: [shared.md](references/saas-integrations/shared.md)

### Other References
| Reference | File |
|-----------|------|
| Policy template | [assets/policy-template.md](assets/policy-template.md) |
| Assessment template | [assets/assessment-template.md](assets/assessment-template.md) |
| Script conventions | [references/script-templates.md](references/script-templates.md) |
| Workflow templates | [references/workflow-templates.md](references/workflow-templates.md) |
| Framework: SOC 2 | [references/frameworks/soc2.md](references/frameworks/soc2.md) |
| Framework: ISO 27001 | [references/frameworks/iso27001.md](references/frameworks/iso27001.md) |
| Policy questions | [references/policies.md](references/policies.md) |
| Task system | [references/task-system.md](references/task-system.md) |
| Small-team controls | [references/small-team-controls.md](references/small-team-controls.md) |
| Evidence scripts | [assets/scripts/](assets/scripts/) |

## Important Notes

- **NEVER batch questions** — ask ONE question per message, wait for answer
- Generate ONE policy at a time
- Use the user's actual answers to customize procedures
- Tailor complexity to company size (smaller = simpler controls)
- For healthcare/fintech, include relevant compliance alignment notes
- Always include placeholders like `[timeframe]`, `[owner name]` for values the user should fill in
- When scanning is enabled, extract concrete values and use them instead of placeholders. Reference with file:line
- When a concrete value is found, bold it in both the evidence table and the policy text
- **Cloud scanning safety**: Only run read-only CLI commands (describe, list, get, show). NEVER run commands that modify infrastructure. Never include secrets, private keys, or credential values in evidence output
- **SaaS scanning safety**: Only call read-only API endpoints (GET requests). Never call endpoints that create, update, or delete data. Redact PII — use counts and percentages instead of user lists. Never include API tokens in evidence output
- When evidence exists from multiple sources (code, cloud, SaaS), compare overlapping controls and flag drift/discrepancies with a cross-source comparison table
