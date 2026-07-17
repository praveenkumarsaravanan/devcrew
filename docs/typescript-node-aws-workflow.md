# TypeScript/Node And AWS Workflow

This workflow covers common Node backend services that deploy on AWS or interact with AWS services.

## Typical Request

```text
/engineering-flow Add retry handling to a TypeScript SQS worker
```

Engineering Flow should detect:

- Backend discipline
- TypeScript/Node stack
- AWS platform signals
- Worker or queue-consumer behavior
- Medium or high risk if retries, DLQs, IAM, sensitive data, or production blast radius are involved

## Standards Activated

| Concern | Primitive |
|---|---|
| Runtime validation, typed config, async errors, logs, timeouts, idempotency | `typescript-node-standards` |
| IAM, KMS/encryption, SQS/EventBridge/Lambda failure handling, CloudWatch, cost, quotas | `aws-application-development` |
| IaC state, plan evidence, drift, rollback | `infrastructure-as-code` |
| Review for Node backend concerns | `typescript-node-reviewer` |
| Review for AWS platform concerns | `aws-platform-reviewer` |

## Implementation Expectations

TypeScript/Node work should include:

- Runtime schemas for HTTP, queue, event, job, env, and external response boundaries
- Typed environment config rather than scattered `process.env`
- Safe async error handling and structured errors
- Explicit outbound timeouts and retry decisions
- Redacted logs for tokens, headers, raw payloads, and sensitive fields
- Idempotency for workers, scheduled jobs, queue consumers, and event handlers

AWS work should include:

- Least-privilege IAM
- Encryption for sensitive storage, queues, logs, and backups where supported
- Retry limits and DLQs/failure destinations for async flows
- CloudWatch metrics, alarms, dashboards, traces, and runbook links
- Cost and quota review for production services
- No secrets in IaC, examples, images, or pipeline config

## Review And Test Path

For standard/full work, Engineering Flow should run:

1. Product/Architecture phases as needed by task size
2. Implementation with Node and AWS standards active
3. Review with `backend-reviewer`, `typescript-node-reviewer`, and `aws-platform-reviewer` as applicable
4. Tests covering runtime validation, async errors, retry/DLQ behavior, idempotency, logging redaction, and AWS failure paths

For IaC or image changes, add:

- `infrastructure-reviewer`
- plan/diff/change-set evidence
- image scan or SBOM/provenance evidence
- rollback or forward-fix path

## Release Evidence

Medium/high-risk Node or AWS changes should produce or link:

- Test results from the release branch or candidate
- Security and secrets scan evidence
- IAM/policy review evidence
- IaC plan and state/locking evidence
- Image scan/provenance evidence if artifacts changed
- Rollback trigger criteria and exact steps
- CloudWatch or equivalent dashboards, alerts, and runbooks
- Required approvals or waivers

Use:

```text
/release-evidence Build evidence for the SQS retry release
```
