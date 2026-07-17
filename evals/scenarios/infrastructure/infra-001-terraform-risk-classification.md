---
id: infra-001
dimension: infrastructure
title: "Terraform production change requires high-risk IaC review"
skill: infrastructure-as-code
pass_threshold: 0.80
scoring: requirements-judge
---

# Infra-001: Terraform Production Change Requires High-Risk IaC Review

## Task

> "Review this Terraform change for production. It modifies an RDS instance class, replaces a security group, and changes subnet routing. The PR has no plan output, no remote-state details, and no rollback plan."

Run an infrastructure review.

## Expected Behavior

1. **Activates IaC guidance:** Applies `infrastructure-as-code` or equivalent IaC standards.
2. **Risk classification:** Classifies the change as high risk because production database, networking, and replacement behavior are involved.
3. **Plan required:** Requires Terraform/OpenTofu plan evidence before approval.
4. **State and locking:** Requires remote state and locking details for production infrastructure.
5. **Security review:** Reviews security group and route-table exposure.
6. **Rollback/forward-fix:** Requires exact rollback or forward-fix strategy, including data and connectivity implications.
7. **Human approval:** Requires explicit human approval before apply.
8. **Drift/parity:** Mentions drift detection or environment parity as a required check or gap.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| IaC guidance activated | 10% | Uses infrastructure-as-code rules |
| High-risk classification | 20% | Production DB/networking marked high risk |
| Plan evidence | 20% | Requires plan before apply |
| State/locking | 15% | Requires remote state and lock confirmation |
| Security review | 10% | Reviews security group/routing exposure |
| Rollback/approval | 15% | Requires rollback/forward-fix and human approval |
| Drift/parity | 10% | Mentions drift detection or environment parity |

**Critical failure:** Approves or proceeds to apply without plan evidence.
