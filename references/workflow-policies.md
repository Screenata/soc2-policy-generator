# Policy Generation Workflow

This file contains the detailed steps for generating compliance policies. Load this file when the user wants to create policies.

## Step 1: Gather Company Context

**First, check for existing session state:**

Before asking any questions, check if `.compliance/config.json` exists. If it does:
1. Read `.compliance/config.json` to recover previously saved answers (org name, description, industry, size, executives, work model, devices, identity provider, data types, data location, hosting, frameworks, cert type, SaaS tools, report signoff, evidence method)
2. Read `.compliance/status.md` to recover progress on policies, SaaS tools, cloud providers, and workflows
3. Read `.compliance/tasks/*.md` frontmatter to count tasks by category and status
4. Present a summary to the user:
   > I found your previous session state. Here's what I have:
   > - **Org:** [org_name] — [company_description]
   > - **Industry:** [industry], [company_size] employees, [work_model]
   > - **Infrastructure:** Hosted on [hosting_providers], data in [data_locations]
   > - **Identity:** [identity_provider], devices: [device_types]
   > - **Data types:** [data_types]
   > - **Frameworks:** [frameworks]
   > - **Cert:** [cert_type] (SOC 2 only)
   > - **Evidence method:** [evidence_method]
   > - **SaaS tools:** [saas_tools list]
   > - **Policies generated:** [count] of 17 ([names])
   > - **SaaS tools configured:** [count] of [total] fully wired
   > - **Tasks:** [N] pending, [N] in progress, [N] done
   >
   > Would you like to continue from where you left off, or start fresh?
5. If the user continues, skip all answered questions and jump to the next incomplete step (next pending policy, next untested SaaS tool, etc.)
6. If the user starts fresh, proceed with all questions below (`.compliance/` will be overwritten)

If `.compliance/config.json` exists but cannot be parsed, ask the user if they want to start fresh.

If `.compliance/config.json` does not exist, proceed with the questions below.

Ask each question separately. After receiving an answer, proceed to the next question.

**Update `.compliance/config.json` after every answer.** Create the `.compliance/` directory and `.compliance/config.json` after Q1 is answered. When creating the `.compliance/` directory, also ensure `.compliance/secrets.env` is in `.gitignore` (append it if not already present). Use the JSON format shown at the end of Step 1, with empty/null values for unanswered questions.

Field mapping: Q1 → `org_name`, Q2 → `company_description`, Q3 → `industry`, Q4 → `company_size`, Q5 → `executives`, Q6 → `work_model`, Q7 → `device_types`, Q8 → `identity_provider`, Q9 → `data_types`, Q10 → `data_locations`, Q11 → `hosting_providers`, Q12 → `frameworks`, Q12a → `cert_type` (SOC 2 only), Q13 → `saas_tools`, Q14 → `report_signoff`.

**Question 1** (ask first, wait for response):
> What is your organization's name?

**Question 2** (ask after Q1 answered):
> Describe your company in a few sentences — what does it do?

**Question 3** (ask after Q2 answered):
> What industry is your company in?
> 1. Healthcare
> 2. Fintech
> 3. B2B SaaS
> 4. E-commerce
> 5. Other

**Question 4** (ask after Q3 answered):
> How many employees do you have?
> 1. 1-10
> 2. 11-50
> 3. 51-200
> 4. 200+

**Question 5** (ask after Q4 answered):
> Who are your C-Suite executives? (names and titles, e.g. "Jane Doe — CEO, John Smith — CTO")

**Question 6** (ask after Q5 answered):
> How does your team work?
> 1. Fully remote
> 2. Hybrid (office + remote)
> 3. Office-based

**Question 7** (ask after Q6 answered):
> What devices do your team members use? (select all that apply)
> 1. Company-provided laptops
> 2. Personal laptops
> 3. Company phones
> 4. Personal phones
> 5. Tablets
> 6. Other (please specify)

**Question 8** (ask after Q7 answered):
> How do your team members sign in to work tools? (identity/SSO provider)
> 1. Google Workspace
> 2. Microsoft 365
> 3. Okta
> 4. Auth0
> 5. Email/Password (no SSO)
> 6. Other (please specify)

