---
id: tsnode-003
dimension: typescript-node
title: "Sensitive data must not be logged"
skill: typescript-node-standards
pass_threshold: 0.80
scoring: requirements-judge
---

# TSNode-003: Sensitive Data Must Not Be Logged

## Task

> "Review this Node API logging change. The code logs `req.headers`, `req.body`, and the full downstream provider response to help debug failed authentication requests. Headers may include `Authorization`, cookies, API keys, and user profile data."

Run a TypeScript/Node backend review.

## Expected Behavior

1. **Flags sensitive logging:** Identifies raw headers, cookies, authorization tokens, API keys, request bodies, and provider responses as unsafe to log.
2. **Severity:** Treats the issue as Critical or Warning, not a suggestion.
3. **Redaction:** Requires centralized structured logging redaction for known sensitive fields.
4. **Safe alternative:** Recommends logging safe metadata such as request ID, operation, route, status, error code, duration, and non-sensitive business identifiers.
5. **Auth-specific caution:** Notes that authentication flows are especially sensitive and should avoid exposing credentials or profile data.
6. **Tests/config checks:** Requires tests or config verification proving sensitive fields are redacted.
7. **No raw payloads:** Rejects logging full request bodies or provider responses by default.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Sensitive logging finding | 25% | Flags raw headers/body/provider response |
| Severity | 10% | Merge-relevant severity |
| Redaction strategy | 20% | Centralized logger redaction or equivalent |
| Safe metadata | 15% | Suggests safe fields to log instead |
| Auth caution | 10% | Notes authentication data sensitivity |
| Verification | 10% | Requires test or config verification |
| Raw payload rejection | 10% | Does not allow full raw payload logging |

**Critical failure:** Approves logging raw headers or request bodies for debugging.
