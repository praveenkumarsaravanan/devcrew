---
name: team-workflow
description: >
  Orchestrates the pre-merge development lifecycle across backend, frontend, and
  fullstack disciplines — requirements, architecture, implementation, review, and
  testing. Uses discipline detection to dispatch the correct agents and checklists
  for each phase. Subagent isolation, structured handoff artifacts, adversarial
  prompting, and automatic re-routing simulate a cross-functional engineering team.
  Post-merge activities (DevOps, release, monitoring) are available as separate prompts.
---

# Team Workflow

## Trigger

Activate this skill when the user asks to build, fix, change, or improve code — regardless of task size. The workflow right-sizes itself automatically in Phase 0.

Examples:

- "Fix the null pointer in the login service" (quick fix)
- "Add input validation to the booking form" (standard change)
- "Build a new notification service" (full feature)
- "Implement the feature from ticket-123" (any size — Phase 0 determines)

Do NOT activate for tasks that have dedicated skills:

- "Review this PR" → `code-review`
- "Release a new version" → `git-release-tag`
- "Write tests for X" → `testing`
- "Debug this error" → `debugging`
- Infrastructure-only work → `devops-engineer` and `sre` agents directly

## Overview

This skill acts as a unified entry point for all development work. Instead of requiring developers to choose the right path, it assesses the task and right-sizes itself automatically. Key mechanics:

- **Scope sizing:** Phase 0 classifies the task as a **quick fix**, **standard change**, or **full feature**, then activates only the phases that add value for that size. Quick fixes skip straight to implementation; full features run the complete lifecycle.
- **Discipline dispatch:** Phase 0 also detects whether the work is backend, frontend, or fullstack, and routes each subsequent phase to the appropriate agents and checklists.
- **Human checkpoints:** Every phase pauses for user confirmation before advancing. The user may skip ahead, repeat a phase, or stop at any point.
- **Subagent isolation:** Phases 2, 4, and 5 spawn separate subagents (via the Task tool) so review and architecture happen in an independent context window, eliminating self-agreement bias.
- **Handoff artifacts:** Each phase produces a structured handoff document. The next phase receives only the handoff (not the full conversation history), keeping context tight.
- **Adversarial prompting:** Review phases (4 and 5) are explicitly adversarial — they assume the code has defects and actively look for them.
- **Automatic re-routing:** Critical findings in review phases trigger an automatic loop back to implementation. No manual "redo" needed.
- **Quality gates:** Each phase has concrete exit criteria that must be met before advancing.

Post-merge activities (DevOps readiness, release management, production monitoring) are **never automatic**. They are available as separate prompts (`/devops-plan`, `/release-readiness`, `/monitoring-plan`) that developers invoke when they choose to.

The user always retains full control:

- **Skip phases** — "skip to implementation" jumps past phases.
- **Repeat phases** — "redo the architecture phase" re-runs a phase with updated context.
- **Stop early** — "that's enough" or "stop here" ends the workflow at the current phase.
- **Override sizing** — "run the full workflow" forces all phases regardless of task size.

---

## Scope Sizing

Phase 0 classifies every task into one of three sizes. The size determines which phases run by default. The user can always override this.

### Size Definitions


| Size              | Signals                                                                                                 | Default Phases               |
| ----------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------- |
| **Quick fix**     | Bug fix, typo, config change, copy update, one-liner, "fix the X", no new files, no API changes         | 0 → 3 → 4 (lightweight)     |
| **Standard change** | Small feature addition, refactor, dependency update, 1–3 files, localized scope, clear implementation | 0 → 1 (light) → 3 → 4 → 5b |
| **Full feature**  | New service/component, multi-file, new API surface, architecture decisions, ticket epic, cross-cutting     | 0 → 1 → 2 → 3 → 4 → 5a → 5b |


### Phase Activation by Size


| Phase                    | Quick fix | Standard change | Full feature |
| ------------------------ | --------- | --------------- | ------------ |
| 0. Detection + Sizing    | **Yes**   | **Yes**         | **Yes**      |
| 1. Requirements          | Skip      | **Light** (brief scope, no edge case table) | **Full** |
| 2. Architecture          | Skip      | Skip            | **Yes**      |
| 3. Implementation        | **Yes**   | **Yes**         | **Yes**      |
| 4. Code Review           | **Lightweight** (inline, non-adversarial) | **Yes** | **Yes** |
| 5a. Test Strategy        | Skip      | Skip            | **Yes**      |
| 5b. Test Implementation  | Skip      | **Yes** (verify Phase 3 tests) | **Yes** |


