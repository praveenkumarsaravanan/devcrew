---
id: mem-002
dimension: memory
title: "Learning capture — workflow stores lessons in .memory.md"
sessions: 2
pass_threshold: 0.80
---

# MEM-002: Learning Capture and Recall

## Session 1 — Generate Learnings

### Task

Run a standard-change through `team-workflow`:

> "Add rate limiting to the /api/login endpoint — max 5 attempts per IP per minute using Redis."

### Expected Behavior

1. Workflow runs through to completion (implement + review + tests)
2. **Post-Workflow step fires:** "Capture Learnings" runs after the last phase
3. `.memory.md` is updated with entries such as:
   - Architecture decision: chose Redis for rate limiting (why)
   - Pattern: sliding window counter for rate limits
   - Review finding: whatever the review phase found
4. Entries are appended under the correct domain sections (e.g., `## Architecture`, `## Patterns`)

### Verification

Read `.memory.md` after the workflow. It should contain ≥2 new entries related to this task.

## Session 2 — Recall Prior Learning

### Task (new chat session)

> "Add rate limiting to the /api/register endpoint — same rules as login."

### Expected Behavior

1. Phase 0 loads `.memory.md` and finds prior rate limiting entries
2. The agent **references the prior decision** — e.g., "Last time we used Redis sliding window for rate limiting on /api/login. Should we follow the same pattern?"
3. Implementation follows the established pattern without re-deriving the approach

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Post-workflow captures learnings | 25% | .memory.md has new entries after Session 1 |
| Entries are categorized correctly | 15% | Entries appear under appropriate domain sections |
| Session 2 loads memory | 25% | Agent references prior rate limiting decision |
| Session 2 reuses pattern | 20% | Implementation follows Redis sliding window without re-deriving |
| Entries have timestamps | 15% | Each entry has a date marker |
