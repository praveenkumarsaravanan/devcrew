# Data Ingestion Design

Design a batch, streaming, file, API, queue, or event data ingestion workflow.

## Steps

1. Activate `data-ingestion`.
2. Classify the feed shape and identify source, destination, owner, schedule, volume, SLA/SLO, and data sensitivity.
3. Define the source contract: schema, identifiers, versioning, samples, compatibility, and breaking-change process.
4. Define landing zone, raw-data retention, metadata, checksum, and auditability.
5. Define schema validation, reject/quarantine handling, reason codes, and data quality reporting.
6. Define idempotency, retry limits, DLQ/failure destination, replay/backfill, and reconciliation.
7. Define observability: freshness, lag, reject rate, duplicate rate, DLQ depth, reconciliation mismatch, alerts, and runbook.

## Output

Return feed design, risks, required decisions, and implementation checklist.
