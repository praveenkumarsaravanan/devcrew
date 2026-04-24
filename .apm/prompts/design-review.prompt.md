---
name: design-review
description: Design review for scalability, reliability, and cost
---

# Design Review

Review the proposed design for:

1. **Scalability** -- Will this handle 10x current load? What are the bottlenecks?
2. **Reliability** -- What happens when dependencies fail? Are there single points of failure?
3. **Data consistency** -- Are there race conditions? How is eventual consistency handled?
4. **API surface** -- Is the interface minimal and hard to misuse?
5. **Operational readiness** -- How will this be monitored? What alerts are needed? What is the rollback plan?
6. **Cost** -- What are the infrastructure cost implications at current and projected scale?

Provide concrete, specific recommendations. Cite specific components or flows when identifying issues.
