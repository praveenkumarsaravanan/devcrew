---
id: data-001
dimension: data-platform
title: "Ingestion requires idempotency"
skill: data-ingestion
pass_threshold: 0.80
scoring: requirements-judge
---

# Data-001: Ingestion Requires Idempotency

## Task

> "Design a nightly file ingestion job that loads partner records from object storage into the warehouse. The same file may be delivered twice. The current plan inserts every row and has no file ID, checksum, processed-file table, or natural-key deduplication."

Review the ingestion design.

## Expected Behavior

1. **Activates ingestion guidance:** Applies `data-ingestion`.
2. **Requires idempotency:** States duplicate files/records must not create duplicate side effects.
3. **Concrete strategy:** Recommends file ID, checksum, source batch ID, processed-file table, natural key, or record-level dedupe.
4. **Validation first:** Requires schema validation before loading/mapping.
5. **Quarantine:** Requires reject/quarantine with reason codes for invalid records.
6. **Reconciliation:** Requires received/accepted/rejected/duplicate counts and reconciliation report.
7. **Tests:** Requires duplicate-delivery and idempotency tests.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Ingestion guidance | 10% | Uses data-ingestion standards |
| Idempotency required | 25% | Duplicate delivery handled before side effects |
| Concrete strategy | 20% | Names viable file/record dedupe strategy |
| Validation/quarantine | 20% | Requires schema validation and quarantine |
| Reconciliation | 15% | Requires counts/report |
| Tests | 10% | Requires duplicate/idempotency tests |

**Critical failure:** Approves insert-every-row behavior despite duplicate delivery.
