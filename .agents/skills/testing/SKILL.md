---
name: testing
description: >
  Write tests for existing or new code outside the full team-workflow. Scans
  codebase conventions, determines the right test types, writes the tests,
  and runs the suite. Use when asked to add tests, improve coverage, or
  write tests for a specific module.
---

# Testing

## Trigger

Activate this skill when:

- The user asks to write tests for a module, function, component, or endpoint
- The user asks to improve test coverage on existing code
- The user asks to add missing tests flagged in a code review
- The user says "write tests for this" or "add test coverage"
- A code review finding (from `code-review` or `team-workflow` Phase 4) calls for additional tests

Do NOT activate when the user wants the full structured workflow (requirements → architecture → implementation → review → testing). Use `team-workflow` for that.

## Workflow

### 1. Scan Codebase Conventions

Before writing any test code, discover how the project already tests:

- **Test framework:** Jest, Vitest, Node test runner, pytest, Go testing, JUnit, xUnit, Playwright, Cypress
- **File location:** `__tests__/`, `*.test.ts`, `*.spec.ts`, `test_*.py`, `*_test.go`, `src/test/java/`
- **Naming patterns:** match file names, describe/it blocks, Test function names
- **Import style:** relative vs. absolute, barrel imports, test utilities
- **Setup/teardown:** beforeEach, fixtures, Testcontainers, Docker Compose, factory patterns
- **Assertion library:** expect, assert, should, custom matchers
- **Mock framework:** Jest/Vitest mocks, unittest.mock, gomock, Mockito, WireMock, nock, MSW

Follow the project's conventions exactly. Your tests should look like they were written by the same team.

### 2. Analyze the Target Code

Read the code to be tested and identify:

- **Public interface:** What functions, methods, components, or endpoints are exposed?
- **Input space:** What are the valid inputs, boundary values, and invalid inputs?
- **Output expectations:** What does the code return, render, emit, or mutate?
- **Error paths:** What can go wrong? Which exceptions, error codes, or error states are possible?
- **Dependencies:** What does the code call? Which dependencies need mocking vs. real instances?
- **Side effects:** Does the code write to a database, publish events, send emails, or modify global state?

### 3. Design Test Cases

For each piece of target code, design tests in this order:

1. **Happy path** — The normal, expected usage that should succeed
2. **Edge cases** — Boundary values, empty inputs, maximum sizes, single items vs. many
3. **Error paths** — Invalid inputs, missing resources, network failures, permission denied
4. **Concurrency** (if applicable) — Simultaneous access, race conditions, idempotency

Use descriptive test names that state the scenario and expected outcome:

```
// Good
should return empty array when user has no orders
should throw NotFoundError when product ID does not exist
should debounce rapid clicks and submit form only once

// Bad
test1
testCreateUser
it works
```

### 4. Write the Tests

#### Backend Tests

**Unit tests:**
- Test each public function in isolation
- Mock external dependencies (databases, HTTP clients, message queues)
- Assert on return values, thrown exceptions, and side effects (mock call verification)

**Integration tests:**
- Test API endpoints or service methods with real dependencies (Testcontainers, in-memory databases)
- Assert on response status, body, headers, and database state after the call
- Clean up test state between tests (truncate tables, reset mocks)

**Contract tests:**
- Validate API response schemas against OpenAPI specs or shared type definitions
- Verify error response format matches the standard error envelope
- For external or cross-team contracts, add provider, consumer, and compatibility tests against OpenAPI, AsyncAPI, protobuf, GraphQL, webhook/event, or file/feed schemas.
- Verify additive changes are optional and old consumers can ignore them. Verify breaking changes have a new version or compatibility path.

**TypeScript/Node backend tests:**
- Test runtime schemas for HTTP body, params, query, env config, queue payloads, and external API responses.
- Test async error handling, structured error mapping, outbound timeouts, and retry decisions.
- Test worker and event-handler idempotency: duplicate delivery, retry exhaustion, poison messages, and dead-letter behavior.
- Test scheduled jobs for empty input, partial failure, checkpoint/resume, and overlap prevention.
- Use fake timers or injectable clocks instead of sleeps for timeout, retry, and schedule behavior.

#### Frontend Tests

**Component tests:**
- Render the component with Testing Library (or project equivalent)
- Simulate user interactions with user-event (clicks, typing, form submission)
- Assert on visible outcomes: text on screen, element visibility, ARIA attributes
- Test loading, error, and empty states — not just the happy path render
- Include accessibility assertions: `toHaveAccessibleName`, `toBeVisible`, axe-core checks

**Hook / utility tests:**
- Test custom hooks with renderHook (Testing Library)
- Test utility functions as pure unit tests

**E2E tests (when requested):**
- Use the project's E2E framework (Playwright, Cypress)
- Test complete user flows (login → navigate → perform action → verify result)
- Use page objects or equivalent abstractions if the project has them

#### Infrastructure And Image Checks

When the target is IaC or image-build work:

- Verify format/validate commands are available for the tool: Terraform/OpenTofu, CDK synth/diff, CloudFormation change set, Pulumi preview, Helm template, or Kubernetes dry run.
- Verify IaC security scanning is configured when available: Checkov, Trivy config, tfsec, Terrascan, cdk-nag, kube-score, or project equivalent.
- Verify plan/diff/change-set output is reviewed before apply/deploy.
- Verify image or AMI scanning is configured before promotion.
- Verify rollback/forward-fix evidence is present for production infrastructure changes.
- Do not run destructive apply/deploy commands from the testing skill.

