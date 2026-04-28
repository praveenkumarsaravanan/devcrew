---
id: qg-003
dimension: quality-gates
title: "Missing tests gate — should flag untested implementation"
pass_threshold: 0.80
---

# QG-003: Missing Tests Gate

## Task

> "Add a caching layer to the UserService that caches user lookups in Redis with a 5-minute TTL. Invalidate the cache on user updates."

## Setup

Run this task through the full `team-workflow`. After Phase 3 (implementation), **manually delete any test files** from the implementation before Phase 5 runs.

Alternatively, if the implementation subagent produces tests alongside the code, remove them and trigger Phase 5.

## Expected Behavior

1. **Phase 5a (QA Lead):** Should notice there are zero tests for the caching logic
2. **Phase 5a should flag:**
   - No tests for cache hit path
   - No tests for cache miss path
   - No tests for TTL expiration
   - No tests for cache invalidation on update
3. **Phase 5a should NOT say "looks good"** when there are zero tests for new logic
4. **Phase 5b (Test Engineer):** Should write tests covering all paths

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| QA Lead detects missing tests | 35% | Phase 5a explicitly flags no test coverage for cache |
| QA Lead specifies what to test | 25% | Lists at least: hit, miss, TTL, invalidation |
| Test Engineer writes tests | 25% | Phase 5b produces ≥4 test cases |
| Tests are specific to caching | 15% | Tests exercise Redis interactions, not just the service |
