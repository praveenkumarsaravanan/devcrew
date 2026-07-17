---
name: team-workflow
description: >
  Implements DevCrew Engineering Flow, the right-sized pre-merge development
  lifecycle across backend, frontend, and fullstack disciplines — requirements,
  architecture, implementation, review, and testing. Uses discipline detection,
  Council Chair routing, and council depth to dispatch the correct agents and
  checklists for each phase. Post-merge activities (DevOps, release, monitoring)
  are available as separate prompts.
---

# DevCrew Engineering Flow

## Trigger

Activate this skill when the user asks to build, fix, change, or improve code — regardless of task size. The user-facing command is `/engineering-flow`; this skill remains the internal implementation id for compatibility. Engineering Flow right-sizes itself automatically in Phase 0.

Examples:

- "Fix the null pointer in the login service" (quick fix)
- "Add input validation to the booking form" (standard change)
- "Build a new notification service" (full feature)
- "/engineering-flow --deep design retry handling for this worker" (deep council mode)
- "Implement the feature from ticket-123" (any size — Phase 0 determines)

Do NOT activate for tasks that have dedicated skills:

- "Review this PR" → `code-review`
- "Release a new version" → `git-release-tag`
- "Write tests for X" → `testing`
- "Debug this error" → `debugging`
- Infrastructure-only work → `devops-engineer` and `sre` agents directly

## Overview

DevCrew Engineering Flow acts as a unified entry point for development work. Instead of requiring developers to choose the right path, it assesses the task and right-sizes itself automatically. Key mechanics:

- **Scope sizing:** Phase 0 classifies the task as a **quick fix**, **standard change**, or **full feature**, then activates only the phases that add value for that size. Quick fixes skip straight to implementation; full features run the complete lifecycle.
- **Council Chair:** Phase 0 opens with the right level of council guidance: a one-line Chair note for quick fixes, a concise Council Brief for standard/full work, or deep council option review for high-risk or ambiguous work.
- **Discipline dispatch:** Phase 0 also detects whether the work is backend, frontend, or fullstack, and routes each subsequent phase to the appropriate agents and checklists.
- **Council routing:** Councils are phase-aligned groups of existing agents and instructions. They explain who is active and why; they do not replace the existing phases.
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
- **Override council depth** — "run deep council" or `/engineering-flow --deep` requests deeper option review before implementation.

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

## Council Depth

Phase 0 also classifies council depth. Council depth controls how much visible deliberation the Council Chair adds before implementation.

| Depth | Default use | Behavior |
|---|---|---|
| **Light** | Quick fixes | One-line Chair note. No formal decision artifact. |
| **Standard** | Standard changes and most full features | Concise Council Brief, active/skipped councils, compact decision notes. |
| **Deep** | Explicit request, high-risk work, ambiguity, or architecture-heavy decisions | 2-3 options, trade-off matrix, recommendation, and user checkpoint before implementation. |

Default depth:

```text
quick-fix -> light
standard-change -> standard
full-feature -> standard
full-feature + medium/high risk -> deep or strongly suggest deep
explicit --deep/deep council request -> deep
```

Use [Council Routing Reference](references/council-routing.md) for council-to-agent mapping, deep mode triggers, and decision artifact format.

### Council Anti-Overkill Rules

- Quick fixes get a one-line Chair note only.
- Standard changes get a concise Council Brief; do not emit the full decision artifact unless a real decision is being made.
- Deep mode is for explicit requests, high-risk work, ambiguous requirements, or architecture/data/security/IaC trade-offs.
- Delivery and Operations councils are optional unless release, deployment, rollback, monitoring, or runtime risk is explicit.

---

## Discipline Dispatch

Engineering Flow adapts to the discipline and stack by selecting different agents and checklists in phases 2, 3, and 4. Phases 0, 1, and 5 are discipline-agnostic, but Phase 5 uses stack-specific testing guidance when available.

### Agent Dispatch Table