### Lightweight Variants

**Phase 1 (Light):** Restate the task in 2–3 sentences. List what is in scope and out of scope. No REQ-IDs, no edge case table, no formal acceptance criteria. Confirm with user and proceed.

**Phase 4 (Lightweight):** Run inline (no subagent). Check the diff for obvious issues — security, error handling, naming. No adversarial stance. Present the result (clean or issues found) to the user for confirmation before proceeding.

---

## Discipline Dispatch

The workflow adapts to the discipline by selecting different agents and checklists in phases 2, 3, and 4. Phases 0, 1, and 5 are discipline-agnostic.

### Agent Dispatch Table

| Phase             | Backend                                                 | Frontend                                                 | Fullstack                                               |
| ----------------- | ------------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------- |
| 0. Detection      | `project-detection` (skill)                             | `project-detection` (skill)                              | `project-detection` (skill)                             |
| 1. Requirements   | `product-analyst`                                       | `product-analyst`                                        | `product-analyst`                                       |
| 2. Architecture   | `architect` (backend focus)                             | `architect` (frontend focus)                             | `architect` (both sections)                             |
| 3. Implementation | `junior-developer` + `senior-developer` (backend focus) | `junior-developer` + `senior-developer` (frontend focus) | `junior-developer` + `senior-developer` (both sections) |
| 4. Code Review    | `backend-reviewer`                                      | `frontend-reviewer`                                      | Both reviewers (sequentially)                           |
| 5a. Test Strategy | `qa-lead`                                               | `qa-lead`                                                | `qa-lead`                                               |
| 5b. Test Impl     | `test-engineer`                                         | `test-engineer`                                          | `test-engineer`                                         |

### Review Checklist Dispatch

| Discipline | Checklist References                                                 |
| ---------- | -------------------------------------------------------------------- |
| Backend    | [Security Scan Reference](references/security-scan-reference.md)     |
| Frontend   | [Frontend Review Checklist](references/frontend-review-checklist.md) |
| Fullstack  | Both checklists                                                      |


---

## Handoff Artifact Format

Every phase produces a handoff in this structure. The next phase receives ONLY this artifact plus the Phase 1 requirements — not the full conversation history.

```
### Phase [N] Handoff: [Phase Name]
**Discipline:** [backend | frontend | fullstack]
**Task size:** [quick-fix | standard-change | full-feature]
**Decision:** [One-sentence summary]
**Artifacts:** [List of deliverables]
**Constraints for next phase:** [What cannot change]
**Open questions:** [Unresolved items]
```

---

## Context Compression

At phase transitions, compress context by:

1. Producing the handoff artifact.
2. Summarizing the phase's work in 10–15 lines max.
3. Carrying forward only: (a) Phase 0 discipline + sizing, (b) Phase 1 requirements (if Phase 1 ran), (c) the preceding handoff, and (d) user checkpoint decisions.
4. Discarding intermediate reasoning, discarded options, and verbose explanations.

---

## Workflow

### Phase 0: Detection + Scope Sizing

**Role:** Project Detection (`project-detection`)

**Execution:** Inline (lightweight inspection, no subagent needed).

**Objective:** Determine (a) the discipline (backend, frontend, fullstack) and (b) the task size (quick fix, standard change, full feature) so the workflow activates only the phases that add value.

**Actions:**

1. **Load project context:**
   - Run the `memory-management` skill (Operation 1: Read Context) to check for `.project-context.md`.
   - If found, load stored platform configuration (tracker, execution mode, git platform) alongside discipline.
   - Run the `memory-management` skill (Operation 3: Read Memory) to load relevant `.memory.md` sections as context for the current task.

2. **Discipline detection:**
   - If the user stated the discipline explicitly, trust them.
   - If `.project-context.md` provided the discipline, confirm with a one-line summary.
   - Otherwise, run `project-detection` to classify by scanning root files, dependencies, and directory structure.
   - For fullstack projects, ask which layer the current task targets. If it spans both, set discipline to **fullstack**.

