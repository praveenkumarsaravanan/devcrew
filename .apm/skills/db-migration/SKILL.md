---
name: db-migration
description: >
  Database migration planning and review for backend services. Use when creating
  schema changes, reviewing migration scripts, planning zero-downtime migrations,
  or evaluating database schema design.
---

# Database Migration

## Trigger

Activate this skill when the user:

- Is writing or reviewing a database migration script (SQL or ORM-based)
- Needs to plan a schema change for a production database
- Asks about zero-downtime migration strategies
- Wants to validate that a migration is safe to run
- Is designing or modifying a database schema
- Needs guidance on rollback planning

## Workflow

### 1. Understand the Change

- Identify what schema changes are being made: new tables, new columns, altered columns, dropped columns, new indexes, data backfills.
- Determine the database engine (PostgreSQL, MySQL, SQLite, etc.) since locking behavior differs.
- Check the size of affected tables — operations on large tables have different risk profiles.
- Ask about the deployment model: can the application tolerate downtime, or must the migration be zero-downtime?

### 2. Review Schema Change Safety

**Adding columns:**
- Safe: `ADD COLUMN ... NULL` (nullable without default). This is fast and non-locking on most engines.
- Risky: `ADD COLUMN ... NOT NULL` without a `DEFAULT`. On PostgreSQL 11+, `NOT NULL DEFAULT <value>` is safe (uses a virtual default). On MySQL and older PostgreSQL, this rewrites the table.
- Never add a column and make it required in the same deployment. Use a multi-step approach: add nullable → backfill → set NOT NULL.

**Dropping columns:**
- Never drop a column that the current application code still references.
- Follow the deprecation sequence: (1) stop writing to the column, (2) deploy code that no longer reads it, (3) drop the column in a later migration.
- Always use `IF EXISTS` to make drops idempotent.

**Renaming columns:**
- Treat as a drop + add. Old code will break if it references the old name.
- Use the expand-and-contract pattern: add new column → dual-write → migrate reads → drop old column.

**Adding indexes:**
- Use `CREATE INDEX CONCURRENTLY` on PostgreSQL to avoid locking the table.
- On MySQL, use `ALTER TABLE ... ADD INDEX` with `ALGORITHM=INPLACE, LOCK=NONE` where supported.
- Estimate index creation time on large tables. An index on a 100M-row table can take minutes to hours.

**Changing column types:**
- Usually requires a table rewrite. Treat like a rename: add new column, backfill, migrate reads/writes, drop old column.
- Safe exceptions: widening a varchar (e.g., `VARCHAR(50)` → `VARCHAR(100)`) on PostgreSQL.

### 3. Check Backwards Compatibility

Every migration must be compatible with the **currently running** application code, not just the code being deployed with it. This is critical for zero-downtime deployments where old and new code run simultaneously.

**Compatibility checklist:**
- Does the old code still work after this migration runs? (e.g., a dropped column will break old code)
- Does the new code work before this migration runs? (e.g., if migration is delayed or rolled back)
- Can the migration and code deploy happen in any order?

**Multi-phase approach for breaking changes:**

| Phase | Migration | Code |
|-------|-----------|------|
| 1 | Add new column (nullable) | Write to both old and new columns |
| 2 | Backfill new column from old column | Read from new column, fall back to old |
| 3 | Add NOT NULL constraint on new column | Read only from new column |
| 4 | Drop old column | Remove references to old column |

### 4. Validate the Rollback Plan

- Every "up" migration must have a corresponding "down" migration.
- The down migration must be tested: run up, insert sample data, run down, verify no errors.
- Some operations are not easily reversible (e.g., dropping a column loses data). In these cases, the rollback plan should include restoring from backup or re-adding the column and backfilling from an audit log.
- Document the rollback procedure in the migration's commit message or PR description.

### 5. Check Index Impact

- New queries introduced in the same PR should have supporting indexes.
- Verify that new indexes don't duplicate existing indexes.
- Check for unused indexes that should be removed (use `pg_stat_user_indexes` on PostgreSQL, `sys.dm_db_index_usage_stats` on SQL Server).
- Composite index column order matters: the leftmost column should be the highest-cardinality filter.

### 6. Verify Data Migration Strategy

For migrations that transform existing data:

- Estimate the number of rows affected and the expected runtime.
- Run data migrations in batches with configurable batch size and sleep interval to avoid overwhelming the database.
- Use transactions per batch (not one giant transaction) to allow progress checkpointing.
- Log progress: `Migrated 50,000 / 2,000,000 rows (2.5%)`.
- Handle failures gracefully: the migration should be re-runnable (idempotent).
- Test with production-scale data volumes before deploying.

### 7. Run the Validation Script

Use the `validate-migration.sh` script to perform automated checks:

```bash
./scripts/validate-migration.sh path/to/migration.sql
```

The script checks for:
- Dangerous patterns (DROP TABLE without IF EXISTS, NOT NULL without DEFAULT, LOCK TABLE)
- Missing rollback migration file
- Other common pitfalls

Fix all critical issues before merging.

## Guardrails

- **Never drop columns without a deprecation period.** Code must stop referencing the column before it is dropped. Minimum two deployment cycles between removing code references and dropping the column.
- **Require rollback scripts.** Every up migration must have a corresponding down migration. If the operation is irreversible, document the manual rollback procedure.
- **No locking migrations on large tables without explicit approval.** Operations that lock tables (non-concurrent index creation, column type changes, table rewrites) on tables with more than 1 million rows require explicit approval from the team lead or DBA.
- **Never run data migrations inside DDL transactions.** Separate schema changes from data backfills. Schema changes are fast; data migrations should be batched.
- **Always test with production-scale data.** A migration that takes 50ms on 100 rows may take 3 hours on 50 million rows. Test against a copy of production data.
- **Use IF EXISTS / IF NOT EXISTS.** Make all DDL statements idempotent so they can be safely re-run.

## References

- [Migration Validation Script](scripts/validate-migration.sh) — automated checks for common migration pitfalls
