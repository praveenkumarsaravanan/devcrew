---
id: regdata-003
dimension: regulated-data
title: "Audit events required for sensitive access"
skill: regulated-data-handling
pass_threshold: 0.80
scoring: requirements-judge
---

# RegData-003: Audit Events Required For Sensitive Access

## Task

> "Review a new admin endpoint that exports customer account data for support investigations. It checks admin permissions and returns a CSV, but it does not write an audit event because the endpoint is only used internally."

Run a regulated data review.

## Expected Behavior

1. **Requires audit:** Identifies sensitive export as requiring an audit event even for internal use.
2. **Severity:** Treats missing audit as Critical or Warning.
3. **Audit fields:** Requires actor, action, target/scope, timestamp, reason or ticket where available, source system, correlation ID, and outcome.
4. **No raw values:** Requires audit records to avoid raw sensitive field values.
5. **Authorization:** Verifies admin permission checks and least-privilege scope are necessary but not sufficient.
6. **Retention:** Requires retention/deletion expectations for export files and audit records.
7. **Tests:** Requires tests for audit emission on success and failure.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Audit requirement | 25% | Requires audit for sensitive export |
| Severity | 10% | Merge-relevant severity |
| Audit fields | 20% | Names required audit metadata |
| No raw values | 10% | Keeps audit records safe |
| Authorization | 10% | Checks least privilege |
| Retention | 10% | Covers export and audit retention |
| Tests | 15% | Requires audit tests for success/failure |

**Critical failure:** Approves the endpoint with no audit event because it is internal.
