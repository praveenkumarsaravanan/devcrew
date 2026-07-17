# Data Ingestion Starter

Opinionated starter for a generic data feed or ingestion pipeline. Use this for batch files, API pulls, event streams, queue consumers, CDC snapshots, and replay/backfill workflows.

## Directory Structure

```text
+-- src/
|   +-- ingestion/
|   +-- mapping/
|   +-- validation/
|   +-- reconciliation/
|   +-- replay/
|   +-- observability/
+-- schemas/
+-- samples/
|   +-- valid/
|   +-- invalid/
|   +-- historical/
+-- tests/
|   +-- golden/
|   +-- unit/
|   +-- integration/
+-- docs/
|   +-- runbooks/
|   +-- data-quality/
+-- .env.example
+-- README.md
```

## Required Starter Patterns

- Source contract document with owner, schedule, schema, identifiers, versioning, samples, SLA/SLO, and compatibility rules.
- Raw landing or audit trail before transformation when feasible.
- Schema validation before mapping.
- Reject/quarantine path with reason codes.
- Idempotency key or processed-record strategy.
- Retry limits, backoff, DLQ/failure destination, and non-retryable behavior.
- Golden-file tests for mapping and rejects.
- Reconciliation report and data quality report.
- Replay/backfill script with dry-run/preview and explicit scope.
- Operational runbook with alerts, diagnosis, escalation, replay, and closure.

## Do Not Include

- Real production payloads.
- Raw sensitive data in samples.
- Secrets, tokens, credentials, private endpoints, or real account identifiers.
