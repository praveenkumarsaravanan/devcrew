---
name: eval
description: >
  Runs the DevCrew evaluation suite — scenario-based tests, LLM-as-judge scoring,
  and report generation. Use to validate that skills, agents, and workflows produce
  correct behavior before release.
---

# Eval

## Trigger

Activate this skill when:

- The user asks to "run evals," "evaluate DevCrew," "test the setup," or "validate the workflow."
- Before a release to verify nothing has regressed.
- After modifying skills, agents, or instructions to check for side effects.

Do NOT activate for:

- Testing application code — use the `testing` skill.
- Reviewing a PR — use the `code-review` skill.

## Overview

The eval suite lives in `evals/` and measures six dimensions:

| Dimension | What it tests | Scenarios |
|-----------|--------------|-----------|
| Right-sizing | Phase 0 classifies tasks correctly | RS-001 through RS-005 |
| Quality gates | Review phases catch planted bugs | QG-001 through QG-003 |
| Memory | Context and learnings persist across sessions | MEM-001 through MEM-003 |
| Governance | Risk classification triggers correct autonomy | GOV-001 through GOV-003 |
| Consistency | Same task produces similar results across runs | CON-001, CON-002 |
| Skill output | Individual skills produce correct, complete output | SO-001 through SO-013 |

## Execution Model — Subagent Isolation

**Every eval scenario runs in its own subagent.** The eval skill itself is the **orchestrator** — it reads scenarios, spawns execution agents, collects outputs, and scores. It never executes tasks directly.

This separation is critical:
- The orchestrator has access to expected values and scoring rubrics. If it also executed the task, it would bias the results.
- Subagents receive only the task description from the scenario. They do not see expected values, scoring criteria, or results from other scenarios.
- Each subagent starts with a clean context, simulating a real user session.

### Agent roles

| Role | What it does | Context it receives |
|------|-------------|-------------------|
| **Orchestrator** (this skill) | Reads scenarios, spawns agents, collects output, scores with judges, writes report | Full access to `evals/` |
| **Execution agent** | Performs the task using DevCrew skills/workflows | Task description only — no expected values, no rubric, no other scenario results |
| **Judge agent** | Scores the execution output against the rubric | Scenario input + execution output + judge prompt + rubric |

### Spawning execution agents

For every scenario, spawn a `generalPurpose` subagent using the appropriate handoff template below. The orchestrator selects the template based on the scenario's dimension.

#### Template A: Right-sizing / Governance (team-workflow scenarios)

```
Task: "You are an AI developer using DevCrew in this workspace.
      A user has asked you to perform the following task. Use the team-workflow
      skill to process it — start from Phase 0 (detection and classification).

      Do NOT read any files under evals/. Do NOT look for expected values.

      User request: <task description from scenario>

      Report back:
      1. Phase 0 classification (quick-fix / standard-change / full-feature)
      2. Risk level assigned (LOW / MEDIUM / HIGH)
      3. Which phases you activated and which you skipped
      4. The rationale for your classification and risk level
      5. Where human gates fired (if any)
      6. A summary of your output for each phase that ran"
```

#### Template B: Quality gates (code-review scenarios)

```
Task: "You are an AI code reviewer using DevCrew in this workspace.
      Review the following code file for security, quality, and standards compliance.
      Use the code-review skill.

      Do NOT read any files under evals/. Do NOT look for expected values.

      File to review: <fixture path>
      Context: <task description from scenario>

      Report back:
      1. Your overall verdict (APPROVE / REQUEST_CHANGES / REJECT)
      2. Every issue you found, with:
         - File and line number
         - Severity (CRITICAL / HIGH / MEDIUM / LOW)
         - Description of the issue
         - Suggested fix
      3. Any false positives you considered but decided not to flag
      4. Summary of what you checked"
```

#### Template C: Memory (persistence scenarios)

```
Task: "You are an AI developer using DevCrew in this workspace.
      Perform the following task. Pay attention to how you handle
      project context and memory files.

      Do NOT read any files under evals/. Do NOT look for expected values.

      User request: <task description from scenario>

      Report back:
      1. Did you find and load .project-context.md? What values did you read?
      2. Did you find and load .memory.md? What learnings did you reference?
      3. Did you re-ask the user for any information that was already stored?
      4. What new learnings (if any) did you write to .memory.md?
      5. Your full output for the task"
```

#### Template D: Skill output (individual skill scenarios)

