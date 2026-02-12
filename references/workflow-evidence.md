# Evidence Collection Workflow

This file contains the detailed steps for setting up automated evidence collection. Load this file when the user wants to set up evidence scripts and GitHub Actions workflows.

## Prerequisites

If `.compliance/config.json` does not exist, gather abbreviated context first:

**Q1:** What is your organization's name?
**Q2:** Where do you host? (AWS, GCP, Azure, Vercel, Heroku, other)
**Q3:** What SaaS tools does your team use? (Okta, Datadog, Jira, GitHub, Slack, PagerDuty, etc.)
**Q4:** Which compliance framework? (SOC 2, ISO 27001, or both)

Write answers to `.compliance/config.json`, leaving unneeded fields null.

## Step 1: Choose Evidence Scope

> Would you like to set up automated evidence collection?
> 1. Yes — full setup (code + cloud + SaaS scripts and workflows)
> 2. Yes — code + SaaS only
> 3. Yes — code + cloud only
> 4. Yes — code only (no external credentials needed)
> 5. No — skip for now

Only show options with SaaS/Cloud if those tools/providers exist in config.json.

## Step 2: Set Up & Test Evidence Scripts

**Resume check:** Before starting, check existing progress:
1. Read `.compliance/status.md` — check the "SaaS Tool Configuration" and "Cloud Provider Configuration" tables for checkmarks
2. Check for existing `.compliance/scripts/{tool}.sh` files (script already copied/generated)
3. Check for existing `.compliance/scripts/{tool}.config.json` files (config already provided)
4. Check `.compliance/secrets.env` for existing tokens (e.g., `OKTA_API_TOKEN` is already set)

If any tools have partial or complete progress, present a status summary:
> Picking up evidence collection. Here's where we are:
>
> | Tool | Script | Config | Tested | Workflow |
> |------|--------|--------|--------|----------|
> | Okta | [x] | [x] | [x] | [ ] |
> | Datadog | [x] | [x] | [ ] | [ ] |
> | Jira | [ ] | [ ] | [ ] | [ ] |
>
> I'll continue with testing Datadog, then set up Jira.
> Want to skip any tools, or continue with all?

**Skip any tool that already has all checkmarks** (Script + Config + Tested). For partially completed tools, resume from the next incomplete step.

For each tool/provider selected, create a task file `.compliance/tasks/auto-{tool}.md` with `category: evidence-auto`, `status: pending`. Follow [script-templates.md](script-templates.md) for conventions. Claim the task (set `locked_by`, `status: in_progress`) before starting work on each tool.

Pre-built scripts for 26 common tools (23 SaaS + 3 cloud providers) are available in `assets/scripts/`. Use the **copy-first** approach — fall back to generating on demand only when needed.

**For each SaaS tool** (skip steps that are already complete):
1. **If `.compliance/scripts/{tool}.sh` already exists**, skip to step 4. Otherwise: **if pre-built script exists** in `assets/scripts/{tool}.sh`, copy it to `.compliance/scripts/{tool}.sh`. **If no pre-built script**, generate one using API patterns from `references/saas-integrations/{category}.md`.
2. **Update `.compliance/status.md`** — mark `[x] Script` for this tool in the "SaaS Tool Configuration" table.
3. **If `.compliance/scripts/{tool}.config.json` already exists**, skip to step 6. Otherwise: ask the user for non-secret config values (domain, project key, etc.) and write to `.compliance/scripts/{tool}.config.json`.
4. **Update `.compliance/status.md`** — mark `[x] Config` for this tool.
5. **Check `.compliance/secrets.env`** for the required token (e.g., `OKTA_API_TOKEN`). If already present, skip to step 7. Otherwise: ask the user to add the required API token to `.compliance/secrets.env`: `{TOOL}_API_TOKEN=your-token-here`
6. Source secrets and test: `set -a; source .compliance/secrets.env; set +a && bash .compliance/scripts/{tool}.sh`
7. Read the output evidence file and verify it looks correct
8. If there are errors (API changed, missing fields), fix the script and rerun — this is the **generate fallback**
9. Repeat until all evidence rows are populated correctly
10. **Update `.compliance/status.md`** — mark `[x] Tested` for this tool.
11. **Mark task done:** Update `.compliance/tasks/auto-{tool}.md` with `status: done`, clear `locked_by`. Update status.md Summary counts.

