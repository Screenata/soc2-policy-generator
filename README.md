# Compliance Skills

A collection of agent skills for generating compliance policy documents.

## Available Skills

| Skill | Description | Status |
|-------|-------------|--------|
| [soc2-policy-generator](./soc2-policy-generator/) | Generate SOC 2 Type I/II policy documents | ✅ Ready |
| iso27001-policy-generator | Generate ISO 27001 policy documents | 🔜 Planned |
| hipaa-policy-generator | Generate HIPAA policy documents | 🔜 Planned |
| compliance-mapper | Map controls across frameworks | 🔜 Planned |

## Usage

Each skill folder can be used independently with any agent that supports the [Agent Skills](https://agentskills.io) format.

### SOC 2 Policy Generator

Generates tailored SOC 2 policies based on company context. Includes:
- 17 policy templates covering all Trust Services Criteria
- Evidence requirements with auditor sufficiency criteria
- Company size-appropriate controls
- Industry-specific variations (Healthcare, Fintech, etc.)

## Structure

```
compliance-skills/
├── README.md
├── soc2-policy-generator/
│   ├── SKILL.md
│   ├── references/
│   │   └── policies.md
│   └── assets/
│       └── policy-template.md
├── iso27001-policy-generator/     # Future
├── hipaa-policy-generator/        # Future
└── compliance-mapper/             # Future
```

## License

MIT

## About

Created by [Screenata](https://screenata.com) - Automated SOC 2 evidence collection.
