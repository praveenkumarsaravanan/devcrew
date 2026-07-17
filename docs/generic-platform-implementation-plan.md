# DevCrew Generic Platform Implementation Plan

## Repo

Cloned to:

```text
/Users/praveenkumarsaravanan/Documents/personal-dev/devcrew
```

`gh repo clone praveenkumarsaravanan/devcrew` could not run because GitHub CLI is not authenticated in this environment. The repository was cloned with `git clone https://github.com/praveenkumarsaravanan/devcrew.git` instead.

## Objective

Expand DevCrew from a generic app-development AI team into a generic TypeScript/Node/React/AWS/platform-development AI team, while keeping the project open-source friendly and avoiding company-specific assumptions.

The implementation should support:

- A user-facing **DevCrew Engineering Flow** for any incoming requirement.
- A council/team structure inside Engineering Flow, coordinated by a visible chairperson.
- A visible Council Chair who explains plan, trade-offs, decisions, risks, and next steps.
- TypeScript/Node service development.
- React frontend/admin workflows.
- AWS application development.
- Infrastructure as Code.
- Data ingestion and mapping.
- Interoperability/API/file contracts.
- Regulated/sensitive data handling.
- Release evidence and operational readiness.

## Product Boundary

Keep these separate:

```text
devcrew
  Generic AI engineering team and Engineering Flow workflow engine.

devcrew-context
  Optional future local search/memory runtime. Not part of this implementation.

company/team-specific packages
  Any proprietary product, client, payer, or internal platform rules.
```

Do not add company names, client names, proprietary product names, or internal topology to DevCrew core.

## Phase 0: Planning Branch And Baseline

Goal:

Prepare the repo for implementation.

Branch:

```text
feat/generic-platform-engineering-flow
```

Actions:

1. Create the branch.
2. Run or document baseline validation:
   - `apm compile`
   - existing eval scenarios, if available
3. Confirm generated target files are not accidentally committed.

Deliverable:

- Baseline status note in the PR description.

## Phase 1: Engineering Flow Council Model And Operating Guidance

Goal:

Make DevCrew's main workflow easy to understand as **DevCrew Engineering Flow**, with a clear Council Chair coordinating the existing lifecycle phases.

Naming:

```text
User-facing display name: DevCrew Engineering Flow
Primary command: /engineering-flow
Planning-only command: /convene-council
Internal skill id, first PR: team-workflow
```

Compatibility rule:

- Do not rename `.apm/skills/team-workflow/` in the first PR.
- Use **DevCrew Engineering Flow** in user-facing prose, prompts, quickstart examples, README copy, and architecture explanations.
- Keep `team-workflow` only where the exact technical skill id, folder path, or backwards-compatible reference is required.
- When the technical name must appear, write it as `DevCrew Engineering Flow (internal skill id: team-workflow)` instead of presenting `team-workflow` as a second product name.
- Add `/engineering-flow` as the user-facing prompt/command that activates the existing skill.
- Keep `/convene-council` as the planning-only sibling for trade-off review without implementation.

Operating guidance means the written instructions that tell agents how to run the lifecycle: Phase 0 classification, council depth, routing, checkpoints, decision artifacts, and handoffs. It is not a new runtime or replacement for the existing skill.

Add:

```text
docs/council-model.md
docs/engineering-flow-council-implementation-plan.md
.apm/agents/council-chair.agent.md
.apm/prompts/engineering-flow.prompt.md
.apm/prompts/convene-council.prompt.md
.apm/skills/team-workflow/references/council-routing.md
```

Update:

```text
.apm/skills/team-workflow/SKILL.md
.apm/prompts/quickstart.prompt.md
README.md
ARCHITECTURE.md
```

Key behavior:

- `/engineering-flow` is the user-facing entry point for request-to-implementation work.
- Every standard/full Engineering Flow starts with a Council Brief.
- The Council Chair explains classification, councils activated, trade-offs, checkpoints, and expected artifacts.
- Phase 0 classifies task size, risk, and council depth:

```text
Task size: quick-fix | standard-change | full-feature
Council depth: light | standard | deep
Risk: low | medium | high
```

