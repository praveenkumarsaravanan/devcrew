---
name: memory-management
description: >
  Manages project-level persistence files — .project-context.md for platform
  configuration and .memory.md for accumulated learnings. Activated by Phase 0
  to load/persist project context, at end of team-workflow to capture learnings,
  or when the user asks to record or recall project knowledge.
---

# Memory Management

## Trigger

Activate this skill when:

- `project-detection` (Phase 0) needs to load stored project context or persist newly detected values.
- `team-workflow` completes and learnings should be captured.
- The user asks to "remember this," "record this decision," "what did we learn," or similar.
- Another skill needs to read or write project-level persistent state.

Do NOT activate for:

- Session-specific temporary notes — those belong in the conversation, not in persistent files.
- Documentation — use the `documentation` skill for READMEs and guides.

## Overview

Two files and a directory at the **project root** (not inside `.apm/` or DevCrew):

| Path | Purpose | Written when | Committed |
|------|---------|-------------|-----------|
| `.project-context.md` | Platform config, project identity, team conventions | First Phase 0 run or `/constitution` prompt | Yes — shared team config |
| `.memory.md` | Active curated memory — recent and high-value learnings | After each `team-workflow` completion | Yes — shared team knowledge |
| `.memory/<domain>.md` | Domain-specific overflow when a section outgrows the root file | Rotation during Operation 4 or 5 | Yes — shared team knowledge |
| `.memory/archive/<quarter>.md` | Quarterly archive of stale entries | Operation 5 (organize) | Yes — historical record |

These files implement PROSE's Context Helper Files and Agent Memory Files respectively. They follow Progressive Disclosure (loaded on-demand) and Explicit Hierarchy (project-level scope).

### Tiered memory architecture

Memory is organized in three tiers to stay within context window limits (~25 KB / ~200 lines per file):

```
.memory.md                          ← Tier 1: Active memory (capped at ~150 lines / ~15 KB)
.memory/                            ← Tier 2: Domain overflow + archives
├── architecture.md                 ← Overflow for Architecture Decisions
├── auth-security.md                ← Overflow for Auth & Security
├── data-handling.md                ← Overflow for Data Handling
├── performance.md                  ← Overflow for Performance
├── testing.md                      ← Overflow for Testing
├── deployment.md                   ← Overflow for Deployment
├── api-design.md                   ← Overflow for API Design
├── ui-patterns.md                  ← Overflow for UI Patterns
├── general.md                      ← Overflow for General
└── archive/                        ← Tier 3: Quarterly archives
    ├── 2026-Q1.md
    └── 2026-Q2.md
```

**Tier 1 (`.memory.md`)** — The active file loaded at Phase 0. Contains the most recent and most valuable entries per domain. Capped at ~150 lines. This is the only file the agent reads by default.

**Tier 2 (`.memory/<domain>.md`)** — When a domain section in `.memory.md` exceeds 20 entries, older entries rotate here. The agent reads these only when a task specifically matches the domain and the root file's entries are insufficient.

**Tier 3 (`.memory/archive/`)** — Quarterly snapshots of entries older than 6 months. Rarely loaded — only during explicit history review or Operation 5 (organize).

### Size budget

| Tier | Max size | Max entries | Loaded when |
|------|---------|------------|------------|
| `.memory.md` | ~15 KB / ~150 lines | ~20 per domain, ~60 total | Every Phase 0 (progressive: 3 sections max) |
| `.memory/<domain>.md` | ~25 KB each | Unlimited | Task matches domain and root file insufficient |
| `.memory/archive/*.md` | Unlimited | Unlimited | Explicit user request only |

### Hybrid bootstrap

These files can be created in two ways:

1. **Script-based (deterministic):** `scripts/init-context.sh` and `scripts/init-memory.sh` create minimal template files with interactive terminal prompts. These run automatically during `apm install` (via `scripts.setup`) or can be invoked manually. This ensures files exist even without an AI agent.
2. **Agent-driven (intelligent):** On the first `team-workflow` run, the agent detects existing files and **enriches** them — filling in architecture overviews, technology decision rationale, and other context that only a conversational agent can gather. If no files exist, the agent creates them from scratch.

The scripts handle creation; the agent handles intelligence. Both paths produce the same file format.

## Workflow

### Operation 1: Read Context

**When:** Phase 0 of `team-workflow` or any skill that needs project configuration.

1. Check for `.project-context.md` at the project root.
2. If found, parse the YAML-like frontmatter section for structured values:
   - `project-name`, `discipline`, `stack`, `tracker`, `tracker-project-key`, `execution`, `git-platform`, `migration-mode`
3. Return the parsed values to the calling skill.
4. If not found, return `null` — the calling skill should proceed with fresh detection.

### Operation 2: Write Context

**When:** After Phase 0 detection completes for the first time, or when `/constitution` runs.

1. Receive the detected/collected values from the calling skill.
2. Check if `.project-context.md` already exists:
   - If yes (likely created by `scripts/init-context.sh`), read the existing file. Merge new values with existing values — new values take precedence for structured fields. **Enrich** the free-form sections (Architecture Overview, Technology Decisions, Team Conventions) with detail gathered from the conversation while preserving any manually-added content.
   - If no, create the file from the template in `references/context-format.md`.
3. Write the file at the project root.
4. Inform the user: "Project context saved to `.project-context.md`. Future runs will use these settings."

### Operation 3: Read Memory

**When:** During Phase 0, to load relevant past learnings as context for the current task.

**Tiered loading strategy:**

