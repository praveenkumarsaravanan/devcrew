# Terraform AWS Starter

Opinionated starter for AWS infrastructure using Terraform or OpenTofu. Use this when the user wants AWS IaC with remote state, environment parity, least privilege, and reviewable plans.

## Directory Structure

```text
+-- infra/
|   +-- modules/
|   |   +-- service/
|   +-- envs/
|   |   +-- dev/
|   |   |   +-- main.tf
|   |   |   +-- variables.tf
|   |   |   +-- backend.tf
|   |   |   +-- terraform.tfvars.example
|   |   +-- staging/
|   |   +-- prod/
|   +-- policies/
|   +-- README.md
+-- scripts/
|   +-- terraform-plan.sh
```

## Backend And Locking

- Configure remote state for every shared environment.
- Use locking. For AWS, S3 state plus DynamoDB locking or the team's equivalent is required.
- Keep state bucket private, encrypted, versioned, and access-controlled.
- Never store secret values in state, variables, tfvars, outputs, resource names, or tags.

## Required Files

`backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_STATE_BUCKET"
    key            = "service/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_WITH_LOCK_TABLE"
    encrypt        = true
  }
}
```

`terraform.tfvars.example`:

```hcl
service_name = "example-service"
environment  = "dev"
owner        = "team-name"
cost_center  = "project-code"
```

Do not include passwords, tokens, access keys, private keys, or real production identifiers in examples.

## CI/CD Pipeline

Minimum pipeline:

1. Format: `terraform fmt -check`.
2. Validate: `terraform validate`.
3. Security scan: Checkov, Trivy config, tfsec, or project equivalent.
4. Plan: generate and review plan for the target environment.
5. Apply: gated by approval for production.
6. Drift detection: scheduled plan or drift job for production/shared environments.

## Review Checklist

- Remote state and locking configured.
- Provider and module versions pinned.
- Plan reviewed before apply.
- IAM scoped by action/resource.
- S3 public access blocked by default.
- KMS/encryption configured where data sensitivity requires it.
- Tags include service, environment, owner, and cost attribution.
- Rollback or forward-fix documented for production changes.
