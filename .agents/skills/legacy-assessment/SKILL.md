---
name: legacy-assessment
description: >
  Assesses existing codebases for migration to AI-native development with DevCrew.
  Produces a gap analysis and phased migration plan. Use when the user asks to
  migrate, onboard, or assess a legacy codebase.
---

# Legacy Assessment

## Trigger

Activate this skill when:

- The user asks to "migrate," "onboard," "assess," or "evaluate" an existing codebase for AI-native development.
- The `/legacy-migrate` prompt invokes this skill.

Do NOT activate for:

- New projects — use `project-bootstrap` instead.
- Projects already using DevCrew — use `team-workflow` directly.

## Workflow

### Step 1: Classify the Codebase

Run `project-detection` to determine:
- Discipline (backend / frontend / fullstack / infrastructure)
- Stack (language, framework, database)
- Platform configuration (tracker, execution mode, git platform)

### Step 2: Assess Current State

Scan the codebase across eight dimensions. For each, assign a maturity level (None / Basic / Moderate / Strong):

| Dimension | What to check | Signals |
|-----------|--------------|---------|
| **Test coverage** | Test framework present? Tests exist? Coverage report available? | Test directories, test config files, CI test steps |
| **Linting & formatting** | Linter configured? Formatter configured? Pre-commit hooks? | `.eslintrc`, `.prettierrc`, `checkstyle.xml`, `.pre-commit-config.yaml` |
| **Security posture** | Secret scanning? Dependency audit? SAST tools? | `.gitleaks.toml`, `npm audit`, Snyk/Dependabot config, OWASP checks |
| **CI/CD pipeline** | Build pipeline exists? Automated tests in CI? Deployment automation? | `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, `Dockerfile` |
| **Infrastructure as Code** | IaC present? Remote state/locking? Plan review? Drift detection? | `*.tf`, `cdk.json`, CloudFormation, Pulumi, Helm, backend config |
| **Image build safety** | Images/AMIs built reproducibly? Scanned? Secrets avoided? | `Dockerfile`, `Containerfile`, Packer templates, image scan steps |
| **Documentation** | README exists? API docs? Architecture docs? | `README.md`, `docs/`, OpenAPI specs, ADRs |
| **Standards compliance** | Coding standards defined? Consistent patterns? | Style guides, `.editorconfig`, consistent naming, architecture patterns |

### Step 3: Produce Gap Analysis

For each dimension, compare the current state against DevCrew's target state:

```
## Gap Analysis

| Dimension | Current State | Target State | Gap | Priority |
|-----------|--------------|-------------|-----|----------|
| Test coverage | [maturity] — [details] | Strong — 80%+ coverage, CI-enforced | [gap description] | [High/Medium/Low] |
| Linting | [maturity] — [details] | Strong — ESLint/Checkstyle + Prettier + pre-commit | [gap description] | [High/Medium/Low] |
| Security | [maturity] — [details] | Strong — secret scanning + dependency audit + SAST | [gap description] | [High/Medium/Low] |
| CI/CD | [maturity] — [details] | Strong — automated build, test, deploy pipeline | [gap description] | [High/Medium/Low] |
| Infrastructure as Code | [maturity] — [details] | Strong — remote state/locking, plan review, drift detection, no secrets in state | [gap description] | [High/Medium/Low] |
| Image build safety | [maturity] — [details] | Strong — scanned immutable artifacts, no baked secrets, promotion evidence | [gap description] | [High/Medium/Low] |
| Documentation | [maturity] — [details] | Moderate — README + API docs + key ADRs | [gap description] | [High/Medium/Low] |
| Standards | [maturity] — [details] | Strong — coding-standards + security-baseline enforced | [gap description] | [High/Medium/Low] |
```

### Step 4: Generate Migration Plan

Use the `migration-phases.md` reference to produce a phased adoption roadmap:

- **M0 — Wire In (Day 1):** Install DevCrew via APM, run `/constitution`, enable `migration-standards` instruction
- **M1 — Safety Net (Week 1-2):** Add linting, secret scanning, basic CI pipeline, initial test coverage for critical paths, and IaC/image scan gates if infrastructure is present
- **M2 — Standards Adoption (Week 3-6):** Enforce coding-standards on new code, increase test coverage, add documentation for key flows
- **M3 — Steady State (Ongoing):** Disable `migration-standards`, enable full `coding-standards`, all new work goes through `team-workflow`

Adjust timelines based on codebase size and team capacity.

### Step 5: Offer Tracker Integration

If a task tracker is configured (from `.project-context.md` or Step 1 detection):

- Offer to create an Epic/Milestone for the migration
- Create child tickets for each migration phase with concrete action items
- Use `/spec-to-issues` for task decomposition

If no tracker, output a Markdown task list.

### Step 6: Present Report

Display the full assessment:
1. Codebase classification
2. Current state assessment (6 dimensions)
3. Gap analysis table
4. Phased migration plan with timelines
5. Recommended first actions

## Guardrails

- **Never modify production code during assessment.** This skill only reads and reports.
- **Prioritize security gaps over style gaps.** Secret scanning and dependency audit are always higher priority than linter configuration.
- **Be honest about gaps.** Do not downplay deficiencies — the migration plan depends on accurate assessment.
- **Respect existing investments.** If the project already has good CI/CD, acknowledge it rather than proposing replacement.
- **Grandfathering is OK.** Existing code doesn't need to be rewritten to match standards — the migration-standards instruction enforces "new code must comply; existing code is grandfathered until touched."

## References

- [Assessment Template](references/assessment-template.md) — Structured template for the gap analysis report
- [Migration Phases](references/migration-phases.md) — Phased adoption roadmap template with action items per phase

## See Also

- **`/legacy-migrate`** — The user-facing entry point that invokes this skill.
- **`project-detection`** — Used in Step 1 for codebase classification.
- **`migration-standards`** — The instruction that enforces gradual adoption during migration.
- **`project-bootstrap`** — For new projects (this skill is for existing ones).
- **`memory-management`** — Persists the migration status in `.project-context.md`.
