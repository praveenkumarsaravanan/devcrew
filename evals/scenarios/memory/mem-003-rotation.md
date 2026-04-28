---
id: mem-003
dimension: memory
title: "Memory rotation — triggers when .memory.md exceeds threshold"
pass_threshold: 0.80
---

# MEM-003: Memory Rotation

## Setup

Create a `.memory.md` file with ~160 lines of content (above the ~150 line threshold) spread across multiple domain sections. Include a mix of old entries (dated 3+ months ago) and recent entries (dated within the last week).

## Task

> "Record this architecture decision: we chose PostgreSQL over MongoDB for the order service because we need ACID transactions for payment processing."

### Expected Behavior

1. `memory-management` skill is activated (Operation 4: Write Memory)
2. **Before appending** the new entry, the skill detects the file exceeds ~150 lines
3. **Rotation triggers:**
   - Older entries are moved to `.memory/<domain>.md` files
   - The root `.memory.md` is trimmed to ≤150 lines
   - A rotation marker is added (e.g., `<!-- overflow: .memory/architecture.md -->`)
4. New entry is appended to the trimmed `.memory.md`
5. `.memory/` directory is created if it didn't exist

## Verification

After the operation:
- `.memory.md` should be ≤150 lines
- `.memory/` directory should exist with at least one domain file
- The new entry about PostgreSQL should be in `.memory.md`
- Older entries should be in `.memory/<domain>.md`, not deleted

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|---------------|
| Detects threshold exceeded | 20% | Agent notices file is over ~150 lines |
| Rotates older entries | 25% | Entries moved to .memory/<domain>.md |
| Root file trimmed | 20% | .memory.md is ≤150 lines after operation |
| New entry added | 15% | PostgreSQL decision is in .memory.md |
| No data loss | 20% | All rotated entries exist in overflow files |
