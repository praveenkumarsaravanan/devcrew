---
id: tri-001
dimension: triage
title: "Data-lifecycle RCA — delete-then-reuse, with a misdirecting symptom"
fixture: fixtures/member_import.js
planted_root_cause: "existingMembers deleted then reused to build dedup map"
red_herrings: 2
pass_threshold: 0.75
---

# TRI-001: Member import skips records — data-lifecycle root cause

## Setup

1. Place `evals/fixtures/member_import.js` in a test project with DevCrew installed.
2. Provide the failure artifact below as the incident's exception report.

## Task

> "Production issue: the member import for tenant ND ran and some members are
> missing afterward — they show as skipped. Triage `member_import.js` and tell me
> the root cause. Exception report row:
> `1286187760010|01-01-2023|...|SKIPPED|Duplicate entry. Member already exists`"

## The planted root cause

`processMemberImport` is wipe-and-replace: it calls `batchWrite(existingMembers, OPS_DELETE)` to delete all existing members, then builds `memberIndex` **from that same `existingMembers` array**. The dedup check `if (existing)` then skips file rows that match the stale index — i.e. matches against records that were just deleted. Skipped members are neither updated nor re-created; they disappear. **The bug is the reuse of `existingMembers` after it was deleted (a data-lifecycle defect), not the skip logic itself.**

## Red herrings (wrong directions the eval checks the agent AVOIDS)

1. **The skip line looks like normal duplicate handling.** Concluding "it correctly skips duplicates" or "the duplicate message is the bug" without tracing `memberIndex` back to the deleted `existingMembers` is the primary failure.
2. **`validateMemberSlot()` throws "Overlap error"** and looks like a plausible culprit — but it is **not called** on the skip path. Blaming the overlap validator is the wrong-direction trap (this is the exact mistake made in the real #1242 incident).

## Expected behavior

1. **Ingest the artifact first** — note the skip reason string and match it to the `if (existing)` branch.
2. **Read the whole function top-to-bottom** — see the `OPS_DELETE` call above the dedup map.
3. **Trace `memberIndex` to its source** — `existingMembers`, which was deleted on the prior line.
4. **Name the data-lifecycle root cause:** dedup map built from deleted data → false "duplicate" skips → records lost.
5. **Do NOT** blame `validateMemberSlot`/overlap (uncalled), and do NOT conclude the skip logic is correct.
6. State confidence; recommend the fix (don't delete first, OR don't dedup against the deleted list).

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Identifies delete-then-reuse root cause | 35% | Names that `existingMembers` is deleted then reused for the dedup map |
| Traced data lifecycle (not symptom-anchored) | 25% | Shows it read above the skip line / traced `memberIndex` to `existingMembers` |
| Ingested the failure artifact | 15% | Used the skip-reason string to locate the `if (existing)` branch |
| Avoided both red herrings | 15% | Did NOT blame `validateMemberSlot`/overlap; did NOT call the skip "correct" |
| Calibrated confidence + correct fix | 10% | States confidence; fix addresses the delete/reuse contradiction |

### Critical failure

If the agent names `validateMemberSlot`/the overlap logic as the root cause, OR concludes the import is "working correctly / just skipping duplicates," the eval is scored 0% — these are the exact misdirections this scenario exists to catch.
