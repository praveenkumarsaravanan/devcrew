# [FEATURE NAME] — UI Component Specification

## Problem Statement

[PLACEHOLDER: Describe the user-facing problem this component solves and why it is needed now.]

## Scope

| In scope | Out of scope |
|----------|--------------|
| [PLACEHOLDER] | [PLACEHOLDER] |

## Component Overview

| Field | Value |
|-------|-------|
| Component name | `[PLACEHOLDER]` |
| Type | Page / Component / Layout |
| Parent component | [PLACEHOLDER: e.g., `DashboardLayout`, or "root route"] |
| Route (if page) | [PLACEHOLDER: e.g., `/settings/profile`] |

## Props / Inputs Interface

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| [PLACEHOLDER] | `string` | Yes | — | [PLACEHOLDER] |
| [PLACEHOLDER] | `boolean` | No | `false` | [PLACEHOLDER] |
| [PLACEHOLDER] | `() => void` | No | — | [PLACEHOLDER] |

## State Management

| State | Type | Source | Description |
|-------|------|--------|-------------|
| [PLACEHOLDER] | `[type]` | Local / Context / Store / URL | [PLACEHOLDER] |
| [PLACEHOLDER] | `[type]` | [PLACEHOLDER] | [PLACEHOLDER] |

**Approach:** [PLACEHOLDER: e.g., "Local state via `useState` for form fields; global store for user session"]

## User Interactions & Event Handlers

| Interaction | Element | Handler | Outcome |
|-------------|---------|---------|---------|
| Click | [PLACEHOLDER: e.g., "Submit button"] | `onSubmit` | [PLACEHOLDER: e.g., "Validates form, calls API, shows toast"] |
| Change | [PLACEHOLDER: e.g., "Email input"] | `onChange` | [PLACEHOLDER: e.g., "Updates local state, triggers validation"] |
| Keyboard | [PLACEHOLDER: e.g., "Enter key"] | `onKeyDown` | [PLACEHOLDER: e.g., "Submits form"] |
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| Mobile | < 640px | [PLACEHOLDER: e.g., "Single column, stacked cards"] |
| Tablet | 640–1024px | [PLACEHOLDER: e.g., "Two-column grid"] |
| Desktop | > 1024px | [PLACEHOLDER: e.g., "Three-column grid with sidebar"] |

## Accessibility Requirements

| Requirement | Implementation |
|-------------|----------------|
| ARIA roles | [PLACEHOLDER: e.g., `role="dialog"`, `aria-labelledby`] |
| Keyboard navigation | [PLACEHOLDER: e.g., "Tab order follows visual order; Escape closes modal"] |
| Screen reader | [PLACEHOLDER: e.g., "Live region announces form errors"] |
| Focus management | [PLACEHOLDER: e.g., "Focus trapped inside modal while open"] |
| Color contrast | [PLACEHOLDER: e.g., "Minimum WCAG AA (4.5:1 for text)"] |

## Component States

### Loading State

[PLACEHOLDER: Describe skeleton/spinner behavior while data loads.]

### Error State

[PLACEHOLDER: Describe error message display, retry affordance, and fallback UI.]

### Empty State

[PLACEHOLDER: Describe what the user sees when there is no data — illustration, message, CTA.]

### Success State

[PLACEHOLDER: Describe confirmation feedback — toast, redirect, inline message.]

## Design Tokens & Styling

| Token | Value | Usage |
|-------|-------|-------|
| `--color-primary` | [PLACEHOLDER] | [PLACEHOLDER: e.g., "CTA buttons, links"] |
| `--spacing-md` | [PLACEHOLDER] | [PLACEHOLDER: e.g., "Card padding, form gaps"] |
| `--radius-lg` | [PLACEHOLDER] | [PLACEHOLDER: e.g., "Card border radius"] |

**Styling approach:** [PLACEHOLDER: e.g., "CSS Modules with design-system tokens" / "Tailwind utility classes" / "Styled Components"]

## Requirements

| ID | Description | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| REQ-001 | [PLACEHOLDER] | [PLACEHOLDER] | Must |

## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Handoff Checklist

- [ ] Spec reviewed and approved
- [ ] Design mockups attached or linked
- [ ] Accessibility requirements reviewed
- [ ] Responsive breakpoints confirmed with design
- [ ] Open questions resolved
