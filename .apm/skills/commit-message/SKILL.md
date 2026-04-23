---
name: commit-message
description: >
  Construct git commit messages that pass the organization's server-side
  commitlint hook. Use when committing code, creating PRs, amending commits,
  or when a push is rejected for invalid commit message format.
---

# Commit Message

## Trigger

Activate this skill when:

- Creating a git commit
- A `git push` is rejected by the server-side `commitlint.sh` pre-receive hook
- The user asks how to format a commit message
- Amending or rewording a commit message

## Required Format

```
<type>(<scope>): <JIRA-ticket>, <description>
```

**Example:**

```
chore(engineering-agent-platform): PROJ-123, add setup script for gh CLI and APM
```

Every component is **required**. The server-side pre-receive hook rejects pushes that do not match this pattern.

## Components

### type

The category of change. Must be one of:

| Type | When to Use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `chore` | Maintenance, config, dependency updates |
| `docs` | Documentation only |
| `refactor` | Code restructuring with no behavior change |
| `test` | Adding or updating tests |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting, whitespace, linting (no logic change) |
| `revert` | Reverting a previous commit |

### scope

The project, package, or module affected. Use the repo name or a recognizable sub-component.

Examples: `engineering-agent-platform`, `api-gateway`, `auth-service`, `shared-ui-library`

### JIRA ticket

The Jira issue key linked to this change (e.g., `PROJ-123`, `ENG-456`).

If no ticket exists, check with the team whether `NOTICKET` is accepted. Some projects require a ticket for every commit.

### description

A short, lowercase summary of the change. Do not capitalize the first word. Do not end with a period.

- Good: `add setup script for gh CLI and APM`
- Bad: `Added setup script for GH CLI and APM.`

## Workflow

### 1. Analyze the Changes

Run `git diff --staged` (or `git diff` for unstaged changes) and `git status` to understand what was changed.

### 2. Determine the Type

Choose the `type` based on the nature of the change, not the files touched. A new file can be `fix` if it fixes a bug; a modified test file can be `feat` if it tests a new feature.

### 3. Determine the Scope

Use the repo name for cross-cutting changes. Use a sub-component name if the change is isolated to a specific module.

### 4. Find the JIRA Ticket

- Check the branch name — it often contains the ticket (e.g., `feat/PROJ-123-add-auth`).
- Check recent conversation or task context for a ticket reference.
- Ask the user if no ticket is apparent.

### 5. Write the Description

Summarize the **what**, not the **how**. Keep it under 72 characters. Use imperative mood (`add`, `fix`, `update` — not `added`, `fixed`, `updated`).

### 6. Construct the Message

Combine all components into the required format:

```
<type>(<scope>): <JIRA-ticket>, <description>
```

For non-trivial changes, add a body separated by a blank line:

```
feat(engineering-agent-platform): ENG-456, add commit message skill

Adds a skill that constructs commit messages matching the org's
server-side commitlint hook format. Triggered automatically when
committing or when a push is rejected.
```

### 7. Commit

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <JIRA-ticket>, <description>

Optional body explaining why the change was made.
EOF
)"
```

## Guardrails

- **Never skip the JIRA ticket.** The hook will reject the push. If unsure, ask the user.
- **Never capitalize the description.** The first word after the ticket must be lowercase.
- **Never end the description with a period.**
- **Always use the exact format.** Deviations like missing parentheses, missing colon, or swapped order will fail the hook.
- **Keep the subject line under 100 characters total.** Long lines may be truncated or rejected by some tools.
- **If a push is rejected**, read the error message, identify which rule failed, fix the commit message with `git commit --amend`, and retry the push.
