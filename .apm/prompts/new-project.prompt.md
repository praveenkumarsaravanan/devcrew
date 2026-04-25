# New Project — Scaffold a Project with DevCrew

Create a new project from scratch with the full DevCrew AI engineering team wired in.

## What This Does

1. Establishes project standards and governance (via `/constitution`)
2. Initializes git with trunk-based branching
3. Configures APM dependencies (DevCrew + optional team package)
4. Sets up MCP servers for your chosen task tracker
5. Scaffolds stack-specific starter files
6. Generates a README with getting-started instructions

## Steps

1. **Activate the `project-bootstrap` skill** — it orchestrates the entire process.
2. Follow the prompts to provide:
   - Project name and stack
   - Task tracker preference
   - Execution mode
   - Whether your team has a shared standards package (Tier 2)
3. Review the generated files.
4. Start building — just describe your first task and `team-workflow` handles the rest.

## When to Use This vs Other Options

| Situation | Use |
|-----------|-----|
| Starting from scratch (no existing code) | **`/new-project`** (this prompt) |
| Adding DevCrew to an existing project | `apm init` + `/constitution` |
| Migrating a legacy codebase to AI-native development | `/legacy-migrate` |
| Creating a team standards package | `/new-team-package` |

## Prerequisites

- `apm` CLI installed ([agentskills.io](https://agentskills.io))
- `git` installed and configured
- MCP servers configured for your tracker (optional — the bootstrap process helps with this)
