# Contract Review

Review an external or cross-team contract change for compatibility, versioning, consumer impact, tests, and regulated-data exposure.

## Steps

1. Activate `interoperability-contracts`.
2. Classify the contract type: OpenAPI, AsyncAPI, webhook, event, gRPC/protobuf, GraphQL, file/feed, SDK, or partner contract.
3. Identify producer, consumers, owner, current version, proposed version, support window, and rollout deadline.
4. Check compatibility: removed or renamed fields, changed types, requiredness, nullability, units, semantics, auth, retries, error codes, schedule, delivery guarantees, or file shape.
5. Define versioning and deprecation requirements for any breaking or high-risk change.
6. Require schemas, representative examples, provider/consumer/compatibility tests, and release or migration evidence.
7. If sensitive data is present, activate `regulated-data-handling` and require classification, masking/redaction, synthetic fixtures, audit events, and retention notes.
8. Define observability for validation failures, deprecated-version traffic, webhook retries, event drops, file rejects, consumer lag, and support escalation.

## Output

Return contract summary, compatibility verdict, findings by severity, required tests, consumer migration plan, regulated-data controls if applicable, and approval recommendation.
