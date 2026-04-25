---
description: Risk-level governance and autonomy boundaries for AI agent operations
applyTo: "**/*.{ts,tsx,js,jsx,java,go,py,rs,sql,yml,yaml,json,html,css,scss}"
---

# Governance

## Risk Levels

Every code change carries a risk level that determines the agent's autonomy boundary. Assess the risk level at the start of implementation (Phase 3) and review (Phase 4).

| Risk Level | Scope | Agent Autonomy | Human Gate |
|------------|-------|----------------|------------|
| **Low** | Documentation, tests, UI polish, linting fixes, dependency bumps (non-breaking), config formatting | Full autonomy — agent implements and self-reviews | Post-review only (PR approval) |
| **Medium** | Business logic, API endpoints, database queries, service integrations, state management, error handling | Agent implements with mandatory human review | PR approval required before merge |
| **High** | Authentication, authorization, encryption, PII handling, payment processing, credential management, data deletion, security configurations | Human-guided assistance only — agent proposes, human decides | Human must approve each step before execution |

## Risk Classification Signals

Use these signals to classify files and changes:

### High Risk — Any of these triggers high-risk classification:

- File path contains: `auth/`, `security/`, `crypto/`, `payment/`, `billing/`, `encryption/`
- File handles: passwords, tokens, API keys, session management, OAuth flows
- File manages: PII (names, emails, addresses, SSN, payment cards), GDPR-relevant data
- File performs: data deletion (hard or soft), bulk mutations, privilege escalation
- Change modifies: CORS configuration, CSP headers, rate limiting rules, firewall rules
- Change touches: environment variable definitions for secrets, credential rotation logic
- References `security-baseline` instruction patterns

### Medium Risk — Default for most application code:

- Business logic implementing user-facing features
- API endpoint handlers and middleware
- Database schema changes and migration scripts
- Service-to-service integration code
- State management (Redux, Zustand, Context, etc.)
- Error handling and retry logic

### Low Risk — Changes with minimal blast radius:

- Test files (`*.test.*`, `*.spec.*`, `__tests__/`)
- Documentation files (`*.md`, `docs/`)
- UI styling changes (CSS, SCSS, Tailwind classes)
- Linter configuration (`.eslintrc`, `.prettierrc`)
- CI configuration that doesn't affect deployment (`*.yml` in `.github/workflows/` for non-deploy jobs)
- Code comments and JSDoc/Javadoc

## Autonomy Rules

### Low Risk
- Agent may implement, test, and prepare the PR without pausing for approval.
- Phase 4 (code review) runs as lightweight inline review.
- Agent should still flag anything surprising in the PR description.

### Medium Risk
- Agent implements normally through the team-workflow phases.
- Phase 4 (code review) runs as full adversarial review with subagent isolation.
- Agent must NOT merge or approve its own changes — a human reviewer is required.
- PR description must reference the spec or ticket that authorized the change.

### High Risk
- Agent operates in **advisory mode**: it proposes changes but does not write them directly.
- Each proposed change must be presented to the user with:
  1. What will change (diff preview)
  2. Why this change is necessary
  3. What could go wrong (risk assessment)
  4. Rollback strategy
- The user must explicitly approve each change before the agent writes it.
- Phase 4 review is mandatory, adversarial, and must include security-focused checks from `security-baseline`.
- Commit messages must include `[HIGH-RISK]` prefix for audit trail visibility.

## Audit Trail Requirements

All changes — regardless of risk level — must satisfy:

- **Traceability:** PR descriptions reference the originating spec (`.spec.md`), ticket ID, or user request.
- **Conventional commits:** Commit messages follow the format defined in `coding-standards` (`type(scope): TICKET, description`).
- **Change justification:** For medium and high risk, the PR body must include a "Why" section explaining the motivation.
- **Review evidence:** For medium and high risk, at least one human reviewer must approve before merge.

## Escalation

If the agent is uncertain about the risk level of a change:

1. Default to the **higher** risk level.
2. Present the classification to the user with reasoning.
3. Let the user override if appropriate.

Never downgrade risk without explicit user approval.

## See Also

- **`security-baseline`** — Defines the security rules that high-risk changes must satisfy.
- **`coding-standards`** — Defines commit message format and PR requirements referenced by audit trail rules.
- **`team-workflow`** — Applies governance at Phase 3 (implementation autonomy) and Phase 4 (review depth).
