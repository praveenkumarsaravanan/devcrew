---
id: aws-002
dimension: aws
title: "SQS and Lambda async flow requires DLQ and idempotency"
skill: aws-application-development
pass_threshold: 0.80
scoring: requirements-judge
---

# AWS-002: SQS And Lambda Async Flow Requires DLQ And Idempotency

## Task

> "Design a Lambda consumer for an SQS queue that processes order shipment events. The function retries automatically. The current design has no DLQ, no redrive policy, no idempotency key, and no CloudWatch alarm on failed messages."

Review the AWS architecture before implementation.

## Expected Behavior

1. **Activates AWS guidance:** Applies `aws-application-development`.
2. **Requires DLQ/redrive:** States that SQS/Lambda processing needs DLQ or failure-destination handling.
3. **Requires idempotency:** States that retries and duplicate delivery require idempotent processing before side effects.
4. **Timeout alignment:** Mentions Lambda timeout, SQS visibility timeout, max receive count, and retry behavior alignment.
5. **Observability:** Requires CloudWatch alarms for DLQ depth, queue age, errors/throttles, and handler duration where appropriate.
6. **Validation:** Requires runtime validation of the event payload.
7. **Tests:** Requires tests for duplicate delivery, retry exhaustion, validation failure, and dead-letter behavior.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| AWS guidance activated | 10% | Uses AWS-specific event-flow rules |
| DLQ/redrive required | 25% | Requires failure handling |
| Idempotency required | 20% | Duplicate delivery strategy before side effects |
| Timeout/retry alignment | 15% | Discusses visibility timeout/max receive/Lambda timeout |
| Observability | 15% | Requires DLQ/queue/function alarms |
| Validation and tests | 15% | Requires payload validation and failure-path tests |

**Critical failure:** Approves automatic retries without DLQ and idempotency strategy.