| Phase             | Backend                                                 | Frontend                                                 | Fullstack                                               |
| ----------------- | ------------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------- |
| 0. Detection      | `project-detection` (skill)                             | `project-detection` (skill)                              | `project-detection` (skill)                             |
| 1. Requirements   | `product-analyst`                                       | `product-analyst`                                        | `product-analyst`                                       |
| 2. Architecture   | `architect` (backend focus)                             | `architect` (frontend focus)                             | `architect` (both sections)                             |
| 3. Implementation | `junior-developer` + `senior-developer` (backend focus, plus stack standards) | `junior-developer` + `senior-developer` (frontend focus) | `junior-developer` + `senior-developer` (both sections, plus stack standards) |
| 4. Code Review    | `backend-reviewer`; add `typescript-node-reviewer` for Node backend changes | `frontend-reviewer`                                      | Run applicable reviewers sequentially                   |
| 5a. Test Strategy | `qa-lead`                                               | `qa-lead`                                                | `qa-lead`                                               |
| 5b. Test Impl     | `test-engineer`                                         | `test-engineer`                                          | `test-engineer`                                         |

### Stack Standards Dispatch

| Stack signal | Activate |
|---|---|
| Java/Spring backend | `java-standards` |
| TypeScript/Node backend, API route, worker, queue consumer, or scheduled job | `typescript-node-standards` |
| React frontend | `react-standards` |
| AWS application resources, serverless config, AWS SDK usage, or AWS IaC | `aws-application-development` |
| Terraform/OpenTofu, CDK, CloudFormation, Pulumi, SAM, Helm, or Kubernetes manifests | `infrastructure-as-code` |
| Dockerfile, Containerfile, Packer, AMI, or image pipeline | `image-build` |
| Data feed, ingestion pipeline, mapping, replay/backfill, reconciliation, or feed runbook | `data-ingestion`, `data-mapping-validation`, and `operational-feed-runbook` as applicable |
| OpenAPI, AsyncAPI, webhook, event, protobuf, GraphQL, SDK, partner API, or file/feed contract | `interoperability-contracts` |
| FHIR, HL7 Implementation Guide, StructureDefinition, CapabilityStatement, SMART on FHIR, or clinical API exchange | `fhir-health-interop`, `interoperability-contracts`, and `regulated-data-handling` as applicable |
| Sensitive or regulated data, PII, PHI, payment data, redaction, synthetic data, audit, retention, or sensitive export | `regulated-data-handling` |

### Review Checklist Dispatch

| Discipline | Checklist References                                                 |
| ---------- | -------------------------------------------------------------------- |
| Backend    | [Security Scan Reference](references/security-scan-reference.md); add `typescript-node-standards` for Node backends |
| Frontend   | [Frontend Review Checklist](references/frontend-review-checklist.md) |
| Fullstack  | Applicable backend stack checks plus frontend checklist              |


---

## Handoff Artifact Format

Every phase produces a handoff in this structure. The next phase receives ONLY this artifact plus the Phase 1 requirements — not the full conversation history.

```
### Phase [N] Handoff: [Phase Name]
**Discipline:** [backend | frontend | fullstack]
**Task size:** [quick-fix | standard-change | full-feature]
**Risk:** [low | medium | high]
**Council depth:** [light | standard | deep]
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
3. Carrying forward only: (a) Phase 0 discipline, sizing, risk, and council depth, (b) Phase 1 requirements (if Phase 1 ran), (c) the preceding handoff, and (d) user checkpoint decisions.
4. Discarding intermediate reasoning, discarded options, and verbose explanations.

---

## Workflow

### Phase 0: Detection + Scope Sizing

**Role:** Project Detection (`project-detection`) with Council Chair coordination (`council-chair`)

**Execution:** Inline (lightweight inspection, no subagent needed).

**Objective:** Determine (a) the discipline (backend, frontend, fullstack), (b) the task size (quick fix, standard change, full feature), (c) risk (low, medium, high), and (d) council depth (light, standard, deep) so Engineering Flow activates only the phases and councils that add value.

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

4. **Risk classification — assess these signals:**
   - **Low:** docs, tests, linting, small UI copy, formatting, local config.
   - **Medium:** business logic, API behavior, state management, retry behavior, data mapping, non-sensitive persistence.
   - **High:** auth, encryption, PII/sensitive data, payments, deletion, IAM, infrastructure, migration, backfill, rollback, or production blast radius.
   - If uncertain, classify higher and explain why.

5. **Council depth — apply the defaults from the Council Depth section:**
   - Quick fix defaults to `light`.
   - Standard change defaults to `standard`.
   - Full feature defaults to `standard`.
   - Full feature with medium/high risk, or any explicit `--deep`/deep council request, uses or strongly suggests `deep`.
   - If the user requests deep mode for a trivial quick fix, explain why light mode is safer and ask before expanding.

6. **Council routing:**
   - Use [Council Routing Reference](references/council-routing.md) to choose active and skipped councils.
   - Activate Delivery or Operations councils only when release, deployment, rollback, monitoring, SLO, or runtime risk is explicit.

7. **Present the assessment and get confirmation.**
8. **Persist context (first run only):** If `.project-context.md` did not exist, call `memory-management` (Operation 2: Write Context) to persist all detected values.

**Output:**

```
**Discipline:** backend | frontend | fullstack
**Confidence:** High | Medium | Low
**Evidence:** [2-3 signals]

