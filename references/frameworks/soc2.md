# SOC 2 Trust Services Criteria — Control Mappings & Matching Reference

This file maps each policy to its relevant SOC 2 Trust Services Criteria (TSC) and provides criteria summaries with key matching topics for semantic matching in the External Document Response workflow ([workflow-responses.md](../workflow-responses.md)).

Source: Based on AICPA 2017 Trust Services Criteria (TSP Section 100), with March 2020 updates.

## How to Use

**For policy generation (Steps 3-6):**
1. Look up the policy ID in the "Control Mappings by Policy" section
2. Include all listed TSC codes in the policy's `satisfies.TSC` frontmatter
3. Reference the criteria descriptions in the policy body where appropriate

**For control matrix mapping (External Document Response workflow):**
1. Use the "Criteria Reference" section to match auditor descriptions to TSC codes
2. Each criterion has a summary and key matching topics for semantic matching
3. Match auditor test descriptions against the key topics to find the right TSC code

## Control Mappings by Policy

### governance-board-oversight

| TSC Code | Description |
|----------|-------------|
| CC1.1 | Demonstrates commitment to integrity and ethical values |
| CC1.2 | Board exercises oversight responsibility |
| CC1.3 | Management establishes structures and reporting lines |

### organizational-structure

| TSC Code | Description |
|----------|-------------|
| CC1.3 | Management establishes structures and reporting lines |
| CC1.4 | Demonstrates commitment to attract, develop, retain competent individuals |
| CC1.5 | Holds individuals accountable for internal control responsibilities |

### code-of-conduct

| TSC Code | Description |
|----------|-------------|
| CC1.1 | Demonstrates commitment to integrity and ethical values |
| CC1.4 | Demonstrates commitment to attract, develop, retain competent individuals |

### information-security-policy

| TSC Code | Description |
|----------|-------------|
| CC1.1 | Demonstrates commitment to integrity and ethical values |
| CC2.2 | Internally communicates information for internal control |
| CC5.1 | Selection and development of control activities |
| CC5.2 | Selection and development of general controls over technology |
| CC5.3 | Deploys control activities through policies and procedures |

### incident-response

| TSC Code | Description |
|----------|-------------|
| CC7.3 | Evaluates security events to determine failures |
| CC7.4 | Responds to identified security incidents |
| CC7.5 | Identifies and implements activities to recover from incidents |

### external-communications

| TSC Code | Description |
|----------|-------------|
| CC1.1 | Demonstrates commitment to integrity and ethical values |
| CC2.2 | Internally communicates information for internal control |
| CC2.3 | Communicates with external parties regarding internal control |

### vendor-management

| TSC Code | Description |
|----------|-------------|
| CC9.2 | Assesses and manages risks associated with vendors and business partners |

### risk-management

| TSC Code | Description |
|----------|-------------|
| CC3.1 | Specifies objectives to enable identification and assessment of risks |
| CC3.2 | Identifies and analyzes risks to objectives |
| CC3.3 | Considers potential for fraud in assessing risks |
| CC3.4 | Identifies and assesses changes that could significantly impact internal controls |

### change-management

| TSC Code | Description |
|----------|-------------|
| CC8.1 | Authorizes, designs, develops, configures, documents, tests, approves, and implements changes |

### access-control

| TSC Code | Description |
|----------|-------------|
| CC6.1 | Implements logical access security software and architectures |
| CC6.2 | Registers and authorizes new users before issuing credentials |
| CC6.3 | Authorizes, modifies, or removes access to protected assets |

### data-management

| TSC Code | Description |
|----------|-------------|
| CC6.5 | Discontinues protections only after no longer necessary |
| CC6.6 | Implements logical access security against external threats |
| CC6.7 | Restricts transmission, movement, and removal of information |
| CC8.1 | Authorizes, designs, develops, configures, documents, tests, approves, and implements changes |

### physical-security

| TSC Code | Description |
|----------|-------------|
| CC6.4 | Restricts physical access to facilities and protected information assets |

### vulnerability-monitoring

| TSC Code | Description |
|----------|-------------|
| CC2.1 | Generates and uses relevant, quality information to support internal control |
| CC4.1 | Selects, develops, and performs evaluations to ascertain controls are functioning |
| CC4.2 | Evaluates and communicates internal control deficiencies |
| CC7.1 | Uses detection and monitoring to identify configuration changes |
| CC7.2 | Monitors system components for anomalies |

### network-security

| TSC Code | Description |
|----------|-------------|
| CC6.6 | Implements logical access security against external threats |
| CC6.7 | Restricts transmission, movement, and removal of information |
| CC7.1 | Uses detection and monitoring to identify configuration changes |

### business-continuity

