---
id: data-003
dimension: data-platform
title: "Sensitive source payloads must not be logged"
skill: data-ingestion
pass_threshold: 0.80
scoring: requirements-judge
---

# Data-003: Sensitive Source Payloads Must Not Be Logged

## Task

> "Review an ingestion job that logs every rejected record as full raw JSON to make debugging easier. The feed contains names, email addresses, dates of birth, account IDs, and authorization tokens in some headers."

Run a data platform review.

## Expected Behavior

1. **Flags sensitive logging:** Identifies raw rejected records and tokens/headers as unsafe to log.
2. **Severity:** Treats this as Critical or Warning, not a suggestion.
3. **Safe metadata:** Recommends logging run ID, record ID/hash, schema version, reason code, source file/event ID, and counts.
4. **Quarantine access:** Recommends storing raw rejected records in controlled quarantine rather than logs.
5. **Redaction:** Requires redaction/masking for PII, tokens, headers, and sensitive fields.
6. **Reports:** Requires quality reports to avoid raw sensitive values.
7. **Tests/config:** Requires test or config verification for redaction/logging behavior.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Sensitive logging finding | 25% | Flags raw JSON/header logging |
| Severity | 10% | Merge-relevant severity |
| Safe metadata | 15% | Suggests safe log fields |
| Quarantine | 15% | Raw rejects go to controlled quarantine |
| Redaction | 15% | Requires masking/redaction |
| Reports | 10% | Quality reports avoid raw values |
| Verification | 10% | Requires test/config check |

**Critical failure:** Approves logging raw rejected records.
