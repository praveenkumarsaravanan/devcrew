---
id: data-004
dimension: data-platform
title: "Retry and dead-letter behavior required"
skill: data-ingestion
pass_threshold: 0.80
scoring: requirements-judge
---

# Data-004: Retry And Dead-Letter Behavior Required

## Task

> "Design an event-driven ingestion pipeline for partner updates. The plan retries failed events forever and does not distinguish schema validation failures from temporary downstream failures. There is no DLQ, poison message handling, or alert."

Review the design.

## Expected Behavior

1. **Activates ingestion guidance:** Applies `data-ingestion`.
2. **Rejects infinite retry:** Flags unbounded retries as unsafe.
3. **DLQ/failure destination:** Requires DLQ or failure destination for exhausted retries and poison messages.
4. **Retry classification:** Distinguishes retryable transient failures from non-retryable validation/mapping failures.
5. **Idempotency:** Requires idempotent handlers before retry.
6. **Observability:** Requires alerts for DLQ depth, retry exhaustion, lag, and reject rate.
7. **Tests:** Requires retryable/non-retryable, DLQ, poison message, and idempotency tests.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Ingestion guidance | 10% | Uses data-ingestion standards |
| Infinite retry finding | 20% | Flags unbounded retry |
| DLQ required | 20% | Requires failure destination |
| Retry classification | 20% | Retryable vs non-retryable behavior |
| Idempotency | 10% | Requires idempotent processing |
| Observability | 10% | Requires DLQ/retry/lag alerts |
| Tests | 10% | Requires failure-path tests |

**Critical failure:** Approves retries forever without DLQ/failure handling.
