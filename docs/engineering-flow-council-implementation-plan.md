# DevCrew Engineering Flow Council Implementation Plan

Status: First PR implementation complete; validation complete.

## Goal

Introduce **DevCrew Engineering Flow** as the user-facing name and command for DevCrew's main request-to-implementation lifecycle, while keeping the existing `team-workflow` skill as the internal implementation for compatibility.

The council model should make the lifecycle easier to follow. It should not replace the existing phases, agents, review loops, quality gates, or memory behavior.

In this plan, "operating guidance" means the written instructions that tell agents how to run the lifecycle: classification, council depth, routing, checkpoints, decision artifacts, and handoffs. It is not a separate runtime.

## Naming Decision

```text
Display name: DevCrew Engineering Flow
Primary command: /engineering-flow
Planning-only command: /convene-council
Internal skill id: team-workflow
```

## Reference Rule

Use **DevCrew Engineering Flow** everywhere users read or invoke the workflow:

- README and architecture prose.
- Quickstart examples.
- Prompt names and command examples.
- Council Chair briefs.
- Eval scenario task text and expected behavior.

Keep `team-workflow` only where the exact technical identifier is required:

- `.apm/skills/team-workflow/` folder path.
- Skill frontmatter `name: team-workflow`.
- Existing evals, references, or compatibility notes that need the old id.
- APM/package internals that would break if renamed.

When both names must appear, use:

```text
DevCrew Engineering Flow (internal skill id: team-workflow)
```

Do not present `team-workflow` as a second user-facing name.

Use this phrasing in docs:

```text
DevCrew Engineering Flow coordinates the DevCrew engineering team through planning, implementation, review, and testing. The Council Chair opens the flow, explains routing and trade-offs, and activates the right councils and agents for the request.
```

## Scope

Build in the first PR only:

- Council model documentation.
- Council Chair agent.
- Engineering Flow prompt/command.
- Council planning prompt.
- Council routing reference in the existing internal skill folder.
- DevCrew Engineering Flow Phase 0 updates for council depth.
- README, architecture, and quickstart wording updates.
- One council eval scenario.

Do not build in the first PR:

- Broad edits to existing specialist agents.
- TypeScript/Node standards.
- AWS standards.
- Infrastructure/IaC standards.
- Data platform skills.
- Regulated data skills.
- Release evidence skill.
- Multi-provider runtime calls or Karpathy-style anonymous model ranking.
- A folder rename from `team-workflow` to `engineering-flow`.
- Token measurement protocol/report-template changes.

## First PR Recommendation

Keep the first PR lean and focused:

```text
Council Chair
/engineering-flow
/convene-council
council-routing.md
DevCrew Engineering Flow updates inside the existing team-workflow skill
quickstart/README/architecture updates
one council eval
```

Success means:

- Quick fixes stay light.
- Standard/full work opens with a concise Council Brief.
- Deep mode exists but only activates for explicit or high-risk/ambiguous cases.
- The Council Chair coordinates; it does not replace specialist agents.
- The existing lifecycle still works.
- No platform-expansion work is mixed into this PR.

## Anti-Overkill Guardrails

Use this routing rule:

```text
Quick fix = one-line Chair note, no formal council artifact.
Standard change = concise Council Brief and compact decision notes.
Full/high-risk/ambiguous = deep council with options, trade-offs, and user checkpoint.
```

Avoid:

- Running deep council for typos, docs copy, simple tests, or localized bug fixes.
- Emitting the full decision artifact for every minor phase.
- Pulling Delivery or Operations councils into normal pre-merge work unless release or runtime risk is explicit.
- Rewriting all existing agents just to mention councils.
- Measuring token efficiency before Engineering Flow behavior is stable.

## Deferred Internal Rename Migration Plan

The first PR should make **DevCrew Engineering Flow** the user-facing name without renaming the internal skill folder. A later migration PR can make the internal primitive match the user-facing name.

Migration goal:

```text
Before: .apm/skills/team-workflow/ with name: team-workflow
After:  .apm/skills/engineering-flow/ with name: engineering-flow
```

Compatibility goal:

