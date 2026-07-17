---
name: project-bootstrap
description: >
  Scaffolds a new project with DevCrew wired in — initializes git, generates
  apm.yml with Tier 1/Tier 2 dependencies, configures MCP servers, scaffolds
  stack-specific files, and runs apm install. Use when starting a project from scratch.
---

# Project Bootstrap

## Trigger

Activate this skill when:

- The user asks to "create a new project," "scaffold a repo," "start from scratch," or "bootstrap a project."
- The `/new-project` prompt invokes this skill.

Do NOT activate for:

- Migrating an existing project — use `legacy-assessment` instead.
- Adding DevCrew to an existing project that already has code — guide them to `apm init` + `/constitution` instead.

## Workflow

### Step 1: Run Constitution

Invoke the `/constitution` prompt to collect project metadata and generate `.project-context.md` and `.memory.md`. This establishes the project's identity, platform configuration, and governance.

If `.project-context.md` already exists (re-running bootstrap), load existing values and let the user confirm or update.

### Step 2: Initialize Git Repository

1. If not already in a git repo, run `git init`.
2. Set up trunk-based branching: create a `main` branch.
3. Generate a `.gitignore` appropriate to the detected stack (use the starter reference for the chosen stack).

### Step 3: Configure Tier 2 Team Package (Optional)

Ask the user:

> "Does your team have a shared standards package (Tier 2)? [y/N]"

- **If yes:** Ask whether it's a **monorepo folder** (inside DevCrew's `teams/` directory) or a **separate repo**.
  - **Monorepo:** Ask for the team name. The dependency will point to the DevCrew repo with `directory: teams/<team-name>`.
  - **Separate repo:** Ask for the git URL and version tag.
- **If no:** Note that the project depends only on Tier 1 (root DevCrew).

### Step 4: Generate `apm.yml`

Generate the project's `apm.yml` at the project root:

```yaml
name: [project-name]
version: "0.1.0"
description: "[project-description]"
dependencies:
  apm:
    - git: "https://github.com/praveenkumarsaravanan/devcrew.git"
      ref: [latest-devcrew-version]
    # If Tier 2 monorepo:
    - git: "https://github.com/praveenkumarsaravanan/devcrew.git"
      ref: [latest-devcrew-version]
      directory: teams/[team-name]
    # If Tier 2 separate repo:
    - git: "[team-package-url]"
      ref: [team-package-version]
```

### Step 5: Generate `.mcp.json`

Generate `.mcp.json` based on the platform choices from `/constitution`:

| Tracker | MCP Server Entry |
|---------|-----------------|
| `jira` | Atlassian MCP server |
| `github-issues` | GitHub MCP server |
| `linear` | Linear MCP server |
| `none` | No tracker server |

Always include:
- The tracker-appropriate MCP server
- Playwright MCP server (for frontend/fullstack projects)

### Step 6: Scaffold Stack-Specific Files

Based on the stack detected in Step 1, use the appropriate starter reference to scaffold:

| Stack | Reference | Key files generated |
|-------|-----------|-------------------|
| Java + Spring Boot | `java-spring-starter.md` | `pom.xml`, `application.yml`, package structure, test setup |
| React + TypeScript | `react-ts-starter.md` | `package.json`, Vite/Next.js config, component structure, test setup |
| Go | `go-starter.md` | `go.mod`, `cmd/` + `internal/` structure, Makefile |
| Python + FastAPI | `python-fastapi-starter.md` | `pyproject.toml`, app structure, pytest setup |
| TypeScript + Node.js | `typescript-node-starter.md` | `package.json`, HTTP/worker/job structure, runtime validation, test setup |
| AWS Serverless | `aws-serverless-starter.md` | Lambda/API/EventBridge/SQS/SNS structure, IAM, DLQs, CloudWatch, KMS, tags |
| Terraform/OpenTofu + AWS | `terraform-aws-starter.md` | Remote state, locking, env layout, scan/plan pipeline, least-privilege checklist |
| Data ingestion pipeline | `data-ingestion-starter.md` | Source contract, landing/quarantine, mapping, golden tests, replay, reconciliation, runbook |

If the user's stack doesn't match any reference, scaffold a minimal structure (README, .gitignore, apm.yml) and let them build from there.

### Step 7: Install Dependencies

Run:
```bash
apm install && apm compile
```

This resolves DevCrew (Tier 1) + team package (Tier 2, if configured), and generates IDE-specific output files.

### Step 8: Generate README

Use the `documentation` skill to generate a starter `README.md` with:
- Project name and description
- Stack and prerequisites
- Getting started (install, run, test)
- Development workflow (briefly mentioning DevCrew Engineering Flow)
- Links to the project's `.project-context.md` and `.memory.md`

### Step 9: Present Summary

Display a summary:

```
Project scaffolded:
- Stack: [stack]
- Tracker: [tracker] ([project-key if applicable])
- Execution: [execution mode]
- Git platform: [git-platform]
- Tier 2 package: [team-name or "none"]
- Files created: [count]

Next steps:
1. Review the generated files
2. Run `git add . && git commit -m "feat: initial project scaffold"`
3. Start building with `/engineering-flow` -- just describe your first task
```

## Guardrails

- **Always run `/constitution` first.** Do not scaffold without establishing project context.
- **Never overwrite existing files.** If the project already has a `package.json`, `pom.xml`, etc., skip scaffolding that file and inform the user.
- **Respect the user's stack choice.** If no starter reference matches, scaffold minimally rather than forcing a template.
- **Pin dependency versions.** `apm.yml` must use exact version refs, not branches or `latest`.
- **Idempotent.** Running bootstrap again should update configuration without destroying existing project files.

## References

- [Java Spring Boot Starter](references/java-spring-starter.md)
- [React TypeScript Starter](references/react-ts-starter.md)
- [Go Starter](references/go-starter.md)
- [Python FastAPI Starter](references/python-fastapi-starter.md)
- [TypeScript Node Starter](references/typescript-node-starter.md)
- [AWS Serverless Starter](references/aws-serverless-starter.md)
- [Terraform AWS Starter](references/terraform-aws-starter.md)
- [Data Ingestion Starter](references/data-ingestion-starter.md)

## See Also

- **`/constitution`** — Called as Step 1 to establish project context.
- **`/new-project`** — The user-facing entry point that invokes this skill.
- **`legacy-assessment`** — For existing projects, use this instead of bootstrap.
- **`team-package-management`** — For creating Tier 2 team packages.
- **`memory-management`** — Manages the `.project-context.md` and `.memory.md` files created here.
