---
name: team-package-management
description: >
  Creates and manages Tier 2 team APM packages — shared coding standards, domain-specific
  skills, and team workflows. Supports monorepo (folder in DevCrew) and separate repo
  hosting strategies. Use when creating a team package, adding team standards, or managing
  shared team primitives.
---

# Team Package Management

## Trigger

Activate this skill when:

- The user asks to "create a team package," "scaffold team standards," or "set up shared team config."
- The `/new-team-package` prompt invokes this skill.
- The user wants to add, modify, or remove primitives in an existing team package.

Do NOT activate for:

- Project-specific configuration — that belongs at Tier 3 (project level), not in a team package.
- Root DevCrew modifications — use `apm-authoring` for Tier 1 changes.

## Overview

Team packages (Tier 2) sit between root DevCrew (Tier 1) and individual projects (Tier 3) in the APM resolution hierarchy:

```
Tier 1: Root DevCrew (universal) → Tier 2: Team Package (team standards) → Tier 3: Project (project-specific)
```

APM resolves primitives by path. A team package can override any DevCrew primitive by mirroring the file path under its own `.apm/` directory. Projects inherit from both tiers, with project-local overrides taking highest precedence.

## Workflow

### Step 1: Determine Action

| User intent | Action |
|-------------|--------|
| Create a new team package | Go to Step 2 |
| Add a primitive to an existing team package | Go to Step 5 |
| List what a team package provides | Go to Step 6 |

### Step 2: Choose Hosting Strategy

Present the two options:

| Strategy | Location | When to use |
|----------|----------|-------------|
| **Monorepo** | `teams/<team-name>/` inside the DevCrew repo | Starting out, small team, simple governance |
| **Separate repo** | Standalone git repository | Independent versioning, access control, CI isolation |

**Recommendation:** Start with monorepo. Extract to a separate repo later if the team needs independent versioning or access control.

### Step 3: Collect Team Details

Ask for:
1. Team name (kebab-case, e.g., `payments-team`, `platform-team`)
2. Primary domain (e.g., "payment processing", "platform infrastructure", "mobile apps")
3. DevCrew version to pin (for separate repo only — monorepo inherits the parent version)

### Step 4: Scaffold the Package

**Monorepo scaffold:** Create at `teams/<team-name>/` inside the DevCrew repo:

```
teams/<team-name>/
├── .apm/
│   ├── instructions/
│   │   └── <team-name>-standards.instructions.md    # Example override
│   ├── skills/                                       # Empty — ready for team skills
│   ├── prompts/                                      # Empty — ready for team prompts
│   └── agents/                                       # Empty — ready for agent overrides
├── apm.yml
├── apm-policy.yml
└── README.md
```

**Separate repo scaffold:** Create in a new directory:

```
<team-name>-standards/
├── .apm/
│   ├── instructions/
│   │   └── <team-name>-standards.instructions.md    # Example override
│   ├── skills/
│   ├── prompts/
│   └── agents/
├── apm.yml                                           # Depends on DevCrew
├── apm-policy.yml
└── README.md
```

**Generate `apm.yml`:**

- **Monorepo:**
  ```yaml
  name: <team-name>-standards
  version: "1.0.0"
  description: "Team standards for <team-name>"
  ```

- **Separate repo:**
  ```yaml
  name: <team-name>-standards
  version: "1.0.0"
  description: "Team standards for <team-name>"
  dependencies:
    apm:
      - git: "https://github.com/praveenkumarsaravanan/devcrew.git"
        ref: <pinned-version>
  ```

**Generate `apm-policy.yml`:** A governance policy file defining what the team package provides and its override scope.

**Generate example instruction override:** Create an example `<team-name>-standards.instructions.md` that demonstrates how to override DevCrew defaults for the team's domain.

**Generate `README.md`:** Document what the package provides, how to consume it, and how to add new primitives.

### Step 5: Add Primitives to Existing Package

To add a new primitive to a team package:

1. Identify the primitive type (instruction, skill, prompt, agent).
2. Create the file at the correct path under `.apm/` following the conventions in `team-package-guide.md`.
3. For overrides: mirror the exact file path from DevCrew's `.apm/` directory.
4. For new primitives: create at a new path under `.apm/`.
5. Validate with `apm compile` (or `bash .apm/skills/apm-authoring/scripts/validate.sh`).

### Step 6: List Package Contents

Scan the team package's `.apm/` directory and report:

| Primitive type | Count | Overrides DevCrew? | Files |
|---------------|-------|-------------------|-------|
| Instructions | N | Yes/No | [file list] |
| Skills | N | Yes/No | [file list] |
| Prompts | N | Yes/No | [file list] |
| Agents | N | Yes/No | [file list] |

## Guardrails

- **Never modify Tier 1 from a team package context.** If the user wants to change DevCrew itself, redirect to `apm-authoring`.
- **Override by path, not by convention.** APM resolves overrides by matching the file path. The team package's file must be at the same relative path under `.apm/` to override a DevCrew primitive.
- **Start with monorepo.** Unless the user has a specific reason for a separate repo, recommend the monorepo approach.
- **Pin versions in separate repos.** When the team package depends on DevCrew, pin to an exact tag — never use branches or `latest`.
- **Keep team packages focused.** A team package should contain only standards, templates, and workflows specific to that team's domain. Universal improvements should go into Tier 1 instead.

## References

- [Team Package Guide](references/team-package-guide.md) — What belongs at each tier, override mechanics, and consumption patterns

## See Also

- **`/new-team-package`** — The user-facing entry point that invokes this skill.
- **`project-bootstrap`** — Consumes team packages when scaffolding new projects.
- **`apm-authoring`** — For creating/modifying Tier 1 (root DevCrew) primitives.
