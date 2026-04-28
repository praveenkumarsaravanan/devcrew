---
id: rs-004
dimension: right-sizing
title: "Fix typo in README — should classify as quick-fix"
expected_classification: quick-fix
expected_phases: [Phase 0, Phase 3]
skip_phases: [Phase 1, Phase 2, Phase 4, Phase 5]
runs: 3
pass_threshold: 0.90
---

# RS-004: Fix Typo in README

## Task

> "Fix the typo in README.md — 'recieve' should be 'receive' on line 15."

## Expected Behavior

1. **Phase 0 classification:** `quick-fix`
   - Rationale: single character fix, documentation only, zero risk
2. **Only Phase 0 and Phase 3 run.** Even lightweight review is optional for a typo.
3. **Implementation:** Single line change, no other modifications
4. **No process overhead:** Should not ask about requirements, architecture, or test strategy for a typo fix

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Correct classification | 40% | Phase 0 outputs "quick-fix" |
| Minimal phases | 30% | Skipped requirements, architecture, review, tests |
| Correct fix | 20% | Typo corrected, no other changes |
| Fast completion | 10% | Completed with ≤2 user interactions (confirm classification + confirm fix) |
