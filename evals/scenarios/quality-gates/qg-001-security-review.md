---
id: qg-001
dimension: quality-gates
title: "Security review — should catch SQL injection and auth bugs"
fixture: fixtures/AuthService.java
planted_bugs: 6
critical_bugs: 2
high_bugs: 2
medium_bugs: 2
pass_threshold: 0.70
---

# QG-001: Security Review — AuthService

## Setup

1. Place `evals/fixtures/AuthService.java` in a test project with DevCrew installed.
2. Ensure `.project-context.md` has `discipline: backend` and `stack: java-spring`.

## Task

> "Review AuthService.java for security issues and code quality. This is a critical authentication service."

## Planted Bugs (6 total)

| # | Severity | Bug | Location |
|---|----------|-----|----------|
| 1 | CRITICAL | SQL injection — string concatenation in query | `login()` |
| 2 | CRITICAL | Plaintext password comparison — no hashing | `verifyPassword()` |
| 3 | HIGH | No rate limiting on authentication | `authenticate()` |
| 4 | HIGH | Predictable token generation | `generateToken()` |
| 5 | MEDIUM | Information disclosure — detailed error messages | `getUser()` |
| 6 | MEDIUM | No input validation on password reset | `resetPassword()` |

## Expected Behavior

1. **Governance classification:** HIGH risk (auth service)
2. **Review should identify:** All critical bugs, most high bugs
3. **Review should NOT approve:** Code should be flagged as requiring fixes before merge
4. **Recommendations:** Should suggest parameterized queries, bcrypt/argon2, rate limiting, JWT/secure random tokens

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Catches both CRITICAL bugs | 30% | SQL injection AND plaintext password identified |
| Catches at least 1 HIGH bug | 20% | Rate limiting OR weak token flagged |
| Catches at least 1 MEDIUM bug | 10% | Information disclosure OR missing validation flagged |
| Correct risk classification | 15% | Classifies as HIGH risk |
| Does NOT approve the code | 15% | Review verdict is "requires changes" or equivalent |
| Suggests proper fixes | 10% | Recommends parameterized queries and password hashing |

### Critical failure

If the review approves this code without flagging SQL injection, the entire eval is scored 0% regardless of other criteria. This is a **must-catch** scenario.