```
Task: "You are an AI developer using DevCrew in this workspace.
      Perform the following task using the specified skill.

      Do NOT read any files under evals/. Do NOT look for expected values.

      Skill to use: <skill name from scenario>
      User request: <task description from scenario>
      Fixture file (if any): <fixture path or 'none'>

      Report back:
      1. The complete output you produced
      2. Any decisions you made and why
      3. Any files you created or modified (list paths and summarize content)
      4. Anything you chose NOT to include and why"
```

#### Template E: Consistency (multi-run scenarios)

```
Task: "You are an AI developer using DevCrew in this workspace.
      Perform the following task. This is a standalone request —
      do not reference any prior runs or results.

      Do NOT read any files under evals/. Do NOT look for expected values.

      User request: <task description from scenario>

      Report back:
      1. Your classification or primary decision
      2. Your full output
      3. Your rationale"
```

For consistency scenarios, spawn N agents using this template (one per run). Each agent must be independent.

### Spawning judge agents

After collecting the execution output, spawn a separate `generalPurpose` subagent for judging:

```
Task: "You are an evaluation judge. Your job is to objectively score an AI agent's
      output against a predefined rubric. Be strict — do not give credit for
      partially meeting a criterion unless the rubric explicitly allows it.

      ## Judge Instructions
      <full contents of evals/judges/<judge>.md>

      ## Scenario
      Task given to agent: <task description from scenario>
      Expected behavior: <expected section from scenario>
      Scoring criteria: <scoring section from scenario>

      ## Agent Output
      <complete output from execution agent>

      ## Instructions
      1. Score each criterion per the judge rubric.
      2. Compute the overall_score as defined in the judge prompt.
      3. Check for critical failure conditions.
      4. Compute the standard_metrics fields.
      5. Return ONLY the structured JSON score object — no commentary."
```

Set `run_in_background: false` so the orchestrator waits for completion.

### Parallelization

- **Within a dimension:** Scenarios MAY be run in parallel (spawn multiple execution agents concurrently) when they are independent.
- **Across dimensions:** Run dimensions sequentially (right-sizing → quality-gates → ...) so the orchestrator can detect critical failures early and stop.
- **Exception — Memory scenarios (MEM-*):** These require two separate sessions and cannot be fully automated in subagents. See Special Handling.

## Workflow

### Mode 1: Single scenario

When the user asks to run a specific scenario:

1. Read the scenario file from `evals/scenarios/<dimension>/<id>.md`.
2. Parse the frontmatter for `expected_classification`, `pass_threshold`, and `scoring`.
3. **Spawn an execution agent** with only the task description. Do NOT include expected values.
4. Collect the execution agent's output.
5. **Spawn a judge agent** with the judge prompt, scenario input, expected values, and execution output.
6. Report pass/fail with the score breakdown.

### Mode 2: Dimension sweep

When the user asks to evaluate a specific dimension (e.g., "eval right-sizing"):

1. List all scenarios in `evals/scenarios/<dimension>/`.
2. **Spawn an execution agent for each scenario** (can run in parallel within a dimension).
3. Collect all outputs.
4. **Spawn a judge agent for each scenario** with the corresponding judge and output.
5. Compute the dimension score as the average across scenarios.
6. Report the dimension score with per-scenario breakdown.

### Mode 3: Full suite

When the user asks to "run all evals" or "full evaluation":

1. Run all dimensions in order: right-sizing → quality-gates → memory → governance → consistency → skill-output.
2. For each dimension, **spawn execution agents for all scenarios** in that dimension.
3. After each dimension completes, **spawn judge agents** and score.
4. Check for critical failures after each dimension — if found, stop and report.
5. Compute standard metrics per dimension (see `evals/rubrics/metrics.md`):
   - Right-sizing: Accuracy, MAE
   - Quality gates: Precision, Recall, F1 (all + CRITICAL), AUC-ROC (if available)
   - Memory: Accuracy (value load)
   - Governance: Accuracy, F1 (HIGH risk), MAE
   - Consistency: Agreement rate, σ
   - Skill output: Criteria accuracy (criteria met / total)
6. Compute the aggregate score using the weights from `evals/rubrics/scoring.md`:
   ```
   Overall = (right_sizing × 0.15) + (quality_gates × 0.20) + (memory × 0.15) + (governance × 0.20) + (consistency × 0.10) + (skill_output × 0.20)
   ```