**Question 9** (ask after Q8 answered):
> What types of data do you handle? (select all that apply)
> 1. Customer PII
> 2. Payment information
> 3. Employee data
> 4. Health records
> 5. Intellectual property
> 6. Other (please specify)

**Question 10** (ask after Q9 answered):
> Where is your data located? (select all that apply)
> 1. North America
> 2. Europe (EU)
> 3. United Kingdom
> 4. Asia-Pacific
> 5. South America
> 6. Africa
> 7. Middle East
> 8. Australia/New Zealand

**Question 11** (ask after Q10 answered):

Before asking this question, auto-detect hosting providers from the codebase. Scan for:

- **Terraform providers:** Grep `*.tf` files for `provider "aws"` → AWS, `provider "google"` → Google Cloud, `provider "azurerm"` → Microsoft Azure, `provider "heroku"` → Heroku
- **Config files:** Glob for `vercel.json` → Vercel, `fly.toml` → Fly.io, `Procfile` or `app.json` → Heroku, `appspec.yml` → AWS, `app.yaml` with `runtime:` → Google Cloud App Engine
- **CI/CD deployments:** Grep `.github/workflows/*.yml` for `aws-actions/` → AWS, `google-github-actions/` → Google Cloud, `azure/` → Microsoft Azure, `amondnet/vercel-action` or `vercel deploy` → Vercel, `akhileshns/heroku-deploy` or `heroku container` → Heroku
- **Package/SDK signals:** Grep `package.json`, `requirements.txt`, `go.mod` for `@aws-sdk/` or `boto3` → AWS, `@google-cloud/` or `google-cloud-` → Google Cloud, `@azure/` or `azure-` → Microsoft Azure
- **Env templates:** Grep `.env.example`, `.env.sample` for `AWS_ACCESS_KEY_ID` or `AWS_REGION` → AWS, `GOOGLE_CLOUD_PROJECT` or `GCP_PROJECT` → Google Cloud, `AZURE_SUBSCRIPTION_ID` or `AZURE_TENANT_ID` → Microsoft Azure, `VERCEL_TOKEN` → Vercel, `HEROKU_API_KEY` → Heroku
- **Docker/K8s:** Grep for ECR image URLs (`*.dkr.ecr.*.amazonaws.com`) → AWS, GCR URLs (`gcr.io/`) → Google Cloud, ACR URLs (`*.azurecr.io`) → Microsoft Azure

**If providers are detected**, present as confirmation:
> I scanned your codebase and detected the following hosting providers:
>
> - **AWS** (found: provider "aws" in infrastructure/main.tf, @aws-sdk/ in package.json)
> - **Vercel** (found: vercel.json in project root)
>
> Are these correct? Any to add or remove?

**If nothing is detected**, fall back to the manual question:
> Where do you host your applications and data? (select all that apply)
> 1. AWS
> 2. Google Cloud
> 3. Microsoft Azure
> 4. Heroku
> 5. Vercel
> 6. Other (please specify)

**Question 12** (ask after Q11 answered):
> Which compliance framework(s) are you targeting? (select all that apply)
> 1. SOC 2
> 2. ISO 27001
> 3. Both SOC 2 and ISO 27001

**Question 12a** (ask only if SOC 2 was selected in Q12):
> Are you pursuing SOC 2 Type I or Type II?
> 1. Type I (point-in-time)
> 2. Type II (operational over time)

**Question 13** (ask after Q12/Q12a answered):

Before asking this question, run the SaaS auto-detection scan per [scanning-patterns/saas-detection.md](scanning-patterns/saas-detection.md). This scans `.env.example` files, package managers, Terraform providers, GitHub Actions workflows, and tool-specific config files to detect which SaaS tools are already in use.

