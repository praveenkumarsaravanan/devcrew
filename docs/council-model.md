# DevCrew Council Model

DevCrew Engineering Flow uses a council model to make the existing lifecycle easier to follow. The council model is a coordination layer over the current phases, agents, quality gates, handoffs, and memory behavior. It does not replace them.

```text
DevCrew Engineering Flow = lifecycle engine
Council Chair = visible coordinator
Councils = phase-aligned groups of existing agents and instructions
```

## Goals

- Explain why a task is classified as quick fix, standard change, or full feature.
- Explain which councils and agents are active.
- Keep quick fixes light.
- Surface trade-offs before expensive or risky work.
- Make user checkpoints explicit.
- Preserve specialist-agent ownership.

## Council Depth

| Depth | Default use | Behavior |
|---|---|---|
| `light` | Quick fixes | One-line Chair note. No formal council artifact. |
| `standard` | Standard changes and most full features | Concise Council Brief, active/skipped councils, compact decision notes. |
| `deep` | High-risk, ambiguous, or architecture-heavy work | Options, trade-off matrix, recommendation, and user checkpoint before implementation. |

## Council Mapping

| Council | Purpose | Existing agent or primitive |
|---|---|---|
| Product Council | Clarify scope and requirements | `product-analyst` |
| Architecture Council | Compare designs and trade-offs | `architect` |
| Implementation Council | Build following project patterns | `junior-developer`, `senior-developer` |
| Review Council | Challenge implementation quality | `backend-reviewer`, `frontend-reviewer` |
| Quality Council | Define and verify test coverage | `qa-lead`, `test-engineer` |
| Delivery Council | Plan release readiness when requested | `release-manager`, `devops-engineer` |
| Operations Council | Plan runtime reliability when requested | `sre` |
| Governance Council | Classify risk and autonomy | `governance.instructions.md`, `security-baseline.instructions.md` |

Delivery and Operations councils are optional post-merge or release-readiness concerns unless the current request explicitly includes deployment, runtime, rollback, or operational risk.

## Council Brief

Every standard or full Engineering Flow starts with a concise Council Brief:

```text
Task size:
Risk:
Council depth:
Active councils:
Skipped councils:
Rationale:
Trade-offs to watch:
User checkpoints:
Expected artifacts:
```

Quick fixes use a compressed Chair note instead of the full brief.

## Decision Artifact

Use the full artifact only when a meaningful decision is being made, especially in standard or deep mode:

```text
Question:
Options considered:
Trade-offs:
Decision:
Rationale:
Risks accepted:
Risks rejected:
User approval needed:
Required follow-ups:
Next council:
```

## Deep Mode

Deep mode activates when the task needs deliberation before implementation.

Manual triggers:

```text
/engineering-flow --deep ...
/engineering-flow deep: ...
Run deep council on this.
Convene the council before implementation.
```

Automatic signals:

- New service boundary, API surface, architecture pattern, or data model.
- Security, auth, encryption, PII, payments, deletion, or regulated data.
- Data migration, replay, backfill, or irreversible data change.
- Infrastructure, IAM, networking, deployment, or rollback risk.
- Ambiguous requirements or conflicting constraints.
- Low confidence project/task classification.

Deep mode inserts this before implementation:

```text
Generate 2-3 options
Council review of options
Trade-off matrix
Recommended path
User checkpoint
Continue normal Engineering Flow
```

## Anti-Overkill Rules

- Quick fix: one-line Chair note, no formal council artifact.
- Standard change: concise Council Brief and compact decision notes.
- Full/high-risk/ambiguous: deep council with options and trade-offs.
- Do not run Delivery or Operations councils automatically after normal pre-merge work.
- Do not use the Council Chair as the developer, reviewer, architect, or QA lead.
- Do not use councils to add ceremony when a phase is already skipped by right-sizing.

