# Phase Execution Reference

This reference preserves detailed execution guidance for DevCrew Engineering Flow while keeping `SKILL.md` concise.

## Phase 1: Requirements

Standard changes:

- Restate the task in 2-3 sentences.
- State in scope and out of scope.
- List non-obvious risks or side effects.

Full features:

- Restate the request in concrete engineering terms.
- Assign REQ-IDs.
- Add acceptance criteria for every requirement.
- Identify edge cases, boundaries, assumptions, dependencies, and scope.
- Use `spec-templates` to produce a `.spec.md` handoff.

## Deep Council Option Review

Use when council depth is `deep`.

Required artifact:

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

Deep mode must not replace implementation, review, or QA. It only chooses the path before those phases run.

## Phase 2: Architecture

Subagent prompt:

```text
You are the Architect agent. Discipline: [discipline]. Review these requirements and design an architecture using the architect agent definition. Produce an architecture decision with diagrams, trade-off analysis, and a recommendation. [Attach Phase 1 handoff]
```

Required checks:

- At least one Mermaid diagram.
- At least two approaches or a justified single approach.
- Every REQ-ID maps to a component.
- Anti-patterns are explicitly called out.
- Recommendation includes risks and revisit criteria.

## Phase 3: Implementation

Execution mode:

| Mode | Behavior |
|---|---|
| `local` | Spawn a `generalPurpose` implementation subagent. |
| `background` | Provide a complete background-agent prompt and pause. |
| `async` | Use `/spec-to-issues` to decompose into tracker work and pause. |
| `manual` | Produce an implementation plan and wait for the user. |

Local subagent prompt:

```text
You are the Junior Developer guided by the Senior Developer. Discipline: [discipline]. Task size: [size]. Implement the changes following codebase patterns. Apply discipline-specific practices from both agent definitions. Handle error paths, validation, and cleanup. [Attach available handoffs]
```

Implementation checks:

- Follow codebase patterns.
- Handle error paths and cleanup.
- Add structured logging for backend work where useful.
- Use accessible, responsive UI patterns for frontend work.
- Write tests alongside implementation when appropriate.
- Map files to REQ-IDs for full features.
- Pause and propose a size upgrade if scope escalates.

## Phase 4: Review

Quick fixes use inline lightweight review.

Standard and full-feature work use isolated review subagents:

| Discipline | Reviewer |
|---|---|
| Backend | `backend-reviewer` |
| Frontend | `frontend-reviewer` |
| Fullstack | Both reviewers sequentially |

Reviewer prompt pattern:

```text
You are the [Backend/Frontend] Reviewer. Review these changes adversarially — assume defects exist. Use the relevant checklist reference. [Attach Phase 3 handoff, Phase 2 handoff if present, changed files]
```

Review checks:

- Inspect every changed file.
- Categorize findings as Critical, Warning, or Suggestion.
- Reference file/location and suggested fix.
- Verify architecture conformance for full features.
- Critical findings automatically route back to Phase 3, capped at 2 cycles.

## Phase 5: Quality

Phase 5a QA Lead prompt:

```text
You are the QA Lead. Discipline: [discipline]. Design a test strategy adversarially — assume untested paths and hidden bugs exist. Produce a structured test plan with TC-IDs, priorities, expected results, test data requirements, and quality gates. Map every REQ-ID to at least one test case. [Attach handoffs]
```

Phase 5b Test Engineer prompt:

```text
You are the Test Engineer. Discipline: [discipline]. Implement or augment tests from the plan and changed files. Scan for conventions, run the suite, verify coverage, and report results. Flag application bugs; do not hide them.
```

Quality checks:

- Full-feature REQ-IDs have test coverage.
- Standard changes cover happy path, error paths, and key edges.
- Test code follows existing conventions.
- Application bugs route back to Phase 3.
- Test quality issues can be retried internally, capped at 2 cycles.