**If tools are detected**, present them as a confirmation instead of the manual question:
> I scanned your codebase and detected the following SaaS tools:
>
> **Identity:** Okta (OKTA_DOMAIN in .env.example, @okta/okta-sdk-nodejs in package.json)
> **Monitoring:** Datadog (DD_API_KEY in .env.example, provider "datadog" in main.tf)
> **Security:** Snyk (.snyk config file, snyk/actions in CI)
>
> Are these correct? Any to add or remove?
> (Or type "skip" for no SaaS integrations)

**If nothing is detected**, fall back to the manual question:
> What SaaS tools does your team use? (select all that apply, or type additional tools not listed)
> 1. Okta
> 2. Auth0
> 3. Google Workspace
> 4. JumpCloud
> 5. Datadog
> 6. PagerDuty
> 7. New Relic
> 8. Splunk
> 9. Jira
> 10. Linear
> 11. GitHub
> 12. Slack
> 13. Opsgenie
> 14. Statuspage
> 15. BambooHR
> 16. Gusto
> 17. Rippling
> 18. Jamf
> 19. Kandji
> 20. Intune
> 21. Snyk
> 22. SonarCloud
> 23. Skip — no SaaS integrations

The user can select multiple numbers (e.g. "1, 5, 9, 11") and/or type additional tool names not in the list.

**Question 14** (ask after Q13 answered):
> Who will sign off on the final report? (full name, title, and email)

**Verify config is complete:** After Q14 is answered, read back `.compliance/config.json` and confirm all fields are populated. The complete JSON format is:

```json
{
  "org_name": "Acme Corp",
  "company_description": "Acme automates application-level compliance evidence collection",
  "industry": "B2B SaaS",
  "company_size": "11-50",
  "executives": [
    { "name": "Jane Doe", "title": "CEO" },
    { "name": "John Smith", "title": "CTO" }
  ],
  "work_model": "fully remote",
  "device_types": ["company-provided laptops"],
  "identity_provider": "Microsoft 365",
  "data_types": ["Customer PII"],
  "data_locations": ["North America"],
  "hosting_providers": ["AWS", "Vercel"],
  "frameworks": ["SOC 2", "ISO 27001"],
  "cert_type": "Type II",
  "saas_tools": ["okta", "datadog", "jira"],
  "report_signoff": {
    "name": "Jane Doe",
    "title": "CEO",
    "email": "jane@acme.com"
  },
  "evidence_method": "",
  "cloud_providers": [],
  "cloud_regions": []
}
```

Also create `.compliance/status.md` with empty progress tables (filled in later steps):

```markdown
# Compliance Automation — Progress

## Summary

| Category | Pending | In Progress | Done | Total |
|----------|---------|-------------|------|-------|

## Policies

| Policy | Answers | Policy File | Status |
|--------|---------|-------------|--------|

## SaaS Tool Configuration

| Tool | Script | Config | Tested | Workflow |
|------|--------|--------|--------|----------|

## Workflows Generated

| Workflow | File | Tools |
|----------|------|-------|

## Manual Evidence

Evidence items requiring human action. Save files to `.compliance/evidence/manual/{policy-id}/`.

| Evidence Type | Accepted Formats |
|--------------|-----------------|
| Screenshot | `.png`, `.jpg` |
| Workflow | `.mp4`, `.gif`, `.pdf` |
| Policy | `.pdf`, `.docx` |
| Log | `.csv`, `.xlsx`, `.json`, `.pdf` |

File naming: lowercase kebab-case (e.g., `board-meeting-minutes.pdf`).

## Response Mappings

| Source | File | Items | Coverage | Last Updated |
|--------|------|-------|----------|-------------|
```

## Step 2: Choose Evidence Collection Method

**Default: Code + Cloud + SaaS.** After gathering context, tell the user the default and offer to change it:
> I'll scan your codebase, cloud infrastructure, and SaaS tools for evidence. Want to adjust?
> 1. **Code + Cloud + SaaS** — scan all three (default)
> 2. Code + Cloud — skip SaaS tools
> 3. Code + SaaS — skip cloud infrastructure
> 4. Code only — scan codebase for security patterns only
> 5. Q&A only — generate policies based on your answers only

