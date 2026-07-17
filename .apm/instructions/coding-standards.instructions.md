---
name: coding-standards
description: Universal coding principles and discipline routing to java-standards, react-standards, or typescript-node-standards
applyTo: "**/*.{ts,tsx,js,jsx,java,sql,css,scss}"
---

# Coding Standards

These universal principles apply to all code regardless of language or framework.
For discipline-specific standards, activate the appropriate skill below.

## Discipline Routing

| Project type | Activate skill |
|--------------|----------------|
| Java backend | `java-standards` |
| TypeScript/Node backend | `typescript-node-standards` |
| React frontend | `react-standards` |
| Fullstack | Activate the applicable backend and frontend skills |
| Other (Go, Python, Angular, Vue, etc.) | No discipline-specific skill yet; apply the universal principles below |

Use `project-detection` when the discipline is unclear.

## Universal Principles

- **Readability over cleverness** — Code is read far more often than it is written. Optimize for the next person reading it.
- **Explicit over implicit** — Make behavior obvious. Avoid magic values, hidden side effects, and implicit type conversions.
- **Fail fast** — Detect invalid state as early as possible and surface errors immediately.
- **Consistency within a codebase** — Follow the established patterns in the project. When in doubt, match the surrounding code.

## Naming

- Names should convey intent. Prefer `remainingRetries` over `r` or `cnt`.
- Avoid abbreviations unless universally understood (`id`, `url`, `http` are fine; `usr`, `cfg`, `mgr` are not).
- Boolean variables use assertion prefixes: `isActive`, `hasPermission`, `canRetry`.
- Constants use SCREAMING_SNAKE_CASE: `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`.

## Git Workflow

- Use **conventional commits**: `type(scope): TICKET, description`.
- Pull requests require **at least one approving reviewer** before merge.
- Use **squash merge** to trunk to keep the commit history linear and readable.
- Branch names follow the pattern: `type/TICKET-short-description`.

## Testing (Universal)

- Minimum **80% code coverage** for business logic modules.
- Test names should describe the scenario and expected outcome: `should return 404 when user does not exist`.
- Use factories or builders for test data — avoid hardcoded object literals scattered across test files.
- Tests must be deterministic. No reliance on wall-clock time, external services, or execution order.

## Dependencies (Universal)

- Pin exact versions in lock files. Never use floating ranges in production.
- Audit dependencies monthly for known vulnerabilities.
- Remove unused dependencies. Dead dependencies increase attack surface and slow builds.
- Evaluate new dependencies against: maintenance activity, download volume, license compatibility, transitive dependency count.