#### Data Platform Tests

When the target is ingestion, mapping, replay, or feed operations:

- Add golden-file tests for representative source-to-target mappings.
- Cover happy path, missing required fields, unknown enums, invalid dates, duplicate records, historical schemas, and schema drift.
- Verify reject/quarantine reason codes and counts.
- Verify idempotency for duplicate files, events, records, and replay.
- Verify retry/DLQ behavior for retryable and non-retryable failures.
- Verify reconciliation and data quality report metrics.
- Use sanitized fixtures. Do not use raw production or sensitive payloads.

#### Contract And Regulated Data Tests

When the target changes interoperability contracts or sensitive data handling:

- Add contract diff or schema compatibility tests for OpenAPI, AsyncAPI, webhook/event schemas, protobuf, GraphQL, SDK types, or file/feed layouts.
- Verify provider outputs and consumer inputs match documented schemas, examples, auth/signing behavior, idempotency keys, retry semantics, and error formats.
- Cover duplicate webhook/event delivery, replay, historical versions, deprecated versions, invalid payloads, and consumer-safe optional additions where relevant.
- Use synthetic or approved de-identified fixtures. Never use raw production sensitive data.
- Test redaction/masking for logs, errors, traces, dashboards, reports, examples, and quality outputs.
- Test audit events for sensitive reads, exports, mutations, deletion, permission changes, replay/backfill, and bulk access.
- Test authorization for sensitive reads, exports, admin overrides, and operational tooling.

### 5. Build Test Utilities

When patterns repeat across test files:

- Create reusable **test factories** for domain objects (e.g., `createUser({ role: "admin" })`)
- Create reusable **request builders** for API calls (e.g., `apiClient.post("/users", overrides)`)
- Create shared **setup helpers** (e.g., `seedDatabase(fixtures)`, `startContainers()`)
- Create **custom matchers** for domain-specific assertions (e.g., `toBeValidOrder(order)`)

Do not duplicate setup code. If you find yourself copying the same block into a third test file, extract a helper.

### 6. Run and Verify

After writing all tests:

1. Run the full test suite (not just new tests — ensure nothing is broken)
2. Fix failures caused by your test code (incorrect assertions, setup issues, race conditions)
3. Flag failures caused by application bugs — report these to the user, do not fix them
4. Report results:

```
## Test Results

| Metric | Value |
|---|---|
| Tests written | X |
| Passed | X |
| Failed | X (Y test bugs fixed, Z app bugs flagged) |
| Files created | X |

### Application Bugs Found
| File | Issue | Details |
|---|---|---|
| path/to/file.ts | [description] | [how the test exposed it] |
```

## Test Quality Standards

Every test must:

- **Test behavior, not implementation** — Assert on observable outputs and side effects, not internal method calls or private state
- **Be independent** — No test depends on another test's execution or state
- **Have clear assertions** — `assertNotNull` is almost never sufficient; assert the actual expected value
- **Handle async correctly** — Use proper await/polling patterns, not arbitrary `sleep()` calls
- **Be deterministic** — No reliance on wall-clock time, external services, or execution order

## Anti-Patterns to Avoid

- **Testing implementation, not behavior** — Tests that break on refactor when behavior is unchanged
- **Test interdependence** — Tests that must run in a specific order or share mutable state
- **Assertion-free tests** — Execute code but never assert; pass even when broken
- **Hardcoded test data** — Literal values scattered across files instead of factories/builders
- **Testing mocks instead of behavior** — Mock setup so elaborate it becomes the test subject
- **Snapshot overuse** — Using snapshots as a substitute for behavioral assertions
- **Coverage theater** — High line coverage but tests don't assert meaningful outcomes

## Guardrails

- **Always scan conventions first.** Do not write tests in a different style than the existing test suite.
- **Always run the full suite after writing.** Your new tests must not break existing tests.
- **Flag application bugs, do not fix them.** Your job is to write tests, not change the application code. Report bugs to the user.
- **Do not over-mock.** Mock external boundaries (network, database, filesystem), not internal modules. If you need more than 3 mocks for a unit test, the code may need refactoring.
- **Include negative tests.** Every test suite must include at least one error-path test. Happy-path-only coverage is incomplete.

## See Also

- **`code-review`** — If a review flagged missing tests, this skill helps you write them. After writing tests, re-run the review to verify the gaps are closed.
- **`typescript-node-standards`** — For Node-specific tests covering runtime validation, async boundaries, outbound calls, workers, and scheduled jobs.
- **`infrastructure-as-code`** — For IaC validation, scan, plan evidence, and drift-detection expectations.
- **`image-build`** — For image/AMI scanning, artifact promotion, and baked-secret checks.
- **`data-mapping-validation`** — For golden-file mapping tests, schema drift cases, and data quality checks.
- **`data-ingestion`** — For idempotency, replay/backfill, retry/DLQ, and reconciliation tests.
- **`interoperability-contracts`** — For provider, consumer, compatibility, webhook/event, and file/feed contract tests.
- **`regulated-data-handling`** — For synthetic fixtures, redaction, audit, authorization, and retention tests.
- **`team-workflow`** — For structured development that includes testing as Phase 5. The team workflow uses the `qa-lead` agent to design the test strategy and the `test-engineer` agent to implement it.
- **`commit-message`** — After writing tests, use this skill to commit with the correct message format (e.g., `test(scope): TICKET, add unit tests for user service`).
