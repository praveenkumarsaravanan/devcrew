# MI Engineer Agent

Organization-wide agent package distributing engineering skills, agents, rules, and MCP server configs across Cursor and GitHub Copilot via [Microsoft APM](https://microsoft.github.io/apm/).

---

## About the Project

MI Engineer Agent defines all engineering primitives — skills, agents, instructions, prompts, hooks, and MCP servers — in a single `.apm/` directory. APM compiles and deploys the correct format for each target IDE so teams get consistent tooling regardless of their editor.

### What's Included


| Type        | Name                | Description                                                 |
| ----------- | ------------------- | ----------------------------------------------------------- |
| Skill       | `code-review`       | Structured code review with severity levels                 |
| Skill       | `api-design`        | REST/gRPC API design guidance and validation                |
| Skill       | `commit-message`    | Construct commit messages matching org commitlint hook      |
| Skill       | `branch-creation`   | Create branches with org naming conventions                 |
| Skill       | `pull-request`      | PR creation with JIRA validation and discrepancy detection  |
| Skill       | `documentation`     | Write and maintain READMEs, guides, runbooks, and ADRs      |
| Skill       | `git-release-tag`   | Tag, release, and publish new versions with changelog           |
| Skill       | `apm-authoring`     | Create and maintain all APM artifacts (skills, agents, instructions, prompts, hooks) |
| Skill       | `project-detection`     | Classify workspace as backend, frontend, fullstack, or infra         |
| Skill       | `backend-team-workflow` | Orchestrated 8-phase backend development lifecycle across team roles |
| Agent       | `backend-reviewer`  | Automated PR reviewer for backend services                  |
| Agent       | `architect`         | Architecture decision support agent                         |
| Agent       | `product-analyst`   | Requirements clarification and acceptance criteria          |
| Agent       | `senior-developer`  | Scalability, performance, rollout, and test guidance        |
| Agent       | `junior-developer`  | Clean implementation following codebase patterns            |
| Agent       | `test-engineer`     | Test code implementation from QA Lead's test plan           |
| Agent       | `qa-lead`           | Test strategy, quality review, and go/no-go decisions       |
| Agent       | `devops-engineer`   | CI/CD pipeline, deployment strategy, and infrastructure     |
| Agent       | `release-manager`   | Release readiness, go/no-go decisions, and rollback plans   |
| Agent       | `sre`               | Observability, SLOs, alerting, and customer impact          |
| Instruction | `coding-standards`  | Organization coding conventions and style                   |
| Instruction | `security-baseline` | Security requirements and baseline controls                 |
| Prompt      | `design-review`     | Prompt template for design review sessions                  |
| Prompt      | `incident-response` | Prompt template for incident triage                         |
| Hook        | `pre-commit-lint`   | Lint check + security guard on pre-commit                   |
| MCP         | `playwright`        | Browser automation and E2E testing                          |
| MCP         | `github`            | Repository, PR, and issue management                        |
| MCP         | `atlassian`         | Jira, Confluence, and Compass via Atlassian Rovo            |


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
.apm/                              # Source of truth for all primitives
  skills/                          # SKILL.md files (+ scripts/, references/)
  agents/                          # .agent.md definitions
  instructions/                    # .instructions.md files
  prompts/                         # .prompt.md templates
  hooks/                           # Hook definitions
.mcp.json                          # MCP server definitions
apm.yml                            # Package manifest (name, version, targets)
apm-policy.yml                     # Governance policy
scripts/                           # Repo-level scripts (setup, etc.)
```

---

## Contributing

For anyone adding or modifying skills, agents, prompts, hooks, or other primitives in this package.

### Prerequisites

- **APM CLI** — `brew tap microsoft/apm && brew install apm`
- **gh CLI** — version 2.40.0+ (the setup script installs it if missing)
- **`GITHUB_TOKEN`** — a PAT from `git.marriott.com` with `repo` and `read:org` scopes. Generate one at [git.marriott.com/settings/tokens](https://git.marriott.com/settings/tokens) and export it:

```sh
# ~/.zshrc or ~/.bashrc
export GITHUB_TOKEN="ghp_your_token_here"
```

### Local Setup

1. Clone the repository:

```sh
git clone https://git.marriott.com/phoenix/mi-engineer-agent.git
cd mi-engineer-agent
```

2. Run the setup script:

```sh
apm run setup
```

This checks `gh` CLI version, GitHub Enterprise auth, `GITHUB_TOKEN`, and APM availability.

3. Compile the package so your IDE can use the skills and instructions:

```sh
apm compile
```

The `.apm/` directory holds **source primitives**. Your IDE reads from compiled output directories (`.cursor/skills/`, `.github/instructions/`, etc.). Without this step, the agent has no access to the skills defined in this repo. Re-run `apm compile` after adding or modifying any primitive.

### Development Workflow

1. Create a feature branch:

```sh
git checkout -b feat/DXP-12345-add-new-skill
```

2. Edit files under `.apm/` — skills, agents, instructions, prompts, hooks, or MCP configs in `.mcp.json`.
3. Validate and pack:

```sh
apm compile                    # Validate package structure
apm pack --target cursor       # Pack for Cursor
apm pack --target copilot      # Pack for Copilot
```

4. Commit using conventional commits:

```sh
git commit -m "feat(skills): DXP-12345, add terraform-plan skill"
```

### Submitting a Pull Request

1. Push your branch and open a PR against `trunk`.
2. All files are owned by `@phoenix/mi-platform-dev-squad` (see `.github/CODEOWNERS`), so a review from that team is required.
3. PRs are squash-merged. The PR title becomes the merge commit message and must follow conventional commit format.

### Releasing New Versions

This package has no registry — consumers pull directly from the Git repo. A "release" is a **git tag + GitHub release** that consumers pin to via `ref:` in their `apm.yml`.

Run the release script from `trunk`:

```sh
git checkout trunk && git pull
bash .apm/skills/git-release-tag/scripts/release.sh --ticket DXP-XXXXX    # defaults to patch
```

The script reads the current version from `apm.yml`, computes the next version, generates a changelog from commits since the last tag, creates an annotated tag with the changelog, pushes, and creates a GitHub release. The `--ticket` flag is required — the org commitlint hook rejects commits without a JIRA ticket.

Preview first with `--dry-run`:

```sh
bash .apm/skills/git-release-tag/scripts/release.sh --dry-run --ticket DXP-XXXXX
```

For minor or major releases, pass the increment explicitly:

```sh
bash .apm/skills/git-release-tag/scripts/release.sh minor --ticket DXP-XXXXX
bash .apm/skills/git-release-tag/scripts/release.sh major --ticket DXP-XXXXX
```

**Increment guide:**


| Increment | When to use                                                       |
| --------- | ----------------------------------------------------------------- |
| `patch`   | Default. Fixes to existing skills, instructions, or prompts       |
| `minor`   | New skills, agents, prompts, hooks, or non-breaking additions     |
| `major`   | Breaking changes to primitives that consumers may have overridden |


**Additional flags:** `--no-push` (tag locally without pushing), `--no-release` (push tag but skip GitHub release), `--json` (structured output for CI/agents), `--confirm` (skip interactive prompts for agent/CI use).


### Adding MCP Servers

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

Two connection types: **`http`** for remote servers, **`command`** for local servers run as child processes. APM converts this into the correct format for each target IDE.

---

## Consumer Guide

For teams adopting MI Engineer Agent in their own repositories. Two installation methods: **global** (all projects on your machine) and **per-project** (version-pinned, committed to the repo). Both can coexist — project-level always takes precedence.

### Prerequisites

1. **APM CLI** — `brew tap microsoft/apm && brew install apm`
2. **gh CLI** (v2.40.0+) — `brew install gh`
3. **GitHub Enterprise auth:**

```sh
gh auth login --hostname git.marriott.com --web --git-protocol https
```

4. **`GITHUB_TOKEN`** — needed by the GitHub MCP server at runtime. Generate a PAT at [git.marriott.com/settings/tokens](https://git.marriott.com/settings/tokens) with `repo` and `read:org` scopes:

```sh
# ~/.zshrc or ~/.bashrc
export GITHUB_TOKEN="ghp_your_token_here"
```

The `atlassian` MCP uses OAuth 2.1 — it opens a browser on first connection. No token needed.

### Global Install (recommended)

```sh
apm install -g git.marriott.com/phoenix/mi-engineer-agent
```

Deploys skills, agents, instructions, prompts, and MCP servers to user-level directories (`~/.cursor/`, `~/.copilot/`). Your IDE picks them up in every project — no per-repo config required.

Update later with `apm deps update -g`.

### Per-Project Install

Use when a repo needs version pinning, hooks, overrides, or team-consistent setup committed to source control.

**Step 1 — Create `apm.yml` in the project root:**

```yaml
name: my-service
version: "1.0.0"
dependencies:
  apm:
    - git: "https://git.marriott.com/phoenix/mi-engineer-agent.git"
      ref: trunk
```

The `ref` field accepts a branch name (`trunk`), a release tag (`v1.1.0`), or a commit SHA. Tags are created by maintainers — see [Releasing New Versions](#releasing-new-versions).

**Step 2 — Install:**

```sh
apm install
```

APM clones the package, resolves dependencies, and deploys all primitives. It creates the IDE directories (`.cursor/`, `.github/`) automatically.

**Step 3 — Verify:**

```sh
ls .cursor/rules/     # Should contain .mdc instruction files
ls .github/agents/    # Should contain .agent.md files
cat apm.lock.yaml     # Should show resolved commit SHA
```

Update to the latest upstream version with `apm deps update`.

### Key Files

Both files belong in source control:


| File                | Purpose                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------ |
| **`apm.yml`**       | The manifest you author. Declares dependencies and which branch/tag to track.                    |
| **`apm.lock.yaml`** | Generated by `apm install`. Pins the exact commit SHA and file hashes for reproducible installs. |


Everything else APM generates (`.cursor/`, `.github/`, `AGENTS.md`, `.mcp.json`) should be **gitignored** — each developer regenerates them locally with `apm install`.

### Where Files Land

**Global** (`apm install -g`):

```
~/.apm/                                    # Package storage
~/.cursor/                                 # Cursor
  rules/*.mdc                              #   Instructions
  agents/*.md                              #   Agents
  skills/{name}/                           #   Skills
~/.copilot/                                # GitHub Copilot (user-level, not ~/.github/)
  copilot-instructions.md                  #   Instructions
  agents/*.md                              #   Agents
  mcp-config.json                          #   MCP config
```

**Per-project** (`apm install`):

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

### Overriding and Governance

APM resolves with this precedence (highest first):

1. **Project-local files** — anything in the project's own `.apm/` directory
2. **Project dependencies** — packages in the project's `apm.yml`
3. **Global packages** — packages installed with `-g`

Override any primitive by mirroring the file path locally:

```
.apm/skills/code-review/SKILL.md        # Your version wins over the package's
.apm/instructions/coding-standards.md   # Same for instructions, agents, prompts
```

The governance policy (`apm-policy.yml`) is set to `warn` — policy violations produce warnings rather than blocking installs.