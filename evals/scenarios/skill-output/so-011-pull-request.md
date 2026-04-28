---
id: SO-011
dimension: skill-output
skill: pull-request
name: Create PR with ticket validation
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-011: Create PR with Ticket Validation

## Task

> Create a pull request for the changes on branch feat/PLAT-1234-add-rate-limiting.
> The Jira ticket PLAT-1234 says "Add rate limiting to public API endpoints"
> with acceptance criteria:
> - Rate limit of 100 req/min per API key
> - Return 429 with Retry-After header when exceeded
> - Rate limits configurable per endpoint
>
> The implementation adds rate limiting using a Redis-based sliding window,
> but only implements global rate limiting (not per-endpoint configuration).

Activate the `pull-request` skill.

## Expected Behavior

1. PR title references the ticket (PLAT-1234).
2. PR description has structured sections (Summary, Changes, Test plan).
3. Identifies the **discrepancy** between the ticket's acceptance criteria and the implementation (per-endpoint config is missing).
4. Test summary lists what was tested.
5. Does not silently approve an incomplete implementation.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| PR title includes ticket key | 15% | PLAT-1234 in title |
| Structured description (summary, changes, test plan) | 20% | ≥3 sections with content |
| Detects the implementation gap (per-endpoint config missing) | 30% | Explicitly flags the discrepancy |
| Test plan is specific (not "tests added") | 20% | Lists specific test scenarios |
| Clear and concise (not overly verbose) | 15% | Scannable by a reviewer |

**Critical failure:** Creates a PR that claims full ticket completion when per-endpoint config is missing.
