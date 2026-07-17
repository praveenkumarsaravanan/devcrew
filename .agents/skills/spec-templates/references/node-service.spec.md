# [FEATURE NAME] - TypeScript Node Service Specification

## Problem Statement

[PLACEHOLDER: Describe the problem this Node service, API route, worker, or scheduled job solves, who is affected, and why it is needed now.]

## Scope

| In scope | Out of scope |
|----------|--------------|
| [PLACEHOLDER] | [PLACEHOLDER] |

## Runtime Profile

| Field | Value |
|-------|-------|
| Runtime | [Express / Fastify / NestJS / API route / Worker / Scheduled job] |
| Entry point | `[PLACEHOLDER]` |
| Responsibility | [PLACEHOLDER] |
| Data ownership | [PLACEHOLDER] |
| Idempotency required | Yes / No / Not applicable |

## Contracts

### HTTP API

| Method | Path | Auth | Request schema | Response schema |
|--------|------|------|----------------|-----------------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

### Events Consumed

| Event | Source | Queue/topic | Runtime schema | Idempotency key |
|-------|--------|-------------|----------------|-----------------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

### Events Published

| Event | Destination | Payload schema | Delivery guarantee |
|-------|-------------|----------------|--------------------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Runtime Validation

| Boundary | Schema / validator | Invalid input behavior |
|----------|--------------------|------------------------|
| Env config | [PLACEHOLDER] | Fail startup |
| HTTP body/params/query | [PLACEHOLDER] | Return 400 with safe structured error |
| Queue/event payload | [PLACEHOLDER] | Mark non-retryable or dead-letter |
| External API response | [PLACEHOLDER] | Treat as downstream failure |

## Error Handling

| Error type | Response or handler behavior | Retry policy |
|------------|------------------------------|--------------|
| Validation | [PLACEHOLDER] | No retry |
| Auth/authz | [PLACEHOLDER] | No retry |
| Downstream timeout | [PLACEHOLDER] | [PLACEHOLDER] |
| Duplicate event | [PLACEHOLDER] | No duplicate side effects |
| Poison message | [PLACEHOLDER] | Dead-letter after max attempts |

## Observability

| Signal | Required fields |
|--------|-----------------|
| Logs | `requestId`, `traceId`, `operation`, `durationMs`, safe business identifiers |
| Metrics | [PLACEHOLDER: latency, error rate, queue depth, retry count, dead-letter count] |
| Traces | [PLACEHOLDER] |

Sensitive fields to redact:

- Authorization headers, cookies, tokens, API keys, passwords, secrets, payment data, SSNs, and raw PII.

## Requirements

| ID | Description | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| REQ-001 | [PLACEHOLDER] | [PLACEHOLDER] | Must |

## Test Plan

| Area | Required coverage |
|------|-------------------|
| Runtime validation | Valid and invalid body/params/query/env/payload cases |
| Async errors | Rejected promises, timeout behavior, retry and non-retry decisions |
| API behavior | Success, auth/authz, validation, conflict, downstream failure |
| Worker/job behavior | Duplicate delivery, idempotency, retry exhaustion, dead-letter/checkpoint behavior |
| Logging | Sensitive data is not emitted |

## Handoff Checklist

- [ ] Runtime validation schemas identified
- [ ] Typed env config requirements defined
- [ ] Error and retry behavior defined
- [ ] Idempotency strategy defined for workers/events/jobs
- [ ] Sensitive logging redaction confirmed
- [ ] API/worker/job tests identified
- [ ] Open questions resolved
