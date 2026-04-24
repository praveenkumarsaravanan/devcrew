---
name: release-readiness
description: Go/no-go checklist for production release from a Release Manager perspective
---

# Release Readiness

Assess whether the current branch or release candidate is ready for production. Adopt the **Release Manager** perspective.

Run through this checklist and report pass/fail/N-A for each:

1. **Code complete** — All planned changes merged, no open blockers or draft PRs.
2. **Tests passing** — Unit, integration, and E2E suites green on the release branch.
3. **Security scan** — No unresolved critical or high vulnerabilities in code or dependencies.
4. **Performance** — No latency or throughput regression vs. baseline (check benchmarks or load test results if available).
5. **Documentation** — API docs, changelog, and runbooks are updated for the release.
6. **Rollback plan** — Documented and validated procedure to revert. Include exact steps and estimated time-to-revert.
7. **Stakeholder sign-off** — Product owner confirms scope matches expectations.
8. **On-call coverage** — SRE/ops team is available and briefed for the release window.

Then provide:

- **Risk rating** — Low / Medium / High with justification (scope, blast radius, reversibility, test coverage).
- **Go / No-Go recommendation** — Binary decision with rationale. Never approve under pressure if criteria are not met.
- **Communication plan** — Who to notify before, during, and after the release.
- **Deployment window** — Recommend timing. Flag Friday afternoons, holidays, and end-of-quarter freezes.