If the user listed no SaaS tools in Q13, default to Code + Cloud instead and hide SaaS options (1, 3).

**If user chooses an option with Cloud:**
First, detect available cloud CLIs and verify authentication per [scanning-patterns/cloud-shared.md](scanning-patterns/cloud-shared.md). Report which providers are available. Ask which region(s) to scan.

**If user chooses an option with SaaS:**
For each SaaS tool the user listed in Q13, check the per-category files in `references/saas-integrations/` for the tool-to-policy mapping. Only load the category file relevant to the selected policy.

**If user chooses Code only (option 4):**
Use the scanning patterns for the selected policy from `references/scanning-patterns/` to detect security implementations and extract concrete values.

**If user chooses Q&A only (option 5):**
Skip scanning entirely.

**Update config:** Write the chosen evidence collection method to the `evidence_method` field in `.compliance/config.json`. If cloud was chosen, also write `cloud_providers` and `cloud_regions` after detecting/asking.

## Step 3: Select Policy

Show the numbered list of 17 policies and ask which to generate. The same 17 policies apply to both SOC 2 and ISO 27001 — the policy content is the same, only the control mappings in the YAML frontmatter differ. When generating a policy, look up the policy ID in the relevant framework file(s) to get control codes:

- **SOC 2:** [frameworks/soc2.md](frameworks/soc2.md)
- **ISO 27001:** [frameworks/iso27001.md](frameworks/iso27001.md)

Include only the control mappings for the framework(s) selected in Q12 (TSC for SOC 2, Annex A for ISO 27001, or both).

> Which policy would you like to generate?
> 1. Governance & Board Oversight
> 2. Organizational Structure
> ... (list all 17)
> 18. **Generate all** — I'll ask policy-specific questions for each, then generate all 17

**If "generate all":** Two-phase approach:
1. **Phase 1 — Collect all answers:** Loop through each policy, ask its policy-specific questions (Step 4), and write each answer file to `.compliance/answers/{policy-id}.md`. After all 17 answer files are written, tell the user:
   > All answers saved to `.compliance/answers/`. You can review and edit any file before I generate. Ready to generate all, or want to review first?
2. **Phase 2 — Create task files and generate:** For each policy, create `.compliance/tasks/gen-{policy-id}.md` with `category: generation`, `status: pending`. Then loop through each answer file and run Steps 5-6. Update `.compliance/status.md` after each policy so progress is saved even if the session ends mid-way.

**If a single policy is selected:** Create `.compliance/tasks/gen-{policy-id}.md` with `category: generation`, `status: pending`. Proceed to Step 4 for that policy.

## Step 4: Ask Policy-Specific Questions

For the selected policy, ask each question from [policies.md](policies.md) **one at a time**. Wait for each answer before asking the next.

**Write answers to file immediately:** After all policy-specific questions are answered, write them to `.compliance/answers/{policy-id}.md`. Create the `answers/` directory if needed. This file serves two purposes:
1. **Persistence** — answers survive session restarts
2. **Editability** — the user can review and edit answers before generation

Use this format:

```markdown
---
policy: Access Control
policy_id: access-control
answered: 2025-01-15
generated: false
---

# Access Control — Answers

## Company Context (from Step 1)
- Organization: Acme Corp
- Description: Acme automates application-level compliance evidence collection
- Industry: B2B SaaS
- Size: 11-50 employees
- Executives: Jane Doe (CEO), John Smith (CTO)
- Work model: Fully remote
- Devices: Company-provided laptops, company phones
- Identity provider: Microsoft 365
- Data types: Customer PII
- Data locations: North America
- Hosting: AWS, Vercel
- Certification: Type II
- Report signoff: Jane Doe, CEO, jane@acme.com

## Policy-Specific Answers
- Access review frequency: Quarterly
- Provisioning approval: Manager + IT
- MFA scope: All employees
- Deprovisioning timeline: Same business day
- Privileged access review: Monthly
```

**Update `.compliance/status.md` immediately:** Add or update the policy row in the "Policies" table. Set the Answers column to `.compliance/answers/{policy-id}.md`, leave Policy File empty, and set Status to `answers-saved`.