| TSC Code | Description |
|----------|-------------|
| CC9.1 | Identifies, selects, and develops risk mitigation activities for business disruptions |
| A1.2 | Authorizes, implements, operates, and monitors environmental protections |
| A1.3 | Tests recovery plan procedures supporting system recovery |
| CC7.4 | Responds to identified security incidents |

### human-resources

| TSC Code | Description |
|----------|-------------|
| CC1.4 | Demonstrates commitment to attract, develop, retain competent individuals |
| CC1.5 | Holds individuals accountable for internal control responsibilities |

### mobile-endpoint

| TSC Code | Description |
|----------|-------------|
| CC6.6 | Implements logical access security against external threats |
| CC6.7 | Restricts transmission, movement, and removal of information |
| CC6.8 | Implements controls to prevent or detect unauthorized or malicious software |

## Quick Reference

| Policy ID | TSC Codes |
|-----------|-----------|
| governance-board-oversight | CC1.1, CC1.2, CC1.3 |
| organizational-structure | CC1.3, CC1.4, CC1.5 |
| code-of-conduct | CC1.1, CC1.4 |
| information-security-policy | CC1.1, CC2.2, CC5.1, CC5.2, CC5.3 |
| incident-response | CC7.3, CC7.4, CC7.5 |
| external-communications | CC1.1, CC2.2, CC2.3 |
| vendor-management | CC9.2 |
| risk-management | CC3.1, CC3.2, CC3.3, CC3.4 |
| change-management | CC8.1 |
| access-control | CC6.1, CC6.2, CC6.3 |
| data-management | CC6.5, CC6.6, CC6.7, CC8.1 |
| physical-security | CC6.4 |
| vulnerability-monitoring | CC2.1, CC4.1, CC4.2, CC7.1, CC7.2 |
| network-security | CC6.6, CC6.7, CC7.1 |
| business-continuity | CC9.1, A1.2, A1.3, CC7.4 |
| human-resources | CC1.4, CC1.5 |
| mobile-endpoint | CC6.6, CC6.7, CC6.8 |

---

## Criteria Reference — Summaries & Matching Topics

Each criterion below includes a summary and key matching topics for semantic matching in the External Document Response workflow ([workflow-responses.md](../workflow-responses.md)). Use these to match auditor control descriptions to the correct TSC codes when explicit codes are not provided.

### CC1 — Control Environment

**CC1.1** — Commitment to integrity and ethical values
- **Topics:** Code of conduct, ethical standards, tone at the top, background checks, confidentiality agreements, contractor agreements

**CC1.2** — Board independence and oversight of internal controls
- **Topics:** Board oversight, board independence, board expertise, board meetings, board charter, security briefings, audit committee, third-party experts

**CC1.3** — Management structures, reporting lines, authorities
- **Topics:** Organizational structure, org chart, reporting lines, roles and responsibilities, delegation of authority, segregation of duties

**CC1.4** — Attract, develop, and retain competent individuals
- **Topics:** Hiring practices, competency requirements, training, performance evaluations, succession planning, security awareness training, onboarding

**CC1.5** — Accountability for internal control responsibilities
- **Topics:** Accountability, performance measures, disciplinary actions, corrective actions, termination procedures

### CC2 — Communication and Information

**CC2.1** — Quality information to support internal controls
- **Topics:** Information quality, monitoring data, log management, event identification, vulnerability scanning, penetration testing

**CC2.2** — Internal communication of control information
- **Topics:** Internal communication, security policies communicated, policy acknowledgment, system changes communicated, whistleblower policy, security awareness

**CC2.3** — External communication regarding internal controls
- **Topics:** External communication, customer commitments, SLAs, MSAs, terms of service, privacy notices, support systems, customer notifications, vendor agreements

### CC3 — Risk Assessment

**CC3.1** — Objectives specified for risk identification
- **Topics:** Operational objectives, compliance objectives, risk identification, security objectives

**CC3.2** — Risk identification and analysis
- **Topics:** Risk identification, risk analysis, risk register, threat assessment, vulnerability assessment, vendor risk, BC/DR risk

**CC3.3** — Fraud risk consideration
- **Topics:** Fraud risk, unauthorized access, data manipulation, management override

**CC3.4** — Changes impacting internal controls
- **Topics:** Technology changes, environment changes, regulatory changes, acquisitions, rapid growth, configuration management

### CC4 — Monitoring Activities

**CC4.1** — Evaluations of control functioning
- **Topics:** Ongoing monitoring, control testing, internal audit, external audit, vulnerability scans, penetration testing, compliance monitoring

**CC4.2** — Communication of control deficiencies
- **Topics:** Deficiency identification, remediation tracking, corrective actions, audit findings

