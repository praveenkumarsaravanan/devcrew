# Code Review Checklist

Use this checklist to ensure thorough coverage during backend code reviews. Each section lists specific items to verify.

---

## Error Handling

- [ ] All errors are checked and handled — no silently ignored return values
- [ ] Errors include context about what operation failed (wrap with message)
- [ ] Error messages do not leak sensitive information (stack traces, internal paths, credentials)
- [ ] Retry logic has backoff and a maximum retry count
- [ ] Partial failure scenarios are handled (e.g., batch operations where some items succeed)
- [ ] Panics / unhandled exceptions are caught at service boundaries
- [ ] Timeouts are set on all external calls (HTTP, DB, gRPC)
- [ ] Circuit breakers or fallbacks exist for critical dependencies

### Language-Specific

**Go**
- [ ] Every `error` return is checked
- [ ] Errors are wrapped with `fmt.Errorf("context: %w", err)` for stack context
- [ ] `defer` is used for cleanup, and deferred functions handle their own errors
- [ ] No use of `panic` outside of program initialization

**Python**
- [ ] No bare `except:` clauses — exceptions are specific
- [ ] Context managers (`with`) are used for resource cleanup
- [ ] `finally` blocks release resources even on exception
- [ ] Custom exceptions inherit from appropriate base classes

**TypeScript**
- [ ] Async functions have try/catch or callers handle rejections
- [ ] Error types are narrowed — no `catch (e: any)` without re-throwing
- [ ] Promise chains have `.catch()` handlers
- [ ] Unhandled promise rejections are impossible in the call chain

**Java**
- [ ] Checked exceptions are handled or declared
- [ ] No empty catch blocks
- [ ] Resources use try-with-resources
- [ ] Custom exceptions include original cause (`new XException("msg", cause)`)

---

## Security

### Injection

- [ ] SQL queries use parameterized statements or an ORM — no string concatenation
- [ ] NoSQL queries use driver-provided query builders — no raw JSON construction
- [ ] Shell commands use argument arrays, not interpolated strings
- [ ] LDAP, XPath, and other query languages use safe construction methods
- [ ] User input in log statements is sanitized to prevent log injection

### Authentication & Authorization

- [ ] New endpoints enforce authentication middleware
- [ ] Authorization checks verify the caller has permission for the specific resource
- [ ] Role/permission checks cannot be bypassed by manipulating request parameters
- [ ] JWT tokens are validated (signature, expiry, issuer, audience)
- [ ] API keys are compared using constant-time comparison

### Secrets Management

- [ ] No hardcoded secrets, API keys, tokens, or passwords in source code
- [ ] No secrets in configuration files committed to version control
- [ ] Secrets are loaded from environment variables or a secrets manager
- [ ] Default values in config do not contain real credentials
- [ ] `.env` files are in `.gitignore`

### Data Protection

- [ ] PII is not written to application logs
- [ ] Sensitive fields are masked or excluded from serialization
- [ ] Data at rest is encrypted where required by policy
- [ ] TLS is enforced for all external communication
- [ ] CORS policies are restrictive and explicitly configured

---

## Performance

### Database

- [ ] No N+1 query patterns — use JOINs, batch queries, or DataLoader
- [ ] Queries against large tables use indexes (check WHERE, JOIN, ORDER BY columns)
- [ ] New columns on large tables have defaults or are nullable to avoid table rewrites
- [ ] Transactions are as short as possible — no external calls inside transactions
- [ ] Connection pool size is appropriate for expected concurrency
- [ ] Query results are paginated — no unbounded SELECT without LIMIT

### Compute

- [ ] No unbounded loops — all loops have a termination condition or maximum iteration count
- [ ] Hot paths avoid unnecessary allocations (object creation, string concatenation)
- [ ] Expensive computations are cached where appropriate (with cache invalidation)
- [ ] Regular expressions are compiled once and reused, not compiled per-request
- [ ] Large payloads are streamed rather than buffered entirely in memory

### Concurrency

- [ ] Shared mutable state is protected by mutexes, channels, or atomic operations
- [ ] Goroutines / threads have lifecycle management — no leaks
- [ ] Context cancellation is propagated to child operations
- [ ] Rate limiting is in place for user-facing and inter-service calls

---

## Code Structure

### Single Responsibility

- [ ] Each function does one thing
- [ ] Functions are under ~60 lines; longer functions are broken into helpers
- [ ] Classes/structs have a clear, single purpose
- [ ] Packages/modules have a cohesive scope (not a "utils" grab-bag)

### Naming

- [ ] Names are descriptive: `getUserByEmail` not `getU` or `fetch`
- [ ] Boolean names read as questions: `isActive`, `hasPermission`, `canRetry`
- [ ] Abbreviations are avoided unless universally understood (ID, URL, HTTP)
- [ ] Consistent naming conventions within the project (camelCase, snake_case, etc.)

### Duplication

- [ ] Similar logic in multiple places is extracted into a shared function
- [ ] Configuration values are defined in one place, not scattered across files
- [ ] Magic numbers and strings are replaced with named constants

### Dependencies

- [ ] New dependencies are justified — not added for trivial functionality
- [ ] Dependency versions are pinned
- [ ] No known CVEs in new dependencies (check with `npm audit`, `pip audit`, `govulncheck`, etc.)

---

## Testing

### Coverage

- [ ] New business logic has unit tests
- [ ] Error paths and edge cases are tested (empty input, nil, zero values, boundary values)
- [ ] Integration tests exist for new API endpoints or database operations
- [ ] Regression tests are added for any bug fixes

### Quality

- [ ] Tests assert behavior, not implementation details
- [ ] Test names describe the scenario: `TestCreateUser_DuplicateEmail_ReturnsConflict`
- [ ] Setup and teardown are isolated — tests do not depend on execution order
- [ ] No shared mutable state between tests

### Mocking

- [ ] Mocks are scoped to the test — not global
- [ ] Only external dependencies are mocked, not internal logic
- [ ] Mock expectations are verified (expected calls were actually made)
- [ ] Mocking does not mask the behavior under test

### Flakiness

- [ ] No time-dependent assertions (`time.Sleep` followed by state check)
- [ ] No reliance on external services in unit tests
- [ ] Randomized test data uses deterministic seeds for reproducibility
- [ ] File system and network operations in tests use temp dirs and test servers

---

## API Design

### Request/Response

- [ ] Request bodies are validated — required fields, types, ranges
- [ ] Response schemas are consistent across endpoints
- [ ] Error responses follow a standard format (code, message, details)
- [ ] Large collections use pagination (cursor-based preferred)

### HTTP Semantics

- [ ] GET is safe and idempotent — no side effects
- [ ] POST is used for creation, not for retrieval
- [ ] PUT replaces the full resource; PATCH applies partial updates
- [ ] DELETE returns 204 on success, 404 if not found
- [ ] Status codes match the outcome (201 for creation, 409 for conflict, etc.)

### Versioning & Compatibility

- [ ] Breaking changes are behind a new API version
- [ ] Deprecated fields are documented and have a removal timeline
- [ ] New optional fields do not break existing clients
- [ ] Content-Type and Accept headers are validated
