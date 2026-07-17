---
name: project-detection
description: >
  Inspects the current workspace to classify the project as backend, frontend,
  fullstack, infrastructure, or data platform, detects AWS, interoperability
  contract, and regulated-data signals, and detects platform configuration
  (task tracker, execution mode, git platform). Supports ask-once persistence via .project-context.md.
  Other skills and agents reference this to scope their behavior to the correct discipline.
---

# Project Detection

## Trigger

Activate this skill when:

- Another skill (e.g., `team-workflow`) instructs you to detect the project type before proceeding.
- The user asks to "implement a feature," "build this," or "develop this" without specifying backend or frontend.
- You need to determine which team workflow to activate.
- The `team-workflow` Phase 0 needs to load or detect platform configuration (task tracker, execution mode, git platform).

Do NOT activate when the user explicitly states the discipline: "build a backend service" or "create a React component" — trust their intent.

## Workflow

Inspect the workspace in this order. Stop as soon as you have high confidence.

### Step 0: Load Project Context

Before any detection, check for persisted project configuration:

1. Look for `.project-context.md` at the project root.
2. **If found:** Parse the stored values (discipline, tracker, execution mode, git platform, stack). Present a one-line summary to the user:
   > "Using **[discipline]** project with **[tracker]** tracker, **[execution]** execution, **[git-platform]**. Change? [y/N]"
   - If the user confirms (or presses Enter), return the stored values and **skip all detection steps**.
   - If the user requests a change, proceed with the relevant detection steps to update only the changed values.
3. **If not found:** Proceed with Step 1 through Step 8. After all detection completes, call the `memory-management` skill to persist results to `.project-context.md`.

### Step 1: Check for Explicit User Context

If the user's request names a specific layer — "API endpoint," "database migration," "React component," "CSS layout" — trust that and skip workspace inspection.

### Step 2: Scan Project Root Files

Look for these markers at the project root (or one level deep):


