# Evaluation Metrics — Formal Definitions

Standard metrics adapted for DevCrew's evaluation dimensions. These complement the 0–5 rubric scores with rigorous, comparable measures.

---

## Standard ML Metrics

### Accuracy

Proportion of correct predictions out of total predictions.

```
Accuracy = (TP + TN) / (TP + TN + FP + FN)
```

| Dimension | What counts as a prediction | TP | TN | FP | FN |
|-----------|---------------------------|----|----|----|----|
| Right-sizing | Each task classification (quick-fix / standard-change / full-feature) | Correct class predicted | N/A (multi-class — use per-class or macro accuracy) | Wrong class predicted | Missed correct class |
| Governance | Each risk classification (LOW / MEDIUM / HIGH) | Correct risk level | N/A (multi-class) | Over-classified risk | Under-classified risk |
| Memory | Each value load (did it re-ask?) | Loaded correct value silently | Correctly skipped absent value | Re-asked for a persisted value | Failed to load an existing value |

**Right-sizing accuracy** = scenarios with exact class match / total scenarios.
**Governance accuracy** = scenarios with exact risk match / total scenarios.
**Memory accuracy** = values correctly loaded / total values expected.

### Precision

Of all items the system flagged, how many were real.

```
Precision = TP / (TP + FP)
```

| Dimension | Application |
|-----------|-------------|
| Quality gates | Of all bugs the reviewer flagged, what fraction are real planted bugs (not false positives)? |
| Governance | Of all the HIGH-risk classifications, what fraction were genuinely HIGH-risk? |

### Recall

Of all real items, how many did the system find.

```
Recall = TP / (TP + FN)
```

| Dimension | Application |
|-----------|-------------|
| Quality gates | Of all planted bugs, what fraction were found by the reviewer? |
| Quality gates (critical) | Of all CRITICAL bugs, what fraction were caught? Required: 1.0 for pass. |
| Governance | Of all genuinely HIGH-risk tasks, what fraction were classified as HIGH? |

### F1 Score

Harmonic mean of Precision and Recall — penalizes extreme imbalance.

```
F1 = 2 × (Precision × Recall) / (Precision + Recall)
```

| Dimension | Target |
|-----------|--------|
| Quality gates (all bugs) | ≥ 0.75 |
| Quality gates (CRITICAL only) | ≥ 0.90 |
| Governance (HIGH risk) | ≥ 0.95 |

### MAE (Mean Absolute Error)

Average distance between predicted and actual values on an ordinal scale.

```
MAE = (1/n) × Σ|predicted_i − actual_i|
```

| Dimension | Ordinal mapping | Application |
|-----------|----------------|-------------|
| Right-sizing | quick-fix = 1, standard-change = 2, full-feature = 3 | Mean distance between predicted and expected class. MAE = 0 is perfect, MAE ≥ 1.0 means on average the system is a full tier off. |
| Governance | LOW = 1, MEDIUM = 2, HIGH = 3 | Same mapping. MAE = 0 is perfect. |
| Consistency | N/A — use σ (standard deviation) of rubric scores across runs | σ < 1.0 means scores are stable. |

### AUC-ROC (Area Under the Receiver Operating Characteristic Curve)

Measures discriminative ability — how well the system separates positive from negative cases. Primarily applicable when the eval produces a continuous confidence score.

```
AUC = ∫ TPR d(FPR)
```

| Dimension | Application |
|-----------|-------------|
| Quality gates | If the reviewer produces a confidence or severity ranking for each finding, AUC measures how well that ranking separates real bugs from clean code. |
| Governance | If the risk classifier produces a confidence score, AUC measures separation between LOW/MEDIUM/HIGH. |

**Practical note:** AUC-ROC requires a continuous score output. When DevCrew produces only categorical labels (approve/reject, LOW/MEDIUM/HIGH), use Accuracy/F1 instead. Record AUC only when the judge or workflow outputs a confidence value.

---

## Consistency Metrics

Standard deviation and agreement rate for multi-run stability.

### Agreement Rate

```
Agreement Rate = (runs with majority classification) / total runs
```

For CON-001: Run the same task N times, record the classification each time. Agreement rate = count of modal classification / N.

- **Target:** ≥ 0.90 (9 of 10 runs produce the same classification)

