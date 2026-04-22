---
name: project-detection
description: >
  Inspects the current workspace to classify the project as backend, frontend,
  fullstack, or infrastructure. Other skills and agents reference this to scope
  their behavior to the correct discipline.
---

# Project Detection

## Trigger

Activate this skill when:

- Another skill (e.g., `backend-team-workflow`) instructs you to detect the project type before proceeding.
- The user asks to "implement a feature," "build this," or "develop this" without specifying backend or frontend.
- You need to determine which team workflow to activate.

Do NOT activate when the user explicitly states the discipline: "build a backend service" or "create a React component" — trust their intent.

## Detection Process

Inspect the workspace in this order. Stop as soon as you have high confidence.

### Step 1: Check for Explicit User Context

If the user's request names a specific layer — "API endpoint," "database migration," "React component," "CSS layout" — trust that and skip workspace inspection.

### Step 2: Scan Project Root Files

Look for these markers at the project root (or one level deep):

| Signal | Indicates |
|---|---|
| `pom.xml`, `build.gradle`, `build.gradle.kts` | Backend (Java/Kotlin) |
| `go.mod`, `go.sum` | Backend (Go) |
| `requirements.txt` or `pyproject.toml` with Flask, Django, FastAPI, SQLAlchemy | Backend (Python) |
| `Cargo.toml` | Backend (Rust) |
| `*.csproj`, `*.sln` with ASP.NET references | Backend (C#/.NET) |
| `application.yml`, `application.properties` | Backend (Spring Boot) |
| `Dockerfile`, `docker-compose.yml` without frontend service | Backend or Infrastructure |
| `next.config.js`, `next.config.mjs`, `next.config.ts` | Fullstack (Next.js) |
| `nuxt.config.ts` | Fullstack (Nuxt) |
| `angular.json` | Frontend (Angular) |
| `vite.config.ts`, `vite.config.js` without server framework | Frontend |
| `svelte.config.js` | Frontend (SvelteKit may be fullstack) |
| `package.json` | Inspect further (Step 3) |
| `terraform/`, `*.tf`, `pulumi/`, `cdk.json` | Infrastructure |
| `helm/`, `Chart.yaml`, `kustomization.yaml` | Infrastructure |

### Step 3: Inspect `package.json` Dependencies

If a `package.json` exists, read its `dependencies` and `devDependencies`:

| Dependency pattern | Indicates |
|---|---|
| `react`, `react-dom`, `vue`, `@angular/core`, `svelte` | Frontend |
| `express`, `fastify`, `koa`, `hapi`, `nestjs`, `@nestjs/*` | Backend (Node.js) |
| `next`, `nuxt`, `remix`, `@remix-run/*` | Fullstack |
| `prisma`, `typeorm`, `sequelize`, `knex`, `drizzle-orm` | Backend (database layer) |
| `tailwindcss`, `sass`, `styled-components`, `@emotion/*` | Frontend (styling) |
| `webpack`, `vite`, `esbuild`, `rollup` (alone, no server deps) | Frontend (build tooling) |

If both frontend and backend dependencies are present, classify as **fullstack**.

### Step 4: Inspect Directory Structure

| Directory pattern | Indicates |
|---|---|
| `src/controllers/`, `src/services/`, `src/repositories/`, `src/models/` | Backend |
| `src/routes/` with handler files (not page files) | Backend |
| `src/components/`, `src/pages/`, `src/views/`, `src/layouts/` | Frontend |
| `src/hooks/` with React/Vue hooks | Frontend |
| `public/`, `static/`, `assets/` with HTML/CSS/images | Frontend |
| `migrations/`, `seeds/`, `db/` | Backend (database) |
| `cmd/`, `internal/`, `pkg/` | Backend (Go) |
| `src/main/java/`, `src/main/resources/` | Backend (Java) |
| Both backend and frontend patterns | Fullstack |

### Step 5: Check for Monorepo Structure

If the project has `packages/`, `apps/`, or workspace configuration (`pnpm-workspace.yaml`, `lerna.json`, `turbo.json`):

1. List the workspace directories.
2. Classify each workspace independently using Steps 2–4.
3. Report the overall structure: "This is a monorepo with backend (`apps/api`) and frontend (`apps/web`) workspaces."
4. Ask the user which workspace the current task targets.

## Output

Report the classification using this format:

```
**Project type:** Backend | Frontend | Fullstack | Infrastructure | Unknown
**Confidence:** High | Medium | Low
**Evidence:** [List the 2-3 strongest signals that led to this classification]
**Frameworks detected:** [e.g., Spring Boot 3.x, PostgreSQL, Redis]
```

If **fullstack**, also report:
```
**Backend layer:** [framework, language, location]
**Frontend layer:** [framework, language, location]
```

## Routing

After classification, recommend the appropriate workflow:

| Classification | Recommended workflow |
|---|---|
| Backend | `backend-team-workflow` |
| Frontend | `frontend-team-workflow` (when available) |
| Fullstack | Run both workflows sequentially, or ask the user which layer the current task targets |
| Infrastructure | No team workflow — use `devops-engineer` and `sre` agents directly |
| Unknown | Ask the user to clarify before proceeding |

## Guardrails

- **Never guess.** If the signals conflict or are ambiguous, report "Unknown" with the conflicting evidence and ask the user.
- **Don't over-inspect.** Stop at the first step that gives high confidence. Reading every file in the repo is unnecessary.
- **Respect explicit intent.** If the user said "backend," don't override them because you found a `package.json` with React. The user knows their task.
- **Monorepos need clarification.** A monorepo is not "fullstack" by default — each workspace has its own type. Always ask which workspace the task targets.