1. **Tier 1 — always check first.** Read `.memory.md` at the project root.
2. If found, load only the sections relevant to the current task domain (progressive disclosure):
   - Match domain sections by keywords in the task description.
   - Always load the "Architecture Decisions" section (universally relevant).
   - Load at most 3 domain sections to avoid context bloat.
3. **Tier 2 — load on demand.** If a matched domain section in `.memory.md` contains a rotation marker (`<!-- older entries in .memory/<domain>.md -->`), and the task requires deeper history for that domain, also read the corresponding `.memory/<domain>.md` file. Cap at 20 entries from the overflow file.
4. **Tier 3 — never auto-load.** Archive files in `.memory/archive/` are only read during Operation 5 (organize) or when the user explicitly asks to review historical memory.
5. If `.memory.md` is not found, return empty — no prior learnings exist.

### Operation 4: Write Memory

**When:** After `team-workflow` completes (all phases done or user stops).

1. Extract learnings from the final handoff artifact:
   - Architecture decisions made and their rationale
   - Patterns that worked well
   - Anti-patterns discovered
   - Lessons learned (what would we do differently?)
2. Determine the domain section(s) this belongs to (e.g., `architecture`, `auth-security`, `data-handling`, `performance`, `testing`, `deployment`, `api-design`, `ui-patterns`, `general`).
3. Check if `.memory.md` exists:
   - If yes, append entries under the appropriate domain section(s). Create new sections if the domain doesn't exist yet.
   - If no, create the file from the template in `references/memory-format.md`, then add the entries.
4. Each entry includes a timestamp, brief summary, and the relevant details (see entry format in `references/memory-format.md`).
5. **Rotation check — run after every append:**
   - Count the entries (H3 headings) in `.memory.md`.
   - If the **total file exceeds ~150 lines or ~15 KB**, trigger rotation:
     a. For each domain section that has more than 20 entries, identify the oldest entries beyond the 10 most recent.
     b. Move those older entries to `.memory/<domain>.md` (create the file if it doesn't exist, using the domain overflow template from `references/memory-format.md`).
     c. Leave a rotation marker at the bottom of the domain section in `.memory.md`:
        `<!-- older entries in .memory/<domain>.md -->`
     d. Ensure `.memory/` directory exists (the bootstrap script creates it, but handle the case where it doesn't).
   - If the file is under the threshold, skip rotation.
6. Inform the user: "Learnings captured in `.memory.md` under [domain section(s)]." If rotation occurred, add: "Older entries rotated to `.memory/<domain>.md` to keep the active file within context limits."

### Operation 5: Organize Memory

**When:** The user asks to clean up, reorganize, or review project memory. Also recommended quarterly.

**Step 1 — Assess current state:**
1. Read `.memory.md` and report: total entries, entries per domain, file size.
2. Scan `.memory/` directory for overflow files and report their sizes.
3. Scan `.memory/archive/` for existing archives.
4. Present the assessment to the user.

**Step 2 — Deduplicate:**
1. Within each domain (across both `.memory.md` and `.memory/<domain>.md`), identify entries that capture the same learning.
2. Merge duplicates: keep the most detailed version, note the dates of all occurrences.
3. Present deduplication candidates to the user for confirmation before merging.

**Step 3 — Rotate oversized sections:**
1. For each domain section in `.memory.md` with more than 20 entries, move the oldest entries (beyond the 10 most recent) to `.memory/<domain>.md`.
2. Leave a rotation marker in `.memory.md`.

**Step 4 — Archive stale entries:**
1. In each `.memory/<domain>.md` overflow file, identify entries older than 6 months.
2. Move them to `.memory/archive/<current-quarter>.md` (e.g., `2026-Q2.md`).
3. Preserve the entry format and domain headings within the archive file.
4. If an archive file for the current quarter already exists, append to it.

**Step 5 — Validate and report:**
1. Ensure all entries are under the correct domain section.
2. Verify `.memory.md` is under the 150-line / 15 KB threshold.
3. Present a summary:
   - Entries deduplicated: N
   - Entries rotated to overflow: N
   - Entries archived: N
   - Current `.memory.md` size: X lines / Y KB
   - Domains with overflow files: [list]

## Guardrails

- **Never delete memory entries without user confirmation.** Reorganize, deduplicate, rotate, or archive — but never delete.
- **Progressive disclosure for reads.** Load only relevant sections from Tier 1. Dip into Tier 2 only when the task needs deep domain history. Never auto-load Tier 3 archives.
- **Respect the size budget.** Keep `.memory.md` under ~150 lines / ~15 KB. This is a hard limit — industry tooling (Claude Code, Cursor) silently truncates files beyond ~25 KB / ~200 lines. Rotation is not optional once the threshold is reached.
- **Merge, don't overwrite context.** When updating `.project-context.md`, preserve existing values and manually-added notes.
- **Project root only.** Context and memory files live at the project root. The `.memory/` directory also lives at the project root.
- **Structured entries.** Memory entries must include a date, domain tag, and summary. Unstructured notes degrade over time.
- **No secrets in memory.** Never persist API keys, tokens, passwords, or connection strings in any memory file.
- **Rotation markers are contracts.** When a domain section has a `<!-- older entries in .memory/<domain>.md -->` marker, the overflow file must exist and contain the rotated entries.

## References

- [Context Format](references/context-format.md) — Canonical `.project-context.md` structure and field definitions
- [Memory Format](references/memory-format.md) — Canonical `.memory.md` structure, domain sections, and entry format

## See Also

- **`project-detection`** — Calls this skill to load/persist project context during Phase 0.
- **`team-workflow`** — Calls this skill at start (read context/memory) and end (write memory).
- **`spec-templates`** — References project context for discipline-aware template selection.
