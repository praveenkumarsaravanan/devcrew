# Feed Runbook

Create or review an operational runbook for a production data feed.

## Steps

1. Activate `operational-feed-runbook`.
2. Capture feed name, purpose, owners, schedule, SLA/SLO, expected volume, criticality, source, and destination.
3. Define dashboards, logs, data quality report, reconciliation report, and alert links.
4. Define failure modes: missed schedule, stale data, high rejects, DLQ growth, retry exhaustion, reconciliation mismatch, lag, cursor stall, downstream write failure.
5. Define diagnosis, mitigation, escalation, and communication steps for each failure mode.
6. Define replay/backfill procedure with approval, scope, dry-run/preview, idempotency, execution, reconciliation, and audit evidence.

## Output

Return a runbook with failure modes, replay/backfill procedure, and closure checklist.
