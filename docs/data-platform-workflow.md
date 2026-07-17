# Data Platform Workflow

This workflow covers generic ingestion, mapping, validation, replay, reconciliation, and operational feed work.

## Typical Request

```text
/engineering-flow --deep Design a CSV ingestion pipeline with replay and reconciliation
```

Engineering Flow should detect:

- Data platform signals such as `feeds/`, `pipelines/`, `mappings/`, `schemas/`, `samples/`, `replay/`, or `reconciliation/`
- Contract risk when the source shape is external or cross-team
- Regulated-data risk when payloads include sensitive fields
- Release evidence needs for production feeds, replay/backfill, or externally visible contracts

## Standards Activated

| Concern | Primitive |
|---|---|
| Source contract, landing, validation, quarantine, idempotency, replay, reconciliation | `data-ingestion` |
| Mapping rules, validation, golden-file tests, reason codes, quality reports | `data-mapping-validation` |
| Feed alerts, diagnosis, replay/backfill, reconciliation, escalation | `operational-feed-runbook` |
| External contract compatibility, versioning, deprecation, consumer migration | `interoperability-contracts` |
| Sensitive data classification, redaction, synthetic fixtures, audit, retention | `regulated-data-handling` |
| Data platform review | `data-platform-reviewer` |

## Design Expectations

Every production feed should define:

- Source owner, schedule, schema, identifiers, expected volume, SLA/SLO, and compatibility rules
- Landing or audit trail with source ID, timestamp, checksum, and version metadata where feasible
- Schema validation before mapping or side effects
- Reject/quarantine handling with reason codes and counts
- Idempotency for duplicate files, events, records, retries, and replays
- Retry limits, backoff, DLQ/failure destination, and non-retryable behavior
- Replay/backfill scope, dry run, approval, rollback/compensation, and reconciliation
- Data quality reporting for received, accepted, rejected, quarantined, duplicate, missing, replayed, and reconciled counts

## Mapping And Test Expectations

Mapping changes should include:

- Versioned mapping rules
- Golden-file tests for happy path, invalid, edge, duplicate, unknown enum, missing field, and historical schema cases
- Explicit nullability, type, format, enum, timestamp, unit, and range validation
- Safe test data using synthetic or approved de-identified fixtures
- Reports that avoid raw sensitive values

## Operations And Monitoring

Production feeds need:

- Freshness, lag, missed schedule, reject rate, duplicate rate, DLQ depth, cursor stall, replay/backfill status, reconciliation mismatch, and downstream write failure signals
- Alerts with owners, tiers, and runbook links
- Runbooks for diagnosis, replay, backfill, quarantine review, reconciliation, escalation, and customer communication

Use:

```text
/feed-runbook Create a runbook for the partner status feed
/data-quality-plan Plan reconciliation for the account mapping pipeline
/mapping-review Review this schema mapping change
```

## Release Evidence

Medium/high-risk data releases should produce or link:

- Source contract and compatibility evidence
- Mapping golden-file and quality report evidence
- Replay/backfill plan and approval
- Reconciliation evidence
- Sensitive-data classification, redaction, audit, and retention evidence
- Monitoring dashboard and feed runbook links
- Rollback or compensation plan

Use:

```text
/release-evidence Review evidence for the production feed migration
```
