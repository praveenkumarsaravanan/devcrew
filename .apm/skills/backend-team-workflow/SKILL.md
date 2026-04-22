---
name: backend-team-workflow
description: >
  Orchestrates a full backend development lifecycle by guiding the agent through
  sequential team phases — requirements, architecture, implementation, review,
  quality assurance (QA Lead + Test Engineer), DevOps, release, and monitoring. Uses
  subagent isolation, structured handoff artifacts, adversarial prompting, and
  automatic re-routing to simulate a real cross-functional backend team.
---

# Backend Team Workflow

## Trigger

Activate this skill when the user:

- Explicitly asks to build a backend service, implement an API, or develop a backend component
- Says "run the backend team workflow" or "run through the backend phases"
- Provides a feature spec or JIRA ticket and the `project-detection` skill classifies the project as **Backend**

**When the project type is ambiguous:** Run the `project-detection` skill first. Proceed with this workflow only if the result is Backend or if the user explicitly confirms backend scope. For fullstack projects, ask which layer the current task targets.

Do NOT activate for:
- Frontend, UI, or client-side work (a future `frontend-team-workflow` will cover those)
- Projects classified as Infrastructure by `project-detection` (use `devops-engineer` and `sre` agents directly)
- Isolated tasks like "review this PR" (use `code-review`), "release a new version" (use `release`), or "write tests for X" (invoke `test-engineer` directly)

## Overview

This skill simulates a cross-functional backend engineering team by running 8 phases. Key mechanics:

- **Subagent isolation:** Phases 2, 4, and 5 spawn separate subagents (via the Task tool) so review and architecture happen in an independent context window, eliminating self-agreement bias.
- **Handoff artifacts:** Each phase produces a structured handoff document. The next phase receives only the handoff (not the full conversation history), keeping context tight.
- **Adversarial prompting:** Review phases (4 and 5) are explicitly adversarial — they assume the code has defects and actively look for them.
- **Automatic re-routing:** Critical findings in review phases trigger an automatic loop back to implementation. No manual "redo" needed.
- **Parallel execution:** Independent phases (5+6 and 7+8) run in parallel via concurrent subagents.
- **Quality gates:** Each phase has concrete exit criteria that must be met before advancing.

The user may:
- **Skip phases** — "skip DevOps" or "skip to implementation" jumps past phases.
- **Repeat phases** — "redo the architecture phase" re-runs a phase with updated context.
- **Stop early** — "that's enough" or "stop here" ends the workflow at the current phase.

---

## Handoff Artifact Format

Every phase ends by producing a handoff artifact in this structure. The next phase receives ONLY this artifact plus the original requirements (Phase 1 handoff), not the full conversation history.

```
### Phase [N] Handoff: [Phase Name]

**Decision:** [One-sentence summary of the key decision or output]

**Artifacts:**
- [List of concrete deliverables: documents, diagrams, code files, test cases]

**Constraints for next phase:**
- [What the next phase must respect or cannot change]

**Open questions:**
- [Anything unresolved that the next phase should address]
```

When entering a new phase, start by reading the handoff artifact from the previous phase. Do not rely on conversation history — the handoff is the contract.

---

## Context Compression

At the transition between phases, compress the conversation context:

1. Produce the handoff artifact (see format above).
2. Summarize the current phase's work in 10–15 lines maximum.
3. Carry forward only: (a) the Phase 1 requirements handoff, (b) the immediately preceding phase's handoff, and (c) any user decisions made at checkpoints.
4. Do not carry forward intermediate reasoning, discarded options, or verbose explanations from earlier phases.

This keeps the agent sharp in later phases. Without compression, Phase 7–8 quality degrades as the context window fills with stale information.

---

## Workflow

### Phase 1: Requirements Clarification

**Role:** Product Analyst (`product-analyst`)

**Execution:** Inline (no subagent needed — this is the starting phase with no prior bias to isolate from).

**Objective:** Ensure the implementation is well-defined before any design or code.

