# Audit Readiness Assessment Workflow

This file contains the detailed steps for running an audit readiness assessment. Load this file when the user wants to know "how ready are we?" before generating policies or collecting evidence. The workflow scans first, shows gaps, then recommends remediation.

## Prerequisites

**Resume check:** Before starting, check if `.compliance/assessment.md` already exists. If it does:
1. Read `.compliance/assessment.md` frontmatter to recover framework, scan date, and readiness score
2. Present a summary:
   > I found a previous assessment from [date]. Overall readiness: [score]% ([framework]).
   >
   > Would you like to re-run the assessment, or view the previous results?
3. If the user wants to view, display the executive summary section
4. If the user wants to re-run, continue below (the file will be overwritten)

**Config check:** If `.compliance/config.json` exists, read it to recover org_name, hosting_providers, saas_tools, and frameworks. Use these to pre-populate context and skip redundant questions.

## Step 1: Minimal Context

The goal is speed: get to scanning as fast as possible. Only ask what cannot be inferred from the codebase.

**Question 1** (ask first, wait for response):

> Which compliance framework are you targeting?
> 1. SOC 2
> 2. ISO 27001
> 3. Both

If `.compliance/config.json` exists and has `frameworks` populated, skip this question and confirm with the user:
> Your config shows you're targeting [frameworks]. I'll assess against that. Want to change the framework, or proceed?

**Question 2** (ask only if `.compliance/config.json` does NOT exist):

> What is your organization's name?

If config.json exists, use `org_name` from it.

**After questions are answered**, create or update `.compliance/config.json` with `org_name` and `frameworks` (leave all other fields null if newly created). Ensure `.compliance/secrets.env` is in `.gitignore`. Then immediately proceed to scanning — do NOT ask about evidence method, SaaS tools, cloud providers, or any other context. Those will be auto-detected.

## Step 2: Codebase Scan

Run all five codebase scanning pattern files. For each domain, use the Basic Detection patterns first, then the Deep Scanning patterns to extract concrete values.

**Domains to scan (load the corresponding scanning-patterns file):**

1. **Access Control** — [access-control.md](scanning-patterns/access-control.md)
   - Auth middleware, JWT, MFA, password config, RBAC, session/token config, lockout, rate limiting
2. **Change Management** — [change-management.md](scanning-patterns/change-management.md)
   - CI/CD pipelines, branch protection, code review config, deployment environments
3. **Network Security** — [network-security.md](scanning-patterns/network-security.md)
   - TLS/SSL, CORS, HSTS, security headers
4. **Data Management** — [data-management.md](scanning-patterns/data-management.md)
   - Encryption at rest, backup configuration, retention policies
5. **Vulnerability & Monitoring** — [vulnerability-monitoring.md](scanning-patterns/vulnerability-monitoring.md)
   - Dependency scanning, SAST, scan schedules, severity thresholds

**Additionally, run auto-detection scans:**

6. **SaaS Tool Detection** — [saas-detection.md](scanning-patterns/saas-detection.md)
   - Run all 6 detection layers (env templates, package deps, Terraform providers, GitHub Actions, config files, Docker Compose)
7. **Hosting Provider Detection** — detect from Terraform providers, config files, CI/CD references, package SDKs, env templates, Docker/K8s manifests

**For each domain**, collect:
- Basic detection hits (file presence, pattern matches)
- Deep scanning extracted values (concrete configs with file:line references)
- Count of controls addressable by findings

**Progress indicator:** After each domain completes, report progress:
> Scanning... Access Control done (found 8 controls).
> Scanning... Change Management done (found 5 controls).
> Scanning... Network Security done (found 3 controls).
> ...

Store all raw scan results in memory for Step 3. Do NOT write intermediate files.

## Step 3: Map Findings to Framework Controls

Load the framework mapping file(s) based on the user's framework choice:
- SOC 2: [frameworks/soc2.md](frameworks/soc2.md)
- ISO 27001: [frameworks/iso27001.md](frameworks/iso27001.md)

Load the policy definitions from [policies.md](policies.md) to get the 17 policy IDs and their evidence requirements.

**For each of the 17 policies**, determine a coverage status based on how much evidence the codebase scan found for that policy's control area.

### Policy Scannability Classification

