# Monitoring Plan

Design the observability and monitoring strategy for a service or a recent change. Adopt the **SRE** perspective.

1. **Observability coverage** — Verify the three pillars are instrumented:
   - **Metrics**: request count, latency (p50/p95/p99), error rate, inflight requests, dependency latency, DB query duration, connection pool size.
   - **Logs**: structured JSON with traceId, appropriate levels (DEBUG/INFO/WARN/ERROR), no secrets or PII.
   - **Traces**: W3C trace context propagated across service boundaries, spans for HTTP calls, DB queries, cache ops, and queue operations.

2. **SLOs and SLIs** — Propose service-level objectives:
   - Availability target (e.g., 99.9% non-5xx responses, 30-day rolling).
   - Latency target (e.g., p99 < 500ms, 30-day rolling).
   - Error budget: how much downtime the target allows, and what happens when it is depleted.

3. **Alerting** — Define alerts with four tiers:
   - P1 (page immediately): service down, error rate > 5%.
   - P2 (respond within 1h): latency > 2x baseline.
   - P3 (respond within 4h): error budget burn rate elevated.
   - P4 (next business day): disk > 80%, cert expiring.
   - Every alert must have a runbook link. No alert without an action.

4. **Customer impact** — Which user flows are affected, blast radius, and degraded-mode options.

5. **Incident readiness** — Can the team detect, diagnose, and recover within the error budget? Identify gaps.

Flag anti-patterns: alerts without runbooks, static thresholds instead of burn-rate, alerting on causes instead of symptoms, and alert fatigue.
