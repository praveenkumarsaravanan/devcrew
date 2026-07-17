# DevCrew

AI engineering team simulation -- specialized agents, skills, rules, hooks, and workflows for Cursor, GitHub Copilot, Claude Code, and Codex CLI, distributed via [Microsoft APM](https://microsoft.github.io/apm/).

---

## About the Project

DevCrew defines all engineering primitives -- skills, agents, instructions, prompts, hooks, and MCP servers -- in a single `.apm/` directory. APM compiles and deploys the correct format for each target IDE so teams get consistent tooling regardless of their editor. Supported targets include Cursor, GitHub Copilot, Claude Code, and Codex CLI.

Codex receives skills, agents, hooks, MCP, and compiled instructions (`AGENTS.md`). Workflow prompts (`/engineering-flow`, etc.) are not supported by the Codex target — use skills or invoke agents directly instead.

### What's Included

**32 skills**, **19 agents**, **27 prompts**, **10 instructions**, hooks, MCP servers, spec templates, and eval scenarios — compiled from `.apm/` for Cursor, Copilot, Claude, and Codex.

**Authoritative catalog:** [docs/devcrew-index.md](docs/devcrew-index.md)

**Topic guides:** [Engineering Flow](docs/engineering-flow.md) · [Triage](docs/triage.md) · [FHIR / HL7](docs/fhir-health-interop.md) · [Data platform](docs/data-platform-workflow.md) · [Node + AWS](docs/typescript-node-aws-workflow.md)

Do not duplicate the full primitive list in other files — see [documentation layering](docs/documentation-layering.md).

Flagship entry points: `/engineering-flow` (build/fix/change), `/quickstart` (orientation), `code-review`, `triage`, `fhir-health-interop`.

### IDE Compatibility


| Component    | Cursor | GitHub Copilot | Claude Code | Codex CLI |
| ------------ | ------ | -------------- | ----------- | --------- |
| Skills       | Yes    | Yes            | Yes         | Yes       |
| Agents       | Yes    | Yes            | Yes         | Yes       |
| Instructions | Yes    | Yes            | Yes         | Yes¹      |
| Prompts      | Yes    | Yes            | Yes         | No        |
| Hooks        | Yes    | N/A            | Yes         | Yes       |
| MCP          | Yes    | Yes            | Yes         | Yes       |

¹ Codex folds instructions into root `AGENTS.md` at compile time (no per-file rules).


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

From the DevCrew repo (recommended — deploys prompts and Codex hooks too):

```sh
apm run install-global
```

Or manually:

```sh
apm install -g --https github.com/praveenkumarsaravanan/devcrew
APM_GLOBAL=1 bash scripts/post-install.sh --global
```

Every project on your machine gets the agents, skills, and instructions automatically. `install-global` compiles, deploys **cursor**, **claude**, and **codex**, syncs skills, and runs post-install (prompts + Codex hooks).

See the full catalog: [docs/devcrew-index.md](docs/devcrew-index.md)

### Run Engineering Flow

Use DevCrew Engineering Flow for day-to-day build, fix, and change requests:

```text
/engineering-flow Add validation to the booking form
```

Use council planning only when you want options and trade-offs before implementation:

```text
/convene-council Compare approaches for retry handling in the worker
```

### FHIR / HL7 development

See **[FHIR / HL7 guide](docs/fhir-health-interop.md)**. **Rule of thumb:** build → `fhir-health-interop` skill; audit → `/fhir-review`.

### Production issue triage

See **[Triage guide](docs/triage.md)**. **Rule of thumb:** production hypothesis → `triage`; active incident → `/incident-response`; dev/staging → `debugging`.

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

## Documentation

- [Documentation layering](docs/documentation-layering.md) — **where to add vs remove** (one fact, one place)
- [DevCrew Index](docs/devcrew-index.md) — executive summary and full primitive catalog
- [Engineering Flow](docs/engineering-flow.md) — workflow phases and routing
- [Triage](docs/triage.md) — production hypothesis vs incident response vs debugging
- [FHIR / HL7](docs/fhir-health-interop.md) — build vs review, IG bundle setup
- [Council Model](docs/council-model.md) — planning-only council reviews
- [Eval Suite](evals/README.md) — behavioral regression tests

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
