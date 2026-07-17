---
name: data-mapping-validation
description: >
  Data mapping and validation guidance for field mappings, transformations,
  schema evolution, golden-file tests, reconciliation, data quality reports,
  and sensitive-data-safe logging.
---

# Data Mapping Validation

## Trigger

Activate this skill when:

- The user asks to map fields, transform records, validate data, compare schemas, build crosswalks, review mapping logic, or produce a data quality plan.
- A task touches canonical models, source-to-target mapping, enum normalization, derived fields, date/time conversion, nullability, schema drift, or golden-file tests.

## Workflow

### 1. Define Mapping Contract

- Document source field, target field, type, required/optional status, transform rule, default behavior, and owner.
- Define primary/natural keys, deduplication keys, and record identity.
- Preserve lineage: source system, source file/event ID, source timestamp, mapping version, and transform version where useful.
- Version mapping rules and make breaking changes explicit.

### 2. Validate Data Semantics

- Validate type, format, range, enum membership, nullability, length, timezone, and unit conversions.
- Define behavior for missing, unknown, deprecated, duplicated, and conflicting values.
- Avoid lossy transforms unless explicitly accepted and documented.
- Separate parser errors, validation errors, mapping errors, and downstream write errors.

### 3. Golden-File Tests

- Use representative fixtures for happy path, boundary, invalid, missing-field, unknown-enum, duplicate, historical, and schema-version cases.
- Golden-file tests compare full transformed output, not just row counts.
- Keep expected outputs reviewed and versioned with the mapping.
- Include negative golden tests for rejected/quarantined records and reason codes.

### 4. Data Quality Reporting

- Report source count, mapped count, rejected count, quarantined count, duplicate count, missing-key count, and mapping-error count.
- Track data quality by source, schema version, mapping version, run ID, and time window.
- Alert when quality metrics exceed thresholds or when source schema drifts.
- Never include raw sensitive values in reports or logs.

## Output

For mapping work, produce:

1. **Mapping summary** - source, target, keys, mapping version.
2. **Mapping table** - source field, target field, transform, validation, default/reject behavior.
3. **Error handling** - reject/quarantine reason codes and non-retryable behavior.
4. **Golden tests** - fixtures and expected outputs.
5. **Quality report** - metrics, thresholds, alerting, and owner.
6. **Required fixes** - Critical/Warning/Suggestion findings.

## Guardrails

- **Never approve mapping logic without representative golden-file tests.**
- **Never silently coerce unknown enums, invalid dates, or missing identifiers.**
- **Never discard fields or records without documented reason codes.**
- **Never log raw sensitive source or target values.**
- **Never change mapping semantics without versioning and compatibility review.**

## See Also

- **`data-ingestion`** - Source contracts, landing zones, idempotency, retries, and replays.
- **`operational-feed-runbook`** - Operational handling for feed failures and reconciliation.