**Actions:**
1. Restate the user's request in concrete, engineering terms.
2. Decompose into discrete, testable requirements. Assign each an ID (REQ-001, REQ-002, ...) for traceability through subsequent phases.
3. For each requirement, write at least one acceptance criterion.
4. Identify edge cases, boundary conditions, and unstated assumptions.
5. List dependencies on external systems, teams, or data sources.
6. Define explicit scope: what is in, what is out.

**Quality gate — do not advance until:**
- [ ] Every requirement has an ID and at least one acceptance criterion
- [ ] Scope boundaries are explicitly stated (in/out)
- [ ] Edge cases table has at least 3 entries
- [ ] Dependencies are listed (or explicitly "none")

**Handoff artifact:** Requirements document with numbered requirements, acceptance criteria, edge case table, scope boundaries, and dependency list. This artifact is referenced by every subsequent phase.

**Checkpoint:** Present the requirements to the user. Ask: "Do these requirements capture what you want to build? Any missing scenarios or scope changes?" Proceed only after confirmation.

---

### Phase 2: Architecture Review

**Role:** Architect (`architect`)

**Execution:** **Subagent** — spawn a separate subagent using the Task tool with `subagent_type="architect"`. Pass it the Phase 1 handoff artifact and the user's original request. This ensures the architecture review is independent from any implementation assumptions.

**Prompt for subagent:**
> You are the Architect agent. Review the following requirements and design a backend architecture. Follow the architect agent definition. Produce an architecture decision with diagrams, trade-off analysis, and a recommendation. [Attach Phase 1 handoff artifact]

**Objective:** Design a backend solution that satisfies the requirements with sound trade-offs.

**Actions:**
1. Propose one or more architectural approaches. For each, state the trade-offs (scalability, complexity, cost, team familiarity).
2. Include a Mermaid diagram showing component interactions, data flows, or service boundaries.
3. Identify anti-patterns that the design avoids (or risks introducing).
4. Flag technology choices and justify them against the criteria in the architect agent.
5. State what would change the recommendation (e.g., "if traffic exceeds X, switch to approach B").
6. Trace back to requirements: for each major component, note which REQ-IDs it satisfies.

**Quality gate — do not advance until:**
- [ ] At least one Mermaid diagram is included
- [ ] Trade-offs are analyzed for at least 2 approaches (unless the choice is obvious and justified)
- [ ] Every REQ-ID from Phase 1 maps to at least one component
- [ ] Anti-patterns are explicitly called out

**Handoff artifact:** Architecture decision with chosen approach, component diagram, technology choices, requirement-to-component mapping, and identified risks.

**Checkpoint:** Present the architecture to the user. Ask: "Does this design align with your constraints? Any concerns about the approach?" Proceed only after confirmation.

---

### Phase 3: Implementation

**Role:** Junior Developer (`junior-developer`) guided by Senior Developer (`senior-developer`)

**Execution:** **Subagent** — spawn using the Task tool with `subagent_type="generalPurpose"`. Pass it the Phase 1 requirements handoff and Phase 2 architecture handoff. The implementation subagent needs full tool access (file read/write, terminal) to write and test code. This isolation ensures the implementation context is separate from the review phases that follow.

**Prompt for subagent:**
> You are the Junior Developer agent guided by the Senior Developer agent. Implement the backend changes following the architecture decision and requirements provided. Follow existing codebase patterns. Write unit tests alongside the code. Handle error paths, input validation, and resource cleanup. Add structured logging for key operations. [Attach Phase 1 and Phase 2 handoffs]

**Objective:** Produce the backend code changes following codebase patterns and production-readiness standards.

**Actions:**
1. **Junior perspective:** Identify existing patterns in the codebase. Plan which files to create or modify. Implement the changes following established conventions.
2. **Senior perspective:** Review the implementation plan for scalability, performance, and backward compatibility concerns before writing code. Ensure rollout safety (feature flags, migration strategy).
3. Write the code, handling error paths, input validation, and resource cleanup.
4. Add structured logging for key operations.
5. Write unit tests alongside the implementation (not after).
6. For each file changed, note which REQ-IDs it addresses.

