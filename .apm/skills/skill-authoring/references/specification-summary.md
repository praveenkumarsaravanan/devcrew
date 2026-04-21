# Agent Skills Specification Summary

Source: [agentskills.io/specification](https://agentskills.io/specification)

This is a condensed reference of the agentskills.io specification. The SKILL.md in the parent directory covers the workflow; this file covers the exact constraints for validation.

## Frontmatter Fields

### `name` (required)


| Rule            | Constraint                                                                       |
| --------------- | -------------------------------------------------------------------------------- |
| Length          | 1–64 characters                                                                  |
| Characters      | Lowercase alphanumeric (`a-z`, `0-9`) and hyphens (`-`) only                     |
| Hyphens         | Must not start or end with a hyphen. Must not contain consecutive hyphens (`--`) |
| Directory match | Must exactly match the parent directory name                                     |


### `description` (required)


| Rule     | Constraint                                                              |
| -------- | ----------------------------------------------------------------------- |
| Length   | 1–1024 characters                                                       |
| Content  | Must describe what the skill does AND when to use it                    |
| Keywords | Include specific trigger words that help agents identify relevant tasks |


### `license` (optional)

Short license name or reference to a bundled license file (e.g., `Apache-2.0`, `Proprietary. LICENSE.txt has complete terms`).

### `compatibility` (optional)


| Rule    | Constraint                                                                  |
| ------- | --------------------------------------------------------------------------- |
| Length  | 1–500 characters                                                            |
| Content | Environment requirements: intended product, system packages, network access |


Only include if the skill has specific requirements. Most skills do not need this field.

### `metadata` (optional)

Arbitrary key-value mapping (string keys to string values). Use for properties not defined by the spec (e.g., `author`, `version`, `category`). Use reasonably unique key names to avoid conflicts.

### `allowed-tools` (optional, experimental)

Space-separated string of pre-approved tools (e.g., `Bash(git:*) Bash(jq:*) Read`). Support varies between agent implementations.

## Body Content

- Markdown after the frontmatter closing `---`
- No format restrictions, but recommended sections: overview, step-by-step workflow, guidelines, examples
- Keep under **500 lines** for efficient context usage
- Move detailed material to `references/` files

## Directory Structure

```
skill-name/
├── SKILL.md              # Required
├── scripts/              # Optional — executable code
│   └── *.sh, *.py, etc.
├── references/           # Optional — supplemental docs
│   └── *.md
├── assets/               # Optional — templates, resources
│   └── *.json, *.yaml, etc.
└── LICENSE               # Optional — if license field references it
```

## Progressive Disclosure Tiers


| Tier          | Content                              | Token Budget | When Loaded                |
| ------------- | ------------------------------------ | ------------ | -------------------------- |
| 1. Catalog    | `name` + `description`               | ~100 tokens  | Session start (all skills) |
| 2. Activation | Full `SKILL.md` body                 | <5000 tokens | When skill is selected     |
| 3. On-demand  | `scripts/`, `references/`, `assets/` | Varies       | When referenced in body    |


## Script Conventions

Scripts in `scripts/` should follow these conventions for agent compatibility:


| Convention             | Why                                                                    |
| ---------------------- | ---------------------------------------------------------------------- |
| No interactive prompts | Agents run in non-interactive shells; `read` will hang                 |
| `--help` flag          | Primary way agents discover the script interface                       |
| `--confirm` flag       | Bypasses prompts for non-interactive execution                         |
| `--dry-run` flag       | Previews destructive operations without side effects                   |
| `--json` flag          | Structured output agents can parse reliably                            |
| Diagnostics to stderr  | Keeps stdout clean for data; agents parse stdout                       |
| Distinct exit codes    | Documented in `--help`; agents branch on failure type                  |
| Pinned dependencies    | Reproducible behavior across environments                              |
| Idempotent operations  | Safe for agent retries ("create if not exists" over "create and fail") |


## File References

Reference files within the skill using relative paths from the skill root:

```markdown
See [reference guide](references/REFERENCE.md) for details.
Run: `bash scripts/validate.sh`
```

Keep references one level deep from `SKILL.md`. Avoid deeply nested reference chains.

## Cross-Client Installation Paths


| Client         | Skill Location                         |
| -------------- | -------------------------------------- |
| Cursor         | `.cursor/skills/{skill-name}/SKILL.md` |
| GitHub Copilot | `.github/skills/{skill-name}/SKILL.md` |
| Codex CLI      | `.agents/skills/{skill-name}/SKILL.md` |
| Amp            | `.agents/skills/{skill-name}/SKILL.md` |


APM handles deployment to the correct path based on the `target` list in `apm.yml`.

## Validation

```bash
skills-ref validate ./my-skill
```

Checks frontmatter validity, naming rules, and directory structure.