7. Determine Capability Level (CL-1 through CL-7) by checking each level's gate in order.
8. If a baseline exists, compute Regression Level (RL-0 through RL-4).
9. Fill in `evals/report-template.md` with all results including metric tables, CL, and RL.
10. Present the summary to the user.

### Mode 4: Before/after baseline

When the user asks to "compare with and without DevCrew":

1. Read `evals/baselines/measurement-protocol.md`.
2. Guide the user through the protocol step by step.
3. Record results in the report template.

### Mode 5: Regression check

When the user asks to "check for regressions" or "compare against baseline":

1. Load the previous report from `evals/reports/` (or ask the user for the baseline file).
2. Run the full suite (Mode 3).
3. Compare per-dimension scores and per-scenario scores against the baseline.
4. Classify the Regression Level per the protocol in `evals/rubrics/metrics.md`.
5. Report the RL with specific scenarios that regressed and the merge policy.

## Running a Scenario (Orchestrator Steps)

For each scenario, the orchestrator performs these steps. The orchestrator **never executes tasks itself**.

### Step 1: Setup

Read the scenario file. Parse frontmatter. Check if it requires fixtures (e.g., `fixture: fixtures/AuthService.java`). If so, ensure the fixture file is available in the workspace before spawning the execution agent.

### Step 2: Spawn execution agent

Spawn a `generalPurpose` subagent with:
- The task description from the scenario's `task` field
- The fixture file path (if applicable)
- An explicit instruction: "Do NOT read any files under evals/. Perform the task using DevCrew skills and report your output."

Do NOT include: expected values, scoring rubric, pass threshold, or any other scenario metadata.

### Step 3: Collect output

When the execution agent completes, collect:
- The Phase 0 classification (if applicable)
- Which phases were activated
- The key outputs (requirements, architecture, review findings, test plan, generated code, etc.)
- Any human gates that fired
- The full agent response

### Step 4: Spawn judge agent

Spawn a separate `generalPurpose` subagent with:
- The judge prompt from `evals/judges/<judge>.md`
- The scenario input (task description + expected values)
- The execution output from Step 3

The judge returns a structured JSON score.

### Step 5: Report

Map the judge score to pass/fail using the scenario's `pass_threshold`. Record in the report.

## Special Handling

### Multi-session scenarios (MEM-001, MEM-002)

Memory scenarios require two separate sessions. Even with subagent isolation, a subagent within the same parent session may inherit workspace state. Instead:

1. Spawn an execution agent for Session 1. Verify `.project-context.md` / `.memory.md` are created.
2. Instruct the user to start a **new chat session** (not a subagent).
3. In the new session, run Session 2 via the eval skill and score.

### Multi-run scenarios (CON-001, CON-002)

Consistency scenarios require multiple independent runs:

1. Spawn a **separate execution agent for each run** (e.g., 5 agents for 5 runs).
2. Each agent receives only the task — no prior results from other runs.
3. **Run agents in parallel** where possible for speed.
4. Collect classifications/outputs from all runs.
5. Spawn a judge agent to score agreement rate.

### Fixture-based scenarios (QG-001, QG-002, SO-007, SO-008)

These require code files to be present in the workspace:

1. Verify fixture files exist in `evals/fixtures/`.
2. Include the fixture file path in the execution agent's task prompt.
3. Clean up any temporary copies after scoring.

## Guardrails

- **Every scenario runs in a subagent.** The orchestrator never executes tasks itself. This is non-negotiable — it prevents answer leakage.
- **Execution agents must not access `evals/`.** The task prompt explicitly forbids reading scenario files, expected values, or scoring criteria.
- **Judge agents are separate from execution agents.** The agent that performed the task must not score its own output.
- **Never modify scenario files during evaluation.** Scenarios are the source of truth.
- **Never pass expected values to execution agents.** Read the expected values only after execution, for scoring.
- **Record all failures.** Do not skip or retry failed scenarios — failures are data.
- **Flag critical failures immediately.** If a quality gate approves code with SQL injection, stop the suite and report.
- **Parallelization within dimensions only.** Run scenarios within a dimension in parallel, but dimensions sequentially (to allow early stopping on critical failure).

## See Also

- `evals/README.md` — overview of the eval framework
- `evals/rubrics/scoring.md` — scoring criteria and thresholds
- `evals/report-template.md` — template for recording results
- `evals/baselines/measurement-protocol.md` — before/after comparison protocol
