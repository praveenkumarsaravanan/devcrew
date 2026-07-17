---
name: aws-baseline
description: Always-on AWS safety checks for IaC, serverless, event-driven, and managed-service configuration
applyTo: "**/*.{tf,tfvars,json,yml,yaml,ts,tsx,js,jsx,py,go,java,template,cfn}"
---

# AWS Baseline

Apply these rules when a file defines or configures AWS resources, AWS SDK usage, serverless infrastructure, CDK/CloudFormation/Terraform/Pulumi/SAM templates, deployment workflows, or AWS examples.

## Required Checks

- IAM policies must be least privilege. Wildcard actions or resources require explicit justification and should be narrowed.
- Secrets must not appear in source, IaC variables, template outputs, examples, environment files, container images, or logs.
- Sensitive data stores need encryption at rest with KMS or the service's supported encryption controls.
- S3 public access is blocked by default. Public buckets, public ACLs, and public bucket policies require explicit approval and documentation.
- Security groups and network policies must avoid broad ingress such as `0.0.0.0/0` unless it is a deliberate public HTTP/HTTPS entrypoint.
- Event-driven flows need retry limits, DLQs or failure destinations, and idempotent handlers.
- CloudWatch logs, metrics, alarms, and runbooks must exist for production AWS workloads.
- Resources must include environment, service, owner, and cost tags or the project's established equivalent.
- Cost drivers and service quotas must be considered for high-volume, always-on, or data-heavy workloads.

## Do Not Allow

- `Action: "*"` or `Resource: "*"` without a narrow, documented exception.
- S3 buckets with public ACLs, public policies, or disabled public-access-block settings by accident.
- Lambda/SQS/EventBridge/SNS/Step Functions flows with retries but no DLQ/failure handling.
- Hardcoded AWS access keys, secret access keys, session tokens, passwords, certificates, or private keys.
- Raw secrets, tokens, authorization headers, cookies, or PII in CloudWatch logs.
- Production infrastructure changes with no rollback or mitigation path.
