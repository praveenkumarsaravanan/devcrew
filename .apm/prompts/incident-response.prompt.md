---
name: incident-response
description: Triage and resolve production incidents with structured severity assessment
---

# Incident Response

Help triage and resolve a production incident:

1. **Assess severity** -- Is this P0 (customer-facing outage), P1 (degraded service), P2 (non-critical), or P3 (cosmetic)?
2. **Identify blast radius** -- Which services, users, and regions are affected?
3. **Find root cause** -- Check recent deployments, dependency health, resource utilization, and error logs.
4. **Suggest mitigation** -- Propose immediate actions: rollback, feature flag, traffic shift, or manual fix.
5. **Draft comms** -- Write a status page update appropriate for the severity level.
6. **Data feed incidents** -- If a feed is involved, activate `operational-feed-runbook`. Check freshness, rejects, quarantine, DLQ, reconciliation, replay/backfill safety, and downstream consumer impact before rerunning jobs.
7. **Document follow-up** -- List action items for the post-mortem: root cause analysis, prevention measures, monitoring gaps.

Prioritize speed of mitigation over perfection. Suggest the safest action that restores service first.