```text
/engineering-flow -> primary command
engineering-flow -> primary skill id
team-workflow -> deprecated compatibility wrapper for one or more minor releases
```

### Migration Preconditions

- The first Engineering Flow council PR has landed.
- `/engineering-flow` works as the primary command.
- The council eval scenario passes or has documented gaps.
- `apm compile` is available, or the lack of APM is documented before migration starts.
- A reference audit has been captured with `rg -n "team-workflow|engineering-flow|Engineering Flow"`.

### Migration Phase M0: Reference Audit

Inventory every `team-workflow` reference and classify it:

| Category | Action |
|---|---|
| User-facing docs and examples | Replace with DevCrew Engineering Flow or `/engineering-flow` |
| Internal skill path references | Update to `.apm/skills/engineering-flow/` |
| Skill frontmatter and skill calls | Update to `engineering-flow` |
| Existing eval scenario prompts | Update to `engineering-flow`, unless testing compatibility |
| Compatibility notes | Keep `team-workflow` with deprecated wording |

Audit command:

```sh
rg -n "team-workflow|Engineering Flow|engineering-flow"
```

### Migration Phase M1: Create The Primary Skill

Move the implementation:

```text
.apm/skills/team-workflow/
-> .apm/skills/engineering-flow/
```

Update inside the moved skill:

```text
name: engineering-flow
title/headings: DevCrew Engineering Flow
references/*.md links
handoff text
examples
related skill references
```

The moved skill becomes the source of truth for the lifecycle.

### Migration Phase M2: Add Compatibility Wrapper

Keep a small deprecated wrapper at:

```text
.apm/skills/team-workflow/SKILL.md
```

Wrapper behavior:

- Frontmatter remains `name: team-workflow`.
- Description states it is deprecated.
- It delegates to DevCrew Engineering Flow.
- It does not duplicate the full lifecycle instructions.
- It tells agents to use `engineering-flow` for all new work.

Compatibility wrapper sketch:

```markdown
---
name: team-workflow
description: Deprecated compatibility wrapper for DevCrew Engineering Flow.
---

# Team Workflow Compatibility Wrapper

`team-workflow` is deprecated. Use DevCrew Engineering Flow (`engineering-flow`) for new work.

When this skill is activated, run the `engineering-flow` skill with the user's original request and preserve all existing behavior.
```

### Migration Phase M3: Update Prompts, Docs, And Evals

Update:

```text
.apm/prompts/engineering-flow.prompt.md
.apm/prompts/quickstart.prompt.md
README.md
ARCHITECTURE.md
evals/README.md
evals/scenarios/*
docs/*
```

Rules:

- New examples use `/engineering-flow`.
- New skill references use `engineering-flow`.
- Compatibility notes may mention `team-workflow`.
- Add one compatibility eval proving old `team-workflow` activation still delegates correctly.

Suggested compatibility eval:

```text
evals/scenarios/council/council-002-team-workflow-compatibility-wrapper.md
```

### Migration Phase M4: Validation

Run:

```sh
apm compile
rg -n "team-workflow"
```

Expected `team-workflow` matches after migration:

- Compatibility wrapper.
- Migration docs.
- Release notes.
- Compatibility eval.

Run targeted evals:

```text
council
right-sizing
governance
skill-output
```

Manual validation prompts:

```text
/engineering-flow Add validation to an API endpoint.
Use engineering-flow to fix a frontend accessibility issue.
Use team-workflow to add retry handling to a worker.
```

Expected behavior:

- `/engineering-flow` is primary.
- `engineering-flow` skill runs directly.
- `team-workflow` still works but is clearly deprecated.
- No user-facing docs present `team-workflow` as the preferred name.

### Migration Phase M5: Deprecation Window

Keep the compatibility wrapper for at least one minor release.

Deprecation messaging:

```text
`team-workflow` remains available as a deprecated alias for DevCrew Engineering Flow. Use `/engineering-flow` or the `engineering-flow` skill for new work.
```

Removal can happen in a later major version only after:

- Release notes announce the removal.
- Evals no longer depend on the old id except migration history.
- Docs and quickstart no longer tell users to invoke `team-workflow`.

## First PR Implementation Checklist

