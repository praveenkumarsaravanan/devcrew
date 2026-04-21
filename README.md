# MI Engineer Agent

Organization-wide agent package distributing engineering skills, agents, rules, and MCP server configs across Cursor and GitHub Copilot via Microsoft APM.

---

## Table of Contents

- [About the Project](#about-the-project)
  - [What's Included](#whats-included)
  - [IDE Compatibility](#ide-compatibility)
  - [Project Structure](#project-structure)
- [Contributing](#contributing)
  - [Prerequisites](#prerequisites)
  - [Local Setup](#local-setup)
  - [Development Workflow](#development-workflow)
  - [Validating Changes](#validating-changes)
  - [Submitting a Pull Request](#submitting-a-pull-request)
  - [Releasing New Versions](#releasing-new-versions)
  - [Adding Custom MCP Servers](#adding-custom-mcp-servers)
- [Consumer Guide](#consumer-guide)
  - [Prerequisites](#consumer-prerequisites)
  - [Global Install (recommended)](#global-install-recommended)
  - [Per-Project Install](#per-project-install)
  - [Understanding `apm.yml` and `apm.lock.yaml`](#understanding-apmyml-and-apmlockyaml)
  - [Where Files Land](#where-files-land)
  - [Version Management](#version-management)
  - [Overriding and Governance](#overriding-and-governance)

---

## About the Project

MI Engineer Agent is a single-source-of-truth package that defines engineering skills, AI agents, coding instructions, prompt templates, hooks, and MCP server configurations in one place (`.apm/`). APM compiles and distributes the correct format for each target IDE so teams get consistent tooling regardless of their editor.

### What's Included

| Type        | Name                | Description                                                |
| ----------- | ------------------- | ---------------------------------------------------------- |
| Skill       | `code-review`       | Structured code review with severity levels                |
| Skill       | `api-design`        | REST/gRPC API design guidance and validation               |
| Skill       | `commit-message`    | Construct commit messages matching org commitlint hook     |
| Skill       | `branch-creation`   | Create branches with org naming conventions                |
| Skill       | `pull-request`      | PR creation with JIRA validation and discrepancy detection |
| Agent       | `backend-reviewer`  | Automated PR reviewer for backend services                 |
| Agent       | `architect`         | Architecture decision support agent                        |
| Instruction | `coding-standards`  | Organization coding conventions and style                  |
| Instruction | `security-baseline` | Security requirements and baseline controls                |
| Prompt      | `design-review`     | Prompt template for design review sessions                 |
| Prompt      | `incident-response` | Prompt template for incident triage                        |
| Hook        | `pre-commit-lint`   | Lint check + security guard on pre-commit                  |
| MCP         | `playwright`        | Browser automation and E2E testing                         |
| MCP         | `github`            | Repository, PR, and issue management                       |
| MCP         | `atlassian`         | Jira, Confluence, and Compass via Atlassian Rovo           |

### IDE Compatibility

| Component    | Cursor | GitHub Copilot |
| ------------ | ------ | -------------- |
| Skills       | ✓      | ✓              |
| Agents       | ✓      | ✓              |
| Instructions | ✓      | ✓              |
| Prompts      | ✓      | ✓              |
| Hooks        | ✓      | N/A            |
| MCP          | ✓      | ✓              |

### Project Structure

```
.apm/                              # Single source of truth
  skills/                          # SKILL.md files
    code-review/SKILL.md
    api-design/SKILL.md
  agents/                          # .agent.md definitions
    backend-reviewer.agent.md
    architect.agent.md
  instructions/                    # .instructions.md files
    coding-standards.instructions.md
    security-baseline.instructions.md
  prompts/                         # .prompt.md templates
    design-review.prompt.md
    incident-response.prompt.md
  hooks/                           # Hook definitions
    pre-commit-lint.json
.mcp.json                          # MCP server definitions
apm.yml                            # Package manifest (name, version, targets)
apm-policy.yml                     # Governance policy
```

---

## Contributing

This section is for anyone who wants to add skills, agents, prompts, hooks, or other primitives to this package.

### Prerequisites

- **APM CLI** — install via Homebrew:

```sh
brew tap microsoft/apm
brew install apm
```

- **gh CLI** — version 2.40.0 or later (the setup script installs it if missing)
- **`GITHUB_TOKEN`** — a PAT from `git.marriott.com` with `repo` and `read:org` scopes. Generate one at https://git.marriott.com/settings/tokens and export it in your shell profile:

```sh
# ~/.zshrc or ~/.bashrc
export GITHUB_TOKEN="ghp_your_token_here"
```

### Local Setup

1. Fork and clone the repository:

```sh
git clone https://git.marriott.com/phoenix/mi-engineer-agent.git
cd mi-engineer-agent
```

2. Run the setup script to configure your local environment:

```sh
apm run setup
```

The script checks and configures: `gh` CLI installation/version, GitHub Enterprise auth against `git.marriott.com`, `GITHUB_TOKEN` env var, and APM CLI availability.

### Development Workflow

1. Create a feature branch following org conventions:

```sh
git checkout -b feat/DXP-12345-add-new-skill
```

2. Edit files under `.apm/` — skills, agents, instructions, prompts, hooks, or MCP configs in `.mcp.json`.
3. Validate, pack, and test (see below).
4. Commit using conventional commits:

```sh
git commit -m "feat(skills): DXP-12345, add terraform-plan skill"
```

### Validating Changes

```sh
apm compile                    # Validate package structure
apm pack --target cursor       # Pack for Cursor
apm pack --target copilot      # Pack for Copilot
ls -la build/                  # Inspect output
```

Or pack all targets at once:

```sh
apm pack --format plugin
```

### Submitting a Pull Request

1. Push your branch and open a pull request against `main`.
2. All files are owned by `@phoenix/mi-platform-dev-squad` (see `.github/CODEOWNERS`), so a review from that team is required.
3. PRs are squash-merged to keep the commit history linear.
4. The PR title should follow conventional commit format, since it becomes the merge commit message.

### Releasing New Versions

Update the `version` field in `apm.yml` following semantic versioning:

- **Patch** (`1.0.1`) — fixes to existing skills, instructions, or prompts
- **Minor** (`1.1.0`) — new skills, agents, prompts, or hooks
- **Major** (`2.0.0`) — breaking changes to existing primitives that consumers may have overridden

Once merged to `main`, consumers pull the new version by re-running `apm install -g` or `apm deps update`.

### Adding Custom MCP Servers

Edit `.mcp.json` in the package root:

```json
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.company.com/v1/mcp"
    },
    "my-local-tool": {
      "command": "npx",
      "args": ["-y", "my-mcp-package"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

Two connection types are supported:

- **`http`** — for remote MCP servers your org already hosts
- **`command`** — for local servers that run as a child process via `npx`, `node`, `python`, etc.

APM handles converting this into the correct format for each target IDE.

---

## Consumer Guide

This section is for teams adopting MI Engineer Agent in their own repositories. There are two ways to install: **global** (applies to all projects on your machine) and **per-project** (version-pinned, committed to the repo). Both can coexist — project-level always takes precedence.

### Consumer Prerequisites

1. **APM CLI** — `brew tap microsoft/apm && brew install apm`
2. **gh CLI** (v2.40.0+) — `brew install gh`
3. **GitHub Enterprise auth**:

```sh
gh auth login --hostname git.marriott.com --web --git-protocol https
```

4. **`GITHUB_TOKEN`** — needed at runtime by the GitHub MCP server. Generate a PAT at [git.marriott.com/settings/tokens](https://git.marriott.com/settings/tokens) with `repo` and `read:org` scopes:

```sh
# ~/.zshrc or ~/.bashrc
export GITHUB_TOKEN="ghp_your_token_here"
```

The `atlassian` MCP uses OAuth 2.1 — it opens a browser on first connection. No token needed.

### Global Install (recommended)

```sh
apm install -g git.marriott.com/phoenix/mi-engineer-agent
```

This deploys skills, agents, instructions, prompts, and MCP servers to user-level directories (`~/.cursor/`, `~/.copilot/`). Your IDE picks them up automatically in every project — no per-repo configuration required.

To update later:

```sh
apm deps update -g
```

> **What global install does not include:** `AGENTS.md` (compiled context file), hooks, version pinning, and project-specific overrides. If you need any of these, use per-project install.
>
> This is rarely a concern — individual instruction files (`.cursor/rules/*.mdc`, `.github/instructions/*.instructions.md`) are the primary mechanism for delivering instructions and are fully deployed globally. `AGENTS.md` is a lower-priority compatibility layer that loads all instructions unconditionally.

### Per-Project Install

Use per-project install when a repo needs version pinning, hooks, overrides, or team-consistent setup committed to source control.

**Step 1 — Create `apm.yml` in the project root:**

```yaml
name: my-service
version: "1.0.0"
dependencies:
  apm:
    - git: "https://git.marriott.com/phoenix/mi-engineer-agent.git"
      ref: trunk
```

The `git:` object form with explicit `ref:` is the required format for GitHub Enterprise repos. The `ref` field accepts a branch name (`trunk`), tag (`v1.0.0`), or commit SHA.

**Step 2 — Install:**

```sh
apm install
```

APM clones the package, resolves dependencies, and deploys all primitives into the project. It automatically creates the IDE directories (`.cursor/`, `.github/`).

**Step 3 — Verify:**

```sh
ls .cursor/rules/     # Should contain .mdc instruction files
ls .github/agents/    # Should contain .agent.md files
cat apm.lock.yaml     # Should show resolved commit SHA
```

To update to the latest upstream version:

```sh
apm deps update
```

### Understanding `apm.yml` and `apm.lock.yaml`

These two files work together and **both belong in source control**:

| File | Purpose |
| --- | --- |
| **`apm.yml`** | The manifest you author. Declares dependencies and which branch/tag to track. Without it, `apm install` does nothing. |
| **`apm.lock.yaml`** | Generated by `apm install`. Pins the exact commit SHA and file hashes. Without it, two developers installing a week apart could get different versions. |

Everything else APM generates (`.cursor/`, `.github/`, `AGENTS.md`, `.mcp.json`) should be **gitignored** — each developer regenerates them locally by running `apm install`.

### Where Files Land

**Global** (`apm install -g`):

```
~/.apm/                                    # Package storage
~/.cursor/                                 # Cursor
  rules/*.mdc                              #   Instructions
  agents/*.md                              #   Agents
  skills/{name}/                           #   Skills
~/.copilot/                                # GitHub Copilot
  copilot-instructions.md                  #   Instructions
  agents/*.md                              #   Agents
  mcp-config.json                          #   MCP config
```

Copilot's user-level directory is `~/.copilot/`, **not** `~/.github/` (that path is project-level only).

**Project** (`apm install` with `apm.yml`):

```
your-repo/
  apm.yml                                  # ← commit
  apm.lock.yaml                            # ← commit
  AGENTS.md                                # Compiled context (gitignored)
  .cursor/                                 # Cursor (gitignored)
    rules/*.mdc
    agents/*.md
    skills/{name}/
    hooks.json
  .github/                                 # Copilot (gitignored)
    instructions/*.instructions.md
    prompts/*.prompt.md
    agents/*.agent.md
    skills/{name}/
    hooks/*.json
  .mcp.json                                # MCP servers (gitignored)
```

### Version Management

Each repo controls which version it tracks via the `ref` field in `apm.yml`. Examples:

```yaml
ref: trunk          # Always latest (track a branch)
ref: v2.0.0         # Pin to a release tag
ref: abc123def456   # Pin to an exact commit SHA
```

Each repo resolves independently — a legacy service can stay pinned to an older tag while a new service tracks `trunk`. The lockfile (`apm.lock.yaml`) ensures reproducible installs regardless of when `apm install` runs.

### Overriding and Governance

APM resolves with this precedence (highest first):

1. **Project-local files** — anything in the project's own `.apm/` directory
2. **Project dependencies** — packages in the project's `apm.yml`
3. **Global packages** — packages installed with `-g`

To override any primitive, mirror the file path locally:

```
.apm/skills/code-review/SKILL.md        # Your version wins over the package's
.apm/instructions/coding-standards.md   # Same for instructions, agents, prompts
```

The `apm-policy.yml` file controls what consumers can change:

- **Skills, Instructions, Prompts, Agents** — fully overridable at the project level
- **Hooks** — overridable in Cursor (Copilot does not support hooks)
- **MCP Servers** — add your own alongside shipped ones, or replace a shipped server by defining one with the same key in your local `.mcp.json`

The governance policy is set to `warn` enforcement — policy violations produce warnings rather than blocking installs.

---

## License

MIT
