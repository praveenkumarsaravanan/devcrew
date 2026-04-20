# MI Engineer Agent

Organization-wide agent package distributing engineering skills, agents, rules, and MCP server configs across Cursor, Claude Code, and GitHub Copilot via Microsoft APM.

## Quick Start

### APM registry (recommended)

Add the dependency to your project's `apm.yml`:

```yaml
dependencies:
  mi-engineer-agent: "^1.0.0"
```

Then install:

```sh
apm install
```

### GitHub repo URL

Install directly from the GitHub repository:

```sh
apm install https://github.com/phoenix/mi-engineer-agent
```

Or add the repo URL to your `apm.yml` and run `apm install`:

```yaml
dependencies:
  mi-engineer-agent: "https://github.com/phoenix/mi-engineer-agent"
```

To pin a specific version or branch, append a ref:

```yaml
dependencies:
  mi-engineer-agent: "https://github.com/phoenix/mi-engineer-agent#v1.0.0"
```

### Git clone

```sh
git clone https://github.com/phoenix/mi-engineer-agent.git
apm install --plugin ./mi-engineer-agent
```

### Direct download

Copy the `.apm/` directory and `.mcp.json` directly into your project.

## What's Included


| Type        | Name                  | Description                                    |
| ----------- | --------------------- | ---------------------------------------------- |
| Skill       | `code-review`         | Structured code review with severity levels    |
| Skill       | `api-design`          | REST/gRPC API design guidance and validation   |
| Skill       | `db-migration`        | Safe database migration planning and execution |
| Skill       | `commit-message`      | Construct commit messages matching org commitlint hook |
| Skill       | `branch-creation`     | Create branches with org naming conventions    |
| Skill       | `pull-request`        | PR creation with JIRA validation and discrepancy detection |
| Agent       | `backend-reviewer`    | Automated PR reviewer for backend services     |
| Agent       | `architect`           | Architecture decision support agent            |
| Instruction | `coding-standards`    | Organization coding conventions and style      |
| Instruction | `security-baseline`   | Security requirements and baseline controls    |
| Prompt      | `design-review`       | Prompt template for design review sessions     |
| Prompt      | `incident-response`   | Prompt template for incident triage            |
| Hook        | `pre-commit-lint`     | Lint check + security guard on pre-commit      |
| MCP         | `playwright`          | Browser automation and E2E testing             |
| MCP         | `github`              | Repository, PR, and issue management           |
| MCP         | `atlassian`           | Jira, Confluence, and Compass via Atlassian Rovo |


## IDE Compatibility


| Component    | Cursor | Claude Code | GitHub Copilot |
| ------------ | ------ | ----------- | -------------- |
| Skills       | ✓      | ✓           | ✓              |
| Agents       | ✓      | ✓           | ✓              |
| Instructions | ✓      | ✓           | ✓              |
| Prompts      | ✓      | ✓           | ✓              |
| Hooks        | ✓      | ✓           | N/A            |
| MCP          | ✓      | ✓           | ✓              |


## Overriding Defaults

APM resolves configuration using a layered precedence system:

1. **Project-local files** — highest priority. Any file you place directly in your repo takes precedence over everything else.
2. **Direct dependencies** — packages listed in your `apm.yml`.
3. **Transitive dependencies** — packages pulled in by your dependencies (lowest priority).

To override a skill, create the same file path in your project:

```
# The package ships:
#   .apm/skills/code-review/SKILL.md
#
# Override it locally:
.apm/skills/code-review/SKILL.md   ← your version wins
```

To override an instruction:

```
# Package default:
#   .apm/instructions/coding-standards.md
#
# Your project-level override:
.apm/instructions/coding-standards.md
```

APM merges the rest and only replaces the specific files you override.

## Project Structure

Everything is defined once in `.apm/` and `.mcp.json`. APM compiles and distributes the correct format for each target IDE.