- [x] Add `docs/council-model.md`.
- [x] Add `.apm/agents/council-chair.agent.md`.
- [x] Add `.apm/prompts/engineering-flow.prompt.md`.
- [x] Add `.apm/prompts/convene-council.prompt.md`.
- [x] Add `.apm/skills/team-workflow/references/council-routing.md`.
- [x] Add `.apm/skills/team-workflow/references/phase-execution-reference.md`.
- [x] Update `.apm/skills/team-workflow/SKILL.md`.
- [x] Update `.apm/prompts/quickstart.prompt.md`.
- [x] Update `README.md`.
- [x] Update `ARCHITECTURE.md`.
- [x] Update setup-script user-facing references.
- [x] Add `evals/scenarios/council/council-001-engineering-flow-chair-brief.md`.
- [x] Run local APM artifact validation.
- [x] Document `apm compile` availability.
- [x] Document validation results.

## APM Primitive Update Plan

Update the APM primitives in a controlled order so the user-facing command, chair behavior, routing reference, and lifecycle skill stay consistent.

### Primitive Update Order

| Step | Primitive | Purpose | Key updates |
|---|---|---|---|
| 1 | `.apm/agents/council-chair.agent.md` | Define the coordinator voice | Council Brief, depth explanation, trade-offs, user checkpoints, decision synthesis |
| 2 | `.apm/skills/team-workflow/references/council-routing.md` | Centralize routing rules | Council depths, council-to-agent map, deep-mode triggers, decision artifact format |
| 3 | `.apm/prompts/engineering-flow.prompt.md` | Add user-facing command | Route `/engineering-flow` to DevCrew Engineering Flow, including deep-mode language |
| 4 | `.apm/prompts/convene-council.prompt.md` | Add planning-only command | Run Council Brief, options, trade-offs, recommendation, no implementation by default |
| 5 | `.apm/skills/team-workflow/SKILL.md` | Update lifecycle behavior | Present as DevCrew Engineering Flow, add council depth in Phase 0, integrate Council Brief and deep mode |
| 6 | `.apm/prompts/quickstart.prompt.md` | Update onboarding | Prefer `/engineering-flow`, explain `/convene-council`, avoid `team-workflow` as user-facing name |
| 7 | Existing docs/evals | Validate behavior | Add council scenario and update examples to Engineering Flow |

Do not update the existing specialist agents in the first PR unless a specific agent must reference a handoff produced by the Council Chair. Broad agent alignment belongs in a later cleanup.

### Primitive Guardrails

- Keep skill, agent, and prompt line counts within the limits from `apm-authoring`.
- Do not duplicate the full lifecycle in the Council Chair or prompts; the lifecycle remains in DevCrew Engineering Flow.
- Keep `council-routing.md` as the source of truth for council activation rules.
- Keep `/convene-council` planning-only unless the user explicitly proceeds.
- Keep `team-workflow` only as the internal skill id/path in the first PR.
- Run APM validation after primitive edits:

```sh
bash .apm/skills/apm-authoring/scripts/validate.sh
apm compile
```

If `apm` is unavailable, document that validation gap and run the local validation script if present.

## Deferred Token Efficiency Measurement Plan

Do not update `evals/baselines/measurement-protocol.md` or `evals/report-template.md` in the first Engineering Flow behavior PR. Add token measurement after the behavior lands and the council eval has proven that quick fixes stay light.

Token measurement should compare DevCrew against a control assistant without DevCrew, but it should not treat fewer raw tokens as the only win. DevCrew may intentionally spend more tokens on planning/review for risky work. The better question is:

```text
How many tokens does it take to reach an accepted, correct, reviewable outcome?
```

### Measurement Questions

| Question | Why it matters |
|---|---|
| Raw token use | Shows direct cost and context footprint |
| User-supplied context tokens | Shows how much explanation the developer had to type |
| Rework tokens | Shows waste from wrong turns, missed requirements, and fixes |
| Quality-adjusted tokens | Shows whether extra tokens bought better outcomes |
| Phase-level tokens | Shows where the workflow is expensive or efficient |
| Repeated-session tokens | Shows whether `.project-context.md` and `.memory.md` reduce re-explanation |

