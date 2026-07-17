---
name: operational-feed-runbook
description: >
  Operational runbook guidance for production data feeds, including schedules,
  ownership, alerts, diagnosis, replay/backfill, reconciliation, escalation,
  and post-incident follow-up.
---

# Operational Feed Runbook

## Trigger

Activate this skill when:

- The user asks for a feed runbook, operational procedure, incident guide, replay process, backfill plan, reconciliation process, or production support plan for a data pipeline.
- SRE, monitoring, incident response, or release readiness needs feed-specific operational guidance.

## Workflow

### 1. Runbook Metadata

Capture:

- Feed name, purpose, owner, upstream owner, downstream owner, schedule, SLA/SLO, expected volume, and criticality.
- Source and destination systems.
- Dashboard, logs, trace, data quality report, and reconciliation report links.
- Access requirements and break-glass path.

### 2. Alerts And Symptoms

Define actionable alerts:

- Missed schedule or stale data.
- High reject/quarantine rate.
- DLQ depth or retry exhaustion.
- Reconciliation mismatch.
- Backlog, lag, cursor stall, or queue age.
- Downstream write failure.
- Sensitive-data logging or policy violation.

### 3. Diagnosis And Mitigation

For each failure mode, document:

- How to confirm impact and blast radius.
- First diagnostics to run.
- Safe mitigation steps.
- When not to retry.
- Escalation owner and required context.

### 4. Replay And Backfill

- Define replay scope, time window, data source, idempotency controls, dry-run/preview, approval gate, and expected volume.
- Define how to prevent duplicate side effects.
- Define rollback or compensation if replay produces bad data.
- Record audit evidence: who approved, when replay ran, records affected, and reconciliation result.

### 5. Closure

- Confirm reconciliation and quality report are clean or exceptions are accepted.
- Communicate status to downstream consumers.
- Capture incident follow-ups: source contract fixes, tests, monitors, runbook updates, and owner.

## Output

Produce a runbook with:

1. **Feed overview** - purpose, owners, schedule, SLA/SLO, criticality.
2. **Signals** - dashboards, alerts, logs, reports, freshness and quality metrics.
3. **Failure modes** - symptoms, diagnosis, mitigation, escalation.
4. **Replay/backfill** - approval, scope, idempotency, dry-run, execution, validation.
5. **Closure checklist** - reconciliation, communication, follow-up actions.

## Guardrails

- **Never define an alert without an action and owner.**
- **Never run replay/backfill without idempotency controls and explicit scope.**
- **Never skip reconciliation after replay, backfill, or recovery.**
- **Never expose raw sensitive payloads in runbooks, dashboards, or incident notes.**
