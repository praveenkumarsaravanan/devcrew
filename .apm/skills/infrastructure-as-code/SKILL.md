---
name: infrastructure-as-code
description: >
  Infrastructure as Code guidance for Terraform, OpenTofu, CDK, CloudFormation,
  Pulumi, SAM, Helm, and Kubernetes manifests. Covers remote state, locking,
  plans, drift detection, secrets safety, environment parity, rollback, and review.
---

# Infrastructure As Code

## Trigger

Activate this skill when:

- The user asks to create, review, deploy, or modify infrastructure as code.
- Files include Terraform/OpenTofu, CDK, CloudFormation, Pulumi, SAM, Helm, Kubernetes, or deployment manifests.
- DevOps, release readiness, Engineering Flow, or an infrastructure reviewer needs IaC-specific safety guidance.
- A change affects cloud resources, networking, IAM, storage, databases, queues, load balancers, or deployment environments.

## Workflow

### 1. Identify IaC Scope

Classify the change:

| Scope | Examples | Review focus |
|---|---|---|
| Low blast radius | Tags, non-prod variable tweaks, dashboard text | formatting, parity, drift |
| App infrastructure | queues, functions, tasks, alarms, buckets, databases | security, rollback, observability |
| Shared platform | VPC, IAM, KMS, clusters, state backends | high-risk review, approval, staged rollout |
| Destructive change | deletion, replacement, data migration, policy removal | explicit approval, backup, rollback/forward-fix |

### 2. State, Locking, And Planning

- Terraform/OpenTofu state must be remote for team/shared infrastructure and must use locking.
- State files must never contain secrets. Avoid writing secret values into variables, outputs, resource names, tags, or generated files.
- Run a plan/diff before apply/deploy:
  - Terraform/OpenTofu: `plan`.
  - CDK: `diff`.
  - CloudFormation/SAM: change set.
  - Pulumi: `preview`.
  - Kubernetes/Helm: template/diff/server-side dry run where available.
- Review replacement, deletion, and privilege-expansion actions before apply.
- Store plan evidence or a concise plan summary for high-risk or production changes.

### 3. Security And Policy

- Apply least privilege for IAM and resource policies.
- Use KMS/encryption where the platform supports it for sensitive data.
- Restrict public exposure. Public load balancers, public buckets, broad ingress, and cross-account access need explicit rationale.
- Keep secrets in a secret manager. IaC should reference secret names or ARNs, never values.
- Scan IaC with tools such as Checkov, Trivy config, tfsec, Terrascan, cdk-nag, kube-score, kube-linter, or the project's equivalent.

### 4. Environment Parity

- Use the same modules/templates across dev, staging, and production with parameterized inputs.
- Avoid copied environment-specific templates that drift.
- Keep provider versions, module versions, and lock files pinned.
- Tag resources with service, environment, owner, and cost attribution.
- Make non-prod smaller through parameters, not different architecture.

### 5. Drift And Change Management

- Run drift detection on a schedule for production/shared infrastructure.
- Treat manual console changes as drift unless documented as emergency remediation.
- Before changing production, identify dependencies, replacement behavior, expected downtime, and rollback or forward-fix path.
- For destructive or irreversible changes, require backup verification and explicit human approval.

### 6. Rollback And Forward-Fix

- Prefer reversible changes and staged rollout.
- Document rollback commands, state restoration approach, and when rollback is unsafe.
- For data stores and schemas, define forward-fix steps when rollback could lose data.
- For policy/network changes, define an emergency mitigation path that restores access safely.

## Output

For IaC work, produce:

1. **Scope and risk** - Resources touched, environment, blast radius, risk level.
2. **Plan evidence** - Plan/diff/change-set summary and high-risk actions.
3. **Security findings** - IAM, secrets, encryption, public exposure, policy issues.
4. **State and drift** - Remote state, locking, drift detection, state safety.
5. **Rollback/forward-fix** - Exact mitigation path and approval needs.
6. **Required fixes** - Critical/Warning/Suggestion items.

## Guardrails

- **Never apply infrastructure without reviewing a plan/diff first.**
- **Never approve local state for shared or production infrastructure.**
- **Never put secrets in variables, tfvars, outputs, state, templates, tags, or examples.**
- **Never approve destructive production changes without explicit approval and rollback or forward-fix plan.**
- **Never approve broad IAM, public storage, or broad network ingress without documented rationale.**
- **Never let environments drift through copy-pasted templates.**

## See Also

- **`infrastructure-reviewer`** - Reviewer agent for IaC and image-build changes.
- **`image-build`** - Container and AMI build hygiene, scanning, and immutable artifact promotion.
- **`aws-application-development`** - AWS-specific platform guidance that complements IaC review.
- **`devops-engineer`** - Deployment and infrastructure planning.
