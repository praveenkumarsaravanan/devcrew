# DevCrew

AI engineering team simulation -- specialized agents, skills, rules, hooks, and workflows for Cursor, GitHub Copilot, and Claude Code, distributed via [Microsoft APM](https://microsoft.github.io/apm/).

---

## About the Project

DevCrew defines all engineering primitives -- skills, agents, instructions, prompts, hooks, and MCP servers -- in a single `.apm/` directory. APM compiles and deploys the correct format for each target IDE so teams get consistent tooling regardless of their editor. Supported targets include Cursor, GitHub Copilot, and Claude Code.

### What's Included


| Type        | Name                | Description                                                           |
| ----------- | ------------------- | --------------------------------------------------------------------- |
| Skill       | `team-workflow`     | Right-sized dev lifecycle (quick-fix to full-feature) across backend, frontend, and fullstack |
| Skill       | `testing`           | Write tests for existing or new code outside the full team-workflow   |
| Skill       | `debugging`         | Systematic error investigation in dev/staging environments            |
| Skill       | `code-review`       | Structured code review with severity levels                           |
| Skill       | `api-design`        | REST/gRPC API design guidance and validation                          |
| Skill       | `commit-message`    | Construct commit messages matching commitlint conventions              |
| Skill       | `branch-creation`   | Create branches with naming conventions                               |
| Skill       | `pull-request`      | PR creation with ticket validation and discrepancy detection          |
| Skill       | `documentation`     | Write and maintain READMEs, guides, runbooks, and ADRs                |
| Skill       | `git-release-tag`   | Tag, release, and publish new versions with changelog                 |
| Skill       | `apm-authoring`     | Create and maintain all APM artifacts (skills, agents, instructions, prompts, hooks) |
| Skill       | `project-detection` | Classify workspace as backend, frontend, fullstack, or infra          |
| Skill       | `java-standards`    | Java coding standards, security baseline, and Spring Boot best practices |
| Skill       | `react-standards`   | React coding standards, security baseline, and TypeScript best practices |
| Agent       | `backend-reviewer`  | Code reviewer for backend services (security, performance, quality)   |
| Agent       | `frontend-reviewer` | Code reviewer for frontend (accessibility, performance, design system)|
| Agent       | `architect`         | Architecture decision support across backend and frontend             |
| Agent       | `product-analyst`   | Requirements clarification and acceptance criteria                    |
| Agent       | `senior-developer`  | Scalability, performance, rollout, and test guidance                  |
| Agent       | `junior-developer`  | Clean implementation following codebase patterns                      |
| Agent       | `test-engineer`     | Test code implementation from QA Lead's test plan                     |
| Agent       | `qa-lead`           | Test strategy, quality review, and go/no-go decisions                 |
| Agent       | `devops-engineer`   | CI/CD pipeline, deployment strategy, and infrastructure               |
| Agent       | `release-manager`   | Release readiness, go/no-go decisions, and rollback plans             |
| Agent       | `sre`               | Observability, SLOs, alerting, and customer impact                    |
| Instruction | `coding-standards`  | Universal coding principles -- routes to `java-standards` or `react-standards` |
| Instruction | `security-baseline` | Universal security rules -- routes to `java-standards` or `react-standards`   |
| Prompt      | `quickstart`        | Orientation guide -- maps common tasks to the right skill or prompt   |
| Prompt      | `design-review`     | Design review for scalability, reliability, and cost                  |
| Prompt      | `incident-response` | Production incident triage and resolution                             |
| Prompt      | `adr`               | Architecture decision record (Nygard format)                          |
| Prompt      | `dependency-audit`  | Audit dependencies for vulnerabilities and license risk               |
| Prompt      | `devops-plan`       | Deployment strategy and CI/CD pipeline design                         |
| Prompt      | `release-readiness` | Go/no-go checklist for production release                             |
| Prompt      | `monitoring-plan`   | SLOs, alerting, and runbook design                                    |
| Hook        | `edit-guards`       | Lint check on file edit + security guard on write operations          |
| MCP         | `playwright`        | Browser automation and E2E testing                                    |
| MCP         | `github`            | Repository, PR, and issue management                                  |
| MCP         | `atlassian`         | Jira, Confluence, and Compass via Atlassian Rovo                      |


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

1. Create a feature branch: `git checkout -b feat/ISSUE-123-add-new-skill`
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
