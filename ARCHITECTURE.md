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

Instead of one general-purpose assistant, you get eleven specialized agents that collaborate through a structured workflow:

| Role | What it does |
|------|-------------|
| Product Analyst | Clarifies requirements, defines acceptance criteria, identifies edge cases |
| Architect | Evaluates design trade-offs, selects patterns, ensures scalability |
| Senior Developer | Guides implementation, catches anti-patterns, validates test coverage |
| Junior Developer | Writes the code following codebase conventions |
| Backend Reviewer | Reviews for security, performance, and correctness |
| Frontend Reviewer | Reviews for accessibility, UX consistency, and design system adherence |
| QA Lead | Designs test strategy, validates coverage, makes quality go/no-go |
| Test Engineer | Implements the test plan — unit, integration, e2e |
| DevOps Engineer | Plans CI/CD, deployment strategy, infrastructure |
| Release Manager | Manages release readiness, rollback plans, change management |
| SRE | Defines SLOs, alerting, runbooks, and assesses customer impact |

These agents don't run independently. They're orchestrated by a **team-workflow** skill that acts as a project manager — sizing the task, activating only the phases that add value, and enforcing quality gates between each handoff.

## Why It's Built This Way

### Everything is prose, nothing is code

Every primitive in DevCrew — agents, skills, instructions, prompts, hooks — is a Markdown file. There's no runtime, no framework, no compiled binary. The AI reads the Markdown and follows the instructions. This design choice has three consequences:

1. **Any developer can read and modify the rules.** You don't need to learn an SDK or DSL. Open the file, edit the text, push.
2. **The AI understands everything natively.** Markdown is the language models' native format. No serialization layer, no abstraction leaks.
3. **It works across IDEs.** APM compiles the same `.apm/` source directory into the right format for Cursor, Copilot, and Claude Code. One source, three targets.

### The workflow right-sizes itself

Most tasks don't need a full development lifecycle. A null pointer fix shouldn't go through architecture review. A typo fix shouldn't require a test strategy.

DevCrew's Phase 0 assesses every task and classifies it as a **quick fix**, **standard change**, or **full feature**, then activates only the phases that add value:

| Classification | What runs |
|---------------|-----------|
| Quick fix | Detect → Implement → Lightweight review |
| Standard change | Detect → Light requirements → Implement → Review → Tests |
| Full feature | Detect → Requirements → Architecture → Implement → Review → Test strategy → Tests |

The developer confirms the classification and can override it at any point. This means the process never gets in the way of small tasks, but full features get the rigor they need.

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

### 19 Skills

Skills are the core building blocks — structured instructions that the AI follows to perform specific tasks:

| Skill | Purpose |
|-------|---------|
| `team-workflow` | Orchestrates the full development lifecycle with scope-adaptive phases |
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
| `commit-message` | Commit messages matching org conventions |
| `branch-creation` | Branch naming with ticket traceability |
| `pull-request` | PR creation with ticket validation and discrepancy detection |
| `documentation` | READMs, guides, runbooks, ADRs |
| `git-release-tag` | Versioned releases with changelog generation |
| `apm-authoring` | Create and maintain APM artifacts |
| `java-standards` | Java/Spring Boot coding standards and security baseline |
| `react-standards` | React/TypeScript coding standards and security baseline |

### 11 Agents

Each agent has a defined persona, expertise area, and interaction style.

### 13 Prompts

Entry points for specific workflows — `/new-project`, `/constitution`, `/legacy-migrate`, `/spec-to-issues`, `/new-team-package`, plus operational prompts for DevOps, release, monitoring, incident response, architecture decisions, design review, and dependency audit.

### 4 Instructions

Always-on rules that apply to every interaction: coding standards, security baseline, governance, and migration standards.

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
"Build a notification service that sends emails when orders ship"
```

Phase 0 detects it's a full feature, loads project context and memory, and runs the complete lifecycle with the right agents for your stack.

### What it doesn't do

DevCrew doesn't replace human judgment on high-risk decisions. It doesn't automatically deploy to production. It doesn't push code without your approval. It doesn't run post-merge activities (DevOps, release, monitoring) unless you explicitly invoke them. The human is always in control of the irreversible actions.

## Design Principles

DevCrew follows the **PROSE** specification for AI-native development:

| Principle | How DevCrew applies it |
|-----------|----------------------|
| **Progressive Disclosure** | Workflow right-sizes itself. Quick fixes get minimal process. Full features get full rigor. Memory loads on-demand. |
| **Reduced Scope** | Each agent has a single responsibility. Each skill does one thing. Subagents get only the handoff artifact they need. |
| **Orchestrated Composition** | `team-workflow` composes agents, skills, and phases into a coherent process. No agent acts in isolation. |
| **Safety Boundaries** | Governance instruction classifies risk. High-risk changes require human approval at each step. Security rules are always enforced. |
| **Explicit Hierarchy** | Three-tier distribution (DevCrew → Team → Project). Lower tiers override higher ones. Project memory is project-scoped. |
