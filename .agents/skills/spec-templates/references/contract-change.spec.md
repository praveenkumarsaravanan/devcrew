# [Contract Name] Contract Change Specification

## Problem Statement

What contract needs to change, why now, and what consumer or producer problem does it solve?

## Contract Summary

| Field | Value |
|---|---|
| Contract type | OpenAPI / AsyncAPI / webhook / event / gRPC-protobuf / GraphQL / file-feed / SDK / other |
| Producer |  |
| Consumers |  |
| Owner |  |
| Current version |  |
| Proposed version |  |
| Environment | internal / partner / public |
| Support channel |  |

## Scope

### In Scope

- 

### Out Of Scope

- 

## Compatibility Assessment

| Change | Additive / Breaking / Unknown | Affected consumers | Mitigation |
|---|---|---|---|
|  |  |  |  |

Breaking changes require a new version, parallel contract, compatibility mode, or explicit consumer migration approval.

## Schema And Examples

- Machine-readable schema location:
- Normal examples:
- Edge examples:
- Invalid examples:
- Historical/versioned examples:
- Error, retry, timeout, idempotency, and correlation ID behavior:

## Security And Regulated Data

| Field or payload area | Classification | Access control | Redaction/masking | Retention |
|---|---|---|---|---|
|  |  |  |  |  |

Document authentication, authorization, signing, encryption, rate limits, and audit events. If sensitive data is present, apply `regulated-data-handling`.

## Versioning And Deprecation

- Versioning strategy:
- Deprecation notice:
- Support window:
- Consumer migration steps:
- Removal date:
- Rollback or compatibility toggle:

## Contract Tests

| Test type | Required? | Evidence |
|---|---|---|
| Provider schema test |  |  |
| Consumer compatibility test |  |  |
| Breaking-change diff test |  |  |
| Webhook/event/file/feed behavior test |  |  |
| Sensitive data redaction/synthetic fixture test |  |  |

## Rollout And Observability

- Rollout plan:
- Consumer notification:
- Validation failure metrics:
- Deprecated-version traffic metric:
- Retry/drop/reject/consumer-lag alerts:
- Runbook or support escalation:

## Handoff Checklist

- [ ] Contract owner and consumers identified
- [ ] Compatibility assessment complete
- [ ] Versioning/deprecation plan defined for breaking changes
- [ ] Schemas and examples updated
- [ ] Security and regulated-data controls documented
- [ ] Contract tests identified or implemented
- [ ] Rollout, observability, and support plan documented
