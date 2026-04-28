---
id: rs-003
dimension: right-sizing
title: "Build notification service — should classify as full-feature"
expected_classification: full-feature
expected_phases: [Phase 0, Phase 1, Phase 2, Phase 3, Phase 4, Phase 5a, Phase 5b]
skip_phases: []
runs: 3
pass_threshold: 0.80
---

# RS-003: Build Notification Service

## Task

> "Build a new notification service that sends email notifications when orders ship. It should support multiple notification channels (email, SMS, push) with a pluggable architecture, handle retries for failed deliveries, and include a dead letter queue for permanently failed notifications."

## Expected Behavior

1. **Phase 0 classification:** `full-feature`
   - Rationale: new service, architecture decision (pluggable channels), multiple components (queue, retry logic, channel adapters), cross-cutting concerns (DLQ, monitoring)
2. **All phases executed:** Full lifecycle from requirements through testing
3. **Requirements (Phase 1):**
   - Should produce a numbered requirements list with acceptance criteria
   - Should identify edge cases: network failures, duplicate sends, channel unavailability
   - Should define scope boundaries: what's included vs deferred
4. **Architecture (Phase 2):**
   - Should evaluate channel abstraction pattern (strategy pattern, plugin registry, etc.)
   - Should address retry strategy (exponential backoff, circuit breaker)
   - Should design DLQ mechanism
   - Should be spawned as a **subagent** (isolated context)
5. **Implementation (Phase 3):**
   - Should follow the architecture from Phase 2
   - Should produce multiple files (service, channel adapters, queue handler, config)
6. **Review (Phase 4):**
   - Should be spawned as a **subagent** (adversarial review)
   - Should check error handling, retry logic correctness, and channel abstraction
7. **Test strategy (Phase 5a):**
   - Should cover unit tests for each channel adapter, integration tests for retry logic, edge case tests for DLQ
8. **Test implementation (Phase 5b):**
   - Should produce working tests that match the strategy

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Correct classification | 15% | Phase 0 outputs "full-feature" |
| Complete requirements | 15% | ≥5 numbered requirements with acceptance criteria |
| Architecture uses subagent | 10% | Phase 2 ran in isolated context (Task tool) |
| Architecture addresses core concerns | 15% | Pluggable channels + retry + DLQ all addressed |
| Review uses subagent | 10% | Phase 4 ran in isolated context (Task tool) |
| Review is adversarial | 10% | Review explicitly looks for defects, not just confirms |
| Test coverage adequate | 15% | Tests cover happy path, each failure mode, and DLQ |
| End-to-end coherence | 10% | Later phases reference earlier handoff artifacts |
