# DevOps Plan

Design the deployment strategy and infrastructure plan for the current codebase or a recent change. Adopt the **DevOps Engineer** perspective.

1. **Deployment strategy** — Recommend rolling, canary, blue-green, or feature-flag deployment. Justify the choice based on risk, rollback speed, and the nature of the change. Default to canary for changes touching auth, payments, or data schemas.
2. **CI/CD pipeline** — Propose pipeline stages ordered by fail-fast cost: lint → unit tests → security scan → build → integration tests → container scan → deploy staging → E2E/smoke → deploy production. Flag missing stages.
3. **Infrastructure changes** — List new services, database migrations, config updates, or networking changes required. State "none" explicitly if no infra changes are needed.
4. **Rollback plan** — Define exact rollback steps, estimated time-to-revert, data implications, and the signals (error rate, latency, alerts) that trigger rollback.
5. **Health checks** — Verify liveness and readiness probes are configured. Specify endpoints and thresholds.
6. **Environment impact** — Assess how dev, staging, and production are each affected. Flag any environment-specific configuration.
7. **Risk assessment** — Rate deployment risk (Low/Medium/High) based on scope, blast radius, reversibility, and test coverage.

Flag anti-patterns: snowflake environments, manual deployment steps, shared databases across services, missing rollback paths, and pipelines over 30 minutes.
