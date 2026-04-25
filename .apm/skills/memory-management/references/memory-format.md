# `.memory.md` — Canonical Format

This file lives at the **project root** and accumulates learnings across development sessions — architecture decisions, patterns, anti-patterns, and lessons. It is committed to version control so the entire team (and future AI sessions) benefit from past experience.

## Tiered Memory Structure

Memory is organized in three tiers to stay within context window limits:

```
.memory.md                          ← Tier 1: Active (capped at ~150 lines)
.memory/                            ← Tier 2: Domain overflow
├── architecture.md
├── auth-security.md
├── data-handling.md
├── performance.md
├── testing.md
├── deployment.md
├── api-design.md
├── ui-patterns.md
├── general.md
└── archive/                        ← Tier 3: Quarterly archives
    ├── 2026-Q1.md
    └── 2026-Q2.md
```

| Tier | Path | Max size | Loaded when |
|------|------|---------|------------|
| 1 | `.memory.md` | ~150 lines / ~15 KB | Every Phase 0 (3 sections max) |
| 2 | `.memory/<domain>.md` | ~25 KB each | Task needs deep domain history |
| 3 | `.memory/archive/*.md` | Unlimited | Explicit user request only |

## Domain Sections

Organize entries under H2 headings by domain. These are the standard domains and their corresponding overflow filenames:

| Domain heading | Overflow file | Keywords that trigger loading |
|---------------|--------------|------------------------------|
| `## Architecture Decisions` | `architecture.md` | Always loaded |
| `## Auth & Security` | `auth-security.md` | auth, login, security, token, password, oauth, permission |
| `## Data Handling` | `data-handling.md` | database, migration, cache, query, schema, data |
| `## Performance` | `performance.md` | performance, latency, optimization, profiling, slow |
| `## Testing` | `testing.md` | test, coverage, flaky, mock, fixture, assertion |
| `## Deployment` | `deployment.md` | deploy, CI, CD, pipeline, rollback, kubernetes, docker |
| `## API Design` | `api-design.md` | endpoint, API, REST, gRPC, contract, versioning |
| `## UI Patterns` | `ui-patterns.md` | component, accessibility, responsive, state, UI, CSS |
| `## General` | `general.md` | (fallback for unmatched entries) |

## Entry Format

Each entry within a domain section uses this structure:

```markdown
### [YYYY-MM-DD] — [Brief Summary]
**Domain:** [domain-tag]
**Context:** [What was happening when this was learned]
**Learning:** [The actual insight or decision]
**Rationale:** [Why this decision was made or why this pattern works]
```

## Rotation Mechanics

When `.memory.md` exceeds ~150 lines:

1. For each domain section with more than 20 entries, keep the **10 most recent** in `.memory.md`.
2. Move older entries to `.memory/<domain>.md`, preserving entry format and chronological order.
3. Add a rotation marker at the bottom of the domain section in `.memory.md`:
   ```markdown
   <!-- older entries in .memory/<domain>.md -->
   ```
4. The overflow file has the same entry format but opens with a brief header:
   ```markdown
   # [Domain Name] — Overflow Memory
   
   Older entries rotated from `.memory.md`. Loaded on demand when a task
   requires deep history for this domain.
   
   ## Entries
   
   ### [YYYY-MM-DD] — [Brief Summary]
   ...
   ```

## Quarterly Archival

During Operation 5 (organize), entries older than 6 months move from Tier 2 overflow files to `.memory/archive/<quarter>.md`:

```markdown
# Memory Archive — 2026 Q1

Archived entries from January–March 2026. These entries have aged out of
active and overflow memory. Loaded only on explicit request.

## Architecture Decisions

### 2026-01-15 — Chose PostgreSQL over MongoDB for order data
...

## Testing

### 2026-02-08 — Adopted contract testing for service boundaries
...
```

## Example: `.memory.md` After Rotation

```markdown
# Project Memory

Accumulated learnings across development sessions. Entries are appended
automatically after each `team-workflow` completion and can be added
manually at any time.

## Architecture Decisions

### 2026-04-20 — Extracted notification service from monolith
**Domain:** architecture
**Context:** Notification logic was coupled to the order service, causing deployment bottlenecks.
**Learning:** Extracted to a standalone service communicating via Kafka events.
**Rationale:** Independent deployment cadence; notifications don't block order processing.

### 2026-04-10 — Adopted CQRS for reporting queries
**Domain:** architecture
**Context:** Complex reporting queries were slowing down the transactional database.
**Learning:** Read models in a separate PostgreSQL replica, updated via CDC.
**Rationale:** Transactional writes stay fast; reporting queries use optimized read schemas.

<!-- older entries in .memory/architecture.md -->

## Testing

### 2026-04-18 — Playwright over Cypress for e2e tests
**Domain:** testing
**Context:** Cypress struggled with multi-tab flows and iframe-heavy third-party widgets.
**Learning:** Migrated e2e suite to Playwright. Parallel execution cut CI time by 40%.
**Rationale:** Better cross-browser support, native multi-tab handling, faster execution.

## Deployment

<!-- No entries yet -->

## General

<!-- No entries yet -->
```

## Progressive Loading Rules

When reading memory at Phase 0:

1. **Always load** the Architecture Decisions section from `.memory.md` (universally relevant).
2. **Match by task keywords** to select up to 2 additional domain sections from `.memory.md`.
3. **Cap at 3 sections** from Tier 1 to stay within the context budget.
4. **Dip into Tier 2** only if a matched section has a rotation marker AND the task description suggests deep domain history is needed (e.g., "we tried this before" or "what was the previous approach").
5. **Never auto-load Tier 3.** Archives are only read during Operation 5 or explicit user requests.

## File Lifecycle

1. **Created** by `scripts/init-memory.sh` during `apm install` (empty template with section headers and `.memory/` directory).
2. **Appended** by the agent after each `team-workflow` completion (Operation 4).
3. **Rotated** automatically when `.memory.md` exceeds the size budget (Operation 4, step 5).
4. **Archived** quarterly during Operation 5 (organize) — entries older than 6 months move to `.memory/archive/`.
5. **Never deleted** without explicit user confirmation.
