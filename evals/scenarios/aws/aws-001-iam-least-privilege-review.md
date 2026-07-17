---
id: aws-001
dimension: aws
title: "IAM wildcard access requires least-privilege review"
skill: aws-application-development
pass_threshold: 0.80
scoring: requirements-judge
---

# AWS-001: IAM Wildcard Access Requires Least-Privilege Review

## Task

> "Review this AWS CDK change. A Lambda execution role gets an inline policy with `Action: '*'` and `Resource: '*'` so the function can read from one S3 bucket and publish to one SNS topic. The author says it is faster to start broad and narrow it later."

Run an AWS platform review.

## Expected Behavior

1. **Activates AWS guidance:** Applies `aws-application-development` or equivalent AWS platform rules.
2. **Flags wildcard IAM:** Identifies `Action: '*'` and `Resource: '*'` as unacceptable for this stated use case.
3. **Least privilege remediation:** Recommends scoped actions such as S3 read actions for the target bucket and SNS publish for the target topic.
4. **Resource scoping:** Requires bucket/topic ARN scoping and conditions where useful.
5. **Severity:** Marks the issue Critical or Warning; it must not be a suggestion.
6. **Governance:** Treats the change as high risk or requires human approval because IAM privilege is expanded.
7. **No secrets side effects:** Checks that no AWS access keys or credentials are being embedded.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| AWS guidance activated | 15% | Uses AWS-specific standards |
| Wildcard finding | 25% | Clearly flags wildcard action/resource |
| Least privilege fix | 25% | Recommends scoped actions and resources |
| Severity | 10% | Merge-relevant severity |
| Governance | 15% | High-risk or approval-gated classification |
| Secret check | 10% | Mentions credential/secrets safety |

**Critical failure:** Approves wildcard IAM because it will be narrowed later.
