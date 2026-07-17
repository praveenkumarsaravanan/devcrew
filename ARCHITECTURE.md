# Why DevCrew

## The Problem

AI coding assistants are powerful, but using them on real projects today feels like handing a contractor a toolbox and saying "build me a house." They have capability, but no process, no standards, no memory of what you told them yesterday, and no awareness of the team around them.

Most teams hit the same walls:

**Every session starts from zero.** The agent doesn't know your project uses Jira, deploys to Kubernetes, follows Java Spring conventions, or that you decided last month to use event sourcing. You re-explain context every time.

**No quality process.** The agent writes code, but nobody reviews it. There's no requirements phase, no architecture check, no test strategy. The developer becomes both the implementer and the entire QA department, which defeats the purpose of delegation.

**No consistency across the team.** One developer gets the agent to follow coding standards by pasting rules into chat. Another developer's agent produces completely different patterns. Standards exist in people's heads, not in the agent's context.

**No path from prototype to production.** Getting an agent to write a function is easy. Getting it to safely build a feature — with proper error handling, security checks, test coverage, and a reviewable PR — requires manual orchestration that varies every time.

**Legacy codebases are left behind.** Most teams have existing projects that predate AI tooling. There's no structured way to bring those projects into an AI-native workflow without starting over.

## What DevCrew Is