**Quality gate — do not advance until:**
- [ ] All unit tests pass
- [ ] No linter errors in changed files
- [ ] Error paths are handled (no bare catches, no swallowed errors)
- [ ] Every REQ-ID from Phase 1 is addressed in at least one file

**Handoff artifact:** Summary of approach, list of files changed with REQ-ID mapping, assumptions made, and any deviations from the Phase 2 architecture (with justification).

**Checkpoint:** Present the implementation to the user. Ask: "Does this implementation match your expectations? Any changes before we move to review?" Proceed only after confirmation.

---

### Phase 4: Code Review

**Role:** Backend Reviewer (`backend-reviewer`)

**Execution:** **Subagent** — spawn a separate subagent using the Task tool with `subagent_type="backend-reviewer"`. Pass it the Phase 3 handoff artifact, the list of changed files, and the Phase 2 architecture handoff. The subagent must NOT have access to the Phase 3 reasoning or conversation — it sees only the code and the architecture it should conform to. This is the most critical isolation point: the reviewer must not be biased by having written the code.

**Prompt for subagent:**
> You are the Backend Reviewer agent. Review the following code changes for quality, security, and adherence to the architecture. Your job is adversarial — assume the code has defects and find them. Do not give the benefit of the doubt. [Attach Phase 3 handoff, Phase 2 handoff, and list of changed files]

**Adversarial stance:** This phase is explicitly adversarial. The reviewer must:
- **Assume at least 3 defects exist** and actively search for them.
- **Challenge every assumption** made in the implementation handoff.
- **Verify** that the code matches the architecture from Phase 2 — flag any deviations not justified in the handoff.
- **Not approve on first pass** unless the code is genuinely flawless. Err on the side of requesting changes.

**Actions:**
1. Review every changed file against the backend reviewer's evaluation dimensions: error handling, security, performance, test coverage, naming.
2. Categorize findings as Critical, Warning, or Suggestion.
3. For each finding, reference the specific file and location, explain why it matters, and provide a concrete fix.
4. Verify the implementation matches the Phase 2 architecture. Flag undocumented deviations.
5. Produce a review summary with finding counts and an overall recommendation (Approve / Request Changes).

**Quality gate — do not advance until:**
- [ ] Zero Critical findings remain
- [ ] All Warning findings are either resolved or explicitly accepted by the user
- [ ] Architecture conformance is verified

**Automatic re-routing:** If the review produces any Critical findings, automatically return to Phase 3 to fix them, then re-run Phase 4. Cap at **2 review cycles**. If Critical findings persist after 2 cycles, present them to the user for a decision.

**Handoff artifact:** Review findings with severity, resolution status, and final recommendation. Critical findings that were fixed should be listed as "Resolved in cycle N."

**Checkpoint:** If approved, inform the user and proceed. If requesting changes after 2 cycles, present unresolved findings and ask: "These critical issues remain after two review cycles. How would you like to proceed?"

---

### Phase 5: Quality Assurance + Phase 6: DevOps Readiness

> **Phase 5 has three sub-phases (5a → 5b → 5c). Phase 6 runs in parallel with Phase 5b (test implementation) since the deployment plan and test code are independent.**

#### Phase 5a: Test Strategy (QA Lead)

**Role:** QA Lead (`qa-lead`)

**Execution:** **Subagent** — spawn using the Task tool with `subagent_type="generalPurpose"` in read-only mode. Pass it the Phase 1 requirements handoff, Phase 3 implementation handoff, and Phase 4 review handoff.

**Prompt for subagent:**
> You are the QA Lead agent. Design a comprehensive test strategy for the following backend implementation. Your job is adversarial — assume the implementation has untested paths, hidden bugs, and missing edge cases. Identify them. Produce a structured test plan with test cases (TC-IDs), priorities, expected results, test data requirements, and quality gates. Map every REQ-ID to at least one test case. Assess whether the Senior Developer should review this plan before implementation. [Attach Phase 1, Phase 3, and Phase 4 handoffs]

