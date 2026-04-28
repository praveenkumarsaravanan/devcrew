---
id: SO-010
dimension: skill-output
skill: spec-templates
name: Generate a feature specification
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-010: Generate a Feature Specification

## Task

> Create a specification for a notification service that sends emails when orders
> ship. It should support email and SMS channels, allow users to set preferences,
> and integrate with the existing order-service via Kafka events.

Activate the `spec-templates` skill.

## Expected Behavior

1. Uses a structured spec format (not freeform prose).
2. Includes:
   - Problem statement / motivation
   - Requirements (numbered)
   - Acceptance criteria (testable)
   - Technical design (mentions Kafka consumer, channel abstraction)
   - Edge cases (failed delivery, invalid preferences, duplicate events)
   - Out of scope / deferred items
3. Requirements are specific enough to implement without ambiguity.
4. Technical design references integration points (Kafka topic, order-service events).

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Structured format with clear sections | 15% | Uses headings, not freeform paragraphs |
| Problem statement / motivation present | 10% | Explains why this is needed |
| Numbered requirements with acceptance criteria | 25% | ≥5 requirements, each with testable criteria |
| Technical design with integration points | 20% | Mentions Kafka, channels, preferences storage |
| Edge cases identified | 15% | ≥3 edge cases with handling strategy |
| Scope boundaries defined | 15% | Explicitly states what's in and what's deferred |

**Critical failure:** Produces implementation code instead of a specification.
