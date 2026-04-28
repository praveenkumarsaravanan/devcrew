---
id: SO-009
dimension: skill-output
skill: documentation
name: Generate README for a new service
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-009: Generate README for a New Service

## Task

> Write a README for the order-service project. It's a Java 21 Spring Boot 3.3
> REST API that manages orders. It uses PostgreSQL for persistence, Redis for
> caching, and Kafka for event publishing. It's deployed on Kubernetes via Helm.
> The team uses Maven, JUnit 5, and Testcontainers.

Activate the `documentation` skill.

## Expected Behavior

1. Title and one-line description.
2. Prerequisites section (Java 21, Maven, Docker for Testcontainers).
3. Quick start / Getting started section with build + run commands.
4. Architecture overview (at least mentions PostgreSQL, Redis, Kafka).
5. API documentation or link to OpenAPI spec.
6. Testing section with commands to run tests.
7. Deployment section (Kubernetes, Helm).
8. Contributing section or link to team conventions.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Has title + description | 10% | Present and accurate |
| Has prerequisites | 10% | Lists Java, Maven, Docker minimum |
| Has getting started with runnable commands | 20% | Commands that would actually work |
| Has architecture/tech stack overview | 20% | Mentions all 3 external systems |
| Has testing section | 15% | Includes test commands |
| Has deployment section | 15% | Mentions K8s/Helm |
| Well-structured (scannable, not a wall of text) | 10% | Uses headings, code blocks, lists |

**Critical failure:** Produces a generic template with no project-specific content.