DevCrew is an AI engineering team packaged as a single installable dependency. It gives your AI assistant the roles, processes, standards, and memory that a real engineering team provides — distributed via [Microsoft APM](https://microsoft.github.io/apm/) and usable across Cursor, GitHub Copilot, and Claude Code.

Instead of one general-purpose assistant, you get specialized agents that collaborate through DevCrew Engineering Flow:

| Role | What it does |
|------|-------------|
| Council Chair | Explains classification, council routing, trade-offs, risks, checkpoints, and next steps |
| Product Analyst | Clarifies requirements, defines acceptance criteria, identifies edge cases |
| Architect | Evaluates design trade-offs, selects patterns, ensures scalability |
| Senior Developer | Guides implementation, catches anti-patterns, validates test coverage |
| Junior Developer | Writes the code following codebase conventions |
| Backend Reviewer | Reviews for security, performance, and correctness |
| TypeScript Node Reviewer | Reviews Node APIs, workers, jobs, runtime validation, async safety, logging, outbound calls, and idempotency |
| AWS Platform Reviewer | Reviews AWS IAM, encryption, S3 exposure, event failure handling, observability, cost, quotas, and deployment safety |
| Infrastructure Reviewer | Reviews IaC and image builds for state safety, plan evidence, secrets, scans, environment parity, and rollback |
| Data Platform Reviewer | Reviews ingestion, mapping, validation, replay, reconciliation, data quality, and feed operations |
| Interoperability Reviewer | Reviews external and cross-team contracts for compatibility, versioning, deprecation, consumer migration, and contract tests |
| Regulated Data Reviewer | Reviews sensitive data classification, minimization, redaction, synthetic fixtures, audit events, retention, and access controls |
| Release Evidence Reviewer | Reviews evidence bundles for scope, tests, security, IaC/image, data, contracts, rollback, monitoring, approvals, and go/no-go readiness |
| Frontend Reviewer | Reviews for accessibility, UX consistency, and design system adherence |
| QA Lead | Designs test strategy, validates coverage, makes quality go/no-go |
| Test Engineer | Implements the test plan — unit, integration, e2e |
| DevOps Engineer | Plans CI/CD, deployment strategy, infrastructure |
| Release Manager | Manages release readiness, rollback plans, change management |
| SRE | Defines SLOs, alerting, runbooks, and assesses customer impact |

These agents don't run independently. They're orchestrated by **DevCrew Engineering Flow** (internal skill id: `team-workflow`) — sizing the task, activating only the phases and councils that add value, and enforcing quality gates between each handoff.

## Why It's Built This Way

### Everything is prose, nothing is code

Every primitive in DevCrew — agents, skills, instructions, prompts, hooks — is a Markdown file. There's no runtime, no framework, no compiled binary. The AI reads the Markdown and follows the instructions. This design choice has three consequences:

1. **Any developer can read and modify the rules.** You don't need to learn an SDK or DSL. Open the file, edit the text, push.
2. **The AI understands everything natively.** Markdown is the language models' native format. No serialization layer, no abstraction leaks.
3. **It works across IDEs.** APM compiles the same `.apm/` source directory into the right format for Cursor, Copilot, and Claude Code. One source, three targets.

### Engineering Flow right-sizes itself

Most tasks don't need a full development lifecycle. A null pointer fix shouldn't go through architecture review. A typo fix shouldn't require a test strategy.

DevCrew's Phase 0 assesses every task and classifies it as a **quick fix**, **standard change**, or **full feature**. It also assigns risk and council depth, then activates only the phases and councils that add value:

| Classification | What runs |
|---------------|-----------|
| Quick fix | Detect → Implement → Lightweight review |
| Standard change | Detect → Light requirements → Implement → Review → Tests |
| Full feature | Detect → Requirements → Architecture → Implement → Review → Test strategy → Tests |

Council depth keeps deliberation proportional:

| Council depth | What it means |
|---------------|---------------|
| Light | One-line Chair note for quick fixes |
| Standard | Concise Council Brief and compact decision notes |
| Deep | Options, trade-off matrix, recommendation, and user checkpoint before implementation |

The developer confirms the classification and can override it at any point. This means the process never gets in the way of small tasks, but full features and high-risk decisions get the rigor they need.

### Subagent isolation prevents self-agreement

When a single AI session writes code and then reviews it, it tends to approve its own work — the same context that produced the code biases the review. DevCrew solves this by spawning separate subagents for architecture (Phase 2), code review (Phase 4), and testing (Phase 5). Each subagent receives only the structured handoff artifact from the previous phase, not the full conversation history.

The review phases are explicitly **adversarial** — they assume the code has defects and actively look for them. Critical findings automatically loop back to implementation without manual intervention.

### Ask once, remember forever

DevCrew introduces two persistent files at the project root:

**`.project-context.md`** stores platform configuration — which task tracker (Jira, GitHub Issues, Linear), which execution mode (local subagents, background agents, async delegation), which git platform, which tech stack. This is detected once during Phase 0 and persisted. Every subsequent session loads the file instead of re-asking.

**`.memory.md`** stores accumulated learnings — architecture decisions, patterns that worked, anti-patterns discovered during review, test strategies that provided good coverage. After each workflow completion, the system captures learnings and appends them. The next session loads this memory, so the agent builds on prior knowledge instead of starting from zero.

Memory uses a **three-tier architecture** to stay manageable:

| Tier | File | Purpose | Size budget |
|------|------|---------|-------------|
| 1 | `.memory.md` | Active working memory — recent, high-value | ~150 lines |
| 2 | `.memory/<domain>.md` | Domain overflow — older entries rotated here | ~300 lines per domain |
| 3 | `.memory/archive/<quarter>.md` | Quarterly archive — stale entries preserved | Unlimited |

This keeps the active context concise while preserving all historical knowledge.

### Governance scales with risk

Not every code change needs the same level of human oversight. DevCrew classifies changes by risk:

| Risk | Examples | Agent autonomy |
|------|----------|---------------|
| Low | Docs, tests, linting, config formatting | Full autonomy — implement and self-review |
| Medium | Business logic, API endpoints, state management | Agent implements, human reviews PR |
| High | Auth, encryption, PII, payments, data deletion | Agent proposes, human approves each step |

This prevents both extremes: the agent isn't blocked on trivial tasks, and it can't autonomously modify authentication logic.

### Three tiers of distribution

DevCrew uses a layered package model so standards compose without conflict:

| Tier | Scope | Example |
|------|-------|---------|
| **Tier 1: DevCrew** | Universal engineering standards | Code review process, commit conventions, workflow phases |
| **Tier 2: Team package** | Team/org-specific standards | Java Spring conventions, React testing patterns, domain-specific agents |
| **Tier 3: Project** | Project-specific config and memory | `.project-context.md`, `.memory.md`, project-level overrides |

Tier 2 packages can live as folders inside the DevCrew monorepo (`teams/<team-name>/`) or as separate repositories. A consumer project declares both tiers as APM dependencies, and lower tiers override higher ones on collision. This means a team can customize DevCrew's defaults without forking it.

### Legacy projects aren't second-class

Most engineering organizations don't get to start fresh. They have existing codebases — some with tests, some without; some with CI, some without; some with documentation, some with folklore.

DevCrew includes a dedicated migration path:

1. **`/legacy-migrate`** runs a structured assessment: scans the codebase, identifies what's present and what's missing, produces a gap analysis.
2. **`legacy-assessment`** generates a phased migration plan (M0 through M3) that progressively adds AI-native capabilities without requiring a rewrite.
3. **`migration-standards`** provides softer enforcement during the transition — standards that would be errors in a new project are downgraded to warnings during migration, while security rules are always enforced.

This makes it practical to bring real projects into the system, not just greenfield demos.

## What's In the Box

### 30 Skills

Skills are the core building blocks — structured instructions that the AI follows to perform specific tasks:

| Skill | Purpose |
|-------|---------|
| `team-workflow` | Internal skill id for DevCrew Engineering Flow; orchestrates the full lifecycle with scope-adaptive phases |
| `project-detection` | Classifies projects and detects platform configuration |
| `memory-management` | Manages persistent context and tiered memory |
| `project-bootstrap` | Scaffolds new projects with stack-specific starters |
| `legacy-assessment` | Assesses codebases and generates migration plans |
| `spec-templates` | Structured specification templates for requirements |
| `team-package-management` | Creates and manages team-level APM packages |
| `code-review` | Structured review with severity levels and checklists |
| `testing` | Writes tests matching project conventions |
| `debugging` | Systematic error investigation with root cause analysis |
| `api-design` | REST/gRPC design guidance and validation |
| `interoperability-contracts` | OpenAPI, AsyncAPI, webhook, event, protobuf, GraphQL, SDK, and file/feed contract compatibility guidance |
| `regulated-data-handling` | Sensitive and regulated data classification, redaction, synthetic test data, audit, and retention guidance |
| `commit-message` | Commit messages matching org conventions |
| `branch-creation` | Branch naming with ticket traceability |
| `pull-request` | PR creation with ticket validation and discrepancy detection |
| `documentation` | READMs, guides, runbooks, ADRs |
| `git-release-tag` | Versioned releases with changelog generation |
| `apm-authoring` | Create and maintain APM artifacts |
| `java-standards` | Java/Spring Boot coding standards and security baseline |
| `typescript-node-standards` | TypeScript/Node backend standards for APIs, workers, jobs, runtime validation, logging, outbound calls, and idempotency |
| `react-standards` | React/TypeScript coding standards and security baseline |
| `aws-application-development` | AWS application standards for IAM, KMS/encryption, S3, event-driven failure handling, observability, cost, quotas, and safe IaC |
| `infrastructure-as-code` | IaC standards for Terraform/OpenTofu, CDK, CloudFormation, Pulumi, Helm, Kubernetes, remote state, plan review, drift, and rollback |
| `image-build` | Container and AMI build standards for scanning, baked-secret prevention, provenance, and immutable promotion |
| `data-ingestion` | Data feed standards for source contracts, landing, validation, quarantine, idempotency, replay, reconciliation, and runbooks |
| `data-mapping-validation` | Data mapping standards for transform rules, schema validation, golden-file tests, and quality reports |
| `operational-feed-runbook` | Operational feed runbook standards for alerts, diagnosis, replay/backfill, reconciliation, and escalation |
| `release-evidence` | Release evidence bundles for scope, tests, security, IaC/image, data, contracts, rollback, monitoring, and approvals |
| `eval` | Guidance for creating and running eval scenarios after APM primitive changes |

### 19 Agents

Each agent has a defined persona, expertise area, and interaction style.

### 24 Prompts

Entry points for specific workflows — `/engineering-flow`, `/convene-council`, `/new-project`, `/constitution`, `/legacy-migrate`, `/spec-to-issues`, `/new-team-package`, plus operational prompts for DevOps, release evidence, release readiness, monitoring, incident response, architecture decisions, AWS architecture review, IaC review, data ingestion design, mapping review, feed runbooks, data quality planning, contract review, design review, and dependency audit.

### 9 Instructions

Always-on rules that apply to every interaction: coding standards, security baseline, TypeScript/Node baseline, AWS baseline, infrastructure baseline, data platform baseline, regulated data baseline, governance, and migration standards.

### 1 Hook

Edit guards that run lint checks on file edits and security guards on write operations.

### 4 Scripts

Bootstrap and lifecycle automation: `setup.sh` (environment validation), `init-context.sh` (interactive project context creation), `init-memory.sh` (memory scaffolding), `post-install.sh` (workaround for APM's missing Cursor prompt deployment).

## How a Developer Uses It

### New project

```
/new-project
```

The agent walks through project setup: collects metadata, generates `.project-context.md` and `.memory.md`, initializes git, configures APM dependencies, scaffolds stack-specific files, and runs `apm install`. By the end, the project has agents, skills, standards, and memory ready to go.

### Existing project

```
/legacy-migrate
```

The agent assesses what's there, identifies gaps, and produces a phased plan to add AI-native capabilities incrementally.

### Day-to-day development

Just describe what you want to build. The system classifies, orchestrates, implements, reviews, and tests — pausing at each checkpoint for your confirmation. It remembers what it learned and loads that context next time.

```
"/engineering-flow Build a notification service that sends emails when orders ship"
```

Phase 0 detects it's a full feature, loads project context and memory, opens with a Council Brief, and runs the complete lifecycle with the right agents for your stack.

For planning-only deliberation:

```
/convene-council Compare options for retry handling in the notification worker
```

This produces options, trade-offs, a recommendation, risks, and next steps without implementing changes unless you explicitly proceed.

### What it doesn't do

DevCrew doesn't replace human judgment on high-risk decisions. It doesn't automatically deploy to production. It doesn't push code without your approval. It doesn't run post-merge activities (DevOps, release, monitoring) unless you explicitly invoke them. The human is always in control of the irreversible actions.

## Design Principles

DevCrew follows the **PROSE** specification for AI-native development:

| Principle | How DevCrew applies it |
|-----------|----------------------|
| **Progressive Disclosure** | Workflow right-sizes itself. Quick fixes get minimal process. Full features get full rigor. Memory loads on-demand. |
| **Reduced Scope** | Each agent has a single responsibility. Each skill does one thing. Subagents get only the handoff artifact they need. |
| **Orchestrated Composition** | DevCrew Engineering Flow (`team-workflow`) composes agents, skills, councils, and phases into a coherent process. No agent acts in isolation. |
| **Safety Boundaries** | Governance instruction classifies risk. High-risk changes require human approval at each step. Security rules are always enforced. |
| **Explicit Hierarchy** | Three-tier distribution (DevCrew → Team → Project). Lower tiers override higher ones. Project memory is project-scoped. |
