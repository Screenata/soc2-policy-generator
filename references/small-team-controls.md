# Small-Team Compensating Controls Reference

When the organization has ≤ 10 employees, standard controls that assume multiple dedicated roles often don't apply directly. Auditors routinely accept compensating controls — alternative measures that mitigate the same risk through different means.

**When to use this reference:** Load this file when `config.json` shows `company_size` of "1-10". Incorporate relevant compensating controls into policy generation and Q&A guidance.

**Key principle:** SOC 2 is risk-based, not headcount-based. The system description should explicitly acknowledge team size and explain why compensating controls adequately address each risk.

---

## Segregation of Duties (SoD)

**The standard control:** Different people perform development, code review, deployment approval, and production access management.

**Why small teams struggle:** With 1-5 developers, the same person often writes, reviews, and deploys code.

### Compensating Controls

**1. Automated CI/CD as Independent Reviewer**
- Required status checks (linting, tests, security scans) must pass before merge
- Branch protection rules prevent direct pushes to main/production
- **Evidence:** Branch protection settings screenshot, CI/CD pipeline configuration, deployment logs showing automated checks
- **Auditor framing:** "Automated controls serve as an independent verification layer, reducing reliance on manual review"

**2. Immutable Audit Trails**
- All code changes tracked in version control with commit signing
- Deployment logs in append-only storage (CloudWatch, Datadog, etc.)
- Infrastructure changes tracked via IaC (Terraform state, CloudFormation)
- **Evidence:** Git log exports, deployment history, IaC change history
- **Auditor framing:** "Comprehensive audit trails enable after-the-fact review and anomaly detection even when real-time separation isn't feasible"

**3. Independent Monitoring & Alerting**
- Third-party monitoring detects unauthorized or anomalous changes
- Alerts route to multiple stakeholders (even if team is small)
- Cloud provider security services (GuardDuty, Security Command Center, Defender)
- **Evidence:** Monitoring dashboard screenshots, alert configuration, alert history
- **Auditor framing:** "Independent monitoring systems provide detective controls that compensate for limited preventive separation"

**4. Periodic External Review**
- Outsourced code review for critical changes (quarterly or per-release)
- External penetration testing (annually at minimum)
- Automated security scanning tools (CodeQL, Snyk, SonarCloud)
- **Evidence:** External review reports, pen test findings, scan results
- **Auditor framing:** "Regular independent assessment provides assurance that controls operate as intended"

### System Description Language

When generating the system description for a small team with SoD compensating controls, include language like:

> Due to the organization's size ([X] employees), traditional segregation of duties across development, review, and deployment roles is not fully achievable. The organization mitigates this risk through: (1) automated CI/CD pipelines with mandatory security checks, (2) immutable audit trails for all code and infrastructure changes, (3) independent monitoring and alerting via [tool], and (4) periodic external security reviews. These compensating controls collectively provide assurance that unauthorized or erroneous changes are detected and addressed.

---

## Board & Management Oversight

**The standard control:** A board of directors or equivalent body provides oversight of the control environment, including regular review of security practices and risk management.

**Why small teams struggle:** Startups often have no formal board, and the CEO/founder is also the person implementing controls.

### Compensating Controls

**1. Documented Advisory Board**
- Even an informal group of advisors counts if meetings are documented
- Quarterly advisory sessions with documented agendas and decisions
- **Evidence:** Meeting minutes, advisory board charter (can be simple), attendee list
- **Auditor framing:** "The organization maintains an advisory group that provides independent oversight of security and operational practices"

**2. External Review Cadence**
- Quarterly review by external accountant, lawyer, or security consultant
- Annual security assessment by independent third party
- **Evidence:** Review reports, consultant engagement letters, findings documentation
- **Auditor framing:** "Independent external reviews serve the oversight function typically performed by a board"

**3. Documented Decision Logs**
- Management decisions on risk acceptance, control changes, and security investments are recorded
- Even a simple log in Notion/Confluence/Google Docs qualifies
- **Evidence:** Decision log entries with dates, rationale, and outcomes
- **Auditor framing:** "Documented management review and decision-making processes demonstrate active governance despite the absence of a formal board structure"

### System Description Language

> The organization operates without a traditional board of directors. Management oversight is maintained through: (1) an advisory group consisting of [description] that meets [frequency], (2) quarterly external reviews by [type of advisor], and (3) documented decision logs for all material security and operational decisions. These mechanisms ensure independent oversight of the control environment.

---

## Dedicated Security Personnel

**The standard control:** A qualified individual (CISO, security manager) is responsible for the organization's security program.

**Why small teams struggle:** Hiring a full-time security professional isn't economically viable for teams under 10 people.

### Compensating Controls

**1. Virtual CISO (vCISO) Arrangement**
- Part-time, outsourced security leadership (typically 5-10 hours/month)
- Provides expertise for control design, risk assessment, and incident response planning
- **Evidence:** vCISO engagement contract, meeting records, deliverables
- **Auditor framing:** "The organization engages a qualified virtual CISO who provides security leadership and oversight on a recurring basis"

