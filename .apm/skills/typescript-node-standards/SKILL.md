---
name: typescript-node-standards
description: >
  Coding standards, security baseline, and best practices for TypeScript/Node.js
  backend services, API routes, workers, scheduled jobs, and queue consumers.
  Activated by coding-standards, security-baseline, and Engineering Flow when
  the backend layer is Node.js.
---

# TypeScript Node Standards

## Trigger

Activate this skill when:

- The `coding-standards`, `security-baseline`, or `typescript-node-baseline` instruction routes you here for server-side TypeScript/Node guidance.
- You are writing or reviewing Node.js backend code, API routes, workers, scheduled jobs, CLIs, or queue consumers.
- `project-detection` classifies the project as backend Node.js or fullstack with a Node.js backend layer.
- Engineering Flow needs stack-specific implementation, review, or test guidance for Express, Fastify, NestJS, Next.js API routes, Remix loaders/actions, or similar server runtimes.

Do not activate this skill for browser-only React components. Use `react-standards` for client-side TypeScript.

## Coding Standards

### TypeScript Configuration

- Use Node 20+ LTS unless the project already pins another supported LTS version.
- Enable `strict: true` in `tsconfig.json`. Prefer also enabling `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, and `noImplicitOverride` for new projects.
- Avoid `any`. Use `unknown` at untrusted boundaries and narrow with runtime validation.
- Keep module format consistent across `package.json`, `tsconfig.json`, and runtime (`type: module`, `module`, `moduleResolution`).
- Do not bypass compiler safety with broad type assertions. A cast must be local, justified, and followed by validation or a safer wrapper.
- Prefer explicit return types for exported functions, handlers, adapters, repositories, and public service methods.

### Project Structure

- Separate transport, application, domain, and infrastructure concerns:
  - `routes/` or `controllers/` parse transport inputs and call services.
  - `services/` contain business operations.
  - `repositories/` or `clients/` isolate persistence and external systems.
  - `schemas/` or `validators/` define runtime validation.
  - `config/` owns environment parsing.
- Keep framework objects out of domain logic. Do not pass `Request`, `Response`, or queue message envelopes into business services.
- Export app factories for tests, e.g. `createApp(config)` or `buildServer(config)`, instead of starting listeners during import.
- Keep side effects out of module top level except safe configuration constants.

### Runtime Validation

- Validate all untrusted inputs at the boundary before business logic runs:
  - HTTP body, params, query, headers, cookies, and files.
  - Environment variables.
  - Queue/event payloads.
  - Webhook payloads and signatures.
  - External API responses before trusting their shape.
- Use a runtime schema library such as Zod, Valibot, io-ts, TypeBox, or the project's established equivalent.
- Derive static types from runtime schemas when possible so compile-time and runtime contracts cannot drift.
- Return structured validation errors with safe field names and messages. Never expose stack traces, raw parser errors, or sensitive values.
- Treat generated or shared OpenAPI/GraphQL/protobuf types as compile-time contracts only unless the runtime also validates payloads.

### Typed Environment Config

- Read `process.env` in one config module only. Other modules receive typed config through dependency injection or import the typed config object.
- Validate environment variables at startup and fail fast if required values are missing or malformed.
- Keep `.env.example` in sync with required variables, defaults, and safe descriptions.
- Model secrets as opaque strings and never log their values.
- Do not use production fallbacks for required secrets, credentials, hostnames, or auth settings.

### Error Handling

- Always handle async errors at transport and worker boundaries. Use framework-supported async handlers or wrappers that forward rejected promises.
- Do not leave floating promises. Await them, return them, or intentionally detach them through a named helper that logs and tracks failure.
- Represent domain errors with specific types or discriminated unions, not generic `Error` strings.
- Map errors to structured responses or retry decisions at boundaries:
  - Validation errors -> 400.
  - Authentication failures -> 401.
  - Authorization failures -> 403.
  - Missing resources -> 404.
  - Conflict/idempotency violations -> 409.
  - Downstream failures -> 502/503 with safe messages.
- Include operation context in internal errors, but redact secrets and PII.
- Use `AbortController`, framework timeout settings, or client timeout options for outbound calls. No outbound network request may wait forever.

### API and Service Security

- Enforce authentication and authorization on every protected route. Default to deny.
- Validate resource ownership before returning or mutating user-owned data.
- Use parameterized queries or ORM query builders. Never interpolate user input into SQL, shell commands, or filesystem paths.
- Configure request body size limits, CORS allowlists, security headers, and rate limits for sensitive routes.
- Verify webhook signatures before parsing or processing webhook payloads.
- Do not return internal identifiers, stack traces, SQL errors, or provider secrets in client-facing errors.

### Logging and Observability

- Use structured logging (`pino`, `winston`, OpenTelemetry-compatible logging, or project equivalent).
- Include correlation fields such as `requestId`, `traceId`, `userId` when safe, `operation`, and `durationMs`.
- Configure logger redaction for tokens, passwords, cookies, authorization headers, API keys, SSNs, payment data, and sensitive payload fields.
- Log business events at `info`, recoverable surprises at `warn`, and actionable failures at `error`.
- Do not log entire request bodies, headers, cookies, queue payloads, or third-party responses by default.
- Emit metrics for request latency, error rate, queue depth, handler duration, retry count, and dead-letter volume where the runtime supports it.

### Outbound Calls

- Set explicit timeouts on HTTP, database, cache, queue, and SDK clients.
- Add retry with exponential backoff only for retry-safe transient failures. Never retry non-idempotent operations without an idempotency key.
- Validate and allowlist user-controlled URLs before outbound calls to prevent SSRF.
- Propagate correlation IDs to downstream services when supported.
- Centralize client construction so timeout, retry, auth, and logging policies are consistent.

### Workers, Events, and Scheduled Jobs

- Make handlers idempotent. Use event IDs, idempotency keys, natural unique constraints, or processed-event records.
- Define retry behavior, max attempts, backoff, poison message handling, and dead-letter routing before shipping a consumer.
- Persist checkpoints or cursor state for batch jobs that process more than one item.
- Treat queue payloads as untrusted input and validate them with runtime schemas.
- Distinguish retryable from non-retryable failures in code. Validation failures should not loop forever.
- Ensure scheduled jobs cannot overlap unsafely. Use locks, leases, or idempotent processing when concurrent runs are possible.

### Testing

- Follow the project's existing test framework first. Common options are Vitest, Jest, Node's built-in test runner, Supertest, Pact, MSW, nock, and Testcontainers.
- Unit-test service logic with external systems mocked at the boundary.
- Integration-test API routes with the real app factory and realistic database/cache/message dependencies when feasible.
- Test runtime validation for body, params, query, env config, queue payloads, and external API response handling.
- Test async error paths, timeout behavior, retry decisions, and non-retryable failures.
- For workers and event handlers, test idempotency, duplicate delivery, retry exhaustion, and dead-letter behavior.
- For scheduled jobs, test empty input, partial failure, checkpoint/resume behavior, and overlap prevention.
- Avoid tests that depend on wall-clock time. Use fake timers or injectable clocks.

### Dependencies

- Prefer established, maintained packages that fit the existing stack. Avoid adding frameworks when a small adapter or platform API is enough.
- Pin versions in lock files and run the native audit command (`npm audit`, `pnpm audit`, or `yarn npm audit`) in CI.
- Do not introduce a dependency with known critical or high CVEs.
- Review transitive dependency size and maintenance health before adding runtime dependencies.

## Guardrails

- **Never trust TypeScript alone at runtime.** Validate untrusted inputs at the boundary.
- **Never read raw `process.env` throughout the codebase.** Use one typed config module.
- **Never log secrets, tokens, cookies, authorization headers, or raw PII.**
- **Never make outbound calls without explicit timeout behavior.**
- **Never write a queue consumer or scheduled job without an idempotency strategy.**
- **Never leave rejected promises unhandled.**
- **Never interpolate user input into SQL, shell commands, filesystem paths, or outbound URLs.**

## See Also

- **`react-standards`** - For browser/client TypeScript and UI work.
- **`api-design`** - REST/gRPC endpoint design guidance that complements Node service implementation.
- **`code-review`** - Standalone reviews route Node backend changes to these checks.
- **`team-workflow`** - DevCrew Engineering Flow uses these standards during implementation, review, and testing.
