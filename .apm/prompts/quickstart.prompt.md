---
name: quickstart
description: Orientation guide — maps common tasks to the right skill or prompt
---

# Quickstart

Welcome to DevCrew. Use `/engineering-flow` when you want DevCrew to take a request through planning, implementation, review, and testing. The Council Chair opens the flow, right-sizes the work, and brings in the right agents automatically.

## Just Describe Your Task

You can invoke DevCrew Engineering Flow directly:

```text
/engineering-flow Add validation to the booking form
```

Engineering Flow accepts any build/fix/change task and right-sizes itself:

| You say... | System classifies as | Phases that run |
|---|---|---|
| "Fix the null pointer in login" | Quick fix | Detect → Implement → Lightweight review |
| "Add validation to the booking form" | Standard change | Detect → Light requirements → Implement → Review → Tests |
| "Build a notification service" | Full feature | Detect → Requirements → Architecture → Implement → Review → Test strategy → Tests |

You confirm the classification, risk, and council depth at the start. You can override at any time: "run the full workflow", "skip to implementation", or "run deep council".

Use `/convene-council` when you want planning and trade-offs only, without implementation.

## Project Lifecycle

Start here when setting up or onboarding a project:

| I want to... | Use this | Type |
|---|---|---|
| Scaffold a new project from scratch | `/new-project` | Prompt |
| Set up project standards and governance | `/constitution` | Prompt |
| Migrate a legacy codebase to AI-native dev | `/legacy-migrate` | Prompt |
| Plan options before implementation | `/convene-council` | Prompt |
| Decompose a spec into tracker tasks | `/spec-to-issues` | Prompt |
| Review a contract change | `/contract-review` | Prompt |
| Create a team standards package | `/new-team-package` | Prompt |

## Specialized Skills

For tasks that have a dedicated skill, use it directly instead of Engineering Flow:

| I want to... | Use this | Type |
|---|---|---|
| Review a pull request | `code-review` | Skill |
| Write tests for existing code | `testing` | Skill |
| Debug an error in dev/staging | `debugging` | Skill |
| Design an API | `api-design` | Skill |
| Review interoperability contracts | `interoperability-contracts` | Skill |
| Build a FHIR / HL7 API or resource | `fhir-health-interop` | Skill |
| Review FHIR conformance before merge | `/fhir-review` | Prompt |
| Fetch HL7 AI-ready IG bundle (once per IG; re-run to refresh from HL7) | `apm run fhir-ai-bundle-setup` | Script |
| Handle sensitive or regulated data | `regulated-data-handling` | Skill |
| Create a git branch | `branch-creation` | Skill |
| Commit my changes | `commit-message` | Skill |
| Open a pull request | `pull-request` | Skill |
| Write or update documentation | `documentation` | Skill |
| Tag and release a new version | `git-release-tag` | Skill |
| Create or edit APM artifacts | `apm-authoring` | Skill |
| Check Java/Spring Boot standards | `java-standards` | Skill |
| Check React/TypeScript standards | `react-standards` | Skill |
| Write a structured specification | `spec-templates` | Skill |
| Manage project context and memory | `memory-management` | Skill |
| Assess a legacy codebase for migration | `legacy-assessment` | Skill |
| Bootstrap a new project | `project-bootstrap` | Skill |
| Manage team packages | `team-package-management` | Skill |

## Post-Merge (Optional, Human-Initiated)

These are never automatic. Invoke them when you're ready:

| I want to... | Use this | Type |
|---|---|---|
| Plan a deployment strategy | `/devops-plan` | Prompt |
| Build release evidence | `/release-evidence` | Prompt |
| Check if a release is ready | `/release-readiness` | Prompt |
| Design monitoring and alerts | `/monitoring-plan` | Prompt |
| Triage a production incident | `/incident-response` | Prompt |
| Audit dependencies | `/dependency-audit` | Prompt |
| Write an ADR | `/adr` | Prompt |
| Review a system design | `/design-review` | Prompt |

## How It Works

**Skills** activate automatically when you describe a task:

- "Fix the login bug" → DevCrew Engineering Flow (quick fix)
- "Build a new search feature" → DevCrew Engineering Flow (full feature)
- "Review this PR" → `code-review` (standalone)
- "Write tests for the user service" → `testing` (standalone)

**Prompts** are invoked via slash commands (Cmd+/ in Cursor):

- `/new-project` — scaffold a new project with DevCrew wired in
- `/engineering-flow` — run the right-sized engineering lifecycle
- `/convene-council` — compare options and trade-offs before implementation
- `/constitution` — set up project standards and persistent context
- `/legacy-migrate` — onboard a legacy codebase
- `/spec-to-issues` — decompose a spec into tracker tasks
- `/new-team-package` — scaffold a team standards package
- `/contract-review` — review contract compatibility, versioning, migration, and tests
- `/fhir-review` — audit FHIR resources, profiles, and IG conformance before merge (build work → `fhir-health-interop` skill instead)
- `/devops-plan` — deployment planning
- `/release-evidence` — build or review evidence for medium/high-risk releases
- `/release-readiness` — go/no-go checklist
- `/monitoring-plan` — SLOs, alerts, and runbooks

**Agents** are role-based personas dispatched automatically by skills. You rarely invoke them directly.

## Workflow Quick Reference

### New project (full lifecycle)

```
/new-project → /constitution → /engineering-flow → commit-message → pull-request
```

### Any task (system right-sizes automatically)

```
branch-creation → /engineering-flow → commit-message → pull-request
```

DevCrew Engineering Flow detects the discipline, task size, risk, and council depth, then runs only the phases that add value. The internal skill id remains `team-workflow` for compatibility.

### Post-merge operations (human-initiated)

```
pull-request (merged) → /devops-plan → /release-evidence → /release-readiness → git-release-tag → /monitoring-plan
```

Each step is optional. The developer chooses which post-merge prompts to run.

## Human Checkpoints

Every phase pauses for your confirmation before advancing. You always control the pace:

- **Confirm** — "looks good, proceed"
- **Skip** — "skip to implementation"
- **Repeat** — "redo the architecture phase"
- **Stop** — "that's enough" or "stop here"
- **Override size** — "run the full workflow" or "just do a quick fix"

## Agents Reference

| Agent | Role |
|---|---|
| `product-analyst` | Requirements, acceptance criteria, edge cases |
| `architect` | System design, technology selection, trade-off analysis |
| `junior-developer` | Implementation following codebase patterns |
| `senior-developer` | Scalability, performance, rollout safety review |
| `backend-reviewer` | Backend code review (security, performance, quality) |
| `aws-platform-reviewer` | AWS security, reliability, observability, cost, quotas, and deployment safety |
| `infrastructure-reviewer` | IaC and image-build review for state, plans, scans, secrets, parity, and rollback |
| `data-platform-reviewer` | Data ingestion, mapping, replay, reconciliation, quality, and feed runbook review |
| `interoperability-reviewer` | External and cross-team contract compatibility, versioning, migration, and contract test review |
| `regulated-data-reviewer` | Sensitive data classification, redaction, synthetic data, audit, retention, and access control review |
| `release-evidence-reviewer` | Release evidence completeness, rollback, monitoring, waiver, and readiness review |
| `frontend-reviewer` | Frontend code review (accessibility, performance, design system) |
| `qa-lead` | Test strategy design and quality go/no-go decisions |
| `test-engineer` | Test code implementation from test plans |
| `devops-engineer` | CI/CD, deployment, and infrastructure-as-code |
| `release-manager` | Release coordination, rollback plans, change management |
| `sre` | Observability, SLOs, alerting, customer impact assessment |
