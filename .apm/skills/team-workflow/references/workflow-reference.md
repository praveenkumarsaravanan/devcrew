# Team Workflow Reference

## Re-Routing Rules

When a review phase identifies issues that require changes to an earlier phase:

| Finding in | Severity | Action |
|---|---|---|
| Phase 4 (Code Review) | Critical | Automatically loop to Phase 3, fix, then re-run Phase 4. Max 2 cycles. |
| Phase 4 (Code Review) | Warning | Present to user. Fix if user agrees, otherwise accept and document. |
| Phase 5b (Test Impl) | Test code quality issues | Re-implement affected tests internally. Max 2 cycles before escalating to user. |
| Phase 5b (Test Impl) | Application bugs found | Route back to Phase 3. Max 2 cycles. |
| Phase 5b (Test Impl) | Untestable code | Flag to user. Recommend Phase 3 refactor. User decides. |

After any re-routing loop, update the handoff artifact for the re-entered phase to reflect the changes made.

## Requirement Traceability

Maintain traceability from requirements through every phase:

| Phase | Traceability action |
|---|---|
| Phase 1 | Assign IDs: REQ-001, REQ-002, ... |
| Phase 2 | Map each component to the REQ-IDs it satisfies |
| Phase 3 | Note which REQ-IDs each changed file addresses |
| Phase 4 | Verify all REQ-IDs have corresponding code |
| Phase 5a | Map each test case (TC-001, ...) to the REQ-IDs it covers |
| Phase 5b | Map each test file to the TC-IDs it implements; verify all REQ-IDs have passing tests |

Post-merge traceability (infrastructure, release readiness, observability) is handled by the `/devops-plan`, `/release-readiness`, and `/monitoring-plan` prompts when the developer invokes them.

At the final summary, produce a traceability matrix:

```
| REQ-ID  | Component     | Files              | Test Cases       |
|---------|---------------|--------------------|------------------|
| REQ-001 | UserService   | UserService.java   | TC-001, TC-003   |
| REQ-002 | AuthMiddleware| auth.middleware.ts  | TC-002, TC-004   |
```

## Phase Summary Template

At the end of the full workflow (or when the user stops early), produce a summary:

```
## Team Workflow Summary

| Phase | Status | Execution | Key Decision / Output |
|---|---|---|---|
| 0. Discipline Detection | Completed | Inline | Discipline: [backend/frontend/fullstack] |
| 1. Requirements | Completed | Inline | X requirements defined, Y edge cases identified |
| 2. Architecture | Completed | Subagent | [Approach chosen] with [key trade-off] |
| 3. Implementation | Completed | Subagent | X files changed, Y new files created |
| 4. Code Review | Completed | Subagent (N cycles) | X critical, Y warnings, Z suggestions |
| 5a. Test Strategy | Completed | Subagent (QA Lead) | X test cases, Y quality gates |
| 5b. Test Implementation | Completed | Subagent (Test Engineer) | X test files, Y tests passing, quality: [verdict] |

[Traceability matrix here]

## Next Steps

For post-merge activities, use these prompts when ready:
- `/devops-plan` — deployment strategy and CI/CD pipeline
- `/release-readiness` — go/no-go checklist and rollback planning
- `/monitoring-plan` — SLOs, alerts, and runbooks
```
