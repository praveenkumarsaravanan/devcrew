---
name: aws-application-development
description: >
  AWS application development guidance for serverless, container, event-driven,
  and managed-service workloads. Covers IAM least privilege, encryption, S3,
  networking, observability, retries, DLQs, tagging, cost, quotas, and safe IaC.
---

# AWS Application Development

## Trigger

Activate this skill when:

- The user asks to design, build, review, or deploy AWS application infrastructure.
- The project uses AWS services such as Lambda, API Gateway, ECS, EKS, S3, DynamoDB, RDS, EventBridge, SQS, SNS, Step Functions, CloudWatch, KMS, Secrets Manager, IAM, CDK, CloudFormation, Terraform, Pulumi, or SAM.
- `project-detection` finds AWS configuration, IaC, serverless files, CDK apps, or AWS SDK usage.
- DevOps, SRE, Engineering Flow, or an AWS platform reviewer needs AWS-specific safety guidance.

Do not activate this skill for non-AWS cloud work unless the user is explicitly comparing AWS options.

## Workflow

### 1. Identify The Workload Shape

Classify the AWS workload before reviewing details:

| Shape | Common services | Key review focus |
|---|---|---|
| Serverless API | API Gateway, Lambda, DynamoDB, Cognito | Auth, throttling, IAM, cold starts, logs, alarms |
| Event-driven worker | EventBridge, SQS, SNS, Lambda, Step Functions | Idempotency, retries, DLQs, poison messages |
| Container service | ECS, EKS, ALB, ECR, CloudWatch | network boundaries, secrets, scaling, health checks |
| Data/storage workflow | S3, KMS, Glue, Athena, RDS, DynamoDB | encryption, access policies, retention, public access |
| Platform/IaC change | CDK, CloudFormation, Terraform, Pulumi | least privilege, drift, secrets, environment parity |

### 2. Security And Identity

- Apply IAM least privilege. Avoid wildcard `Action: "*"`, `Resource: "*"`, and broad managed policies unless explicitly justified and time-bound.
- Prefer resource-scoped IAM policies with condition keys such as account, region, principal, tag, source ARN, or VPC endpoint where applicable.
- Use role-based access for compute. Do not embed long-lived AWS access keys in source, IaC, container images, Lambda environment variables, or examples.
- Use Secrets Manager, Parameter Store SecureString, or the platform's secret manager for secrets. Reference secret ARNs or names, not values.
- Require KMS encryption for sensitive data at rest. Use customer-managed KMS keys when access separation, audit, or rotation requirements justify them.
- Enable CloudTrail for auditability and make sure security-relevant actions are logged.

### 3. Storage, Data, And Network Boundaries

- Block S3 public access by default. Any public bucket, public object ACL, or public bucket policy requires explicit user approval and documented business need.
- Enable S3 encryption, versioning when recovery matters, lifecycle rules when retention matters, and access logging or CloudTrail data events when auditability matters.
- Keep databases, queues, and internal services private unless a public endpoint is explicitly required.
- Review VPC, subnet, security group, route table, and load balancer exposure. Avoid `0.0.0.0/0` ingress except public HTTP/HTTPS entrypoints with compensating controls.
- Use TLS for service-to-service and external communication.

### 4. Eventing, Retries, And Idempotency

- Every SQS, SNS, EventBridge, Lambda, and Step Functions flow needs a retry and failure strategy.
- Configure DLQs or failure destinations for async Lambda, SQS consumers, EventBridge targets, and Step Functions failure paths.
- Make handlers idempotent before enabling retries. Use event IDs, idempotency keys, conditional writes, processed-event records, or natural unique constraints.
- Distinguish retryable and non-retryable failures. Validation failures should not retry forever.
- Set visibility timeouts longer than the handler's worst-case processing time, and align Lambda timeout with queue visibility and retry settings.
- For FIFO queues, document ordering and deduplication requirements.

### 5. Observability And Operations

- Emit CloudWatch logs with structured fields and redaction. Do not log secrets, tokens, authorization headers, cookies, or raw PII.
- Define CloudWatch metrics and alarms for errors, latency/duration, throttles, retries, DLQ depth, queue age, iterator age, concurrency, saturation, and dependency failures.
- Add dashboards for user-facing APIs and critical event flows.
- Propagate trace context where possible and enable X-Ray or OpenTelemetry tracing for high-value flows.
- Define runbook-ready alerts: owner, impact, threshold, first diagnostic steps, and rollback or mitigation action.

### 6. Environment, Cost, And Quotas

- Tag AWS resources with at least `service`, `environment`, `owner`, and `cost-center` or project equivalent.
- Separate dev, staging, and production through accounts, environments, or isolated stacks. Avoid shared production credentials.
- Check service quotas for Lambda concurrency, API Gateway throttles, SQS throughput, Step Functions limits, DynamoDB capacity, ENI limits, and CloudWatch costs.
- Estimate cost drivers before adding always-on compute, high-volume logs, large data scans, cross-region traffic, or high-cardinality metrics.
- Use budgets, anomaly detection, or cost alerts for new or high-volume services.

### 7. IaC And Deployment Safety

- Define AWS resources in IaC. Avoid console-only changes.
- Never put secrets in IaC variables, state files, examples, templates, or generated outputs.
- Use parameterized environment configuration rather than copied templates.
- Review generated IAM policies, synthesized templates, and deployment diffs before apply/deploy.
- Add rollback strategy for application and infrastructure changes. For destructive changes, require explicit human approval.

## Output

For AWS design or review work, produce:

1. **Workload classification** - Shape, services involved, and environment.
2. **Security review** - IAM, secrets, encryption, public exposure, and auditability.
3. **Reliability review** - retries, DLQs, idempotency, timeouts, quotas, and rollback.
4. **Observability plan** - logs, metrics, alarms, dashboards, traces, and runbooks.
5. **Cost and quota notes** - likely cost drivers and quota risks.
6. **Required fixes** - Critical/Warning/Suggestion findings with concrete remediation.

## Guardrails

- **Never approve wildcard IAM without justification, scope reduction, and a follow-up.**
- **Never approve public S3 access by default.**
- **Never approve async/event-driven AWS flows without DLQ or failure-destination handling.**
- **Never approve retries without an idempotency strategy.**
- **Never place secrets in IaC, examples, environment files, container images, or logs.**
- **Never skip cost and quota review for high-volume or always-on AWS resources.**

## See Also

- **`aws-platform-reviewer`** - AWS-specific review agent for platform and infrastructure changes.
- **`devops-engineer`** - Deployment and IaC planning; activates this skill for AWS work.
- **`sre`** - Observability, SLOs, alerting, and runbook planning; activates this skill for AWS workloads.
- **`team-workflow`** - Pre-merge Engineering Flow; uses this skill when AWS app resources are part of the task.
