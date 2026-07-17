# [FEATURE NAME] — Service Specification

## Problem Statement

[PLACEHOLDER: Describe the problem this service solves, who is affected, and why it is needed now.]

## Scope

| In scope | Out of scope |
|----------|--------------|
| [PLACEHOLDER] | [PLACEHOLDER] |

## Service Overview

| Field | Value |
|-------|-------|
| Service name | `[PLACEHOLDER]` |
| Responsibility | [PLACEHOLDER: One-sentence summary of what this service owns] |
| Bounded context | [PLACEHOLDER: e.g., "Billing", "Identity", "Notifications"] |
| Runtime | [PLACEHOLDER: e.g., "Long-running server", "Cron worker", "Event-driven processor"] |

## Interfaces

### Public API

| Method | Path / RPC | Description |
|--------|-----------|-------------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

### Events Published

| Event | Payload Summary | Topic / Queue | Consumers |
|-------|----------------|---------------|-----------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

### Events Consumed

| Event | Source | Topic / Queue | Handler |
|-------|--------|---------------|---------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Data Model

### Entities

| Entity | Fields (name : type) | Constraints |
|--------|---------------------|-------------|
| [PLACEHOLDER] | `id: UUID`, `name: string`, `created_at: timestamp` | [PLACEHOLDER: e.g., "name unique per tenant"] |

### Relationships

[PLACEHOLDER: Describe entity relationships — one-to-many, many-to-many, foreign keys.]

## Integration Points

| System | Protocol | Direction | Purpose |
|--------|----------|-----------|---------|
| [PLACEHOLDER: e.g., "Payment Gateway"] | REST / gRPC / AMQP | Inbound / Outbound | [PLACEHOLDER] |
| [PLACEHOLDER: e.g., "PostgreSQL"] | TCP | Outbound | Primary data store |
| [PLACEHOLDER: e.g., "Redis"] | TCP | Outbound | Cache / rate limiting |

## Error Handling Strategy

| Error Type | Handling | Retry Policy |
|------------|----------|--------------|
| Transient (network, timeout) | [PLACEHOLDER: e.g., "Retry with exponential backoff"] | [PLACEHOLDER: e.g., "3 retries, max 30s"] |
| Validation (bad input) | [PLACEHOLDER: e.g., "Return 400, log warning"] | No retry |
| Downstream failure | [PLACEHOLDER: e.g., "Circuit breaker, fallback response"] | [PLACEHOLDER] |
| Data corruption | [PLACEHOLDER: e.g., "Alert, halt processing, manual review"] | No retry |

## Scaling Considerations

| Dimension | Strategy |
|-----------|----------|
| Horizontal scaling | [PLACEHOLDER: e.g., "Stateless; scale via replicas behind load balancer"] |
| Throughput target | [PLACEHOLDER: e.g., "1,000 req/s at p99 < 200ms"] |
| Bottleneck | [PLACEHOLDER: e.g., "Database writes — mitigate with write-behind cache"] |
| Auto-scaling trigger | [PLACEHOLDER: e.g., "CPU > 70% for 5 minutes"] |

## Observability

### Logs

| Log Event | Level | Key Fields |
|-----------|-------|------------|
| [PLACEHOLDER: e.g., "Order processed"] | INFO | `order_id`, `user_id`, `duration_ms` |
| [PLACEHOLDER: e.g., "Payment failed"] | ERROR | `order_id`, `error_code`, `provider` |

### Metrics

| Metric | Type | Labels | Alert Threshold |
|--------|------|--------|-----------------|
| [PLACEHOLDER: e.g., `request_duration_seconds`] | Histogram | `method`, `status` | p99 > 500ms |
| [PLACEHOLDER: e.g., `queue_depth`] | Gauge | `queue_name` | > 10,000 |

### Traces

| Span | Parent | Key Attributes |
|------|--------|----------------|
| [PLACEHOLDER: e.g., "handle_request"] | — | `http.method`, `http.route` |
| [PLACEHOLDER: e.g., "db_query"] | `handle_request` | `db.statement`, `db.duration` |

## Requirements

| ID | Description | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| REQ-001 | [PLACEHOLDER] | [PLACEHOLDER] | Must |

## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Handoff Checklist

- [ ] Spec reviewed and approved
- [ ] Data model reviewed by data team
- [ ] Integration contracts agreed with upstream/downstream teams
- [ ] Observability requirements confirmed with SRE
- [ ] Open questions resolved
