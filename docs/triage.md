# Production Issue Triage

Evidence-gated first-pass investigation for production defects. Output is a **hypothesis for human review — never a verdict.**

## When to use what

| You want to… | Use | How |
|--------------|-----|-----|
| First-pass root-cause **hypothesis** on a production defect | `triage` skill / `/triage` | Evidence-backed triage card; mirror + worktree, artifact-first reads |
| Severity, escalation, comms during an **active incident** | `/incident-response` | Not the same as triage — operational response |
| After fix: verify fix, score hypothesis, find sibling bugs | `/postmortem` | Close the loop on a fixed incident |
| Dev/staging bug (not production incident) | `debugging` skill | No production mirror/worktree discipline required |
| Full feature / fix through Engineering Flow | `/engineering-flow` | Separate from triage workflow |

**Rule of thumb:** production defect hypothesis → **`triage`** / **`/triage`**. Active incident ops → **`/incident-response`**. Local repro → **`debugging`**.

## Skill vs `/triage` prompt

| | `triage` (skill) | `/triage` (prompt) |
|---|------------------|-------------------|
| **Type** | Skill — full investigation discipline | Slash command — entry point for the same workflow |
| **Note** | When skill and prompt share a name, post-install deploys **skill only** to avoid duplicate Cursor commands | Use `/triage` in palette when available; otherwise invoke the skill |

## Workspace setup (per project)

```sh
apm run triage-setup [dir]
```

Scaffolds `triage-mirrors/`, `triage-runs/`, and incident knowledge base. Run when onboarding a repo to triage — not on every incident.

## Primitives

| Piece | Location |
|-------|----------|
| Skill | `.apm/skills/triage/SKILL.md` |
| Prompts | `.apm/prompts/triage.prompt.md`, `postmortem.prompt.md` |
| Script | `scripts/triage-setup.sh` |
| Eval | `evals/scenarios/triage/tri-001-data-lifecycle.md` |

## See also

- [Documentation layering](./documentation-layering.md) — where to put triage content without duplicating
- [Engineering Flow](./engineering-flow.md) — post-merge / ops prompt list
- [DevCrew Index](./devcrew-index.md) — full catalog