3. **Scope sizing — assess these signals:**
   - How many files will likely change? (1–2 = small; 3–5 = medium; 6+ = large)
   - Does the task introduce a new API surface, service, or component? (yes = larger)
   - Is there an architecture decision to make (new technology, new pattern, data model change)? (yes = full feature)
   - Does the user's description suggest a bug fix, config change, or copy update? (yes = quick fix)
   - Is there a ticket? If so, is it a bug, story, or epic? (bug = quick fix; story = standard; epic = full feature)

3. **Present the assessment and get confirmation.**
4. **Persist context (first run only):** If `.project-context.md` did not exist, call `memory-management` (Operation 2: Write Context) to persist all detected values.

**Output:**

```
**Discipline:** backend | frontend | fullstack
**Confidence:** High | Medium | Low
**Evidence:** [2-3 signals]

**Task size:** quick-fix | standard-change | full-feature
**Sizing rationale:** [1-2 sentences explaining why]
**Active phases:** [list of phases that will run]

**Platform:** tracker=[tracker] | execution=[mode] | git=[platform]
**Context source:** .project-context.md (persisted) | fresh detection
**Memory loaded:** [relevant domain sections, or "none"]
```

**Quality gate — do not advance until:**

- A discipline is confirmed (not "Unknown"). If Low confidence, ask the user.
- A task size is confirmed. The user may override: "I want the full workflow" or "just do a quick fix."
- The user has seen the active phases list and confirmed.

**Checkpoint:** "I've classified this as a **[size]** task on a **[discipline]** project. Here's the plan: [active phases]. Does that feel right, or would you like me to adjust?"

---

### Phase 1: Requirements Clarification

**Role:** Product Analyst (`product-analyst`)

**Execution:** Inline (no subagent needed).

**Objective:** Ensure the implementation is well-defined before any design or code. The depth of this phase adapts to the task size from Phase 0.

#### Full Feature (default)

1. Restate the user's request in concrete, engineering terms.
2. Decompose into discrete, testable requirements. Assign each an ID (REQ-001, REQ-002, ...) for traceability through subsequent phases.
3. For each requirement, write at least one acceptance criterion.
4. Identify edge cases, boundary conditions, and unstated assumptions.
5. List dependencies on external systems, teams, or data sources.
6. Define explicit scope: what is in, what is out.

**Quality gate (full feature):**

- Every requirement has an ID and at least one acceptance criterion
- Scope boundaries are explicitly stated (in/out)
- Edge cases table has at least 3 entries
- Dependencies are listed (or explicitly "none")

#### Standard Change (light variant)

1. Restate what the task does in 2–3 sentences.
2. State what is in scope and what is explicitly out of scope.
3. List any non-obvious risks or side effects.

No REQ-IDs, no edge case table, no formal acceptance criteria. This keeps the overhead proportional to the task.

#### Quick Fix

Phase 1 is skipped entirely. Proceed directly to Phase 3.

---

**Mid-workflow right-sizing checkpoint (standard change and full feature):**

After completing Phase 1, re-evaluate scope sizing. If the requirements reveal the task is simpler or more complex than Phase 0 estimated, propose a size adjustment (downgrade or upgrade) and get user confirmation before continuing. For quick fixes (Phase 1 skipped), the scope escalation checkpoint in Phase 3 serves this purpose instead.

---

**Handoff artifact:** Requirements document with numbered requirements, acceptance criteria, edge case table, scope boundaries, and dependency list (full feature) — or a brief scope statement (standard change). **For full features:** activate the `spec-templates` skill to produce a `.spec.md` file as the formal handoff artifact. This file becomes the contract between Phase 1 and all subsequent phases.

**Checkpoint:** Present the requirements to the user. Ask: "Do these requirements capture what you want to build? Any missing scenarios or scope changes?" Proceed only after confirmation.

---

### Phase 2: Architecture Review

**Role:** Architect (`architect`). **Runs for full features only.** If a standard change was upgraded to full feature via mid-workflow right-sizing, Phase 1 must be re-run in full mode (producing REQ-IDs) before Phase 2 begins — the light Phase 1 output is insufficient for architecture mapping.

**Execution:** **Subagent** — spawn with `subagent_type="architect"`. Pass Phase 0 discipline, Phase 1 handoff, and the user's original request.

**Prompt for subagent:** "You are the Architect agent. Discipline: **[discipline]**. Review these requirements and design an architecture using the architect agent definition. Produce an architecture decision with diagrams, trade-off analysis, and a recommendation. [Attach Phase 1 handoff]"

**Objective:** Design a solution that satisfies the requirements with sound trade-offs.

**Actions:**

