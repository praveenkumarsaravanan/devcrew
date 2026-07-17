---
name: regulated-data-handling
description: >
  Generic sensitive and regulated data handling guidance for classification,
  minimization, redaction, synthetic test data, audit events, retention, and
  safe operational visibility. Use for PII, PHI, payment data, credentials,
  secrets, customer data, or other protected data classes.
---

# Regulated Data Handling

## Trigger

Activate this skill when the user or diff mentions:

- PII, PHI, payment data, customer records, credentials, tokens, secrets, identifiers, addresses, dates of birth, account numbers, or similarly sensitive fields
- Logs, traces, metrics, dashboards, reports, runbooks, exports, fixtures, samples, or test data that may contain sensitive values
- Data classification, masking, redaction, de-identification, synthetic data, privacy, retention, deletion, audit, consent, access control, or compliance
- External contracts, feeds, APIs, or webhooks carrying sensitive payloads

This skill is intentionally domain-neutral. Apply local legal/compliance standards when the project defines them.

## Workflow

### 1. Classify The Data

Identify every sensitive data class involved:

- **Secrets and credentials:** passwords, tokens, API keys, certificates, session IDs, authorization headers
- **Personal data:** names, emails, phone numbers, addresses, DOB, government IDs, device IDs, account IDs
- **Financial or payment data:** card data, bank details, invoices, payment status, billing addresses
- **Health, legal, employment, or other regulated records:** project-specific protected fields
- **Operational metadata:** IP addresses, user agents, correlation IDs, geolocation, tenant IDs

Record sensitivity, purpose, source, owner, allowed consumers, retention, and whether the data crosses trust boundaries.

### 2. Minimize And Protect

Require:

- Collect, store, transmit, and expose only fields needed for the stated purpose.
- Encrypt sensitive data in transit and at rest using project-approved controls.
- Enforce least-privilege access by role, tenant, environment, and purpose.
- Separate raw sensitive storage from derived, masked, or aggregated views.
- Avoid placing sensitive fields in URLs, query strings, cache keys, labels, metric dimensions, or object names.

### 3. Redact Operational Visibility

Logs, traces, metrics, alerts, dashboards, reports, and runbooks must avoid raw sensitive values.

Prefer safe metadata:

- request ID, run ID, file/event ID, schema version, reason code, hashed record ID, count, status, tenant-safe aggregate, and timestamp

Require redaction or masking for:

- tokens, cookies, authorization headers, secrets, names, emails, phone numbers, addresses, government IDs, payment fields, raw payloads, and free-text fields that may contain sensitive values

### 4. Use Synthetic Or De-Identified Test Data

Tests, fixtures, examples, demos, seed data, snapshots, screenshots, and generated docs must use:

- Synthetic data that never came from production, or
- De-identified data approved by the project's policy and verified to remove direct and indirect identifiers

Do not copy raw production payloads into tests, issue comments, docs, prompts, or local fixtures.

### 5. Add Audit And Retention Controls

Require audit events for sensitive actions:

- create, read/export, update, delete, permission change, token/secret access, admin override, replay/backfill, and bulk access

Audit records should include actor, action, target, timestamp, reason/purpose where available, source system, correlation ID, and outcome. They should not include raw sensitive values.

Define retention and deletion behavior for sensitive data, raw payloads, derived data, logs, audit records, quarantine, backups, and test artifacts.

### 6. Verify With Tests And Review Evidence

Require evidence for:

- Redaction/masking tests for logs, errors, traces, and reports
- Authorization tests for sensitive reads, exports, and mutations
- Synthetic/de-identified fixture review
- Audit event tests for high-risk actions
- Retention/deletion behavior or documented operational controls

## Output

Return:

1. **Data classification** - fields, sensitivity, purpose, owner, and trust boundary
2. **Risk verdict** - low, medium, or high, with rationale
3. **Required controls** - minimization, access, encryption, redaction, test data, audit, retention
4. **Unsafe exposures** - logs, fixtures, docs, exports, URLs, metrics, or reports that need correction
5. **Verification plan** - tests and review evidence required before merge

## Guardrails

- **Never approve raw sensitive data in logs, metrics, traces, reports, docs, examples, or fixtures.**
- **Never use production data as test data** unless the project has an explicit approved de-identification process and evidence.
- **Classify before designing controls.** If classification is unknown, pause and identify the data owner or policy.
- **Audit high-risk access and mutation.** Sensitive export, deletion, permission, replay, or bulk operations need audit evidence.
- **Prefer purpose limitation.** Do not retain or expose sensitive fields just because they are available.
- **Avoid compliance theater.** Name concrete controls, tests, and owners rather than vague compliance claims.

## See Also

- **`security-baseline`** - Universal security expectations for secrets, auth, input handling, and safe errors.
- **`interoperability-contracts`** - Contract changes that carry sensitive fields or external consumer obligations.
- **`data-ingestion`** - Feed landing, quarantine, replay, and reconciliation guidance for sensitive payloads.
- **`testing`** - Synthetic data, redaction, audit, authorization, and retention test guidance.
- **`team-workflow`** - Engineering Flow dispatches this skill for regulated-data-sensitive changes.
