# `.project-context.md` — Canonical Format

This file lives at the **project root** and stores platform configuration, project identity, and team conventions. It is committed to version control and shared across the team.

## Frontmatter Fields

The file begins with a YAML-style frontmatter block delimited by `---`:

| Field | Type | Description |
|-------|------|-------------|
| `project-name` | string | Human-readable project name |
| `discipline` | enum | `backend` \| `frontend` \| `fullstack` \| `infrastructure` |
| `stack` | string | Freeform technology stack description |
| `tracker` | enum | `github-issues` \| `jira` \| `linear` \| `azure-devops` \| `none` |
| `tracker-project-key` | string | Jira project key (e.g., `PLAT`), or empty |
| `tracker-repo` | string | GitHub repo for issues (e.g., `org/repo`), or empty |
| `execution` | enum | `local` \| `background` \| `async` \| `manual` |
| `git-platform` | enum | `github` \| `ghe` \| `gitlab` \| `bitbucket` \| `azure-repos` |
| `migration-mode` | boolean | `true` during legacy migration, `false` for normal operation |
| `created` | ISO date | When this file was first created |
| `last-updated` | ISO date | When this file was last modified |

## Free-Form Sections

Below the frontmatter, include markdown sections for context that doesn't fit structured fields:

- **Architecture Overview** — High-level system description, major components, data flow.
- **Technology Decisions** — Key tech choices with rationale (why X over Y).
- **Team Conventions** — Branching strategy, PR review policy, naming conventions, coding standards.
- **Notes** — Anything else the team wants to persist across sessions.

## Example

```markdown
---
project-name: Order Platform
discipline: backend
stack: "Java 21, Spring Boot 3.3, PostgreSQL 16, Redis 7, Kafka 3.6"
tracker: jira
tracker-project-key: PLAT
tracker-repo: ""
execution: background
git-platform: ghe
migration-mode: false
created: 2025-11-10
last-updated: 2026-03-18
---

## Architecture Overview

Hexagonal architecture with domain-driven modules. Three bounded contexts:
Orders, Inventory, and Notifications. Async communication via Kafka between
contexts; synchronous REST APIs for external consumers.

## Technology Decisions

- **Spring Boot 3.3** over Quarkus — team expertise and existing library ecosystem.
- **PostgreSQL 16** — JSONB columns for flexible order metadata; row-level security for multi-tenancy.
- **Redis 7** — Session cache and rate-limiting. Cluster mode in production.

## Team Conventions

- Branch naming: `feat/PLAT-123-short-description`, `fix/PLAT-456-brief`
- PRs require 1 approval + passing CI before merge.
- Squash-merge to `main`; release branches for hotfixes.
- Commit messages follow Conventional Commits via commitlint.

## Notes

- Legacy v1 API still active; deprecation scheduled for Q3 2026.
- Shared internal library `platform-commons` is at v4.2.1 — do not upgrade until auth module is migrated.
```