```
.apm/                              # Single source of truth
  skills/                          # SKILL.md files
    code-review/SKILL.md
    api-design/SKILL.md
    db-migration/SKILL.md
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

When you run `apm pack`, APM reads from `.apm/` and generates the IDE-specific files and formats automatically:

```sh
apm pack --target cursor     # → Cursor plugin format
apm pack --target claude     # → Claude Code plugin format
apm pack --target copilot    # → VS Code / GitHub Copilot format
apm pack --format plugin     # → all targets at once
```

You define once, APM distributes everywhere.

## Distribution

This package supports three distribution channels:


| Channel            | Use Case                              | Command                                            |
| ------------------ | ------------------------------------- | -------------------------------------------------- |
| **APM registry**   | Org-wide rollout via `apm.yml`        | `apm install`                                      |
| **GitHub repo URL**| Install from a repo without registry  | `apm install https://github.com/phoenix/mi-engineer-agent` |
| **Plugin format**  | Marketplace or manual plugin install  | `apm pack --format plugin`                         |
| **Git repo clone** | Clone or fork for full customization  | `git clone <repo-url>`                             |


## Environment Variables

The MCP servers that connect to external services need these environment variables set locally:


| Variable          | Used By        | Description                                                          |
| ----------------- | -------------- | -------------------------------------------------------------------- |
| `GITHUB_TOKEN`    | `github` MCP   | GitHub Personal Access Token with `repo`, `read:org` scopes         |
| `GITHUB_API_URL`  | `github` MCP   | API base URL for GitHub Enterprise (default: `https://api.github.com`) |


The `github` MCP is pre-configured to connect to the enterprise instance at `git.marriott.com`. The `GITHUB_TOKEN` must be a Personal Access Token generated on **git.marriott.com** (not github.com) with `repo` and `read:org` scopes.

To point at a different GitHub instance, override `GITHUB_API_URL` in your environment:

```sh
export GITHUB_API_URL="https://your-ghe-host.com/api/v3"
```


The `atlassian` MCP uses OAuth 2.1 -- on first connection it opens a browser for authentication. No API token needed.

These are resolved from your shell environment at runtime. The package itself contains no secrets.

## Setup

After installing the package, run the setup script to configure your local environment:

```sh
apm run setup
```

Or run it directly:

```sh
npx mi-engineer-agent/scripts/setup.sh
```

The script checks and configures:

1. **gh CLI** — installs via Homebrew if missing, verifies minimum version
2. **GitHub Enterprise auth** — authenticates `gh` against `git.marriott.com` (opens a browser for OAuth)
3. **GITHUB_TOKEN** — checks the env var is set for the GitHub MCP server
4. **APM** — verifies the APM CLI is installed

You also need `GITHUB_TOKEN` exported in your shell profile for the GitHub MCP server:

```sh
# ~/.zshrc or ~/.bashrc
export GITHUB_TOKEN="ghp_your_token_here"
```

Generate the token at https://git.marriott.com/settings/tokens with `repo` and `read:org` scopes.

## Development

1. Fork and clone the repository:
  ```sh
   git clone https://github.com/phoenix/mi-engineer-agent.git
   cd mi-engineer-agent
  ```
2. Install APM if you haven't already:

   **Homebrew (macOS/Linux, recommended):**
   ```sh
   brew tap microsoft/apm
   brew install apm
   ```

3. Edit files under `.apm/` (skills, agents, instructions, prompts, hooks, MCP configs).
4. Validate the package structure:
  ```sh
   apm compile
  ```
5. Pack and test for a specific target:
  ```sh
   apm pack --target cursor
   apm pack --target copilot
   apm pack --target claude
   ls -la build/
  ```
   APM generates the correct IDE-specific files from your `.apm/` source.
6. Or pack all targets at once:
  ```sh
   apm pack --format plugin
   ls -la build/
  ```
7. Submit a pull request.

## Adding Custom MCP Servers

To add your own MCP servers, edit `.mcp.json` in the package root:

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
- **`http`** -- for remote MCP servers your org already hosts
- **`command`** -- for local servers that run as a child process via `npx`, `node`, `python`, etc.

APM handles converting this into the correct format for each target IDE (e.g., `.vscode/mcp.json` for Copilot, `.cursor-plugin/` for Cursor).

## License

MIT