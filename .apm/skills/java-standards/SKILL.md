---
name: java-standards
description: >
  Coding standards, security baseline, and best practices for Java backend
  services (Spring Boot, JPA, Maven/Gradle). Activated by the coding-standards
  and security-baseline instructions when the project is classified as backend
  or fullstack.
---

# Java Standards

## Trigger

Activate this skill when:

- The `coding-standards` or `security-baseline` instruction routes you here for Java-specific guidance
- The user asks about Java coding conventions, Spring Boot patterns, or backend security
- You are reviewing or writing Java code and need to verify it follows org standards
- `project-detection` classifies the project as backend (Java) or fullstack with a Java backend layer

## Coding Standards

### Naming Conventions

| Element              | Convention           | Example                                    |
|----------------------|----------------------|--------------------------------------------|
| Packages             | lowercase dotted     | `com.example.booking.service`             |
| Classes              | PascalCase noun      | `ReservationService`, `GuestRepository`    |
| Interfaces           | PascalCase adjective or noun | `Searchable`, `GuestRepository`    |
| Methods              | camelCase verb       | `findByEmail`, `cancelReservation`         |
| Constants            | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`    |
| Database tables      | snake_case plural    | `user_profiles`, `order_items`             |
| Environment variables| SCREAMING_SNAKE_CASE | `DATABASE_URL`, `API_SECRET_KEY`           |
| Boolean variables    | Assertion prefix     | `isActive`, `hasPermission`, `canRetry`    |

- Name service methods after the business operation: `cancelReservation`, `checkIn`, `calculateLoyaltyPoints` — not `process`, `handle`, `execute`.

### Service Layer

- Use **constructor injection** for dependencies. Do not use field injection (`@Autowired` on fields).
- Keep controllers thin — business logic belongs in service classes, not in `@RestController` methods.
- Use `@Transactional` at the service layer, not the repository or controller layer.
- Validate input at the controller boundary using Bean Validation (`@Valid`, `@NotNull`, `@Size`). Do not scatter validation logic across service methods.
- Return DTOs from controllers, not JPA entities. Map entities to DTOs at the service boundary.
- Use `Optional` for methods that may not return a result. Never return `null` from a method that is expected to return a value — use `Optional.empty()`.

### Error Handling

- Always handle errors explicitly. Never ignore return values that indicate failure.
- Never swallow exceptions. If you catch an exception, log it, wrap it with context, or re-throw it. An empty catch block is never acceptable.
- Use specific exception types (`IllegalArgumentException`, `EntityNotFoundException`) over generic `RuntimeException`.
- Include the operation that failed and the input that caused the failure in error messages.
- Distinguish between retryable and non-retryable errors at the type level.
- Use structured error responses with error codes, human-readable messages, and contextual metadata.
- Catch exceptions at service boundaries (controllers, message handlers) — do not scatter try/catch across every method.

### Logging

- Use structured logging (JSON format) via SLF4J + Logback or Log4j2.
- Include a correlation ID (request ID / trace ID) in every log entry via MDC to enable request tracing across services.
- Log at appropriate levels:
  - **DEBUG** — Detailed diagnostic information. Disabled in production by default.
  - **INFO** — Significant business events: request received, order placed, job completed.
  - **WARN** — Unexpected but recoverable: retry triggered, fallback used, deprecated API called.
  - **ERROR** — Failures requiring attention: unhandled exceptions, failed external calls after retries, data integrity violations.
- Never log secrets, tokens, passwords, or unmasked PII.
- Include structured fields (not string concatenation) for queryable metadata: `userId`, `orderId`, `durationMs`.

### Testing

- Write **unit tests** (JUnit 5 + Mockito) for all public service methods. Test happy path, edge cases, and error paths.
- Write **integration tests** (`@SpringBootTest` + Testcontainers) for all API endpoints. Cover authentication, authorization, input validation, success responses, and error responses.
- Use `@Sql` or test fixtures for database state setup. Clean up between tests.
- Mock external services (HTTP clients, message queues) at the boundary, not deep in the call stack.
- Minimum **80% code coverage** for business logic modules.

### Dependencies

- Manage dependency versions via a BOM (Spring Boot BOM, or a custom platform BOM) to avoid version conflicts.
- Pin dependency versions in `pom.xml` or `gradle.lockfile`. Never use floating ranges.
- Use Dependabot or Renovate for automated dependency update PRs.
- Run `mvn dependency:analyze` or `gradle dependencies` to detect unused and undeclared dependencies.
- Prefer Spring ecosystem libraries for cross-cutting concerns (security, caching, messaging) over standalone alternatives.

## Security Standards

### Input Validation

- Validate all user input at API boundaries using Bean Validation (`@Valid`, `@NotNull`, `@Size`, `@Pattern`) before any processing occurs.
- Use allowlists over denylists. Define what is permitted rather than trying to enumerate what is forbidden.
- Sanitize input before database queries, template rendering, and shell execution.
- Enforce type, length, format, and range constraints on all inputs. Reject early with structured error responses.
- Never trust client-side validation alone. Always re-validate on the server.

### Authentication and Authorization

- Use short-lived access tokens. JWT expiry should be under 1 hour.
- Implement refresh token rotation — each refresh token is single-use.
- Hash passwords with bcrypt, scrypt, or Argon2 with appropriate work factors.
- Implement account lockout or exponential backoff after repeated failed login attempts.
- Check permissions at every endpoint. Default to deny.
- Validate resource ownership — users can only access their own resources unless explicitly authorized.
- Log all authorization failures for security monitoring.

### Data Protection

- Encrypt data at rest using AES-256 or equivalent.
- Encrypt data in transit using TLS 1.2+ for all connections, including internal service-to-service.
- Use parameterized queries (PreparedStatement, JPA named parameters) for all database operations. Never construct queries via string concatenation.
- Mask PII in logs, error messages, and monitoring dashboards.
- Implement data retention policies. Do not store data longer than necessary.

### Dependency Security

- Run OWASP Dependency-Check (`mvn org.owasp:dependency-check-maven:check` or `dependencyCheckAnalyze` Gradle task) in CI on every build.
- Do not merge code that introduces dependencies with known critical CVEs.
- Review new dependencies before adoption: maintenance status, known vulnerabilities, license, transitive dependencies.
- Subscribe to security advisories for Spring, Jackson, and other critical libraries.

### API Security

- Rate limit all endpoints. Stricter limits for authentication endpoints.
- Validate `Content-Type` headers on all requests that accept a body.
- Implement CORS properly: restrict allowed origins to known domains, no wildcard (`*`) in production.
- Return minimal error information to clients. No stack traces, SQL errors, or internal IPs.
- Use security headers: `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`, `Referrer-Policy`, `Permissions-Policy`.
- Implement request size limits to prevent DoS via oversized payloads.
- Include CSRF tokens in all state-changing requests. Use SameSite cookie attribute.

## Guardrails

- **Never use field injection.** Constructor injection is the only accepted pattern.
- **Never return JPA entities from controllers.** Always map to DTOs.
- **Never swallow exceptions.** An empty catch block is never acceptable.
- **Never construct SQL via string concatenation.** Use parameterized queries.
- **Never log secrets or PII.** Mask sensitive data in all log outputs.
- **Never skip input validation.** Bean Validation at the controller boundary is mandatory.

## See Also

- **`react-standards`** — For frontend-specific standards when working on fullstack projects.
- **`team-workflow`** — The `backend-reviewer` agent uses these standards during Phase 4 code review.
- **`code-review`** — Standalone code reviews reference these standards for Java-specific checks.
- **`api-design`** — REST/gRPC endpoint design guidance that complements the service layer standards here.
