# DevCrew APM — Executive Summary & Index

**Package:** `devcrew` (see `apm.yml` for current version)  
**Distribution:** [Microsoft APM](https://microsoft.github.io/apm/)  
**Targets:** Cursor, GitHub Copilot, Claude Code, Codex CLI

DevCrew is a distributable AI engineering team — skills, agents, rules, workflows, hooks, and MCP integrations — compiled from a single `.apm/` source directory. One source of truth simulates how a real engineering organization works: classify risk, right-size process, route to specialists, enforce standards, and gate releases.

**Doc rule:** [documentation-layering.md](./documentation-layering.md) — write once, link often; this file is the **catalog**, not the how-to for every topic.

---

## At a Glance

| Primitive | Count | Role |
|-----------|-------|------|
| **Skills** | 32 | Repeatable procedures the AI follows |
| **Agents** | 19 | Specialist personas (reviewers, implementers, coordinators) |
| **Instructions** | 10 | Always-on rules injected by file type/path |
| **Prompts** | 27 | Slash commands / workflow entry points |
| **Hooks** | 1 file, 3 guards | Automated checks on edit and tool use |
| **MCP servers** | 3 | GitHub, Atlassian, Playwright |
| **Spec templates** | 10 | Structured `.spec.md` formats |
| **Eval scenarios** | 50 | Behavioral regression tests |
| **APM scripts** | 11 | Setup, install, release, memory, context, triage, FHIR AI bundles, verify |

---

## The Flagship Workflow

**Skill:** `team-workflow`  
**Prompt:** `/engineering-flow`

Together these implement **DevCrew Engineering Flow** — a right-sized lifecycle from quick fix through standard change to full feature:

- **Phase 0:** Classify task size, risk, and discipline
- **Phases 1–5:** Requirements, architecture, implementation, adversarial review, testing (activated only when they add value)
- **Council mode:** `council-chair` agent + `/convene-council` prompt for planning-only trade-off review

See also: [engineering-flow.md](./engineering-flow.md), [council-model.md](./council-model.md)

### Production Issue Triage

| Piece | Name | Purpose |
|-------|------|---------|
| Skill | `triage` | Mirror+worktree, artifact-first reads, hypothesis card |
| Prompt | `/triage` | First-pass production-issue triage (skill-only deploy if name collides) |
| Prompt | `/postmortem` | After fix: verify, score hypothesis, record confirmed cause |
| Script | `triage-setup` | Per-project triage workspace scaffolding |
| Eval | `tri-001-data-lifecycle` | Root-cause discipline (`triage-judge`) |

**User guide (routing vs incident response vs debugging):** [triage.md](./triage.md)

### FHIR / HL7 Health Interoperability

| Piece | Name | Purpose |
|-------|------|---------|
| Skill | `fhir-health-interop` | FHIR REST, profiles, SMART on FHIR; Da Vinci CRD/DTR/PAS stack on R4 + US Core STU9 |
| Prompt | `/fhir-review` | Focused IG conformance review outside Engineering Flow |
| Script | `fhir-ai-bundle-setup` | One-time fetch into `.fhir/ai-bundles/<ig>/`; re-run only to refresh from HL7 |
| Reference | `hl7-ai-packages.md` | HL7 artifact catalog and technical checklist |

**User guide (routing, setup, refresh):** [fhir-health-interop.md](./fhir-health-interop.md)

---

## Skills Index (32)

### Core Workflow & Delivery

| Skill | Purpose |
|-------|---------|
| `team-workflow` | Main Engineering Flow lifecycle |
| `project-detection` | Classify backend / frontend / fullstack / infra / data |
| `memory-management` | `.project-context.md` + `.memory.md` persistence |
| `spec-templates` | Generate discipline-specific specs |
| `branch-creation` | Branch naming conventions |
| `commit-message` | Conventional commit format |
| `pull-request` | PR creation with ticket validation |
| `git-release-tag` | Version bump, tag, GitHub release |
| `code-review` | Structured review with severity levels |
| `testing` | Add tests outside full workflow |
| `debugging` | Systematic error investigation (dev/staging) |
| `triage` | Production-issue first pass — evidence-backed hypothesis card |
| `documentation` | READMEs, guides, runbooks, ADRs |
| `eval` | Run the evaluation suite before release |

### Project & Team Setup

| Skill | Purpose |
|-------|---------|
| `project-bootstrap` | Scaffold new project with DevCrew wired in |
| `legacy-assessment` | Gap analysis + migration plan for existing codebases |
| `team-package-management` | Tier 2 team APM packages (org standards) |
| `apm-authoring` | Create and maintain APM artifacts |

### Discipline Standards

| Skill | Purpose |
|-------|---------|
| `java-standards` | Java / Spring Boot standards |
| `typescript-node-standards` | Node / API / worker / queue standards |
| `react-standards` | React / frontend standards |
| `api-design` | REST / gRPC / OpenAPI design |

### Platform & Infrastructure

| Skill | Purpose |
|-------|---------|
| `aws-application-development` | IAM, encryption, S3, events, observability, cost |
| `infrastructure-as-code` | Terraform, CDK, CloudFormation, K8s, state, drift |
| `image-build` | Container / AMI builds, scanning, no baked secrets |

### Data Platform

| Skill | Purpose |
|-------|---------|
| `data-ingestion` | Feeds, contracts, validation, replay, reconciliation |
| `data-mapping-validation` | Mappings, golden files, quality reports |
| `operational-feed-runbook` | Production feed operations |

### Contracts, Compliance & Release

| Skill | Purpose |
|-------|---------|
| `interoperability-contracts` | OpenAPI, AsyncAPI, webhooks, events, protobuf, SDKs, FHIR exchange contracts |
| `fhir-health-interop` | FHIR / HL7 IGs, HL7 AI bundles (`ai.zip`), NPM validation, SMART on FHIR |
| `regulated-data-handling` | PII / PHI classification, redaction, audit, retention |
| `release-evidence` | Evidence bundles for medium / high-risk releases |

**Source:** `.apm/skills/<name>/SKILL.md`

---

## Agents Index (19)

### Review Council (adversarial, isolated subagents)

| Agent | Focus |
|-------|-------|
| `backend-reviewer` | Backend quality, security, performance |
| `typescript-node-reviewer` | Node runtime safety, async, idempotency |
| `frontend-reviewer` | Accessibility, performance, design system |
| `aws-platform-reviewer` | AWS security, reliability, cost |
| `infrastructure-reviewer` | IaC, image builds, state, rollback |
| `data-platform-reviewer` | Ingestion, mapping, replay, data quality |
| `interoperability-reviewer` | Contract compatibility, versioning |
| `regulated-data-reviewer` | Sensitive data, audit, retention |
| `release-evidence-reviewer` | Release readiness evidence |

### Implementation & Leadership

| Agent | Focus |
|-------|-------|
| `product-analyst` | Requirements, acceptance criteria |
| `architect` | System design, trade-offs |
| `senior-developer` | Scalability, rollout, test strategy |
| `junior-developer` | Clean implementation from spec |
| `test-engineer` | Test code from QA plan |
| `qa-lead` | Test strategy, quality go/no-go |
| `devops-engineer` | CI/CD, deployment, IaC |
| `release-manager` | Release readiness, rollback |
| `sre` | SLOs, alerting, customer impact |
| `council-chair` | Engineering Flow coordination and routing |

**Source:** `.apm/agents/<name>.agent.md`

---

## Instructions Index (10) — Always-On Rules

| Instruction | Scope |
|-------------|-------|
| `advisor-mode` | All interactions — challenge assumptions, avoid sycophancy |
| `governance` | Risk levels (low / medium / high) and agent autonomy boundaries |
| `coding-standards` | Universal principles; routes to Java / Node / React standards |
| `security-baseline` | Universal security; routes to discipline skills |
| `typescript-node-baseline` | Server-side TypeScript / Node safety |
| `aws-baseline` | AWS IaC, serverless, managed services |
| `infrastructure-baseline` | Terraform, Dockerfiles, Packer, K8s |
| `data-platform-baseline` | Ingestion, mapping, replay, reconciliation |
| `regulated-data-baseline` | PII / PHI, masking, synthetic data, audit |
| `migration-standards` | Softer enforcement during legacy migration |

These compile to `AGENTS.md`, `CLAUDE.md`, and IDE-specific rule files.

**Source:** `.apm/instructions/<name>.instructions.md`

---

## Prompts Index (27) — Slash Commands

### Daily Driver

| Prompt | Command | Purpose |
|--------|---------|---------|
| `quickstart` | `/quickstart` | Map tasks to the right skill or prompt |
| `engineering-flow` | `/engineering-flow` | Main build / fix / change workflow |
| `convene-council` | `/convene-council` | Planning-only options and trade-offs |

### Project Setup

| Prompt | Purpose |
|--------|---------|
| `constitution` | Bootstrap `.project-context.md` and governance |
| `new-project` | Scaffold project with DevCrew |
| `new-team-package` | Create Tier 2 team package |
| `legacy-migrate` | Legacy codebase onboarding |
| `spec-to-issues` | Break spec into tracker issues |

### Focused Reviews (outside full flow)

| Prompt | Purpose |
|--------|---------|
| `node-service-review` | TypeScript / Node backend review |
| `aws-architecture-review` | AWS platform review |
| `iac-review` | IaC and image build review |
| `contract-review` | API / webhook / event / FHIR contract review |
| `fhir-review` | FHIR resources, profiles, CapabilityStatement, IG conformance |
| `mapping-review` | Data mapping review |
| `design-review` | Scalability, reliability, cost |

### Data Platform

| Prompt | Purpose |
|--------|---------|
| `data-ingestion-design` | Feed design (contracts, retry, replay) |
| `data-quality-plan` | Quality and reconciliation plan |
| `feed-runbook` | Operational runbook for feeds |

### Operations & Release

| Prompt | Purpose |
|--------|---------|
| `triage` | First-pass production-issue triage — hypothesis card for human review |
| `postmortem` | Close the loop after fix — score hypothesis, record confirmed cause |
| `incident-response` | Production incident severity, comms, and escalation |
| `monitoring-plan` | SLOs, alerting, runbooks |
| `devops-plan` | CI/CD and deployment strategy |
| `release-readiness` | Go / no-go checklist |
| `release-evidence` | Evidence bundle for risky releases |
| `dependency-audit` | Vulnerability and license audit |
| `adr` | Architecture Decision Record (Nygard format) |

**Source:** `.apm/prompts/<name>.prompt.md`  
**Note:** Codex does not support prompts natively — use skills or agent invocation instead. When a prompt shares a name with a skill (`triage`, `release-evidence`), post-install deploys the **skill only** to avoid duplicate `/commands` in Cursor.

---

## Hooks, MCP & Scripts

### Hooks (`edit-guards`)

| Hook | Trigger | Action |
|------|---------|--------|
| `lint-check` | After file edit (`ts` / `js` / `py` / `go` / `java`) | Check coding standards |
| `apm-eval-reminder` | After `.apm/` edit | Remind to validate and run eval |
| `security-guard` | Before write / edit tools | Block secrets in files |

**Source:** `.apm/hooks/edit-guards.json`

Codex receives a separate Bash `PreToolUse` command hook via `scripts/setup-codex-hooks.sh` (run by `apm run postinstall`).

### MCP Servers

| Server | Capability |
|--------|------------|
| `github` | Repositories, PRs, issues |
| `atlassian` | Jira, Confluence, Compass |
| `playwright` | Browser automation / E2E |

**Source:** `.mcp.json`

### APM Scripts (`apm run …`)

| Script | Purpose |
|--------|---------|
| `setup` | gh, SSH, APM, bootstrap context / memory |
| `install-global` | Compile, deploy cursor/claude/codex globally, post-install |
| `postinstall` | Cursor prompts and Codex hooks (project or `--global`) |
| `codex-hooks` | Redeploy Codex hooks only |
| `triage-setup` | Scaffold triage workspace (mirrors, runs, knowledge base) |
| `fhir-ai-bundle-setup` | Fetch HL7 LLM-ready IG bundle into `.fhir/ai-bundles/` — run once; re-run only to refresh from HL7 |
| `verify-commands` | Audit Cursor/Claude commands for skill or scope duplicates |
| `init-context` | Interactive `.project-context.md` |
| `init-memory` | Create `.memory.md` structure |
| `release` | Version bump, tag, GitHub release |

**Source:** `apm.yml` → `scripts/`

---

## Spec Templates (10)

Under `.apm/skills/spec-templates/references/`:

| Template | Use case |
|----------|----------|
| `api-endpoint.spec.md` | REST / API endpoint changes |
| `service.spec.md` | Backend service features |
| `node-service.spec.md` | TypeScript / Node services |
| `ui-component.spec.md` | Frontend components |
| `aws-infrastructure.spec.md` | AWS infrastructure changes |
| `data-ingestion.spec.md` | Data feed ingestion |
| `data-mapping.spec.md` | Field mapping and validation |
| `contract-change.spec.md` | External / cross-team contracts |
| `migration.spec.md` | Codebase migration work |
| `release-evidence.spec.md` | Release evidence bundles |

---

## Evaluation Suite (50 Scenarios)

Quality gate for the package itself. See [evals/README.md](../evals/README.md).

| Category | Examples |
|----------|----------|
| Right-sizing | Quick fix vs standard vs full feature |
| Quality gates | Security review, frontend review, missing tests |
| Governance | Risk classification accuracy |
| Memory | Context persistence across sessions |
| Advisor mode | No sycophancy, no manufactured disagreement |
| AWS / Infra | IAM, DLQ, S3, Terraform, Packer secrets |
| Data platform | Idempotency, mapping, backfill, sensitive data |
| Contracts | OpenAPI compatibility, webhook versioning |
| Regulated data | No PII in logs, synthetic fixtures, audit |
| Release evidence | High-risk bundles, IaC rollback |
| Skill output | SO-001 through SO-013 per-skill scenarios |
| Council | Chair routing brief |
| Triage | Data-lifecycle tracing, artifact-first, no red-herring root cause |

**Judges:** `evals/judges/` includes `triage-judge.md` for triage discipline scoring.

**Source:** `evals/scenarios/`

---

## Three-Tier Distribution Model

```
Tier 1: DevCrew (this package)  →  universal engineering standards
Tier 2: Team packages           →  org-specific overrides
Tier 3: Project                 →  .project-context.md, .memory.md, local .apm/
```

See also: [distributing-ai-tooling.md](../distributing-ai-tooling.md), [ARCHITECTURE.md](../ARCHITECTURE.md)

---

## IDE Coverage

| Capability | Cursor | Claude | Copilot | Codex |
|------------|--------|--------|---------|-------|
| Skills | Yes | Yes | Yes | Yes |
| Agents | Yes | Yes | Yes | Yes (TOML) |
| Instructions | Yes (rules) | Yes (rules) | Yes | Yes (via `AGENTS.md`) |
| Prompts / commands | Yes (27) | Yes | Yes | No — use skills |
| Hooks | Yes (prompt) | Yes | Partial | Yes (command) |
| MCP | Yes | Yes | Yes | Yes |

---

## Quick Reference

```sh
# Global install — compile + cursor/claude/codex + prompts + Codex hooks
apm run install-global

# Per-project install (all targets in apm.yml)
apm compile && apm install --target cursor,claude,codex && apm run postinstall

# Triage workspace (per project)
apm run triage-setup ./triage-workspace

# HL7 AI-ready FHIR bundle — see docs/fhir-health-interop.md (once per IG; re-run to refresh)
apm run fhir-ai-bundle-setup us-core

# Release new package version
apm run release -- --dry-run --ticket ISSUE-XXX
```

---

## Related Documentation

- [documentation-layering.md](./documentation-layering.md) — where to add vs remove content (repo-wide)
- [README.md](../README.md) — Quick start and contributing
- [engineering-flow.md](./engineering-flow.md) — Workflow phases and routing
- [triage.md](./triage.md) — Production triage routing
- [fhir-health-interop.md](./fhir-health-interop.md) — FHIR build vs review, IG bundle setup
- [council-model.md](./council-model.md) — Council planning model
- [data-platform-workflow.md](./data-platform-workflow.md) — Data feed workflows
- [typescript-node-aws-workflow.md](./typescript-node-aws-workflow.md) — Node + AWS workflows
- [generic-platform-support.md](./generic-platform-support.md) — Cross-cutting platform capabilities