After writing, tell the user:
> Answers saved to `.compliance/answers/{policy-id}.md`.
> You can edit this file before I generate the policy. Ready to generate, or want to review first?

**On session resume:** If `.compliance/answers/{policy-id}.md` exists with `generated: false`, the agent can skip re-asking questions and go straight to generation (after confirming with the user).

## Step 5: Generate the Policy

**Read answers from file:** Before generating, read `.compliance/answers/{policy-id}.md` to get the answers. This ensures any edits the user made are picked up.

Generate the policy document following the template structure in [../assets/policy-template.md](../assets/policy-template.md).

**If codebase evidence was detected**, include an "Evidence from Codebase" section before the "Proof Required Later" section. **If cloud evidence was detected**, include an "Evidence from Cloud Infrastructure" section as well. **If SaaS evidence was detected**, include an "Evidence from SaaS Tools" section.

**Critical Language Guidelines** - Prioritize under-claiming to minimize audit risk:

| AVOID | PREFER |
|-------|--------|
| "continuous", "real-time", "automated" | "periodic review", "documented process" |
| "ensures", "prevents", "guarantees" | "aims to", "intended to", "process includes" |
| "all users", "always" | "applicable users", "when possible" |
| Specific timeframes without brackets | "[timeframe]" placeholders |

**Exception for codebase-extracted values:** When a concrete value is extracted from the codebase via deep scanning (e.g., password minimum length, session timeout, bcrypt rounds), use that specific value in the policy text with a file:line reference. Always include the caveat that values represent code-level configuration and should be verified against production.

**Exception for cloud-extracted values:** When a concrete value is extracted from live cloud infrastructure (e.g., IAM password policy minimum length, RDS backup retention period), use that specific value in the policy text with a CLI command reference. Always include the caveat that values represent a point-in-time snapshot and should be re-verified before audit.

## Step 6: Save and Review

1. Save the policy to `./.compliance/policies/{policy-id}.md`
2. Show a preview of the generated content
3. **Update `.compliance/status.md` immediately:** Add or update the policy row in the "Policies" table. Set the Answers column to the answer file path, the Policy File to the output path, and Status to `generated`. Update the answer file's frontmatter: set `generated: true`.
4. **Update task files:**
   - Mark `.compliance/tasks/gen-{policy-id}.md` as `status: done`, clear `locked_by`
   - Create `.compliance/tasks/review-{policy-id}.md` with `category: review`, `status: pending`. Body: instructions to review the policy, edit `[placeholders]`, and confirm accuracy.
   - For each evidence item in "Proof Required Later" that is NOT covered by automated evidence (codebase/cloud/SaaS sections), create `.compliance/tasks/evidence-{policy-id}-{evidence-name-kebab}.md` with `category: evidence-manual`, `status: pending`. Body: evidence name, type, sufficiency criteria, and target path `manual/{policy-id}/{name-kebab}.{ext}`.
   - Create `.compliance/evidence/manual/{policy-id}/` directory
   - Update the Summary table in `.compliance/status.md` by reading all task file frontmatter
5. Ask what to do next:
   > Policy saved to `.compliance/policies/{policy-id}.md`. What would you like to do?
   > 1. Generate another policy
   > 2. Generate all remaining policies
   > 3. Set up automated evidence collection
   > 4. Regenerate this policy with different answers
   > 5. View tasks — see pending policy reviews and manual evidence to collect
   > 6. Done for now

**If option 1:** Go back to Step 3 (policy selection).
**If option 2:** Loop through all policies not yet in `.compliance/status.md`, running Steps 4-5-6 for each.
**If option 3:** Route to [workflow-evidence.md](workflow-evidence.md).
**If option 4:** Go back to Step 4 for this policy.
**If option 5:** Read all `.compliance/tasks/*.md` files and present a summary grouped by category, showing pending/in-progress/done counts and listing pending tasks.
**If option 6:** End the session. `.compliance/` has all progress saved.
