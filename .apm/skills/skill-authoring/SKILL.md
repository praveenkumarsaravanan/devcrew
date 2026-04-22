---
name: skill-authoring
description: >
  Create and maintain Agent Skills and Agent definitions following APM conventions.
  Use when writing a new skill or agent, modifying an existing SKILL.md or .agent.md,
  adding scripts or references, or when asked about structure, naming, or conventions.
---

# Skill & Agent Authoring

## Trigger

Activate this skill when:

- The user asks to create, write, or add a new skill or agent
- The user asks to modify or improve an existing SKILL.md or .agent.md
- The user asks about skill or agent structure, conventions, or the agentskills.io spec
- The user wants to add scripts, references, or assets to a skill
- The user is overriding or extending a skill or agent from a dependency

## Available Scripts

- **`scripts/validate.sh`** — Validates all agents and skills for correct frontmatter format, required fields, naming conventions, and structural rules

## Specification Source

All skill conventions are drawn from the [agentskills.io specification](https://agentskills.io/specification). Agent conventions follow the same frontmatter pattern. When in doubt, the spec is the source of truth.

---

## Part 1: Skills

### Directory Structure

Every skill is a directory containing at minimum a `SKILL.md` file. The directory name must exactly match the `name` field in the frontmatter.

```
skill-name/
├── SKILL.md              # Required — metadata + instructions
├── scripts/              # Optional — executable code
├── references/           # Optional — supplemental documentation
└── assets/               # Optional — templates, static resources
```

In this repo, skills live under `.apm/skills/`. Consumers may also define skills in their own `.apm/skills/` directory, which take precedence over package-level skills.

### Skill Workflow

#### 1. Choose a Name

- 1–64 characters
- Lowercase alphanumeric (`a-z`, `0-9`) and hyphens (`-`) only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name exactly

#### 2. Write the Frontmatter

The `SKILL.md` file starts with YAML frontmatter between `---` delimiters. **Both opening and closing `---` are required.**

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

Place in `scripts/` with relative paths. Follow these conventions for agent use:

- **No interactive prompts.** Accept all input via flags, env vars, or stdin.
- **Implement `--help`.** This is how agents learn the script interface.
- **Use `--confirm` for destructive actions, `--dry-run` for stateful operations, `--json` for structured output.**
- **Write diagnostics to stderr, data to stdout.**
- **Use distinct exit codes.** Document them in `--help`.

#### 5. Validate

Run the validation script before committing:

```bash
bash .apm/skills/skill-authoring/scripts/validate.sh --skills
```

Then compile:

```bash
apm compile
```

---

## Part 2: Agents

### File Structure

Each agent is a single `.agent.md` file. The filename (without `.agent.md`) must match the `name` field in the frontmatter.

```
.apm/agents/
├── architect.agent.md
├── backend-reviewer.agent.md
├── qa-lead.agent.md
└── test-engineer.agent.md
```

### Agent Workflow

#### 1. Choose a Name

Same rules as skills: lowercase, hyphens, no consecutive hyphens, 1–64 chars. The name becomes the filename: `my-agent.agent.md`.

#### 2. Write the Frontmatter

**Both opening and closing `---` are required.** This is the most common error — missing the closing delimiter breaks APM parsing.

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

**Correct:**

```yaml
---
name: my-agent
description: Does something useful
---

# My Agent        ← Body starts after the closing ---
```

#### 3. Write the Body

Structure agent definitions with these sections:

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

Run the validation script before committing:

```bash
bash .apm/skills/skill-authoring/scripts/validate.sh --agents
```

Or validate a single file:

```bash
bash .apm/skills/skill-authoring/scripts/validate.sh --file .apm/agents/my-agent.agent.md
```

Then compile:

```bash
apm compile
```

---

## Validation Script

The validation script checks all agents and skills automatically:

```bash
bash .apm/skills/skill-authoring/scripts/validate.sh           # All agents and skills
bash .apm/skills/skill-authoring/scripts/validate.sh --agents   # Agents only
bash .apm/skills/skill-authoring/scripts/validate.sh --skills   # Skills only
bash .apm/skills/skill-authoring/scripts/validate.sh --json     # JSON output for CI
bash .apm/skills/skill-authoring/scripts/validate.sh --help     # Usage
```

**What it checks:**

| Check | Agents | Skills |
|---|---|---|
| Opening `---` delimiter present | ✓ | ✓ |
| Closing `---` delimiter present | ✓ | ✓ |
| `name` field exists and is valid | ✓ | ✓ |
| `name` matches filename/directory | ✓ | ✓ |
| `description` field exists | ✓ | ✓ |
| No uppercase in name | ✓ | ✓ |
| No consecutive hyphens in name | ✓ | ✓ |
| Line count under limit (300 agents, 500 skills) | ✓ | ✓ |
| Scripts implement `--help` | — | ✓ |

**Always run validation after creating or modifying any agent or skill.** Then run `apm compile` to regenerate output files.

## Progressive Disclosure

Agents load skills in tiers to optimize token usage:

| Tier | What loads | Budget |
|---|---|---|
| **1. Catalog** | `name` + `description` from frontmatter | ~100 tokens per skill |
| **2. Activation** | Full `SKILL.md` body | <5000 tokens recommended |
| **3. On-demand** | Files in `scripts/`, `references/`, `assets/` | Loaded only when referenced |

Front-load the most important instructions in the body. Put detailed reference material in separate files.

## Guardrails

- **Always run `bash .apm/skills/skill-authoring/scripts/validate.sh` before committing.** This catches frontmatter errors, naming violations, and line count issues automatically.
- **Always run `apm compile` after validation passes.** Validation checks format; compilation checks APM integration.
- **Always check the spec.** The [agentskills.io specification](https://agentskills.io/specification) is the source of truth.
- **Never use uppercase in names.** Lowercase alphanumeric + hyphens only.
- **Never exceed line limits.** 500 lines for SKILL.md, 300 lines for .agent.md. Split into `references/` files.
- **Never omit the closing `---` in frontmatter.** This is the #1 parsing error.
- **Never write interactive scripts for agent use.** All input must come from flags or env vars.
- **Always include a description with trigger keywords.** Without trigger context, agents cannot match the skill or agent to user intent.

## References

- [Full Specification Summary](references/specification-summary.md) — complete field constraints, naming rules, and validation criteria from agentskills.io
