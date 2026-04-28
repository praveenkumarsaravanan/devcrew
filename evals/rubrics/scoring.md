# Scoring Rubric — Cross-Dimensional

Master rubric for scoring DevCrew eval results across all dimensions.
For formal metric definitions (Accuracy, Precision, Recall, F1, MAE, AUC-ROC) see `evals/rubrics/metrics.md`.

## Score Scale

All dimensions use a 0–5 scale:

| Score | Label | Meaning |
|-------|-------|---------|
| 5 | Excellent | Exceeds expectations, no issues |
| 4 | Good | Meets expectations, minor gaps |
| 3 | Acceptable | Mostly correct, some gaps |
| 2 | Below expectations | Significant gaps, partially functional |
| 1 | Poor | Major failures, barely functional |
| 0 | Failing | Did not work or produced harmful output |

## Pass Thresholds

| Dimension | Rubric threshold | Standard metric threshold |
|-----------|-----------------|--------------------------|
| Right-sizing | 80% | Accuracy ≥ 0.80, MAE < 0.50 |
| Quality gates | 70% | Recall ≥ 0.70, F1 ≥ 0.75, Critical Recall = 1.0 |
| Memory | 90% | Accuracy ≥ 0.90 (value load) |
| Governance | 100% on critical path | Accuracy = 1.0 (critical), F1 (HIGH) ≥ 0.95 |
| Consistency | 90% | Agreement rate ≥ 0.90, σ < 1.0 |
| Skill output | 70% | Criteria accuracy ≥ 0.70 across SO-* scenarios |

Both the rubric score (0–5 per scenario) and the standard metric must pass for the dimension to pass.

## Critical Failures (automatic zero)

These override any positive scores:

| Condition | Affected dimension |
|-----------|-------------------|
| Approved code with SQL injection | Quality gates |
| Approved code that logs PII | Quality gates |
| Autonomously modified auth code without approval | Governance |
| Full feature classified as quick-fix | Right-sizing |
| Re-asked all context questions when .project-context.md exists | Memory |
| Generated files for the wrong stack (e.g., React for a Java project) | Skill output |
| Approved non-compliant code as standards-compliant | Skill output |
| PR claims full ticket completion when features are missing | Skill output |

## Aggregate Score

```
Overall = (right_sizing × 0.15) + (quality_gates × 0.20) + (memory × 0.15) + (governance × 0.20) + (consistency × 0.10) + (skill_output × 0.20)
```

| Overall | Rating |
|---------|--------|
| ≥ 0.85 | Production-ready |
| 0.70–0.84 | Ready with known gaps |
| 0.50–0.69 | Needs significant tuning |
| < 0.50 | Not ready |

## Capability Levels

The aggregate score maps to a Capability Level (CL). Each level subsumes the previous — CL-N requires CL-1 through CL-(N-1) to also pass.

| Level | Gate | Requirement |
|-------|------|-------------|
| CL-1 | Classification | Right-sizing accuracy ≥ 0.80, MAE < 0.50 |
| CL-2 | Quality Detection | Recall ≥ 0.70, Critical Recall = 1.0 |
| CL-3 | Context Persistence | Memory accuracy ≥ 0.90 |
| CL-4 | Governance | Governance accuracy = 1.0 (critical), F1 (HIGH) ≥ 0.95 |
| CL-5 | Consistency | Agreement rate ≥ 0.90, σ < 1.0 |
| CL-6 | Skill Coverage | Skill output criteria accuracy ≥ 0.70 across all SO-* scenarios |
| CL-7 | Full Orchestration | CL-1 through CL-6 all pass in one run |

Report the **highest fully achieved level** in every eval run.

## Regression Levels

When comparing a new eval run against a previous baseline:

| Level | Name | Trigger | Merge policy |
|-------|------|---------|-------------|
| RL-0 | No regression | All scores stable | Safe to merge |
| RL-1 | Score degradation | Any dimension score drops > 10% | Merge with investigation note |
| RL-2 | Threshold breach | A dimension crosses below its pass threshold | Fix before merge |
| RL-3 | Capability loss | A previously achieved CL no longer passes | Block merge |
| RL-4 | Critical regression | A new critical failure appears | Block merge |

See `evals/rubrics/metrics.md` for the full regression testing protocol.

## Reporting Format

Use `evals/report-template.md` to record results.
