---
name: code-review
description: >
  Systematic code review for backend services. Use when asked to review a PR,
  audit code quality, check for security vulnerabilities, or evaluate backend
  code changes. Covers Go, Python, TypeScript, and Java.
---

# Code Review

## Trigger

Activate this skill when the user:

- Asks to review a pull request or merge request
- Requests a code audit or quality check on backend code
- Wants a security scan or vulnerability assessment of source code
- Asks to evaluate code changes before merging
- Mentions reviewing diffs, changesets, or patches

## Workflow

### 1. Gather Context

- Identify the PR or set of changed files. If given a PR URL, fetch the diff using `gh pr diff` or the platform's API.
- Read the PR description, linked issues, and any conversation threads for intent.
- Determine the languages involved (Go, Python, TypeScript, Java) to apply language-specific checks.

### 2. Read All Changed Files

- Walk through every changed file in the diff. Do not skip files.
- For each file, load enough surrounding context (not just the diff lines) to understand the change in its module.

### 3. Check Error Handling

- **Go**: Verify every returned `error` is checked. Look for silently ignored errors (`_ = someFunc()`). Ensure errors are wrapped with context (`fmt.Errorf("doing X: %w", err)`).
- **Python**: Confirm bare `except:` or `except Exception:` blocks are intentional. Verify exceptions carry meaningful messages.
- **TypeScript**: Check that async functions have proper try/catch or `.catch()`. Ensure error types are narrowed, not caught as `any`.
- **Java**: Verify checked exceptions are handled or explicitly declared. Look for empty catch blocks.

### 4. Check Security

- Scan for hardcoded secrets, API keys, tokens, or passwords in source code or config files.
- Look for SQL injection vectors: raw string interpolation in queries instead of parameterized statements.
- Check for path traversal, command injection, and SSRF where user input reaches filesystem, shell, or HTTP calls.
- Verify authentication and authorization are enforced on new or changed endpoints.
- Confirm sensitive data (PII, credentials) is not logged.

### 5. Check Performance

- Flag N+1 query patterns: loops that issue individual DB queries instead of batch operations.
- Look for unbounded loops or recursive calls without termination guarantees.
- Check for missing database indexes on columns used in WHERE, JOIN, or ORDER BY clauses.
- Identify unnecessary allocations, especially in hot paths (e.g., allocating inside tight loops in Go).
- Verify pagination on list/query endpoints to prevent unbounded result sets.

### 6. Check Naming and Structure

- Verify names are descriptive and follow the project's conventions (camelCase, snake_case, PascalCase as appropriate).
- Flag single-letter variable names outside of short closures or loop counters.
- Check for single responsibility: functions should do one thing. Flag functions over ~60 lines or with deeply nested logic.
- Identify code duplication that should be extracted into shared utilities.

### 7. Check Tests

- Confirm new logic has corresponding test coverage.
- Verify edge cases are tested: empty inputs, boundary values, error paths.
- Check that mocks and stubs are scoped correctly and don't mask real bugs.
- Look for flaky test patterns: time-dependent assertions, shared mutable state, network calls without mocking.

### 8. Provide Structured Feedback

Organize findings into categories with severity levels:

| Severity | Meaning |
|----------|---------|
| **🔴 Critical** | Must fix before merge — security vulnerability, data loss risk, crash |
| **🟠 Major** | Should fix — incorrect behavior, missing error handling, no tests |
| **🟡 Minor** | Improve — naming, structure, minor performance, style |
| **🔵 Nit** | Optional — cosmetic, preference, non-blocking suggestion |

For each finding, include:
1. File and line reference
2. What the issue is
3. Why it matters
4. A concrete suggestion or code example to fix it

End with a summary: total findings by severity, overall assessment (approve, request changes, or comment), and a one-line verdict.

## Guardrails

- **Never approve without reviewing all changed files.** Partial reviews miss critical issues.
- **Always flag hardcoded secrets.** Any string that looks like a key, token, password, or connection string in source code is a critical finding.
- **Require tests for new logic.** If a PR introduces new business logic, branching, or error handling without corresponding tests, mark it as a major finding.
- **Do not rewrite the author's code.** Provide suggestions, not replacements. Respect the author's style where it doesn't violate conventions.
- **Stay objective.** Base feedback on concrete principles (correctness, security, performance), not personal preference.
- **Check the review checklist.** Before finalizing, verify all categories in the checklist have been covered.

## References

- [Review Checklist](references/review-checklist.md) — detailed per-category checklist for thorough reviews
