# Assessment Report Template

Use this structure when generating the audit readiness assessment report.

## Required File Header

```markdown
<!--
GENERATED DRAFT ONLY - USER REVIEW REQUIRED

- Not audit-ready
- Not legally binding
- Not a substitute for professional audits
- Score reflects detectable technical controls only

Review, edit, and own all content.
-->
```

## YAML Frontmatter

```yaml
---
type: assessment
org_name: [Organization Name]
frameworks: [SOC 2 | ISO 27001 | Both]
scan_date: [YYYY-MM-DD]
scan_sources: [code | code+cloud | code+saas | code+cloud+saas]
readiness_score: [0-100]
readiness_label: [Audit-ready (technical) | Partially ready | Significant gaps | Early stage]
policies_covered: [N]
policies_partial: [N]
policies_gap: [N]
policies_not_scannable: [N]
cloud_providers_scanned: [list or "none"]
saas_tools_scanned: [list or "none"]
---
```

## Required Sections

### 1. Title

```markdown
# Audit Readiness Assessment — [Organization Name]
```

### 2. Executive Summary

```markdown
## Executive Summary

**Overall Readiness Score: [score]% — [label]**

| Category | Count | % of Total |
|----------|-------|-----------|
| ✓ Covered | [N] | [%] |
| ◐ Partial | [N] | [%] |
| ✗ Gap | [N] | [%] |
| — Not Scannable | [N] | [%] |

**Scan sources:** [Codebase | Codebase + AWS | Codebase + Okta, Datadog | etc.]
**Scan date:** [YYYY-MM-DD]
```

### 3. Top Gaps

```markdown
### Top Gaps

| Priority | Policy | Domain | Impact |
|----------|--------|--------|--------|
| 1 | [policy name] | [domain] | [brief explanation of audit risk] |
| 2 | [policy name] | [domain] | [brief explanation] |
| 3 | [policy name] | [domain] | [brief explanation] |
```

### 4. Score Caveat

```markdown
**Note:** This score reflects technical controls detectable from your codebase [and cloud infrastructure] [and SaaS tools]. Process controls (governance, HR, vendor management) require manual verification and are not fully captured. The score aims to indicate technical readiness and should not be treated as audit certification.
```

### 5. Per-Domain Detailed Findings

Generate one sub-section per scanning domain. Order by: scannable domains first (sorted by gap severity — gaps first, then partial, then covered), then not-scannable domains.

```markdown
## Detailed Findings

### Access Control

**Policies:** access-control
**Framework Controls:** [SOC 2: CC6.1, CC6.2, CC6.3] [ISO 27001: A.5.15, A.5.16, ...]
**Status:** [✓ Covered / ◐ Partial / ✗ Gap]

#### Controls Found

| Status | Control | Evidence | Source | Reference |
|--------|---------|----------|--------|-----------|
| ✓ | Password hashing | **bcrypt, 12 rounds** | Code | `src/services/auth.ts:45` |
| ✓ | RBAC roles | **Admin, Editor, Viewer** | Code | `src/models/user.ts:12` |
| ✓ | Session timeout | **30 min** | Code | `src/config/session.ts:8` |
| ✗ | MFA enforcement | none | — | Not detected |

#### Recommendations

- [Specific recommendation for each gap/partial control]
- [e.g., "Add MFA enforcement — no multi-factor configuration detected in codebase"]
```

If cloud or SaaS scanning was performed, the Source column will also contain "Cloud" or "SaaS" entries with corresponding references (CLI commands or API endpoints).

### 6. Not-Scannable Policies

```markdown
## Policies Requiring Manual Verification

These policies cover governance, process, and people controls that cannot be detected from code, cloud, or SaaS scanning. They require manual documentation and review.

| Policy | Framework Controls | What to Prepare |
|--------|--------------------|-----------------|
| Governance & Board Oversight | [controls] | Board charter, meeting minutes, security briefing records |
| Organizational Structure | [controls] | Org chart, job descriptions, security lead designation |
| Code of Conduct & Ethics | [controls] | Signed code of conduct, NDA agreements, whistleblower procedure |
| External Communications | [controls] | Communication policy, breach notification templates |
| Vendor Management | [controls] | Vendor inventory, due diligence records, contract templates |
| Risk Management | [controls] | Risk register, risk assessment methodology, treatment plans |
| Physical Security | [controls] | Office access logs, visitor policy, cloud provider SOC 2 reports |
| Human Resources | [controls] | Background check policy, security training records, onboarding checklist |
```

### 7. SaaS Tools Detected

```markdown
## SaaS Tools Detected

| Tool | Category | Detection Source | Compliance Relevance |
|------|----------|-----------------|---------------------|
| [tool] | [category] | [file:pattern] | [which policies it provides evidence for] |
```

If no tools detected: "No SaaS tools were detected in the codebase."

### 8. Cloud Providers Detected

```markdown
## Cloud Providers Detected

| Provider | Detection Source | Scanned? | Controls Covered |
|----------|-----------------|----------|-----------------|
| [provider] | [file:pattern] | [Yes / No — reason] | [list controls if scanned] |
```

### 9. Remediation Roadmap

```markdown
## Recommended Remediation Roadmap

### Priority 1 — Quick Wins

Technical controls that can be implemented quickly with high compliance impact.

| Action | Policy | Effort | Impact |
|--------|--------|--------|--------|
| [e.g., "Add branch protection rules"] | change-management | Low | Covers CC8.1 |
| [e.g., "Enable dependency scanning in CI"] | vulnerability-monitoring | Low | Covers CC7.1 |

### Priority 2 — Generate Policies for Gap Areas

| Policy | Controls Covered | Effort |
|--------|-----------------|--------|
| [policy-name] | [controls] | [Low / Medium / High] |

### Priority 3 — Set Up Evidence Collection

| Tool / Provider | Evidence Type | Policies Supported |
|-----------------|--------------|-------------------|
| [tool] | [SaaS / Cloud] | [policies] |
```

### 10. Required Footer

```markdown
---
**Assessment Safety Note:** This assessment identifies detectable controls and aims to indicate technical readiness. It is not a substitute for a formal audit. Process and governance controls require manual verification.

---
Generated with [Compliance Automation](https://github.com/screenata/compliance-automation)
```
