---
name: apm-authoring
description: >
  Create and maintain all APM artifacts — skills, agents, instructions, prompts,
  and hooks. Use when writing or modifying any .apm/ file, or when asked about
  APM structure, naming conventions, or the agentskills.io spec.
---

# APM Authoring

## Trigger

Activate this skill when:

- The user asks to create, write, or modify a skill, agent, instruction, prompt, or hook
- The user asks about APM structure, conventions, or the agentskills.io spec
- The user wants to add scripts, references, or assets to a skill
- The user is overriding or extending an artifact from a dependency

## Available Scripts

- **`scripts/validate.sh`** — Validates all APM artifacts for correct frontmatter, required fields, naming conventions, and structural rules

## Specification Source

Skill and agent conventions are drawn from the [agentskills.io specification](https://agentskills.io/specification). When in doubt, the spec is the source of truth.

---

## Part 1: Skills

### Directory Structure

Every skill is a directory under `.apm/skills/` containing at minimum a `SKILL.md`. The directory name must exactly match the `name` field in the frontmatter.

```
skill-name/
├── SKILL.md              # Required — metadata + instructions
├── scripts/              # Optional — executable code
├── references/           # Optional — supplemental documentation
└── assets/               # Optional — templates, static resources
```

### Skill Workflow

#### 1. Choose a Name

- 1–64 characters, lowercase alphanumeric + hyphens only
- Must not start/end with a hyphen or contain consecutive hyphens
- Must match the parent directory name exactly

#### 2. Write the Frontmatter

**Both opening and closing `---` are required.**

```yaml
---
name: my-skill
description: >
  What the skill does and when to use it.
---
```

| Field | Required | Constraints |
|---|---|---|
| `name` | Yes | Must match directory name. 1–64 chars, lowercase + hyphens. |
| `description` | Yes | 1–1024 chars. Include functionality AND trigger keywords. |
| `license` | No | License name or reference to a bundled file |
| `compatibility` | No | Environment requirements, max 500 chars |

#### 3. Write the Body

Structure with: **Trigger**, **Workflow**, **Guardrails**, and optionally **References**. Keep `SKILL.md` under **500 lines**. Move detailed material to `references/*.md`.

#### 4. Add Scripts (If Needed)

Place in `scripts/` with relative paths. Conventions for agent use:

- **No interactive prompts.** Accept all input via flags, env vars, or stdin.
- **Implement `--help`.** This is how agents learn the script interface.
- **Use `--confirm` for destructive actions, `--dry-run` for stateful operations, `--json` for structured output.**
- **Write diagnostics to stderr, data to stdout.**
- **Use distinct exit codes.** Document them in `--help`.

#### 5. Validate

```bash
bash .apm/skills/apm-authoring/scripts/validate.sh --skills
apm compile
```

---

## Part 2: Agents

### File Structure

Each agent is a single `.agent.md` file under `.apm/agents/`. The filename (without `.agent.md`) must match the `name` field.

```
.apm/agents/
├── architect.agent.md
├── backend-reviewer.agent.md
└── test-engineer.agent.md
```

### Agent Workflow

#### 1. Choose a Name

Same rules as skills: lowercase + hyphens, 1–64 chars. The name becomes the filename: `my-agent.agent.md`.

#### 2. Write the Frontmatter

**Both opening and closing `---` are required.** Missing the closing delimiter is the #1 parsing error.

```yaml
---
name: my-agent
description: One-line summary of what the agent does and when to use it
---
```

| Field | Required | Constraints |
|---|---|---|
| `name` | Yes | Must match filename (without `.agent.md`). Lowercase + hyphens. |
| `description` | Yes | One-line summary. Include the agent's role and trigger context. |

**Common mistake — missing closing `---`:**

```yaml
---
name: my-agent
description: Does something useful

# My Agent        ← APM cannot parse this — frontmatter never closed
```

#### 3. Write the Body

| Section | Purpose |
|---|---|
| **Role description** | Who the agent is and what perspective it brings (1-2 paragraphs) |
| **Core Responsibilities** | What the agent evaluates, produces, or decides |
| **Evaluation Checklist / Framework** | Concrete criteria the agent uses (tables work well) |
| **Output Format** | How the agent structures its response |
| **Anti-Patterns** | What the agent flags as wrong (makes the agent opinionated) |
| **Handoff** | What the agent receives from and produces for other agents in a workflow |

Keep agent files under **300 lines** for token efficiency.

#### 4. Validate

```bash
bash .apm/skills/apm-authoring/scripts/validate.sh --agents
apm compile
```

---

## Part 3: Instructions

Instructions are always-on rules that APM injects into agent context for matching files. They live under `.apm/instructions/` as individual `.instructions.md` files.

### File Structure

```
.apm/instructions/
├── coding-standards.instructions.md
└── security-baseline.instructions.md
```

### Frontmatter

```yaml
---
description: What this instruction set covers
applyTo: "**/*.{ts,js,py,go,java,rs}"
---
```

| Field | Required | Purpose |
|---|---|---|
| `description` | Yes | Summary of the instruction's scope. Used in compiled output. |
| `applyTo` | Yes | Glob pattern for which files these rules apply to. |

### Writing Guidelines

- Instructions are **passive context** — they load automatically for matching files, unlike skills which activate on demand.
- Keep each file focused on one concern (e.g., security, coding standards). Do not combine unrelated rules.
- Use bullet lists and tables for scannable rules. Agents process structured content more reliably.
- Avoid duplicating content that belongs in a skill. Instructions define *what* rules to follow; skills define *how* to perform tasks.

### Validate

```bash
bash .apm/skills/apm-authoring/scripts/validate.sh --instructions
apm compile
```

---

## Part 4: Prompts

Prompts are reusable, user-invokable templates that agents follow for specific tasks. They live under `.apm/prompts/` as `.prompt.md` files.

### File Structure

```
.apm/prompts/
├── design-review.prompt.md
└── incident-response.prompt.md
```

### Format

Prompts do **not** use YAML frontmatter. They are plain Markdown starting with a heading.

```markdown
# Prompt Title

Step-by-step instructions for the agent to follow when this prompt is invoked.
```

### Writing Guidelines

- Start with a `# Heading` that describes the task.
- Use numbered steps for sequential workflows. Agents follow numbered lists more reliably than prose.
- Be specific about the output format. If you want a table, severity levels, or a checklist, say so.
- End with the most important constraint: e.g., "Prioritize speed of mitigation over perfection."
- Keep prompts under **100 lines**. They load entirely into context on invocation.

### Naming

- Filename: `kebab-case.prompt.md` (e.g., `incident-response.prompt.md`)
- The name should describe the task, not the role (e.g., `design-review` not `architect-prompt`)

### Validate

```bash
bash .apm/skills/apm-authoring/scripts/validate.sh --prompts
apm compile
```

---

## Part 5: Hooks

Hooks are JSON configuration files that trigger agent actions on specific events. They live under `.apm/hooks/`.

### File Structure

```
.apm/hooks/
└── pre-commit-lint.json
```

### Format

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      {
        "name": "hook-name",
        "type": "prompt",
        "prompt": "What the agent should do when triggered",
        "matchers": {
          "filePattern": "\\.(ts|js|py)$"
        }
      }
    ]
  }
}
```

### Available Hook Events

| Event | Fires when |
|---|---|
| `afterFileEdit` | A file matching the pattern is edited |
| `preToolUse` | Before a tool is executed (can block the action) |

### Writing Guidelines

- Each hook must have a `name`, `type`, and `prompt`.
- Use `matchers` to scope hooks narrowly. Broad patterns (e.g., `.*`) waste tokens on irrelevant files.
- Use `preToolUse` hooks sparingly — they add latency to every matching tool call.
- Keep prompts concise. The hook prompt loads into context on every trigger.

### Validate

```bash
bash .apm/skills/apm-authoring/scripts/validate.sh --hooks
apm compile
```

---

## Validation Script

The validation script checks all APM artifacts automatically:

```bash
bash .apm/skills/apm-authoring/scripts/validate.sh              # Everything
bash .apm/skills/apm-authoring/scripts/validate.sh --agents      # Agents only
bash .apm/skills/apm-authoring/scripts/validate.sh --skills      # Skills only
bash .apm/skills/apm-authoring/scripts/validate.sh --instructions # Instructions only
bash .apm/skills/apm-authoring/scripts/validate.sh --prompts     # Prompts only
bash .apm/skills/apm-authoring/scripts/validate.sh --hooks       # Hooks only
bash .apm/skills/apm-authoring/scripts/validate.sh --json        # JSON output for CI
```

**Always run validation after creating or modifying any APM artifact.** Then run `apm compile` to regenerate output files.

## Guardrails

- **Always run `bash .apm/skills/apm-authoring/scripts/validate.sh` before committing.**
- **Always run `apm compile` after validation passes.** Validation checks format; compilation checks APM integration.
- **Always check the spec.** The [agentskills.io specification](https://agentskills.io/specification) is the source of truth for skills and agents.
- **Never use uppercase in names.** Lowercase alphanumeric + hyphens only.
- **Never exceed line limits.** 500 lines for skills, 300 for agents, 100 for prompts.
- **Never omit the closing `---` in frontmatter.** This is the #1 parsing error for skills and agents.
- **Never write interactive scripts for agent use.** All input must come from flags or env vars.

## References

- [Full Specification Summary](references/specification-summary.md) — complete field constraints, naming rules, and validation criteria from agentskills.io