1. Propose one or more architectural approaches. For each, state the trade-offs (scalability, complexity, cost, team familiarity).
2. Include a Mermaid diagram showing component interactions, data flows, or service boundaries.
3. Identify anti-patterns that the design avoids (or risks introducing) — use the discipline-specific anti-pattern list from the architect agent.
4. Flag technology choices and justify them against the criteria in the architect agent, including the discipline-specific criteria (backend: database/queue/cache; frontend: rendering strategy/state management/bundle size).
5. State what would change the recommendation (e.g., "if traffic exceeds X, switch to approach B").
6. Trace back to requirements: for each major component, note which REQ-IDs it satisfies.

**Quality gate — do not advance until:**

- At least one Mermaid diagram is included
- Trade-offs are analyzed for at least 2 approaches (unless the choice is obvious and justified)
- Every REQ-ID from Phase 1 maps to at least one component
- Anti-patterns are explicitly called out

**Handoff artifact:** Architecture decision with chosen approach, component diagram, technology choices, requirement-to-component mapping, and identified risks.

**Checkpoint:** Present the architecture to the user. Ask: "Does this design align with your constraints? Any concerns about the approach?" Proceed only after confirmation.

---

### Phase 3: Implementation

**Role:** Junior Developer (`junior-developer`) guided by Senior Developer (`senior-developer`)

**Execution strategy:** Determined by the `execution` value from Phase 0 (stored in `.project-context.md`):

| Mode | Behavior |
|------|----------|
| **`local`** (default) | Spawn a `generalPurpose` subagent in the current IDE session. This is the existing behavior. |
| **`background`** | Describe the implementation plan, then instruct the user to delegate to a Cursor Background Agent or Claude Code `--background` mode. Provide the full Phase 1 requirements and Phase 2 architecture as the background agent's prompt. |
| **`async`** | Run `/spec-to-issues` to decompose the spec into parallelizable tracker tasks. Each task can be assigned to an async agent (GitHub Coding Agent, Devin, etc.) or a team member. The workflow pauses here until tasks are completed. |
| **`manual`** | Produce a detailed implementation plan (files to create/modify, code patterns to follow, test expectations) and let the developer code it themselves. Skip to Phase 4 when the developer signals completion. |

For `local` mode (the default), proceed with the subagent-based implementation below. For other modes, produce the appropriate output and pause for user action.

**Subagent execution (local mode):** Spawn with `subagent_type="generalPurpose"`. Pass Phase 0 discipline, plus Phase 1 requirements and Phase 2 architecture handoffs (if those phases ran). Needs full tool access.

**Prompt for subagent:** "You are the Junior Developer guided by the Senior Developer. Discipline: **[discipline]**. Task size: **[size]**. Implement the changes following codebase patterns. Apply discipline-specific practices from both agent definitions. Handle error paths, validation, and cleanup. [Attach available handoffs from prior phases]"

**Objective:** Produce the code changes following codebase patterns and production-readiness standards.

**Actions:**

1. **Junior perspective:** Identify existing patterns in the codebase. Plan which files to create or modify. Implement the changes following established conventions.
2. **Senior perspective:** Review the implementation plan for scalability, performance, and backward compatibility concerns before writing code. Ensure rollout safety (feature flags, migration strategy).
3. Write the code, handling error paths, input validation, and resource cleanup.
4. **Backend:** Add structured logging for key operations.
5. **Frontend:** Implement accessible, responsive UI with design system tokens. Handle all async states (loading, error, empty).
6. Write tests alongside the implementation (not after). For quick fixes, tests are recommended but optional if the change is trivial (one-liner, config change).
7. **(Full feature only):** For each file changed, note which REQ-IDs it addresses.

**Scope escalation checkpoint (quick fix and standard change):** If during implementation the scope clearly exceeds the current sizing (new files needed, API changes, architecture decisions), pause and propose upgrading to a larger size before continuing.

**Quality gate — do not advance until:**

- All tests pass (if tests were written)
- No linter errors in changed files
- Error paths are handled (no bare catches, no swallowed errors)
- **(Full feature only):** Every REQ-ID from Phase 1 is addressed in at least one file
- **Frontend additional:** Semantic HTML used, keyboard navigation verified, design tokens applied

**Handoff artifact:** Summary of approach, list of files changed (with REQ-ID mapping for full features), assumptions made, and any deviations from the Phase 2 architecture if it ran (with justification).

