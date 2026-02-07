# Change Management Scanning Patterns (CC8.1)

For policy: **Change Management** (`change-management`)
See [shared.md](shared.md) for evidence formatting and value usage guidelines.

## Basic Detection

**CI/CD Pipeline** - Check for pipeline configuration files:
```
Glob: .github/workflows/*.yml, .gitlab-ci.yml, Jenkinsfile, azure-pipelines.yml, .circleci/config.yml, bitbucket-pipelines.yml, .travis.yml
```
File presence alone indicates CI/CD is configured.

## Deep Scanning (Value Extraction)

### Branch Protection Configuration

Extract required reviewer count, required status checks, and enforcement rules.

**Find files:**
```
Glob: .github/**/*.{yml,yaml}, **/*.tf, **/terraform/**/*.*, **/*branch*protect*.*, **/CODEOWNERS, .gitlab/**/*.*
```

**Extract values:**
```
Grep: required_approving_review_count\s*=\s*(\d+)  → required reviewers (Terraform)
Grep: required_status_checks\s*\{[^}]*contexts\s*=\s*\[([^\]]+)\]  → required check names (multiline)
Grep: enforce_admins\s*=\s*(true)  → admin enforcement
Grep: dismiss_stale_reviews\s*=\s*(true)  → stale review dismissal
Grep: require_code_owner_reviews\s*=\s*(true)  → code owner review required
Grep: allow_force_pushes\s*=\s*(false)  → force push disabled
Grep: approvals_before_merge:\s*(\d+)  → GitLab required approvals
Grep: \*\s+@(\S+)  → CODEOWNERS entries
```

**Use in policy text:**
- Instead of: "Changes to the main branch require code review"
- Write: "The **main** branch requires **2 approving reviews**, **stale reviews are dismissed** on new commits, **code owner review is required** (see `CODEOWNERS`), and **force pushes are disabled** (see `infrastructure/github.tf:45-60`). Required status checks: **ci/test, ci/lint, security/snyk**."

### CI/CD Pipeline Stages and Security Scanning

Extract pipeline stage names, test/lint tools, and security scanning tool configuration.

**Find files:**
```
Glob: .github/workflows/*.{yml,yaml}, .gitlab-ci.yml, Jenkinsfile, azure-pipelines.yml, .circleci/config.yml, .github/dependabot.yml, .snyk, .trivyignore
```

**Extract values:**
```
Grep: (?:npm\s+(?:test|run\s+test)|pytest|go\s+test|cargo\s+test|jest|mocha|vitest)  → test tool
Grep: (?:npm\s+run\s+lint|eslint|flake8|golangci-lint|rubocop|clippy)  → lint tool
Grep: snyk/actions/(?:node|python|go|docker)@(\S+)  → Snyk action version
Grep: snyk\s+(?:test|monitor|container\s+test)  → Snyk CLI command
Grep: --severity-threshold=(\w+)  → Snyk severity threshold
Grep: package-ecosystem:\s*["']?(\w+)["']?  → Dependabot ecosystem
Grep: interval:\s*["']?(\w+)["']?  → Dependabot check interval
Grep: github/codeql-action/init  → CodeQL presence
Grep: aquasecurity/trivy-action  → Trivy presence
Grep: severity:\s*['"]?([A-Z,]+)['"]?  → Trivy severity filter
Grep: npm\s+audit  → npm audit in CI
Grep: environment:\s*(?:name:\s*)?['"]?(\w+)['"]?  → deployment environment names
```

**Use in policy text:**
- Instead of: "Changes are tested through a CI/CD pipeline"
- Write: "All changes go through a **GitHub Actions CI/CD pipeline** with stages: **lint** (ESLint), **test** (Jest), **security scan** (Snyk with **high severity threshold**), **build**, and **deploy** (see `.github/workflows/ci.yml`). **Dependabot** monitors **npm** and **docker** ecosystems **weekly** (see `.github/dependabot.yml`)."

## Example Evidence Table

| Control | Extracted Value | File | Line | Raw Evidence |
|---------|----------------|------|------|-------------|
| Required reviewers | **2** | infrastructure/github.tf | 48 | `required_approving_review_count = 2` |
| Required checks | **ci/test, ci/lint, security/snyk** | infrastructure/github.tf | 52 | `contexts = ["ci/test", "ci/lint", "security/snyk"]` |
| CI/CD pipeline | **GitHub Actions** | .github/workflows/ci.yml | - | Pipeline with lint, test, scan, build, deploy stages |
| Security scanning | **Snyk (high threshold), Trivy (CRITICAL,HIGH)** | .github/workflows/ci.yml | 45, 62 | `--severity-threshold=high` |
| Dependabot | **npm + docker, weekly** | .github/dependabot.yml | - | `interval: weekly` |

## Cloud Scanning Cross-Reference

For live infrastructure evidence related to change management:
- AWS: CodePipeline (if used) -- see [aws.md](aws.md#change-management-cc81)
- Note: Change management evidence primarily comes from codebase scanning (CI/CD, branch protection). Cloud scanning adds supplementary deployment pipeline evidence.