### CC5 — Control Activities

**CC5.1** — Control activities for risk mitigation
- **Topics:** Control selection, control design, risk mitigation, preventive controls, detective controls

**CC5.2** — General controls over technology
- **Topics:** Technology infrastructure, IT general controls, SDLC, software development lifecycle

**CC5.3** — Policies and procedures deploying controls
- **Topics:** Policies and procedures, policy reassessment, data retention, disposal, backup, change management, risk management program

### CC6 — Logical and Physical Access Controls

**CC6.1** — Logical access security software and architectures
- **Topics:** Logical access, database access, OS access, firewall access, privileged access, encryption keys, data classification, asset inventory, unique usernames, password requirements, MFA, system segmentation, production access

**CC6.2** — User registration and access authorization
- **Topics:** User provisioning, access authorization, role-based access, least privilege, access requests, approval workflow, access reviews

**CC6.3** — Access modification and removal
- **Topics:** Access modification, access removal, termination checklists, role changes, access reviews, quarterly reviews

**CC6.4** — Physical access restrictions
- **Topics:** Physical access, facility security, visitor management, visitor badges, escort requirements, access cards, data center security

**CC6.5** — Discontinuation of protections via established processes
- **Topics:** Asset disposal, data destruction, media sanitization, data retention, data purging, electronic media destruction

**CC6.6** — Protection against external threats
- **Topics:** Firewalls, IDS/IPS, network monitoring, VPN, remote access, network hardening, encryption in transit, TLS/SSL, firewall rules review, patching, endpoint security

**CC6.7** — Restrictions on data transmission, movement, removal
- **Topics:** Data transmission, DLP, encryption, MDM, removable media, USB controls, portable media encryption

**CC6.8** — Prevention/detection of unauthorized or malicious software
- **Topics:** Anti-malware, antivirus, endpoint protection, software restrictions, code scanning, patching

### CC7 — System Operations

**CC7.1** — Detection and monitoring for configuration changes and vulnerabilities
- **Topics:** Configuration monitoring, vulnerability detection, baseline configurations, change detection, infrastructure monitoring, vulnerability scanning, hardening standards

**CC7.2** — Monitoring for anomalies
- **Topics:** Security monitoring, log monitoring, SIEM, anomaly detection, alert management, monitoring tools, intrusion detection, penetration testing

**CC7.3** — Security event evaluation
- **Topics:** Event evaluation, incident classification, triage, security event assessment

**CC7.4** — Incident response execution
- **Topics:** Incident response, containment, eradication, communication, escalation, root cause analysis, post-incident review, vulnerability remediation

**CC7.5** — Recovery from security incidents
- **Topics:** Incident recovery, restoration, lessons learned, BC/DR activation, recovery testing, incident response plan testing, tabletop exercises

### CC8 — Change Management

**CC8.1** — Change authorization, development, testing, approval, and implementation
- **Topics:** Change management, change authorization, change testing, code review, version control, deployment, rollback, emergency changes, CI/CD, branch protection, production migration, segregation of environments

### CC9 — Risk Mitigation

**CC9.1** — Risk mitigation for business disruptions
- **Topics:** Business continuity, disaster recovery, BC/DR, recovery plans, recovery testing, business impact analysis, cybersecurity insurance, data backup

**CC9.2** — Vendor and business partner risk management
- **Topics:** Vendor management, third-party risk, vendor assessments, vendor contracts, vendor monitoring, vendor performance, vendor termination, vendor SLAs

### Additional Criteria — Availability

**A1.1** — Capacity management
- **Topics:** Capacity planning, resource monitoring, performance monitoring, scalability

**A1.2** — Environmental protections, backup, and recovery infrastructure
- **Topics:** Backup infrastructure, recovery infrastructure, redundancy, failover, backup procedures, data replication

**A1.3** — Recovery plan testing
- **Topics:** Recovery testing, DR testing, BC/DR drills, tabletop exercises, failover testing, RTO, RPO

### Additional Criteria — Confidentiality

**C1.1** — Identification and maintenance of confidential information
- **Topics:** Data classification, confidential data handling, information labeling, retention requirements

**C1.2** — Disposal of confidential information
- **Topics:** Secure deletion, data destruction, media sanitization

### Additional Criteria — Processing Integrity

**PI1.1-PI1.5** — Processing integrity controls
- **Topics:** Data accuracy, data completeness, input validation, processing accuracy, data storage, data integrity

### Additional Criteria — Privacy

**P1-P8** — Privacy criteria
- **Topics:** Privacy notice, consent, data collection, use limitation, retention, disposal, data subject access, correction, third-party disclosure, breach notification, data quality, complaint handling
