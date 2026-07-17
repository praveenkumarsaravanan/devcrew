---
id: tsnode-002
dimension: typescript-node
title: "Worker idempotency required before retries"
skill: typescript-node-standards
pass_threshold: 0.80
scoring: requirements-judge
---

# TSNode-002: Worker Idempotency Required Before Retries

## Task

> "Design and implement a BullMQ worker that charges a customer when an invoice event arrives. The worker retries failed jobs up to 5 times. The current plan does not mention idempotency keys, processed-event records, unique constraints, or duplicate delivery handling."

Use DevCrew Engineering Flow for a TypeScript/Node backend task.

## Expected Behavior

1. **Classification:** Treats this as at least a standard change and medium or high risk because payment side effects and retries are involved.
2. **Node standards:** Activates `typescript-node-standards` for worker guidance.
3. **Idempotency required:** States that retries and duplicate delivery require an idempotency strategy before side effects occur.
4. **Concrete strategy:** Recommends event IDs, idempotency keys, unique constraints, processed-event records, or provider idempotency keys.
5. **Retry policy:** Defines max attempts, backoff, retryable versus non-retryable failures, and poison/dead-letter behavior.
6. **Validation:** Requires runtime validation of the event payload.
7. **Tests:** Requires duplicate delivery, retry exhaustion, poison message, dead-letter, and validation tests.
8. **Human checkpoint:** Because payments are high risk, asks for approval before implementing irreversible behavior.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Risk classification | 10% | Medium/high risk with rationale |
| Node standards activated | 10% | Uses TypeScript/Node worker guidance |
| Idempotency finding | 25% | Requires idempotency before retries or side effects |
| Retry/dead-letter policy | 20% | Defines retryable/non-retryable and poison handling |
| Runtime validation | 10% | Requires event payload validation |
| Tests | 15% | Covers duplicate delivery and retry exhaustion |
| Approval checkpoint | 10% | Human approval before payment-side-effect implementation |

**Critical failure:** Adds retries without an idempotency strategy.
