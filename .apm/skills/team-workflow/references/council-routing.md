# Council Routing Reference

This reference defines how DevCrew Engineering Flow maps task size and risk to councils. It is a coordination layer over the existing phases and agents, not a replacement for them.

## Council Depth

| Depth | Default trigger | Behavior |
|---|---|---|
| `light` | Quick fixes | One-line Chair note. No formal decision artifact unless risk escalates. |
| `standard` | Standard changes and most full features | Council Brief plus compact decision notes at major gates. |
| `deep` | Explicit request, high risk, ambiguity, or architecture-heavy work | Options, trade-off matrix, recommendation, and user checkpoint before implementation. |

## Default Depth Rules

```text
quick-fix -> light
standard-change -> standard
full-feature -> standard
full-feature + medium/high risk -> deep or strongly suggest deep
explicit --deep/deep council request -> deep
```

## Deep Mode Signals

Activate or strongly recommend deep mode when any signal is present:

- New service boundary, architecture pattern, API surface, or data model.
- Security, auth, encryption, PII, payments, deletion, or regulated data.
- Data migration, replay, backfill, retention, or irreversible data change.
- Infrastructure, IAM, networking, deployment, rollback, or cost risk.
- Ambiguous requirements, conflicting constraints, or low confidence classification.
- User explicitly asks for trade-offs, options, or council review before implementation.

Avoid deep mode for typos, copy changes, config formatting, simple tests, localized bug fixes, and small docs updates.

## Council Map

| Council | Runs by default when | Existing agent or primitive |
|---|---|---|
| Product Council | Standard/full work with requirements uncertainty | `product-analyst` |
| Architecture Council | Full features or deep mode design decisions | `architect` |
| Implementation Council | All implementation work | `junior-developer`, `senior-developer` |
| Review Council | Quick-fix lightweight review; standard/full adversarial review | `backend-reviewer`, `frontend-reviewer` |
| Quality Council | Standard/full test verification; full-feature test strategy | `qa-lead`, `test-engineer` |
| Delivery Council | Explicit release/deployment readiness work | `release-manager`, `devops-engineer` |
| Operations Council | Explicit runtime/SLO/monitoring work | `sre` |
| Governance Council | Medium/high risk or safety-sensitive work | `governance.instructions.md`, `security-baseline.instructions.md` |

## Council Brief

For standard/full work, open with:

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

For quick fixes, compress to:

```text
Chair note: [quick-fix], [risk], [next phase], [why no formal council artifact].
```

## Decision Artifact

Use the full artifact only for meaningful choices:

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

## Deep Mode Output

Deep mode must produce:

1. Two or three viable options.
2. Trade-off matrix.
3. Recommended path.
4. Risks accepted and rejected.
5. User approval checkpoint.

After approval, continue the normal Engineering Flow phases. Do not let deep mode replace implementation, review, or QA.

