---
name: data-ingestion
description: >
  Data ingestion guidance for batch, streaming, file, API, queue, and event
  feeds. Covers source contracts, landing zones, schema validation,
  quarantine/reject handling, idempotency, retry/DLQ, reconciliation,
  backfill/replay, observability, and data quality reporting.
---

# Data Ingestion

## Trigger

Activate this skill when:

- The user asks to design, build, review, or operate a data feed, ETL/ELT job, ingestion pipeline, import, export, stream, batch load, or event/file/API integration.
- A task touches source contracts, landing zones, schema validation, retries, DLQs, backfills, replays, reconciliation, data quality, or feed runbooks.
- Engineering Flow, SRE, testing, or a data platform reviewer needs data-ingestion safety guidance.

## Workflow

### 1. Classify The Feed

| Feed shape | Examples | Primary risks |
|---|---|---|
| File batch | CSV, JSONL, XML, parquet, SFTP/object storage | schema drift, partial files, duplicate files |
| API pull | paginated API, partner endpoint | rate limits, auth expiry, missed pages |
| Event/queue stream | Kafka, SQS, Pub/Sub, webhooks | duplicate delivery, ordering, poison messages |
| Database replication | CDC, snapshots, incremental sync | cursor drift, deletes, lag |
| Manual/backfill | one-time import, replay, correction | blast radius, auditability, overwrite risk |

### 2. Source Contract

- Define producer, consumer, schedule, delivery method, expected volume, owner, SLA/SLO, and escalation contact.
- Define schema, required fields, nullable fields, types, enums, identifiers, timestamp semantics, timezone, and versioning.
- Define compatibility rules for schema changes and how breaking changes are approved.
- Define sample payloads or files for happy path, invalid, edge, and historical cases.

### 3. Landing, Validation, And Quarantine

- Land raw data before transformation when feasible. Preserve file/event identifiers, source timestamp, receive timestamp, checksum, and version.
- Validate schema before mapping or side effects.
- Reject or quarantine invalid records with reason codes and safe metadata.
- Do not silently drop records. Every reject/quarantine path must be queryable and reportable.
- Treat external source data as untrusted input and avoid logging raw sensitive payloads.

### 4. Processing Safety

- Make ingestion idempotent by source file ID, event ID, natural key, checksum, cursor, or processed-record table.
- Define retry limits, backoff, DLQ/failure destination, poison-message handling, and non-retryable error behavior.
- Keep checkpoints/cursors durable and auditable.
- Distinguish replay-safe operations from one-way side effects.
- Define backfill/replay scope, time window, dry-run mode, expected volume, and rollback/compensation.

### 5. Reconciliation And Data Quality

- Reconcile counts, totals, checksums, cursor ranges, or source acknowledgements after each run.
- Produce a data quality report with received, accepted, rejected, quarantined, retried, replayed, and missing counts.
- Track freshness, lag, duplicate rate, reject rate, reconciliation variance, and DLQ depth.
- Alert on missed schedule, stale data, high reject rate, reconciliation mismatch, and retry/DLQ growth.

## Output

For ingestion design or review, produce:

1. **Feed summary** - source, destination, schedule, volume, owner, SLA/SLO.
2. **Contract** - schema, versioning, identifiers, samples, compatibility.
3. **Validation and quarantine** - accepted/rejected paths, reason codes, reporting.
4. **Processing controls** - idempotency, retry/DLQ, checkpoints, replay/backfill.
5. **Reconciliation and quality** - metrics, reports, alerts, runbook needs.
6. **Required fixes** - Critical/Warning/Suggestion findings.

## Guardrails

- **Never process source data without a source contract.**
- **Never skip schema validation before transformation or side effects.**
- **Never silently drop invalid records. Use reject/quarantine with reason codes.**
- **Never enable retries without idempotency and bounded failure handling.**
- **Never run a backfill or replay without scope, dry-run or preview, and rollback/compensation plan.**
- **Never log raw sensitive payloads, credentials, tokens, or full source files.**

## See Also

- **`data-mapping-validation`** - Field mappings, transform rules, golden-file tests, and quality reports.
- **`operational-feed-runbook`** - Operator runbook for feed failures, replays, and reconciliation.
- **`data-platform-reviewer`** - Reviewer agent for data feed and mapping changes.
