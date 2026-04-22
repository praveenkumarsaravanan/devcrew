# Architecture Decision Record

Create an ADR documenting an architecture or design decision. Follow the Nygard format.

Structure the ADR as:

## Title

Short noun phrase: "Use cursor-based pagination for list endpoints"

## Status

One of: **Proposed** | **Accepted** | **Deprecated** | **Superseded by [ADR-XXX]**

## Context

What is the situation that motivates this decision? Include:
- The problem or requirement driving the decision.
- Constraints (technical, organizational, timeline, cost).
- Relevant prior decisions or existing patterns.

## Decision

State the decision clearly and concisely. Start with "We will..." Include:
- The chosen approach.
- Key trade-offs accepted.
- What alternatives were considered and why they were rejected.

## Consequences

What becomes easier or harder as a result of this decision? Include:
- **Positive**: benefits, simplifications, capabilities gained.
- **Negative**: costs, limitations, complexity introduced.
- **Risks**: what could go wrong and how to mitigate.

---

Save the ADR as `docs/adr/NNNN-<title-slug>.md` (create the directory if it doesn't exist). Number sequentially from existing ADRs in the directory.
