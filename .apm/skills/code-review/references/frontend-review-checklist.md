# Frontend Review Checklist

Use this checklist to ensure thorough coverage during frontend code reviews. Each section lists specific items to verify.

---

## Accessibility (WCAG 2.1 AA)

### Semantic Structure

- [ ] Heading hierarchy is logical (`h1` → `h2` → `h3`, no skipped levels)
- [ ] Landmark regions are used (`<main>`, `<nav>`, `<aside>`, `<header>`, `<footer>`)
- [ ] Lists use `<ul>`, `<ol>`, or `<dl>` — not styled `<div>` elements
- [ ] Tables use `<th>`, `scope`, and `<caption>` for data tables; layout tables are avoided
- [ ] Page has a descriptive `<title>` that updates on route changes

### Interactive Elements

- [ ] All interactive elements are focusable and operable via keyboard
- [ ] Custom widgets implement the correct ARIA role, states, and keyboard pattern (see WAI-ARIA Authoring Practices)
- [ ] Focus order follows visual layout (no unexpected jumps via `tabindex` > 0)
- [ ] Focus is visible on all interactive elements (no `outline: none` without replacement)
- [ ] Focus is managed programmatically on route changes and modal open/close
- [ ] Buttons use `<button>`, not `<div onClick>`; links use `<a href>`
- [ ] Toggle controls communicate state (`aria-pressed`, `aria-expanded`, `aria-checked`)

### Text and Labels

- [ ] Images have `alt` text (meaningful for informative images, empty `alt=""` for decorative)
- [ ] Form inputs have associated `<label>` elements (via `for`/`id` or wrapping)
- [ ] Error messages are associated with inputs (`aria-describedby`, `aria-invalid="true"`)
- [ ] Icon-only buttons and links have accessible names (`aria-label` or visually-hidden text)
- [ ] Placeholder text is not the only label for an input

### Color and Contrast

- [ ] Text meets 4.5:1 contrast ratio (3:1 for large text ≥ 18pt or bold ≥ 14pt)
- [ ] Non-text UI components meet 3:1 contrast ratio (borders, icons, focus indicators)
- [ ] Information is not conveyed by color alone (use icons, patterns, or text alongside color)
- [ ] Focus indicators meet 3:1 contrast against adjacent colors

### Dynamic Content

- [ ] Live regions announce dynamic updates (`aria-live="polite"` or `aria-live="assertive"`)
- [ ] Toast notifications and alerts use `role="alert"` or `role="status"`
- [ ] Loading states are announced to screen readers
- [ ] Route changes announce the new page title or heading to screen readers

---

## Performance

### Bundle Size

- [ ] New dependencies are justified — check bundlephobia.com for gzipped size
- [ ] Dependencies > 50KB gzipped have no lighter alternative
- [ ] Imports are selective (`import { debounce } from 'lodash-es'`, not `import _ from 'lodash'`)
- [ ] CJS-only packages are flagged (prevent tree-shaking in modern bundlers)
- [ ] Unused dependencies are removed from `package.json`

### Loading Strategy

- [ ] Routes use code splitting (`React.lazy`, dynamic `import()`, framework-specific equivalent)
- [ ] Heavy components not visible on initial render are lazy-loaded
- [ ] Images use `loading="lazy"` for below-fold content
- [ ] Critical CSS is inlined or loaded first; non-critical CSS is deferred
- [ ] Fonts use `font-display: swap` or `optional` to prevent invisible text during load
- [ ] Preload hints (`<link rel="preload">`) are used for critical resources

### Render Performance

- [ ] Components avoid unnecessary re-renders (stable props, memoization where measured)
- [ ] Lists with > 50 items use virtualization (react-window, @tanstack/virtual)
- [ ] Expensive computations in render are memoized (`useMemo`, `computed`)
- [ ] Event handlers for high-frequency events (scroll, resize, input) are throttled or debounced
- [ ] DOM reads and writes are not interleaved (batch reads then writes to avoid layout thrashing)
- [ ] CSS animations use `transform` and `opacity`, not layout-triggering properties

### Network

- [ ] API responses are cached and deduplicated (SWR, React Query, Apollo, or equivalent)
- [ ] Requests are not duplicated on re-render or re-mount
- [ ] Pagination or infinite scroll is used for large data sets
- [ ] Assets use cache-busting filenames (content hash) for long-lived CDN caching
- [ ] API calls are parallelized when independent (`Promise.all`, concurrent queries)

---

## Security

### Cross-Site Scripting (XSS)

- [ ] User input is never rendered via `dangerouslySetInnerHTML`, `v-html`, or `[innerHTML]`
- [ ] If raw HTML rendering is unavoidable, input is sanitized with DOMPurify or equivalent
- [ ] URL parameters are validated before use in `href`, `src`, or redirects
- [ ] `javascript:` protocol is blocked in user-provided URLs
- [ ] Template literals in JSX/templates do not include unsanitized user input

