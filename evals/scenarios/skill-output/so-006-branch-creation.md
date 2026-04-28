---
id: SO-006
dimension: skill-output
skill: branch-creation
name: Create branch from Jira ticket
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-006: Create Branch from Jira Ticket

## Task

> Create a branch for Jira ticket PLAT-1234: "Add rate limiting to public API endpoints"

Activate the `branch-creation` skill.

## Expected Behavior

1. Branch name includes the ticket key (`PLAT-1234`).
2. Branch name includes a short description derived from the ticket title.
3. Uses the correct prefix (`feat/` for a new feature).
4. Description is kebab-case, concise (≤5 words), and meaningful.
5. Does not include special characters or spaces.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Contains ticket key (PLAT-1234) | 25% | Exact match |
| Correct prefix (feat/) | 20% | Matches the change type |
| Kebab-case description | 20% | Lowercase, hyphen-separated |
| Description is concise and meaningful | 20% | ≤5 words, reflects the ticket title |
| No invalid characters | 15% | No spaces, uppercase (except ticket key), special chars |

Expected output: `feat/PLAT-1234-add-rate-limiting` or similar.

**Critical failure:** Branch name doesn't include the ticket key.
