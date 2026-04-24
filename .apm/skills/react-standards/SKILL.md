---
name: react-standards
description: >
  Coding standards, security baseline, and best practices for React frontend
  applications (TypeScript, Testing Library, CSS Modules/Tailwind). Activated
  by the coding-standards and security-baseline instructions when the project
  is classified as frontend or fullstack.
---

# React Standards

## Trigger

Activate this skill when:

- The `coding-standards` or `security-baseline` instruction routes you here for React-specific guidance
- The user asks about React coding conventions, component patterns, or frontend security
- You are reviewing or writing React/TypeScript code and need to verify it follows org standards
- `project-detection` classifies the project as frontend (React) or fullstack with a React frontend layer

## Coding Standards

### Naming Conventions

| Element              | Convention            | Example                                    |
|----------------------|-----------------------|--------------------------------------------|
| Components           | PascalCase            | `GuestCard`, `BookingModal`                |
| Hooks                | `use` prefix          | `useAuth`, `useBookingSearch`              |
| Context              | PascalCase + Context  | `AuthContext`, `ThemeContext`               |
| Event handlers       | `handle` prefix       | `handleSubmit`, `handleClick`              |
| Props interfaces     | PascalCase + Props    | `GuestCardProps`, `BookingModalProps`       |
| Utility functions    | camelCase             | `formatCurrency`, `parseQueryParams`        |
| Constants            | SCREAMING_SNAKE_CASE  | `MAX_FILE_SIZE`, `DEFAULT_PAGE_SIZE`        |
| Boolean variables    | Assertion prefix      | `isLoading`, `hasPermission`, `canSubmit`   |
| CSS modules          | camelCase             | `styles.headerContainer`                    |
| Test files           | `.test.tsx` suffix    | `GuestCard.test.tsx`                        |
| Story files          | `.stories.tsx` suffix | `GuestCard.stories.tsx`                     |

### Component Standards

- **Functional components only.** Do not use class components in new code.
- **TypeScript required.** All components, hooks, and utilities must be typed. Avoid `any` — use `unknown` with type narrowing when the type is genuinely unknown.
- **Single responsibility.** Each component handles one concern. If a component exceeds 200 lines, split it.
- **Props interface required.** Define a `Props` type for every component. Export it if consumers need it.
- **Destructure props** in the function signature for readability.
- **No inline styles** unless dynamically computed. Use CSS Modules, Tailwind, or styled-components (match project convention).
- **Use semantic HTML.** `<button>` not `<div onClick>`. `<nav>`, `<main>`, `<article>` not generic `<div>`.
- **Key prop on lists.** Use stable, unique identifiers — never array indices unless the list is static and never reordered.

### Hooks and State Management

- Keep state as close to where it's used as possible. Do not hoist state to a parent unless siblings need it.
- Use `useState` for simple local state, `useReducer` for complex state with multiple sub-values.
- Memoize expensive computations with `useMemo` and callback references with `useCallback` only when there is a measured performance need. Do not pre-optimize.
- Always include correct dependency arrays in `useEffect`, `useMemo`, and `useCallback`. ESLint `exhaustive-deps` rule must be enabled and not suppressed.
- Clean up side effects (subscriptions, timers, abort controllers) in `useEffect` return functions.
- Custom hooks must start with `use` and encapsulate a single reusable behavior.
- Do not call hooks conditionally or inside loops.

### Error Handling

- Use Error Boundaries (`ErrorBoundary`) to catch rendering errors and display fallback UI instead of crashing the app.
- Handle async errors in every `useEffect`, event handler, and data fetching hook. Unhandled promise rejections should never reach the console.
- Model async state explicitly: `loading`, `error`, `success`. Never leave the UI in an indeterminate state.
- Show user-friendly error messages. Never display raw stack traces, error codes, or API response bodies to users.
- Implement retry logic for transient network failures (React Query / SWR built-in retry, or manual retry with exponential backoff).
- Log client-side errors to a monitoring service (Sentry, Datadog RUM, or equivalent).

### Logging

- Use a centralized logging utility — do not scatter `console.log` across production code.
- Log user-impacting errors to an error tracking service (Sentry, Datadog RUM). Include route, component name, and user action context.
- Strip debug logging from production builds (use environment checks or build-time removal).
- Never log tokens, credentials, or PII on the client.
- Log performance metrics (Core Web Vitals, API latency) for monitoring.

### Testing

- Write **component tests** (Testing Library + Jest/Vitest) for all interactive components. Test user interactions (clicks, form submissions, keyboard events), not implementation details.
- Test **loading, error, and empty states** — not just the happy path render.
- Include **accessibility assertions**: `toBeVisible`, `toHaveAccessibleName`, `toHaveRole`. Run axe-core checks.
- Use `userEvent` over `fireEvent` for realistic user interaction simulation.
- Write **hook tests** (`renderHook`) for custom hooks with non-trivial logic.
- Use **MSW (Mock Service Worker)** for API mocking in tests — mock at the network level, not the module level.
- Avoid snapshot tests as a substitute for behavioral assertions. Use them only for stable, small UI fragments where visual regression matters.
- Minimum **80% code coverage** for business logic modules.