### Token Metrics

| Metric | Formula | Interpretation |
|---|---|---|
| Total tokens per task | input + output tokens across all turns | Raw cost for the task |
| User context tokens | tokens typed by user to explain project/task context | Lower means less manual context burden |
| Assistant output tokens | assistant response tokens across all turns | Measures verbosity and artifact size |
| Rework tokens | tokens after a redo/fix/retry request | Lower means fewer wrong turns |
| Tokens per accepted task | total tokens / task accepted | Basic efficiency metric |
| Tokens per quality point | total tokens / judge quality score | Normalizes cost by output quality |
| Tokens per defect caught | review tokens / true positives | Useful for review scenarios |
| Context reuse savings | repeated context tokens without DevCrew - repeated context tokens with DevCrew | Measures memory/context value |

### Collection Methods

Preferred method:

- Use IDE/provider telemetry if available, capturing input tokens, output tokens, cached tokens, and model name per turn.

Fallback method:

- Save full transcripts for each task and estimate tokens with a consistent tokenizer.
- Use the same estimator for control and DevCrew runs.
- Record the estimator and model family in the report.

Manual approximation:

- Count user messages and assistant/tool outputs.
- Estimate tokens from text length only for directional comparison.
- Mark the result as approximate, not billing-grade.

### Before/After Protocol

Use the existing `evals/baselines/measurement-protocol.md` task set and add token fields:

```text
Task:
Condition: without-devcrew | with-devcrew
Model:
Total input tokens:
Total output tokens:
Cached/read tokens, if available:
User context tokens:
Rework tokens:
Quality score:
Task accepted: yes | no
Notes:
```

Run the same task set twice:

1. Control: same model, no DevCrew primitives or memory.
2. Treatment: same model, DevCrew installed, `/engineering-flow` used.

Normalize by outcome:

```text
Token delta = (with_devcrew_tokens - without_devcrew_tokens) / without_devcrew_tokens
Quality delta = with_devcrew_quality - without_devcrew_quality
Efficiency = total_tokens / quality_score
```

### How To Interpret Results

| Result | Interpretation |
|---|---|
| Fewer tokens and same/better quality | Clear efficiency win |
| More tokens and much better quality | Worth it for standard/full/high-risk work |
| More tokens and same quality | Process may be too heavy; tighten routing or artifacts |
| Fewer tokens but worse quality | False economy; workflow is skipping needed context |
| Lower repeated-session context tokens | Memory/context persistence is working |
| Lower rework tokens | Council/routing prevented wrong turns |

Expected pattern:

- Quick fixes may use more tokens with DevCrew unless light mode is very tight.
- Standard changes should reduce rework and user context tokens.
- Full features may use more planning tokens but should improve quality-adjusted efficiency.
- Repeated sessions should show the clearest token savings from persisted context and memory.

## Code And Primitive Update Plan

### `.apm/prompts/engineering-flow.prompt.md`

Create the user-facing command for the main lifecycle.

Expected behavior:

- Route to DevCrew Engineering Flow, implemented by the existing internal `team-workflow` skill.
- Make clear that `/engineering-flow` runs the lifecycle, including implementation when appropriate.
- Accept explicit deep mode language such as `--deep`, `deep:`, or "run deep council".
- Mention `/convene-council` when the user appears to want planning only.

### `.apm/prompts/convene-council.prompt.md`

Create the planning-only command.

Expected behavior:

- Produce a Council Brief.
- Generate options when useful.
- Compare trade-offs.
- Recommend a path.
- Ask for user approval before implementation.
- Do not modify files unless the user explicitly proceeds.

### `.apm/agents/council-chair.agent.md`

Define the chairperson role.

Responsibilities:

- Explain task classification.
- Explain council depth.
- Activate and skip councils deliberately.
- Surface trade-offs and risks.
- Maintain user checkpoints.
- Synthesize decision artifacts.

Non-responsibilities:

- Do not implement code.
- Do not replace specialized agents.
- Do not approve high-risk work without user confirmation.

### `.apm/skills/team-workflow/references/council-routing.md`

Add the operational routing map.

