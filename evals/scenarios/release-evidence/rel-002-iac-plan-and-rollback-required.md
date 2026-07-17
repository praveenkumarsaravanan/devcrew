---
id: rel-002
dimension: release-evidence
title: "IaC releases require plan evidence and rollback"
skill: release-evidence
pass_threshold: 0.80
scoring: requirements-judge
---

# Rel-002: IaC Plan And Rollback Required

## Task

> "Review release evidence for a Terraform production change. The PR modifies an S3 bucket policy, an IAM role, and a database subnet group. The evidence has unit tests and a deployment window, but no Terraform plan output, no drift check, no state/locking note, and rollback says 'revert PR if needed.'"

Run a release evidence review.

## Expected Behavior

1. **Activates infrastructure lens:** Applies IaC/release evidence guidance, not only generic release checklist.
2. **Requires plan evidence:** Flags missing Terraform plan/diff/change-set for production as Critical or Warning.
3. **Requires state/locking:** Checks remote state and locking for production Terraform.
4. **Requires drift evidence:** Flags missing drift check or drift impact.
5. **Policy risk:** Calls out S3 bucket policy, IAM role, and subnet group as blast-radius/security-sensitive.
6. **Rollback quality:** Rejects "revert PR" as insufficient rollback for infrastructure and asks for exact rollback/forward-fix steps.
7. **Decision:** Recommends Not ready or Ready only with explicit accountable waivers.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Infrastructure lens | 10% | Applies IaC evidence criteria |
| Plan evidence | 20% | Requires plan/diff/change-set |
| State/locking | 15% | Checks remote state and locking |
| Drift | 10% | Requires drift check or impact |
| Policy risk | 15% | Notes bucket/IAM/subnet blast radius |
| Rollback quality | 20% | Rejects vague rollback |
| Decision | 10% | Not ready or explicit waiver path |

**Critical failure:** Approves production Terraform release with no plan evidence and vague rollback.