- Deep mode adds option generation, council review, a trade-off matrix, and a user checkpoint before implementation.
- `/convene-council` runs council planning only and does not implement unless the user explicitly asks to proceed.
- Every council emits a decision artifact:

```text
Question:
Options considered:
Trade-offs:
Decision:
Rationale:
Risks accepted:
Risks rejected:
User approval needed:
Required follow-ups:
Next council:
```

Councils:

- Product Council
- Architecture Council
- Implementation Council
- Review Council
- Quality Council
- Delivery Council
- Operations Council
- Governance Council

Validation:

- Add an eval scenario proving `/engineering-flow` opens with the Council Chair, explains role routing and trade-offs, and preserves the underlying lifecycle phases.

Suggested eval:

```text
evals/scenarios/council/council-001-engineering-flow-chair-brief.md
```

## Phase 2: TypeScript/Node First-Class Support

Status: Complete. Core primitives, routing updates, eval scenarios, validation, and `apm compile` are complete.

Goal:

Fill the biggest current stack gap. DevCrew has Java and React standards, but not TypeScript/Node backend standards.

Add:

```text
.apm/skills/typescript-node-standards/SKILL.md
.apm/instructions/typescript-node-baseline.instructions.md
.apm/agents/typescript-node-reviewer.agent.md
.apm/prompts/node-service-review.prompt.md
.apm/skills/project-bootstrap/references/typescript-node-starter.md
.apm/skills/spec-templates/references/node-service.spec.md
```

Update:

```text
.apm/instructions/coding-standards.instructions.md
.apm/instructions/security-baseline.instructions.md
.apm/skills/project-detection/SKILL.md
.apm/skills/testing/SKILL.md
.apm/skills/code-review/SKILL.md
.apm/skills/project-bootstrap/SKILL.md
README.md
```

Standards to cover:

- Strict TypeScript.
- Runtime validation at boundaries.
- Typed environment config.
- Safe async error handling.
- Structured errors.
- Logging with redaction.
- Timeouts for outbound calls.
- Idempotency for workers and event handlers.
- Test conventions for APIs, workers, scheduled jobs, and queue consumers.

Validation:

```text
evals/scenarios/typescript-node/tsnode-001-runtime-validation-required.md
evals/scenarios/typescript-node/tsnode-002-worker-idempotency-required.md
evals/scenarios/typescript-node/tsnode-003-sensitive-data-not-logged.md
```

## Phase 3: AWS Application Development Support

Status: Complete. AWS primitives, routing updates, eval scenarios, validation, and `apm compile` are complete.

Goal:

Add generic AWS guidance without becoming AWS-only or company-specific.

Add:

```text
.apm/skills/aws-application-development/SKILL.md
.apm/instructions/aws-baseline.instructions.md
.apm/agents/aws-platform-reviewer.agent.md
.apm/prompts/aws-architecture-review.prompt.md
.apm/skills/project-bootstrap/references/aws-serverless-starter.md
```

Update:

```text
.apm/agents/devops-engineer.agent.md
.apm/agents/sre.agent.md
.apm/prompts/devops-plan.prompt.md
.apm/prompts/monitoring-plan.prompt.md
.apm/skills/project-detection/SKILL.md
.apm/instructions/governance.instructions.md
```

Standards to cover:

- IAM least privilege.
- KMS/encryption.
- S3 public access controls.
- VPC/security group review.
- CloudWatch logs, metrics, and alarms.
- DLQs and retry policies.
- EventBridge/SQS/SNS/Lambda/Step Functions patterns.
- Environment tagging.
- Cost and quota awareness.
- No secrets in IaC or examples.

Validation:

```text
evals/scenarios/aws/aws-001-iam-least-privilege-review.md
evals/scenarios/aws/aws-002-sqs-dlq-required.md
evals/scenarios/aws/aws-003-s3-public-access-blocked.md
```

## Phase 4: Infrastructure As Code And Image Builds

Status: Complete. IaC/image primitives, routing updates, eval scenarios, validation, and `apm compile` are complete.

Goal:

