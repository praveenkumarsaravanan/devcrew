# MI Engineer Agent

Organization-wide agent package distributing engineering skills, agents, rules, and MCP server configs across Cursor, Claude Code, and GitHub Copilot via Microsoft APM.

---

## Table of Contents

- [About the Project](#about-the-project)
  - [What's Included](#whats-included)
  - [IDE Compatibility](#ide-compatibility)
  - [Project Structure](#project-structure)
  - [Environment Variables](#environment-variables)
- [Contributing](#contributing)
  - [Prerequisites](#prerequisites)
  - [Local Setup](#local-setup)
  - [Development Workflow](#development-workflow)
  - [Validating Changes](#validating-changes)
  - [Submitting a Pull Request](#submitting-a-pull-request)
  - [Releasing New Versions](#releasing-new-versions)
  - [Adding Custom MCP Servers](#adding-custom-mcp-servers)
- [Consumer Guide](#consumer-guide)
  - [Getting Started](#getting-started)
  - [Per-Project Setup](#per-project-setup-when-you-need-more-control)
  - [How the Two Scopes Interact](#how-the-two-scopes-interact)
  - [Where Files Land](#where-files-land)
  - [Version Management Across Repos](#version-management-across-repos)
  - [Alternative Installation Methods](#alternative-installation-methods)
  - [IDE-Specific Behavior](#ide-specific-behavior)
  - [Overriding Defaults](#overriding-defaults)
  - [Access Levels and Governance](#access-levels-and-governance)

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


| Component    | Cursor | Claude Code | GitHub Copilot |
| ------------ | ------ | ----------- | -------------- |
| Skills       | ✓      | ✓           | ✓              |
| Agents       | ✓      | ✓           | ✓              |
| Instructions | ✓      | ✓           | ✓              |
| Prompts      | ✓      | ✓           | ✓              |
| Hooks        | ✓      | ✓           | N/A            |
| MCP          | ✓      | ✓           | ✓              |


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

### Environment Variables

The MCP servers that connect to external services need these environment variables set locally:


| Variable         | Used By      | Description                                                                                                       |
| ---------------- | ------------ | ----------------------------------------------------------------------------------------------------------------- |
| `GITHUB_TOKEN`   | `github` MCP | GitHub Personal Access Token with `repo`, `read:org` scopes                                                       |
| `GITHUB_API_URL` | `github` MCP | API base URL for GitHub Enterprise (default: [https://git.marriott.com/api/v3](https://git.marriott.com/api/v3) ) |


The `github` MCP is pre-configured to connect to the enterprise instance at `git.marriott.com`. The `GITHUB_TOKEN` must be a Personal Access Token generated on **git.marriott.com** (not github.com) with `repo` and `read:org` scopes.

To point at a different GitHub instance, override `GITHUB_API_URL` in your environment:

```sh
export GITHUB_API_URL="https://git.marriott.com/api/v3"
```

The `atlassian` MCP uses OAuth 2.1 — on first connection it opens a browser for authentication. No API token needed.

These are resolved from your shell environment at runtime. The package itself contains no secrets.

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
- `**GITHUB_TOKEN`** — a PAT from `git.marriott.com` with `repo` and `read:org` scopes, exported in your shell profile:
  ```sh
  # ~/.zshrc or ~/.bashrc
  export GITHUB_TOKEN="ghp_your_token_here"
  ```
  Generate the token at https://git.marriott.com/settings/tokens.

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
   Or run it directly:
   The script checks and configures:
  - **gh CLI** — installs via Homebrew if missing, verifies minimum version
  - **GitHub Enterprise auth** — authenticates `gh` against `git.marriott.com` (opens a browser for OAuth)
  - **GITHUB_TOKEN** — checks the env var is set for the GitHub MCP server
  - **APM** — verifies the APM CLI is installed

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

Validate the package structure:

```sh
apm compile
```

Pack and test for a specific IDE target:

```sh
apm pack --target cursor
apm pack --target copilot
apm pack --target claude
ls -la build/
```

Or pack all targets at once:

```sh
apm pack --format plugin
ls -la build/
```

APM generates the correct IDE-specific files from your `.apm/` source into the `build/` directory.

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

Once merged to `main`, the CI pipeline publishes the new version to the APM registry.

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

- `**http**` — for remote MCP servers your org already hosts
- `**command**` — for local servers that run as a child process via `npx`, `node`, `python`, etc.

APM handles converting this into the correct format for each target IDE.

---

## Consumer Guide

This section is for teams adopting MI Engineer Agent in their own repositories.

### Installation Scopes

APM supports two installation scopes. Choose based on how you want the package to apply:


| Scope                          | Command          | Where Files Land                                                              | Best For                                               |
| ------------------------------ | ---------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------ |
| **Global** (recommended start) | `apm install -g` | `~/.apm/` → deployed to `~/.copilot/`, `~/.claude/`, etc.                     | One-time setup, works across all repos on your machine |
| **Project** (opt-in)           | `apm install`    | Project root (`.cursor-plugin/`, `AGENTS.md`, `CLAUDE.md`, `.copilot/`, etc.) | Version pinning, project-specific overrides            |


Both scopes can coexist. Project-level always takes precedence over global when both are present.

### Getting Started

#### Step 1 — Prerequisites for installation

APM pulls the package from a private GitHub Enterprise repo, so it needs credentials to download it:

1. `**gh` CLI** (v2.40.0+) — install with `brew install gh` if missing.
2. **GitHub Enterprise auth** — authenticate so APM can access the package:
  ```sh
   gh auth login --hostname git.marriott.com --web --git-protocol https
  ```

#### Step 2 — Install globally

```sh
apm install -g git.marriott.com/phoenix/mi-engineer-agent
```

This installs the package to your user scope (`~/.apm/`) and deploys skills, agents, prompts, and MCP servers to user-level directories (`~/.copilot/`, `~/.claude/`, etc.). Your IDE picks these up automatically in every project you open — no per-repo configuration required.

> **What you get vs. what you miss with global install:**
>
>
> |                                              | Global (`-g`) | Project (`apm.yml`) |
> | -------------------------------------------- | ------------- | ------------------- |
> | Skills (code-review, api-design, etc.)       | ✓             | ✓                   |
> | Agents (architect, backend-reviewer)         | ✓             | ✓                   |
> | Prompts (design-review, incident-response)   | ✓             | ✓                   |
> | MCP servers (GitHub, Atlassian, Playwright)  | ✓             | ✓                   |
> | Instructions deployed to IDE-native paths    | ✓             | ✓                   |
> | `AGENTS.md` / `CLAUDE.md` — compiled context | —             | ✓                   |
> | Hooks (pre-commit lint, security guard)      | —             | ✓                   |
> | Version pinning per repo                     | —             | ✓                   |
> | Project-specific overrides                   | —             | ✓                   |
>

#### `AGENTS.md` and `CLAUDE.md` — do you need them?

APM deploys instructions in **two forms**, and understanding the difference matters:

1. **Individual instruction files** (e.g., `.cursor/rules/*.mdc`, `.github/instructions/*.instructions.md`) — these are the IDE-native format. Each IDE loads them directly with full support for scoping, activation modes, and priority. In Cursor, `.mdc` rules support four activation modes: always apply, apply intelligently (AI decides based on task), apply to specific file globs, or apply only when mentioned. These are the **primary mechanism** for delivering instructions to the agent.
2. `**AGENTS.md` / `CLAUDE.md`** — these are compiled roll-ups of all instructions into a single markdown file at the project root. They act as **passive, always-loaded context**. The entire file is fed to the agent on every interaction. They exist for compatibility — `AGENTS.md` is a convention that Cursor, Copilot, Codex, and other tools all recognize as a baseline context file.

**In practice, the individual files do the heavy lifting.** They offer granular control (file-scoped rules, smart activation) and are higher priority in the IDE's rule hierarchy. `AGENTS.md` sits at the lowest priority and loads everything unconditionally, which can waste tokens in large projects.

**What this means for global install:** Global install deploys the individual instruction files to user-level directories (e.g., `~/.cursor/rules/`), so the agent **does** pick up coding standards and security baselines. You lose `AGENTS.md`, but since the individual files are the more capable mechanism, the practical impact is minimal. The main reasons to use project-level install are version pinning, overrides, and hooks — not `AGENTS.md` itself.

#### Step 3 — Configure tokens for runtime tools

The installed skills and MCP servers interact with GitHub at runtime. Set `GITHUB_TOKEN` so they can authenticate:

1. Generate a Personal Access Token at [https://git.marriott.com/settings/tokens](https://git.marriott.com/settings/tokens) with `repo` and `read:org` scopes.
2. Export it in your shell profile:
  ```sh
   # ~/.zshrc or ~/.bashrc
   export GITHUB_TOKEN="ghp_your_token_here"
  ```

Without this token the GitHub MCP server won't be able to create PRs, read issues, or perform other GitHub operations on your behalf.

#### Updating

To pull the latest version later:

```sh
apm deps update -g
```

### Per-Project Setup (when you need more control)

The global install covers most developers. Add a project-level `apm.yml` when a repo needs:

- **Version pinning** — lock a specific version so all developers on the repo use the same one.
- **Project-specific overrides** — replace a shipped skill or instruction with a custom version for that repo.
- **Team consistency** — the `apm.yml` is committed to source control, so `apm install` after clone reproduces the exact setup.

**Step 1 — Add `apm.yml` to the project root:**

```yaml
dependencies:
  mi-engineer-agent: "^1.0.0"
```

**Step 2 — Install:**

```sh
apm install
```

This pulls the package and generates IDE-specific files into the project root. The generated files should be gitignored — only `apm.yml` and `apm.lock.yaml` are committed.

### How the Two Scopes Interact

When both global and project-level installations exist, APM resolves with this precedence (highest first):

1. **Project-local files** — anything in the project's own `.apm/` directory
2. **Project dependencies** — packages in the project's `apm.yml`
3. **Global packages** — packages installed with `-g`

A project `apm.yml` always wins. If repo-A pins `mi-engineer-agent@1.0.0` but your global install has `2.0.0`, repo-A uses `1.0.0` when you work inside it. Outside any APM-configured project, the global `2.0.0` applies.

### Where Files Land

**Global scope** (from `apm install -g`) — primitives deploy to user-level directories in your home folder. Each IDE has its own path:

```
~/.apm/                                    # Package storage (shared)
│
├── ~/.cursor/                             # ── Cursor ──
│   ├── rules/*.mdc                        #   Instructions as Cursor rules
│   ├── agents/*.md                        #   Agent definitions
│   ├── skills/{name}/                     #   Skill folders
│   └── hooks.json                         #   Hook definitions
│
├── ~/.copilot/                            # ── GitHub Copilot / VS Code ──
│   ├── copilot-instructions.md            #   User-level instructions
│   ├── agents/*.md                        #   Agent definitions
│   └── mcp-config.json                    #   MCP server config
│
└── ~/.claude/                             # ── Claude Code ──
    ├── commands/*.md                      #   Prompts as slash commands
    ├── agents/*.md                        #   Agent definitions
    └── skills/{name}/                     #   Skill folders
```

Note: Copilot's user-level directory is `~/.copilot/`, **not** `~/.github/`. The `.github/` path is project-level only. No `AGENTS.md` or `CLAUDE.md` is generated at global scope.

**Project scope** (from `apm install` with `apm.yml`) — files are generated into the project root, organized by IDE target:

```
your-repo/
├── apm.yml                                # Committed to source control
├── apm.lock.yaml                          # Committed — pins exact versions
├── AGENTS.md                              # Compiled instructions — Cursor and Copilot read this
│
├── .cursor/                               # ── Cursor ──
│   ├── rules/*.mdc                        #   Instructions as Cursor rules
│   ├── agents/*.md                        #   Agent definitions
│   ├── skills/{name}/                     #   Skill folders
│   └── hooks.json                         #   Hook definitions
│
├── .github/                               # ── GitHub Copilot / VS Code ──
│   ├── instructions/*.instructions.md     #   Instruction files
│   ├── prompts/*.prompt.md                #   Prompt templates
│   ├── agents/*.agent.md                  #   Agent definitions
│   ├── skills/{name}/                     #   Skill folders
│   └── hooks/*.json                       #   Hook definitions
│
├── .claude/                               # ── Claude Code ──
│   ├── CLAUDE.md                          #   Compiled instructions
│   ├── commands/*.md                      #   Prompts as slash commands
│   ├── agents/*.md                        #   Agent definitions
│   └── skills/{name}/                     #   Skill folders
│
├── .mcp.json                              # MCP server definitions (all IDEs)
└── ... your existing project files
```

All generated files should be **gitignored**. Each developer runs `apm install` locally after cloning a repo that has an `apm.yml`. Only `apm.yml` and `apm.lock.yaml` are committed to source control.

### Version Management Across Repos

Each repo declares its own version constraint in `apm.yml`:

```yaml
# repo-a/apm.yml — accepts any 1.x.x
dependencies:
  mi-engineer-agent: "^1.0.0"

# repo-b/apm.yml — accepts any 2.x.x
dependencies:
  mi-engineer-agent: "^2.0.0"

# repo-c/apm.yml — pinned to exact version
dependencies:
  mi-engineer-agent: "1.3.2"
```

There is no conflict — each repo resolves independently. A legacy service can stay on v1 while a new service adopts v2. The `apm.lock.yaml` in each repo pins the exact commit SHA, so installs are reproducible regardless of new releases.

To pick up the latest version within your pinned range:

```sh
apm deps update
```

### Alternative Installation Methods

If the APM registry isn't an option, choose one of these:


| Method              | Best For                             | Command                                                            |
| ------------------- | ------------------------------------ | ------------------------------------------------------------------ |
| **GitHub repo URL** | Install from repo without registry   | `apm install https://git.marriott.com/phoenix/mi-engineer-agent`   |
| **Plugin format**   | Marketplace or manual plugin install | `apm pack --format plugin`                                         |
| **Git clone**       | Fork for full customization          | `git clone https://git.marriott.com/phoenix/mi-engineer-agent.git` |


GitHub Repo URL

Install directly:

```sh
apm install https://git.marriott.com/phoenix/mi-engineer-agent
```

Or add the repo URL to your `apm.yml`:

```yaml
dependencies:
  mi-engineer-agent: "https://git.marriott.com/phoenix/mi-engineer-agent"
```

To pin a specific version or branch, append a ref:

```yaml
dependencies:
  mi-engineer-agent: "https://git.marriott.com/phoenix/mi-engineer-agent#v1.0.0"
```

Git Clone

```sh
git clone https://git.marriott.com/phoenix/mi-engineer-agent.git
apm install --plugin ./mi-engineer-agent
```

Direct Download

Copy the `.apm/` directory and `.mcp.json` directly into your project.

Regardless of install method, always run `apm run setup` on first use.

### IDE-Specific Behavior

APM deploys primitives into the native directory structure each IDE expects. `apm install` handles this automatically — you define nothing extra.


| IDE                | Target   | Generated Paths                                                                                                  |
| ------------------ | -------- | ---------------------------------------------------------------------------------------------------------------- |
| **Cursor**         | `cursor` | `AGENTS.md`, `.cursor/rules/`, `.cursor/agents/`, `.cursor/skills/`, `.cursor/hooks.json`                        |
| **GitHub Copilot** | `vscode` | `AGENTS.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, `.github/skills/`, `.github/hooks/` |
| **Claude Code**    | `claude` | `CLAUDE.md`, `.claude/commands/`, `.claude/agents/`, `.claude/skills/`                                           |


APM auto-detects which targets to generate based on your project structure (e.g., `.cursor/` exists → Cursor target is enabled). You can also set the target explicitly in `apm.yml`:

```yaml
target:
  - cursor
  - copilot
  - claude
```

After installation, your IDE's AI agent automatically picks up the skills, instructions, agents, prompts, hooks, and MCP servers shipped in this package.

### Overriding Defaults

APM resolves configuration using a layered precedence system:

1. **Project-local files** — highest priority. Any file you place directly in your repo takes precedence.
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

APM merges the rest and only replaces the specific files you override. The same pattern works for agents, prompts, hooks, and MCP configs — mirror the file path locally and your version takes precedence.

### Access Levels and Governance

The `apm-policy.yml` file controls what consumers can and cannot change:

- **Skills, Instructions, Prompts** — fully overridable at the project level. Place a file at the same path and your version wins.
- **Hooks** — overridable in Cursor and Claude Code. GitHub Copilot does not support hooks.
- **MCP Servers** — consumers can add their own MCP servers alongside the ones shipped in this package. To replace a shipped server, define one with the same key in your local `.mcp.json`.
- **Agents** — overridable by placing a matching `.agent.md` at the same path.

The governance policy is set to `warn` enforcement, meaning policy violations produce warnings rather than blocking installs. This allows teams to iterate while the org converges on standards.

---

## License

MIT