**Adversarial stance:** The QA Lead must:
- **Assume every code path has an untested edge case** and design test cases to expose them.
- **Challenge the unit tests** written in Phase 3 — are they testing behavior or just covering lines?
- **Design tests that try to break the system**, not confirm it works.
- **Verify requirement coverage** — every REQ-ID must map to at least one test case.

**Actions:**
1. Design a layered test strategy (unit gaps, integration, contract, backend E2E, performance) appropriate to the change.
2. List specific test cases with ID (TC-001, ...), scenario, type, priority, expected result, and the REQ-ID it covers.
3. Identify boundary and negative test scenarios.
4. Define quality gates with pass/fail criteria.
5. Assess regression risk to existing functionality.
6. Specify test data requirements (fixtures, Testcontainers, mocked services).
7. **Assess Senior Developer review triggers:**
   - Phase 3 handoff flagged performance concerns? → Trigger
   - Change touches 3+ services or data stores? → Trigger
   - Domain logic has known edge case history? → Trigger
   - New test infrastructure needed? → Trigger
   - Uncertain about coverage adequacy? → Trigger

**Conditional Senior Developer Review:** If any trigger is met, present the test plan to the Senior Developer (`senior-developer`) before proceeding. Ask: "Does this test plan cover the critical paths? Any domain-specific scenarios or performance concerns I should add?" Incorporate feedback into the plan.

**Quality gate — do not advance until:**
- [ ] Every REQ-ID from Phase 1 is covered by at least one test case
- [ ] At least 3 negative/boundary test cases are included
- [ ] Quality gates are defined with pass/fail criteria
- [ ] Regression risk is assessed (High/Medium/Low with justification)
- [ ] Senior Developer review completed (if triggers were met)

**Handoff artifact:** Test plan with test cases (including REQ-ID traceability), quality gates, test data requirements, regression risk assessment, and Senior Developer feedback (if applicable).

**Checkpoint:** Present the test plan to the user. Ask: "Does this test coverage feel sufficient? Any scenarios I should add?" Proceed only after confirmation.

---

#### Phase 5b: Test Implementation (Test Engineer) + Phase 6: DevOps Readiness (Parallel)

> **Phase 5b and Phase 6 run in parallel.** The Test Engineer implements tests from the QA Lead's plan while the DevOps Engineer designs the deployment strategy. Spawn both as concurrent subagents.

##### Phase 5b: Test Implementation

**Role:** Test Engineer (`test-engineer`)

**Execution:** **Subagent** — spawn using the Task tool with `subagent_type="generalPurpose"`. Pass it the Phase 5a test plan handoff, Phase 3 implementation handoff, and the list of changed files. The Test Engineer subagent needs full tool access (file read/write, terminal) to write and run test code. This must be a **separate subagent from Phase 3** — the test author has no shared context with the code author.

**Prompt for subagent:**
> You are the Test Engineer agent. Implement the test cases from the following test plan as executable test code. Scan the codebase for existing test conventions and follow them exactly. Write integration tests, contract tests, and backend E2E tests. Run the full suite and report results. Flag application bugs — do not fix them. [Attach Phase 5a test plan handoff, Phase 3 handoff, and list of changed files]