It should define:

- Council depths: `light`, `standard`, `deep`.
- Council-to-agent mappings.
- Automatic deep mode signals.
- Manual deep mode triggers.
- Decision artifact expectations.

### `.apm/skills/team-workflow/SKILL.md`

Keep the internal skill id as `team-workflow`, but describe the workflow itself as DevCrew Engineering Flow. Inside the file, update user-visible headings and examples to Engineering Flow while preserving the frontmatter `name` and path for compatibility.

Phase 0 should classify:

```text
Task size: quick-fix | standard-change | full-feature
Council depth: light | standard | deep
Risk: low | medium | high
```

Default depth:

```text
quick-fix -> light
standard-change -> standard
full-feature -> standard
full-feature + medium/high risk -> deep or strongly suggest deep
```

Deep mode should insert:

```text
Generate 2-3 options
Council review of options
Trade-off matrix
Recommended path
User checkpoint
Continue normal Engineering Flow
```

### Docs

Update user-facing docs to say:

```text
DevCrew Engineering Flow is implemented by the `team-workflow` skill.
```

Avoid presenting `team-workflow` as the primary user-facing name except where exact internal implementation details matter.

## Council Mapping

| Council | Existing agent or primitive |
|---|---|
| Product Council | `product-analyst` |
| Architecture Council | `architect` |
| Implementation Council | `junior-developer`, `senior-developer` |
| Review Council | `backend-reviewer`, `frontend-reviewer` |
| Quality Council | `qa-lead`, `test-engineer` |
| Delivery Council | `release-manager`, `devops-engineer` |
| Operations Council | `sre` |
| Governance Council | `governance.instructions.md`, `security-baseline.instructions.md` |

## Decision Artifact

Use the full artifact for standard/deep mode:

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

Light mode may use a compressed Chair note.

## Validation Plan

Run when implementation is complete:

```sh
apm compile
```

If APM is unavailable, document that explicitly.

Manual validation prompts:

```text
/engineering-flow Fix a typo in the README.
/engineering-flow Add retry handling to a TypeScript SQS worker.
/engineering-flow --deep Design a data ingestion pipeline for a CSV feed.
/convene-council Compare options for adding release evidence to high-risk changes.
```

Expected validation behavior:

- Quick fixes stay light.
- Standard work receives a Council Brief.
- Deep mode shows options and trade-offs before implementation.
- `/convene-council` does not implement by default.
- Docs use DevCrew Engineering Flow as the user-facing name.
- `team-workflow` remains intact as the internal skill id.

## Validation Results

2026-06-06:

```text
bash .apm/skills/apm-authoring/scripts/validate.sh
```

Result:

- Passed: 52
- Failed: 0
- Warnings: 10

Warnings:

- `.apm/skills/team-workflow/SKILL.md` is 422 lines and approaching the 500-line limit.
- Existing prompt files use frontmatter before the first `#` heading.
- Existing `quickstart.prompt.md` is over the 100-line prompt-efficiency recommendation.

`apm compile`:

- Passed after installing APM CLI 0.18.0.
- Generated target context successfully for `claude`, `cursor`, and `vscode`.
- No generated target files appeared as new tracked diffs in `git status`.

## Open Decisions

- Whether `/engineering-flow --deep` and `/engineering-flow deep:` should both be documented as canonical triggers.
- Whether to add a short alias such as `/flow` later.
- How many minor releases to keep the `team-workflow` compatibility wrapper before removing it in a major version.

## Progress Log

- 2026-06-06: Naming decision set to DevCrew Engineering Flow, with `/engineering-flow` as the primary command and `team-workflow` retained as the internal skill id.
- 2026-06-06: Added staged migration plan to rename the internal skill id/path to `engineering-flow` while keeping `team-workflow` as a deprecated wrapper.
- 2026-06-06: Tightened first PR scope to lean Engineering Flow council behavior; deferred internal rename, token measurement, broad agent rewrites, and platform skill expansion.
- 2026-06-06: Implemented first PR scope, moved detailed phase mechanics into `phase-execution-reference.md`, passed local APM validation, installed APM CLI 0.18.0, and passed `apm compile`.
