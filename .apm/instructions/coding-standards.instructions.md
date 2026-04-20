---
description: Organization-wide coding standards for backend services
applyTo: "**/*.{ts,js,py,go,java,rs}"
---

# Coding Standards

## General Principles

- **Readability over cleverness** — Code is read far more often than it is written. Optimize for the next person reading it, not for the fewest keystrokes.
- **Explicit over implicit** — Make behavior obvious. Avoid magic values, hidden side effects, and implicit type conversions.
- **Fail fast** — Detect invalid state as early as possible and surface errors immediately. Do not let bad data propagate through the system silently.

## Naming Conventions

| Element              | Convention          | Example                  |
|----------------------|---------------------|--------------------------|
| Variables, functions | camelCase           | `getUserById`, `retryCount` |
| Types, classes       | PascalCase          | `UserProfile`, `OrderService` |
| Constants            | SCREAMING_SNAKE_CASE| `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS` |
| Database tables      | snake_case          | `user_profiles`, `order_items` |
| Environment variables| SCREAMING_SNAKE_CASE| `DATABASE_URL`, `API_SECRET_KEY` |

- Names should convey intent. Prefer `remainingRetries` over `r` or `cnt`.
- Avoid abbreviations unless universally understood (`id`, `url`, `http` are fine; `usr`, `cfg`, `mgr` are not).
- Boolean variables should read as assertions: `isActive`, `hasPermission`, `canRetry`.

## Error Handling

- Always handle errors explicitly. Never ignore return values that indicate failure.
- Never swallow exceptions. If you catch an exception, log it, wrap it with context, or re-throw it. An empty catch block is never acceptable.
- Use structured error types with error codes, human-readable messages, and contextual metadata.
- Include the operation that failed and the input that caused the failure in error messages.
- Distinguish between retryable and non-retryable errors at the type level.

## Logging

- Use structured logging (JSON format) in all services.
- Include a correlation ID (request ID / trace ID) in every log entry to enable request tracing across services.
- Log at appropriate levels:
  - **DEBUG** — Detailed diagnostic information useful during development. Disabled in production by default.
  - **INFO** — Significant business events: request received, order placed, job completed.
  - **WARN** — Unexpected but recoverable situations: retry triggered, fallback used, deprecated API called.
  - **ERROR** — Failures that require attention: unhandled exceptions, failed external calls after retries exhausted, data integrity violations.
- Never log secrets, tokens, passwords, or unmasked PII.
- Include structured fields (not string interpolation) for queryable metadata: `userId`, `orderId`, `durationMs`.

## Testing

- Minimum **80% code coverage** for business logic modules.
- Write **unit tests** for all public functions. Test the happy path, edge cases, and error paths.
- Write **integration tests** for all API endpoints. Cover authentication, authorization, input validation, success responses, and error responses.
- Test names should describe the scenario and expected outcome: `should return 404 when user does not exist`.
- Use factories or builders for test data — avoid hardcoded object literals scattered across test files.
- Tests must be deterministic. No reliance on wall-clock time, external services, or execution order.

## Git Workflow

- Use **conventional commits**: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`.
- Commit messages must include a concise subject line and, for non-trivial changes, a body explaining *why* the change was made.
- Pull requests require **at least one approving reviewer** before merge.
- Use **squash merge** to main to keep the commit history linear and readable.
- Branch names follow the pattern: `feat/short-description`, `fix/short-description`, `chore/short-description`.

## Dependencies

- Pin exact versions in lock files (`package-lock.json`, `poetry.lock`, `go.sum`). Never use floating ranges in production.
- Audit dependencies monthly for known vulnerabilities.
- Remove unused dependencies. Dead dependencies increase attack surface and slow builds.
- Evaluate new dependencies against these criteria: maintenance activity, download volume, license compatibility, transitive dependency count.
- Prefer standard library solutions over third-party packages when the standard library is adequate.
