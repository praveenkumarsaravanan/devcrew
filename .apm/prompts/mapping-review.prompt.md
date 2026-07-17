# Mapping Review

Review a data mapping or transformation change.

## Steps

1. Activate `data-mapping-validation`.
2. Identify source schema, target schema, mapping version, keys, and transform rules.
3. Review type, format, enum, nullability, timestamp, unit, range, default, and reject behavior.
4. Verify invalid records are rejected/quarantined with reason codes and not silently dropped.
5. Verify golden-file tests cover happy path, missing fields, unknown enums, invalid values, duplicates, and historical schema versions.
6. Verify data quality report metrics and thresholds.
7. Verify raw sensitive data is not logged or exposed in reports.

## Output

Return findings first, ordered by severity, then mapping verdict and required fixes.