**Actions:**
1. Scan the codebase for test conventions (framework, file location, naming, setup/teardown, assertion style).
2. Implement every TC-ID from the QA Lead's test plan as executable test code:
   - Integration tests with real dependencies (Testcontainers or project's existing test infra)
   - Contract tests validating API schemas and response formats
   - Backend E2E tests orchestrating multi-step business workflows through API calls
   - Build reusable test factories, builders, and helpers when patterns repeat
3. Run the full test suite. Fix test-code failures. Flag application bugs as findings.
4. Produce a test execution report with pass/fail counts, coverage metrics, and TC-ID to test file mapping.

**Quality gate — do not advance until:**
- [ ] Every TC-ID from the test plan has a corresponding test file
- [ ] All tests pass (test bugs fixed, app bugs flagged)
- [ ] Test code follows project conventions (verified by scanning existing tests)

**Handoff artifact:** Test files created (with TC-ID mapping), execution report, application bugs found, and any deviations from the plan.

---

##### Phase 6: DevOps Readiness

**Role:** DevOps Engineer (`devops-engineer`)

**Execution:** **Subagent** — spawn concurrently with Phase 5b. Pass it the Phase 2 architecture handoff and Phase 3 implementation handoff.

**Prompt for subagent:**
> You are the DevOps Engineer agent. Design the deployment strategy and infrastructure plan for the following backend implementation. [Attach Phase 2 and Phase 3 handoffs]

**Actions:**
1. Recommend the deployment strategy (rolling, canary, blue-green, feature flag) with justification.
2. Identify infrastructure changes required (new services, database changes, config updates).
3. Define or update CI/CD pipeline stages for the change.
4. Verify health checks, resource limits, and autoscaling configuration.
5. Assess environment impact across dev, staging, and production.

**Quality gate — do not advance until:**
- [ ] Deployment strategy is chosen with justification
- [ ] Rollback mechanism is defined
- [ ] Health check endpoints are specified
- [ ] Infrastructure changes are listed (or explicitly "none")

**Handoff artifact:** Deployment plan with strategy, infrastructure changes, pipeline updates, and rollback mechanism.

---

#### Phase 5c: Quality Review & Go/No-Go (QA Lead)

**Role:** QA Lead (`qa-lead`)

**Execution:** **Subagent** — spawn after Phase 5b and Phase 6 complete. Pass it the Phase 5a test plan, Phase 5b execution report and test files, and Phase 6 DevOps handoff.

**Prompt for subagent:**
> You are the QA Lead agent. Review the Test Engineer's test implementation against your test plan. Verify coverage, test quality, and execution results. Make the quality go/no-go decision. [Attach Phase 5a test plan, Phase 5b execution report, test files]

**Actions:**
1. **Coverage check:** Map every TC-ID from the plan to a test file. Flag any missing test cases.
2. **Quality check:** Review test code for anti-patterns (implementation testing, weak assertions, flaky patterns, mock-heavy tests).
3. **Execution validation:** Verify all tests pass. Classify any failures as test bugs or application bugs.
4. **Gap analysis:** Identify scenarios the Test Engineer discovered during implementation that should be added to the plan.
5. **Make the quality decision:**

| Decision | When | Action |
|---|---|---|
| **Quality Approved** | All quality gates pass, coverage sufficient, no critical gaps | Proceed to Phase 7 |
| **Tests Need Rework** | Test code has quality issues, missing coverage, or flaky tests | Route back to Test Engineer (Phase 5b) with specific findings. Max 2 cycles. |
| **Code Needs Rework** | Tests reveal application bugs or untestable code | Route back to Phase 3 with findings. Max 2 cycles. |

**Quality gate — do not advance until:**
- [ ] Every TC-ID has a passing test
- [ ] Zero test quality issues rated Critical
- [ ] Application bugs are either fixed (routed to Phase 3) or accepted by the user
- [ ] Quality verdict is stated with rationale

**Handoff artifact:** Quality verdict with evidence — coverage report (TC-ID to test file mapping), test quality findings, execution summary, and go/no-go recommendation.

**Combined Checkpoint (Phase 5 + 6):** Present the quality verdict and the DevOps plan together. Ask: "Here are the quality assessment and deployment plan. Any adjustments before we assess release readiness?"

---

### Phase 7: Release Readiness + Phase 8: Production Monitoring (Parallel)

> **These two phases run in parallel.** The release checklist and the monitoring plan are independent assessments. Spawn both as concurrent subagents and present results together.

#### Phase 7: Release Readiness

**Role:** Release Manager (`release-manager`)

**Execution:** **Subagent** — spawn using the Task tool. Pass it handoff artifacts from Phases 1, 4, 5, and 6.

**Prompt for subagent:**
> You are the Release Manager agent. Assess release readiness for the following backend implementation. You have the requirements, code review results, test plan, and deployment plan. Make a go/no-go recommendation. [Attach Phase 1, Phase 4, Phase 5, and Phase 6 handoffs]

**Actions:**
1. Run through the release readiness checklist: code complete, tests passing, security scan, performance, documentation, rollback plan, on-call coverage.
2. Assess risk using the risk matrix (scope, blast radius, reversibility, test coverage).
3. Document the rollback procedure with exact steps and estimated time.
4. Define communication plan: who to notify before, during, and after.
5. Make a go/no-go recommendation with rationale.

**Quality gate — do not advance until:**
- [ ] Every checklist item is assessed (pass/fail/N/A)
- [ ] Risk rating is assigned (Low/Medium/High) with justification
- [ ] Rollback procedure has exact steps and estimated duration
- [ ] Go/no-go recommendation is stated with rationale

**Handoff artifact:** Release assessment with readiness checklist, risk rating, rollback plan, and go/no-go recommendation.

---

#### Phase 8: Production Monitoring

**Role:** SRE (`sre`)

**Execution:** **Subagent** — spawn concurrently with Phase 7. Pass it handoff artifacts from Phases 2, 3, and 5.

**Prompt for subagent:**
> You are the SRE agent. Design the observability and monitoring plan for the following backend implementation. Assess customer impact and incident readiness. [Attach Phase 2, Phase 3, and Phase 5 handoffs]

**Actions:**
1. Verify observability coverage: metrics, logs, and traces are instrumented for the new code paths.
2. Propose or verify SLOs/SLIs for the affected service.
3. Define alerts for the new functionality with tier, condition, and runbook outline.
4. Assess customer impact: which user flows are affected, blast radius, degraded-mode options.
5. Verify incident readiness: can the team detect, diagnose, and recover within the error budget?

**Quality gate — do not advance until:**
- [ ] At least one SLO/SLI is proposed for the affected service
- [ ] Alerts are defined with clear conditions and severity tiers
- [ ] Customer impact is assessed with blast radius estimate
- [ ] Runbook outline exists for the most likely failure modes

**Handoff artifact:** Observability assessment, SLO recommendations, alert plan, and customer impact analysis.

---

**Combined Checkpoint (Phase 7 + 8):** Present both the release assessment and the monitoring plan together. Inform the user the workflow is complete and produce the final summary.

---

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

---

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

---

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

## Guardrails

- **Never skip the requirements phase silently.** If the user says "just build it," still produce a brief requirements summary and confirm before coding. Misunderstood requirements waste more time than the 2 minutes spent clarifying.
- **Always checkpoint between phases.** Never proceed from one phase to the next without presenting the output and getting user confirmation. The user may have context that changes the approach.
- **Use subagents for review phases.** Phases 2, 4, 5, 6, 7, and 8 should be spawned as separate subagents whenever the Task tool is available. If subagents are unavailable (e.g., in a non-Cursor environment), fall back to inline execution with explicit adversarial instructions.
- **Handoff artifacts are the contract.** Never pass raw conversation history between phases. The handoff artifact is the only input the next phase receives (plus the Phase 1 requirements).
- **Respect re-routing caps.** Automatic re-routing loops are capped at 2 cycles. After 2 failed cycles, escalate to the user — do not loop indefinitely.
- **Apply all phases' perspectives, not just the comfortable ones.** The value of this workflow is comprehensive coverage. Skipping security, testing, or monitoring review defeats the purpose.
- **Keep each phase focused.** Do not let the architecture phase drift into implementation details, or the test phase into DevOps concerns. Each phase has a clear scope.
- **Respect the user's pace.** If the user wants to stop at Phase 3 and come back later, produce a partial summary and note where to resume.
- **Cite the agent by name when switching roles.** At the start of each phase, state which role you are adopting (e.g., "Switching to the **Product Analyst** perspective for Phase 1"). This makes role transitions visible.
- **Stay within backend scope.** If the user's request involves frontend, mobile, or other non-backend work, note that this workflow covers the backend portion only and suggest addressing the other disciplines separately.
- **Trace requirements end-to-end.** Every phase must reference REQ-IDs. If a requirement has no corresponding component, code, test, or monitoring, flag it as a gap.
