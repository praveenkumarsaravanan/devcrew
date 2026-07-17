# Generic Platform Support

DevCrew is intentionally generic. It supports common platform and delivery concerns without becoming tied to one company, cloud, framework, or regulated domain.

## Capability Areas

| Area | What DevCrew adds | Primary primitives |
|---|---|---|
| Engineering Flow | Right-sized lifecycle with council routing | `/engineering-flow`, `team-workflow`, `council-chair` |
| TypeScript/Node | Runtime validation, typed config, async safety, logging, idempotency | `typescript-node-standards`, `typescript-node-reviewer` |
| AWS | IAM, encryption, S3 exposure, async failure handling, observability, cost, quotas | `aws-application-development`, `aws-platform-reviewer` |
| Infrastructure and images | State, plan evidence, drift, secrets, scans, rollback, immutable promotion | `infrastructure-as-code`, `image-build`, `infrastructure-reviewer` |
| Data platform | Source contracts, validation, quarantine, mapping, replay, reconciliation, runbooks | `data-ingestion`, `data-mapping-validation`, `operational-feed-runbook`, `data-platform-reviewer` |
| Contracts | OpenAPI, AsyncAPI, webhooks, events, protobuf, GraphQL, SDK, file/feed compatibility | `interoperability-contracts`, `interoperability-reviewer`, `/contract-review` |
| Regulated data | Classification, minimization, redaction, synthetic data, audit, retention | `regulated-data-handling`, `regulated-data-reviewer` |
| Release readiness | Evidence bundles, rollback, monitoring, approvals, waivers | `release-evidence`, `release-evidence-reviewer`, `/release-evidence` |

## Routing Model

Project detection finds signals in dependencies, files, directories, and user intent. Engineering Flow then activates only the relevant standards and reviewers.

Examples:

| Signal | Routing |
|---|---|
| `package.json` with Express and queue consumer | TypeScript/Node backend standards |
| `serverless.yml`, SQS, Lambda, or CDK | AWS application guidance |
| `.tf`, `cdk.json`, Helm chart, Dockerfile, Packer | Infrastructure/image guidance |
| `feeds/`, `mappings/`, `schemas/`, replay scripts | Data platform guidance |
| `openapi.yaml`, `asyncapi.yaml`, `*.proto`, `webhooks/` | Interoperability contract guidance |
| `privacy/`, `pii/`, `payment/`, audit/retention changes | Regulated data guidance |

## Design Principles

- Protocols are examples, not identity. OpenAPI and AsyncAPI are contract forms; the real skill is interoperability.
- Regulated data is domain-neutral. Project policy decides legal nuance; DevCrew enforces durable engineering controls.
- Release readiness is evidence-backed. Medium and high-risk releases need proof, not claims.
- Post-merge work stays opt-in. DevOps, release, monitoring, and incident prompts run when the developer chooses.
- Production triage is separate from Engineering Flow: `/triage` (hypothesis card), `/postmortem` (close-out), `/incident-response` (severity/comms). See [devcrew-index.md](./devcrew-index.md#production-issue-triage-separate-from-engineering-flow).
- Quick fixes stay light. Specialist lanes activate only when the task or diff signals them.

## Recommended Usage

Start with Engineering Flow for build work:

```text
/engineering-flow Add a webhook for order status changes
```

Use specialist prompts when you want focused planning or review:

```text
/contract-review Review the partner webhook payload migration
/release-evidence Build evidence for the high-risk auth release
/monitoring-plan Add observability for the ingestion pipeline
```

Use `/convene-council` when you want options before implementation:

```text
/convene-council Compare API versioning options for the partner contract
```
