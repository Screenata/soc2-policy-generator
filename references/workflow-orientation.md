# Workflow: SOC 2 Orientation

Guide newcomers through the fundamentals before they start generating policies or running assessments. Deliver this conversationally — one concept per message, wait for acknowledgment, then continue.

---

## Step 1: Welcome & Gauge Familiarity

Start with:

> **Welcome! Let's make sure you have a solid foundation before diving into compliance work.**
>
> How familiar are you with SOC 2?
> 1. Brand new — I've heard the term but that's about it
> 2. Somewhat familiar — I know it's a security/compliance thing but not the details
> 3. Fairly familiar — I understand the basics but have specific questions

- If **option 1 or 2** → proceed to Step 2 (full orientation)
- If **option 3** → ask "What would you like to understand better?" and answer their specific questions, then skip to Step 7 (decision tree)

---

## Step 2: What SOC 2 Actually Is

> **SOC 2 is an attestation — not a certification.**
>
> A licensed CPA firm examines your security controls and issues a report describing what they found. It's more like a home inspection report than a diploma.
>
> Key things to know:
> - **You don't "pass" or "fail"** — the auditor reports on whether your controls are designed properly (Type 1) or operating effectively over time (Type 2)
> - **It's a historical report** — it describes what existed at a point in time or during a specific period, like a newspaper
> - **It's based on YOUR controls** — unlike a checklist framework, SOC 2 lets you define controls that fit how your company actually operates
> - **You need a CPA firm** — you cannot self-certify; the report must come from a licensed auditor
>
> Ready to continue?

Wait for acknowledgment, then proceed.

---

## Step 3: Type 1 vs Type 2

> **There are two types of SOC 2 reports, and you should almost always start with Type 1.**
>
> **Type 1 (Point-in-Time)**
> - Examines the *design* of your controls at a single date
> - "Do you have the right controls in place?"
> - Typical prep time: 2-4 months
> - Lower cost, faster to complete
> - Good first step to show customers you're serious
>
> **Type 2 (Period of Time)**
> - Examines the *operating effectiveness* of your controls over 3-12 months
> - "Are you actually following your controls consistently?"
> - Requires an observation period (usually 6-12 months)
> - This is what most enterprise customers ultimately want
>
> **The typical path:** Type 1 first → begin your observation period → Type 2 audit after 6-12 months of operating your controls.
>
> Some auditors will issue a "bridge letter" while you're between Type 1 and Type 2, which can help you close deals in the interim.
>
> Make sense so far?

Wait for acknowledgment.

---

## Step 4: The 5 Trust Service Categories

> **SOC 2 is organized around 5 Trust Service Categories (TSCs). You choose which ones apply to you.**
>
> | Category | What It Covers | Who Needs It |
> |----------|---------------|--------------|
> | **Security** (required) | Protection against unauthorized access | Everyone — this is mandatory |
> | **Availability** | System uptime and performance | If you promise SLAs or uptime guarantees |
> | **Confidentiality** | Protection of confidential data | If you handle sensitive business data |
> | **Processing Integrity** | Accurate and complete data processing | If data accuracy is critical (fintech, analytics) |
> | **Privacy** | Personal information handling | If you collect end-user personal data |
>
> **Most startups start with Security only.** You can add categories in future audits as your commitments grow. Starting narrow keeps scope manageable and costs down.
>
> Your auditor will help you decide which categories to include based on what you promise customers in your contracts.
>
> Questions about the categories, or shall we continue?

Wait for acknowledgment.

---

## Step 5: What Auditors Actually Look At

> **An auditor examines three things:**
>
> 1. **Your system description** — a written narrative of what your service does, how it's built, who's involved, and what you promise customers
> 2. **Your controls** — the specific security practices you've implemented (policies, technical configurations, processes)
> 3. **Evidence that controls work** — logs, screenshots, configurations, records that prove you're doing what you say
>
> In practice, this means:
> - **Policies** — documented rules for how your company handles security, access, changes, incidents, etc.
> - **Technical controls** — MFA enforcement, encryption, access reviews, vulnerability scanning, etc.
> - **Process controls** — onboarding/offboarding procedures, vendor reviews, risk assessments, etc.
> - **Evidence** — the artifacts that prove all of the above actually happens
>
> The auditor does NOT build your controls for you. They verify what you've built. That's why preparation is the real work.
>
> Ready for the practical stuff?

Wait for acknowledgment.

---

## Step 6: Realistic Expectations

> **Here's what the process actually looks like for a small team:**
>
> **Timeline**
> - Readiness assessment: 1-2 weeks
> - Gap remediation + policy creation: 1-3 months
> - Type 1 audit: 2-4 weeks
> - Observation period for Type 2: 6-12 months
> - Type 2 audit: 3-6 weeks
>
> **Cost ranges** (varies significantly by scope and auditor quality)
> - GRC automation tool (optional): $5k-$20k/year
> - Readiness assessment: $5k-$15k (or included with auditor)
> - Type 1 audit: $15k-$40k
> - Type 2 audit: $20k-$60k
> - Total first year: $25k-$80k depending on approach
>
> **What matters more than tools:**
> - Someone who understands the controls and can make decisions
> - Management commitment to follow through
> - Realistic policies you can actually comply with (don't over-promise)
>
> **For small teams (≤ 10 people):** SOC 2 is risk-based, not headcount-based. Even one-person companies have achieved it. Where standard controls require multiple people (like segregation of duties), auditors accept well-documented compensating controls. I'll help you with those when we get to policy generation.
>
> **Red flags when choosing an auditor:**
> - Sub-$10k for a Type 1 (likely a rubber stamp)
> - Promises of unrealistic timelines ("SOC 2 ready in 2 weeks")
> - Works entirely within a GRC platform with minimal auditor involvement
> - Takes a one-size-fits-all approach instead of tailoring controls to your risks
>
> That's the full picture. Let's figure out your best next step.

Wait for acknowledgment.

---

## Step 7: Decision Tree — What to Do Next

> **Based on where you are, here's what I'd recommend:**
>
> 1. **Run a readiness assessment** (recommended first step) — I'll scan your codebase, cloud infrastructure, and SaaS tools to identify what controls you already have and where the gaps are. Takes ~5 minutes and gives you a concrete starting point.
>
> 2. **Start generating policies** — if you already know your gaps and want to jump into creating the compliance documentation your auditor will need.
>
> 3. **Respond to an auditor control matrix** — if you already have a document from your auditor or a customer questionnaire that needs responses.
>
> Which would you like to do?

Route based on answer:
- **Option 1** → Load [workflow-assessment.md](workflow-assessment.md) and begin Step 1
- **Option 2** → Load [workflow-policies.md](workflow-policies.md) and begin Step 1
- **Option 3** → Load [workflow-responses.md](workflow-responses.md) and begin Step 1