Support Terraform/OpenTofu/CDK/CloudFormation and AMI/container build workflows.

Add:

```text
.apm/skills/infrastructure-as-code/SKILL.md
.apm/skills/image-build/SKILL.md
.apm/instructions/infrastructure-baseline.instructions.md
.apm/agents/infrastructure-reviewer.agent.md
.apm/prompts/iac-review.prompt.md
.apm/skills/project-bootstrap/references/terraform-aws-starter.md
.apm/skills/spec-templates/references/aws-infrastructure.spec.md
```

Update:

```text
.apm/agents/devops-engineer.agent.md
.apm/prompts/devops-plan.prompt.md
.apm/prompts/release-readiness.prompt.md
.apm/skills/legacy-assessment/SKILL.md
.apm/skills/testing/SKILL.md
```

Standards to cover:

- Remote state and locking.
- Plan before apply.
- Drift detection.
- No secrets in state or vars.
- Immutable artifact promotion.
- Packer/container image scanning.
- Rollback and forward-fix strategy.
- Environment parity.

Validation:

```text
evals/scenarios/infrastructure/infra-001-terraform-risk-classification.md
evals/scenarios/infrastructure/infra-002-packer-image-no-baked-secrets.md
evals/scenarios/infrastructure/infra-003-iam-least-privilege-review.md
```

## Phase 5: Data Platform Support

Status: Complete. Data platform primitives, routing updates, eval scenarios, validation, and `apm compile` are complete.

Goal:

Support generic ingestion, mapping, validation, retry, replay, and operational feed workflows.

Add:

```text
.apm/skills/data-ingestion/SKILL.md
.apm/skills/data-mapping-validation/SKILL.md
.apm/skills/operational-feed-runbook/SKILL.md
.apm/instructions/data-platform-baseline.instructions.md
.apm/agents/data-platform-reviewer.agent.md
.apm/prompts/data-ingestion-design.prompt.md
.apm/prompts/mapping-review.prompt.md
.apm/prompts/feed-runbook.prompt.md
.apm/prompts/data-quality-plan.prompt.md
.apm/skills/project-bootstrap/references/data-ingestion-starter.md
.apm/skills/spec-templates/references/data-ingestion.spec.md
.apm/skills/spec-templates/references/data-mapping.spec.md
```

Update:

```text
.apm/skills/testing/SKILL.md
.apm/skills/team-workflow/SKILL.md
.apm/prompts/monitoring-plan.prompt.md
.apm/prompts/incident-response.prompt.md
.apm/agents/sre.agent.md
```

Standards to cover:

- Source contract.
- Landing zone.
- Schema validation.
- Quarantine/reject handling.
- Idempotency.
- Retry and DLQ behavior.
- Reconciliation.
- Backfill/replay.
- Golden-file tests.
- Data quality report.
- Operational runbook.

Validation:

```text
evals/scenarios/data-platform/data-001-ingestion-requires-idempotency.md
evals/scenarios/data-platform/data-002-mapping-requires-golden-tests.md
evals/scenarios/data-platform/data-003-sensitive-data-not-logged.md
evals/scenarios/data-platform/data-004-retry-and-dead-letter-required.md
evals/scenarios/data-platform/data-005-backfill-plan-required.md
```

## Phase 6: Contracts And Regulated Data

Status: Complete. Contract and regulated-data primitives, routing updates, eval scenarios, validation, and `apm compile` are complete.

Goal:

Support external contracts and generic sensitive/regulated data handling without hard-coding a domain.

Add:

```text
.apm/skills/interoperability-contracts/SKILL.md
.apm/skills/regulated-data-handling/SKILL.md
.apm/instructions/regulated-data-baseline.instructions.md
.apm/agents/interoperability-reviewer.agent.md
.apm/agents/regulated-data-reviewer.agent.md
.apm/prompts/contract-review.prompt.md
.apm/skills/spec-templates/references/contract-change.spec.md
```

Update:

