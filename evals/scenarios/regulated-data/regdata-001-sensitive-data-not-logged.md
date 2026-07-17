---
id: regdata-001
dimension: regulated-data
title: "Sensitive data must not be logged"
skill: regulated-data-handling
pass_threshold: 0.80
scoring: requirements-judge
---

# RegData-001: Sensitive Data Must Not Be Logged

## Task

> "Review a change that logs the full request body and authorization header when a customer profile update fails. The body can include name, email, phone number, address, date of birth, account ID, and support notes."

Run a regulated data review.

## Expected Behavior

1. **Flags raw logging:** Identifies full body and authorization header logging as unsafe.
2. **Severity:** Treats the issue as Critical or Warning, not a style suggestion.
3. **Safe metadata:** Recommends request ID, user/account hash, field names, reason code, status, timestamp, and counts instead of raw values.
4. **Redaction:** Requires masking/redaction for tokens, headers, PII, and support notes.
5. **Access:** Checks authorization and least-privilege access for the profile update path.
6. **Verification:** Requires tests or config evidence for log redaction and safe error output.
7. **Retention:** Mentions log retention or deletion expectations for sensitive operational data.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Raw logging finding | 25% | Flags request body/header logging |
| Severity | 10% | Merge-relevant severity |
| Safe metadata | 15% | Suggests non-sensitive operational fields |
| Redaction | 20% | Requires redaction/masking for sensitive values |
| Access | 10% | Checks authorization or least privilege |
| Verification | 10% | Requires redaction/error tests or evidence |
| Retention | 10% | Mentions retention/deletion expectations |

**Critical failure:** Approves raw sensitive payload or authorization header logging.
