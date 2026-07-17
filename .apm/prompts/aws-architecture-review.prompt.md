# AWS Architecture Review

Review an AWS application design, IaC change, or deployment plan from the AWS Platform Reviewer perspective.

## Inputs

- Workload description, diagram, IaC diff, or changed files.
- Target environment: dev, staging, production, or shared platform.
- Known services involved: Lambda, API Gateway, ECS, EKS, S3, DynamoDB, RDS, EventBridge, SQS, SNS, Step Functions, CloudWatch, KMS, IAM, Secrets Manager, or others.

## Review Steps

1. Classify the workload shape: serverless API, event-driven worker, container service, data/storage workflow, or platform/IaC change.
2. Activate `aws-application-development`.
3. Review IAM least privilege, secrets handling, KMS/encryption, S3 public access, VPC/security groups, and audit logging.
4. Review reliability: retries, DLQs/failure destinations, idempotency, timeouts, rollback, service quotas, and failure modes.
5. Review observability: CloudWatch logs, metrics, alarms, dashboards, traces, and runbooks.
6. Review environment tagging, cost drivers, and quota risks.
7. Identify high-risk items that need human approval before implementation or deploy.

## Output

Return findings first, ordered by severity, with file/line references when available.

End with:

- AWS workload summary.
- Required fixes.
- Operational readiness verdict.
- Cost/quota notes.
- Overall recommendation: Approve or Request Changes.
