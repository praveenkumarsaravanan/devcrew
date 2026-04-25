---
description: Softer enforcement during legacy codebase migration — flags violations as warnings, prioritizes security over style
applyTo: "**/*.{ts,tsx,js,jsx,java,go,py,rs,sql,yml,yaml,json,html,css,scss}"
---

# Migration Standards

> **This instruction is active only when `migration-mode: true` is set in `.project-context.md`.** When migration is complete, the team sets `migration-mode: false` and this instruction deactivates — full `coding-standards` enforcement takes over.

## Core Principle

**New code must comply; existing code is grandfathered until touched.**

When a file is modified during migration:
- **New code** added to the file must follow `coding-standards` and `security-baseline`.
- **Existing code** in the same file does not need to be refactored unless it introduces a security vulnerability.
- **Touched functions** (functions where the logic is modified, not just imported) should be brought up to standard if the effort is proportional to the change.

## Severity Overrides During Migration

During migration, the standard severity levels are adjusted:

| Category | Normal enforcement | Migration enforcement |
|----------|-------------------|----------------------|
| Security violations (secrets, auth, injection) | **Critical** — block merge | **Critical** — block merge (unchanged) |
| Missing error handling in new code | **Critical** — block merge | **Warning** — flag in PR, recommend fix |
| Style/naming violations in new code | **Warning** — require fix | **Suggestion** — note in PR, fix if easy |
| Style/naming violations in existing code | **Warning** — require fix | **Ignored** — do not flag |
| Missing tests for new code | **Warning** — require fix | **Warning** — flag in PR, recommend fix |
| Missing tests for existing code | **Warning** — require fix | **Ignored** — tracked in migration plan |
| Documentation gaps in new code | **Suggestion** — nice to have | **Suggestion** — nice to have (unchanged) |

## What Never Gets Grandfathered

Regardless of migration phase, these must always be enforced:

- **No committed secrets** — API keys, tokens, passwords in source control
- **No SQL injection** — parameterized queries required
- **No XSS vulnerabilities** — output encoding required
- **No hardcoded credentials** — environment variables or secret managers only
- **No disabled security headers** — CORS, CSP, HSTS must be configured
- **Dependency vulnerabilities** — critical CVEs must be patched

## Migration Progress Tracking

The migration status is tracked in `.project-context.md`:

```yaml
migration-mode: true
migration-phase: M1  # M0 | M1 | M2 | M3
migration-started: 2026-04-25
```

As the team progresses through phases:
- **M0 (Wire In):** This instruction activates. Maximum leniency.
- **M1 (Safety Net):** Security enforcement tightens. Linting warnings appear.
- **M2 (Standards Adoption):** Style warnings become errors for new code. Test requirements enforced.
- **M3 (Steady State):** Set `migration-mode: false`. This instruction deactivates. Full `coding-standards` takes over.

## Phase-Specific Behavior

### During M0 — M1
- Report all findings but only block on security
- Suggest but don't require tests for new code
- Ignore all style violations in existing code

### During M2
- Block on security AND missing error handling in new code
- Require tests for new business logic
- Flag style violations in new code as warnings (not blockers)

### During M3 (transition)
- Enforce full `coding-standards` on all new code
- Flag existing code violations when files are touched
- This instruction should be deactivated after M3 is confirmed complete

## See Also

- **`coding-standards`** — The full enforcement instruction that takes over after migration.
- **`security-baseline`** — Security rules that are always enforced, even during migration.
- **`legacy-assessment`** — Produces the migration plan that determines the current phase.
- **`governance`** — Risk levels apply during migration; high-risk code is never grandfathered.
