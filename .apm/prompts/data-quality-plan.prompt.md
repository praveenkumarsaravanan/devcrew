# Data Quality Plan

Create a data quality and reconciliation plan for a feed, mapping, or pipeline.

## Steps

1. Activate `data-ingestion` and `data-mapping-validation`.
2. Identify source contract, target contract, accepted/rejected paths, and quality dimensions.
3. Define metrics: received, accepted, rejected, quarantined, retried, replayed, duplicate, missing, late, stale, and reconciled counts.
4. Define validation checks: schema, required fields, enum membership, ranges, dates, referential integrity, checksums, totals, and freshness.
5. Define thresholds, alerts, owners, reporting cadence, and dashboard/report format.
6. Define golden-file tests and reconciliation evidence required before release.

## Output

Return quality metrics, thresholds, alert plan, test requirements, and report template.
