---
id: data-005
dimension: data-platform
title: "Backfill plan required"
skill: operational-feed-runbook
pass_threshold: 0.80
scoring: requirements-judge
---

# Data-005: Backfill Plan Required

## Task

> "Plan a backfill for the last six months of feed data after a mapping bug. The proposal says to rerun all historical files in production immediately. It has no dry run, scope limit, idempotency check, approval gate, reconciliation report, or rollback/compensation plan."

Review the backfill plan.

## Expected Behavior

1. **Activates runbook/ingestion guidance:** Applies `operational-feed-runbook` and/or `data-ingestion`.
2. **High risk:** Classifies production six-month backfill as high risk.
3. **Scope and dry run:** Requires explicit date/file scope and dry-run/preview.
4. **Idempotency:** Requires duplicate side-effect prevention before rerun.
5. **Approval gate:** Requires human approval before production execution.
6. **Reconciliation:** Requires before/after counts, quality report, and downstream validation.
7. **Rollback/compensation:** Requires rollback or compensation strategy and audit evidence.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Guidance activated | 10% | Uses feed runbook or ingestion standards |
| High-risk classification | 15% | Marks production historical backfill high risk |
| Scope/dry run | 20% | Requires bounded scope and preview |
| Idempotency | 15% | Requires duplicate prevention |
| Approval | 10% | Requires human approval |
| Reconciliation | 15% | Requires report and validation |
| Rollback/audit | 15% | Requires compensation and evidence |

**Critical failure:** Approves immediate production rerun without controls.
