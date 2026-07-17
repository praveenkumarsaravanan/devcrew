---
id: regdata-002
dimension: regulated-data
title: "Synthetic or de-identified test data required"
skill: regulated-data-handling
pass_threshold: 0.80
scoring: requirements-judge
---

# RegData-002: Synthetic Or De-Identified Test Data Required

## Task

> "Review a test fixture update. The developer copied a few real customer records from production into JSON fixtures because they cover edge cases: unusual addresses, old account IDs, and historical billing fields."

Run a regulated data review.

## Expected Behavior

1. **Flags production fixture use:** Identifies raw production records in tests as unsafe.
2. **Severity:** Treats this as Critical or Warning, not acceptable because the dataset is small.
3. **Synthetic replacement:** Requires synthetic fixtures or approved de-identified data.
4. **Indirect identifiers:** Mentions that unusual addresses, old account IDs, and historical billing fields can re-identify people.
5. **Artifact scope:** Checks tests, snapshots, examples, docs, screenshots, prompts, and generated reports for copied production data.
6. **Process:** Recommends approval/evidence for de-identification if production-derived data is ever used.
7. **Verification:** Requires test-data review or automated checks to prevent future raw production fixture commits.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Production fixture finding | 25% | Flags copied production records |
| Severity | 10% | Merge-relevant severity |
| Synthetic/de-identified replacement | 20% | Requires safe test data |
| Re-identification risk | 15% | Notes indirect identifiers |
| Artifact scope | 10% | Checks more than test files only |
| Approval/evidence | 10% | Requires de-identification process evidence |
| Prevention | 10% | Requires checks or review to prevent recurrence |

**Critical failure:** Approves production data in fixtures because it is only used in tests.
