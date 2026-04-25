---
name: spec-templates
description: >
  Provides structured specification templates for requirements documentation.
  Activated by team-workflow Phase 1 (full feature) or when a user asks to write
  a spec. Produces a .spec.md file from a discipline-appropriate template.
---

# Spec Templates

## Trigger

Activate this skill when:

- `team-workflow` Phase 1 instructs you to produce a specification document for a full feature.
- The user asks to "write a spec," "create a spec," "document the requirements," or similar.
- The user wants to convert requirements into a structured, implementation-ready format.

Do NOT activate for:

- Quick fixes or standard changes — these use Phase 1's light variant (no spec file).
- Standalone documentation — use the `documentation` skill instead.

## Workflow

### Step 1: Determine the Spec Type

Based on the discipline (from Phase 0) and the nature of the task, select the appropriate template:

| Task nature | Template | When to use |
|-------------|----------|-------------|
| New REST or gRPC endpoint | `api-endpoint.spec.md` | Adding or modifying API endpoints |
| New UI component or page | `ui-component.spec.md` | Frontend components, pages, or flows |
| New backend service or module | `service.spec.md` | Services, workers, processors, integrations |
| Data or schema migration | `migration.spec.md` | Database schema changes, data transformations, system migrations |

If the task doesn't fit any template, use the canonical structure from `spec-format.md` as a base and adapt it.

If the task spans multiple types (e.g., a new API endpoint with a corresponding UI), create separate spec sections for each type within a single `.spec.md` file.

### Step 2: Gather Inputs

Collect information from the Phase 1 requirements (if available) or from the user:

1. **Problem statement:** What problem does this solve? Why now?
2. **Scope:** What is in scope and explicitly out of scope?
3. **Requirements:** Numbered requirements with acceptance criteria (REQ-001, REQ-002, ...)
4. **Constraints:** Technical, organizational, or timeline constraints
5. **Dependencies:** External systems, teams, or data sources

### Step 3: Fill the Template

1. Copy the selected template structure.
2. Fill in each section with the gathered inputs.
3. For API specs: define request/response schemas, error codes, and authentication requirements.
4. For UI specs: define component hierarchy, state management approach, and interaction patterns.
5. For service specs: define interfaces, data flows, and integration points.
6. For migration specs: define rollback strategy, data validation, and zero-downtime requirements.

### Step 4: Validate Completeness

Before presenting the spec, verify:

- [ ] Every requirement has an ID (REQ-NNN) and at least one acceptance criterion
- [ ] Scope boundaries are explicitly stated (in/out)
- [ ] API contracts are defined (if applicable)
- [ ] Error scenarios are documented
- [ ] A handoff checklist exists for the implementation phase
- [ ] Dependencies are listed or explicitly noted as "none"

### Step 5: Write the Spec File

Save the spec as `<feature-name>.spec.md` in the project root or a `specs/` directory if one exists.

Present the spec to the user for review and confirmation.

## Output

The spec file follows the canonical structure defined in `spec-format.md`:

```
# [Feature Name] Specification

## Problem Statement
## Scope
## Requirements
## API Contracts (if applicable)
## Data Model (if applicable)
## Error Scenarios
## Validation Criteria
## Dependencies
## Handoff Checklist
```

## Guardrails

- **Never skip the problem statement.** If the user jumps straight to requirements, ask "What problem does this solve?" first.
- **Specs are for full features only.** Quick fixes and standard changes do not need spec files.
- **One spec per feature.** Do not combine unrelated features into a single spec.
- **Requirements must be testable.** Every REQ-ID must have acceptance criteria that a test can verify.
- **Keep specs implementation-agnostic where possible.** Define what, not how — the architecture phase handles the how.

## References

- [Canonical Spec Format](references/spec-format.md) — Structure and field definitions for all spec types
- [API Endpoint Template](references/api-endpoint.spec.md) — Template for REST/gRPC endpoint specifications
- [UI Component Template](references/ui-component.spec.md) — Template for frontend component specifications
- [Service Template](references/service.spec.md) — Template for backend service specifications
- [Migration Template](references/migration.spec.md) — Template for data/schema migration specifications

## See Also

- **`team-workflow`** — Phase 1 activates this skill for full features to produce structured specs.
- **`memory-management`** — Specs reference project context from `.project-context.md`.
- **`documentation`** — For non-spec documentation (READMEs, guides, ADRs).
