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
| **High** | Authentication, authorization, encryption, PII/sensitive data handling, payment processing, credential management, data deletion, sensitive exports, audit/retention controls, breaking external contracts, backfill/replay, IAM, network exposure, public storage, production infrastructure, security configurations | Human-guided assistance only — agent proposes, human decides | Human must approve each step before execution |

## Risk Classification Signals

Use these signals to classify files and changes:

### High Risk — Any of these triggers high-risk classification:

- File path contains: `auth/`, `security/`, `crypto/`, `payment/`, `billing/`, `encryption/`
- File handles: passwords, tokens, API keys, session management, OAuth flows
- File manages: PII (names, emails, addresses, SSN, payment cards), GDPR-relevant data
- File performs: data deletion (hard or soft), bulk mutations, privilege escalation
- Change modifies: CORS configuration, CSP headers, rate limiting rules, firewall rules
- Change touches: environment variable definitions for secrets, credential rotation logic
- Change modifies: IAM policies/roles, KMS keys/key policies, security groups, public load balancers, VPC routing, S3 bucket policies/ACLs/public-access-block settings
- Change creates or changes: production AWS infrastructure, async retry/DLQ behavior, destructive infrastructure actions, cross-account access, or public data exposure
- Change creates or changes: production data feeds, source contracts, mapping semantics, replay/backfill scripts, reconciliation logic, reject/quarantine behavior, or data quality thresholds
- Change creates or changes: public, partner, or cross-team contracts, OpenAPI/AsyncAPI specs, webhooks, protobuf schemas, file/feed contracts, versioning, deprecation, or consumer migration paths
- Change creates or changes: sensitive data classification, masking/redaction, synthetic/de-identified test data, audit events, sensitive exports, retention/deletion, or bulk access controls
- References `security-baseline` instruction patterns
- References `aws-baseline` instruction patterns
- References `infrastructure-baseline` instruction patterns
- References `data-platform-baseline` instruction patterns
- References `regulated-data-baseline` instruction patterns

### Medium Risk — Default for most application code:

- Business logic implementing user-facing features
- API endpoint handlers and middleware
- Database schema changes and migration scripts
- Service-to-service integration code
- Additive contract changes with documented compatibility and low sensitivity
- State management (Redux, Zustand, Context, etc.)
- Error handling and retry logic
- Non-production AWS configuration, routine tag updates, and low-blast-radius cloud configuration changes
- Data mapping or ingestion changes that do not affect sensitive data, production replay/backfill, or externally visible contracts
- Internal contract or schema cleanup that does not affect existing consumers

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
- **`aws-baseline`** — Defines AWS-specific safety rules for IAM, public exposure, encryption, async failure handling, observability, and secrets.
- **`infrastructure-baseline`** — Defines IaC and image-build safety rules for state, plan evidence, drift, secrets, scans, promotion, and rollback.
- **`data-platform-baseline`** — Defines data ingestion, mapping, replay, reconciliation, and feed operation safety rules.
- **`regulated-data-baseline`** — Defines regulated data classification, redaction, synthetic test data, audit, and retention safety rules.
- **`coding-standards`** — Defines commit message format and PR requirements referenced by audit trail rules.
- **`team-workflow`** — Applies governance at Phase 3 (implementation autonomy) and Phase 4 (review depth).
