# [FEATURE NAME] — Migration Specification

## Problem Statement

[PLACEHOLDER: Describe why this migration is needed — what limitation, inconsistency, or requirement drives the change.]

## Scope

| In scope | Out of scope |
|----------|--------------|
| [PLACEHOLDER] | [PLACEHOLDER] |

## Migration Overview

| Field | Value |
|-------|-------|
| Migration type | Schema / Data / Combined |
| Source state | [PLACEHOLDER: Current schema version, data format, or system] |
| Target state | [PLACEHOLDER: Desired schema version, data format, or system] |
| Affected tables / collections | [PLACEHOLDER: e.g., `users`, `orders`] |
| Estimated row count | [PLACEHOLDER: e.g., "~2M rows in `orders`"] |

## Schema Changes

### Before

```sql
-- [PLACEHOLDER: Current DDL or model definition]
CREATE TABLE [table] (
    [column] [type] [constraints]
);
```

### After

```sql
-- [PLACEHOLDER: Target DDL or model definition]
CREATE TABLE [table] (
    [column] [type] [constraints],
    [new_column] [type] [constraints]
);
```

### Diff Summary

| Change | Table | Column | Before | After |
|--------|-------|--------|--------|-------|
| Add | [PLACEHOLDER] | [PLACEHOLDER] | — | `[type] [constraints]` |
| Alter | [PLACEHOLDER] | [PLACEHOLDER] | `[old type]` | `[new type]` |
| Drop | [PLACEHOLDER] | [PLACEHOLDER] | `[type]` | — |

## Data Transformation Rules

| Rule | Source | Target | Logic |
|------|--------|--------|-------|
| [PLACEHOLDER: e.g., "Backfill status"] | `orders.state` | `orders.status` | [PLACEHOLDER: e.g., "Map 'active' → 'ACTIVE', 'done' → 'COMPLETED'"] |
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

**Null handling:** [PLACEHOLDER: e.g., "Rows with NULL `state` default to 'UNKNOWN'"]

**Batch size:** [PLACEHOLDER: e.g., "Process 5,000 rows per batch to limit lock duration"]

## Rollback Strategy

| Field | Value |
|-------|-------|
| Reversible | Yes / No / Partial |
| Rollback method | [PLACEHOLDER: e.g., "Run reverse migration script `V2__rollback.sql`"] |
| Data loss on rollback | [PLACEHOLDER: e.g., "New column data lost; original columns preserved"] |
| Manual steps | [PLACEHOLDER: e.g., "None" or "Re-deploy previous application version first"] |
| Rollback deadline | [PLACEHOLDER: e.g., "Within 24 hours before dependent features are released"] |

## Zero-Downtime Plan

| Phase | Action | Downtime |
|-------|--------|----------|
| 1. Expand | [PLACEHOLDER: e.g., "Add new column as nullable, deploy code that writes both old and new"] | None |
| 2. Migrate | [PLACEHOLDER: e.g., "Backfill existing rows in batches"] | None |
| 3. Contract | [PLACEHOLDER: e.g., "Remove old column reads from code, deploy"] | None |
| 4. Cleanup | [PLACEHOLDER: e.g., "Drop old column, add NOT NULL constraint"] | None |

**Pattern:** [PLACEHOLDER: Expand-Contract / Blue-Green / Dual-Write / Other]

## Validation Queries

### Pre-Migration Checks

```sql
-- [PLACEHOLDER: Verify preconditions]
-- Example: Confirm no orphaned rows
SELECT COUNT(*) FROM [table] WHERE [fk_column] NOT IN (SELECT id FROM [parent]);
```

### Post-Migration Checks

```sql
-- [PLACEHOLDER: Verify migration success]
-- Example: All rows have new column populated
SELECT COUNT(*) FROM [table] WHERE [new_column] IS NULL;
-- Expected: 0
```

### Data Integrity Assertions

| Assertion | Query | Expected Result |
|-----------|-------|-----------------|
| [PLACEHOLDER: e.g., "Row count unchanged"] | `SELECT COUNT(*) FROM [table]` | [PLACEHOLDER: e.g., "Same as pre-migration count"] |
| [PLACEHOLDER: e.g., "No null values in new column"] | `SELECT COUNT(*) FROM [table] WHERE [col] IS NULL` | 0 |

## Estimated Duration & Resource Impact

| Metric | Estimate |
|--------|----------|
| Migration duration | [PLACEHOLDER: e.g., "~45 minutes for 2M rows at 5K/batch"] |
| Peak CPU impact | [PLACEHOLDER: e.g., "~20% increase on DB primary"] |
| Peak I/O impact | [PLACEHOLDER: e.g., "~500 IOPS additional write load"] |
| Lock duration | [PLACEHOLDER: e.g., "< 1s per batch (row-level locks only)"] |
| Recommended window | [PLACEHOLDER: e.g., "Off-peak: weekday 2–4 AM UTC"] |

## Requirements

| ID | Description | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| REQ-001 | [PLACEHOLDER] | [PLACEHOLDER] | Must |

## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Handoff Checklist

- [ ] Spec reviewed and approved
- [ ] Rollback script tested in staging
- [ ] Validation queries verified in staging
- [ ] DBA reviewed schema changes and estimated lock impact
- [ ] On-call team notified of migration window
- [ ] Open questions resolved
