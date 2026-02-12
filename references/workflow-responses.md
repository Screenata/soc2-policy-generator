# External Document Response Workflow

This file contains the detailed steps for mapping auditor control matrices, security questionnaires (SIG, CAIQ, custom), and vendor questionnaires to existing policies and evidence. Load this file when the user provides an external compliance document to respond to.

## Prerequisites

If `.compliance/config.json` does not exist, gather abbreviated context first:

**Q1:** What is your organization's name?
**Q2:** What industry is your company in? (Healthcare, Fintech, B2B SaaS, E-commerce, Other)
**Q3:** Which compliance framework? (SOC 2, ISO 27001, or both)

Write answers to `.compliance/config.json`, leaving unneeded fields null.

Also read `.compliance/status.md` to see which policies have been generated. If no policies exist, tell the user:
> No policies have been generated yet. I'll map your document to the framework controls and show you which policies to generate first. The response will show gaps that get filled in as you generate policies.

## Input Formats Supported

- `.xlsx` / `.xls` file (preferred — auditor control matrices are typically spreadsheets)
- `.csv` file
- Pasted text (markdown table, numbered list, or raw text)

## Step 1: Read and Understand the Document Structure

**If the user provides an XLSX/CSV file:**

1. Install `openpyxl` if needed: `pip3 install openpyxl`
2. Read the file using Python and print out:
   - Sheet names (for XLSX)
   - Column headers
   - First 3-5 data rows
   - Total row count
3. **Identify the column roles** by reading the headers and sample data. Look for columns that serve these roles:
   - **ID column:** Control/test identifiers (e.g., "Control ID", "Test #", "Ref", "Q#")
   - **Control reference column:** Framework control codes (e.g., "Trust ID", "TSC", "Control Ref", "Annex A")
   - **Description column:** What the control requires or the question text (e.g., "Control Description", "Requirement", "Question", "Trust Services Criteria")
   - **Control activity column:** What the company does to satisfy the control (e.g., "Control Activity", "Implementation", "How we meet this")
   - **Evidence/responsibility column:** What evidence is expected (e.g., "Evidence Required", "Company Responsibilities", "Artifacts")
   - **Status column:** Where to mark coverage status (e.g., "Status", "Control Status", "Compliance Status")
   - **Response/comments column:** Where to write the company's response (e.g., "Company Comments", "Response", "Notes", "Company Response")
4. **Present the column mapping to the user for confirmation:**
   > I've read your spreadsheet. Here's what I found:
   >
   > - **[N] rows** of controls/questions across [N] sheets
   > - Column layout:
   >   - Column A "[header]" → Control IDs
   >   - Column B "[header]" → Framework control codes
   >   - Column C "[header]" → Requirements/descriptions
   >   - Column D "[header]" → Control activities (company fills in)
   >   - Column F "[header]" → Status (company fills in)
   >   - Column G "[header]" → Comments (company fills in)
   >
   > I'll draft responses for the fillable columns (D, F, G) and you can review before I write them back.
   >
   > Does this mapping look right? Are there columns I should skip or any I missed?
5. Wait for user confirmation. If the user corrects the mapping, adjust accordingly.

**If the user pastes text:**

1. Ask the user to confirm the source name:
   > What should I call this document? (e.g., "ACME Corp SOC 2 Audit Q3 2024", "Vendor Security Questionnaire")
