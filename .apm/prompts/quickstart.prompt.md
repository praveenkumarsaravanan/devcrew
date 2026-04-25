---
name: quickstart
description: Orientation guide — maps common tasks to the right skill or prompt
---

# Quickstart

Welcome to devcrew. Describe what you want to do and the system routes to the right skill, right-sizes the workflow, and brings in the right agents automatically.

## Just Describe Your Task

You don't need to pick a workflow. `team-workflow` accepts any task and right-sizes itself:

| You say... | System classifies as | Phases that run |
|---|---|---|
| "Fix the null pointer in login" | Quick fix | Detect → Implement → Lightweight review |
| "Add validation to the booking form" | Standard change | Detect → Light requirements → Implement → Review → Tests |
| "Build a notification service" | Full feature | Detect → Requirements → Architecture → Implement → Review → Test strategy → Tests |

You confirm the classification at the start and can override it at any time ("run the full workflow" or "skip to implementation").

## Project Lifecycle

Start here when setting up or onboarding a project:

| I want to... | Use this | Type |
|---|---|---|
| Scaffold a new project from scratch | `/new-project` | Prompt |
| Set up project standards and governance | `/constitution` | Prompt |
| Migrate a legacy codebase to AI-native dev | `/legacy-migrate` | Prompt |
| Decompose a spec into tracker tasks | `/spec-to-issues` | Prompt |
| Create a team standards package | `/new-team-package` | Prompt |

## Specialized Skills

For tasks that have a dedicated skill, use it directly instead of `team-workflow`:

| I want to... | Use this | Type |
|---|---|---|
| Review a pull request | `code-review` | Skill |
| Write tests for existing code | `testing` | Skill |
| Debug an error in dev/staging | `debugging` | Skill |
| Design an API | `api-design` | Skill |
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
| Check if a release is ready | `/release-readiness` | Prompt |
| Design monitoring and alerts | `/monitoring-plan` | Prompt |
| Triage a production incident | `/incident-response` | Prompt |
| Audit dependencies | `/dependency-audit` | Prompt |
| Write an ADR | `/adr` | Prompt |
| Review a system design | `/design-review` | Prompt |

## How It Works

**Skills** activate automatically when you describe a task:

- "Fix the login bug" → `team-workflow` (quick fix)
- "Build a new search feature" → `team-workflow` (full feature)
- "Review this PR" → `code-review` (standalone)
- "Write tests for the user service" → `testing` (standalone)

**Prompts** are invoked via slash commands (Cmd+/ in Cursor):

- `/new-project` — scaffold a new project with DevCrew wired in
- `/constitution` — set up project standards and persistent context
- `/legacy-migrate` — onboard a legacy codebase
- `/spec-to-issues` — decompose a spec into tracker tasks
- `/new-team-package` — scaffold a team standards package
- `/devops-plan` — deployment planning
- `/release-readiness` — go/no-go checklist
- `/monitoring-plan` — SLOs, alerts, and runbooks

**Agents** are role-based personas dispatched automatically by skills. You rarely invoke them directly.

## Workflow Quick Reference

### New project (full lifecycle)

```
/new-project → /constitution → team-workflow → commit-message → pull-request
```

### Any task (system right-sizes automatically)

```
branch-creation → team-workflow → commit-message → pull-request
```

`team-workflow` detects the discipline and task size, then runs only the phases that add value.

### Post-merge operations (human-initiated)

```
pull-request (merged) → /devops-plan → /release-readiness → git-release-tag → /monitoring-plan
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
| `frontend-reviewer` | Frontend code review (accessibility, performance, design system) |
| `qa-lead` | Test strategy design and quality go/no-go decisions |
| `test-engineer` | Test code implementation from test plans |
| `devops-engineer` | CI/CD, deployment, and infrastructure-as-code |
| `release-manager` | Release coordination, rollback plans, change management |
| `sre` | Observability, SLOs, alerting, customer impact assessment |
