---
name: regulated-data-baseline
description: Always-on regulated and sensitive data checks for classification, masking, synthetic test data, audit, and retention
applyTo: "**/{api,apis,api-design,contracts,webhooks,schemas,regulated,regulated-data,regulated-data-handling,sensitive,privacy,pii,phi,payment,payments,billing,compliance}/**/*.{ts,tsx,js,jsx,py,java,go,sql,yml,yaml,json,xml,proto,avsc,md}"
---

# Regulated Data Baseline

Apply these rules when code, docs, tests, contracts, schemas, APIs, webhooks, reports, fixtures, or runbooks handle sensitive or regulated data.

## Required Checks

- Classify sensitive fields before designing storage, transport, logs, reports, tests, exports, or retention.
- Minimize collection and exposure to fields required for the stated purpose.
- Enforce least-privilege access for sensitive reads, exports, mutations, admin actions, and operational tooling.
- Encrypt sensitive data in transit and at rest using project-approved controls.
- Do not put sensitive values in URLs, query strings, object names, cache keys, metric labels, or log dimensions.
- Redact or mask secrets, tokens, authorization headers, cookies, PII, PHI, payment data, raw payloads, and free-text sensitive fields in logs, traces, errors, dashboards, reports, and runbooks.
- Use synthetic or approved de-identified data in tests, fixtures, examples, demos, screenshots, prompts, and docs.
- Emit audit events for sensitive create/read/export/update/delete, permission changes, token/secret access, admin overrides, replay/backfill, and bulk access.
- Define retention and deletion behavior for raw data, derived data, quarantine, logs, audit records, backups, and test artifacts.
- Verify redaction, authorization, audit, and synthetic/de-identified data expectations with tests or review evidence.

## Do Not Allow

- Raw sensitive data in logs, traces, metrics, dashboards, reports, docs, examples, prompts, or fixtures.
- Production data copied into tests or local fixtures without documented de-identification approval.
- Sensitive exports, deletion, permission changes, replay/backfill, or bulk access with no audit event.
- Contract or schema changes that add sensitive fields without classification, access controls, redaction rules, and retention notes.
- Error responses that expose secrets, raw payloads, stack traces, or sensitive validation details.
