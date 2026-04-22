# Backend Team Workflow Reference

## Re-Routing Rules

When a review phase identifies issues that require changes to an earlier phase:

| Finding in | Severity | Action |
|---|---|---|
| Phase 4 (Code Review) | Critical | Automatically loop to Phase 3, fix, then re-run Phase 4. Max 2 cycles. |
| Phase 4 (Code Review) | Warning | Present to user. Fix if user agrees, otherwise accept and document. |
| Phase 5b (Test Impl) | Test code quality issues | QA Lead (5c) routes back to Test Engineer (5b) with findings. Max 2 cycles. |
| Phase 5b (Test Impl) | Application bugs found | QA Lead (5c) routes back to Phase 3. Max 2 cycles. |
| Phase 5b (Test Impl) | Untestable code | QA Lead (5c) flags to user. Recommend Phase 3 refactor. User decides. |
| Phase 7 (Release) | No-go | Present blockers. User decides whether to loop back or abort. |

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
| Phase 5b | Map each test file to the TC-IDs it implements |
| Phase 5c | Verify all REQ-IDs have passing tests (TC-ID → test file → pass) |
| Phase 6 | Note which REQ-IDs require infrastructure changes |
| Phase 7 | Verify all REQ-IDs are release-ready |
| Phase 8 | Verify all REQ-IDs have observability coverage |

At the final summary, produce a traceability matrix:

```
| REQ-ID  | Component     | Files              | Test Cases       | Monitored |
|---------|---------------|--------------------|------------------|-----------|
| REQ-001 | UserService   | UserService.java   | TC-001, TC-003   | Yes       |
| REQ-002 | AuthMiddleware| auth.middleware.ts  | TC-002, TC-004   | Yes       |
```

## Phase Summary Template

At the end of the full workflow (or when the user stops early), produce a summary:

```
## Backend Team Workflow Summary

| Phase | Status | Execution | Key Decision / Output |
|---|---|---|---|
| 1. Requirements | Completed | Inline | X requirements defined, Y edge cases identified |
| 2. Architecture | Completed | Subagent | [Approach chosen] with [key trade-off] |
| 3. Implementation | Completed | Subagent | X files changed, Y new files created |
| 4. Code Review | Completed | Subagent (N cycles) | X critical, Y warnings, Z suggestions |
| 5a. Test Strategy | Completed | Subagent (QA Lead) | X test cases, Y quality gates |
| 5b. Test Implementation | Completed | Subagent (Test Engineer, parallel w/6) | X test files, Y tests passing |
| 5c. Quality Review | Completed | Subagent (QA Lead) | Quality [Approved/Rework] |
| 6. DevOps | Completed | Subagent (parallel w/5b) | [Deployment strategy] chosen |
| 7. Release | Completed | Subagent (parallel) | [Go/No-Go] — risk: [Low/Medium/High] |
| 8. Monitoring | Completed | Subagent (parallel) | X alerts defined, SLO: [target] |

[Traceability matrix here]
```
