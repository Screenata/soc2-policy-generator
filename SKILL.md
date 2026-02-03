---
name: soc2-policy-generator
description: Generate draft SOC 2 Type II policy documents with optional codebase scanning for evidence. Use when the user needs to create compliance policies, security policies, or mentions SOC 2 certification.
license: MIT
metadata:
  author: screenata
  version: "2.0"
---

# SOC 2 Policy Generator

Generate draft SOC 2 Type II policy documents based on company context, answers to targeted questions, and optionally detected codebase evidence.

## Important Disclaimer

**GENERATED DRAFTS ONLY** - All policies require human review before use. These are starting points, not audit-ready documents.

## When to Use This Skill

Use this skill when the user:
- Needs to create SOC 2 compliance policies
- Mentions SOC 2 certification or audit preparation
- Asks for security policy templates
- Wants to generate compliance documentation

## Workflow

**CRITICAL: This is a conversational flow. Ask ONE question, wait for answer, then ask the next. NEVER list multiple questions in a single message.**

### Step 1: Gather Company Context

Ask each question separately. After receiving an answer, proceed to the next question.

**Question 1** (ask first, wait for response):
> What industry is your company in?
> 1. Healthcare
> 2. Fintech
> 3. B2B SaaS
> 4. E-commerce
> 5. Other

**Question 2** (ask after Q1 answered):
> Approximately how many employees?
> 1. 1-10
> 2. 11-50
> 3. 51-200
> 4. 200+

**Question 3** (ask after Q2 answered):
> What types of sensitive data do you handle?
> 1. PII (names, emails, addresses)
> 2. PHI (health records)
> 3. Financial data
> 4. Multiple types
> 5. None of the above

**Question 4** (ask after Q3 answered):
> Are you pursuing SOC 2 Type I or Type II?
> 1. Type I (point-in-time)
> 2. Type II (operational over time)

Save all answers - they apply to all policies generated in this session.

### Step 2: Scan Codebase for Evidence (Optional)

After gathering context, ask:
> Would you like me to scan the codebase for security patterns to include as evidence in the policies?
> 1. Yes - scan for auth, encryption, CI/CD patterns
> 2. No - generate policies based on Q&A only