| Signal                                                                         | Indicates                             |
| ------------------------------------------------------------------------------ | ------------------------------------- |
| `pom.xml`, `build.gradle`, `build.gradle.kts`                                  | Backend (Java/Kotlin)                 |
| `go.mod`, `go.sum`                                                             | Backend (Go)                          |
| `requirements.txt` or `pyproject.toml` with Flask, Django, FastAPI, SQLAlchemy | Backend (Python)                      |
| `Cargo.toml`                                                                   | Backend (Rust)                        |
| `*.csproj`, `*.sln` with ASP.NET references                                    | Backend (C#/.NET)                     |
| `application.yml`, `application.properties`                                    | Backend (Spring Boot)                 |
| `Dockerfile`, `Containerfile`, `docker-compose.yml` without frontend service   | Backend, Infrastructure, or Image Build |
| `next.config.js`, `next.config.mjs`, `next.config.ts`                          | Fullstack (Next.js, Node backend)     |
| `nuxt.config.ts`                                                               | Fullstack (Nuxt)                      |
| `angular.json`                                                                 | Frontend (Angular)                    |
| `vite.config.ts`, `vite.config.js` without server framework                    | Frontend                              |
| `svelte.config.js`                                                             | Frontend (SvelteKit may be fullstack) |
| `package.json`                                                                 | Inspect further (Step 3)              |
| `terraform/`, `*.tf`, `*.tfvars`, `*.hcl`, `pulumi/`, `cdk.json`               | Infrastructure as Code (inspect cloud provider) |
| `serverless.yml`, `serverless.ts`, `template.yaml`, `samconfig.toml`           | Infrastructure or Backend (AWS serverless) |
| `cdk.context.json`, `lib/*stack.ts`, `stacks/`, `constructs/`                  | Infrastructure or Backend (AWS CDK)   |
| `packer/`, `*.pkr.hcl`, `packer.json`                                          | Image Build (AMI)                     |
| `helm/`, `Chart.yaml`, `kustomization.yaml`                                    | Infrastructure                        |
| `schemas/`, `samples/`, `mappings/`, `data-quality/`, `runbooks/feeds/`        | Data Platform                         |
| `openapi.yml`, `openapi.yaml`, `openapi.json`, `asyncapi.yml`, `asyncapi.yaml`, `*.proto`, `graphql.schema.*` | Interoperability Contract signal |
| `contracts/`, `webhooks/`, `events/`, `partner-api/`                           | Interoperability Contract signal      |
| `fhir/`, `input/fsh/`, `*.fsh`, `simplifier.json`, `ig.ini`                  | FHIR / HL7 Implementation Guide signal |
| `package.fhir.json`, `fhir-settings.json`                                      | FHIR NPM / IG tooling signal          |


### Step 3: Inspect `package.json` Dependencies

If a `package.json` exists, read its `dependencies` and `devDependencies`:


| Dependency pattern                                             | Indicates                |
| -------------------------------------------------------------- | ------------------------ |
| `react`, `react-dom`, `vue`, `@angular/core`, `svelte`         | Frontend                 |
| `express`, `fastify`, `koa`, `hapi`, `@hapi/hapi`, `nestjs`, `@nestjs/*` | Backend (Node.js) |
| `next`, `nuxt`, `remix`, `@remix-run/*`                        | Fullstack                |
| `prisma`, `typeorm`, `sequelize`, `knex`, `drizzle-orm`        | Backend (database layer; inspect surrounding stack) |
| `bullmq`, `agenda`, `bee-queue`, `amqplib`, `kafkajs`          | Backend (Node.js worker or queue consumer) |
| `@apache-arrow/*`, `parquetjs`, `csv-parse`, `fast-csv`, `ajv` | Data ingestion or validation |
| `@asyncapi/*`, `openapi-types`, `swagger-jsdoc`, `protobufjs`, `@bufbuild/*`, `graphql` | API or interoperability contracts |
| `fhir`, `@types/fhir`, `fhir-kit-client`, `node-fhir-server-core`, `@bonfhir/core`, `hapi-fhir` | FHIR / HL7 health interoperability |
| `aws-sdk`, `@aws-sdk/*`, `aws-cdk-lib`, `constructs`, `serverless` | AWS application or infrastructure |
| `tailwindcss`, `sass`, `styled-components`, `@emotion/*`       | Frontend (styling)       |
| `webpack`, `vite`, `esbuild`, `rollup` (alone, no server deps) | Frontend (build tooling) |


If both frontend and backend dependencies are present, classify as **fullstack**.

### Step 4: Inspect Directory Structure


| Directory pattern                                                       | Indicates          |
| ----------------------------------------------------------------------- | ------------------ |
| `src/controllers/`, `src/services/`, `src/repositories/`, `src/models/` | Backend            |
| `src/routes/` with handler files (not page files)                       | Backend            |
| `src/workers/`, `src/jobs/`, `src/queues/`, `src/consumers/`             | Backend            |
| `src/components/`, `src/pages/`, `src/views/`, `src/layouts/`           | Frontend           |
| `src/hooks/` with React/Vue hooks                                       | Frontend           |
| `public/`, `static/`, `assets/` with HTML/CSS/images                    | Frontend           |
| `migrations/`, `seeds/`, `db/`                                          | Backend (database) |
| `infra/`, `infrastructure/`, `cdk/`, `serverless/`, `.aws/`              | Infrastructure or AWS platform |
| `images/`, `packer/`, `docker/`, `containers/`                            | Image Build or Infrastructure |
| `data/`, `feeds/`, `pipelines/`, `ingestion/`, `mapping/`, `mappings/`, `reconciliation/`, `replay/`, `backfill/`, `schemas/`, `samples/` | Data Platform |
| `contracts/`, `webhooks/`, `events/`, `protobuf/`, `proto/`, `openapi/`, `asyncapi/`, `schemas/partner/` | Interoperability Contract signal |
| `fhir/`, `profiles/`, `terminology/`, `capabilitystatement/`, `structuredefinition/`, `.fhir/` | FHIR / HL7 signal |
| `privacy/`, `regulated/`, `compliance/`, `pii/`, `phi/`, `payments/`, `billing/`, `sensitive/` | Regulated Data signal |
| `cmd/`, `internal/`, `pkg/`                                             | Backend (Go)       |
| `src/main/java/`, `src/main/resources/`                                 | Backend (Java)     |
| Both backend and frontend patterns                                      | Fullstack          |


### Step 5: Check for Monorepo Structure

If the project has `packages/`, `apps/`, or workspace configuration (`pnpm-workspace.yaml`, `lerna.json`, `turbo.json`):

1. List the workspace directories.
2. Classify each workspace independently using Steps 2–4.
3. Report the overall structure: "This is a monorepo with backend (`apps/api`) and frontend (`apps/web`) workspaces."
4. Ask the user which workspace the current task targets.

### Step 6: Task Tracker Detection

Detect which task tracking system the project uses:

1. Check which MCP servers are available in the current environment:
   - **Atlassian MCP** → Jira is available
   - **GitHub MCP** → GitHub Issues is available
   - **Linear MCP** → Linear is available
2. If multiple trackers are available, ask the user to choose.
3. If only one tracker is available, confirm with the user.
4. If no tracker MCP is available, set tracker to `none`.
5. **If Jira selected:** Also ask for the Jira project key (e.g., `PROJ`).
6. **If GitHub Issues selected:** Confirm the repository (from `git remote -v`).

Store as: `tracker: github-issues | jira | linear | azure-devops | none`

### Step 7: Execution Mode Detection

Ask the user how implementation work should be executed:

| Mode | Description | When to use |
|------|-------------|-------------|
| `local` | Spawn subagents in the current IDE session (Cursor Task tool) | Default — interactive development |
| `background` | Use Cursor Background Agents or Claude Code `--background` | Longer tasks the developer doesn't want to watch |
| `async` | Decompose into tracker tasks for async agent execution | CI-based agents, GitHub Coding Agent, parallel work |
| `manual` | Produce implementation plan only; developer codes it | Learning, pair programming, compliance requirements |

Default to `local` if the user has no preference.

Store as: `execution: local | background | async | manual`

### Step 8: Git Platform Detection

Detect the git hosting platform from the remote URL:

1. Run `git remote -v` and inspect the origin URL.
2. Classify:

| URL pattern | Platform |
|-------------|----------|
| `github.com` | `github` |
| `github.<enterprise-domain>` or GHE URL patterns | `ghe` |
| `gitlab.com` or self-hosted GitLab | `gitlab` |
| `bitbucket.org` or self-hosted Bitbucket | `bitbucket` |
| `dev.azure.com` or `visualstudio.com` | `azure-repos` |

3. Present the detected platform and confirm with the user.

Store as: `git-platform: github | ghe | gitlab | bitbucket | azure-repos`

## Output

Report the classification using this format:

```
**Project type:** Backend | Frontend | Fullstack | Infrastructure | Data Platform | Unknown
**Confidence:** High | Medium | Low
**Evidence:** [List the 2-3 strongest signals that led to this classification]
**Frameworks detected:** [e.g., Spring Boot 3.x, PostgreSQL, Redis]
**Stack standards:** [e.g., java-standards, typescript-node-standards, react-standards, aws-application-development, infrastructure-as-code, image-build, data-ingestion, data-mapping-validation, interoperability-contracts, regulated-data-handling, or none]
**Platform signals:** [e.g., AWS Lambda/SQS/S3/CDK/Terraform, data feed/mapping/replay, contract/webhook/schema, regulated data, or none]
```

**Platform configuration:**
```
**Task tracker:** [github-issues | jira | linear | azure-devops | none]
**Execution mode:** [local | background | async | manual]
**Git platform:** [github | ghe | gitlab | bitbucket | azure-repos]
**Context source:** [.project-context.md (persisted) | fresh detection]
```

If **fullstack**, also report:

```
**Backend layer:** [framework, language, location]
**Frontend layer:** [framework, language, location]
```

## Routing

After classification, recommend the appropriate workflow:


| Classification | Recommended workflow                                                                        |
| -------------- | ------------------------------------------------------------------------------------------- |
| Backend        | `team-workflow` (discipline: backend); activate stack standards such as `java-standards` or `typescript-node-standards` when detected |
| Frontend       | `team-workflow` (discipline: frontend); activate `react-standards` when React is detected |
| Fullstack      | `team-workflow` (discipline: fullstack); ask the user which layer the current task targets and activate the relevant stack standards |
| Infrastructure | Use `devops-engineer`, `infrastructure-as-code`, `image-build` when images are involved, `sre`, and `aws-application-development` when AWS signals are present |
| Data Platform  | Use `team-workflow` for implementation; activate `data-ingestion`, `data-mapping-validation`, `operational-feed-runbook`, and `data-platform-reviewer` as applicable |
| Unknown        | Ask the user to clarify before proceeding                                                   |


### Platform Routing

After classification, the platform values are used by downstream skills:

| Value | Used by |
|-------|---------|
| `tracker` | `/spec-to-issues` to create tasks in the correct system |
| `execution` | `team-workflow` Phase 3 to select the implementation strategy |
| `git-platform` | `project-bootstrap` and `pull-request` for platform-specific operations |
| AWS platform signals | `aws-application-development`, `/aws-architecture-review`, `/devops-plan`, and `/monitoring-plan` |
| IaC/image signals | `infrastructure-as-code`, `image-build`, `/iac-review`, `/devops-plan`, and `/release-readiness` |
| Data feed/mapping signals | `data-ingestion`, `data-mapping-validation`, `operational-feed-runbook`, `/data-ingestion-design`, `/mapping-review`, `/feed-runbook`, and `/data-quality-plan` |
| Contract signals | `interoperability-contracts`, `/contract-review`, `api-design`, `testing`, and `interoperability-reviewer` |
| FHIR / HL7 signals | `fhir-health-interop`, `/fhir-review`, `interoperability-contracts`, `regulated-data-handling`, and `interoperability-reviewer` |
| Regulated data signals | `regulated-data-handling`, `regulated-data-baseline`, `security-baseline`, `testing`, and `regulated-data-reviewer` |


## Guardrails

- **Never guess.** If the signals conflict or are ambiguous, report "Unknown" with the conflicting evidence and ask the user.
- **Don't over-inspect.** Stop at the first step that gives high confidence. Reading every file in the repo is unnecessary.
- **Respect explicit intent.** If the user said "backend," don't override them because you found a `package.json` with React. The user knows their task.
- **Monorepos need clarification.** A monorepo is not "fullstack" by default — each workspace has its own type. Always ask which workspace the task targets.
- **Ask once, persist forever.** If `.project-context.md` exists, use its values. Only re-ask if the user explicitly requests a change.
- **Detect trackers from MCP, not assumptions.** Never assume a specific tracker. Check which MCP servers are available and let the user choose.
- **Default execution to local.** If the user has no preference for execution mode, default to `local` (current IDE subagents).

## See Also

- **`team-workflow`** — After detection, this is the primary workflow that uses the classification to dispatch the correct agents and checklists.
- **`typescript-node-standards`** — Use when the backend layer is Node.js, including API routes, workers, jobs, and queue consumers.
- **`aws-application-development`** — Use when AWS services, IaC, CDK, serverless config, or AWS SDK usage is detected.
- **`infrastructure-as-code`** — Use when Terraform/OpenTofu, CDK, CloudFormation, Pulumi, SAM, Helm, or Kubernetes manifests are detected.
- **`image-build`** — Use when Dockerfiles, Containerfiles, Packer templates, AMIs, or image pipelines are detected.
- **`data-ingestion`** — Use when feeds, pipelines, schemas, mappings, reconciliation, replay, or backfill signals are detected.
- **`interoperability-contracts`** — Use when OpenAPI, AsyncAPI, webhooks, events, protobuf, GraphQL, SDK, partner, or file/feed contract signals are detected.
- **`fhir-health-interop`** — Use when FHIR, HL7 Implementation Guides, StructureDefinitions, SMART on FHIR, **CRD / DTR / PAS**, or `.fhir/ai-bundles` signals are detected. CRD/DTR/PAS work maps to the Da Vinci stack in `fhir-health-interop` (R4 + US Core STU9 + HRex + workflow IGs).
- **`regulated-data-handling`** — Use when sensitive fields, regulated data, synthetic/de-identified fixtures, audit, redaction, retention, or privacy signals are detected.
- **`code-review`** — For standalone reviews, the classification determines whether to apply backend checks, frontend checks, or both.
- **`memory-management`** — After detection completes, this skill persists the results to `.project-context.md` so future runs skip detection.
- **`spec-templates`** — Uses the discipline classification to select the appropriate spec template.
