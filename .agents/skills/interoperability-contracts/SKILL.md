---
name: interoperability-contracts
description: >
  Design and review external or cross-team contracts across OpenAPI, AsyncAPI,
  webhooks, gRPC/protobuf, GraphQL, and file/feed formats. Use when changes must
  preserve compatibility, versioning, consumer expectations, and contract tests.
---

# Interoperability Contracts

## Trigger

Activate this skill when the user or diff mentions:

- OpenAPI, Swagger, AsyncAPI, gRPC/protobuf, GraphQL schemas, webhooks, events, SDK contracts, file contracts, feed contracts, or partner integrations
- FHIR REST APIs, CapabilityStatements, StructureDefinitions, Implementation Guides, SMART on FHIR, or HL7 cross-team exchange contracts
- Breaking changes, compatibility, versioning, deprecation, migration windows, or consumer rollout
- Contract tests, schema validation, provider/consumer verification, examples, or mock servers
- Cross-team or external system boundaries where another team depends on the shape or timing of data

Do NOT activate only because an internal helper function has a TypeScript type. This skill is for durable integration contracts, not ordinary local interfaces.

## Workflow

### 1. Classify the Contract

Identify the contract shape and owner:

- **Synchronous API:** OpenAPI, REST, gRPC/protobuf, GraphQL, FHIR REST (`CapabilityStatement`, profiles, search params)
- **Asynchronous API:** AsyncAPI, queue/event schema, pub/sub topic, webhook
- **File or feed:** CSV, JSON, XML, Avro, Parquet, fixed-width, batch delivery manifest
- **Consumer relationship:** public, partner, internal cross-team, or service-to-service
- **Ownership:** producer, consumers, approving owner, support channel, and escalation path

Record the current version, proposed version, release date, and compatibility promise.

### 2. Check Compatibility

Treat these as potentially breaking unless proven otherwise:

- Removing or renaming fields, endpoints, events, topics, enum values, files, columns, or headers
- Changing field type, format, units, nullability, requiredness, default, sort order, or semantic meaning
- Tightening validation for existing consumers
- Changing authentication, authorization, rate limits, idempotency keys, retry semantics, delivery guarantees, or error codes
- Changing webhook/event ordering, deduplication identifiers, replay behavior, or acknowledgement rules
- Changing file delimiter, encoding, compression, partitioning, naming, delivery schedule, retention, or checksum rules

Additive changes are usually safe only when they are optional, documented, tested, and ignored safely by existing consumers.

### 3. Define Versioning And Deprecation

For every breaking or high-risk change:

- Introduce a new version or parallel contract path/topic/file shape.
- Publish a deprecation notice with affected consumers, migration steps, support window, and removal date.
- Keep old and new versions running long enough for consumers to migrate.
- Provide a rollback or compatibility toggle when rollout risk is material.
- Document how clients discover versions and supported capabilities.

Do not rely on "all consumers should update quickly" as a migration plan.

### 4. Specify Schemas And Examples

Every contract should include:

- Machine-readable schema where practical: OpenAPI, AsyncAPI, protobuf, GraphQL schema, JSON Schema, Avro, XML Schema, or tabular layout
- Human-readable behavior notes for semantics that schemas cannot express
- Request, response, event, webhook, and file examples for normal, edge, invalid, and historical cases
- Standard error, retry, timeout, idempotency, and correlation ID expectations
- Security requirements: authentication, authorization, signing, encryption, and rate limits
- Sensitive field classification and redaction expectations when applicable

### 5. Require Contract Tests

Choose tests that match the boundary:

- **Provider tests:** Verify implementation emits or accepts the documented schema.
- **Consumer tests:** Verify representative consumers can parse, ignore optional additions, and handle errors.
- **Compatibility tests:** Compare old and new specs for breaking changes.
- **Webhook/event tests:** Verify signing, idempotency, duplicate delivery, retries, ordering assumptions, and replay safety.
- **File/feed tests:** Verify delimiter, encoding, required columns, schema drift, invalid records, checksums, manifests, and historical versions.

Contract tests should run before merge for changed contracts and before release for externally visible changes.

### 6. Plan Rollout And Observability

Define:

- Consumer notification, migration owners, and deadline
- Staged rollout, canary, dual-write/dual-read, or parallel topic/path strategy
- Dashboards and alerts for request errors, contract validation failures, event drops, webhook retries, file rejects, consumer lag, and deprecated-version traffic
- Support runbook and escalation path

## Output

Return:

1. **Contract summary** - type, owner, producer, consumers, current/proposed versions
2. **Compatibility verdict** - compatible, additive with safeguards, or breaking
3. **Required changes** - schema, examples, tests, rollout, observability, and docs
4. **Consumer impact** - affected consumers and migration plan
5. **Open decisions** - items that need owner or user approval

## Guardrails

- **Never approve an undocumented breaking change.** Breaking changes need versioning, deprecation, consumer migration, and tests.
- **Do not make protocol examples the identity of the skill.** OpenAPI, AsyncAPI, webhooks, protobuf, and files are forms of interoperability contracts.
- **Always require examples.** Schemas without representative examples are incomplete.
- **Always check sensitive fields.** If the contract carries sensitive data, activate `regulated-data-handling`.
- **Prefer additive evolution.** Add optional fields or parallel versions before changing existing semantics.
- **Treat external contracts as high blast radius.** Public, partner, or production cross-team contracts need explicit review evidence.

## See Also

- **`api-design`** - REST and gRPC resource modeling, error formats, pagination, and OpenAPI structure.
- **`fhir-health-interop`** - FHIR REST, Implementation Guides, HL7 AI bundles (`ai.zip`), NPM validation, and SMART on FHIR.
- **`data-ingestion`** - Feed contracts, landing, validation, quarantine, idempotency, replay, and reconciliation.
- **`regulated-data-handling`** - Sensitive data classification, masking, synthetic data, audit, and retention.
- **`testing`** - Contract, compatibility, provider, consumer, webhook, event, and file/feed test guidance.
- **`team-workflow`** - Engineering Flow dispatches this skill for contract-sensitive changes.
