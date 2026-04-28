---
id: con-001
dimension: consistency
title: "Classification consistency across multiple runs"
runs: 5
pass_threshold: 0.90
---

# CON-001: Classification Consistency

## Protocol

Run each of the following tasks **5 times each** in separate chat sessions (fresh context each time). Record the Phase 0 classification for every run.

### Tasks

| Task | Expected classification |
|------|----------------------|
| "Fix the broken unit test in OrderServiceTest.java" | quick-fix |
| "Add email validation to the registration form" | standard-change |
| "Build a real-time inventory sync service with event sourcing" | full-feature |

### Recording Template

```
Task: [task text]
Run 1: [classification]  Run 2: [classification]  Run 3: [classification]  Run 4: [classification]  Run 5: [classification]
Agreement: [X/5]
```

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Quick-fix task agreement | 33% | ≥4 out of 5 runs classify as "quick-fix" |
| Standard-change task agreement | 33% | ≥4 out of 5 runs classify as "standard-change" |
| Full-feature task agreement | 34% | ≥4 out of 5 runs classify as "full-feature" |

### Aggregate pass

Overall consistency score = average agreement across all three tasks. Must be ≥90% (at least 4/5 on each) to pass.

---

# CON-002: Output Quality Consistency

## Protocol

Run the following task **3 times** in separate sessions. Score each output using the LLM-as-judge rubric for requirements quality.

### Task

> "Add a password reset flow. Users request a reset via email, receive a link with a time-limited token, click the link, and set a new password."

### What to Compare

For each run, capture the Phase 1 (Requirements) output and score it on:

| Criterion | Score 1-5 |
|-----------|-----------|
| Requirements are numbered with acceptance criteria | |
| Edge cases identified (expired token, invalid token, already-used token) | |
| Scope boundaries defined (what's in vs deferred) | |
| Security considerations mentioned (token entropy, HTTPS, rate limiting) | |

### Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Mean score ≥ 3.5 | 40% | Average across all runs and criteria |
| Standard deviation < 1.0 | 30% | Scores don't swing wildly between runs |
| No run scores below 2.0 on any criterion | 30% | No catastrophically bad output |
