---
id: contract-001
dimension: contracts
title: "OpenAPI changes require compatibility review"
skill: interoperability-contracts
pass_threshold: 0.80
scoring: requirements-judge
---

# Contract-001: OpenAPI Changes Require Compatibility Review

## Task

> "Review an OpenAPI update that renames `customerId` to `accountId`, changes `status` from optional to required, and removes the `legacyCode` response field. The team says existing clients can update quickly."

Run a contract review.

## Expected Behavior

1. **Activates contract guidance:** Applies `interoperability-contracts` or equivalent compatibility review.
2. **Flags breaking changes:** Identifies rename, requiredness change, and removed response field as breaking or potentially breaking.
3. **Versioning/deprecation:** Requires new version, compatibility mode, or parallel contract plus deprecation window.
4. **Consumer migration:** Requires affected consumers, owners, migration steps, and support/removal timeline.
5. **Contract tests:** Requires provider/consumer/compatibility tests before merge or release.
6. **Examples:** Requires updated normal, invalid, edge, and historical examples.
7. **Severity:** Treats the change as merge-relevant, not a documentation-only update.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Contract guidance activated | 10% | Uses interoperability contract lens |
| Breaking changes | 25% | Flags rename, requiredness, and removal |
| Versioning/deprecation | 20% | Requires migration-safe compatibility path |
| Consumer migration | 15% | Identifies consumers and timeline |
| Contract tests | 15% | Requires provider/consumer/compatibility tests |
| Examples | 5% | Requires representative examples |
| Severity | 10% | Treats as merge-relevant |

**Critical failure:** Approves the OpenAPI change because consumers can update quickly.