2. Parse the pasted content and extract for each item:
   - **ID:** Test number, control ID, or row number
   - **Description:** The test description or security question
   - **Control references:** Any explicit TSC codes (CC#.#) or Annex A codes (A.#.#) mentioned
3. If the content is ambiguous, show the first 5 parsed rows and ask:
   > Here's how I parsed the first few items. Does this look right?

**In both cases**, save the parsed input to `.compliance/responses/{sanitized-name}-raw.md` as a normalized table:

```markdown
---
source: "ACME Corp SOC 2 Audit Q3 2024"
input_format: xlsx  # or csv, pasted
input_file: "path/to/original.xlsx"  # if applicable
parsed_date: 2024-01-15
total_items: 80
column_mapping:
  id: A
  trust_id: B
  description: C
  control_activity: D
  evidence_required: E
  status: F
  comments: G
---

| ID | Description | Referenced Controls |
|----|-------------|---------------------|
| PA-1 | Board charter outlining oversight responsibilities | CC 1.2, CC 1.3 |
| PA-2 | Board expertise to oversee security controls | CC 1.2 |
```

## Step 2: Map Each Item

For each parsed item:

1. **Resolve control codes:**
   - If the item includes explicit control codes (CC#.#, A.#.#), use them directly
   - If no codes, semantically match the description to controls by reading `references/frameworks/soc2.md` and/or `references/frameworks/iso27001.md` (based on the framework in config.json). Use the "Criteria Reference" section in `soc2.md` for deeper matching using summaries and key topics

2. **Map controls to policies:**
   - Look up the matched control codes in the framework files to find the corresponding policy ID(s)
   - Example: CC6.1 → `access-control`, CC7.3 → `incident-response`

3. **Check policy and evidence existence:**
   - Look for `.compliance/policies/{policy-id}.md`
   - If the policy file exists, extract:
     - Relevant procedure text for drafting a response
     - Evidence from Codebase table entries (if any)
     - Evidence from Cloud Infrastructure table entries (if any)
     - Evidence from SaaS Tools table entries (if any)
     - Relevant "Proof Required Later" items
   - Also check `.compliance/evidence/` for collected evidence files

4. **Determine coverage status:**
   - **Covered:** Policy exists AND has at least one evidence item (code, cloud, or SaaS)
   - **Partial:** Policy exists but no automated evidence collected yet
   - **Gap:** No policy generated for the mapped control(s)
   - **Unmapped:** Cannot confidently match to any control — flag for user review

## Step 3: Generate Response Document

Always generate a markdown response document first — this is the working document for review. Save to `.compliance/responses/{sanitized-name}.md`:

```markdown
---
source: "ACME Corp SOC 2 Audit Q3 2024"
input_format: xlsx
generated: 2024-01-15
total_items: 80
covered: 52
partial: 18
gaps: 8
unmapped: 2
---

<!--
GENERATED DRAFT ONLY - USER REVIEW REQUIRED

- Mappings are AI-generated and may contain errors
- Review each response before submitting to your auditor
- Edit below the <!-- user-edit --> markers — those edits are preserved on re-run
-->

# ACME Corp SOC 2 Audit Q3 2024 — Response

## Coverage Summary

| Status | Count | % |
|--------|-------|---|
| Covered | 52 | 65% |
| Partial | 18 | 22% |
| Gap | 8 | 10% |
| Unmapped | 2 | 3% |

---

## Responses

### PA-1 — Board charter outlining oversight responsibilities

**Status:** Covered
**Controls:** CC 1.2, CC 1.3 → `governance-board-oversight`

<!-- auto-generated -->

**Control Activity (Column D):**
The company's board of directors has a documented charter that outlines its oversight responsibilities for internal control, including information security governance. [Tailored using policy procedures and any extracted evidence values]

**Company Comments (Column G):**
See governance-board-oversight policy. Evidence: [list specific evidence items with file references]. Manual evidence to collect: board meeting minutes, org chart.

**Suggested Status (Column F):** Implemented

**Evidence:**
- Policy: `.compliance/policies/governance-board-oversight.md`
- [Any code/cloud/SaaS evidence references]

**Manual evidence needed:**
- [ ] Board meeting minutes (Policy)
- [ ] Board charter document (Policy)

<!-- end-auto-generated -->

<!-- user-edit: Add your notes below this line -->

---

### PA-2 — Board expertise to oversee security controls
...
```

At the end of the response document, add a gaps section:

```markdown
## Gaps — Action Required

These items have no matching policy. Generate the recommended policies to fill these gaps.

| ID | Description | Recommended Policy | Controls |
|----|-------------|-------------------|----------|
| PA-38 | BC/DR plans | `business-continuity` | CC 9.1 |
| PA-47 | Vendor management program | `vendor-management` | CC 9.2 |

## Unmapped Items — User Review Required

These items could not be confidently matched to any control. Please map them manually.

| ID | Description | Suggested Control | Notes |
|----|-------------|-------------------|-------|
| ... | ... | — | Could not confidently match |

## Suggested Next Steps

1. **Review the draft responses above** — edit control activities and comments to match your actual processes
2. **Generate missing policies** for gap items: [list policy names] (covers [N] items)
3. **Collect manual evidence** for partially covered items
4. Once reviewed, I'll write the responses back to the original spreadsheet
```

## Step 4: Present Summary and Offer Write-Back

After generating the markdown response, present to the user:

> I've mapped your [document name] to our compliance artifacts. Here's the breakdown:
>
> - **Covered:** [N] items ([%]) — policy exists with evidence
> - **Partial:** [N] items ([%]) — policy exists, needs evidence
> - **Gaps:** [N] items ([%]) — need to generate these policies
> - **Unmapped:** [N] items ([%]) — couldn't match, needs your review
>
> Response saved to `.compliance/responses/{name}.md` — **please review and edit before I write it back.**
>
> What would you like to do?
> 1. **Review the responses** — I'll walk through them with you
> 2. **Write back to XLSX** — I'll fill in the spreadsheet with the draft responses (you can still edit after)
> 3. **Generate missing policies** first — covers [N] gap items
> 4. **Re-map** after editing — I'll update the mappings

**XLSX Write-Back (when user chooses option 2 or confirms after review):**

1. Ensure `openpyxl` is installed: `pip3 install openpyxl`
2. Write a Python script to `.compliance/scripts/fill-responses.py` that:
   - Opens the original XLSX file
   - For each row, finds the matching response from the markdown response document
   - Fills in the identified response columns (e.g., Control Activity, Status, Comments) using the draft values
   - Preserves all existing formatting, merged cells, formulas, and data in other columns
   - Saves to `.compliance/responses/{name}-filled.xlsx` (never overwrites the original)
3. Run the script and confirm success
4. Tell the user:
   > Done! Filled spreadsheet saved to `.compliance/responses/{name}-filled.xlsx`
   >
   > **Original file is unchanged.** Review the filled version and copy it to your auditor when ready.

**Important write-back rules:**
- **Never overwrite the original file.** Always save to a new file in `.compliance/responses/`.
- **Only fill columns the user confirmed as fillable** in Step 1.
- **Preserve all existing cell values** — if a cell already has content, append rather than replace (unless the user explicitly says to overwrite).
- **Mark draft values** — if the spreadsheet has a status column, use values like "Implemented", "Partially Implemented", "Not Implemented", or "Needs Review" depending on coverage status.

If the user wants to generate missing policies, route to [workflow-policies.md](workflow-policies.md) Step 3 with the recommended policy pre-selected, then loop through Steps 4-6. After generating, offer to re-run the mapping.

## Step 5: Re-run Mapping

When the user asks to re-run (e.g., "update the mapping", "re-run", or after generating new policies):

1. Read the existing response file `.compliance/responses/{name}.md`
2. Read the raw input file `.compliance/responses/{name}-raw.md` to get original items and column mapping
3. For each section in the response:
   - **Replace** content between `<!-- auto-generated -->` and `<!-- end-auto-generated -->` with freshly generated content (updated evidence, status, etc.)
   - **Preserve** any content the user added after `<!-- user-edit -->` markers
4. Update the coverage counts in the frontmatter
5. Update the "Response Mappings" table in `.compliance/status.md`
6. Present updated coverage summary to the user
7. If the input was XLSX, offer to re-run the write-back to produce an updated filled spreadsheet

## Status Tracking

After generating or re-running a response document, update `.compliance/status.md` by adding or updating a row in the "Response Mappings" table:

```markdown
| ACME Corp SOC 2 Audit Q3 2024 | `responses/acme-q3-2024.md` | 80 | 65% | 2024-01-15 |
```