**2. Shared Responsibility Model with Ownership Matrix**
- Security responsibilities documented and distributed across existing team members
- RACI matrix (or simpler) showing who owns what
- Each person's security responsibilities included in their role description
- **Evidence:** Responsibility matrix, role descriptions, training records
- **Auditor framing:** "Security responsibilities are formally assigned across the team with documented ownership, ensuring comprehensive coverage despite the absence of a dedicated security role"

**3. Automated Security Tooling**
- Dependabot / Renovate for dependency vulnerability management
- SAST/DAST tools in CI/CD pipeline
- Cloud security posture management (AWS Config, GCP SCC, Azure Defender)
- Endpoint protection on all devices
- **Evidence:** Tool configurations, scan results, remediation records
- **Auditor framing:** "Automated security tooling provides continuous monitoring and vulnerability detection, reducing the operational burden on the team"

### System Description Language

> Security program management is handled through a combination of: (1) a virtual CISO / designated security lead ([name/arrangement]), (2) documented security responsibilities distributed across the [X]-person team, and (3) automated security tooling providing continuous monitoring. This model ensures qualified security oversight while reflecting the organization's size and operational structure.

---

## Access Management

**The standard control:** Access provisioning and deprovisioning are reviewed and approved by someone other than the requestor. Periodic access reviews are conducted.

**Why small teams struggle:** When there are only 2-3 people, everyone may need broad access, and there's no dedicated IT team to manage provisioning.

### Compensating Controls

**1. Principle of Least Privilege via IaC**
- Infrastructure access defined in code (Terraform, Pulumi, CloudFormation)
- Changes to access require code review and deployment pipeline
- **Evidence:** IaC configurations, change history, PR review records
- **Auditor framing:** "Access management is codified in infrastructure-as-code, ensuring changes are tracked, reviewed, and auditable"

**2. Automated Access Reviews**
- Identity provider exports showing current access (Okta, Google Workspace, etc.)
- Quarterly review documented with sign-off (even if just one person reviewing)
- **Evidence:** Access review exports, review completion records with dates
- **Auditor framing:** "Quarterly access reviews are conducted using identity provider reports, with documented sign-off confirming appropriateness of access levels"

**3. Time-Limited Elevated Access**
- Break-glass procedures for production access with automatic expiry
- Just-in-time access provisioning where possible
- All elevated access logged and reviewed
- **Evidence:** Break-glass procedure documentation, access logs showing time-limited grants
- **Auditor framing:** "Elevated access is granted on a time-limited, just-in-time basis with comprehensive logging"

### System Description Language

> Access management reflects the organization's [X]-person team size. Access is provisioned through [identity provider] with infrastructure access codified in [IaC tool]. Quarterly access reviews are conducted and documented. Elevated production access follows break-glass procedures with time-limited grants and comprehensive logging.

---

## Change Management (Solo / Small Dev Team)

**The standard control:** Code changes are reviewed by someone other than the author before deployment to production.

**Why small teams struggle:** A solo developer or 2-person team cannot always have a different person review every change.

### Compensating Controls

**1. Automated CI/CD Pipeline as Reviewer**
- Mandatory test suites, linting, and security scans before deployment
- No direct deployment to production — all changes go through the pipeline
- Automated rollback capabilities
- **Evidence:** Pipeline configuration, deployment logs, test/scan results
- **Auditor framing:** "An automated CI/CD pipeline with mandatory quality and security gates serves as an independent verification step for all production changes"

**2. Post-Deployment Verification**
- Documented checklist verified after each production deployment
- Automated health checks and smoke tests
- Monitoring alerts for deployment-correlated anomalies
- **Evidence:** Deployment checklist records, health check results, monitoring configuration
- **Auditor framing:** "Post-deployment verification procedures and automated health monitoring provide detective controls for change-related issues"

**3. Outsourced Code Review for Critical Changes**
- External reviewer for security-sensitive or high-risk changes
- Threshold-based: all changes above a defined risk level get external review
- **Evidence:** External review records, risk categorization criteria, reviewer engagement
- **Auditor framing:** "High-risk changes undergo independent external review, ensuring critical code paths receive qualified scrutiny"

**4. Comprehensive Change Documentation**
- All changes tracked in ticketing system (Jira, Linear, GitHub Issues)
- Commits linked to tickets
- Deployment records linked to change requests
- **Evidence:** Ticket history, commit-to-ticket linkage, deployment records
- **Auditor framing:** "All changes are tracked from request through deployment, providing a complete audit trail"

### System Description Language

> Change management is adapted to the organization's [X]-person development team. All code changes are tracked in [ticketing system] and deployed exclusively through an automated CI/CD pipeline that enforces testing, linting, and security scanning. [If applicable: Changes to security-sensitive components undergo external review.] Post-deployment verification and automated health monitoring provide additional assurance. This approach ensures change quality and traceability while reflecting the team's operational reality.

---

## Usage in Policy Generation

When generating policies for a small team (≤ 10 employees):

1. **During Q&A:** When a policy question surfaces a control that typically requires multiple roles, proactively offer the relevant compensating control pattern from this file
2. **In policy text:** Use the "System Description Language" templates to frame compensating controls positively — focus on what the organization DOES, not what it lacks
3. **In evidence tables:** Include the evidence items listed under each compensating control as required evidence for the policy
4. **Tone:** Never frame small size as a weakness. Frame it as an operational context that the control environment is designed around
