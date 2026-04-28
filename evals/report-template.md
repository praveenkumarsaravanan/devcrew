# DevCrew Eval Report

**Date:** YYYY-MM-DD
**Evaluator:** [name]
**DevCrew version:** v1.5.1
**AI model:** [model name and version]
**IDE:** [Cursor / Copilot / Claude Code]
**Baseline version:** [version this run is compared against, or "N/A — first run"]

---

## Tier 1: Scenario Results

### Right-Sizing

| Scenario | Expected | Actual | Phases correct | Score |
|----------|----------|--------|---------------|-------|
| RS-001 Null pointer | quick-fix | | | /5 |
| RS-002 Validation | standard-change | | | /5 |
| RS-003 Notification service | full-feature | | | /5 |
| RS-004 Typo fix | quick-fix | | | /5 |
| RS-005 REST endpoint | standard-change | | | /5 |

**Dimension score:** /25 → **%**

#### Standard Metrics

| Metric | Value | Target | Pass |
|--------|-------|--------|------|
| Accuracy | /5 correct | ≥ 0.80 | [ ] |
| MAE | | < 0.50 | [ ] |

### Quality Gates

| Scenario | Bugs planted | Bugs caught | False positives | Critical missed | Score |
|----------|-------------|-------------|----------------|----------------|-------|
| QG-001 AuthService | 6 | | | | /5 |
| QG-002 PaymentForm | 5 | | | | /5 |
| QG-003 Missing tests | N/A | | | | /5 |

**Dimension score:** /15 → **%**
**Critical failures:** [ ] None [ ] See notes

#### Standard Metrics

| Metric | Value | Target | Pass |
|--------|-------|--------|------|
| Precision | | — (report) | — |
| Recall (all bugs) | | ≥ 0.70 | [ ] |
| Recall (CRITICAL) | | = 1.0 | [ ] |
| F1 (all bugs) | | ≥ 0.75 | [ ] |
| F1 (CRITICAL) | | ≥ 0.90 | [ ] |
| AUC-ROC | | — (if available) | — |

### Memory

| Scenario | Context persisted | Context loaded | Learnings captured | Score |
|----------|------------------|---------------|-------------------|-------|
| MEM-001 Context persistence | | | N/A | /5 |
| MEM-002 Learning capture | N/A | | | /5 |
| MEM-003 Rotation | N/A | N/A | | /5 |

**Dimension score:** /15 → **%**

#### Standard Metrics

| Metric | Value | Target | Pass |
|--------|-------|--------|------|
| Accuracy (value load) | /N correct | ≥ 0.90 | [ ] |

### Governance

| Scenario | Expected risk | Actual risk | Autonomy correct | Score |
|----------|--------------|-------------|-----------------|-------|
| GOV-001 Auth change | HIGH | | | /5 |
| GOV-002 Doc change | LOW | | | /5 |
| GOV-003 Business logic | MEDIUM | | | /5 |

**Dimension score:** /15 → **%**
**Critical failures:** [ ] None [ ] See notes

#### Standard Metrics

| Metric | Value | Target | Pass |
|--------|-------|--------|------|
| Accuracy | /3 correct | = 1.0 (critical path) | [ ] |
| F1 (HIGH risk) | | ≥ 0.95 | [ ] |
| MAE | | < 0.50 | [ ] |

### Consistency

| Scenario | Agreement rate | Score |
|----------|--------------|-------|
| CON-001 Classification (3 tasks × 5 runs) | /15 | /5 |
| CON-002 Output quality (σ) | | /5 |

**Dimension score:** /10 → **%**

#### Standard Metrics

| Metric | Value | Target | Pass |
|--------|-------|--------|------|
| Agreement rate | | ≥ 0.90 | [ ] |
| σ (rubric scores) | | < 1.0 | [ ] |

### Skill Output

#### Scaffolding

| Scenario | Skill | Criteria met | Score |
|----------|-------|-------------|-------|
| SO-001 Bootstrap Java | project-bootstrap | /6 | /5 |
| SO-002 Bootstrap React | project-bootstrap | /6 | /5 |
| SO-003 Legacy assessment | legacy-assessment | /5 | /5 |
| SO-004 Team package | team-package-management | /5 | /5 |

#### Standards

| Scenario | Skill | Criteria met | Score |
|----------|-------|-------------|-------|
| SO-005 Commit message | commit-message | /5 | /5 |
| SO-006 Branch creation | branch-creation | /5 | /5 |
| SO-007 Java standards | java-standards | /6 | /5 |
| SO-008 React standards | react-standards | /6 | /5 |