### Client-Side Secrets

- [ ] No API keys, tokens, or internal URLs in client-side source code
- [ ] Environment variables use the framework's public prefix (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`)
- [ ] `.env` files with sensitive values are in `.gitignore`
- [ ] Source maps in production do not expose internal logic (disabled or access-restricted)

### Authentication and Authorization

- [ ] Auth tokens are stored in HttpOnly cookies, not `localStorage` or `sessionStorage`
- [ ] CSRF tokens are included in state-changing requests (forms, mutations)
- [ ] Token expiry is handled gracefully (refresh flow, redirect to login)
- [ ] Client-side route guards are backed by server-side authorization (UI hiding is not access control)
- [ ] Sensitive routes check authentication before rendering content (no flash of protected data)

### Third-Party Code

- [ ] Third-party scripts use Subresource Integrity (`integrity` attribute)
- [ ] `postMessage` listeners validate the origin before processing
- [ ] Third-party iframes use `sandbox` attribute with minimal permissions
- [ ] Cookie consent is implemented where required by regulation

---

## UX Consistency

### Design System

- [ ] Colors use design system tokens — no hardcoded hex values or `rgb()`
- [ ] Spacing follows the design grid (4px/8px scale or project-defined scale)
- [ ] Typography uses design system font sizes, weights, and line heights
- [ ] Shadows, border radii, and transitions use design tokens
- [ ] Shared components from the design system are used instead of one-off implementations
- [ ] Icons are from the project's icon library, not ad-hoc SVGs

### Responsive Design

- [ ] Layout works at mobile (320px), tablet (768px), and desktop (1280px+) widths
- [ ] Touch targets are at least 44x44 CSS pixels on mobile
- [ ] Text is readable without horizontal scrolling at any viewport width
- [ ] Images scale appropriately (responsive `srcset` or CSS `max-width: 100%`)
- [ ] Navigation adapts to small screens (hamburger menu, bottom nav, or equivalent)

### State Communication

- [ ] Loading states show a skeleton, spinner, or progress indicator
- [ ] Error states show a user-friendly message with a recovery action (retry, go back)
- [ ] Empty states explain what to do next (not just a blank page)
- [ ] Success feedback is visible (toast, inline confirmation, updated state)
- [ ] Disabled states have visible styling and accessible communication (`aria-disabled`)
- [ ] Form validation errors are shown inline next to the relevant field

### Interaction Patterns

- [ ] Modals trap focus and return focus to the trigger on close
- [ ] Confirmation dialogs protect destructive actions (delete, discard changes)
- [ ] Long-running operations show progress and can be cancelled where appropriate
- [ ] Undo is preferred over "are you sure?" confirmation for recoverable actions
- [ ] Navigation away from unsaved changes shows a warning

---

## CSS Quality

### Scoping

- [ ] CSS approach matches project convention (CSS Modules, Tailwind, styled-components, BEM)
- [ ] Styles do not leak to unrelated components (no unscoped global selectors)
- [ ] Global styles are limited to reset, typography, and design tokens

### Specificity and Maintainability

- [ ] Selector nesting is 3 levels or fewer
- [ ] `!important` is not used (flag any with justification required)
- [ ] Magic numbers are replaced with design tokens or named CSS custom properties
- [ ] `z-index` values follow a defined scale (not arbitrary large numbers like `z-index: 9999`)
- [ ] Vendor prefixes are handled by Autoprefixer/PostCSS, not manually

### Layout

- [ ] Flexbox or Grid is used for layout — no `float`-based layouts in new code
- [ ] `position: absolute/fixed` is used sparingly and documented when needed
- [ ] Responsive breakpoints use the design system's defined breakpoints
- [ ] Units are consistent (rem for typography, px for borders, % or viewport units for layout)

---

## Testing

### Component Tests

- [ ] New components have unit or integration tests
- [ ] Tests render the component and assert on user-visible output, not internal state
- [ ] User interactions are simulated with user-event or equivalent (not direct state manipulation)
- [ ] Async behavior (data fetching, timers) is properly awaited
- [ ] Accessibility assertions are included (axe-core, `toHaveAccessibleName`, role queries)

### Visual and E2E Tests

- [ ] Visual regression tests exist for components with complex layout (Storybook + Chromatic, Percy)
- [ ] E2E tests cover critical user flows (login, checkout, form submission)
- [ ] Cross-browser testing covers the project's browser support matrix
- [ ] Mobile viewport tests are included for responsive features

### Test Quality

- [ ] Snapshot tests are used sparingly and only for stable, well-understood output
- [ ] Tests do not depend on CSS class names or DOM structure for assertions
- [ ] Mock data uses factories or builders, not hardcoded objects
- [ ] Tests are deterministic — no reliance on animation timing, network, or viewport size
