# DevCrew

AI engineering team simulation -- specialized agents, skills, rules, hooks, and workflows for Cursor, GitHub Copilot, and Claude Code, distributed via [Microsoft APM](https://microsoft.github.io/apm/).

---

## About the Project

DevCrew defines all engineering primitives -- skills, agents, instructions, prompts, hooks, and MCP servers -- in a single `.apm/` directory. APM compiles and deploys the correct format for each target IDE so teams get consistent tooling regardless of their editor. Supported targets include Cursor, GitHub Copilot, and Claude Code.

### What's Included


| Type        | Name                    | Description                                                          |
| ----------- | ----------------------- | -------------------------------------------------------------------- |
| Skill       | `code-review`           | Structured code review with severity levels                          |
| Skill       | `api-design`            | REST/gRPC API design guidance and validation                         |
| Skill       | `commit-message`        | Construct commit messages matching commitlint hook                   |
| Skill       | `branch-creation`       | Create branches with naming conventions                              |
| Skill       | `pull-request`          | PR creation with JIRA validation and discrepancy detection           |
| Skill       | `documentation`         | Write and maintain READMEs, guides, runbooks, and ADRs               |
| Skill       | `git-release-tag`       | Tag, release, and publish new versions with changelog                |
| Skill       | `apm-authoring`         | Create and maintain all APM artifacts                                |
| Skill       | `project-detection`     | Classify workspace as backend, frontend, fullstack, or infra         |
| Skill       | `backend-team-workflow` | Orchestrated 5-phase backend development lifecycle across team roles |
| Agent       | `backend-reviewer`      | Automated PR reviewer for backend services                           |
| Agent       | `architect`             | Architecture decision support agent                                  |
| Agent       | `product-analyst`       | Requirements clarification and acceptance criteria                   |
| Agent       | `senior-developer`      | Scalability, performance, rollout, and test guidance                 |
| Agent       | `junior-developer`      | Clean implementation following codebase patterns                     |
| Agent       | `test-engineer`         | Test code implementation from QA Lead's test plan                    |
| Agent       | `qa-lead`               | Test strategy, quality review, and go/no-go decisions                |
| Agent       | `devops-engineer`       | CI/CD pipeline, deployment strategy, and infrastructure              |
| Agent       | `release-manager`       | Release readiness, go/no-go decisions, and rollback plans            |
| Agent       | `sre`                   | Observability, SLOs, alerting, and customer impact                   |
| Instruction | `coding-standards`      | Coding conventions and style                                         |
| Instruction | `security-baseline`     | Security requirements and baseline controls                          |
| Prompt      | `design-review`         | Prompt template for design review sessions                           |
| Prompt      | `incident-response`     | Prompt template for incident triage                                  |
| Hook        | `pre-commit-lint`       | Lint check + security guard on pre-commit                            |
| MCP         | `playwright`            | Browser automation and E2E testing                                   |
| MCP         | `github`                | Repository, PR, and issue management                                 |
| MCP         | `atlassian`             | Jira, Confluence, and Compass via Atlassian Rovo                     |


### IDE Compatibility


| Component    | Cursor | GitHub Copilot | Claude Code |
| ------------ | ------ | -------------- | ----------- |
| Skills       | Yes    | Yes            | Yes         |
| Agents       | Yes    | Yes            | Yes         |
| Instructions | Yes    | Yes            | Yes         |
| Prompts      | Yes    | Yes            | Yes         |
| Hooks        | Yes    | N/A            | Yes         |
| MCP          | Yes    | Yes            | Yes         |


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

## Quick Start

### Prerequisites

- **APM CLI** -- `brew tap microsoft/apm && brew install apm`
- **gh CLI** (v2.40.0+) -- `brew install gh`

### Install Globally

```sh
apm install -g github.com/praveenkumarsaravanan/devcrew
```

Every project on your machine gets the agents, skills, and instructions automatically.

### Install Per-Project

Add to your project's `apm.yml`:

```yaml
name: my-service
version: "1.0.0"
dependencies:
  apm:
    - git: "https://github.com/praveenkumarsaravanan/devcrew.git"
      ref: trunk
```

Then run:

```sh
apm install
```

---

## Contributing

### Local Setup

```sh
git clone https://github.com/praveenkumarsaravanan/devcrew.git
cd devcrew
apm run setup
apm compile
```

### Development Workflow

1. Create a feature branch: `git checkout -b feat/PROJ-123-add-new-skill`
2. Edit files under `.apm/`
3. Validate: `apm compile`
4. Commit: `git commit -m "feat(skills): add terraform-plan skill"`
5. Open a PR against `trunk`

### Releasing

```sh
git checkout trunk && git pull
bash .apm/skills/git-release-tag/scripts/release.sh          # patch (default)
bash .apm/skills/git-release-tag/scripts/release.sh minor     # minor
bash .apm/skills/git-release-tag/scripts/release.sh major     # major
```

Preview with `--dry-run`. Run non-interactively with `--confirm`.

---

## License

MIT
