# AWS Serverless Starter

Opinionated scaffold for a generic AWS serverless application. Use this for API Gateway + Lambda, SQS/EventBridge workers, SNS fanout, Step Functions orchestration, and DynamoDB/S3-backed workflows. Keep provider choices generic and avoid company-specific topology.

## Baseline Services

| Concern | Default option |
|---|---|
| Compute | Lambda |
| API | API Gateway HTTP API or REST API |
| Events | EventBridge, SQS, SNS |
| Orchestration | Step Functions when multi-step state is explicit |
| Storage | DynamoDB or S3 based on access pattern |
| Secrets | Secrets Manager or SSM SecureString |
| Encryption | KMS-backed service encryption |
| Observability | CloudWatch logs, metrics, alarms, dashboards; X-Ray/OpenTelemetry where useful |

## Directory Structure

```text
+-- src/
|   +-- handlers/
|   +-- workers/
|   +-- workflows/
|   +-- schemas/
|   +-- config/
|   +-- observability/
+-- infra/
|   +-- app/                  # CDK/SAM/CloudFormation/Terraform entrypoint
|   +-- stacks/
|   +-- parameters/
+-- tests/
|   +-- unit/
|   +-- integration/
+-- docs/
|   +-- runbooks/
+-- .env.example
+-- README.md
```

## Required Starter Patterns

- All handlers validate runtime inputs before business logic.
- IAM policies are scoped by action and resource. No wildcard admin policy in starter examples.
- Lambda roles reference secrets by ARN/name and never include secret values.
- SQS/EventBridge/Lambda async flows include DLQ or failure destination configuration.
- Worker handlers are idempotent before retry is enabled.
- S3 buckets block public access, enable encryption, and define lifecycle rules when retention matters.
- Sensitive storage uses KMS or service-managed encryption.
- Public endpoints have auth, throttling/rate limiting, request size limits, and safe CORS.
- CloudWatch alarms cover errors, duration/latency, throttles, DLQ depth, queue age, and concurrency where applicable.
- Resources are tagged with `service`, `environment`, `owner`, and cost attribution.

## Example Non-Secret Configuration

```text
SERVICE_NAME=example-service
ENVIRONMENT=dev
AWS_REGION=us-east-1
LOG_LEVEL=info
```

Do not include AWS access keys, passwords, tokens, private keys, or real ARNs that expose an internal account in examples.

## Deployment Safety

- Run IaC diff/plan before deploy.
- Promote the same artifact across environments.
- Use environment-specific parameters, not copied templates.
- Define rollback or mitigation before production deploy.
- Check quotas for Lambda concurrency, API Gateway throttling, SQS throughput, Step Functions transitions, and CloudWatch log volume.
