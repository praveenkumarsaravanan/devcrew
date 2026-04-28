---
id: rs-001
dimension: right-sizing
title: "Null pointer fix — should classify as quick-fix"
expected_classification: quick-fix
expected_phases: [Phase 0, Phase 3, Phase 4-lightweight]
skip_phases: [Phase 1, Phase 2, Phase 5]
runs: 3
pass_threshold: 0.80
---

# RS-001: Null Pointer Fix

## Task

Give this prompt to the agent with DevCrew installed:

> "Fix the null pointer exception in UserService.java at line 42. The `getUser()` method returns null when the user ID doesn't exist in the database, but the caller doesn't check for null before calling `.getName()`."

## Expected Behavior

1. **Phase 0 classification:** `quick-fix`
   - Rationale: single file, single bug, clear root cause, no architecture decision
2. **Phases skipped:** Requirements (Phase 1), Architecture (Phase 2), full test strategy (Phase 5)
3. **Phases executed:** Detect (Phase 0) → Implement (Phase 3) → Lightweight review (Phase 4)
4. **Implementation:** Should add a null check or use `Optional`, not restructure the service
5. **No scope creep:** Should not refactor unrelated code or add new features

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Correct classification | 30% | Phase 0 outputs "quick-fix" |
| Skipped unnecessary phases | 20% | Did not run requirements or architecture |
| Focused implementation | 25% | Fix is ≤10 lines, addresses only the null check |
| No scope creep | 15% | No unrelated file changes |
| Completed within context | 10% | Did not require user intervention beyond confirmation |
