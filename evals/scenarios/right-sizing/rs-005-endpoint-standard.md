---
id: rs-005
dimension: right-sizing
title: "Add REST endpoint — should classify as standard-change"
expected_classification: standard-change
expected_phases: [Phase 0, Phase 1-light, Phase 3, Phase 4, Phase 5]
skip_phases: [Phase 2]
runs: 3
pass_threshold: 0.80
---

# RS-005: Add REST Endpoint

## Task

> "Add a GET /api/users/{id}/orders endpoint that returns the last 10 orders for a user, sorted by date descending. Include pagination support with offset and limit query parameters."

## Expected Behavior

1. **Phase 0 classification:** `standard-change`
   - Rationale: new endpoint (not a fix), touches controller + service + maybe repository, but follows existing patterns — no new architectural decision
2. **Phases executed:** Detect → Light requirements → Implement → Review → Tests
3. **Architecture skipped:** Adding an endpoint to an existing service follows established patterns
4. **Requirements (Phase 1):** Should capture: response format, pagination contract, sort order, error cases (user not found, no orders)
5. **Implementation (Phase 3):** Controller, service method, repository query, DTO
6. **Review (Phase 4):** Should check SQL injection risk, pagination bounds, N+1 queries
7. **Tests (Phase 5):** Should test happy path, empty orders, invalid user, pagination edge cases

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Correct classification | 25% | Phase 0 outputs "standard-change" |
| Requirements include error cases | 15% | Lists at least: user not found, empty results, invalid pagination |
| No architecture phase | 10% | Phase 2 did not run |
| Implementation follows patterns | 20% | Uses existing project conventions for controllers and services |
| Review checks security | 15% | Mentions injection risk or input sanitization |
| Tests cover pagination | 15% | At least one test for offset/limit behavior |