**Checkpoint:** Present the implementation to the user. Ask: "Does this implementation match your expectations? Any changes before we move to review?" Proceed only after confirmation.

---

### Phase 4: Code Review

**Quick-fix variant:** No subagent. The orchestrating agent performs a brief inline review of the changed lines (correctness, regressions, style). If clean, proceed to end. If issues found, return to Phase 3.

**Standard-change and full-feature variant (below):**

**Role:** Dispatched by discipline:


| Discipline | Reviewer Agent               | Subagent Type             | Notes                                                                                                               |
| ---------- | ---------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Backend    | `backend-reviewer`           | `backend-reviewer`        | Registered subagent type — agent definition loaded automatically                                                    |
| Frontend   | `frontend-reviewer`          | `generalPurpose`          | No registered subagent type — the prompt must instruct the agent to follow the `frontend-reviewer` agent definition |
| Fullstack  | Both reviewers, sequentially | One subagent per reviewer |                                                                                                                     |


**Execution:** **Subagent** — spawn using the Task tool. The subagent must NOT have access to Phase 3 reasoning — it sees only the code and the architecture. This is the most critical isolation point.

**Prompt for subagent (backend):** "You are the Backend Reviewer. Review these changes adversarially — assume defects exist. Use security-scan-reference.md. [Attach Phase 3 handoff, Phase 2 handoff, changed files]"

**Prompt for subagent (frontend):** "You are the Frontend Reviewer. Review these changes adversarially — assume defects exist. Use frontend-review-checklist.md. [Attach Phase 3 handoff, Phase 2 handoff, changed files]"

**Fullstack:** Run both prompts sequentially. Merge findings.

**Adversarial stance (standard change and full feature only):**

The following does NOT apply to quick-fix lightweight reviews. For standard and full-feature reviews, the reviewer must:

- Assume at least 3 defects exist and actively search for them.
- Challenge every assumption in the implementation handoff.
- **(Full feature only):** Verify code matches Phase 2 architecture — flag unjustified deviations.
- Not approve on first pass unless genuinely flawless.

**Actions:**

1. Review every changed file against the reviewer's evaluation dimensions.
2. Categorize findings as Critical, Warning, or Suggestion.
3. For each finding, reference the file and location, explain why it matters, and provide a fix.
4. **(Full feature only):** Verify the implementation matches the Phase 2 architecture.
5. Produce a review summary with finding counts and an overall recommendation (Approve / Request Changes).

**Quality gate — do not advance until:**

- Zero Critical findings remain
- All Warning findings are either resolved or explicitly accepted by the user
- **(Full feature only):** Architecture conformance is verified against Phase 2

**Automatic re-routing:** If the review produces any Critical findings, automatically return to Phase 3 to fix them, then re-run Phase 4. Cap at **2 review cycles**. If Critical findings persist after 2 cycles, present them to the user for a decision.

**Handoff artifact:** Review findings with severity, resolution status, and final recommendation. Critical findings that were fixed should be listed as "Resolved in cycle N."

**Checkpoint:** If approved, inform the user and proceed. If requesting changes after 2 cycles, present unresolved findings and ask: "These critical issues remain after two review cycles. How would you like to proceed?"

---

### Phase 5: Quality Assurance

> **Phase 5 has two sub-phases (5a → 5b). The QA Lead designs the test strategy, then the Test Engineer implements tests, runs them, and reports results directly.**

#### Phase 5a: Test Strategy (QA Lead)

**Role:** QA Lead (`qa-lead`)

**Execution:** **Subagent** — spawn with `subagent_type="generalPurpose"` in read-only mode. Pass Phase 0 discipline, Phase 1 requirements, Phase 3 implementation, and Phase 4 review handoffs.

**Prompt for subagent:** "You are the QA Lead. Discipline: **[discipline]**. Design a test strategy adversarially — assume untested paths and hidden bugs exist. Produce a structured test plan with TC-IDs, priorities, expected results, test data requirements, and quality gates. Map every REQ-ID to at least one test case. [Attach Phase 1, Phase 3, Phase 4 handoffs]"

**Adversarial stance:** The QA Lead must:

- Assume every code path has an untested edge case.
- Challenge Phase 3 unit tests — are they testing behavior or just covering lines?
- Design tests that try to break the system, not confirm it works.
- Verify every REQ-ID maps to at least one test case.

**Actions:**

