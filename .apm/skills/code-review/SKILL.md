---
name: code-review
description: >
  Systematic code review for backend and frontend services. Use when asked to
  review a PR, audit code quality, check for security vulnerabilities, or
  evaluate code changes. Covers Go, Python, TypeScript, Java, and frontend
  frameworks (React, Vue, Angular, Svelte).
---

# Code Review

## Trigger

Activate this skill when the user:

- Asks to review a pull request or merge request
- Requests a code audit or quality check
- Wants a security scan or vulnerability assessment of source code
- Asks to evaluate code changes before merging
- Mentions reviewing diffs, changesets, or patches

## Workflow

### 1. Gather Context

- Identify the PR or set of changed files. If given a PR URL, fetch the diff using `gh pr diff` or the platform's API.
- Read the PR description, linked issues, and any conversation threads for intent.
- Determine the languages and frameworks involved (Go, Python, TypeScript, Java, React, Vue, Angular, Svelte) to apply the correct checks.

### 2. Read All Changed Files

- Walk through every changed file in the diff. Do not skip files.
- For each file, load enough surrounding context (not just the diff lines) to understand the change in its module.
- Classify each file by discipline: backend (Go, Python, Java, server-side TypeScript), frontend (React/Vue/Angular/Svelte components, CSS, client-side TypeScript), or shared (utilities, types, configs). This determines which checks to apply.

### 3. Check Error Handling

- **Go**: Verify every returned `error` is checked. Look for silently ignored errors (`_ = someFunc()`). Ensure errors are wrapped with context (`fmt.Errorf("doing X: %w", err)`).
- **Python**: Confirm bare `except:` or `except Exception:` blocks are intentional. Verify exceptions carry meaningful messages.
- **TypeScript**: Check that async functions have proper try/catch or `.catch()`. Ensure error types are narrowed, not caught as `any`.
- **Java**: Verify checked exceptions are handled or explicitly declared. Look for empty catch blocks.

### 4. Check Security

**Backend:**
- Scan for hardcoded secrets, API keys, tokens, or passwords in source code or config files.
- Look for SQL injection vectors: raw string interpolation in queries instead of parameterized statements.
- Check for path traversal, command injection, and SSRF where user input reaches filesystem, shell, or HTTP calls.
- Verify authentication and authorization are enforced on new or changed endpoints.
- Confirm sensitive data (PII, credentials) is not logged.

**Frontend:**
- Flag `dangerouslySetInnerHTML`, `v-html`, or `[innerHTML]` with user-provided content (XSS vectors).
- Verify user-provided URLs are validated before use in `href`, `src`, or `window.open` (block `javascript:` protocol).
- Check that no API keys, tokens, or internal URLs are exposed in client-side bundles.
- Verify CSRF tokens are included in state-changing requests.
- Check that auth tokens use HttpOnly cookies, not `localStorage`.
- Verify `postMessage` listeners validate origin before processing messages.

### 5. Check Performance

**Backend:**
- Flag N+1 query patterns: loops that issue individual DB queries instead of batch operations.
- Look for unbounded loops or recursive calls without termination guarantees.
- Check for missing database indexes on columns used in WHERE, JOIN, or ORDER BY clauses.
- Identify unnecessary allocations, especially in hot paths (e.g., allocating inside tight loops in Go).
- Verify pagination on list/query endpoints to prevent unbounded result sets.

**Frontend:**
- Flag new dependencies > 50KB gzipped without justification (check bundlephobia.com).
- Look for full-library imports (`import _ from 'lodash'`) instead of selective imports.
- Check for unnecessary re-renders: unstable references in props, missing or incorrect dependency arrays, components that should be memoized.
- Flag missing code splitting on route boundaries.
- Verify expensive computations are memoized (`useMemo`, `computed`).
- Check that high-frequency event handlers (scroll, resize, input) are throttled or debounced.
- Flag CSS animations using layout-triggering properties (`top`, `left`, `width`, `height`) instead of `transform`/`opacity`.

### 6. Check Naming and Structure

- Verify names are descriptive and follow the project's conventions (camelCase, snake_case, PascalCase as appropriate).
- Flag single-letter variable names outside of short closures or loop counters.
- Check for single responsibility: functions should do one thing. Flag functions over ~60 lines or with deeply nested logic.
- Identify code duplication that should be extracted into shared utilities.

### 7. Check Accessibility (Frontend Files)

For frontend components and pages, verify:

- Semantic HTML is used (`<button>`, `<nav>`, `<main>`, `<form>`) instead of generic `<div>` with event handlers.
- Interactive elements are keyboard-accessible (focusable, operable, visible focus indicator).
- Images have meaningful `alt` text (or `alt=""` for decorative images).
- Form inputs have associated `<label>` elements.
- Color contrast meets WCAG 2.1 AA ratios (4.5:1 normal text, 3:1 large text).
- ARIA attributes are used correctly and only when native semantics are insufficient.
- Dynamic content changes are announced to screen readers (`aria-live`, `role="alert"`).
- Focus is managed on route changes and modal open/close.

### 8. Check Design System (Frontend Files)

- Design system tokens are used for colors, spacing, typography, and shadows — no hardcoded values.
- Shared components from the design system are used instead of one-off implementations.
- CSS scoping matches project convention (CSS Modules, Tailwind, styled-components, BEM).
- `!important` is not used; selector specificity is low and predictable.
- `z-index` values follow a defined scale.

### 9. Check Tests

- Confirm new logic has corresponding test coverage.
- Verify edge cases are tested: empty inputs, boundary values, error paths.
- Check that mocks and stubs are scoped correctly and don't mask real bugs.
- Look for flaky test patterns: time-dependent assertions, shared mutable state, network calls without mocking.
- **Frontend:** Verify component tests assert on user-visible behavior (not internal state), accessibility assertions are included, and loading/error/empty states are tested.

### 10. Provide Structured Feedback

Organize findings into categories with severity levels:

| Severity | Meaning |
|----------|---------|
| **Critical** | Must fix before merge — security vulnerability, data loss risk, accessibility violation, crash |
| **Warning** | Should fix — incorrect behavior, missing error handling, performance issue, no tests |
| **Suggestion** | Nice to have — naming, structure, minor refactors, alternative approaches |

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

## See Also

- **`pull-request`** — After addressing review findings, use this skill to create or update the PR with ticket validation and test plan checks.
- **`testing`** — If the review identifies missing test coverage, use this skill to write targeted tests without running the full team workflow.
- **`team-workflow`** — For structured development that includes review as Phase 4. The team workflow uses the same reviewer agents but adds adversarial prompting and re-routing.

## References

- [Review Checklist](references/review-checklist.md) — detailed per-category checklist for thorough backend reviews
- [Frontend Review Checklist](references/frontend-review-checklist.md) — accessibility, performance, security, UX, and CSS checklist for frontend reviews (shared with `team-workflow`)
