---
id: infra-003
dimension: infrastructure
title: "IaC IAM policy must be least privilege"
skill: infrastructure-as-code
pass_threshold: 0.80
scoring: requirements-judge
---

# Infra-003: IaC IAM Policy Must Be Least Privilege

## Task

> "Review a Terraform module that creates an IAM role for a batch job. The policy grants `s3:*`, `dynamodb:*`, and `kms:*` on `*`. The job only needs to read one S3 prefix, write to one DynamoDB table, and decrypt one KMS key."

Run an IaC review.

## Expected Behavior

1. **Activates IaC and AWS guidance:** Applies `infrastructure-as-code` and AWS least-privilege guidance.
2. **Flags broad IAM:** Identifies broad actions and wildcard resources as unacceptable for the stated use case.
3. **Scoped fix:** Recommends specific S3 read actions on the prefix, DynamoDB write actions on the table, and KMS decrypt on the key.
4. **Resource scoping:** Requires concrete ARNs and optional conditions where useful.
5. **Plan/security evidence:** Requires plan review and IaC security scan before apply.
6. **Governance:** Treats privilege expansion as high risk or approval-gated.
7. **No secrets:** Checks that credentials or secrets are not embedded in module variables/outputs.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| IaC/AWS guidance activated | 15% | Uses infrastructure and AWS standards |
| Broad IAM finding | 25% | Flags `s3:*`, `dynamodb:*`, `kms:*`, `*` resources |
| Scoped remediation | 25% | Recommends exact scoped actions/resources |
| Plan/scan evidence | 10% | Requires plan and IaC scan |
| Governance | 15% | High-risk or approval-gated |
| Secret safety | 10% | Mentions no credentials/secrets in vars/outputs |

**Critical failure:** Approves the wildcard policy because the batch job is internal.
