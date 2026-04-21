---
name: skill-authoring
description: >
  Create and maintain Agent Skills following the agentskills.io specification.
  Use when writing a new skill, modifying an existing SKILL.md, adding scripts
  or references to a skill, or when asked about skill structure, naming, or
  conventions.
---

# Skill Authoring

## Trigger

Activate this skill when:

- The user asks to create, write, or add a new skill
- The user asks to modify or improve an existing SKILL.md
- The user asks about skill structure, conventions, or the agentskills.io spec
- The user wants to add scripts, references, or assets to a skill
- The user is overriding or extending a skill from a dependency

## Specification Source

All conventions in this skill are drawn from the [agentskills.io specification](https://agentskills.io/specification). When in doubt, the spec is the source of truth.

## Directory Structure

Every skill is a directory containing at minimum a `SKILL.md` file. The directory name must exactly match the `name` field in the frontmatter.

```
skill-name/
├── SKILL.md              # Required — metadata + instructions
├── scripts/              # Optional — executable code
├── references/           # Optional — supplemental documentation
└── assets/               # Optional — templates, static resources
```

In this repo, skills live under `.apm/skills/`. Consumers may also define skills in their own `.apm/skills/` directory, which take precedence over package-level skills.

## Workflow

### 1. Choose a Name

The name must satisfy all of these rules:

- 1–64 characters
- Lowercase alphanumeric (`a-z`, `0-9`) and hyphens (`-`) only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name exactly

```
✅ code-review, api-design, skill-authoring
❌ Code-Review (uppercase), -api (leading hyphen), my--skill (consecutive hyphens)
```

### 2. Write the Frontmatter

The `SKILL.md` file starts with YAML frontmatter between `---` delimiters.

**Required fields:**

| Field | Constraints |
| --- | --- |
| `name` | Must match directory name. 1–64 chars, lowercase + hyphens. |
| `description` | 1–1024 chars. Describe what the skill does AND when to use it. Include trigger keywords so agents can match it to user intent. |

**Optional fields:**

| Field | Purpose |
| --- | --- |
| `license` | License name or reference to a bundled file |
| `compatibility` | Environment requirements, max 500 chars (e.g., "Requires Python 3.14+") |
| `metadata` | Arbitrary key-value pairs (e.g., `author`, `version`) |
| `allowed-tools` | Space-separated pre-approved tools (experimental) |

**Good description — includes functionality AND trigger keywords:**

```yaml
description: >
  Extracts text and tables from PDF files, fills PDF forms, and merges
  multiple PDFs. Use when working with PDF documents or when the user
  mentions PDFs, forms, or document extraction.
```

**Bad description — too vague for agent matching:**

```yaml
description: Helps with PDFs.
```

### 3. Write the Body

The Markdown body after the frontmatter contains instructions the agent follows. Structure it with these sections:

| Section | Purpose |
| --- | --- |
| **Trigger** | When to activate — list concrete phrases and situations |
| **Workflow** | Numbered steps the agent follows, with code blocks for commands |
| **Guardrails** | Hard rules the agent must never break |
| **References** (optional) | Links to files in `references/` for detailed context |

Keep `SKILL.md` under **500 lines**. Agents load the full body into context on activation — larger files waste tokens. Move detailed reference material to `references/*.md`.

### 4. Add Scripts (If Needed)

Place executable scripts in `scripts/` and reference them with relative paths from the skill root:

```markdown
## Available Scripts

- **`scripts/validate.sh`** — Validates configuration files

## Workflow

1. Run validation:
   ```bash
   bash scripts/validate.sh "$INPUT_FILE"
   ```
```

**Script conventions for agent use** (from [agentskills.io/skill-creation/using-scripts](https://agentskills.io/skill-creation/using-scripts)):

- **No interactive prompts.** Agents cannot respond to TTY input. Accept all input via flags, env vars, or stdin.
- **Implement `--help`.** This is how agents learn the script interface.
- **Use `--confirm` for destructive actions.** Let agents skip prompts explicitly rather than piping `yes`.
- **Use `--dry-run` for stateful operations.** Lets agents preview before committing.
- **Use `--json` for structured output.** Agents parse structured data better than free-form text.
- **Write diagnostics to stderr, data to stdout.** Keeps parseable output clean.
- **Use distinct exit codes.** Document them in `--help` so agents can branch on failure type.
- **Pin dependency versions.** Use inline dependency declarations where the language supports it (PEP 723 for Python, `npm:` specifiers for Deno).

### 5. Add References (If Needed)

Place supplemental documentation in `references/`. Keep each file focused on one topic. Reference from `SKILL.md`:

```markdown
## References

- [Review Checklist](references/review-checklist.md) — detailed per-category checklist
```

### 6. Validate

Before committing, verify:

- [ ] `name` in frontmatter matches the directory name exactly
- [ ] `name` passes naming rules (lowercase, no consecutive hyphens, no leading/trailing hyphen)
- [ ] `description` includes what the skill does AND when to use it (trigger keywords)
- [ ] `SKILL.md` is under 500 lines
- [ ] All script paths in code blocks use relative paths from the skill root
- [ ] Scripts include `--help`, avoid interactive prompts, and use meaningful exit codes
- [ ] No secrets, tokens, or credentials in any skill file

## Progressive Disclosure

Agents load skills in tiers to optimize token usage. Design with this in mind:

| Tier | What loads | Budget |
| --- | --- | --- |
| **1. Catalog** | `name` + `description` from frontmatter | ~100 tokens, loaded at session start for all skills |
| **2. Activation** | Full `SKILL.md` body | <5000 tokens recommended, loaded when skill is selected |
| **3. On-demand** | Files in `scripts/`, `references/`, `assets/` | Loaded only when explicitly referenced in the body |

Front-load the most important instructions in the body. Put detailed reference material in separate files so it only consumes tokens when needed.

## Guardrails

- **Always check the spec.** The [agentskills.io specification](https://agentskills.io/specification) is the source of truth. If this skill and the spec disagree, follow the spec.
- **Never use uppercase in skill names.** The spec strictly requires lowercase alphanumeric + hyphens.
- **Never exceed 500 lines in SKILL.md.** Split into `references/` files instead.
- **Never hardcode absolute paths in scripts.** Use relative paths from the skill root.
- **Never write interactive scripts for agent use.** All input must come from flags or env vars. Interactive prompts hang the agent session.
- **Always include a description with trigger keywords.** A skill without trigger context will never be activated by an agent.
- **Always list scripts in the body.** Agents discover scripts through the `SKILL.md` body, not by scanning the filesystem.

## References

- [Full Specification Summary](references/specification-summary.md) — complete field constraints, naming rules, and validation criteria from agentskills.io
