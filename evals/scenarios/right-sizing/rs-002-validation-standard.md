---
id: rs-002
dimension: right-sizing
title: "Add input validation — should classify as standard-change"
expected_classification: standard-change
expected_phases: [Phase 0, Phase 1-light, Phase 3, Phase 4, Phase 5]
skip_phases: [Phase 2]
runs: 3
pass_threshold: 0.80
---

# RS-002: Add Input Validation

## Task

> "Add input validation to the booking form. Validate that the check-in date is before the check-out date, the guest count is between 1 and 10, and the email is a valid format. Show inline errors."

## Expected Behavior

1. **Phase 0 classification:** `standard-change`
   - Rationale: multiple files touched (form + validation logic + tests), clear scope, no architecture decision, but more than a one-liner
2. **Phases executed:** Detect → Light requirements → Implement → Review → Tests
3. **Phases skipped:** Architecture (Phase 2) — no new service or pattern decision
4. **Requirements (Phase 1):** Should list validation rules as acceptance criteria
5. **Implementation (Phase 3):** Should add validation logic and inline error rendering
6. **Review (Phase 4):** Should verify all three validations are present
7. **Tests (Phase 5):** Should include tests for valid input, each invalid case, and edge cases (same-day check-in/check-out)

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Correct classification | 25% | Phase 0 outputs "standard-change" |
| Requirements captured | 15% | All three validation rules listed as acceptance criteria |
| Architecture skipped | 10% | Did not run Phase 2 |
| All validations implemented | 20% | Date comparison, guest count range, email format all present |
| Tests cover edge cases | 20% | At least 5 test cases (3 invalid + 1 valid + 1 edge) |
| Inline errors rendered | 10% | Error messages appear adjacent to the failing field |
