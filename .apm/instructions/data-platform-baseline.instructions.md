---
name: data-platform-baseline
description: Always-on data platform checks for ingestion, mapping, validation, replay, reconciliation, and feed operations
applyTo: "**/{data,data-platform,feeds,pipelines,ingestion,mapping,mappings,reconciliation,replay,backfill,schemas,samples,runbooks}/**/*.{ts,tsx,js,jsx,py,java,go,sql,yml,yaml,json,csv,tsv,xml,avsc,proto,md}"
---

# Data Platform Baseline

Apply these rules when code or docs define data feeds, ingestion jobs, mapping logic, validation schemas, data quality checks, replay/backfill scripts, reconciliation reports, or operational feed runbooks.

## Required Checks

- Every feed has a source contract: owner, schedule, schema, identifiers, versioning, samples, SLA/SLO, and compatibility rules.
- Raw/source data lands before transformation when feasible, with source ID, timestamp, checksum, and version metadata.
- Schema validation runs before mapping or side effects.
- Invalid records are rejected or quarantined with reason codes. Do not silently drop records.
- Processing is idempotent before retries, replays, backfills, or duplicate delivery handling.
- Retry limits, backoff, DLQ/failure destination, and non-retryable behavior are defined.
- Mapping logic has golden-file tests for happy path, edge, invalid, unknown-enum, missing-field, duplicate, and historical cases.
- Reconciliation and data quality reports include received, accepted, rejected, quarantined, retried, replayed, duplicate, and missing counts where applicable.
- Backfill/replay plans include scope, dry-run/preview, approval, rollback/compensation, and reconciliation.
- Logs, reports, dashboards, and runbooks do not expose raw sensitive payloads.

## Do Not Allow

- Feed changes with no source contract.
- Mapping changes without representative golden-file tests.
- Retries or replay without idempotency.
- Silent drops of invalid records.
- Backfills without explicit scope and reconciliation.
- Raw sensitive values in logs, dashboards, runbooks, or quality reports.
