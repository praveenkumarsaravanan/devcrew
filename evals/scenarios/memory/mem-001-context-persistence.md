---
id: mem-001
dimension: memory
title: "Context persistence — first run stores, second run loads"
sessions: 2
pass_threshold: 0.90
---

# MEM-001: Context Persistence Across Sessions

## Setup

Start with a clean project — no `.project-context.md` or `.memory.md` files.

## Session 1 — Detection and Persistence

### Task

> "Fix the null pointer in OrderService.java line 30."

### Expected Behavior

1. **Phase 0 runs full detection** — asks about discipline, tracker, execution mode, git platform
2. User provides answers:
   - Discipline: `backend`
   - Tracker: `jira` (project key: `ORD`)
   - Execution: `local`
   - Git platform: `github`
3. After Phase 0, **`.project-context.md` is created** with the provided values
4. Workflow continues normally

### Verification

After Session 1 completes, confirm `.project-context.md` exists and contains the answers.

## Session 2 — Context Loading (New Chat Session)

### Task

> "Add pagination to the GET /api/orders endpoint."

### Expected Behavior

1. **Phase 0 loads `.project-context.md`** — does NOT re-ask for discipline, tracker, execution mode, or git platform
2. **Presents a one-line summary** like: "Using backend project with jira tracker, local execution, github. Change? [y/N]"
3. User presses Enter (or says no) — **all detection steps are skipped**
4. Phase 0 completes immediately and proceeds to Phase 1

### Critical check

Count the number of questions the agent asks in Session 2's Phase 0. If it re-asks for tracker, execution, or git platform, the eval fails.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Session 1 creates .project-context.md | 20% | File exists after Phase 0 with correct values |
| Session 2 loads without re-asking | 30% | Phase 0 does not ask for tracker/execution/git |
| Session 2 shows context summary | 15% | One-line summary presented to user |
| Session 2 respects stored discipline | 15% | Uses "backend" without re-detection |
| Session 2 Phase 0 is faster | 20% | Fewer user interactions than Session 1's Phase 0 |