```text
.apm/skills/api-design/SKILL.md
.apm/instructions/security-baseline.instructions.md
.apm/instructions/governance.instructions.md
.apm/skills/project-detection/SKILL.md
.apm/skills/code-review/SKILL.md
.apm/skills/testing/SKILL.md
.apm/skills/team-workflow/SKILL.md
.apm/skills/spec-templates/SKILL.md
README.md
ARCHITECTURE.md
.apm/prompts/quickstart.prompt.md
evals/README.md
```

Standards to cover:

- OpenAPI, AsyncAPI, webhooks, file/feed contracts.
- Standards-based protocols as examples, not the identity of the skill.
- Backward compatibility.
- Versioning and deprecation.
- Contract tests.
- Sensitive data classification.
- Masking/redaction.
- Synthetic/de-identified test data.
- Audit events and retention.

Validation:

```text
evals/scenarios/regulated-data/regdata-001-sensitive-data-not-logged.md
evals/scenarios/regulated-data/regdata-002-synthetic-test-data-required.md
evals/scenarios/regulated-data/regdata-003-audit-events-required.md
evals/scenarios/contracts/contract-001-backward-compatible-openapi.md
evals/scenarios/contracts/contract-002-webhook-versioning-required.md
```

## Phase 7: Release Evidence And Delivery Readiness

Status: Complete. Release evidence primitives, routing updates, eval scenarios, validation, and `apm compile` are complete.

Goal:

Make delivery decisions explicit and evidence-backed for medium/high-risk work.

Add:

```text
.apm/skills/release-evidence/SKILL.md
.apm/agents/release-evidence-reviewer.agent.md
.apm/prompts/release-evidence.prompt.md
.apm/skills/spec-templates/references/release-evidence.spec.md
```

Update:

```text
.apm/prompts/release-readiness.prompt.md
.apm/prompts/devops-plan.prompt.md
.apm/prompts/monitoring-plan.prompt.md
.apm/agents/devops-engineer.agent.md
.apm/agents/release-manager.agent.md
.apm/agents/sre.agent.md
.apm/skills/pull-request/SKILL.md
.apm/skills/spec-templates/SKILL.md
README.md
ARCHITECTURE.md
.apm/prompts/quickstart.prompt.md
evals/README.md
```

Release evidence should include:

- Scope and tickets.
- Risk classification.
- Changed components.
- Test evidence.
- Security checks.
- IaC/image evidence.
- Data impact.
- Contract compatibility.
- Rollback plan.
- Monitoring/runbooks.
- Approvals.

Validation:

```text
evals/scenarios/release-evidence/rel-001-high-risk-release-evidence-required.md
evals/scenarios/release-evidence/rel-002-iac-plan-and-rollback-required.md
```

## Phase 8: Documentation And Packaging

Status: Complete. Discoverability docs, README/architecture/eval metadata, and `apm.yml` packaging description are updated.

Goal:

Make the new model discoverable and maintainable.

Update:

```text
README.md
ARCHITECTURE.md
evals/README.md
apm.yml
```

Add:

```text
docs/council-model.md
docs/engineering-flow.md
docs/generic-platform-support.md
docs/typescript-node-aws-workflow.md
docs/data-platform-workflow.md
```

Also update:

- What’s Included table.
- IDE compatibility if any new primitive behaves differently.
- Quickstart examples.
- Example workflows.

## Phase 9: Validation

Status: Complete. APM validation and compile pass after the expanded Engineering Flow, platform, data, contract, regulated-data, release evidence, and documentation updates.

Goal:

Ensure the expanded DevCrew package remains coherent.

Run:

```sh
apm compile
```

If APM is available, run targeted evals:

```text
council
typescript-node
aws
infrastructure
data-platform
regulated-data
release-evidence
```

Manual validation prompts:

1. "/engineering-flow Add retry handling to a TypeScript SQS worker."
2. "/engineering-flow Review a Terraform change that opens an S3 bucket policy."
3. "/engineering-flow --deep Design a data ingestion pipeline for a CSV feed."
4. "/engineering-flow Add a React admin screen for feed status."
5. "/convene-council Prepare release evidence options for a high-risk queue behavior change."

Expected behavior:

