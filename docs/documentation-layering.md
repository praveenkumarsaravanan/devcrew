# Documentation Layering

How DevCrew docs are organized so we **write once and link often**. Applies to every topic — FHIR, triage, data platform, contracts, release, and new primitives.

Based on the same principles as the `documentation` skill: one fact, one place; audience first; link don't copy.

## The four layers

| Layer | Location | Audience | What belongs here |
|-------|----------|----------|-------------------|
| **1. Entry** | `README.md` | New visitors, installers | What DevCrew is, quick start, install, **links** — not full catalogs |
| **2. Catalog** | `docs/devcrew-index.md` | Anyone finding a primitive | Counts, inventory tables, one-line purpose per skill/agent/prompt — **no workflow prose** |
| **3. Topic guide** | `docs/<topic>.md` | Users choosing the right tool | When-to-use tables, setup-once vs refresh, rule of thumb, links to primitives |
| **4. Agent source** | `.apm/skills/`, `.apm/prompts/`, `.apm/agents/` | AI at runtime | Hard rules, workflows, checklists — **not** user onboarding essays |

**Compiled output** (`.agents/`, `AGENTS.md`, global Cursor commands) is generated — never edit for documentation; change `.apm/` and recompile.

## Topic guides (layer 3)

Use a dedicated `docs/<topic>.md` when a domain has:

- Multiple primitives (skill + prompt + script)
- Confusable entry points (e.g. skill name vs slash command)
- One-time setup vs day-to-day use

| Topic guide | Covers |
|-------------|--------|
| [engineering-flow.md](./engineering-flow.md) | `/engineering-flow`, phases, council, post-merge prompts |
| [triage.md](./triage.md) | `/triage` vs `/incident-response` vs `debugging`, `triage-setup` |
| [fhir-health-interop.md](./fhir-health-interop.md) | `fhir-health-interop` vs `/fhir-review`, IG bundle setup |
| [data-platform-workflow.md](./data-platform-workflow.md) | Feeds, mapping, replay, data prompts |
| [typescript-node-aws-workflow.md](./typescript-node-aws-workflow.md) | Node + AWS standards and review path |
| [council-model.md](./council-model.md) | Planning-only council |
| [generic-platform-support.md](./generic-platform-support.md) | Cross-cutting platform capabilities |

**Add** a new topic guide when you introduce a domain with routing ambiguity. **Do not** paste its tables into README or the index.

## What each file should contain

### README.md

| Add | Remove / avoid |
|-----|----------------|
| Install, global setup, 2–3 flagship commands | Full skill/agent/prompt tables (use index link) |
| Links to index + topic guides + this doc | Workflow steps duplicated from `engineering-flow.md` |
| One-line pointers for special domains (FHIR, triage) | “Rule of thumb” tables copied from topic guides |

### docs/devcrew-index.md

| Add | Remove / avoid |
|-----|----------------|
| At-a-glance counts | Long how-to prose |
| Per-primitive **one-line** purpose in index tables | Duplicate when-to-use tables from topic guides |
| **Inventory** block per domain (Piece \| Name \| Purpose) + link to topic guide | Same routing table in index and engineering-flow and README |

### docs/engineering-flow.md

| Add | Remove / avoid |
|-----|----------------|
| Engineering Flow phases, council, handoffs | Full domain guides (data, FHIR, triage details) |
| Post-merge prompt **list** (names only) | Step-by-step triage or FHIR setup |
| **One line + link** per special domain | Duplicate topic-guide tables |

### docs/<topic>.md

| Add | Remove / avoid |
|-----|----------------|
| When-to-use routing table | Agent hard rules (stay in skill) |
| Setup once / refresh policy for scripts | Full primitive catalog |
| Pointers to `.apm/` source paths | Copy of index inventory tables |

### .apm/skills/<name>/SKILL.md

| Add | Remove / avoid |
|-----|----------------|
| Triggers, hard rules, workflow, output format | User-facing onboarding tables |
| Compact skill-vs-prompt note if needed for agents | Link to `docs/<topic>.md` for routing (one line OK) |
| `references/` for technical detail | Duplicate of topic guide |

### .apm/prompts/<name>.prompt.md

| Add | Remove / avoid |
|-----|----------------|
| Steps and output for **this command only** | Domain routing prose (belongs in topic guide) |
| One-line “activates skill X” | Repeated “when to use” tables |

### .apm/prompts/quickstart.prompt.md

| Add | Remove / avoid |
|-----|----------------|
| Single row per action in **one** table section | Same rows in Project Lifecycle **and** Specialized Skills |
| Link or “see docs/…” for complex domains | Full domain guides inlined |

## Decision tree: where does new content go?

```
Is it for humans choosing a command/skill?
  └─ Yes → Is the domain complex (multiple primitives, easy to confuse)?
        └─ Yes → docs/<topic>.md (or extend an existing topic guide)
        └─ No  → One row in devcrew-index + optional quickstart row
  └─ No  → Is it how the AI should behave?
        └─ Yes → .apm/skills/ or .apm/prompts/ or .apm/agents/
        └─ No  → Is it install/repo onboarding?
              └─ Yes → README.md (brief) + link
```

## Common duplication traps in this repo

| Trap | Canonical location | Usually remove from |
|------|-------------------|---------------------|
| Full primitive catalog | `docs/devcrew-index.md` | README mega-table, duplicate index sections |
| Engineering Flow phases | `docs/engineering-flow.md` | README, quickstart long form |
| Triage vs incident vs debugging | `docs/triage.md` | index prose, engineering-flow tables |
| FHIR build vs review | `docs/fhir-health-interop.md` | README, index, engineering-flow |
| Data feed design expectations | `docs/data-platform-workflow.md` | index, team-workflow prose |
| Node/AWS implementation rules | `typescript-node-aws-workflow.md` + skills | README, index |
| Skill vs prompt same name (`triage`, `release-evidence`) | `devcrew-index.md` note + post-install behavior | Duplicate slash commands |
| Technical reference (HL7 packages, team package tiers) | `references/` under skill | Topic guides, README |

## When updating docs

1. **Edit the canonical layer first** (topic guide or skill — never README first).
2. **Search** for the old phrase across `docs/`, `README.md`, `.apm/prompts/`:
   ```sh
   rg -l "phrase" docs README.md .apm/prompts
   ```
3. **Replace duplicates with links** — do not copy the new paragraph elsewhere.
4. **Run** `apm compile` if `.apm/` changed.

## Checklist before merging doc changes

- [ ] Every new fact appears in **one** canonical file
- [ ] README does not grow a new full table if index already lists it
- [ ] Topic guide exists OR index has only inventory + link
- [ ] `engineering-flow.md` uses one-line pointers for domains
- [ ] Prompts contain steps only, not routing essays
- [ ] `quickstart` has no duplicate rows across sections
- [ ] Related Documentation / See also links updated

## See also

- `documentation` skill — general writing principles
- [DevCrew Index](./devcrew-index.md) — authoritative primitive catalog
- [Engineering Flow](./engineering-flow.md) — main workflow entry