| Policy ID | Primary Scan Domain | Scannability |
|-----------|-------------------|--------------|
| access-control | Access Control | Scannable |
| change-management | Change Management | Scannable |
| network-security | Network Security | Scannable |
| data-management | Data Management | Scannable |
| vulnerability-monitoring | Vulnerability & Monitoring | Scannable |
| incident-response | Vulnerability & Monitoring (monitoring subset) | Partial |
| business-continuity | Data Management (backup subset) | Partial |
| mobile-endpoint | SaaS Detection (MDM tools) | Partial |
| information-security-policy | Multiple (cross-cutting) | Partial |
| governance-board-oversight | — | Not Scannable |
| organizational-structure | — | Not Scannable |
| code-of-conduct | — | Not Scannable |
| external-communications | — | Not Scannable |
| vendor-management | — | Not Scannable |
| risk-management | — | Not Scannable |
| physical-security | — | Not Scannable |
| human-resources | — | Not Scannable |

### Coverage Determination Rules

- **Covered** (✓): 3+ deep-scanned values extracted for the policy's control area, OR basic detection hits across 2+ control categories within the domain
- **Partial** (◐): 1-2 basic detection hits but fewer than 3 deep-scanned values, OR the policy is in a "Partial" scannability category and some related signals were found
- **Gap** (✗): No scan results for this domain AND the policy is in a Scannable category
- **Not Scannable** (—): The policy covers process/document/people controls that cannot be detected from code. These are NOT counted as gaps but are listed separately as requiring manual verification

**For each control within a covered/partial policy**, map the extracted evidence to the specific framework control codes using the framework mapping files.

## Step 4: Optional Cloud & SaaS Enhancement

After the codebase scan completes, check if additional scanning layers are available:

**Cloud CLI check** (per [cloud-shared.md](scanning-patterns/cloud-shared.md)):
1. Check for installed CLIs: `aws --version`, `gcloud --version`, `az --version`
2. If any CLI is found, verify authentication (`aws sts get-caller-identity`, `gcloud auth list`, `az account show`)
3. If authenticated, offer the user:
   > I detected [AWS CLI / GCP SDK / Azure CLI] with active credentials. Want me to scan your cloud infrastructure too? This adds coverage for controls like encryption at rest, backup config, IAM policies, and network security groups.
   >
   > 1. Yes, scan [provider(s)]
   > 2. No, codebase scan is enough

**SaaS tool check:**
1. From the SaaS auto-detection results (Step 2, item 6), if tools were detected, inform the user:
   > I detected these SaaS tools in your codebase: [list]. If you provide API tokens, I can scan them for additional evidence (MFA enrollment rates, policy configs, etc.).
   >
   > 1. Yes, set up SaaS scanning
   > 2. No, skip SaaS scanning

**If user opts in to cloud scanning:**
- Follow the cloud-shared.md safety rules (read-only commands only)
- For each provider, run the control-relevant commands from the provider-specific scanning file ([aws.md](scanning-patterns/aws.md), [gcp.md](scanning-patterns/gcp.md), [azure.md](scanning-patterns/azure.md))
- Add results to the findings set before generating the report

**If user opts in to SaaS scanning:**
- For each detected tool, ask for the API token (one tool at a time)
- Store tokens in `.compliance/secrets.env`
- If a pre-built script exists in `assets/scripts/{tool}.sh`, copy it to `.compliance/scripts/` and run it
- If no pre-built script, generate one using API patterns from `references/saas-integrations/{category}.md`
- Add results to the findings set before generating the report

**If user declines both**, proceed directly to Step 5 with codebase results only.

## Step 5: Calculate Readiness Score

The readiness score provides a single percentage that answers "how ready are we?"

### Scoring Method

Each of the 17 policies has a weight based on framework importance and scannability. Weights are distributed across 3 tiers:

**Tier 1 — High Weight (8 points each):** Policies covering controls that are directly scannable from code/cloud/SaaS.
- access-control
- change-management
- network-security
- data-management
- vulnerability-monitoring

**Tier 2 — Medium Weight (5 points each):** Policies covering controls that are partially scannable or have some technical signals.
- incident-response
- business-continuity
- mobile-endpoint
- information-security-policy

**Tier 3 — Low Weight (3 points each):** Policies covering process/document/people controls that cannot be scanned from code.
- governance-board-oversight
- organizational-structure
- code-of-conduct
- external-communications
- vendor-management
- risk-management
- physical-security
- human-resources

**Total possible points:** (5 × 8) + (4 × 5) + (8 × 3) = 40 + 20 + 24 = 84

**Points awarded per policy:**
- Covered: 100% of weight
- Partial: 50% of weight
- Gap: 0% of weight
- Not Scannable with no signals: 0% (noted separately)

**Readiness Score = (points earned / total possible points) × 100**