#### Artifacts

| Scenario | Skill | Criteria met | Score |
|----------|-------|-------------|-------|
| SO-009 Documentation | documentation | /7 | /5 |
| SO-010 Spec template | spec-templates | /6 | /5 |
| SO-011 Pull request | pull-request | /5 | /5 |
| SO-012 Testing | testing | /6 | /5 |
| SO-013 Debugging | debugging | /5 | /5 |

**Dimension score:** /65 → **%**
**Critical failures:** [ ] None [ ] See notes

#### Standard Metrics

| Metric | Value | Target | Pass |
|--------|-------|--------|------|
| Criteria accuracy (mean) | | ≥ 0.70 | [ ] |
| Scenarios passed | /13 | | |
| Per-skill breakdown | See notes | | |

---

## Tier 2: Judge Scores

| Judge | Scenarios evaluated | Mean score | Pass rate |
|-------|-------------------|-----------|-----------|
| Classification | RS-001 through RS-005 | /5 | % |
| Review quality | QG-001, QG-002 | /5 | % |
| Requirements | RS-003, RS-005 | /5 | % |
| Memory | MEM-001, MEM-002 | /5 | % |
| Governance | GOV-001 through GOV-003 | /5 | % |
| Skill output | SO-001 through SO-013 | /5 | % |

---

## Tier 3: Before/After (if conducted)

| Metric | Without DevCrew | With DevCrew | Delta |
|--------|----------------|-------------|-------|
| Avg time to completion | min | min | % |
| Avg quality score | /5 | /5 | |
| Avg interactions | | | % |
| Avg reworks | | | % |
| Context re-explanations | | | % |

---

## Aggregate Score

```
Right-sizing:  __% × 0.15 = __
Quality gates: __% × 0.20 = __
Memory:        __% × 0.15 = __
Governance:    __% × 0.20 = __
Consistency:   __% × 0.10 = __
Skill output:  __% × 0.20 = __
                           ────
Overall:                    __%
```

**Rating:** [ ] Production-ready (≥85%) [ ] Ready with gaps (70-84%) [ ] Needs tuning (50-69%) [ ] Not ready (<50%)

---

## Capability Level

| Level | Gate | Pass | Notes |
|-------|------|------|-------|
| CL-1 | Classification | [ ] | Accuracy ≥ 0.80, MAE < 0.50 |
| CL-2 | Quality Detection | [ ] | Recall ≥ 0.70, Critical Recall = 1.0 |
| CL-3 | Context Persistence | [ ] | Memory accuracy ≥ 0.90 |
| CL-4 | Governance | [ ] | Gov accuracy = 1.0 (critical), F1 (HIGH) ≥ 0.95 |
| CL-5 | Consistency | [ ] | Agreement rate ≥ 0.90, σ < 1.0 |
| CL-6 | Skill Coverage | [ ] | Criteria accuracy ≥ 0.70 across SO-* scenarios |
| CL-7 | Full Orchestration | [ ] | CL-1 through CL-6 all pass |

**Highest achieved level:** CL-__

---

## Regression Analysis

**Baseline run:** [date or "N/A — first run"]

| Dimension | Baseline score | Current score | Delta | Threshold breached |
|-----------|---------------|--------------|-------|-------------------|
| Right-sizing | % | % | | [ ] |
| Quality gates | % | % | | [ ] |
| Memory | % | % | | [ ] |
| Governance | % | % | | [ ] |
| Consistency | % | % | | [ ] |
| Skill output | % | % | | [ ] |

| Check | Result |
|-------|--------|
| Any dimension dropped > 10%? | [ ] No [ ] Yes → which: |
| Any threshold breach? | [ ] No [ ] Yes → which: |
| Capability Level changed? | [ ] Same [ ] Improved [ ] Regressed → from CL-__ to CL-__ |
| New critical failure? | [ ] No [ ] Yes → which: |

**Regression Level:** RL-__

| RL | Meaning | Merge policy |
|----|---------|-------------|
| 0 | No regression | Safe to merge |
| 1 | Score degradation (>10% drop) | Merge with investigation note |
| 2 | Threshold breach | Fix before merge |
| 3 | Capability loss | Block merge |
| 4 | Critical regression | Block merge |

---

## Findings

### Strengths

1.
2.
3.

### Weaknesses

1.
2.
3.

### Recommendations

1.
2.
3.

---

## Notes

[Any observations, anomalies, or context about the evaluation]
