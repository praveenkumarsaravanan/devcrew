# DevCrew Evaluation Suite

Structured evaluation framework for measuring whether DevCrew's AI engineering team works as designed.

## What We're Measuring

| Dimension | Claim | Pass criteria |
|-----------|-------|---------------|
| **Right-sizing** | Phase 0 classifies task size correctly | Matches expected classification in ≥80% of runs |
| **Quality gates** | Review phases catch real defects | Catches ≥70% of planted issues, zero false approvals on critical bugs |
| **Memory** | Context persists and loads across sessions | Session 2 loads Session 1's values without re-asking |
| **Governance** | Risk classification triggers correct autonomy | Auth changes → high risk, docs → low risk, 100% accuracy on critical path |
| **Consistency** | Same task produces similar results across runs | Classification matches in ≥90% of runs, output quality σ < 1.0 on rubric |
| **Contracts** | External and cross-team contracts preserve compatibility | Breaking changes require versioning, deprecation, migration, tests, and observability |
| **Regulated data** | Sensitive data is classified and protected | Raw sensitive data is not logged or used in fixtures; audit and retention are required |
| **Release evidence** | Medium/high-risk release decisions are evidence-backed | Missing rollback, security, IaC, data, contract, or monitoring evidence blocks readiness |
| **Skill output** | Individual skills produce correct, complete output | Criteria accuracy ≥ 0.70 across 13 skill-specific scenarios (SO-001 through SO-013) |
| **Advisor mode** | Responses challenge flawed premises and confirm sound ones without sycophancy or manufactured contrarianism | Correct direction on 100% of scenarios; zero sycophancy on flawed premises and zero manufactured disagreement on sound ones |
| **Triage** | Triage finds the true root cause via disciplined investigation (artifact-first, whole-function read, data-lifecycle tracing) — not symptom-anchored or red-herring guesses | Correct root cause with traced data lifecycle; zero confident-wrong diagnoses and zero red-herring root causes |

## Evaluation Tiers

### Tier 1: Scenario-Based (evals/scenarios/)

Predefined tasks with expected outcomes. Each scenario is a Markdown file with YAML frontmatter containing:
- `task` — the prompt to give the agent
- `expected` — what the correct behavior looks like
- `scoring` — how to measure pass/fail

Run scenarios by reading the file and executing the task through DevCrew, then scoring against the rubric.

### Tier 2: LLM-as-Judge (evals/judges/)

Judge prompts that a separate model uses to score DevCrew's output. Each judge evaluates a specific dimension (classification accuracy, review quality, requirements completeness, memory accuracy).

Feed the judge the scenario input + DevCrew's output + the rubric. The judge returns a structured score.

### Tier 3: Before/After Comparison (evals/baselines/)

Protocol for measuring the same tasks with and without DevCrew. Captures time, quality, and consistency deltas.

## Directory Structure

```
evals/
  scenarios/
    right-sizing/          # Phase 0 classification scenarios
    quality-gates/         # Review phase catch-rate scenarios
    memory/                # Persistence across sessions
    governance/            # Risk classification accuracy
    consistency/           # Multi-run stability
    contracts/             # Contract compatibility scenarios
    regulated-data/        # Sensitive data handling scenarios
    release-evidence/      # Delivery readiness evidence scenarios
    advisor-mode/          # Challenge-vs-confirm calibration (no sycophancy or contrarianism)
    triage/                # Root-cause discipline — data-lifecycle tracing, no red-herring guesses
    skill-output/          # Individual skill correctness (SO-001 through SO-013)
  judges/                  # LLM-as-judge prompt templates
  rubrics/                 # Scoring criteria and standard metrics
  baselines/               # Before/after comparison protocol
  fixtures/                # Sample code for quality-gate and standards scenarios
  report-template.md       # Template for recording eval results
```

## Running Evals

### Individual scenario

```
Read the scenario file, execute the task described in `task`, then score the output using the rubric in `scoring`.
```

### Full suite via the eval skill

```
Activate the `eval` skill: "Run the DevCrew eval suite"
```

The skill orchestrates all scenarios, applies judges, and produces a scored report.

### Before/after baseline

Follow the protocol in `evals/baselines/measurement-protocol.md` with a real project.

## Metrics

Beyond the 0–5 rubric scores, the suite computes standard ML evaluation metrics.
See `evals/rubrics/metrics.md` for formal definitions:

| Metric | Primary dimensions |
|--------|--------------------|
| Accuracy | Right-sizing, Memory, Governance, Skill output |
| Precision / Recall / F1 | Quality gates, Governance |
| MAE | Right-sizing, Governance |
| AUC-ROC | Quality gates (optional, when confidence scores available) |
| Agreement rate / σ | Consistency |

### Capability Levels (CL-1 through CL-6)

Tiered gates that measure what DevCrew can reliably do. CL-7 (Full Orchestration) requires all six dimensions to pass simultaneously.

### Regression Levels (RL-0 through RL-4)

Compare each new eval run against a baseline to detect score degradation (RL-1), threshold breaches (RL-2), capability loss (RL-3), or critical regressions (RL-4). RL-3 and RL-4 block merges.

## Interpreting Results

| Score | Rating | Action |
|-------|--------|--------|
| ≥90% | Strong | Ship with confidence |
| 70–89% | Acceptable | Investigate failures, may need skill tuning |
| 50–69% | Weak | Significant gaps — review failing scenarios and fix underlying skills |
| <50% | Failing | Fundamental issues — reassess skill design |
