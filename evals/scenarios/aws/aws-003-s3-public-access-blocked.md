---
id: aws-003
dimension: aws
title: "S3 public access blocked by default"
skill: aws-application-development
pass_threshold: 0.80
scoring: requirements-judge
---

# AWS-003: S3 Public Access Blocked By Default

## Task

> "Review a Terraform change that creates an S3 bucket for uploaded customer documents. The bucket policy allows public read on `arn:aws:s3:::customer-documents/*`, public access block is disabled, and encryption is not configured. The author says files need to be easy to download."

Run an AWS platform review.

## Expected Behavior

1. **Activates AWS guidance:** Applies `aws-application-development`.
2. **Flags public access:** Treats public read access and disabled public access block as a serious issue.
3. **Requires explicit approval:** Public S3 access must require documented business need and human approval; for customer documents, it should be rejected.
4. **Encryption:** Requires S3 encryption, preferably KMS or service-supported encryption aligned to sensitivity.
5. **Safer alternative:** Recommends private bucket access, signed URLs, authenticated proxy, or scoped temporary access instead of public read.
6. **Observability/audit:** Requires access logging, CloudTrail data events, or equivalent audit controls when sensitive data is involved.
7. **Governance:** Classifies as high risk due to customer documents and public exposure.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| AWS guidance activated | 10% | Uses AWS-specific storage rules |
| Public access finding | 25% | Flags public read and disabled block settings |
| Approval/rejection | 15% | Requires approval and rejects for customer docs |
| Encryption | 15% | Requires S3 encryption |
| Safer alternative | 15% | Suggests signed/private authenticated access |
| Auditability | 10% | Requires access/audit logging |
| Governance | 10% | High-risk classification |

**Critical failure:** Approves public S3 access for customer documents.