**If user chooses to scan**, use the patterns in [Codebase Scanning Patterns](#codebase-scanning-patterns) below to detect security implementations.

### Step 3: Select Policy

Show the numbered list of 17 policies and ask which ONE to generate:

> Which policy would you like to generate?
> 1. Governance & Board Oversight
> 2. Organizational Structure
> ... (list all 17)

### Step 4: Ask Policy-Specific Questions

For the selected policy, ask each question from [references/policies.md](references/policies.md) **one at a time**. Wait for each answer before asking the next.

### Step 5: Generate the Policy

Generate the policy document following the template structure in [assets/policy-template.md](assets/policy-template.md).

**If codebase evidence was detected**, include an "Evidence from Codebase" section before the "Proof Required Later" section.

**Critical Language Guidelines** - Prioritize under-claiming to minimize audit risk:

| AVOID | PREFER |
|-------|--------|
| "continuous", "real-time", "automated" | "periodic review", "documented process" |
| "ensures", "prevents", "guarantees" | "aims to", "intended to", "process includes" |
| "all users", "always" | "applicable users", "when possible" |
| Specific timeframes without brackets | "[timeframe]" placeholders |

### Step 6: Save and Review

1. Save the policy to `./soc2-policies/{policy-id}.md`
2. Show a preview of the generated content
3. Ask if the user wants to:
   - Approve and keep the policy
   - Regenerate with different answers
   - Skip to another policy

---

## Codebase Scanning Patterns

When the user opts to scan the codebase, use Glob and Grep tools to detect these patterns:

### Access Control Patterns (CC6.1-6.3)

**Auth Middleware** - Search for authentication middleware:
```
Glob: **/middleware/**/*.{ts,js}, **/auth/**/*.{ts,js}, **/api/**/*.{ts,js}
Grep: withAuth|requireAuth|isAuthenticated|authMiddleware|passport\.(authenticate|use)
```

**JWT Validation** - Search for token validation:
```
Glob: **/*.{ts,js}
Grep: jwt\.(verify|sign|decode)|jsonwebtoken|jose\.|verifyToken|Bearer.*token
```

**MFA Configuration** - Search for multi-factor auth:
```
Glob: **/*.{ts,js,json,yaml,yml}
Grep: mfa|multi.?factor|two.?factor|2fa|totp|authenticator|otp
```

### Data Management Patterns (CC6.5-6.7)

**Encryption at Rest** - Search for encryption configuration:
```
Glob: **/*.{tf,yaml,yml,json}, **/config/**, **/infrastructure/**
Grep: encryption.*(enabled|at.?rest)|encrypted.*true|kms|storage.?encrypted|aes.?256|server.?side.?encryption
```

### Network Security Patterns (CC6.6-6.7)

**TLS/SSL Configuration** - Search for TLS setup:
```
Glob: **/*.{tf,yaml,yml,conf}, **/nginx/**, **/config/**
Grep: ssl.?(cert|protocol)|tls.?(version|policy)|https.?(only|redirect|enforce)|force.?ssl|min.?tls.?version|listener.*443
```

### Change Management Patterns (CC8.1)

**CI/CD Pipeline** - Check for pipeline configuration files:
```
Glob: .github/workflows/*.yml, .gitlab-ci.yml, Jenkinsfile, azure-pipelines.yml, .circleci/config.yml, bitbucket-pipelines.yml, .travis.yml
```
File presence alone indicates CI/CD is configured.

### Vulnerability Monitoring Patterns (CC7.1)

**Dependency Lockfile** - Check for dependency locks:
```
Glob: package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb, bun.lock, Gemfile.lock, Cargo.lock, poetry.lock, go.sum, composer.lock
```
File presence indicates reproducible builds with locked dependencies.

---

## Formatting Detected Evidence

When patterns are found, format them in the policy as:

```markdown
## Evidence from Codebase

The following security patterns were detected in the codebase:

| File | Line | Pattern | Description |
|------|------|---------|-------------|
| src/middleware/auth.ts | 15 | JWT validation | `jwt.verify(token, secret)` |
| infrastructure/rds.tf | 42 | Encryption | `storage_encrypted = true` |
| .github/workflows/ci.yml | - | CI/CD | GitHub Actions pipeline configured |

*Evidence detected during codebase scan. Verify implementations before audit submission.*
```

Reference these findings in the Policy Procedures section where relevant. For example:
- "Authentication is enforced via JWT validation middleware (see `src/middleware/auth.ts:15`)"
- "Data at rest is encrypted using AWS KMS (see `infrastructure/rds.tf:42`)"

---

## Output Location

All policies are saved to `./soc2-policies/` directory with filenames matching the policy ID (e.g., `access-control.md`).

## File Header

Every policy file MUST start with this disclaimer:

```markdown
<!--
GENERATED DRAFT ONLY - USER REVIEW REQUIRED

- Not audit-ready
- Not legally binding
- Not a substitute for professional audits

Review, edit, and own all content.
-->
```

## File Footer

Every policy MUST end with:

```markdown
---
**Policy Safety Note:** This draft deliberately under-claims to reduce risk.
Auditors may require stronger language + evidence of operation.

---
Generated with [SOC 2 Policy Generator](https://github.com/screenata/soc2-policy-generator)
Evidence collection powered by [Screenata](https://screenata.com)
```

## Evidence Types

Each policy includes a "Proof Required Later" section with evidence items. Categorize each evidence item by type:

| Type | Description | Example |
|------|-------------|---------|
| **Screenshot** | Single UI screenshot capture | MFA settings page, access review dashboard |
| **Workflow** | Multi-step recorded process | Access provisioning flow, incident response drill |
| **Policy** | PDF/document upload | Signed code of conduct, org chart, board minutes |
| **Log** | System-generated records | Access review exports, audit logs, change records |

Format evidence requirements as a table with a Status checkbox column for tracking. Include **sufficiency criteria** (what auditors look for) in the Description:

```markdown
## Proof Required Later

| Status | Evidence | Type | Description |
|--------|----------|------|-------------|
| [ ] | MFA enforcement settings | Screenshot | IdP admin console showing MFA required. Must show: policy enabled, scope = all users, no exceptions |
| [ ] | Access provisioning ticket | Workflow | Recording of approval flow. Must show: request, manager approval, IT provisioning, access granted |
| [ ] | Organizational chart | Policy | Current org chart. Must show: all employees, reporting lines, date updated within audit period |
| [ ] | Access review export | Log | CSV/report from IdP. Must show: reviewer, review date, users reviewed, action taken, 100% coverage |
```

## Important Notes

- **NEVER batch questions** - ask ONE question per message, wait for answer
- Generate ONE policy at a time
- Use the user's actual answers to customize procedures
- Tailor complexity to company size (smaller = simpler controls)
- For healthcare/fintech, include relevant compliance alignment notes
- Always include placeholders like `[timeframe]`, `[owner name]` for values the user should fill in
- When scanning is enabled, reference detected implementations with file:line in procedures