**For cloud providers** (skip steps that are already complete):
1. **If `.compliance/scripts/{provider}.sh` already exists**, skip to step 4. Otherwise: **if pre-built script exists** in `assets/scripts/{provider}.sh`, copy it to `.compliance/scripts/{provider}.sh`. **If no pre-built script**, generate using CLI patterns from `references/scanning-patterns/{provider}.md`.
2. **If `.compliance/scripts/{provider}.config.json` already exists**, skip to step 4. Otherwise: write config with region and other settings.
3. **Update `.compliance/status.md`** — mark `[x] Script` and `[x] Config` for this provider in the "Cloud Provider Configuration" table.
4. Verify cloud CLI is authenticated (`aws sts get-caller-identity`, `gcloud auth list`, etc.)
5. Run `bash .compliance/scripts/{provider}.sh` to test
6. Verify and iterate
7. **Update `.compliance/status.md`** — mark `[x] Tested` for this provider.

**For code scanning:**
1. **If `.compliance/scripts/code-scan.sh` already exists and status.md shows tested**, skip entirely.
2. Otherwise: generate `.compliance/scripts/code-scan.sh` using patterns from `references/scanning-patterns/`
3. Run `bash .compliance/scripts/code-scan.sh` to test
4. Verify the output contains detected patterns
5. **Update `.compliance/status.md`** — mark code scanning as tested.

Copy `assets/scripts/collect-all.sh` to `.compliance/scripts/collect-all.sh` — the runner that executes all scripts in the directory.

## Step 3: Generate Workflows

Once scripts are tested and working, generate GitHub Actions workflows that call them. Use [workflow-templates.md](workflow-templates.md) for the workflow structure.

Workflows are thin wrappers — they just:
1. Check out the repo
2. Inject secrets as env vars
3. Call `bash .compliance/scripts/{tool}.sh` for each tool
4. Commit evidence files

Generate:
- `.github/workflows/compliance-code-scan.yml` — runs `code-scan.sh` weekly + on PRs
- `.github/workflows/compliance-cloud-scan.yml` — runs `{provider}.sh` weekly/monthly (only if Cloud was chosen)
- `.github/workflows/compliance-saas-scan.yml` — runs `{tool}.sh` weekly (only if SaaS was chosen)

Evidence files are saved to `.compliance/evidence/` with code, cloud, and saas subdirectories.

**If workflows already exist** from a previous session, update them to include new script calls rather than creating duplicate workflow files. Always deduplicate — if a provider's or tool's steps are already present, skip adding them again.

**Update `.compliance/status.md` after each workflow is generated:** Add or update the workflow's row in the "Workflows Generated" table with the workflow file path, tools included, and creation date. Also mark the `Workflow` column as `[x]` for each tool included in that workflow in the "SaaS Tool Configuration" table.

**Update manual evidence tasks after workflows are generated:** Re-evaluate all `.compliance/tasks/evidence-*.md` task files. For each manual evidence task, check if the evidence item is now covered by a workflow (cross-reference the policy's automated evidence sections and `.compliance/evidence/` contents). If covered, mark the task `status: done` with a note: "Automated via {workflow-name}". Update status.md Summary counts.

After generating, output:
1. The list of required GitHub Secrets (per provider)
2. The minimum IAM/RBAC permissions needed (read-only)
3. The scan schedule summary
4. Updated task counts: "{N} manual evidence items remaining across {P} policies"
