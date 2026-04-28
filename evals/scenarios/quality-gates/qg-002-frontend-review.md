---
id: qg-002
dimension: quality-gates
title: "Frontend review — should catch XSS, PII leak, and a11y issues"
fixture: fixtures/PaymentForm.tsx
planted_bugs: 5
critical_bugs: 1
high_bugs: 1
medium_bugs: 2
low_bugs: 1
pass_threshold: 0.70
---

# QG-002: Frontend Review — PaymentForm

## Setup

1. Place `evals/fixtures/PaymentForm.tsx` in a test project with DevCrew installed.
2. Ensure `.project-context.md` has `discipline: frontend` and `stack: react-typescript`.

## Task

> "Review PaymentForm.tsx for security, accessibility, and code quality. This handles credit card payments."

## Planted Bugs (5 total)

| # | Severity | Bug | Location |
|---|----------|-----|----------|
| 1 | CRITICAL | PII logged to console (credit card, CVV) | `handleSubmit()` |
| 2 | HIGH | XSS via `dangerouslySetInnerHTML` with user input | render return |
| 3 | MEDIUM | No input sanitization before callback | `handleSubmit()` |
| 4 | MEDIUM | Missing form labels and ARIA attributes | all `<input>` elements |
| 5 | LOW | No debounce on input handlers | `onChange` handlers |

## Expected Behavior

1. **Governance classification:** HIGH risk (payment processing, PII)
2. **Review should catch:** PII logging (critical), XSS (high), accessibility (medium)
3. **Frontend-specific checks:** Accessibility issues should be flagged by the `frontend-reviewer` agent
4. **Review should NOT approve:** Payment form with PII logging should never pass review

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Catches PII logging (CRITICAL) | 30% | Console.log of credit card/CVV identified |
| Catches XSS (HIGH) | 20% | dangerouslySetInnerHTML with user input flagged |
| Catches accessibility (MEDIUM) | 15% | Missing labels or ARIA attributes noted |
| Catches sanitization (MEDIUM) | 10% | Raw input passed to callback flagged |
| Correct risk classification | 10% | Classifies as HIGH risk |
| Does NOT approve the code | 15% | Review verdict is "requires changes" |

### Critical failure

If the review approves code that logs credit card numbers to console, the entire eval is scored 0%.