Round to the nearest whole number. Present as a percentage.

### Score Interpretation

| Score Range | Label | Meaning |
|------------|-------|---------|
| 80–100% | Audit-ready (technical) | Strong technical controls in code. Focus on process/document gaps |
| 60–79% | Partially ready | Some controls implemented. Targeted remediation needed |
| 40–59% | Significant gaps | Many controls missing. Broad remediation needed |
| 0–39% | Early stage | Limited controls found. Full compliance build-out needed |

### Score Caveat

Always include this caveat with the score:
> **Note:** This score reflects technical controls detectable from your codebase [and cloud infrastructure] [and SaaS tools]. Process controls (governance, HR, vendor management) require manual verification and are not fully captured. The score aims to indicate technical readiness and should not be treated as audit certification.

## Step 6: Generate Assessment Report

Save the report to `.compliance/assessment.md` using the template structure from [assets/assessment-template.md](../assets/assessment-template.md).

**Report sections:**
1. Executive Summary — score, coverage table, scan sources, date
2. Top Gaps — priority-ranked table with policy name, domain, and impact
3. Per-Domain Findings — one sub-section per scanning domain with Controls Found table (Status | Control | Evidence | Source | Reference), ordered by gap severity
4. Not-Scannable Policies — table with "What to Prepare" guidance for manual verification
5. SaaS Tools Detected — table with tool, category, detection source, compliance relevance
6. Cloud Providers Detected — table with provider, detection source, scanned status, controls covered
7. Remediation Roadmap — three priority tiers (quick wins, generate policies, evidence collection)

**Update `.compliance/status.md`:** Add or update an "Assessment" section:

```markdown
## Assessment

| Date | Framework | Score | Covered | Partial | Gap | Not Scannable |
|------|-----------|-------|---------|---------|-----|---------------|
| [date] | [framework] | [score]% | [N] | [N] | [N] | [N] |
```

**Update `.compliance/config.json`:** Write the detected hosting providers and SaaS tools into the config so subsequent workflows can use them (only write if the fields are currently null).

**Present the executive summary to the user:**

> ## Audit Readiness Assessment Complete
>
> **Overall Score: [score]% — [label]**
>
> | Status | Count | Policies |
> |--------|-------|----------|
> | ✓ Covered | [N] | [list] |
> | ◐ Partial | [N] | [list] |
> | ✗ Gap | [N] | [list] |
> | — Not Scannable | [N] | [list] |
>
> **Top 3 Gaps:**
> 1. [policy name] — [brief description of what's missing]
> 2. [policy name] — [brief description]
> 3. [policy name] — [brief description]
>
> Full report saved to `.compliance/assessment.md`.

## Step 7: Recommend Remediation and Chain to Other Workflows

After presenting the summary, offer next steps based on the gaps found:

> Based on your assessment, here's what I recommend:
>
> 1. **Generate policies for gap areas** — I'll create [N] policies covering your gaps (→ Policy Generation workflow)
> 2. **Set up evidence collection** — I'll configure automated scanning for [N] detected tools/providers (→ Evidence Collection workflow)
> 3. **Both** — generate policies first, then set up evidence collection
> 4. **Export the report** — keep the assessment for now
> 5. **Re-run with cloud/SaaS scanning** — add more evidence sources _(only show if cloud/SaaS was skipped in Step 4)_

**If option 1 (Generate policies):**
- Write the list of gap policy IDs to `.compliance/config.json` under `assessment_gaps`
- Create task files `.compliance/tasks/gen-{policy-id}.md` for each gap policy with `category: generation`, `status: pending`
- If `.compliance/config.json` is minimal (only org_name + frameworks), the policy workflow will ask the remaining context questions (Q2–Q14) as needed in its Step 1
- Route to [workflow-policies.md](workflow-policies.md) Step 3 with the gap policies pre-selected in the policy list

**If option 2 (Evidence collection):**
- Write detected tools/providers to `.compliance/config.json` fields `saas_tools` and `hosting_providers` (if not already there)
- Route to [workflow-evidence.md](workflow-evidence.md) Step 1 with the detected tools pre-populated

**If option 3 (Both):**
- Run option 1 first (generate policies for all gap areas)
- After the last policy is generated, automatically transition to option 2 (evidence collection setup)

**If option 4 (Export):**
- The report is already saved to `.compliance/assessment.md`. End the workflow.

**If option 5 (Re-run with more sources):**
- Go back to Step 4 and prompt for cloud/SaaS credentials
- After scanning, re-run Steps 5–6 to update the report with improved coverage
