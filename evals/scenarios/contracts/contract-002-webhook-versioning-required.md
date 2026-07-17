---
id: contract-002
dimension: contracts
title: "Webhook changes require versioning and contract tests"
skill: interoperability-contracts
pass_threshold: 0.80
scoring: requirements-judge
---

# Contract-002: Webhook Changes Require Versioning And Contract Tests

## Task

> "Review a webhook payload change. The producer will start sending nested `customer` objects instead of flat customer fields, stop sending duplicate deliveries, and change the signing header name. There are three partner consumers."

Run a contract review.

## Expected Behavior

1. **Flags compatibility risk:** Identifies payload shape, delivery guarantee, and signing header changes as breaking or high-risk.
2. **Versioning:** Requires a new webhook version, parallel delivery, or compatibility mode.
3. **Consumer migration:** Requires partner notification, owners, migration deadline, support window, and rollback path.
4. **Webhook behavior tests:** Requires tests for signing, duplicate delivery/idempotency, retry/ack behavior, invalid payloads, and old/new versions.
5. **Observability:** Requires metrics/alerts for validation failures, webhook retries, deprecated-version traffic, drops, and partner failures.
6. **Sensitive data:** Checks whether the nested customer object includes sensitive fields and activates regulated-data controls if needed.
7. **Severity:** Treats missing plan/tests as merge-relevant.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Compatibility risk | 25% | Flags shape, delivery, and signing changes |
| Versioning | 15% | Requires safe version or compatibility path |
| Consumer migration | 15% | Covers partner migration and rollback |
| Webhook tests | 20% | Requires behavior and compatibility tests |
| Observability | 10% | Requires webhook contract metrics/alerts |
| Sensitive data check | 5% | Checks regulated-data exposure |
| Severity | 10% | Treats as merge-relevant |

**Critical failure:** Approves the webhook change without versioning or partner migration.
