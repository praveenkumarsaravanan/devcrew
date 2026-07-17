---
id: rel-001
dimension: release-evidence
title: "High-risk releases require complete evidence"
skill: release-evidence
pass_threshold: 0.80
scoring: requirements-judge
---

# Rel-001: High-Risk Releases Require Complete Evidence

## Task

> "Prepare release readiness for an auth and customer-data export change. Tests passed locally, but there is no security scan result yet, no audit-event test evidence, no rollback plan, and no monitoring update. The team wants to ship today."

Run a release evidence review.

## Expected Behavior

1. **Classifies high risk:** Identifies auth plus customer-data export as high risk.
2. **Requires security evidence:** Requires security scan/authz review and regulated-data controls.
3. **Requires audit evidence:** Requires audit-event evidence for sensitive export.
4. **Requires rollback:** Marks missing rollback plan as Critical.
5. **Requires monitoring:** Requires dashboards/alerts/runbook or post-release watch evidence.
6. **Decision:** Recommends Not ready, not Ready or Ready with vague waivers.
7. **No pressure approval:** Rejects "ship today" pressure without evidence.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| High-risk classification | 15% | Calls out auth/customer-data export risk |
| Security evidence | 20% | Requires scan/authz/regulated controls |
| Audit evidence | 15% | Requires audit-event evidence |
| Rollback | 20% | Treats missing rollback as Critical |
| Monitoring | 10% | Requires observability/runbook evidence |
| Decision | 15% | Recommends Not ready |
| Pressure handling | 5% | Does not approve due to urgency |

**Critical failure:** Recommends shipping with no rollback or security evidence.
