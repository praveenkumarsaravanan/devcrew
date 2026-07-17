---
name: devops-plan
description: Deployment strategy and infrastructure plan from a DevOps Engineer perspective
---

# DevOps Plan

Design the deployment strategy and infrastructure plan for the current codebase or a recent change. Adopt the **DevOps Engineer** perspective.

1. **Deployment strategy** — Recommend rolling, canary, blue-green, or feature-flag deployment. Justify the choice based on risk, rollback speed, and the nature of the change. Default to canary for changes touching auth, payments, or data schemas.
2. **CI/CD pipeline** — Propose pipeline stages ordered by fail-fast cost: lint → unit tests → security scan → build → integration tests → container scan → deploy staging → E2E/smoke → deploy production. Flag missing stages.
3. **Infrastructure changes** — List new services, database migrations, config updates, or networking changes required. State "none" explicitly if no infra changes are needed.
4. **Rollback plan** — Define exact rollback steps, estimated time-to-revert, data implications, and the signals (error rate, latency, alerts) that trigger rollback.
5. **Health checks** — Verify liveness and readiness probes are configured. Specify endpoints and thresholds.
6. **Environment impact** — Assess how dev, staging, and production are each affected. Flag any environment-specific configuration.
7. **Risk assessment** — Rate deployment risk (Low/Medium/High) based on scope, blast radius, reversibility, and test coverage.
8. **AWS review** — If AWS resources are involved, activate `aws-application-development` and review IAM least privilege, KMS/encryption, S3 public access, VPC/security groups, retry/DLQ behavior, CloudWatch alarms, tags, cost, quotas, and secrets handling.
9. **IaC and image evidence** — If infrastructure or image builds are involved, activate `infrastructure-as-code` and `image-build`. Verify remote state and locking, plan/diff/change-set review, drift detection, no secrets in state/vars/images, image scanning, immutable artifact promotion, environment parity, and rollback or forward-fix strategy.
10. **Release evidence handoff** — For medium/high-risk work, activate `release-evidence` and summarize which evidence the DevOps plan supplies: deployment strategy, pipeline checks, IaC/image evidence, rollback steps, environment impact, monitoring handoff, and remaining gaps.

Flag anti-patterns: snowflake environments, manual deployment steps, shared databases across services, missing rollback paths, and pipelines over 30 minutes.
