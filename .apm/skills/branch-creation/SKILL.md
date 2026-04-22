---
name: branch-creation
description: >
  Create git branches following the organization's naming conventions.
  Use when starting work on a new feature, fix, or chore, or when the
  user asks to create a branch.
---

# Branch Creation

## Trigger

Activate this skill when:

- The user asks to create a new branch
- Starting work on a new feature, bug fix, or task
- The user provides a JIRA ticket and wants to begin implementation

## Required Format

```
<type>/<JIRA-ticket>-<short-description>
```

**Examples:**

```
feat/ENG-456-add-user-auth
fix/PROJ-789-null-pointer-on-checkout
chore/INFRA-101-upgrade-node-20
docs/ENG-500-api-migration-guide
refactor/PROJ-321-extract-payment-module
```

## Components

### type

Must match the commit type conventions (see `commit-message` skill for the full list). Common branch types:

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

### JIRA ticket

The Jira issue key (e.g., `ENG-456`, `PROJ-789`). This links the branch to the ticket for traceability.

### short-description

A brief, kebab-case summary of the work. Keep it under 5 words.

- Good: `add-user-auth`, `fix-cart-total`, `upgrade-node-20`
- Bad: `adding-the-new-user-authentication-feature-to-the-backend-service`

## Workflow

### 1. Identify the JIRA Ticket

- Ask the user for the ticket if not provided.
- If the Atlassian MCP is available, fetch the ticket details to confirm the summary matches the planned work.

### 2. Determine the Type

Choose based on the nature of the work described in the ticket:

- Is it a new capability? → `feat`
- Is it fixing a bug? → `fix`
- Is it cleanup, config, or dependencies? → `chore`

### 3. Construct the Branch Name

Combine components in the required format. Keep the description concise and lowercase.

### 4. Create the Branch

```bash
git checkout -b <type>/<JIRA-ticket>-<short-description>
```

If the branch should track a remote base branch:

```bash
git checkout -b <type>/<JIRA-ticket>-<short-description> origin/trunk
```

### 5. Confirm

Print the created branch name and confirm the user is on the correct base branch.

## Guardrails

- **Always include the JIRA ticket.** Branches without tickets break traceability and may be rejected by CI.
- **Use kebab-case for the description.** No underscores, camelCase, or spaces.
- **Keep it short.** Branch names over 60 characters cause issues with some tools.
- **Branch from the correct base.** Default to `trunk` unless the user specifies otherwise.
- **Check for existing branches.** Before creating, run `git branch -a | grep <ticket>` to avoid duplicates.