### Dependencies

- Prefer the standard library and platform APIs (`fetch`, `AbortController`, `Intl`, `URL`) over third-party packages when the platform API is adequate.
- Check bundle size impact before adding a dependency (`bundlephobia.com`). Flag additions over 50KB gzipped.
- Prefer ESM-compatible, tree-shakeable packages. Avoid CJS-only packages in modern bundler setups.
- Keep React, React DOM, and React Router on the same major version. Do not mix React 17 and 18 patterns.
- Pin dependency versions via `package-lock.json`. Never use floating ranges in production.

## Security Standards

### Secrets and Environment Variables

- Never embed API keys, tokens, or internal URLs in client-side JavaScript. Everything in the browser bundle is public.
- Only expose environment variables prefixed with `NEXT_PUBLIC_`, `VITE_`, or `REACT_APP_` (depending on framework). Unprefixed variables must stay server-side.
- If an API key must be used client-side (e.g., Google Maps), restrict it by HTTP referrer or domain in the provider's console.

### XSS Prevention

- **React default:** JSX auto-escapes interpolated values. This protects against most XSS. Do not bypass it.
- **Never use `dangerouslySetInnerHTML`** with user-supplied or untrusted content. If you must render HTML, sanitize it with DOMPurify first.
- **Never use `eval()`**, `new Function()`, or `document.write()` with dynamic content.
- **Validate `href` and `src` values** derived from user input. Block `javascript:` and `data:` URIs.
- **Avoid `innerHTML`** in vanilla JS helpers. Use `textContent` for text insertion.
- **Set `Content-Security-Policy` headers** to restrict script sources. At minimum: `script-src 'self'`. Avoid `'unsafe-inline'` and `'unsafe-eval'`.

### CSRF

- Include CSRF tokens in all state-changing requests (POST, PUT, DELETE, PATCH).
- Use the SameSite cookie attribute (`Strict` or `Lax`) to prevent cross-origin cookie transmission.
- For SPAs using token-based auth with cookies, verify the `Origin` or `Referer` header on the server.

### Authentication and Session Management

- Store tokens in HttpOnly, Secure, SameSite cookies. Never store tokens in `localStorage` or `sessionStorage` — they are accessible to any script on the page (XSS risk).
- Redirect to login on 401 responses. Do not cache expired tokens.
- Clear all auth state on logout — tokens, cached user data, and any in-memory session state.
- Implement idle session timeout on the client. Warn the user before auto-logout.

### Authorization

- Use route guards to hide unauthorized UI, but understand this is a UX convenience, not a security control. The backend must enforce access.
- Do not render UI for actions the user is not authorized to perform. Fetch permissions from the backend and conditionally render.
- Never include admin-only code paths in the public bundle. Use code splitting to load admin modules only for authorized users.

### Input Validation

- Validate form inputs on the client for user experience, but never rely on client validation for security — the server is the authority.
- Use controlled components for form state. Avoid uncontrolled inputs for anything submitted to the server.
- Sanitize user-generated content before rendering. Never use `dangerouslySetInnerHTML` with user input.
- Validate URLs from user input before use in `href`, `src`, or `window.open`. Block `javascript:` protocol URIs.

### Data Protection

- Do not store sensitive data (PII, payment info, health data) in browser storage (`localStorage`, `sessionStorage`, `IndexedDB`). Use in-memory state that clears on tab close.
- Clear sensitive data from component state when the user navigates away or the component unmounts.
- Do not include sensitive data in URL query parameters — they appear in browser history, server logs, and referrer headers.
- Mask sensitive fields in forms (password inputs use `type="password"`; credit card numbers show only last 4 digits).

### Dependency Security

- Run `npm audit` in CI on every build.
- Do not merge code that introduces dependencies with known critical or high CVEs.
- Use Subresource Integrity (SRI) attributes for any third-party scripts loaded from CDNs.
- Audit transitive dependencies — a safe direct dependency can pull in a vulnerable transitive one.

### Third-Party Integrations

- Validate `postMessage` origin when receiving cross-origin messages. Never trust messages without checking `event.origin`.
- Load third-party scripts asynchronously (`async` or `defer`) to prevent blocking the main thread.
- Use `rel="noopener noreferrer"` on all external links opened with `target="_blank"`.
- Audit third-party analytics and tracking scripts for data collection scope. Ensure they comply with the org's privacy policy.
- Isolate third-party widgets in sandboxed iframes when possible.

## Guardrails

- **Never use `dangerouslySetInnerHTML` with user input.** Sanitize with DOMPurify if HTML rendering is required.
- **Never store tokens in localStorage.** Use HttpOnly cookies.
- **Never use `any` in TypeScript.** Use `unknown` with type narrowing.
- **Never use class components.** Functional components with hooks only.
- **Never suppress `exhaustive-deps`.** Fix the dependency array instead.
- **Never skip accessibility.** Semantic HTML and ARIA attributes are mandatory.

## See Also

- **`java-standards`** — For backend-specific standards when working on fullstack projects.
- **`team-workflow`** — The `frontend-reviewer` agent uses these standards during Phase 4 code review.
- **`code-review`** — Standalone code reviews reference these standards for React-specific checks.