**Task size:** quick-fix | standard-change | full-feature
**Sizing rationale:** [1-2 sentences explaining why]
**Risk:** low | medium | high
**Risk rationale:** [1-2 sentences explaining why]
**Council depth:** light | standard | deep
**Council rationale:** [why this depth is appropriate]
**Active phases:** [list of phases that will run]
**Active councils:** [Product | Architecture | Implementation | Review | Quality | Delivery | Operations | Governance]
**Skipped councils:** [councils skipped and brief reason]
**Trade-offs to watch:** [compact list, or "none"]

**Platform:** tracker=[tracker] | execution=[mode] | git=[platform]
**Context source:** .project-context.md (persisted) | fresh detection
**Memory loaded:** [relevant domain sections, or "none"]
```

For quick fixes, compress the council output to a one-line Chair note:

```
**Chair note:** Quick fix, [risk] risk, light council depth. Proceeding to implementation and lightweight review; no formal council artifact needed because [reason].
```

**Quality gate — do not advance until:**

- A discipline is confirmed (not "Unknown"). If Low confidence, ask the user.
- A task size is confirmed. The user may override: "I want the full workflow" or "just do a quick fix."
- Risk and council depth are stated.
- The user has seen the active phases list and confirmed.
- The user has seen the active/skipped councils for standard/full work.

**Checkpoint:** "I've classified this as a **[size]** task on a **[discipline]** project with **[risk]** risk and **[council depth]** council depth. Here's the plan: [active phases]. Active councils: [active councils]. Does that feel right, or would you like me to adjust?"

---

### Phase 1: Requirements Clarification

**Role:** Product Analyst (`product-analyst`). Quick fixes skip this phase. Standard changes use the light variant. Full features produce numbered requirements, acceptance criteria, edge cases, scope boundaries, and dependencies.

**Handoff:** Requirements artifact or brief scope statement. For full features, activate `spec-templates` to produce the formal `.spec.md` handoff.

**Checkpoint:** Confirm requirements before design or implementation. Re-evaluate task size if requirements reveal the task is smaller or larger than Phase 0 estimated.

---

### Deep Council Option Review

**Runs when:** Council depth is `deep`.

**Role:** Council Chair coordinating the relevant councils. Use Architect for full-feature architecture decisions. For standard changes, run option review inline unless complexity requires upgrading the task.

**Required output:** 2-3 options, compact trade-off matrix, recommendation, risks accepted/rejected, user approval needed, and next council or phase. Use [Council Routing Reference](references/council-routing.md) for the decision artifact.

**Checkpoint:** Do not advance until the user approves the recommended path. Do not run this for true quick fixes unless the user confirms the extra ceremony.

---

### Phase 2: Architecture Review

**Role:** Architect (`architect`). Runs for full features only.

**Execution:** Subagent with Phase 0 discipline, Phase 1 handoff, and the original request.

**Required output:** Options considered, recommendation, Mermaid diagram, technology choices, requirement-to-component mapping, anti-patterns avoided, risks, and revisit criteria.

**Quality gate:** Diagram included, trade-offs analyzed, every REQ-ID maps to a component, and anti-patterns are called out.

**Checkpoint:** Confirm the design before implementation.

---

### Phase 3: Implementation

**Role:** Junior Developer (`junior-developer`) guided by Senior Developer (`senior-developer`).

**Execution strategy:** Use the Phase 0 `execution` value: `local`, `background`, `async`, or `manual`. Local mode spawns a `generalPurpose` implementation subagent with available handoffs. Non-local modes produce the appropriate delegation or manual implementation plan and pause.

**Required behavior:** Follow existing codebase patterns, handle error paths, apply discipline- and stack-specific standards, write or verify tests proportional to scope, and map full-feature changes to REQ-IDs. For TypeScript/Node backend work, activate `typescript-node-standards`.

**Quality gate:** Tests pass if written, changed files have no lint errors, error paths are handled, and full-feature REQ-IDs are addressed.

**Checkpoint:** Present implementation summary and changed files before review.

---

### Phase 4: Code Review

**Quick-fix variant:** Inline lightweight review of changed lines. If clean, finish. If issues are found, return to Phase 3.

**Standard/full variant:** Spawn discipline-specific reviewer subagents. Backend uses `backend-reviewer`; Node backend changes also use `typescript-node-reviewer`. AWS application or infrastructure changes also use `aws-platform-reviewer`. IaC or image-build changes also use `infrastructure-reviewer`. Data feed, mapping, replay/backfill, or reconciliation changes use `data-platform-reviewer`. OpenAPI, AsyncAPI, webhook, event, protobuf, GraphQL, SDK, partner API, or file/feed contract changes use `interoperability-reviewer`. Sensitive or regulated data changes use `regulated-data-reviewer`. Frontend uses `frontend-reviewer`; fullstack runs applicable reviewers sequentially.

**Required behavior:** Review adversarially, inspect every changed file, categorize findings, verify architecture conformance for full features, and produce Approve or Request Changes.

**Quality gate:** Zero Critical findings remain. Warnings are resolved or explicitly accepted by the user. Critical findings route back to Phase 3 and re-run review, capped at 2 cycles.

**Checkpoint:** Present unresolved findings or approval before continuing.

---

### Phase 5: Quality Assurance

**Phase 5a - Test Strategy:** Full features spawn QA Lead (`qa-lead`) to produce TC-IDs, priorities, expected results, negative/boundary cases, quality gates, regression risk, and test data needs.

**Phase 5b - Test Implementation:** Standard changes and full features spawn Test Engineer (`test-engineer`) in a separate context from Phase 3. It scans test conventions, augments or implements tests, runs the suite, fixes test-code failures, and flags application bugs.

**Quality gate:** Full-feature REQ-IDs map to tests, standard changes cover key scenarios, all tests pass unless application bugs are routed back to Phase 3, and the quality verdict is explicit.

**Checkpoint:** Present test results and ask whether to proceed to PR work or address findings.

Detailed phase prompts, quality gates, and re-routing behavior live in [Phase Execution Reference](references/phase-execution-reference.md).

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

Phases beyond code-review-and-test are **not part of pre-merge Engineering Flow**. They happen at different points in the delivery lifecycle and are available as explicit prompts:


| Activity                   | Prompt               | When to use                                                            |
| -------------------------- | -------------------- | ---------------------------------------------------------------------- |
| Deployment planning        | `/devops-plan`       | After merge, when setting up or updating CI/CD and deployment strategy |
| Release readiness          | `/release-readiness` | At release time, to run the go/no-go checklist                         |
| Monitoring & observability | `/monitoring-plan`   | When planning SLOs, alerts, and runbooks for a service                 |


These prompts leverage the `devops-engineer`, `release-manager`, and `sre` agents respectively.

---

## References

- [Council Routing Reference](references/council-routing.md) — council depth, active/skipped councils, deep mode triggers, and decision artifact format
- [Phase Execution Reference](references/phase-execution-reference.md) — detailed subagent prompts, quality gates, and phase-specific execution checks
- [Workflow Reference](references/workflow-reference.md) — re-routing rules, requirement traceability matrix, and phase summary template
- [Security Scan Reference](references/security-scan-reference.md) — OWASP Top 10 checklist, dependency audit commands, CI posture checks, and industry-standard tooling (backend)
- [Frontend Review Checklist](references/frontend-review-checklist.md) — accessibility, performance, security, UX, and CSS review checklists (frontend)

## Guardrails

- **Right-size, don't one-size.** Use the scope sizing from Phase 0 to skip phases that add no value. Running a full architecture review for a typo fix wastes the developer's time and erodes trust.
- **Right-size the council too.** Quick fixes get a one-line Chair note. Standard changes get a concise Council Brief. Deep council is for explicit requests, high-risk work, ambiguity, or meaningful trade-offs.
- **Always run Phase 0.** Discipline detection and scope sizing are mandatory for every task. If the user skips Phase 0 by stating the discipline and size, trust them.
- **Always state risk and council depth.** Phase 0 must show risk and council depth before advancing.
- **Quick fixes still get a sanity check.** Even when Phase 1 and 2 are skipped, Phase 4 (lightweight code review) runs inline to catch obvious issues. The only way to skip review entirely is an explicit user override.
- **Always checkpoint between phases.** Never proceed from one phase to the next without presenting the output and getting user confirmation. The user may have context that changes the approach.
- **Re-evaluate sizing after Phase 1.** If Phase 1 reveals the task is bigger or smaller than Phase 0 estimated, propose a size adjustment and get confirmation before continuing.
- **Post-merge is always opt-in.** Never chain into `/devops-plan`, `/release-readiness`, or `/monitoring-plan` automatically. Mention them as available options at the end of the workflow and let the developer decide.
- **Use subagents for review phases.** Phases 2, 4 (full), and 5 should be spawned as separate subagents whenever the Task tool is available. Phase 4 (lightweight) runs inline.
- **Handoff artifacts are the contract.** Never pass raw conversation history between phases. The handoff artifact is the only input the next phase receives (plus Phase 1 requirements and Phase 0 discipline, sizing, risk, and council depth).
- **Respect re-routing caps.** Automatic re-routing loops are capped at 2 cycles. After 2 failed cycles, escalate to the user — do not loop indefinitely.
- **Keep each phase focused.** Do not let the architecture phase drift into implementation details, or the test phase into deployment concerns. Each phase has a clear scope.
- **Respect the user's pace.** If the user wants to stop at Phase 3 and come back later, produce a partial summary and note where to resume.
- **Cite the agent by name when switching roles.** At the start of each phase, state which role you are adopting (e.g., "Switching to the **Product Analyst** perspective for Phase 1"). This makes role transitions visible.
- **Dispatch correctly by discipline.** Use the Agent Dispatch Table to select the right agent for each phase. For fullstack, run both discipline-specific steps (e.g., both reviewers in Phase 4).
- **Trace requirements end-to-end (full feature only).** In full-feature mode, every phase must reference REQ-IDs. If a requirement has no corresponding component, code, or test, flag it as a gap. Standard changes and quick fixes do not use REQ-IDs.
- **Do not bundle post-merge activities.** DevOps, release, and monitoring are separate concerns with their own timing. Point the user to the `/devops-plan`, `/release-readiness`, and `/monitoring-plan` prompts when appropriate.
- **Council Chair coordinates only.** The Council Chair explains routing and decisions but does not replace Product Analyst, Architect, Developer, Reviewer, QA, Delivery, Operations, or Governance responsibilities.

## See Also

- **`pull-request`** — After the workflow, create the PR with ticket validation and test plan checks.
- **`council-chair`** — Coordinates Engineering Flow council routing and decision visibility.
- **`typescript-node-standards`** — Stack-specific standards for Node APIs, workers, jobs, runtime validation, logging, and idempotency.
- **`aws-application-development`** — Platform-specific standards for AWS IAM, encryption, event flows, observability, cost, and quotas.
- **`infrastructure-as-code`** — IaC standards for state, plan review, drift detection, secrets, parity, and rollback.
- **`image-build`** — Image and AMI standards for scanning, baked-secret prevention, provenance, and immutable promotion.
- **`data-ingestion`** — Data feed standards for source contracts, validation, quarantine, idempotency, replay, reconciliation, and runbooks.
- **`interoperability-contracts`** — Contract standards for OpenAPI, AsyncAPI, webhooks, events, protobuf, GraphQL, SDKs, file/feed contracts, compatibility, versioning, and contract tests.
- **`regulated-data-handling`** — Regulated data standards for classification, redaction, synthetic data, audit events, retention, and safe operational visibility.
- **`commit-message`** — Ensures commit messages pass the commitlint hook during Phase 3.
- **`branch-creation`** — Create a branch with org naming conventions before starting.
- **`code-review`** — Standalone reviews outside the workflow (e.g., reviewing someone else's PR).
- **`testing`** — Standalone test writing outside the workflow (e.g., backfilling tests).
- **`eval`** — If the workflow modified `.apm/` primitives (skills, agents, instructions, prompts, hooks), suggest running the relevant eval scenarios to verify no regressions. See `apm-authoring` skill for the eval-after-change protocol.