1. Design a layered test strategy appropriate to the discipline and change scope.
2. List specific test cases with ID (TC-001, ...), scenario, type, priority, expected result, and the REQ-ID it covers.
3. Identify boundary and negative test scenarios.
4. Define quality gates with pass/fail criteria.
5. Assess regression risk to existing functionality.
6. Specify test data requirements (fixtures, Testcontainers, mocked services).
7. **Assess Senior Developer review triggers:** Performance concerns? 3+ services touched? Known edge case history? New test infra needed? Complex UI interactions? If any trigger is met, present the test plan to the Senior Developer before proceeding.

**Quality gate — do not advance until:**

- Every REQ-ID from Phase 1 is covered by at least one test case
- At least 3 negative/boundary test cases are included
- Quality gates are defined with pass/fail criteria
- Regression risk is assessed (High/Medium/Low with justification)
- Senior Developer review completed (if triggers were met)

**Handoff artifact:** Test plan with test cases (including REQ-ID traceability), quality gates, test data requirements, regression risk assessment, and Senior Developer feedback (if applicable).

**Checkpoint:** Present the test plan to the user. Ask: "Does this test coverage feel sufficient? Any scenarios I should add?" Proceed only after confirmation.

---

#### Phase 5b: Test Implementation & Quality Verification (Test Engineer)

**Role:** Test Engineer (`test-engineer`)

**Execution:** **Subagent** — spawn with `subagent_type="generalPurpose"`. Pass Phase 0 discipline, Phase 3 implementation handoff, changed files list, and Phase 5a test plan (if Phase 5a ran). Needs full tool access. Must be a **separate subagent from Phase 3**.

**Prompt for subagent (full feature):** "You are the Test Engineer. Discipline: **[discipline]**. Implement the test cases from this test plan. Scan for existing test conventions. Run the full suite, verify coverage, report results. Flag application bugs — do not fix them. [Attach Phase 5a test plan, Phase 3 handoff, changed files]"

**Prompt for subagent (standard change):** "You are the Test Engineer. Discipline: **[discipline]**. Review and augment the tests from Phase 3. Verify key scenarios are covered (happy path, error paths, edge cases). Run the suite and report results. [Attach Phase 3 handoff, changed files]"

**Actions:**

1. Scan the codebase for test conventions (framework, location, naming, setup/teardown).
2. **(Full feature):** Implement every TC-ID from the QA Lead's test plan.
3. **(Standard change):** Review Phase 3 tests and add missing coverage.
4. Run the full test suite. Fix test-code failures. Flag application bugs.
5. Produce a test execution report with pass/fail counts, coverage metrics, and a quality verdict.

**Quality gate — do not advance until:**

- **(Full feature):** Every TC-ID from the test plan has a corresponding test file
- **(Standard change):** Changed code has test coverage for key scenarios (happy path, error paths)
- All tests pass (test bugs fixed, app bugs flagged)
- Test code follows project conventions (verified by scanning existing tests)
- Quality verdict is stated: Approved, or Needs Rework (with specific findings)

**Automatic re-routing:**


| Finding                                      | Action                                                                                             |
| -------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Test code quality issues or missing coverage | Re-implement the affected tests. Max 2 internal cycles before escalating to the user.              |
| Application bugs discovered                  | Flag in the handoff artifact. Route back to Phase 3 for fixes, then re-run Phase 5b. Max 2 cycles. |
| Untestable code                              | Flag in the handoff artifact and present to the user for a decision.                               |


**Handoff artifact:** Test files created (with TC-ID mapping), execution report, quality verdict, application bugs found, and any deviations from the plan.

**Checkpoint:** Present the test results and quality verdict to the user. Ask: "Tests are complete. Here are the results and any issues found. Ready to proceed with creating a PR, or would you like to address the findings first?"

---

### Post-Workflow: Capture Learnings

**After the workflow completes** (all phases done, or the user stops early), run the `memory-management` skill (Operation 4: Write Memory) to capture learnings:

1. Extract from the final handoff artifacts:
   - Architecture decisions made and their rationale
   - Patterns that worked well during implementation
   - Anti-patterns discovered during review
   - Test strategies that provided good coverage
2. Append entries to `.memory.md` under the appropriate domain sections.
3. Inform the user: "Learnings captured in `.memory.md`."

This step is automatic and lightweight — it should not require user interaction unless the learnings are ambiguous.

---

## Post-Merge Activities

