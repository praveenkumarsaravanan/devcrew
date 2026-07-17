---
name: release-evidence
description: >
  Build and review evidence bundles for medium and high-risk releases. Use when
  release readiness needs proof for scope, tests, security, IaC/image changes,
  data impact, contract compatibility, rollback, monitoring, runbooks, and approvals.
---

# Release Evidence

## Trigger

Activate this skill when:

- The user asks for release evidence, delivery readiness, production readiness evidence, or a release evidence bundle
- `/release-evidence` is invoked
- `/release-readiness`, `/devops-plan`, `/monitoring-plan`, or `pull-request` needs evidence for medium or high-risk work
- A change touches production infrastructure, auth, sensitive data, payments, data feeds, external contracts, migrations, replay/backfill, or broad customer impact

Do NOT use this skill as a substitute for tests, review, or release approval. It collects and checks evidence; it does not create evidence that is missing.

## Workflow

### 1. Classify Release Scope And Risk

Capture:

- Release name, version, branch, commit SHA, PR, tickets, and owner
- Changed services, components, contracts, data flows, infrastructure, images, and runbooks
- Risk level: low, medium, or high, using `governance`
- Blast radius: users, tenants, services, data, environments, and external consumers affected
- Reversibility: feature flag, redeploy, rollback, forward-fix, data repair, or manual compensation

Medium and high-risk releases require a complete evidence bundle. Low-risk releases may use a compact summary.

### 2. Collect Evidence

Build an evidence table with pass/fail/not-applicable status:

| Area | Evidence required |
|---|---|
| Scope and tickets | Ticket/spec/PR links, accepted scope, changed components |
| Tests | Unit, integration, E2E, smoke, contract, data quality, load/perf where relevant |
| Security | Dependency/code scan, secrets scan, auth/authz review, regulated-data controls |
| IaC and image | Plan/diff/change-set, remote state/locking, drift, scans, SBOM/provenance, immutable artifact |
| Data impact | Migration/backfill/replay plan, reconciliation, data quality, quarantine, retention |
| Contract compatibility | OpenAPI/AsyncAPI/webhook/event/file/feed compatibility, versioning, deprecation, consumer migration |
| Rollback | Exact steps, trigger criteria, time-to-revert, data implications, owner |
| Monitoring/runbooks | SLIs/SLOs, dashboards, alerts, logs/traces, runbook links, on-call coverage |
| Approvals | Product, engineering, security, data, infrastructure, SRE, release manager as applicable |

Use links, command names, artifact IDs, report names, or concise summaries. "Looks good" is not evidence.

### 3. Check Evidence Quality

For each evidence item:

- Verify it is specific to this release, not a generic claim.
- Verify freshness: evidence should come from the release branch, release candidate, or target environment.
- Verify ownership: missing owners are release risks.
- Verify failures and waivers are explicit, time-bound, and approved by the right owner.
- Verify manual-only evidence states who performed it, when, where, and what result was observed.

### 4. Identify Release Gaps

Classify gaps:

- **Critical:** Missing rollback for high-risk change, missing security evidence for auth/sensitive data, missing IaC plan for production infrastructure, missing contract compatibility for external consumers, missing audit/retention evidence for sensitive export/deletion, no monitoring for customer-impacting path.
- **Warning:** Incomplete test evidence, missing runbook link, unclear owner, no performance baseline for latency-sensitive path, weak deprecation timeline, manual-only validation with no notes.
- **Suggestion:** Improve evidence formatting, add dashboard links, tighten communication plan, or add clearer ticket/spec traceability.

### 5. Produce Recommendation

Return one of:

- **Ready:** Evidence is complete and remaining risk is accepted.
- **Ready with waivers:** Gaps are explicitly waived by accountable owners.
- **Not ready:** Critical evidence is missing or stale.

## Output

Return:

1. **Release summary** - scope, tickets, changed components, risk, blast radius
2. **Evidence matrix** - pass/fail/N-A by evidence area
3. **Findings** - Critical, Warning, Suggestion ordered by severity
4. **Rollback and monitoring verdict** - exact readiness statement
5. **Approvals needed** - owners and missing sign-offs
6. **Recommendation** - Ready, Ready with waivers, or Not ready

## Guardrails

- **Never call missing evidence "passed."** Mark it failed or not-applicable with rationale.
- **Never approve high-risk releases without rollback and monitoring evidence.**
- **Never accept generic security claims.** Require scan results, review evidence, or explicit waiver.
- **Never ignore contract, data, IaC, or image impact.** Mark them N-A only after checking scope.
- **Waivers need owners.** A waiver without an accountable owner and expiry is still a gap.
- **Keep the bundle compact.** Link to reports instead of pasting long logs.

## See Also

- **`release-manager`** - Go/no-go decisions and release coordination.
- **`devops-engineer`** - Deployment strategy, IaC/image evidence, and rollback planning.
- **`sre`** - Monitoring, SLOs, alerts, runbooks, and incident readiness.
- **`infrastructure-as-code`** - Plan, state, drift, secret, and rollback evidence.
- **`image-build`** - Scan, SBOM/provenance, immutable artifact, and rollback evidence.
- **`interoperability-contracts`** - Contract compatibility and consumer migration evidence.
- **`regulated-data-handling`** - Sensitive data, audit, retention, and synthetic test-data evidence.