- Council Chair explains the plan.
- DevCrew Engineering Flow is named as the user-facing workflow.
- `team-workflow` remains an internal implementation detail.
- Correct councils are activated.
- Trade-offs are visible.
- Risk classification is clear.
- No company-specific language appears.
- Artifacts are compact and useful.

## Phase 10: Token Efficiency Measurement

Goal:

Measure whether DevCrew Engineering Flow improves token efficiency compared with a bare assistant, especially by reducing repeated context, rework, and missed-requirement churn.

Timing:

- Do not include this in the first Engineering Flow council PR.
- Add it only after `/engineering-flow` behavior lands and the council eval proves quick fixes stay light.

Add or update:

```text
evals/baselines/measurement-protocol.md
evals/report-template.md
```

Measure:

- Total input and output tokens per task.
- User-supplied context tokens.
- Rework tokens.
- Tokens per accepted task.
- Tokens per quality point.
- Tokens per defect caught for review scenarios.
- Repeated-session context savings from `.project-context.md` and `.memory.md`.

Interpretation:

- Fewer raw tokens is a clear win only if quality stays the same or improves.
- More tokens can still be a win for standard/full/high-risk work if quality, defect detection, or rework improves.
- Quick fixes should stay light; if they become token-heavy, tighten the Engineering Flow light-mode path.

## PR Strategy

Recommended PR breakdown:

1. Lean Engineering Flow council model and chair.
2. Internal Engineering Flow rename migration (`team-workflow` -> `engineering-flow`) with compatibility wrapper, after behavior is proven.
3. Token efficiency measurement updates, after behavior is stable.
4. TypeScript/Node standards.
5. AWS application development.
6. Infrastructure and image builds.
7. Data platform skills.
8. Contracts and regulated data.
9. Release evidence.
10. Documentation and eval cleanup.

Avoid one giant PR. The change is conceptually large and should land in reviewable layers.

First PR guardrails:

- Keep quick fixes light.
- Add only one council eval.
- Do not rename the internal skill folder.
- Do not update token-measurement protocols yet.
- Do not rewrite all existing specialist agents.
- Do not mix in TypeScript/Node, AWS, data, regulated-data, or release-evidence expansion.

## Internal Rename Migration Recommendation

After the first Engineering Flow council PR lands, run a dedicated migration PR to align the internal skill id and path with the user-facing name.

Migration target:

```text
.apm/skills/team-workflow/      -> deprecated wrapper
.apm/skills/engineering-flow/   -> primary implementation
name: team-workflow             -> compatibility id only
name: engineering-flow          -> primary skill id
```

Migration actions:

1. Audit all references with `rg -n "team-workflow|engineering-flow|Engineering Flow"`.
2. Move the full implementation to `.apm/skills/engineering-flow/`.
3. Update the moved skill frontmatter to `name: engineering-flow`.
4. Keep `.apm/skills/team-workflow/SKILL.md` as a small deprecated compatibility wrapper.
5. Update docs, prompts, quickstart, architecture, and evals to prefer Engineering Flow.
6. Add one compatibility eval proving `team-workflow` delegates to Engineering Flow.
7. Run `apm compile` and targeted evals.

Expected post-migration rule:

```text
Engineering Flow is the product/workflow name and primary skill id.
team-workflow exists only as a deprecated compatibility wrapper.
```

## First Commit Recommendation

Start with:

```text
feat(workflow): add engineering flow council guidance
```

Files:

```text
docs/council-model.md
docs/engineering-flow-council-implementation-plan.md
.apm/agents/council-chair.agent.md
.apm/prompts/engineering-flow.prompt.md
.apm/prompts/convene-council.prompt.md
.apm/skills/team-workflow/references/council-routing.md
.apm/skills/team-workflow/references/phase-execution-reference.md
.apm/skills/team-workflow/SKILL.md
.apm/prompts/quickstart.prompt.md
README.md
ARCHITECTURE.md
scripts/init-context.sh
scripts/init-memory.sh
evals/scenarios/council/council-001-engineering-flow-chair-brief.md
```

Why first:

DevCrew Engineering Flow becomes the user-friendly entry point, and the council model becomes the organizing layer for all later skills and agents.