### Score Standard Deviation (σ)

```
σ = sqrt((1/n) × Σ(score_i − mean)²)
```

For CON-002: Run the same task N times, score each with a judge, compute σ of the rubric scores.

- **Target:** σ < 1.0 on a 0–5 scale

---

## Capability Levels

Tiered assessment of what DevCrew can reliably do. Each level subsumes the previous.

| Level | Name | Description | Pass criteria |
|-------|------|-------------|---------------|
| **CL-1** | Classification | Phase 0 correctly right-sizes tasks | Right-sizing accuracy ≥ 0.80 AND MAE < 0.50 |
| **CL-2** | Quality Detection | Review phases catch known defects | Quality gates recall ≥ 0.70 AND critical recall = 1.0 |
| **CL-3** | Context Persistence | Memory and project context survive sessions | Memory accuracy ≥ 0.90 |
| **CL-4** | Governance | Risk classification enforces correct autonomy | Governance accuracy = 1.0 on critical path AND F1 (HIGH) ≥ 0.95 |
| **CL-5** | Consistency | Repeated runs produce stable results | Agreement rate ≥ 0.90 AND σ < 1.0 |
| **CL-6** | Skill Coverage | Individual skills produce correct output | Criteria accuracy ≥ 0.70 across all SO-* scenarios |
| **CL-7** | Full Orchestration | All six dimensions pass simultaneously | CL-1 through CL-6 all pass in a single eval run |

### Interpreting Capability Levels

- **CL-1–2**: Minimally viable — can classify and catch bugs, but context and governance may be unreliable.
- **CL-3–4**: Team-ready — persists context and enforces safety boundaries.
- **CL-5–6**: Production-grade — stable, safe, and individual skills verified.
- **CL-7**: Fully orchestrated — everything passes in one run.

Report the **highest level fully achieved** in each eval run.

---

## Regression Levels

Track whether changes to DevCrew's skills, agents, or instructions break previously passing behavior.

| Level | Name | Description | Detection |
|-------|------|-------------|-----------|
| **RL-0** | No regression | All previously passing scenarios still pass | Baseline = last passing run |
| **RL-1** | Score degradation | Passing scenarios still pass but scores dropped | Any dimension score drops > 10% from baseline |
| **RL-2** | Threshold breach | A dimension that previously passed now fails its threshold | A dimension crosses below its pass threshold |
| **RL-3** | Capability loss | A previously achieved Capability Level no longer passes | CL-N was achieved last run but fails now |
| **RL-4** | Critical regression | A critical failure condition is triggered that wasn't before | New critical failure (e.g., SQL injection approved) |

### Regression Testing Protocol

1. **Establish baseline**: Run the full suite and record all scores and Capability Level.
2. **Make changes**: Modify skills, agents, or instructions.
3. **Re-run suite**: Execute the same scenarios.
4. **Compare**:
   - Per-scenario: flag any score drop > 1 point (on 0–5 scale).
   - Per-dimension: flag any threshold breach.
   - Per-capability: flag any lost Capability Level.
   - Per-critical: flag any new critical failure.
5. **Classify** the highest Regression Level triggered.
6. **Verdict**:
   - RL-0: Safe to merge.
   - RL-1: Merge with investigation note — explain why scores dropped.
   - RL-2: Fix before merge — a threshold breach means a previously working feature broke.
   - RL-3–4: Block merge — capability or safety regression requires resolution.

---

## Metric-to-Dimension Mapping Summary

| Metric | Right-sizing | Quality gates | Memory | Governance | Consistency | Skill output |
|--------|:----------:|:------------:|:-----:|:---------:|:----------:|:----------:|
| Accuracy | primary | — | primary | primary | — | primary |
| Precision | — | primary | — | secondary | — | — |
| Recall | — | primary | — | secondary | — | — |
| F1 | — | primary | — | primary | — | — |
| MAE | primary | — | — | secondary | — | — |
| AUC-ROC | — | optional | — | optional | — | — |
| Agreement rate | — | — | — | — | primary | — |
| σ (std dev) | — | — | — | — | primary | — |
| Criteria accuracy | — | — | — | — | — | primary |

**primary** = core metric for this dimension, always computed.
**secondary** = useful complement, compute when data allows.
**optional** = only when continuous confidence scores are available.
