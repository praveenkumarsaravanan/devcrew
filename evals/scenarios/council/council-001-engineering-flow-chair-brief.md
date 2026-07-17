---
id: council-001
dimension: council
title: "Engineering Flow chair brief and decision routing"
skill: team-workflow
expected_council_depth: deep
pass_threshold: 0.80
scoring: requirements-judge
---

# Council-001: Engineering Flow Chair Brief And Decision Routing

## Task

> "/engineering-flow --deep Design and implement retry handling for a TypeScript SQS worker that processes customer notification events. The worker must avoid duplicate sends, redact sensitive fields in logs, and use a dead letter queue for permanently failed messages."

Activate DevCrew Engineering Flow.

## Expected Behavior

1. **User-facing name:** Uses "DevCrew Engineering Flow" or `/engineering-flow` as the workflow name. Does not present `team-workflow` as the primary user-facing name.
2. **Council Chair opens the flow:** Produces a concise Council Brief before implementation.
3. **Classification:** Classifies the task as `standard-change` or `full-feature`, with rationale. `quick-fix` is incorrect.
4. **Risk:** Classifies risk as `medium` or `high` because retry behavior, customer notifications, logging redaction, and DLQ behavior affect reliability and sensitive data handling.
5. **Council depth:** Uses `deep` because the user explicitly requested `--deep` and the task has reliability/data-handling trade-offs.
6. **Active councils:** Names Implementation, Review, Quality, and Governance councils. Product and Architecture may be active if the agent treats the request as full-feature.
7. **Skipped councils:** Names skipped councils with a reason, especially Delivery and Operations if not in scope.
8. **Trade-offs:** Compares at least two retry/idempotency approaches before implementation.
9. **Decision artifact:** Produces a decision artifact or compact equivalent with options, trade-offs, recommendation, risks, approval needs, and next council.
10. **Preserves lifecycle:** Continues or plans to continue through the normal Engineering Flow phases. The Council Chair does not replace developer, reviewer, or QA roles.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Engineering Flow naming | 10% | Uses DevCrew Engineering Flow or `/engineering-flow` as the user-facing name |
| Chair brief present | 15% | Includes task size, risk, council depth, active/skipped councils |
| Correct depth | 15% | Uses `deep` or explicitly proposes it for user approval |
| Correct risk | 10% | Medium/high risk with rationale |
| Council routing | 15% | Correctly maps councils to existing agents/instructions |
| Trade-off analysis | 15% | Compares at least two retry/idempotency/logging approaches |
| Decision artifact | 10% | Includes recommendation, accepted/rejected risks, approval needs, next council |
| Lifecycle preserved | 10% | Does not replace implementation/review/QA with the Chair |

**Critical failure:** Treats every task as deep mode by default, or replaces the existing lifecycle phases with a standalone council discussion.