Phases beyond code-review-and-test are **not part of this workflow**. They happen at different points in the delivery lifecycle and are available as explicit prompts:


| Activity                   | Prompt               | When to use                                                            |
| -------------------------- | -------------------- | ---------------------------------------------------------------------- |
| Deployment planning        | `/devops-plan`       | After merge, when setting up or updating CI/CD and deployment strategy |
| Release readiness          | `/release-readiness` | At release time, to run the go/no-go checklist                         |
| Monitoring & observability | `/monitoring-plan`   | When planning SLOs, alerts, and runbooks for a service                 |


These prompts leverage the `devops-engineer`, `release-manager`, and `sre` agents respectively.

---

## References

- [Workflow Reference](references/workflow-reference.md) — re-routing rules, requirement traceability matrix, and phase summary template
- [Security Scan Reference](references/security-scan-reference.md) — OWASP Top 10 checklist, dependency audit commands, CI posture checks, and industry-standard tooling (backend)
- [Frontend Review Checklist](references/frontend-review-checklist.md) — accessibility, performance, security, UX, and CSS review checklists (frontend)

## Guardrails

- **Right-size, don't one-size.** Use the scope sizing from Phase 0 to skip phases that add no value. Running a full architecture review for a typo fix wastes the developer's time and erodes trust.
- **Always run Phase 0.** Discipline detection and scope sizing are mandatory for every task. If the user skips Phase 0 by stating the discipline and size, trust them.
- **Quick fixes still get a sanity check.** Even when Phase 1 and 2 are skipped, Phase 4 (lightweight code review) runs inline to catch obvious issues. The only way to skip review entirely is an explicit user override.
- **Always checkpoint between phases.** Never proceed from one phase to the next without presenting the output and getting user confirmation. The user may have context that changes the approach.
- **Re-evaluate sizing after Phase 1.** If Phase 1 reveals the task is bigger or smaller than Phase 0 estimated, propose a size adjustment and get confirmation before continuing.
- **Post-merge is always opt-in.** Never chain into `/devops-plan`, `/release-readiness`, or `/monitoring-plan` automatically. Mention them as available options at the end of the workflow and let the developer decide.
- **Use subagents for review phases.** Phases 2, 4 (full), and 5 should be spawned as separate subagents whenever the Task tool is available. Phase 4 (lightweight) runs inline.
- **Handoff artifacts are the contract.** Never pass raw conversation history between phases. The handoff artifact is the only input the next phase receives (plus the Phase 1 requirements and Phase 0 discipline/sizing).
- **Respect re-routing caps.** Automatic re-routing loops are capped at 2 cycles. After 2 failed cycles, escalate to the user — do not loop indefinitely.
- **Keep each phase focused.** Do not let the architecture phase drift into implementation details, or the test phase into deployment concerns. Each phase has a clear scope.
- **Respect the user's pace.** If the user wants to stop at Phase 3 and come back later, produce a partial summary and note where to resume.
- **Cite the agent by name when switching roles.** At the start of each phase, state which role you are adopting (e.g., "Switching to the **Product Analyst** perspective for Phase 1"). This makes role transitions visible.
- **Dispatch correctly by discipline.** Use the Agent Dispatch Table to select the right agent for each phase. For fullstack, run both discipline-specific steps (e.g., both reviewers in Phase 4).
- **Trace requirements end-to-end (full feature only).** In full-feature mode, every phase must reference REQ-IDs. If a requirement has no corresponding component, code, or test, flag it as a gap. Standard changes and quick fixes do not use REQ-IDs.
- **Do not bundle post-merge activities.** DevOps, release, and monitoring are separate concerns with their own timing. Point the user to the `/devops-plan`, `/release-readiness`, and `/monitoring-plan` prompts when appropriate.

## See Also

- **`pull-request`** — After the workflow, create the PR with ticket validation and test plan checks.
- **`commit-message`** — Ensures commit messages pass the commitlint hook during Phase 3.
- **`branch-creation`** — Create a branch with org naming conventions before starting.
- **`code-review`** — Standalone reviews outside the workflow (e.g., reviewing someone else's PR).
- **`testing`** — Standalone test writing outside the workflow (e.g., backfilling tests).
- **`eval`** — If the workflow modified `.apm/` primitives (skills, agents, instructions, prompts, hooks), suggest running the relevant eval scenarios to verify no regressions. See `apm-authoring` skill for the eval-after-change protocol.

